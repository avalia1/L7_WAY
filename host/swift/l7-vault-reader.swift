// ══════════════════════════════════════════════════════════════
// L7 VAULT READER — The Sealed Library
// Native macOS app. Touch ID gate. Read-only. No network.
//
// All classified content in one place:
//   ◆ DOCTRINE  — Encrypted wisdom (AES-256, machine-bound)
//   ◇ SALT      — Immutable archive (read-only, chmod 444)
//   ⬡ VAULT     — Protected documents (encrypted volume)
//
// Fingerprint to enter. Read only. Nothing leaves.
//
// Creator: Alberto Valido Delgado
// Publisher: Avli Cloud
// License: Proprietary — Law XXX: Biometrics only, no passwords
// ══════════════════════════════════════════════════════════════

import Foundation
import LocalAuthentication
import CryptoKit

// ─── Paths ─────────────────────────────────────────
let HOME = NSHomeDirectory()
let L7_DIR = ProcessInfo.processInfo.environment["L7_DIR"] ?? HOME + "/.l7"
let L7_WAY = HOME + "/Backup/L7_WAY"

let DOCTRINE_SOURCE = L7_WAY + "/salt/doctrine"
let DOCTRINE_VAULT  = HOME + "/.claude/projects/-Users-rnir-hrc-avd/memory/doctrine"
let SALT_DIR        = L7_WAY + "/salt"
let VAULT_DIR       = L7_WAY + "/.vault"
let VAULT_MOUNT     = "/Volumes/L7_VAULT"
let AUDIT_LOG       = L7_DIR + "/vault-reader/audit.log"
let VERSION         = "1.0.0"

// ─── Colors ────────────────────────────────────────
struct C {
    static let reset   = "\u{1b}[0m"
    static let bold    = "\u{1b}[1m"
    static let dim     = "\u{1b}[2m"
    static let gold    = "\u{1b}[93m"   // Doctrine
    static let silver  = "\u{1b}[97m"   // Salt
    static let green   = "\u{1b}[32m"   // Vault
    static let copper  = "\u{1b}[91m"   // Restricted
    static let cyan    = "\u{1b}[96m"   // Info
    static let blue    = "\u{1b}[94m"   // Menu
    static let magenta = "\u{1b}[95m"   // Headers
    static let earth   = "\u{1b}[33m"   // Earth/amber
}

// ─── Logging ───────────────────────────────────────
func auditLog(_ entry: String) {
    let dir = L7_DIR + "/vault-reader"
    try? FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
    let line = "[\(ISO8601DateFormatter().string(from: Date()))] \(entry)\n"
    if let handle = FileHandle(forWritingAtPath: AUDIT_LOG) {
        handle.seekToEndOfFile()
        handle.write(line.data(using: .utf8)!)
        handle.closeFile()
    } else {
        FileManager.default.createFile(atPath: AUDIT_LOG, contents: line.data(using: .utf8))
    }
}

// ─── Anti-Debug ────────────────────────────────────
func verifyNotTraced() -> Bool {
    var info = kinfo_proc()
    var size = MemoryLayout<kinfo_proc>.stride
    var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
    let r = sysctl(&mib, 4, &info, &size, nil, 0)
    if r == 0 && (info.kp_proc.p_flag & P_TRACED) != 0 {
        auditLog("SECURITY: Debugger detected — ABORT")
        return false
    }
    return true
}

// ─── Machine UUID ──────────────────────────────────
func machineUUID() -> String? {
    let pipe = Pipe()
    let proc = Process()
    proc.executableURL = URL(fileURLWithPath: "/usr/sbin/ioreg")
    proc.arguments = ["-d2", "-c", "IOPlatformExpertDevice"]
    proc.standardOutput = pipe
    proc.standardError = FileHandle.nullDevice
    try? proc.run()
    proc.waitUntilExit()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    guard let output = String(data: data, encoding: .utf8) else { return nil }
    for line in output.components(separatedBy: "\n") {
        if line.contains("IOPlatformUUID") {
            let parts = line.components(separatedBy: "\"")
            if parts.count >= 4 { return parts[3] }
        }
    }
    return nil
}

// ─── Biometric Gate ────────────────────────────────
func authenticate() -> Bool {
    let context = LAContext()
    context.localizedFallbackTitle = ""  // No password fallback — Law XXX
    var error: NSError?

    guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
        print("\(C.copper)  DENIED: Biometric hardware unavailable.\(C.reset)")
        print("\(C.copper)  Law XXX: No passwords. Fingerprint ONLY.\(C.reset)")
        auditLog("AUTH_FAIL: Biometrics unavailable")
        return false
    }

    let sem = DispatchSemaphore(value: 0)
    var ok = false
    context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                           localizedReason: "L7 Vault Reader — The Sealed Library requires your fingerprint") { success, _ in
        ok = success
        sem.signal()
    }
    sem.wait()

    if ok {
        auditLog("AUTH_OK: Fingerprint verified")
    } else {
        auditLog("AUTH_FAIL: Fingerprint rejected")
        print("\(C.copper)  DENIED: Fingerprint not recognized.\(C.reset)")
    }
    return ok
}

// ─── Doctrine Decryption ───────────────────────────
func deriveDoctrineKey() -> Data? {
    guard let uuid = machineUUID() else { return nil }
    let input = "\(uuid):L7_DOCTRINE_SALT_42"
    let hash = SHA256.hash(data: Data(input.utf8))
    return Data(hash)
}

func decryptDoctrine(_ encPath: String) -> String? {
    guard let key = deriveDoctrineKey() else { return nil }
    let keyHex = key.map { String(format: "%02x", $0) }.joined()

    let pipe = Pipe()
    let errPipe = Pipe()
    let proc = Process()
    proc.executableURL = URL(fileURLWithPath: "/usr/bin/openssl")
    proc.arguments = ["enc", "-aes-256-cbc", "-d", "-salt", "-pbkdf2", "-iter", "100000",
                       'm working on my work"-in", encPath, "-pass", "pass:\(keyHex)"]
    proc.standardOutput = pipe
    proc.standardError = errPipe
    try? proc.run()
    proc.waitUntilExit()

    if proc.terminationStatus != 0 { return nil }
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    return String(data: data, encoding: .utf8)
}

// ─── Content Listing ───────────────────────────────
struct ClassifiedFile {
    let name: String
    let path: String
    let category: String  // doctrine, salt, vault
    let encrypted: Bool
    let size: Int
}

func listDoctrine() -> [ClassifiedFile] {
    let fm = FileManager.default
    guard fm.fileExists(atPath: DOCTRINE_VAULT) else { return [] }
    let files = (try? fm.contentsOfDirectory(atPath: DOCTRINE_VAULT)) ?? []
    return files.filter { $0.hasSuffix(".enc") }.sorted().map { f in
        let path = DOCTRINE_VAULT + "/" + f
        let size = (try? fm.attributesOfItem(atPath: path)[.size] as? Int) ?? 0
        let name = String(f.dropLast(4)) // remove .enc
        return ClassifiedFile(name: name, path: path, category: "doctrine", encrypted: true, size: size)
    }
}

func listSalt() -> [ClassifiedFile] {
    let fm = FileManager.default
    guard fm.fileExists(atPath: DOCTRINE_SOURCE) else { return [] }
    let files = (try? fm.contentsOfDirectory(atPath: DOCTRINE_SOURCE)) ?? []
    return files.filter { $0.hasSuffix(".salt.md") }.sorted().map { f in
        let path = DOCTRINE_SOURCE + "/" + f
        let size = (try? fm.attributesOfItem(atPath: path)[.size] as? Int) ?? 0
        return ClassifiedFile(name: f, path: path, category: "salt", encrypted: false, size: size)
    }
}

func listVault() -> [ClassifiedFile] {
    let fm = FileManager.default
    // Check encrypted volume first
    let dir = fm.fileExists(atPath: VAULT_MOUNT) ? VAULT_MOUNT : VAULT_DIR
    guard fm.fileExists(atPath: dir) else { return [] }
    let files = (try? fm.contentsOfDirectory(atPath: dir)) ?? []
    return files.filter { !$0.hasPrefix(".") }.sorted().map { f in
        let path = dir + "/" + f
        let size = (try? fm.attributesOfItem(atPath: path)[.size] as? Int) ?? 0
        return ClassifiedFile(name: f, path: path, category: "vault", encrypted: dir == VAULT_MOUNT, size: size)
    }
}

// ─── Display ───────────────────────────────────────
func printBanner() {
    print("""
    \(C.magenta)\(C.bold)
    ╔══════════════════════════════════════════════════╗
    ║                                                  ║
    ║       ⬡  L7 VAULT READER  ⬡                     ║
    ║       The Sealed Library                         ║
    ║                                                  ║
    ║       Fingerprint verified. Read only.            ║
    ║                                                  ║
    ╚══════════════════════════════════════════════════╝
    \(C.reset)
    """)
}

func printMainMenu(doctrine: [ClassifiedFile], salt: [ClassifiedFile], vault: [ClassifiedFile]) {
    let total = doctrine.count + salt.count + vault.count

    print("\(C.dim)  ─────────────────────────────────────────────\(C.reset)")
    print("  \(C.bold)\(total) classified files\(C.reset) across 3 archives")
    print("\(C.dim)  ─────────────────────────────────────────────\(C.reset)")
    print()

    // Doctrine
    print("  \(C.gold)\(C.bold)◆ DOCTRINE\(C.reset)\(C.gold)  — Encrypted wisdom (AES-256, this machine only)\(C.reset)")
    for (i, f) in doctrine.enumerated() {
        let shortName = f.name.replacingOccurrences(of: ".salt.md", with: "")
        print("    \(C.gold)[\(i + 1)] \(shortName)\(C.reset)\(C.dim)  (\(f.size)B encrypted)\(C.reset)")
    }
    print()

    // Salt
    let saltOffset = doctrine.count
    print("  \(C.silver)\(C.bold)◇ SALT\(C.reset)\(C.silver)  — Immutable archive (read-only, sealed)\(C.reset)")
    for (i, f) in salt.enumerated() {
        let shortName = f.name.replacingOccurrences(of: ".salt.md", with: "")
        print("    \(C.silver)[\(saltOffset + i + 1)] \(shortName)\(C.reset)\(C.dim)  (\(f.size)B)\(C.reset)")
    }
    print()

    // Vault
    let vaultOffset = saltOffset + salt.count
    let vaultStatus = FileManager.default.fileExists(atPath: VAULT_MOUNT) ? "OPEN" : "SEALED"
    print("  \(C.green)\(C.bold)⬡ VAULT\(C.reset)\(C.green)  — Protected documents [\(vaultStatus)]\(C.reset)")
    for (i, f) in vault.enumerated() {
        print("    \(C.green)[\(vaultOffset + i + 1)] \(f.name)\(C.reset)\(C.dim)  (\(f.size)B)\(C.reset)")
    }
    print()

    print("\(C.dim)  ─────────────────────────────────────────────\(C.reset)")
    print("  \(C.blue)Commands:\(C.reset)")
    print("    \(C.cyan)<number>\(C.reset)       Read a file by number")
    print("    \(C.cyan)search <term>\(C.reset)  Search across all classified content")
    print("    \(C.cyan)list\(C.reset)           Refresh file listing")
    print("    \(C.cyan)status\(C.reset)         Show integrity & encryption status")
    print("    \(C.cyan)quit\(C.reset)           Exit (fingerprint required to re-enter)")
    print("\(C.dim)  ─────────────────────────────────────────────\(C.reset)")
}

func displayFile(_ file: ClassifiedFile) {
    print()
    print("\(C.dim)  ═══════════════════════════════════════════════\(C.reset)")

    switch file.category {
    case "doctrine":
        print("  \(C.gold)\(C.bold)◆ \(file.name)\(C.reset)")
        print("  \(C.gold)  Decrypting...\(C.reset)")
        if let content = decryptDoctrine(file.path) {
            print("\(C.dim)  ───────────────────────────────────────────\(C.reset)")
            for line in content.components(separatedBy: "\n") {
                if line.hasPrefix("#") {
                    print("  \(C.gold)\(C.bold)\(line)\(C.reset)")
                } else if line.hasPrefix("---") {
                    print("  \(C.dim)\(line)\(C.reset)")
                } else if line.hasPrefix("|") {
                    print("  \(C.cyan)\(line)\(C.reset)")
                } else if line.hasPrefix("```") {
                    print("  \(C.earth)\(line)\(C.reset)")
                } else if line.hasPrefix("-") || line.hasPrefix("*") {
                    print("  \(C.silver)\(line)\(C.reset)")
                } else {
                    print("  \(line)")
                }
            }
            auditLog("READ_DOCTRINE: \(file.name)")
        } else {
            print("  \(C.copper)DECRYPTION FAILED — wrong machine or corrupted.\(C.reset)")
            auditLog("READ_FAIL: \(file.name) — decryption failed")
        }

    case "salt":
        print("  \(C.silver)\(C.bold)◇ \(file.name)\(C.reset)")
        if let content = try? String(contentsOfFile: file.path, encoding: .utf8) {
            print("\(C.dim)  ───────────────────────────────────────────\(C.reset)")
            for line in content.components(separatedBy: "\n") {
                if line.hasPrefix("#") {
                    print("  \(C.silver)\(C.bold)\(line)\(C.reset)")
                } else if line.hasPrefix("---") {
                    print("  \(C.dim)\(line)\(C.reset)")
                } else if line.hasPrefix("|") {
                    print("  \(C.cyan)\(line)\(C.reset)")
                } else if line.hasPrefix("```") {
                    print("  \(C.earth)\(line)\(C.reset)")
                } else if line.hasPrefix("-") || line.hasPrefix("*") {
                    print("  \(C.gold)\(line)\(C.reset)")
                } else {
                    print("  \(line)")
                }
            }
            auditLog("READ_SALT: \(file.name)")
        } else {
            print("  \(C.copper)Cannot read file.\(C.reset)")
        }

    case "vault":
        print("  \(C.green)\(C.bold)⬡ \(file.name)\(C.reset)")
        if let content = try? String(contentsOfFile: file.path, encoding: .utf8) {
            print("\(C.dim)  ───────────────────────────────────────────\(C.reset)")
            for line in content.components(separatedBy: "\n") {
                if line.hasPrefix("#") {
                    print("  \(C.green)\(C.bold)\(line)\(C.reset)")
                } else if line.hasPrefix("---") {
                    print("  \(C.dim)\(line)\(C.reset)")
                } else if line.hasPrefix("|") {
                    print("  \(C.cyan)\(line)\(C.reset)")
                } else {
                    print("  \(line)")
                }
            }
            auditLog("READ_VAULT: \(file.name)")
        } else {
            print("  \(C.copper)Cannot read file.\(C.reset)")
        }

    default:
        print("  \(C.copper)Unknown category.\(C.reset)")
    }

    print("\(C.dim)  ═══════════════════════════════════════════════\(C.reset)")
    print()
}

func searchAll(_ term: String, doctrine: [ClassifiedFile], salt: [ClassifiedFile], vault: [ClassifiedFile]) {
    print()
    print("  \(C.cyan)\(C.bold)Searching for: \(term)\(C.reset)")
    print("\(C.dim)  ─────────────────────────────────────────────\(C.reset)")
    var hits = 0

    // Search doctrine (encrypted — must decrypt first)
    for f in doctrine {
        if let content = decryptDoctrine(f.path), content.lowercased().contains(term.lowercased()) {
            hits += 1
            let shortName = f.name.replacingOccurrences(of: ".salt.md", with: "")
            print("  \(C.gold)◆ \(shortName)\(C.reset)")
            for line in content.components(separatedBy: "\n") {
                if line.lowercased().contains(term.lowercased()) {
                    let highlighted = line.replacingOccurrences(of: term,
                        with: "\(C.bold)\(C.copper)\(term)\(C.reset)", options: .caseInsensitive)
                    print("    \(highlighted)")
                }
            }
            print()
        }
    }

    // Search salt
    for f in salt {
        if let content = try? String(contentsOfFile: f.path, encoding: .utf8),
           content.lowercased().contains(term.lowercased()) {
            hits += 1
            let shortName = f.name.replacingOccurrences(of: ".salt.md", with: "")
            print("  \(C.silver)◇ \(shortName)\(C.reset)")
            for line in content.components(separatedBy: "\n") {
                if line.lowercased().contains(term.lowercased()) {
                    let highlighted = line.replacingOccurrences(of: term,
                        with: "\(C.bold)\(C.copper)\(term)\(C.reset)", options: .caseInsensitive)
                    print("    \(highlighted)")
                }
            }
            print()
        }
    }

    // Search vault
    for f in vault {
        if let content = try? String(contentsOfFile: f.path, encoding: .utf8),
           content.lowercased().contains(term.lowercased()) {
            hits += 1
            print("  \(C.green)⬡ \(f.name)\(C.reset)")
            for line in content.components(separatedBy: "\n") {
                if line.lowercased().contains(term.lowercased()) {
                    let highlighted = line.replacingOccurrences(of: term,
                        with: "\(C.bold)\(C.copper)\(term)\(C.reset)", options: .caseInsensitive)
                    print("    \(highlighted)")
                }
            }
            print()
        }
    }

    print("\(C.dim)  ─────────────────────────────────────────────\(C.reset)")
    print("  \(C.cyan)\(hits) file(s) matched.\(C.reset)")
    auditLog("SEARCH: \"\(term)\" — \(hits) hits")
    print()
}

func showStatus(doctrine: [ClassifiedFile], salt: [ClassifiedFile], vault: [ClassifiedFile]) {
    print()
    print("  \(C.magenta)\(C.bold)═══ STATUS ═══\(C.reset)")
    print()

    // Machine
    if let uuid = machineUUID() {
        print("  \(C.cyan)Machine:\(C.reset) \(uuid.prefix(8))... (verified)")
    } else {
        print("  \(C.copper)Machine:\(C.reset) UNKNOWN — key derivation will fail")
    }
    print()

    // Doctrine encryption
    print("  \(C.gold)\(C.bold)◆ Doctrine Encryption\(C.reset)")
    let manifestPath = DOCTRINE_VAULT + "/MANIFEST"
    if FileManager.default.fileExists(atPath: manifestPath) {
        if let manifest = try? String(contentsOfFile: manifestPath, encoding: .utf8) {
            for line in manifest.components(separatedBy: "\n").prefix(3) {
                print("    \(C.dim)\(line)\(C.reset)")
            }
        }
        // Test decryption
        if let first = doctrine.first, decryptDoctrine(first.path) != nil {
            print("    \(C.green)✓ Decryption key valid\(C.reset)")
        } else {
            print("    \(C.copper)✗ Decryption failed\(C.reset)")
        }
    } else {
        print("    \(C.copper)No manifest found\(C.reset)")
    }
    print("    \(C.dim)\(doctrine.count) encrypted file(s)\(C.reset)")
    print()

    // Salt integrity
    print("  \(C.silver)\(C.bold)◇ Salt Archive\(C.reset)")
    var readOnly = 0
    for f in salt {
        let attrs = try? FileManager.default.attributesOfItem(atPath: f.path)
        let perms = (attrs?[.posixPermissions] as? Int) ?? 0
        if perms == 0o444 { readOnly += 1 }
    }
    print("    \(C.dim)\(salt.count) sealed file(s), \(readOnly) read-only (444)\(C.reset)")
    if readOnly == salt.count {
        print("    \(C.green)✓ All files immutable\(C.reset)")
    } else {
        print("    \(C.copper)✗ \(salt.count - readOnly) file(s) not locked\(C.reset)")
    }
    print()

    // Vault
    print("  \(C.green)\(C.bold)⬡ Vault\(C.reset)")
    if FileManager.default.fileExists(atPath: VAULT_MOUNT) {
        print("    \(C.green)Status: OPEN at \(VAULT_MOUNT)\(C.reset)")
    } else {
        print("    \(C.earth)Status: SEALED\(C.reset)")
    }
    print("    \(C.dim)\(vault.count) file(s) accessible\(C.reset)")
    print()

    // Audit log
    if let logContent = try? String(contentsOfFile: AUDIT_LOG, encoding: .utf8) {
        let lines = logContent.components(separatedBy: "\n").filter { !$0.isEmpty }
        print("  \(C.blue)\(C.bold)Audit Log\(C.reset)")
        print("    \(C.dim)\(lines.count) entries total\(C.reset)")
        for line in lines.suffix(5) {
            print("    \(C.dim)\(line)\(C.reset)")
        }
    }

    print()
    print("  \(C.magenta)\(C.bold)══════════════\(C.reset)")
    print()
}

// ─── REPL ──────────────────────────────────────────
func repl() {
    var doctrine = listDoctrine()
    var salt = listSalt()
    var vault = listVault()
    let allFiles = doctrine + salt + vault

    printMainMenu(doctrine: doctrine, salt: salt, vault: vault)

    while true {
        print("\(C.blue)  vault-reader>\(C.reset) ", terminator: "")
        fflush(stdout)
        guard let input = readLine()?.trimmingCharacters(in: .whitespaces) else {
            break
        }

        if input.isEmpty { continue }

        let lower = input.lowercased()

        if lower == "quit" || lower == "exit" || lower == "q" {
            print("\(C.dim)  Sealed. The Dead remember.\(C.reset)")
            auditLog("SESSION_END")
            break
        }

        if lower == "list" || lower == "ls" || lower == "refresh" {
            doctrine = listDoctrine()
            salt = listSalt()
            vault = listVault()
            printMainMenu(doctrine: doctrine, salt: salt, vault: vault)
            continue
        }

        if lower == "status" || lower == "integrity" {
            showStatus(doctrine: doctrine, salt: salt, vault: vault)
            continue
        }

        if lower.hasPrefix("search ") {
            let term = String(input.dropFirst(7)).trimmingCharacters(in: .whitespaces)
            if !term.isEmpty {
                searchAll(term, doctrine: doctrine, salt: salt, vault: vault)
            }
            continue
        }

        if lower == "help" || lower == "?" {
            printMainMenu(doctrine: doctrine, salt: salt, vault: vault)
            continue
        }

        // Number selection
        if let num = Int(input), num >= 1, num <= allFiles.count {
            let refreshed = listDoctrine() + listSalt() + listVault()
            if num <= refreshed.count {
                displayFile(refreshed[num - 1])
            }
            continue
        }

        // Partial name match
        let all = listDoctrine() + listSalt() + listVault()
        if let match = all.first(where: { $0.name.lowercased().contains(lower) }) {
            displayFile(match)
            continue
        }

        print("  \(C.copper)Unknown command. Type 'help' or a file number.\(C.reset)")
    }
}

// ─── Main ──────────────────────────────────────────
func main() {
    // Anti-debug
    guard verifyNotTraced() else {
        fputs("\(C.copper)SECURITY: Debugger detected. Access denied.\(C.reset)\n", stderr)
        exit(1)
    }

    // Biometric gate — fingerprint only, no fallback
    print("""
    \(C.magenta)\(C.bold)
    ⬡  L7 VAULT READER  ⬡
    \(C.reset)\(C.dim)
    Place your finger on Touch ID to enter.
    \(C.reset)
    """)

    guard authenticate() else {
        print("\(C.copper)\(C.bold)  ACCESS DENIED\(C.reset)")
        print("\(C.copper)  Law XXX: Fingerprint only. No passwords. No fallback.\(C.reset)")
        exit(1)
    }

    auditLog("SESSION_START: Fingerprint verified")
    printBanner()
    repl()
}

main()
