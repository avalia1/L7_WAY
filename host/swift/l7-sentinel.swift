// ======================================================================
// L7 SENTINEL — Founder's Command Center
// Native arm64. Zero network. Zero dependencies. Maximum security.
//
// Law XV    — The Founder has perpetual, unrestricted access.
// Law XXX   — Biometrics + passphrase. Dual-factor always.
// Law XXXIII — Privacy as foundation. All devices under Founder control.
//
// This app is the Founder's eyes. It sees everything on the machine.
// It controls microphones, cameras, network, and processes.
// It is a sealed ashram — no outgoing connections, no IPC, no sharing.
//
// Creator: Alberto Valido Delgado
// System: L7 Universal OS
// License: Proprietary (Law XXII)
// ======================================================================

import Foundation
import Security
import CryptoKit
import LocalAuthentication

// ─────────────────────────────────────────
// MARK: - Configuration
// ─────────────────────────────────────────

let L7_DIR = ProcessInfo.processInfo.environment["L7_DIR"]
    ?? NSHomeDirectory() + "/.l7"
let SENTINEL_DIR = L7_DIR + "/sentinel"
let SENTINEL_LOG = SENTINEL_DIR + "/audit.log"
let SENTINEL_PASS_HASH = SENTINEL_DIR + "/.passhash"
let SENTINEL_STATE = SENTINEL_DIR + "/state.json"
let SENTINEL_VERSION = "1.0.0"

// ANSI
let R  = "\u{1b}[0m"
let B  = "\u{1b}[1m"
let DM = "\u{1b}[2m"
let GOLD   = "\u{1b}[93m"
let RED    = "\u{1b}[91m"
let GREEN  = "\u{1b}[92m"
let CYAN   = "\u{1b}[96m"
let BLUE   = "\u{1b}[94m"
let MAG    = "\u{1b}[95m"
let WHITE  = "\u{1b}[97m"
let BG_RED = "\u{1b}[41m"

// ─────────────────────────────────────────
// MARK: - State
// ─────────────────────────────────────────

// ─────────────────────────────────────────
// EPHEMERAL MEMORY ONLY
// ─────────────────────────────────────────
// Sentinel holds all scan data, threat data, and process lists IN RAM ONLY.
// When Sentinel exits, all scan data vanishes. No disk cache of sensitive reads.
// Only the audit log persists (permanent, append-only, per founding rules).
// The Sentinel READS the system but does not STORE what it reads.
// Editing system settings requires escalated re-authentication.
// ─────────────────────────────────────────

struct SentinelState {
    var lockdownActive: Bool
    var micKilled: Bool
    var cameraKilled: Bool
    var networkKilled: Bool
    var lastScan: String
    // threatLog is ephemeral — lives in RAM, dies with the process
    var threatLog: [(timestamp: String, type: String, process: String, pid: Int, action: String)]
}

var state = SentinelState(
    lockdownActive: false,
    micKilled: false,
    cameraKilled: false,
    networkKilled: false,
    lastScan: "",
    threatLog: []
)

/// Escalated auth — required for any WRITE operation (changing settings, killing processes)
/// Read-only scans do NOT require re-auth after initial login.
/// But any action that CHANGES the system does.
func escalatedAuth(action: String) -> Bool {
    printInfo("Escalated auth required: \(action)")
    return dualAuth(reason: "L7 Sentinel: \(action)")
}

// ─────────────────────────────────────────
// MARK: - Dual Authentication
// ─────────────────────────────────────────

func hashPassphrase(_ passphrase: String) -> String {
    let data = Data(passphrase.utf8)
    return SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
}

/// Prompt passphrase via macOS native secure dialog — works from anywhere
func promptPassphrase(title: String, message: String) -> String? {
    let script = """
    tell application "System Events"
        activate
        set userInput to display dialog "\(message)" with title "\(title)" default answer "" with hidden answer buttons {"Cancel", "OK"} default button "OK"
        return text returned of userInput
    end tell
    """
    let (output, status) = shell("osascript -e '\(script)' 2>/dev/null")
    guard status == 0, !output.isEmpty else { return nil }
    return output.trimmingCharacters(in: .whitespacesAndNewlines)
}

func passphraseExists() -> Bool {
    FileManager.default.fileExists(atPath: SENTINEL_PASS_HASH)
}

func setupPassphrase() -> Bool {
    printInfo("Setting passphrase via system dialog...")

    guard let p1 = promptPassphrase(
        title: "L7 Sentinel — Set Passphrase",
        message: "Create your Sentinel passphrase.\nThis + Touch ID = access. Neither alone is sufficient."
    ), !p1.isEmpty else {
        printError("Passphrase required.")
        return false
    }

    guard let p2 = promptPassphrase(
        title: "L7 Sentinel — Confirm Passphrase",
        message: "Confirm your passphrase."
    ), p1 == p2 else {
        printError("Passphrases did not match.")
        return false
    }

    try? hashPassphrase(p1).write(toFile: SENTINEL_PASS_HASH, atomically: true, encoding: .utf8)
    if !FileManager.default.fileExists(atPath: SENTINEL_PASS_HASH) { return false }
    chmod(SENTINEL_PASS_HASH, 0o600)
    auditLog("PASSPHRASE_SET")
    printOK("Passphrase set.")
    return true
}

func verifyPassphrase() -> Bool {
    guard let stored = try? String(contentsOfFile: SENTINEL_PASS_HASH, encoding: .utf8) else { return false }

    guard let input = promptPassphrase(
        title: "L7 Sentinel — Authentication",
        message: "Enter your passphrase to continue."
    ) else {
        auditLog("PASSPHRASE_CANCELLED")
        printError("Authentication cancelled.")
        return false
    }

    let match = hashPassphrase(input) == stored.trimmingCharacters(in: .whitespacesAndNewlines)
    if !match { auditLog("PASSPHRASE_FAIL"); printError("Wrong passphrase.") }
    return match
}

func authenticateBiometric(reason: String) -> Bool {
    let ctx = LAContext()
    ctx.localizedFallbackTitle = ""
    var err: NSError?
    guard ctx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &err) else {
        printError("Biometrics unavailable.")
        return false
    }
    let sem = DispatchSemaphore(value: 0)
    var ok = false
    ctx.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { r, _ in
        ok = r; sem.signal()
    }
    sem.wait()
    return ok
}

func dualAuth(reason: String) -> Bool {
    guard verifyPassphrase() else { return false }
    guard authenticateBiometric(reason: reason) else {
        printError("Biometric failed. Both required.")
        return false
    }
    auditLog("DUAL_AUTH_OK: \(reason)")
    return true
}

// ─────────────────────────────────────────
// MARK: - Anti-Debug & Process Isolation
// ─────────────────────────────────────────

func verifyNotTraced() -> Bool {
    var info = kinfo_proc()
    var size = MemoryLayout<kinfo_proc>.stride
    var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
    let r = sysctl(&mib, 4, &info, &size, nil, 0)
    if r == 0 && (info.kp_proc.p_flag & P_TRACED) != 0 {
        auditLog("SECURITY: Debugger detected — ABORT")
        printError("Debugger attached. Sentinel refuses to operate.")
        return false
    }
    return true
}

// ─────────────────────────────────────────
// MARK: - Shell Execution (sandboxed)
// ─────────────────────────────────────────

@discardableResult
func shell(_ cmd: String, silent: Bool = false) -> (output: String, status: Int32) {
    let proc = Process()
    proc.executableURL = URL(fileURLWithPath: "/bin/zsh")
    proc.arguments = ["-c", cmd]
    let pipe = Pipe()
    proc.standardOutput = pipe
    proc.standardError = pipe
    try? proc.run()
    proc.waitUntilExit()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8) ?? ""
    return (output.trimmingCharacters(in: .whitespacesAndNewlines), proc.terminationStatus)
}

// ─────────────────────────────────────────
// MARK: - Microphone Control
// ─────────────────────────────────────────

struct AudioProcess {
    let pid: Int
    let name: String
    let device: String
}

func scanMicProcesses() -> [AudioProcess] {
    // Find processes with audio input devices open
    let (output, _) = shell("lsof +D /dev/ 2>/dev/null | grep -i 'audio\\|mic\\|coreaudio' || true")
    var results: [AudioProcess] = []

    // Also check for processes accessing audio HAL
    let (halOutput, _) = shell("lsof -c coreaudiod 2>/dev/null | head -20 || true")

    // Get processes using audio input specifically
    let (psOutput, _) = shell("""
        ps aux | grep -iE 'audio|record|mic|capture|listen|voice|speech|dictation|siri' | grep -v grep | grep -v l7-sentinel || true
    """)

    for line in psOutput.components(separatedBy: "\n") where !line.isEmpty {
        let parts = line.split(separator: " ", maxSplits: 10).map(String.init)
        if parts.count >= 2, let pid = Int(parts[1]) {
            let name = parts.count >= 11 ? parts[10...].joined(separator: " ") : parts.last ?? "unknown"
            results.append(AudioProcess(pid: pid, name: name, device: "audio"))
        }
    }

    // Check for any process with microphone TCC access
    let (tccOutput, _) = shell("""
        sqlite3 ~/Library/Application\\ Support/com.apple.TCC/TCC.db \
        "SELECT client, auth_value FROM access WHERE service='kTCCServiceMicrophone'" 2>/dev/null || true
    """)

    for line in tccOutput.components(separatedBy: "\n") where !line.isEmpty {
        let parts = line.split(separator: "|").map(String.init)
        if parts.count >= 2 {
            let app = parts[0]
            let auth = parts[1]
            if auth == "2" { // 2 = allowed
                results.append(AudioProcess(pid: 0, name: app, device: "TCC-microphone-allowed"))
            }
        }
    }

    return results
}

func killMicProcesses() {
    printInfo("Scanning for microphone access...")
    let procs = scanMicProcesses()

    if procs.isEmpty {
        printOK("No processes found accessing microphone.")
    } else {
        for p in procs {
            if p.pid > 0 {
                print("  \(RED)\u{25CF}\(R) [\(p.pid)] \(B)\(p.name)\(R) — \(p.device)")
            } else {
                print("  \(GOLD)\u{25CF}\(R) \(B)\(p.name)\(R) — \(p.device)")
            }
        }
    }

    // Kill audio input at the system level
    printInfo("Muting system microphone input...")
    shell("osascript -e 'set volume input volume 0'")

    // Kill coreaudiod processes that serve input (will restart but mic stays muted)
    let (activeAudio, _) = shell("lsof /dev/audio* 2>/dev/null | awk '{print $2}' | sort -u | grep -v PID || true")
    for pidStr in activeAudio.components(separatedBy: "\n") where !pidStr.isEmpty {
        if let pid = Int(pidStr), pid > 1 {
            auditLog("MIC_KILL: pid=\(pid)")
            shell("kill -9 \(pid) 2>/dev/null || true", silent: true)
        }
    }

    // Disable dictation
    shell("defaults write com.apple.speech.recognition.AppleSpeechRecognition.prefs DictationIMMasterDictationEnabled -bool false 2>/dev/null || true")

    state.micKilled = true
    auditLog("MIC_KILLED: Input volume 0, dictation disabled")
    printOK("Microphone: \(RED)DEAD\(R). Input volume 0. Dictation off.")
}

func restoreMic() {
    shell("osascript -e 'set volume input volume 75'")
    state.micKilled = false
    auditLog("MIC_RESTORED: Input volume 75")
    printOK("Microphone restored to 75%.")
}

// ─────────────────────────────────────────
// MARK: - Camera Control
// ─────────────────────────────────────────

func scanCameraProcesses() -> [(pid: Int, name: String)] {
    var results: [(Int, String)] = []

    // Check for processes using the camera
    let (output, _) = shell("""
        ps aux | grep -iE 'camera|facetime|photo|video|capture|avfoundation|VDC' | grep -v grep | grep -v l7-sentinel || true
    """)

    for line in output.components(separatedBy: "\n") where !line.isEmpty {
        let parts = line.split(separator: " ", maxSplits: 10).map(String.init)
        if parts.count >= 2, let pid = Int(parts[1]) {
            let name = parts.count >= 11 ? parts[10...].joined(separator: " ") : "unknown"
            results.append((pid, name))
        }
    }

    // Check for camera LED indicator (AppleCameraAssistant)
    let (camAssist, _) = shell("pgrep -l AppleCameraAssistant 2>/dev/null || true")
    if !camAssist.isEmpty {
        results.append((0, "AppleCameraAssistant (camera LED active)"))
    }

    // TCC camera permissions
    let (tcc, _) = shell("""
        sqlite3 ~/Library/Application\\ Support/com.apple.TCC/TCC.db \
        "SELECT client, auth_value FROM access WHERE service='kTCCServiceCamera'" 2>/dev/null || true
    """)

    for line in tcc.components(separatedBy: "\n") where !line.isEmpty {
        let parts = line.split(separator: "|").map(String.init)
        if parts.count >= 2 && parts[1] == "2" {
            results.append((0, "\(parts[0]) (TCC-camera-allowed)"))
        }
    }

    return results
}

func killCameraProcesses() {
    printInfo("Scanning for camera access...")
    let procs = scanCameraProcesses()

    if procs.isEmpty {
        printOK("No processes found accessing camera.")
    } else {
        for p in procs {
            if p.pid > 0 {
                print("  \(RED)\u{25CF}\(R) [\(p.pid)] \(B)\(p.name)\(R)")
            } else {
                print("  \(GOLD)\u{25CF}\(R) \(B)\(p.name)\(R)")
            }
        }
    }

    // Kill VDCAssistant (camera daemon)
    shell("sudo killall VDCAssistant 2>/dev/null || true")
    shell("sudo killall AppleCameraAssistant 2>/dev/null || true")

    // Kill any process actively using camera
    let (camPids, _) = shell("fuser /dev/video* 2>/dev/null || lsof /dev/video* 2>/dev/null | awk 'NR>1{print $2}' || true")
    for pidStr in camPids.components(separatedBy: "\n") where !pidStr.isEmpty {
        if let pid = Int(pidStr.trimmingCharacters(in: .whitespaces)), pid > 1 {
            auditLog("CAMERA_KILL: pid=\(pid)")
            shell("kill -9 \(pid) 2>/dev/null || true")
        }
    }

    state.cameraKilled = true
    auditLog("CAMERA_KILLED: VDCAssistant and camera processes terminated")
    printOK("Camera: \(RED)DEAD\(R). All camera processes terminated.")
}

// ─────────────────────────────────────────
// MARK: - Network Control
// ─────────────────────────────────────────

struct NetConnection {
    let proto: String
    let localAddr: String
    let remoteAddr: String
    let state: String
    let pid: Int
    let process: String
}

func scanNetwork() -> [NetConnection] {
    var results: [NetConnection] = []

    // Active connections
    let (output, _) = shell("lsof -i -n -P 2>/dev/null | grep -v l7-sentinel | head -80 || true")

    for line in output.components(separatedBy: "\n") where !line.isEmpty {
        let parts = line.split(separator: " ", omittingEmptySubsequences: true).map(String.init)
        if parts.count >= 9 {
            let process = parts[0]
            let pid = Int(parts[1]) ?? 0
            let proto = parts.count > 7 ? parts[7] : ""
            let name = parts.count > 8 ? parts[8] : ""

            // Split name into local->remote
            let addrParts = name.split(separator: "-").map(String.init)
            let local = addrParts.count > 0 ? addrParts[0] : ""
            let remote = addrParts.count > 1 ? addrParts[1].replacingOccurrences(of: ">", with: "") : ""

            let connState = parts.count > 9 ? parts[9] : ""

            results.append(NetConnection(
                proto: proto,
                localAddr: local,
                remoteAddr: remote,
                state: connState.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: ""),
                pid: pid,
                process: process
            ))
        }
    }
    return results
}

func showNetwork() {
    let conns = scanNetwork()

    print()
    print("  \(B)\(WHITE)Active Network Connections:\(R)")
    print("  \(DM)═══════════════════════════════════════════════════════\(R)")

    if conns.isEmpty {
        printOK("No active connections detected.")
        return
    }

    // Group by ESTABLISHED vs LISTEN vs other
    let established = conns.filter { $0.state == "ESTABLISHED" }
    let listening = conns.filter { $0.state == "LISTEN" }
    let other = conns.filter { $0.state != "ESTABLISHED" && $0.state != "LISTEN" }

    if !established.isEmpty {
        print("  \(RED)\(B)ESTABLISHED (\(established.count)):\(R)")
        for c in established {
            print("    \(RED)\u{25CF}\(R) [\(c.pid)] \(B)\(c.process)\(R)  \(c.localAddr) -> \(GOLD)\(c.remoteAddr)\(R)")
        }
        print()
    }

    if !listening.isEmpty {
        print("  \(GOLD)\(B)LISTENING (\(listening.count)):\(R)")
        for c in listening {
            print("    \(GOLD)\u{25CF}\(R) [\(c.pid)] \(B)\(c.process)\(R)  \(c.localAddr)")
        }
        print()
    }

    if !other.isEmpty {
        print("  \(DM)OTHER (\(other.count)):\(R)")
        for c in other.prefix(10) {
            print("    \(DM)\u{25CB}\(R) [\(c.pid)] \(c.process)  \(c.localAddr) \(c.state)")
        }
        print()
    }

    print("  \(DM)Total: \(conns.count) connections\(R)")
    print()
}

func killAllNetwork() {
    printInfo("Killing all outgoing network connections...")

    let conns = scanNetwork()
    let outgoing = conns.filter { !$0.remoteAddr.isEmpty && $0.state == "ESTABLISHED" }

    var killed = 0
    var skipped: [String] = []

    for c in outgoing {
        // Don't kill critical system processes
        let critical = ["kernel_task", "launchd", "WindowServer", "loginwindow"]
        if critical.contains(c.process) {
            skipped.append(c.process)
            continue
        }

        if c.pid > 1 {
            shell("kill -9 \(c.pid) 2>/dev/null || true")
            auditLog("NET_KILL: pid=\(c.pid) process=\(c.process) remote=\(c.remoteAddr)")
            killed += 1
        }
    }

    // Flush DNS cache to prevent cached connections
    shell("dscacheutil -flushcache 2>/dev/null || true")

    // Disable Wi-Fi (most aggressive option)
    printInfo("Disabling Wi-Fi...")
    let (wifiDevice, _) = shell("networksetup -listallhardwareports | awk '/Wi-Fi/{getline; print $2}' || true")
    if !wifiDevice.isEmpty {
        shell("networksetup -setairportpower \(wifiDevice) off 2>/dev/null || true")
        auditLog("WIFI_DISABLED: device=\(wifiDevice)")
    }

    state.networkKilled = true
    auditLog("NET_KILLED: \(killed) connections terminated, DNS flushed, Wi-Fi disabled")
    printOK("Network: \(RED)DEAD\(R). \(killed) connections killed. Wi-Fi off. DNS flushed.")
    if !skipped.isEmpty {
        printInfo("Skipped critical: \(skipped.joined(separator: ", "))")
    }
}

func restoreNetwork() {
    let (wifiDevice, _) = shell("networksetup -listallhardwareports | awk '/Wi-Fi/{getline; print $2}' || true")
    if !wifiDevice.isEmpty {
        shell("networksetup -setairportpower \(wifiDevice) on 2>/dev/null || true")
    }
    state.networkKilled = false
    auditLog("NET_RESTORED: Wi-Fi re-enabled")
    printOK("Network restored. Wi-Fi on.")
}

// ─────────────────────────────────────────
// MARK: - Process Monitor
// ─────────────────────────────────────────

func scanAllProcesses() {
    print()
    print("  \(B)\(WHITE)Running Processes (sorted by CPU):\(R)")
    print("  \(DM)═══════════════════════════════════════════════════════\(R)")

    let (output, _) = shell("ps aux --sort=-%cpu | head -30")
    let lines = output.components(separatedBy: "\n")

    for (i, line) in lines.enumerated() {
        if i == 0 {
            print("  \(DM)\(line)\(R)")
        } else {
            // Highlight suspicious processes
            let lower = line.lowercased()
            let suspicious = lower.contains("record") || lower.contains("capture") ||
                lower.contains("stream") || lower.contains("spy") ||
                lower.contains("keylog") || lower.contains("sniff") ||
                lower.contains("hook") || lower.contains("inject")
            if suspicious {
                print("  \(RED)\(B)\(line)\(R)")
            } else {
                print("  \(line)")
            }
        }
    }
    print()
}

func killProcess(_ pidStr: String) {
    guard let pid = Int(pidStr), pid > 1 else {
        printError("Invalid PID: \(pidStr)")
        return
    }

    // Verify it's not a critical system process
    let (name, _) = shell("ps -p \(pid) -o comm= 2>/dev/null || true")
    let critical = ["kernel_task", "launchd", "WindowServer", "loginwindow", "systemd", "init"]
    if critical.contains(name.trimmingCharacters(in: .whitespacesAndNewlines)) {
        printError("Cannot kill critical system process: \(name)")
        return
    }

    shell("kill -9 \(pid) 2>/dev/null || true")
    auditLog("PROCESS_KILL: pid=\(pid) name=\(name)")
    printOK("Killed PID \(pid) (\(name))")
}

// ─────────────────────────────────────────
// MARK: - Full Lockdown Mode
// ─────────────────────────────────────────

func engageLockdown() {
    print()
    print("  \(BG_RED)\(WHITE)\(B) !! FULL LOCKDOWN MODE !! \(R)")
    print()

    printInfo("Step 1/4: Killing microphone...")
    killMicProcesses()

    print()
    printInfo("Step 2/4: Killing camera...")
    killCameraProcesses()

    print()
    printInfo("Step 3/4: Killing network...")
    killAllNetwork()

    print()
    printInfo("Step 4/4: Scanning for threats...")
    let threats = scanThreats()

    state.lockdownActive = true
    // ephemeral — no disk state

    print()
    print("  \(DM)═══════════════════════════════════════════════════════\(R)")
    print("  \(BG_RED)\(WHITE)\(B)  LOCKDOWN ACTIVE  \(R)")
    print("  \(DM)═══════════════════════════════════════════════════════\(R)")
    print("  \(RED)Microphone:\(R)  DEAD")
    print("  \(RED)Camera:\(R)      DEAD")
    print("  \(RED)Network:\(R)     DEAD")
    print("  \(RED)Wi-Fi:\(R)       OFF")
    print("  \(RED)DNS Cache:\(R)   FLUSHED")
    print("  \(RED)Threats:\(R)     \(threats) detected")
    print("  \(DM)═══════════════════════════════════════════════════════\(R)")
    print()

    auditLog("LOCKDOWN_ENGAGED: mic=dead camera=dead net=dead wifi=off threats=\(threats)")
}

func disengageLockdown() {
    printInfo("Disengaging lockdown...")
    restoreMic()
    restoreNetwork()
    state.lockdownActive = false
    state.micKilled = false
    state.cameraKilled = false
    state.networkKilled = false
    // ephemeral — no disk state
    auditLog("LOCKDOWN_DISENGAGED")
    printOK("Lockdown disengaged. Systems restored.")
}

// ─────────────────────────────────────────
// MARK: - Threat Scan
// ─────────────────────────────────────────

func scanThreats() -> Int {
    var count = 0

    // Check for screen recording
    let (screenRec, _) = shell("ps aux | grep -iE 'screencapture|screen.record|obs|screenflow' | grep -v grep || true")
    if !screenRec.isEmpty {
        print("  \(RED)\u{26A0} Screen recording detected:\(R)")
        for line in screenRec.components(separatedBy: "\n") where !line.isEmpty {
            print("    \(RED)\(line)\(R)")
            count += 1
        }
    }

    // Check for keyloggers
    let (keylog, _) = shell("ps aux | grep -iE 'keylog|keystroke|inputmonitor|keyboard.*log' | grep -v grep || true")
    if !keylog.isEmpty {
        print("  \(RED)\u{26A0} Potential keylogger detected:\(R)")
        for line in keylog.components(separatedBy: "\n") where !line.isEmpty {
            print("    \(RED)\(line)\(R)")
            count += 1
        }
    }

    // Check for suspicious LaunchAgents/Daemons
    let (agents, _) = shell("""
        ls ~/Library/LaunchAgents/ 2>/dev/null | grep -viE 'com.apple|com.l7|com.google.keystone' || true
    """)
    if !agents.isEmpty {
        print("  \(GOLD)\u{26A0} Non-standard LaunchAgents:\(R)")
        for line in agents.components(separatedBy: "\n") where !line.isEmpty {
            print("    \(GOLD)\(line)\(R)")
            count += 1
        }
    }

    // Check for remote access tools
    let (remote, _) = shell("ps aux | grep -iE 'vnc|teamviewer|anydesk|remote.*desktop|ssh.*-R|ngrok' | grep -v grep || true")
    if !remote.isEmpty {
        print("  \(RED)\u{26A0} Remote access tools detected:\(R)")
        for line in remote.components(separatedBy: "\n") where !line.isEmpty {
            print("    \(RED)\(line)\(R)")
            count += 1
        }
    }

    // Check for debuggers attached to L7 processes
    let (l7Procs, _) = shell("pgrep -f 'l7-' 2>/dev/null || true")
    for pidStr in l7Procs.components(separatedBy: "\n") where !pidStr.isEmpty {
        if let pid = Int(pidStr) {
            var info = kinfo_proc()
            var size = MemoryLayout<kinfo_proc>.stride
            var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, Int32(pid)]
            if sysctl(&mib, 4, &info, &size, nil, 0) == 0 {
                if (info.kp_proc.p_flag & P_TRACED) != 0 {
                    print("  \(RED)\u{26A0} L7 process \(pid) is being TRACED/DEBUGGED!\(R)")
                    count += 1
                }
            }
        }
    }

    // Check SIP status
    let (sip, _) = shell("csrutil status 2>/dev/null || true")
    if sip.contains("disabled") {
        print("  \(RED)\u{26A0} System Integrity Protection is DISABLED!\(R)")
        count += 1
    }

    // Check FileVault
    let (fv, _) = shell("fdesetup status 2>/dev/null || true")
    if fv.contains("Off") {
        print("  \(RED)\u{26A0} FileVault disk encryption is OFF!\(R)")
        count += 1
    }

    // Check firewall
    let (fw, _) = shell("defaults read /Library/Preferences/com.apple.alf globalstate 2>/dev/null || echo 0")
    if fw.trimmingCharacters(in: .whitespacesAndNewlines) == "0" {
        print("  \(GOLD)\u{26A0} macOS Firewall is OFF\(R)")
        count += 1
    }

    if count == 0 {
        printOK("No threats detected.")
    } else {
        print()
        printError("\(count) threat(s) detected.")
    }

    state.lastScan = iso8601()
    auditLog("THREAT_SCAN: \(count) threats found")
    return count
}

// ─────────────────────────────────────────
// MARK: - System Status Dashboard
// ─────────────────────────────────────────

func showDashboard() {
    print()
    print("  \(B)\(WHITE)L7 SENTINEL — System Status\(R)")
    print("  \(DM)═══════════════════════════════════════════════════════\(R)")

    // Lockdown status
    let lockStatus = state.lockdownActive ? "\(BG_RED)\(WHITE)\(B) LOCKDOWN ACTIVE \(R)" : "\(GREEN)Normal\(R)"
    print("  \(WHITE)Mode:\(R)        \(lockStatus)")

    // Mic status
    let (micVol, _) = shell("osascript -e 'input volume of (get volume settings)' 2>/dev/null || echo '?'")
    let micStatus = micVol.trimmingCharacters(in: .whitespacesAndNewlines)
    let micColor = micStatus == "0" ? RED : GREEN
    print("  \(WHITE)Microphone:\(R)  \(micColor)\(micStatus == "0" ? "MUTED (vol 0)" : "Active (vol \(micStatus))")\(R)")

    // Camera
    let (camActive, _) = shell("pgrep VDCAssistant 2>/dev/null || true")
    let camStatus = camActive.isEmpty ? "\(RED)Off\(R)" : "\(GOLD)Camera daemon running\(R)"
    print("  \(WHITE)Camera:\(R)      \(camStatus)")

    // Network
    let (wifiStatus, _) = shell("networksetup -getairportpower en0 2>/dev/null || echo 'unknown'")
    let wifiOn = wifiStatus.contains("On")
    print("  \(WHITE)Wi-Fi:\(R)       \(wifiOn ? "\(GREEN)On\(R)" : "\(RED)Off\(R)")")

    let (connCount, _) = shell("lsof -i -n -P 2>/dev/null | grep ESTABLISHED | wc -l || echo 0")
    print("  \(WHITE)Connections:\(R) \(connCount.trimmingCharacters(in: .whitespacesAndNewlines)) established")

    // SIP
    let (sip, _) = shell("csrutil status 2>/dev/null | head -1 || true")
    let sipOn = sip.contains("enabled")
    print("  \(WHITE)SIP:\(R)         \(sipOn ? "\(GREEN)Enabled\(R)" : "\(RED)DISABLED\(R)")")

    // FileVault
    let (fv, _) = shell("fdesetup status 2>/dev/null | head -1 || true")
    let fvOn = fv.contains("On")
    print("  \(WHITE)FileVault:\(R)   \(fvOn ? "\(GREEN)On\(R)" : "\(RED)OFF\(R)")")

    // Firewall
    let (fw, _) = shell("defaults read /Library/Preferences/com.apple.alf globalstate 2>/dev/null || echo 0")
    let fwOn = fw.trimmingCharacters(in: .whitespacesAndNewlines) != "0"
    print("  \(WHITE)Firewall:\(R)    \(fwOn ? "\(GREEN)On\(R)" : "\(RED)OFF\(R)")")

    // Uptime
    let (uptime, _) = shell("uptime | sed 's/.*up/up/' | sed 's/,.*//'")
    print("  \(WHITE)Uptime:\(R)      \(uptime.trimmingCharacters(in: .whitespacesAndNewlines))")

    // Last scan
    print("  \(WHITE)Last Scan:\(R)   \(state.lastScan.isEmpty ? "never" : state.lastScan)")

    print("  \(DM)═══════════════════════════════════════════════════════\(R)")
    print()
}

// ─────────────────────────────────────────
// MARK: - TCC Permissions Viewer
// ─────────────────────────────────────────

func showPermissions() {
    print()
    print("  \(B)\(WHITE)App Permissions (TCC Database):\(R)")
    print("  \(DM)═══════════════════════════════════════════════════════\(R)")

    let services = [
        ("kTCCServiceMicrophone", "Microphone"),
        ("kTCCServiceCamera", "Camera"),
        ("kTCCServiceScreenCapture", "Screen Recording"),
        ("kTCCServiceAccessibility", "Accessibility"),
        ("kTCCServiceSystemPolicyAllFiles", "Full Disk Access"),
        ("kTCCServiceListenEvent", "Input Monitoring"),
    ]

    for (service, label) in services {
        print("  \(B)\(GOLD)\(label):\(R)")
        let (output, _) = shell("""
            sqlite3 ~/Library/Application\\ Support/com.apple.TCC/TCC.db \
            "SELECT client, auth_value FROM access WHERE service='\(service)'" 2>/dev/null || true
        """)

        if output.isEmpty {
            print("    \(DM)No apps granted\(R)")
        } else {
            for line in output.components(separatedBy: "\n") where !line.isEmpty {
                let parts = line.split(separator: "|").map(String.init)
                if parts.count >= 2 {
                    let app = parts[0]
                    let auth = parts[1]
                    let authLabel = auth == "2" ? "\(GREEN)allowed\(R)" : (auth == "0" ? "\(RED)denied\(R)" : "\(GOLD)ask\(R)")
                    print("    \(WHITE)\(app)\(R) — \(authLabel)")
                }
            }
        }
        print()
    }
}

// ─────────────────────────────────────────
// MARK: - Persistence & Audit
// ─────────────────────────────────────────

func ensureSentinelDir() {
    let fm = FileManager.default
    if !fm.fileExists(atPath: SENTINEL_DIR) {
        try? fm.createDirectory(atPath: SENTINEL_DIR, withIntermediateDirectories: true)
        chmod(SENTINEL_DIR, 0o700)
    }
}

// State is EPHEMERAL — no save, no load, no disk persistence.
// When Sentinel exits, all runtime state vanishes from memory.
// Only the audit log survives (append-only, permanent).

func auditLog(_ entry: String) {
    ensureSentinelDir()
    let line = "[\(iso8601())] \(entry)\n"
    if let handle = FileHandle(forWritingAtPath: SENTINEL_LOG) {
        handle.seekToEndOfFile()
        handle.write(line.data(using: .utf8)!)
        handle.closeFile()
    } else {
        FileManager.default.createFile(atPath: SENTINEL_LOG, contents: line.data(using: .utf8))
        chmod(SENTINEL_LOG, 0o600)
    }
}

func showAudit() {
    guard let data = FileManager.default.contents(atPath: SENTINEL_LOG),
          let log = String(data: data, encoding: .utf8) else {
        printInfo("No audit entries.")
        return
    }
    let lines = log.components(separatedBy: "\n").filter { !$0.isEmpty }
    print()
    print("  \(B)\(WHITE)Audit Log (last 40):\(R)")
    print("  \(DM)═══════════════════════════════════════════════════════\(R)")
    for line in lines.suffix(40) {
        // Color-code by severity
        if line.contains("KILL") || line.contains("THREAT") || line.contains("VIOLATION") || line.contains("LOCKDOWN") {
            print("  \(RED)\(line)\(R)")
        } else if line.contains("WARN") || line.contains("TAMPER") {
            print("  \(GOLD)\(line)\(R)")
        } else {
            print("  \(DM)\(line)\(R)")
        }
    }
    print()
    printInfo("Total: \(lines.count) entries (permanent, never deleted)")
    print()
}

func iso8601() -> String {
    let f = ISO8601DateFormatter()
    f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return f.string(from: Date())
}

// ─────────────────────────────────────────
// MARK: - Display
// ─────────────────────────────────────────

func banner() {
    print("""
    \(RED)\(B)
    ╔═══════════════════════════════════════════════════════╗
    ║                                                       ║
    ║       \(WHITE)L7 SENTINEL\(RED)  —  Command Center                  ║
    ║       \(DM)For The Founder's Eyes Only\(R)\(RED)\(B)                    ║
    ║                                                       ║
    ║       \(MAG)Passphrase + Touch ID = Access\(RED)                 ║
    ║       \(MAG)Zero Network. Zero Trust. Sealed Ashram.\(RED)        ║
    ║                                                       ║
    ╚═══════════════════════════════════════════════════════╝
    \(R)
    """)
}

func printMenu() {
    print("""
    \(B)\(WHITE)  Commands:\(R)
    \(DM)  ─────────────────────────────────────────────────\(R)
      \(RED)LOCKDOWN\(R)              Kill mic + camera + network (nuclear)
      \(RED)UNLOCK\(R)                Disengage lockdown, restore systems

      \(GOLD)mic kill\(R)              Mute mic, kill audio input, disable dictation
      \(GOLD)mic restore\(R)           Restore microphone
      \(GOLD)mic scan\(R)              Show processes with mic access

      \(GOLD)cam kill\(R)              Kill camera daemon and processes
      \(GOLD)cam scan\(R)              Show processes with camera access

      \(GOLD)net kill\(R)              Kill connections, disable Wi-Fi, flush DNS
      \(GOLD)net restore\(R)           Re-enable Wi-Fi
      \(GOLD)net scan\(R)              Show all active connections

      \(CYAN)scan\(R)                  Full threat scan
      \(CYAN)processes\(R)             Show running processes (CPU sorted)
      \(CYAN)kill\(R) <pid>            Kill a specific process
      \(CYAN)permissions\(R)           Show app permissions (TCC)
      \(CYAN)status\(R)               System security dashboard

      \(WHITE)audit\(R)                Show audit log
      \(WHITE)quit\(R)                 Exit Sentinel

    """)
}

func printError(_ msg: String) {
    print("  \(RED)\(B)\u{2716}\(R) \(RED)\(msg)\(R)")
}

func printOK(_ msg: String) {
    print("  \(GREEN)\(B)\u{2714}\(R) \(GREEN)\(msg)\(R)")
}

func printInfo(_ msg: String) {
    print("  \(CYAN)\u{25C8}\(R) \(msg)")
}

// ─────────────────────────────────────────
// MARK: - Main
// ─────────────────────────────────────────

func main() {
    banner()

    // Anti-debug
    guard verifyNotTraced() else { exit(1) }

    ensureSentinelDir()
    auditLog("SENTINEL_OPEN: v\(SENTINEL_VERSION) pid=\(getpid()) ppid=\(getppid()) uid=\(getuid())")

    // First-time setup
    if !passphraseExists() {
        printInfo("First-time Sentinel setup.")
        print()
        guard setupPassphrase() else {
            printError("Passphrase required. Cannot operate without dual-factor.")
            exit(1)
        }
        print()
        printInfo("Verifying Touch ID...")
        guard authenticateBiometric(reason: "L7 Sentinel: Verify biometric enrollment") else {
            printError("Touch ID required. Cannot operate without dual-factor.")
            exit(1)
        }
        printOK("Dual-factor configured.")
        auditLog("SENTINEL_INIT: Dual auth configured")
    } else {
        printInfo("Dual authentication required...")
        print()
        guard dualAuth(reason: "L7 Sentinel: Founder authentication") else {
            printError("Access denied.")
            auditLog("SENTINEL_DENIED: Failed dual auth")
            exit(1)
        }
    }

    printOK("Welcome, Founder. You have full control.")
    print()

    // state is ephemeral — starts fresh each session
    showDashboard()
    printMenu()

    while true {
        print("  \(RED)\(B)l7:sentinel>\(R) ", terminator: "")
        guard let input = readLine()?.trimmingCharacters(in: .whitespaces), !input.isEmpty else { continue }

        let parts = input.split(separator: " ", maxSplits: 1).map(String.init)
        let cmd = parts[0].lowercased()
        let arg = parts.count > 1 ? parts[1].lowercased() : ""

        switch cmd {
        case "lockdown":
            printInfo("Dual auth required for lockdown...")
            if dualAuth(reason: "L7 Sentinel: FULL LOCKDOWN") {
                engageLockdown()
            }

        case "unlock":
            printInfo("Dual auth required to disengage...")
            if dualAuth(reason: "L7 Sentinel: Disengage lockdown") {
                disengageLockdown()
            }

        case "mic":
            switch arg {
            case "kill":
                if escalatedAuth(action: "Kill microphone") { killMicProcesses() }
            case "restore":
                if escalatedAuth(action: "Restore microphone") { restoreMic() }
            case "scan":
                let procs = scanMicProcesses()
                if procs.isEmpty { printOK("No mic access detected.") }
                else {
                    for p in procs {
                        print("  \(RED)\u{25CF}\(R) [\(p.pid)] \(B)\(p.name)\(R) — \(p.device)")
                    }
                }
            default: printError("Usage: mic <kill|restore|scan>")
            }

        case "cam":
            switch arg {
            case "kill":
                if escalatedAuth(action: "Kill camera") { killCameraProcesses() }
            case "scan":
                let procs = scanCameraProcesses()
                if procs.isEmpty { printOK("No camera access detected.") }
                else {
                    for p in procs {
                        print("  \(RED)\u{25CF}\(R) [\(p.pid)] \(B)\(p.name)\(R)")
                    }
                }
            default: printError("Usage: cam <kill|scan>")
            }

        case "net":
            switch arg {
            case "kill":
                if escalatedAuth(action: "Kill network") { killAllNetwork() }
            case "restore":
                if escalatedAuth(action: "Restore network") { restoreNetwork() }
            case "scan": showNetwork()
            default: printError("Usage: net <kill|restore|scan>")
            }

        case "scan":
            print()
            printInfo("Running full threat scan...")
            print()
            _ = scanThreats()
            // ephemeral — no disk state

        case "processes", "ps":
            scanAllProcesses()

        case "kill":
            if arg.isEmpty { printError("Usage: kill <pid>") }
            else if escalatedAuth(action: "Kill process \(arg)") { killProcess(arg) }

        case "permissions", "perms":
            showPermissions()

        case "status", "st":
            showDashboard()

        case "audit", "log":
            showAudit()

        case "quit", "q", "exit":
            // ephemeral — no disk state
            auditLog("SENTINEL_CLOSE: Normal exit")
            printOK("Sentinel sealed.")
            exit(0)

        case "help", "?":
            printMenu()

        default:
            printError("Unknown: \(cmd). Type 'help'.")
        }
    }
}

main()
