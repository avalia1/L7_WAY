// ======================================================================
// L7 GATEWAY — One-Way Network Gate & Passwordless Auth
// Native arm64. The vessel's membrane. Data in, nothing out.
//
// Law I     — All flows through the Gateway. No exceptions.
// Law XV    — The Founder has perpetual, unrestricted access.
// Law XXX   — Biometrics only. No passwords in the OS.
// Law XXXIII — Privacy as foundation.
//
// NETWORK: One-way valve. Data enters atomized, gets remade inside.
//          Nothing leaves without Founder's explicit, authenticated approval.
//
// AUTH: Passwordless OS. Touch ID for everything local.
//       External passwords live in the Wallet (keykeeper).
//       The Gateway mediates — you never type a password again.
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
let GW_DIR = L7_DIR + "/gateway"
let GW_LOG = GW_DIR + "/audit.log"
let GW_CREDS = GW_DIR + "/keykeeper.enc"
let GW_FIREWALL = GW_DIR + "/firewall.pf"
let GW_WHITELIST = GW_DIR + "/whitelist.json"
let GW_VERSION = "1.0.0"

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
let BG_GRN = "\u{1b}[42m"

// ─────────────────────────────────────────
// MARK: - Biometric Auth (Passwordless)
// ─────────────────────────────────────────

func bioAuth(reason: String) -> Bool {
    let ctx = LAContext()
    ctx.localizedFallbackTitle = ""  // No password fallback — ever
    var err: NSError?
    guard ctx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &err) else {
        printError("Biometrics unavailable: \(err?.localizedDescription ?? "unknown")")
        return false
    }
    let sem = DispatchSemaphore(value: 0)
    var ok = false
    ctx.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { r, _ in
        ok = r; sem.signal()
    }
    sem.wait()
    if ok { auditLog("AUTH_OK: \(reason)") }
    else { auditLog("AUTH_FAIL: \(reason)") }
    return ok
}

// ─────────────────────────────────────────
// MARK: - Anti-Debug
// ─────────────────────────────────────────

func verifyNotTraced() -> Bool {
    var info = kinfo_proc()
    var size = MemoryLayout<kinfo_proc>.stride
    var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
    let r = sysctl(&mib, 4, &info, &size, nil, 0)
    if r == 0 && (info.kp_proc.p_flag & P_TRACED) != 0 {
        auditLog("SECURITY: Debugger — ABORT")
        return false
    }
    return true
}

// ─────────────────────────────────────────
// MARK: - Shell
// ─────────────────────────────────────────

@discardableResult
func shell(_ cmd: String) -> (output: String, status: Int32) {
    let proc = Process()
    proc.executableURL = URL(fileURLWithPath: "/bin/zsh")
    proc.arguments = ["-c", cmd]
    let pipe = Pipe()
    proc.standardOutput = pipe
    proc.standardError = Pipe()
    try? proc.run()
    proc.waitUntilExit()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    return (String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "", proc.terminationStatus)
}

// ─────────────────────────────────────────
// MARK: - One-Way Network Valve
// ─────────────────────────────────────────
// Principle: Data flows IN. Nothing flows OUT without explicit approval.
// Implementation: pf (packet filter) rules + process whitelisting.
//
// Allowed outgoing: DNS (port 53), DHCP, whitelisted apps only.
// All other outgoing: BLOCKED and LOGGED.
// Incoming: Already blocked by macOS firewall + stealth mode.

struct WhitelistEntry: Codable {
    let app: String          // process name
    let direction: String    // "in" or "both" (never "out" alone)
    let ports: [Int]         // allowed ports
    let reason: String
    let addedAt: String
}

var whitelist: [WhitelistEntry] = []

func loadWhitelist() {
    guard let data = FileManager.default.contents(atPath: GW_WHITELIST),
          let list = try? JSONDecoder().decode([WhitelistEntry].self, from: data) else {
        // Default whitelist — minimal, essential only
        whitelist = [
            WhitelistEntry(app: "mDNSResponder", direction: "both", ports: [53, 5353], reason: "DNS resolution (system)", addedAt: iso8601()),
            WhitelistEntry(app: "configd", direction: "both", ports: [67, 68], reason: "DHCP (system)", addedAt: iso8601()),
        ]
        return
    }
    whitelist = list
}

func saveWhitelist() {
    if let data = try? JSONEncoder().encode(whitelist),
       let obj = try? JSONSerialization.jsonObject(with: data),
       let pretty = try? JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted) {
        try? pretty.write(to: URL(fileURLWithPath: GW_WHITELIST))
    }
}

func generateFirewallRules() -> String {
    var rules = """
    # ══════════════════════════════════════════════
    # L7 GATEWAY — One-Way Valve Firewall Rules
    # Generated: \(iso8601())
    # Principle: Data IN only. Nothing OUT without approval.
    # ══════════════════════════════════════════════

    # Default: block everything outgoing
    set block-policy drop
    set skip on lo0

    # Allow established connections (responses to our requests)
    pass in quick on en0 keep state

    # Allow loopback
    pass quick on lo0 all

    # Allow DHCP
    pass out quick on en0 proto udp from any to any port {67, 68}

    # Allow DNS (essential for any connectivity)
    pass out quick on en0 proto {udp, tcp} from any to any port 53


    """

    // Add whitelisted apps' ports
    for entry in whitelist {
        if entry.direction == "both" && !entry.ports.isEmpty {
            let portList = entry.ports.map(String.init).joined(separator: ", ")
            rules += "    # \(entry.app): \(entry.reason)\n"
            rules += "    pass out quick on en0 proto {tcp, udp} from any to any port {\(portList)}\n\n"
        }
    }

    rules += """

    # Block and log everything else outgoing
    block drop log out quick on en0 all

    # Allow all incoming that's part of established state
    pass in on en0 proto tcp from any to any flags S/SA keep state
    """

    return rules
}

func showFirewallStatus() {
    print()
    print("  \(B)\(WHITE)One-Way Valve Status:\(R)")
    print("  \(DM)═══════════════════════════════════════════════════════\(R)")

    // macOS firewall
    let (fwState, _) = shell("/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate 2>/dev/null")
    let (stealth, _) = shell("/usr/libexec/ApplicationFirewall/socketfilterfw --getstealthmode 2>/dev/null")
    print("  \(WHITE)App Firewall:\(R)  \(fwState.contains("blocking") ? "\(GREEN)ON\(R)" : "\(RED)OFF\(R)")")
    print("  \(WHITE)Stealth Mode:\(R)  \(stealth.contains("on") ? "\(GREEN)ON\(R)" : "\(RED)OFF\(R)")")

    // Current outgoing connections
    let (conns, _) = shell("lsof -i -n -P 2>/dev/null | grep ESTABLISHED | awk '{print $1, $9}' | sort -u")
    let connLines = conns.components(separatedBy: "\n").filter { !$0.isEmpty }

    let outgoing = connLines.filter { !$0.contains("127.0.0.1") }
    let local = connLines.filter { $0.contains("127.0.0.1") }

    print("  \(WHITE)Connections:\(R)   \(connLines.count) total, \(outgoing.count) external, \(local.count) local")
    print()

    if !outgoing.isEmpty {
        print("  \(GOLD)External connections:\(R)")
        for c in outgoing {
            let parts = c.split(separator: " ").map(String.init)
            let app = parts.first ?? "?"
            let addr = parts.count > 1 ? parts[1] : "?"

            // Check if whitelisted
            let isWhitelisted = whitelist.contains(where: { app.contains($0.app) })
            let status = isWhitelisted ? "\(GREEN)whitelisted\(R)" : "\(RED)UNAUTHORIZED\(R)"
            print("    \(app)  \(addr)  \(status)")
        }
    }
    print()

    // Whitelist
    print("  \(B)\(WHITE)Whitelist:\(R)")
    if whitelist.isEmpty {
        print("    \(DM)No entries\(R)")
    } else {
        for w in whitelist {
            print("    \(GREEN)\u{25CF}\(R) \(B)\(w.app)\(R) — ports \(w.ports) — \(w.reason)")
        }
    }
    print()

    // Listening ports
    let (listening, _) = shell("lsof -i -n -P 2>/dev/null | grep LISTEN | awk '{print $1, $9}' | sort -u")
    if !listening.isEmpty {
        print("  \(GOLD)Listening ports:\(R)")
        for l in listening.components(separatedBy: "\n") where !l.isEmpty {
            print("    \(DM)\(l)\(R)")
        }
    }
    print()
}

func enforceOneWay() {
    printInfo("Generating one-way firewall rules...")
    let rules = generateFirewallRules()

    // Write rules file
    try? rules.write(toFile: GW_FIREWALL, atomically: true, encoding: .utf8)
    printOK("Rules written to \(GW_FIREWALL)")

    print()
    print("  \(DM)Generated rules:\(R)")
    for line in rules.components(separatedBy: "\n").prefix(25) {
        print("  \(DM)\(line)\(R)")
    }
    print("  \(DM)...\(R)")
    print()

    printInfo("To activate, run with sudo:")
    print("    \(GOLD)sudo pfctl -f \(GW_FIREWALL) && sudo pfctl -e\(R)")
    print()
    printInfo("To disable:")
    print("    \(GOLD)sudo pfctl -d\(R)")
    print()

    auditLog("FIREWALL_RULES_GENERATED: \(whitelist.count) whitelisted apps")
}

func killUnauthorized() {
    let (conns, _) = shell("lsof -i -n -P 2>/dev/null | grep ESTABLISHED | awk '{print $1, $2, $9}' | sort -u")

    var killed = 0
    for line in conns.components(separatedBy: "\n") where !line.isEmpty {
        let parts = line.split(separator: " ").map(String.init)
        guard parts.count >= 3 else { continue }
        let app = parts[0]
        let pid = Int(parts[1]) ?? 0
        let addr = parts[2]

        if addr.contains("127.0.0.1") || addr.contains("192.168") { continue }

        let isWhitelisted = whitelist.contains(where: { app.contains($0.app) })
        if !isWhitelisted && pid > 1 {
            let critical = ["kernel_task", "launchd", "WindowServer", "loginwindow", "mDNSResponder", "configd"]
            if !critical.contains(app) {
                shell("kill -9 \(pid) 2>/dev/null || true")
                auditLog("NET_KILL_UNAUTHORIZED: pid=\(pid) app=\(app) addr=\(addr)")
                printError("Killed: \(app) [\(pid)] -> \(addr)")
                killed += 1
            }
        }
    }

    if killed == 0 {
        printOK("No unauthorized connections found.")
    } else {
        printOK("\(killed) unauthorized connections terminated.")
    }
}

// ─────────────────────────────────────────
// MARK: - Passwordless Keykeeper
// ─────────────────────────────────────────
// External passwords stored in macOS Keychain with Touch ID.
// You never type passwords. Touch ID retrieves them.
// The Gateway mediates between you and the outside world.

struct Credential: Codable {
    let service: String      // e.g., "github.com", "gmail"
    let username: String
    let createdAt: String
    let lastUsed: String
}

func keykeeperTag(_ service: String) -> String {
    "cloud.avli.l7.keykeeper.\(service.lowercased().replacingOccurrences(of: " ", with: "-"))"
}

func storeCredential(service: String, username: String, password: String) -> Bool {
    let tag = keykeeperTag(service)

    // Touch ID protected
    let access = SecAccessControlCreateWithFlags(
        nil,
        kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
        .biometryCurrentSet,
        nil
    )!

    let query: [String: Any] = [
        kSecClass as String:              kSecClassGenericPassword,
        kSecAttrService as String:        "L7Keykeeper",
        kSecAttrAccount as String:        tag,
        kSecValueData as String:          Data(password.utf8),
        kSecAttrAccessControl as String:  access,
        kSecAttrLabel as String:          "L7 Keykeeper — \(service)",
        kSecAttrComment as String:        "user: \(username)",
    ]

    SecItemDelete(query as CFDictionary)
    let status = SecItemAdd(query as CFDictionary, nil)
    guard status == errSecSuccess else {
        printError("Keychain store failed: \(status)")
        return false
    }

    auditLog("CRED_STORE: \(service) user=\(username)")
    return true
}

func retrieveCredential(service: String) -> (username: String, password: String)? {
    let tag = keykeeperTag(service)

    let query: [String: Any] = [
        kSecClass as String:           kSecClassGenericPassword,
        kSecAttrService as String:     "L7Keykeeper",
        kSecAttrAccount as String:     tag,
        kSecReturnData as String:      true,
        kSecReturnAttributes as String: true,
    ]

    var result: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &result)

    guard status == errSecSuccess,
          let dict = result as? [String: Any],
          let data = dict[kSecValueData as String] as? Data,
          let password = String(data: data, encoding: .utf8) else {
        return nil
    }

    // Extract username from comment
    let comment = dict[kSecAttrComment as String] as? String ?? ""
    let username = comment.replacingOccurrences(of: "user: ", with: "")

    auditLog("CRED_ACCESS: \(service)")
    return (username, password)
}

func listCredentials() -> [(service: String, tag: String)] {
    let query: [String: Any] = [
        kSecClass as String:           kSecClassGenericPassword,
        kSecAttrService as String:     "L7Keykeeper",
        kSecReturnAttributes as String: true,
        kSecMatchLimit as String:      kSecMatchLimitAll,
    ]

    var result: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &result)
    guard status == errSecSuccess, let items = result as? [[String: Any]] else {
        return []
    }

    return items.compactMap { item in
        guard let account = item[kSecAttrAccount as String] as? String,
              let label = item[kSecAttrLabel as String] as? String else { return nil }
        let service = label.replacingOccurrences(of: "L7 Keykeeper — ", with: "")
        return (service, account)
    }
}

func deleteCredential(service: String) -> Bool {
    let tag = keykeeperTag(service)
    let query: [String: Any] = [
        kSecClass as String:           kSecClassGenericPassword,
        kSecAttrService as String:     "L7Keykeeper",
        kSecAttrAccount as String:     tag,
    ]
    let status = SecItemDelete(query as CFDictionary)
    auditLog("CRED_DELETE: \(service)")
    return status == errSecSuccess
}

// ─────────────────────────────────────────
// MARK: - Credential Commands
// ─────────────────────────────────────────

func promptDialog(title: String, message: String, hidden: Bool = false) -> String? {
    let hiddenFlag = hidden ? " with hidden answer" : ""
    let script = """
    tell application "System Events"
        activate
        set userInput to display dialog "\(message)" with title "\(title)" default answer ""\(hiddenFlag) buttons {"Cancel", "OK"} default button "OK"
        return text returned of userInput
    end tell
    """
    let (output, status) = shell("osascript -e '\(script)' 2>/dev/null")
    guard status == 0, !output.isEmpty else { return nil }
    return output
}

func cmdStoreCred() {
    print()
    printInfo("Touch ID to store new credential...")
    guard bioAuth(reason: "L7 Gateway: Store credential") else { return }

    guard let service = promptDialog(title: "L7 Keykeeper — Service", message: "Service name (e.g., github.com, gmail):"),
          !service.isEmpty else {
        printError("Service required.")
        return
    }

    guard let username = promptDialog(title: "L7 Keykeeper — Username", message: "Username or email for \(service):"),
          !username.isEmpty else {
        printError("Username required.")
        return
    }

    guard let password = promptDialog(title: "L7 Keykeeper — Password", message: "Password for \(service):", hidden: true),
          !password.isEmpty else {
        printError("Password required.")
        return
    }

    if storeCredential(service: service, username: username, password: password) {
        printOK("Credential stored: \(service) (\(username))")
        printInfo("Touch ID will retrieve it. You never type this password again.")
    }
    print()
}

func cmdGetCred(service: String) {
    printInfo("Touch ID to retrieve credential...")
    // Touch ID is automatically triggered by Keychain access with biometric protection

    guard let cred = retrieveCredential(service: service) else {
        printError("No credential found for: \(service)")
        return
    }

    print()
    print("  \(B)\(WHITE)\(service)\(R)")
    print("  \(DM)────────────────────────────\(R)")
    print("  \(WHITE)User:\(R) \(CYAN)\(cred.username)\(R)")
    print("  \(WHITE)Pass:\(R) \(DM)****\(R) (in clipboard for 30s)")

    // Copy to clipboard temporarily
    shell("echo -n '\(cred.password.replacingOccurrences(of: "'", with: "'\\''"))' | pbcopy")

    // Clear clipboard after 30 seconds
    DispatchQueue.global().asyncAfter(deadline: .now() + 30) {
        shell("echo '' | pbcopy")
        auditLog("CLIPBOARD_CLEARED: \(service)")
    }

    auditLog("CRED_COPIED: \(service) — clipboard clears in 30s")
    print()
}

func cmdListCreds() {
    let creds = listCredentials()
    print()
    print("  \(B)\(WHITE)Stored Credentials (Keykeeper):\(R)")
    print("  \(DM)═══════════════════════════════════════\(R)")

    if creds.isEmpty {
        printInfo("No credentials stored yet.")
    } else {
        for (i, c) in creds.enumerated() {
            print("  \(GREEN)\u{25CF}\(R) \(B)\(c.service)\(R)")
        }
        print()
        printInfo("\(creds.count) credential(s). Touch ID retrieves. You never type passwords.")
    }
    print()
}

// ─────────────────────────────────────────
// MARK: - Whitelist Management
// ─────────────────────────────────────────

func cmdWhitelistAdd() {
    guard let app = promptDialog(title: "L7 Gateway — Whitelist", message: "Process name to whitelist (e.g., Brave, curl):"),
          !app.isEmpty else { return }

    guard let portStr = promptDialog(title: "L7 Gateway — Ports", message: "Allowed ports (comma-separated, e.g., 443,80):"),
          !portStr.isEmpty else { return }

    guard let reason = promptDialog(title: "L7 Gateway — Reason", message: "Why does \(app) need network? (audit trail):"),
          !reason.isEmpty else { return }

    let ports = portStr.split(separator: ",").compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }

    let entry = WhitelistEntry(app: app, direction: "both", ports: ports, reason: reason, addedAt: iso8601())
    whitelist.append(entry)
    saveWhitelist()

    auditLog("WHITELIST_ADD: \(app) ports=\(ports) reason=\(reason)")
    printOK("Whitelisted: \(app) on ports \(ports)")
}

func cmdWhitelistRemove(app: String) {
    let before = whitelist.count
    whitelist.removeAll(where: { $0.app.lowercased() == app.lowercased() })
    if whitelist.count < before {
        saveWhitelist()
        auditLog("WHITELIST_REMOVE: \(app)")
        printOK("Removed: \(app)")
    } else {
        printError("Not found: \(app)")
    }
}

// ─────────────────────────────────────────
// MARK: - Audit & Persistence
// ─────────────────────────────────────────

func ensureGWDir() {
    let fm = FileManager.default
    if !fm.fileExists(atPath: GW_DIR) {
        try? fm.createDirectory(atPath: GW_DIR, withIntermediateDirectories: true)
        chmod(GW_DIR, 0o700)
    }
}

func auditLog(_ entry: String) {
    ensureGWDir()
    let line = "[\(iso8601())] \(entry)\n"
    if let handle = FileHandle(forWritingAtPath: GW_LOG) {
        handle.seekToEndOfFile()
        handle.write(line.data(using: .utf8)!)
        handle.closeFile()
    } else {
        FileManager.default.createFile(atPath: GW_LOG, contents: line.data(using: .utf8))
        chmod(GW_LOG, 0o600)
    }
}

func showAudit() {
    guard let data = FileManager.default.contents(atPath: GW_LOG),
          let log = String(data: data, encoding: .utf8) else {
        printInfo("No audit entries.")
        return
    }
    let lines = log.components(separatedBy: "\n").filter { !$0.isEmpty }
    print()
    print("  \(B)\(WHITE)Gateway Audit (last 30):\(R)")
    print("  \(DM)═══════════════════════════════════════\(R)")
    for line in lines.suffix(30) {
        if line.contains("KILL") || line.contains("FAIL") || line.contains("UNAUTHORIZED") {
            print("  \(RED)\(line)\(R)")
        } else if line.contains("CRED") || line.contains("WHITELIST") {
            print("  \(GOLD)\(line)\(R)")
        } else {
            print("  \(DM)\(line)\(R)")
        }
    }
    printInfo("Total: \(lines.count) entries (permanent)")
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
    \(BLUE)\(B)
    ╔═══════════════════════════════════════════════════════╗
    ║                                                       ║
    ║       \(WHITE)L7 GATEWAY\(BLUE)  —  One-Way Valve                   ║
    ║       \(DM)Data In. Nothing Out. Passwordless.\(R)\(BLUE)\(B)           ║
    ║                                                       ║
    ║       \(MAG)Touch ID = Access. No passwords in the OS.\(BLUE)     ║
    ║       \(MAG)External passwords live in Keykeeper.\(BLUE)          ║
    ║                                                       ║
    ╚═══════════════════════════════════════════════════════╝
    \(R)
    """)
}

func printMenu() {
    print("""
    \(B)\(WHITE)  Commands:\(R)
    \(DM)  ─────────────────────────────────────────────────\(R)
      \(BLUE)\(B)NETWORK\(R)
      \(GOLD)valve\(R)                Show one-way valve status
      \(GOLD)enforce\(R)              Generate & show firewall rules
      \(GOLD)kill-unauth\(R)          Kill all unauthorized connections
      \(GOLD)whitelist\(R)            Show whitelisted apps
      \(GOLD)whitelist add\(R)        Add app to whitelist (Touch ID)
      \(GOLD)whitelist rm\(R) <app>   Remove app from whitelist

      \(BLUE)\(B)KEYKEEPER (Passwordless)\(R)
      \(GOLD)creds\(R)               List stored credentials
      \(GOLD)store\(R)               Store new credential (Touch ID)
      \(GOLD)get\(R) <service>       Retrieve credential -> clipboard
      \(GOLD)delete\(R) <service>    Delete credential (Touch ID)

      \(BLUE)\(B)SYSTEM\(R)
      \(GOLD)audit\(R)               Show audit log
      \(GOLD)quit\(R)                Exit Gateway

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

    guard verifyNotTraced() else {
        printError("Debugger detected. Gateway refuses to operate.")
        exit(1)
    }

    ensureGWDir()
    auditLog("GATEWAY_OPEN: v\(GW_VERSION) pid=\(getpid()) uid=\(getuid())")

    printInfo("Touch ID required...")
    guard bioAuth(reason: "L7 Gateway: Founder authentication") else {
        printError("Access denied.")
        auditLog("GATEWAY_DENIED")
        exit(1)
    }

    printOK("Welcome, Founder. Gateway active.")
    print()

    loadWhitelist()
    showFirewallStatus()
    printMenu()

    while true {
        print("  \(BLUE)\(B)l7:gateway>\(R) ", terminator: "")
        guard let input = readLine()?.trimmingCharacters(in: .whitespaces), !input.isEmpty else { continue }

        let parts = input.split(separator: " ", maxSplits: 1).map(String.init)
        let cmd = parts[0].lowercased()
        let arg = parts.count > 1 ? parts[1] : ""

        switch cmd {
        case "valve", "status", "v":
            showFirewallStatus()

        case "enforce":
            printInfo("Touch ID required to modify firewall...")
            if bioAuth(reason: "L7 Gateway: Generate firewall rules") {
                enforceOneWay()
            }

        case "kill-unauth", "kill":
            printInfo("Touch ID required...")
            if bioAuth(reason: "L7 Gateway: Kill unauthorized connections") {
                killUnauthorized()
            }

        case "whitelist", "wl":
            switch arg.lowercased() {
            case "add":
                if bioAuth(reason: "L7 Gateway: Modify whitelist") {
                    cmdWhitelistAdd()
                }
            case _ where arg.lowercased().hasPrefix("rm "):
                let app = String(arg.dropFirst(3))
                if bioAuth(reason: "L7 Gateway: Remove \(app) from whitelist") {
                    cmdWhitelistRemove(app: app)
                }
            default:
                print()
                print("  \(B)\(WHITE)Whitelist:\(R)")
                if whitelist.isEmpty {
                    printInfo("Empty.")
                } else {
                    for w in whitelist {
                        print("  \(GREEN)\u{25CF}\(R) \(B)\(w.app)\(R) ports:\(w.ports) — \(w.reason)")
                    }
                }
                print()
            }

        case "creds", "credentials":
            cmdListCreds()

        case "store", "add":
            cmdStoreCred()

        case "get", "g":
            if arg.isEmpty { printError("Usage: get <service>") }
            else { cmdGetCred(service: arg) }

        case "delete", "del", "rm":
            if arg.isEmpty { printError("Usage: delete <service>") }
            else if bioAuth(reason: "L7 Gateway: Delete credential for \(arg)") {
                if deleteCredential(service: arg) { printOK("Deleted: \(arg)") }
                else { printError("Not found: \(arg)") }
            }

        case "audit", "log":
            showAudit()

        case "quit", "q", "exit":
            auditLog("GATEWAY_CLOSE")
            printOK("Gateway sealed.")
            exit(0)

        case "help", "?":
            printMenu()

        default:
            printError("Unknown: \(cmd). Type 'help'.")
        }
    }
}

main()
