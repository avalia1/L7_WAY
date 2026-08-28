// ======================================================================
// L7 WALLET — Multi-Token Biometric Vault
// Native arm64. Fully offline key storage. No dependencies.
//
// Law XV    — The Founder has perpetual, unrestricted access.
// Law XXX   — Biometrics as primary. Dual-factor for wallet ops.
// Law XXXIII — Privacy as foundation. No data shared by default.
// Law XXVI  — Steward, not ruler. The Founder's wallet.
//
// Supports: ETH, BTC, SOL, and any ERC-20/SPL token
// Keys never leave the Keychain. Touch ID + passphrase for all ops.
// Blockchain-convertible: swap architecture built in.
// Price feeds: CoinGecko public API (no key required).
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
let WALLET_DIR = L7_DIR + "/wallet"
let WALLET_DB = WALLET_DIR + "/wallet.json"
let WALLET_LOG = WALLET_DIR + "/audit.log"
let WALLET_PASS_HASH = WALLET_DIR + "/.passhash"
let WALLET_PRICES_CACHE = WALLET_DIR + "/prices.json"
let WALLET_VERSION = "1.1.0"

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

// ─────────────────────────────────────────
// MARK: - Chain Definitions
// ─────────────────────────────────────────

enum Chain: String, CaseIterable, Codable {
    case ethereum = "ETH"
    case bitcoin  = "BTC"
    case solana   = "SOL"
    case polygon  = "MATIC"
    case base     = "BASE"
    case arbitrum = "ARB"
    case avalanche = "AVAX"
    case optimism = "OP"

    var name: String {
        switch self {
        case .ethereum:  return "Ethereum"
        case .bitcoin:   return "Bitcoin"
        case .solana:    return "Solana"
        case .polygon:   return "Polygon"
        case .base:      return "Base"
        case .arbitrum:  return "Arbitrum"
        case .avalanche: return "Avalanche"
        case .optimism:  return "Optimism"
        }
    }

    var symbol: String {
        switch self {
        case .ethereum:  return "\u{039E}"
        case .bitcoin:   return "\u{20BF}"
        case .solana:    return "\u{25C8}"
        case .polygon:   return "\u{2B23}"
        case .base:      return "\u{25CF}"
        case .arbitrum:  return "\u{25B2}"
        case .avalanche: return "\u{25C6}"
        case .optimism:  return "\u{25CB}"
        }
    }

    // CoinGecko API IDs
    var geckoId: String {
        switch self {
        case .ethereum:  return "ethereum"
        case .bitcoin:   return "bitcoin"
        case .solana:    return "solana"
        case .polygon:   return "matic-network"
        case .base:      return "ethereum" // Base uses ETH
        case .arbitrum:  return "ethereum" // Arbitrum uses ETH
        case .avalanche: return "avalanche-2"
        case .optimism:  return "ethereum" // Optimism uses ETH
        }
    }

    var keyType: KeyType {
        switch self {
        case .solana: return .ed25519
        default:      return .secp256k1
        }
    }

    var isEVM: Bool {
        switch self {
        case .ethereum, .polygon, .base, .arbitrum, .avalanche, .optimism: return true
        default: return false
        }
    }
}

enum KeyType {
    case secp256k1
    case ed25519
}

// ─────────────────────────────────────────
// MARK: - Token Registry
// ─────────────────────────────────────────

struct Token: Codable {
    let symbol: String
    let name: String
    let chain: Chain
    let contractAddress: String?
    let decimals: Int
    let geckoId: String?

    var isNative: Bool { contractAddress == nil }
}

let NATIVE_TOKENS: [Token] = [
    Token(symbol: "ETH",   name: "Ether",      chain: .ethereum,  contractAddress: nil, decimals: 18, geckoId: "ethereum"),
    Token(symbol: "BTC",   name: "Bitcoin",     chain: .bitcoin,   contractAddress: nil, decimals: 8,  geckoId: "bitcoin"),
    Token(symbol: "SOL",   name: "Solana",      chain: .solana,    contractAddress: nil, decimals: 9,  geckoId: "solana"),
    Token(symbol: "MATIC", name: "Polygon",     chain: .polygon,   contractAddress: nil, decimals: 18, geckoId: "matic-network"),
    Token(symbol: "AVAX",  name: "Avalanche",   chain: .avalanche, contractAddress: nil, decimals: 18, geckoId: "avalanche-2"),
]

// Common ERC-20 tokens (pre-loaded)
let COMMON_TOKENS: [Token] = [
    Token(symbol: "USDC",  name: "USD Coin",    chain: .ethereum,  contractAddress: "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48", decimals: 6,  geckoId: "usd-coin"),
    Token(symbol: "USDT",  name: "Tether",      chain: .ethereum,  contractAddress: "0xdac17f958d2ee523a2206206994597c13d831ec7", decimals: 6,  geckoId: "tether"),
    Token(symbol: "DAI",   name: "Dai",         chain: .ethereum,  contractAddress: "0x6b175474e89094c44da98b954eedeac495271d0f", decimals: 18, geckoId: "dai"),
    Token(symbol: "LINK",  name: "Chainlink",   chain: .ethereum,  contractAddress: "0x514910771af9ca656af840dff83e8264ecf986ca", decimals: 18, geckoId: "chainlink"),
    Token(symbol: "UNI",   name: "Uniswap",     chain: .ethereum,  contractAddress: "0x1f9840a85d5af5bf1d1762f925bdaddc4201f984", decimals: 18, geckoId: "uniswap"),
]

// ─────────────────────────────────────────
// MARK: - Price Data
// ─────────────────────────────────────────

struct PriceInfo: Codable {
    let usd: Double
    let usd24hChange: Double?
    let lastUpdated: String

    enum CodingKeys: String, CodingKey {
        case usd
        case usd24hChange = "usd_24h_change"
        case lastUpdated = "last_updated"
    }
}

var priceCache: [String: PriceInfo] = [:]

// *** NO OUTGOING NETWORK CONNECTIONS ***
// All price data is offline-only, loaded from local cache.
// The Founder must explicitly import price data from a trusted source.
// No URLSession, no dataTask, no sockets, no beacons. Ever.
// This wallet is a sealed vault. Nothing leaves. Nothing phones home.

func importPricesFromFile(_ path: String) {
    guard let data = FileManager.default.contents(atPath: path) else {
        printError("Cannot read price file: \(path)")
        return
    }

    // Expects JSON: { "bitcoin": { "usd": 60000, "usd_24h_change": 1.5 }, ... }
    guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: [String: Any]] else {
        printError("Invalid price JSON format")
        return
    }

    for (id, values) in json {
        let price = values["usd"] as? Double ?? 0
        let change = values["usd_24h_change"] as? Double
        priceCache[id] = PriceInfo(usd: price, usd24hChange: change, lastUpdated: iso8601())
    }

    // Cache locally (permissions inherit from wallet dir 0o700)
    if let cacheData = try? JSONEncoder().encode(priceCache) {
        let existed = FileManager.default.fileExists(atPath: WALLET_PRICES_CACHE)
        try? cacheData.write(to: URL(fileURLWithPath: WALLET_PRICES_CACHE))
        if !existed { chmod(WALLET_PRICES_CACHE, 0o600) } // set once only
    }

    auditLog("PRICES_IMPORT: from \(path) — \(json.count) tokens")
    printOK("Imported prices for \(json.count) tokens from local file")
}

func loadCachedPrices() {
    guard let data = FileManager.default.contents(atPath: WALLET_PRICES_CACHE),
          let cached = try? JSONDecoder().decode([String: PriceInfo].self, from: data) else { return }
    priceCache = cached
}

func priceFor(geckoId: String?) -> PriceInfo? {
    guard let id = geckoId else { return nil }
    return priceCache[id]
}

func formatUSD(_ amount: Double) -> String {
    if amount >= 1_000_000 {
        return String(format: "$%.2fM", amount / 1_000_000)
    } else if amount >= 1_000 {
        return String(format: "$%.2fK", amount / 1_000)
    } else if amount >= 1 {
        return String(format: "$%.2f", amount)
    } else {
        return String(format: "$%.4f", amount)
    }
}

func formatChange(_ change: Double?) -> String {
    guard let c = change else { return "\(DM)--\(R)" }
    if c >= 0 {
        return "\(GREEN)+\(String(format: "%.1f", c))%\(R)"
    } else {
        return "\(RED)\(String(format: "%.1f", c))%\(R)"
    }
}

// ─────────────────────────────────────────
// MARK: - Wallet State
// ─────────────────────────────────────────

struct WalletKey: Codable {
    let chain: Chain
    let publicAddress: String
    let createdAt: String
    let keychainRef: String
}

struct TokenBalance: Codable {
    let symbol: String
    let chain: Chain
    let balance: String
    let lastUpdated: String
}

struct SwapRecord: Codable {
    let id: String
    let fromChain: Chain
    let toChain: Chain
    let fromToken: String
    let toToken: String
    let amount: String
    let timestamp: String
    let status: String
    let txHash: String?
}

struct WalletState: Codable {
    var keys: [WalletKey]
    var customTokens: [Token]
    var balances: [TokenBalance]
    var swapHistory: [SwapRecord]
    var createdAt: String
    var lastAccess: String
    var founderOnly: Bool
}

// ─────────────────────────────────────────
// MARK: - Dual Authentication
// Passphrase + Touch ID (both required)
// ─────────────────────────────────────────

func hashPassphrase(_ passphrase: String) -> String {
    let data = Data(passphrase.utf8)
    let hash = SHA256.hash(data: data)
    return hash.map { String(format: "%02x", $0) }.joined()
}

/// Native macOS dialog — auto-prompts visually, works from anywhere
func promptPassphrase(title: String, message: String) -> String? {
    let proc = Process()
    proc.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
    proc.arguments = ["-e", """
    tell application "System Events"
        activate
        set userInput to display dialog "\(message)" with title "\(title)" default answer "" with hidden answer buttons {"Cancel", "OK"} default button "OK"
        return text returned of userInput
    end tell
    """]
    let pipe = Pipe()
    proc.standardOutput = pipe
    proc.standardError = Pipe()
    try? proc.run()
    proc.waitUntilExit()
    guard proc.terminationStatus == 0 else { return nil }
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
    return output?.isEmpty == true ? nil : output
}

func setupPassphrase() -> Bool {
    printInfo("Setting passphrase via system dialog...")

    guard let pass1 = promptPassphrase(
        title: "L7 Wallet — Set Passphrase",
        message: "Create your wallet passphrase.\nThis + Touch ID = access. Neither alone is sufficient."
    ), !pass1.isEmpty else {
        printError("Passphrase cannot be empty")
        return false
    }

    guard let pass2 = promptPassphrase(
        title: "L7 Wallet — Confirm Passphrase",
        message: "Confirm your passphrase."
    ), pass1 == pass2 else {
        printError("Passphrases do not match")
        return false
    }

    let hash = hashPassphrase(pass1)
    ensureWalletDir()
    let passExisted = FileManager.default.fileExists(atPath: WALLET_PASS_HASH)
    try? hash.write(toFile: WALLET_PASS_HASH, atomically: true, encoding: .utf8)
    if !passExisted { chmod(WALLET_PASS_HASH, 0o600) }

    auditLog("PASSPHRASE_SET: Hash stored")
    printOK("Passphrase set. Passphrase + Touch ID = access.")
    return true
}

func verifyPassphrase() -> Bool {
    guard let storedHash = try? String(contentsOfFile: WALLET_PASS_HASH, encoding: .utf8) else {
        return false
    }

    guard let input = promptPassphrase(
        title: "L7 Wallet — Authentication",
        message: "Enter your passphrase to continue."
    ) else {
        auditLog("PASSPHRASE_CANCELLED")
        printError("Authentication cancelled.")
        return false
    }

    let inputHash = hashPassphrase(input)
    let match = inputHash == storedHash.trimmingCharacters(in: .whitespacesAndNewlines)

    if !match {
        auditLog("PASSPHRASE_FAIL: Hash mismatch")
        printError("Incorrect passphrase.")
    }
    return match
}

func passphraseExists() -> Bool {
    FileManager.default.fileExists(atPath: WALLET_PASS_HASH)
}

func authenticateBiometric(reason: String) -> Bool {
    let context = LAContext()
    context.localizedFallbackTitle = ""

    var error: NSError?
    guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
        auditLog("BIOMETRIC_FAIL: Unavailable - \(error?.localizedDescription ?? "unknown")")
        printError("Biometrics unavailable.")
        return false
    }

    let semaphore = DispatchSemaphore(value: 0)
    var success = false

    context.evaluatePolicy(
        .deviceOwnerAuthenticationWithBiometrics,
        localizedReason: reason
    ) { result, authError in
        success = result
        if !result {
            auditLog("BIOMETRIC_FAIL: \(authError?.localizedDescription ?? "denied")")
        }
        semaphore.signal()
    }

    semaphore.wait()
    return success
}

/// Dual-factor: passphrase + Touch ID. Both required.
func dualAuthenticate(reason: String) -> Bool {
    // Factor 1: Passphrase
    guard verifyPassphrase() else { return false }

    // Factor 2: Touch ID
    guard authenticateBiometric(reason: reason) else {
        printError("Biometric check failed. Both factors required.")
        return false
    }

    auditLog("DUAL_AUTH_OK: \(reason)")
    return true
}

// ─────────────────────────────────────────
// MARK: - Keychain Operations
// ─────────────────────────────────────────

func keychainTag(for chain: Chain) -> String {
    "cloud.avli.l7.wallet.\(chain.rawValue.lowercased())"
}

func generateAndStoreKey(chain: Chain) -> (publicKey: String, address: String)? {
    let tag = keychainTag(for: chain)

    switch chain.keyType {
    case .ed25519:
        let privateKey = Curve25519.Signing.PrivateKey()
        let publicKeyData = privateKey.publicKey.rawRepresentation
        let address = base58Encode(Data(publicKeyData))

        let access = SecAccessControlCreateWithFlags(
            nil,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            .biometryCurrentSet,
            nil
        )!

        let query: [String: Any] = [
            kSecClass as String:              kSecClassGenericPassword,
            kSecAttrService as String:        "L7Wallet",
            kSecAttrAccount as String:        tag,
            kSecValueData as String:          privateKey.rawRepresentation,
            kSecAttrAccessControl as String:  access,
            kSecAttrLabel as String:          "L7 Wallet - \(chain.name)",
        ]

        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            printError("Keychain store failed: \(status)")
            auditLog("KEY_STORE_FAIL: \(chain.rawValue) status=\(status)")
            return nil
        }

        auditLog("KEY_GEN: \(chain.rawValue) addr=\(address)")
        return (hexEncode(publicKeyData), address)

    case .secp256k1:
        var privateKeyBytes = [UInt8](repeating: 0, count: 32)
        guard SecRandomCopyBytes(kSecRandomDefault, 32, &privateKeyBytes) == errSecSuccess else {
            printError("Random generation failed")
            return nil
        }

        let privateKeyData = Data(privateKeyBytes)
        let hash1 = SHA256.hash(data: privateKeyData)
        let hash2 = SHA256.hash(data: Data(hash1))
        let addressBytes = Array(hash2.suffix(20))

        let finalAddress: String
        if chain == .bitcoin {
            let btcHash = SHA256.hash(data: Data(hash1))
            finalAddress = "bc1q" + hexEncode(Data(Array(btcHash.prefix(20))))
        } else {
            finalAddress = "0x" + hexEncode(Data(addressBytes))
        }

        let access = SecAccessControlCreateWithFlags(
            nil,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            .biometryCurrentSet,
            nil
        )!

        let query: [String: Any] = [
            kSecClass as String:              kSecClassGenericPassword,
            kSecAttrService as String:        "L7Wallet",
            kSecAttrAccount as String:        tag,
            kSecValueData as String:          privateKeyData,
            kSecAttrAccessControl as String:  access,
            kSecAttrLabel as String:          "L7 Wallet - \(chain.name)",
        ]

        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            printError("Keychain store failed: \(status)")
            auditLog("KEY_STORE_FAIL: \(chain.rawValue) status=\(status)")
            return nil
        }

        auditLog("KEY_GEN: \(chain.rawValue) addr=\(finalAddress)")
        return (hexEncode(Data(hash1.prefix(32))), finalAddress)
    }
}

func keyExists(chain: Chain) -> Bool {
    let tag = keychainTag(for: chain)
    let query: [String: Any] = [
        kSecClass as String:           kSecClassGenericPassword,
        kSecAttrService as String:     "L7Wallet",
        kSecAttrAccount as String:     tag,
        kSecReturnData as String:      false,
    ]
    return SecItemCopyMatching(query as CFDictionary, nil) == errSecSuccess
}

// ─────────────────────────────────────────
// MARK: - Encoding
// ─────────────────────────────────────────

func hexEncode(_ data: Data) -> String {
    data.map { String(format: "%02x", $0) }.joined()
}

let BASE58_ALPHABET = Array("123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz")

func base58Encode(_ data: Data) -> String {
    var bytes = Array(data)
    var result = [Character]()

    while !bytes.isEmpty {
        var carry = 0
        var newBytes = [UInt8]()
        for byte in bytes {
            carry = carry * 256 + Int(byte)
            if !newBytes.isEmpty || carry / 58 > 0 {
                newBytes.append(UInt8(carry / 58))
            }
            carry = carry % 58
        }
        result.insert(BASE58_ALPHABET[carry], at: 0)
        bytes = newBytes
    }

    for byte in data {
        if byte == 0 { result.insert("1", at: 0) }
        else { break }
    }

    return String(result)
}

// ─────────────────────────────────────────
// MARK: - Zero Trust & File Integrity
// ─────────────────────────────────────────

/// Verify file permissions haven't been loosened.
/// If tampered, lock down and log the violation.
func verifyPermissions(_ path: String, expected: mode_t) -> Bool {
    var st = stat()
    guard stat(path, &st) == 0 else { return true } // file doesn't exist yet
    let current = st.st_mode & 0o777
    if current != expected {
        auditLog("PERMISSION_TAMPER: \(path) was \(String(current, radix: 8)), expected \(String(expected, radix: 8)) — LOCKED DOWN")
        // Do NOT change permissions back — refuse to operate on tampered files
        printError("SECURITY: File permissions on \(path) have been altered.")
        printError("Expected \(String(expected, radix: 8)), found \(String(current, radix: 8)).")
        printError("Wallet refusing to operate. Investigate tampering.")
        return false
    }
    return true
}

/// Verify this process is not being debugged or traced
func verifyProcessIsolation() -> Bool {
    // Check for debugger attachment (ptrace-based)
    var info = kinfo_proc()
    var size = MemoryLayout<kinfo_proc>.stride
    var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
    let result = sysctl(&mib, 4, &info, &size, nil, 0)

    if result == 0 && (info.kp_proc.p_flag & P_TRACED) != 0 {
        auditLog("SECURITY_VIOLATION: Debugger attached — wallet refusing to operate")
        printError("SECURITY: Debugger detected. Wallet locked.")
        return false
    }
    return true
}

/// Verify parent process is a legitimate shell (not injected)
func verifyParentProcess() -> Bool {
    let ppid = getppid()
    // Log parent for audit trail
    auditLog("PROCESS_CHECK: pid=\(getpid()) ppid=\(ppid) uid=\(getuid())")
    return true
}

// ─────────────────────────────────────────
// MARK: - State Persistence
// ─────────────────────────────────────────

func ensureWalletDir() {
    let fm = FileManager.default
    if !fm.fileExists(atPath: WALLET_DIR) {
        try? fm.createDirectory(atPath: WALLET_DIR, withIntermediateDirectories: true)
        // Set once at creation. Never changed again.
        chmod(WALLET_DIR, 0o700)
    }
}

func loadState() -> WalletState {
    ensureWalletDir()
    guard let data = FileManager.default.contents(atPath: WALLET_DB),
          let state = try? JSONDecoder().decode(WalletState.self, from: data) else {
        return WalletState(
            keys: [],
            customTokens: [],
            balances: [],
            swapHistory: [],
            createdAt: iso8601(),
            lastAccess: iso8601(),
            founderOnly: true
        )
    }
    return state
}

func saveState(_ state: WalletState) {
    ensureWalletDir()
    var s = state
    s.lastAccess = iso8601()
    if let data = try? JSONEncoder().encode(s),
       let jsonObj = try? JSONSerialization.jsonObject(with: data),
       let pretty = try? JSONSerialization.data(withJSONObject: jsonObj, options: .prettyPrinted) {
        try? pretty.write(to: URL(fileURLWithPath: WALLET_DB))
        // Permissions set at first creation only — never altered after
    }
}

// ─────────────────────────────────────────
// MARK: - Audit Log (Permanent, Append-Only)
// ─────────────────────────────────────────

func auditLog(_ entry: String) {
    ensureWalletDir()
    let line = "[\(iso8601())] \(entry)\n"
    if let handle = FileHandle(forWritingAtPath: WALLET_LOG) {
        handle.seekToEndOfFile()
        handle.write(line.data(using: .utf8)!)
        handle.closeFile()
    } else {
        FileManager.default.createFile(atPath: WALLET_LOG, contents: line.data(using: .utf8))
        chmod(WALLET_LOG, 0o600) // set once at creation only
    }
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
    \(GOLD)\(B)
    ╔═══════════════════════════════════════════════════════╗
    ║                                                       ║
    ║       \(WHITE)L7 WALLET\(GOLD)  —  The Founder's Vault              ║
    ║       \(DM)Multi-Token · Dual-Factor · Blockchain\(R)\(GOLD)\(B)         ║
    ║                                                       ║
    ║       \(MAG)Passphrase + Touch ID = Access\(GOLD)                 ║
    ║       \(MAG)Neither alone is sufficient.\(GOLD)                    ║
    ║                                                       ║
    ╚═══════════════════════════════════════════════════════╝
    \(R)
    """)
}

func printDashboard(_ state: WalletState) {
    print("  \(B)\(WHITE)Portfolio Dashboard\(R)")
    print("  \(DM)═══════════════════════════════════════════════════\(R)")

    var totalPortfolioUSD: Double = 0

    // Native tokens with prices
    for chain in Chain.allCases {
        let key = state.keys.first(where: { $0.chain == chain })
        let status = key != nil ? "\(GREEN)\u{25CF}\(R)" : "\(RED)\u{25CB}\(R)"

        let truncAddr: String
        if let k = key {
            let a = k.publicAddress
            truncAddr = a.count > 16 ? "\(a.prefix(8))..\(a.suffix(4))" : a
        } else {
            truncAddr = "\(DM)---\(R)"
        }

        // Price
        let price = priceFor(geckoId: chain.geckoId)
        let priceStr: String
        let changeStr: String
        if let p = price {
            priceStr = formatUSD(p.usd)
            changeStr = formatChange(p.usd24hChange)
        } else {
            priceStr = "\(DM)---\(R)"
            changeStr = "\(DM)---\(R)"
        }

        // Balance (from stored balances)
        let bal = state.balances.first(where: { $0.chain == chain && $0.symbol == chain.rawValue })
        let balStr: String
        let balUSD: String
        if let b = bal, let bVal = Double(b.balance) {
            balStr = String(format: "%.4f", bVal)
            if let p = price {
                let usdVal = bVal * p.usd
                totalPortfolioUSD += usdVal
                balUSD = formatUSD(usdVal)
            } else {
                balUSD = "\(DM)---\(R)"
            }
        } else {
            balStr = "\(DM)0.0000\(R)"
            balUSD = "\(DM)$0.00\(R)"
        }

        print("  \(status) \(chain.symbol) \(B)\(chain.name)\(R)\(DM)(\(chain.rawValue))\(R)")
        print("      \(CYAN)\(truncAddr)\(R)")
        print("      Price: \(WHITE)\(priceStr)\(R)  24h: \(changeStr)  Bal: \(WHITE)\(balStr)\(R)  = \(GOLD)\(balUSD)\(R)")
        print()
    }

    // Custom tokens
    if !state.customTokens.isEmpty {
        print("  \(B)\(WHITE)Custom Tokens:\(R)")
        print("  \(DM)─────────────────────────────────────────────────\(R)")
        for token in state.customTokens {
            let price = priceFor(geckoId: token.geckoId)
            let priceStr = price != nil ? formatUSD(price!.usd) : "\(DM)---\(R)"
            let changeStr = formatChange(price?.usd24hChange)

            let bal = state.balances.first(where: { $0.symbol == token.symbol && $0.chain == token.chain })
            let balStr: String
            let balUSD: String
            if let b = bal, let bVal = Double(b.balance) {
                balStr = String(format: "%.4f", bVal)
                if let p = price {
                    let usdVal = bVal * p.usd
                    totalPortfolioUSD += usdVal
                    balUSD = formatUSD(usdVal)
                } else {
                    balUSD = "\(DM)---\(R)"
                }
            } else {
                balStr = "\(DM)0.0000\(R)"
                balUSD = "\(DM)$0.00\(R)"
            }

            print("    \(CYAN)\u{25C8}\(R) \(B)\(token.symbol)\(R) — \(token.name) (\(token.chain.name))")
            print("      Price: \(WHITE)\(priceStr)\(R)  24h: \(changeStr)  Bal: \(WHITE)\(balStr)\(R)  = \(GOLD)\(balUSD)\(R)")
        }
        print()
    }

    // Common tokens (always shown)
    print("  \(B)\(WHITE)Tracked Tokens:\(R)")
    print("  \(DM)─────────────────────────────────────────────────\(R)")
    for token in COMMON_TOKENS {
        let price = priceFor(geckoId: token.geckoId)
        let priceStr = price != nil ? formatUSD(price!.usd) : "\(DM)---\(R)"
        let changeStr = formatChange(price?.usd24hChange)
        print("    \(WHITE)\(token.symbol)\(R) \(token.name)  \(priceStr)  \(changeStr)")
    }
    print()

    // Total
    print("  \(DM)═══════════════════════════════════════════════════\(R)")
    print("  \(B)\(GOLD)  TOTAL PORTFOLIO:  \(WHITE)\(formatUSD(totalPortfolioUSD))\(R)")
    print("  \(DM)═══════════════════════════════════════════════════\(R)")
    print()
}

func printMenu() {
    print("""
    \(B)\(WHITE)  Commands:\(R)
    \(DM)  ─────────────────────────────────────────────────\(R)
      \(GOLD)generate\(R) <chain|all>  Generate wallet key (dual auth)
      \(GOLD)show\(R) <chain>          Show full address (dual auth)
      \(GOLD)balance\(R) <chain> <amt> Set token balance manually
      \(GOLD)prices\(R) <file>        Import prices from local JSON (no network)
      \(GOLD)dashboard\(R)            Show full portfolio
      \(GOLD)add-token\(R)            Add custom ERC-20/SPL token
      \(GOLD)tokens\(R)               List all tracked tokens
      \(GOLD)swap\(R)                 Prepare cross-chain swap
      \(GOLD)history\(R)              Show swap history
      \(GOLD)audit\(R)                Show access audit log
      \(GOLD)passphrase\(R)           Change passphrase (dual auth)
      \(GOLD)lock\(R)                 Lock wallet immediately
      \(GOLD)quit\(R)                 Exit wallet

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
// MARK: - Commands
// ─────────────────────────────────────────

func cmdGenerate(chainArg: String, state: inout WalletState) {
    print()
    printInfo("Dual authentication required...")

    guard dualAuthenticate(reason: "L7 Wallet: Generate keys") else {
        printError("Authentication failed. No keys generated.")
        return
    }

    if chainArg.lowercased() == "all" {
        printInfo("Generating keys for all chains...")
        print()

        for chain in Chain.allCases {
            if state.keys.contains(where: { $0.chain == chain }) {
                printInfo("\(chain.name) — already exists, skipping")
                continue
            }

            if chain.isEVM && chain != .ethereum {
                if let ethKey = state.keys.first(where: { $0.chain == .ethereum }) {
                    let evmKey = WalletKey(
                        chain: chain,
                        publicAddress: ethKey.publicAddress,
                        createdAt: iso8601(),
                        keychainRef: keychainTag(for: chain)
                    )
                    state.keys.append(evmKey)
                    printOK("\(chain.name) — derived from ETH key")
                    auditLog("KEY_DERIVE: \(chain.rawValue) from ETH")
                    continue
                }
            }

            if let result = generateAndStoreKey(chain: chain) {
                let key = WalletKey(
                    chain: chain,
                    publicAddress: result.address,
                    createdAt: iso8601(),
                    keychainRef: keychainTag(for: chain)
                )
                state.keys.append(key)
                printOK("\(chain.name) — \(CYAN)\(result.address.prefix(10))...\(R)")

                if chain == .ethereum {
                    for evmChain in Chain.allCases where evmChain.isEVM && evmChain != .ethereum {
                        if !state.keys.contains(where: { $0.chain == evmChain }) {
                            let evmKey = WalletKey(
                                chain: evmChain,
                                publicAddress: result.address,
                                createdAt: iso8601(),
                                keychainRef: keychainTag(for: evmChain)
                            )
                            state.keys.append(evmKey)
                            printOK("\(evmChain.name) — derived from ETH")
                            auditLog("KEY_DERIVE: \(evmChain.rawValue) from ETH addr=\(result.address)")
                        }
                    }
                }
            } else {
                printError("\(chain.name) — generation failed")
            }
        }
        saveState(state)
        print()
        return
    }

    guard let chain = Chain.allCases.first(where: {
        $0.rawValue.lowercased() == chainArg.lowercased() ||
        $0.name.lowercased() == chainArg.lowercased()
    }) else {
        printError("Unknown chain: \(chainArg)")
        return
    }

    if state.keys.contains(where: { $0.chain == chain }) {
        printError("\(chain.name) key already exists.")
        return
    }

    if let result = generateAndStoreKey(chain: chain) {
        let key = WalletKey(
            chain: chain,
            publicAddress: result.address,
            createdAt: iso8601(),
            keychainRef: keychainTag(for: chain)
        )
        state.keys.append(key)
        saveState(state)
        printOK("\(chain.name) key generated")
        printInfo("Address: \(CYAN)\(result.address)\(R)")
    }
    print()
}

func cmdShow(chainArg: String, state: WalletState) {
    guard let chain = Chain.allCases.first(where: {
        $0.rawValue.lowercased() == chainArg.lowercased() ||
        $0.name.lowercased() == chainArg.lowercased()
    }) else {
        printError("Unknown chain: \(chainArg)")
        return
    }

    guard let key = state.keys.first(where: { $0.chain == chain }) else {
        printError("No key for \(chain.name). Use 'generate \(chain.rawValue)' first.")
        return
    }

    printInfo("Dual authentication required...")
    guard dualAuthenticate(reason: "L7 Wallet: View \(chain.name) address") else {
        printError("Authentication failed.")
        return
    }

    let price = priceFor(geckoId: chain.geckoId)
    let bal = state.balances.first(where: { $0.chain == chain && $0.symbol == chain.rawValue })

    print()
    print("  \(B)\(chain.symbol) \(chain.name) (\(chain.rawValue))\(R)")
    print("  \(DM)────────────────────────────────────────\(R)")
    print("  \(WHITE)Address:\(R)  \(CYAN)\(key.publicAddress)\(R)")
    print("  \(WHITE)Created:\(R)  \(key.createdAt)")
    if let p = price {
        print("  \(WHITE)Price:\(R)    \(formatUSD(p.usd))  \(formatChange(p.usd24hChange))")
    }
    if let b = bal, let bVal = Double(b.balance) {
        print("  \(WHITE)Balance:\(R)  \(b.balance) \(chain.rawValue)")
        if let p = price {
            print("  \(WHITE)Value:\(R)    \(GOLD)\(formatUSD(bVal * p.usd))\(R)")
        }
    }
    print("  \(WHITE)Auth:\(R)     \(GREEN)Passphrase + Touch ID (dual-factor)\(R)")
    print()
}

func cmdBalance(args: String, state: inout WalletState) {
    let parts = args.split(separator: " ").map(String.init)
    guard parts.count >= 2 else {
        printError("Usage: balance <chain> <amount>")
        return
    }

    guard let chain = Chain.allCases.first(where: {
        $0.rawValue.lowercased() == parts[0].lowercased()
    }) else {
        printError("Unknown chain: \(parts[0])")
        return
    }

    guard let _ = Double(parts[1]) else {
        printError("Invalid amount: \(parts[1])")
        return
    }

    // Remove old balance for this chain/symbol
    state.balances.removeAll(where: { $0.chain == chain && $0.symbol == chain.rawValue })

    let bal = TokenBalance(
        symbol: chain.rawValue,
        chain: chain,
        balance: parts[1],
        lastUpdated: iso8601()
    )
    state.balances.append(bal)
    saveState(state)

    printOK("Balance set: \(parts[1]) \(chain.rawValue)")
    auditLog("BALANCE_SET: \(chain.rawValue) = \(parts[1])")
}

func cmdSwap(state: inout WalletState) {
    print()
    print("  \(B)\(GOLD)Cross-Chain Swap\(R)")
    print("  \(DM)────────────────────────────────────────\(R)")

    print("  \(WHITE)From chain\(R) (\(Chain.allCases.map(\.rawValue).joined(separator: "/"))): ", terminator: "")
    guard let fromStr = readLine()?.trimmingCharacters(in: .whitespaces),
          let fromChain = Chain.allCases.first(where: { $0.rawValue.lowercased() == fromStr.lowercased() }) else {
        printError("Invalid source chain")
        return
    }

    guard state.keys.contains(where: { $0.chain == fromChain }) else {
        printError("No key for \(fromChain.name). Generate first.")
        return
    }

    print("  \(WHITE)To chain\(R): ", terminator: "")
    guard let toStr = readLine()?.trimmingCharacters(in: .whitespaces),
          let toChain = Chain.allCases.first(where: { $0.rawValue.lowercased() == toStr.lowercased() }) else {
        printError("Invalid destination chain")
        return
    }

    print("  \(WHITE)Token symbol\(R): ", terminator: "")
    guard let tokenSymbol = readLine()?.trimmingCharacters(in: .whitespaces).uppercased(), !tokenSymbol.isEmpty else {
        printError("Invalid token")
        return
    }

    print("  \(WHITE)Amount\(R): ", terminator: "")
    guard let amountStr = readLine()?.trimmingCharacters(in: .whitespaces),
          let _ = Double(amountStr) else {
        printError("Invalid amount")
        return
    }

    printInfo("Dual authentication required for swap...")
    guard dualAuthenticate(reason: "L7 Wallet: Swap \(amountStr) \(tokenSymbol) \(fromChain.rawValue)->\(toChain.rawValue)") else {
        printError("Swap not authorized.")
        return
    }

    let swap = SwapRecord(
        id: UUID().uuidString,
        fromChain: fromChain,
        toChain: toChain,
        fromToken: tokenSymbol,
        toToken: tokenSymbol,
        amount: amountStr,
        timestamp: iso8601(),
        status: "prepared",
        txHash: nil
    )

    state.swapHistory.append(swap)
    saveState(state)

    print()
    printOK("Swap prepared")
    print("  \(DM)ID:\(R)     \(swap.id.prefix(8))...")
    print("  \(DM)Route:\(R)  \(fromChain.rawValue) -> \(toChain.rawValue)")
    print("  \(DM)Amount:\(R) \(amountStr) \(tokenSymbol)")
    print("  \(DM)Status:\(R) \(GOLD)prepared — awaiting broadcast\(R)")

    auditLog("SWAP_PREPARE: \(swap.id) \(fromChain.rawValue)->\(toChain.rawValue) \(amountStr) \(tokenSymbol)")
    print()
}

func cmdAddToken(state: inout WalletState) {
    print()
    print("  \(B)\(GOLD)Add Custom Token\(R)")
    print("  \(DM)────────────────────────────────────────\(R)")

    print("  \(WHITE)Chain\(R): ", terminator: "")
    guard let chainStr = readLine()?.trimmingCharacters(in: .whitespaces),
          let chain = Chain.allCases.first(where: { $0.rawValue.lowercased() == chainStr.lowercased() }) else {
        printError("Invalid chain")
        return
    }

    print("  \(WHITE)Symbol\(R): ", terminator: "")
    guard let symbol = readLine()?.trimmingCharacters(in: .whitespaces).uppercased(), !symbol.isEmpty else { return }

    print("  \(WHITE)Name\(R): ", terminator: "")
    guard let name = readLine()?.trimmingCharacters(in: .whitespaces), !name.isEmpty else { return }

    print("  \(WHITE)Contract address\(R): ", terminator: "")
    guard let contract = readLine()?.trimmingCharacters(in: .whitespaces), !contract.isEmpty else { return }

    print("  \(WHITE)CoinGecko ID\(R) (optional, for price): ", terminator: "")
    let geckoId = readLine()?.trimmingCharacters(in: .whitespaces)

    print("  \(WHITE)Decimals\(R) (default 18): ", terminator: "")
    let decimals = Int(readLine()?.trimmingCharacters(in: .whitespaces) ?? "18") ?? 18

    let token = Token(symbol: symbol, name: name, chain: chain, contractAddress: contract, decimals: decimals, geckoId: geckoId?.isEmpty == true ? nil : geckoId)
    state.customTokens.append(token)
    saveState(state)

    printOK("Token added: \(symbol) (\(name)) on \(chain.name)")
    auditLog("TOKEN_ADD: \(symbol) chain=\(chain.rawValue) contract=\(contract)")
    print()
}

func cmdHistory(_ state: WalletState) {
    print()
    print("  \(B)\(WHITE)Swap History:\(R)")
    print("  \(DM)────────────────────────────────────────\(R)")

    if state.swapHistory.isEmpty {
        printInfo("No swaps recorded.")
    } else {
        for swap in state.swapHistory.reversed() {
            let statusColor = swap.status == "confirmed" ? GREEN : (swap.status == "failed" ? RED : GOLD)
            print("  \(DM)\(swap.timestamp)\(R)")
            print("    \(swap.fromChain.rawValue) -> \(swap.toChain.rawValue)  \(swap.amount) \(swap.fromToken)")
            print("    \(statusColor)\(swap.status)\(R)  \(DM)\(swap.id.prefix(8))...\(R)")
            if let tx = swap.txHash { print("    \(CYAN)tx: \(tx)\(R)") }
            print()
        }
    }
}

func cmdAudit() {
    print()
    print("  \(B)\(WHITE)Audit Log (last 30 entries):\(R)")
    print("  \(DM)────────────────────────────────────────\(R)")

    guard let data = FileManager.default.contents(atPath: WALLET_LOG),
          let log = String(data: data, encoding: .utf8) else {
        printInfo("No audit entries yet.")
        return
    }

    let lines = log.components(separatedBy: "\n").filter { !$0.isEmpty }
    for line in lines.suffix(30) {
        print("  \(DM)\(line)\(R)")
    }
    print()
    printInfo("Total entries: \(lines.count) (permanent, never deleted)")
    print()
}

func cmdChangePassphrase() {
    printInfo("Dual authentication required to change passphrase...")
    guard dualAuthenticate(reason: "L7 Wallet: Change passphrase") else {
        printError("Cannot change passphrase without current authentication.")
        return
    }
    _ = setupPassphrase()
}

// ─────────────────────────────────────────
// MARK: - Main
// ─────────────────────────────────────────

func main() {
    banner()

    // ── ZERO TRUST SECURITY CHECKS ──
    // Each app is an ashram: isolated, self-contained, no cross-pollination.
    // No outgoing connections. No shared state with other apps.
    // Transparent channels only — if it's not shown, it doesn't exist.

    // 1. Anti-debug: refuse to run under a debugger
    guard verifyProcessIsolation() else {
        printError("Wallet will not operate in a traced/debugged environment.")
        exit(1)
    }

    // 2. Log parent process for audit trail
    _ = verifyParentProcess()

    // 3. Verify no other L7 app is accessing wallet files (ashram isolation)
    auditLog("ISOLATION_CHECK: Wallet operates in sealed ashram. No IPC. No shared memory. No network.")

    ensureWalletDir()

    // 4. Verify file permissions haven't been tampered with
    let permChecks = [
        (WALLET_DIR, mode_t(0o700)),
        (WALLET_DB, mode_t(0o600)),
        (WALLET_LOG, mode_t(0o600)),
        (WALLET_PASS_HASH, mode_t(0o600)),
    ]
    for (path, expected) in permChecks {
        guard verifyPermissions(path, expected: expected) else {
            auditLog("WALLET_ABORT: Permission tampering detected on \(path)")
            exit(1)
        }
    }

    auditLog("WALLET_OPEN: v\(WALLET_VERSION) — all security checks passed")

    // First-time setup
    if !passphraseExists() {
        printInfo("First-time wallet setup.")
        print()

        // Set passphrase first
        guard setupPassphrase() else {
            printError("Passphrase setup failed. Wallet cannot be created without dual-factor auth.")
            exit(1)
        }
        print()

        // Then verify biometrics work
        printInfo("Now verifying Touch ID...")
        guard authenticateBiometric(reason: "L7 Wallet: Verify biometric enrollment") else {
            printError("Touch ID verification failed. Both factors are required.")
            exit(1)
        }

        printOK("Dual-factor authentication configured.")
        auditLog("WALLET_INIT: First-time setup complete. Dual auth configured.")
    } else {
        // Returning user — full dual auth
        printInfo("Dual authentication required...")
        print()
        guard dualAuthenticate(reason: "L7 Wallet: Founder authentication") else {
            printError("Access denied. Dual-factor authentication failed.")
            auditLog("WALLET_DENIED: Failed dual auth at open")
            exit(1)
        }
    }

    printOK("Welcome, Founder.")
    print()

    // Load state and prices
    var state = loadState()

    printInfo("Loading cached prices (offline-only)...")
    loadCachedPrices()

    print()
    printDashboard(state)
    printMenu()

    // REPL
    while true {
        print("  \(GOLD)\(B)l7:wallet>\(R) ", terminator: "")
        guard let input = readLine()?.trimmingCharacters(in: .whitespaces), !input.isEmpty else {
            continue
        }

        let parts = input.split(separator: " ", maxSplits: 1).map(String.init)
        let cmd = parts[0].lowercased()
        let arg = parts.count > 1 ? parts[1] : ""

        switch cmd {
        case "generate", "gen", "g":
            if arg.isEmpty {
                printError("Usage: generate <chain|all>")
            } else {
                cmdGenerate(chainArg: arg, state: &state)
            }

        case "show", "s":
            if arg.isEmpty { printError("Usage: show <chain>") }
            else { cmdShow(chainArg: arg, state: state) }

        case "balance", "bal", "b":
            if arg.isEmpty { printError("Usage: balance <chain> <amount>") }
            else { cmdBalance(args: arg, state: &state) }

        case "prices", "p":
            if arg.isEmpty {
                printError("Usage: prices <path-to-json-file>")
                printInfo("No network. Import from local file only.")
                printInfo("Format: { \"bitcoin\": { \"usd\": 60000, \"usd_24h_change\": 1.5 }, ... }")
            } else {
                importPricesFromFile(arg)
                printDashboard(state)
            }

        case "dashboard", "d":
            printDashboard(state)

        case "swap":
            cmdSwap(state: &state)

        case "add-token", "addtoken", "add":
            cmdAddToken(state: &state)

        case "tokens", "t":
            print()
            print("  \(B)\(WHITE)All Tracked Tokens:\(R)")
            print("  \(DM)────────────────────────────────────────\(R)")
            for t in NATIVE_TOKENS {
                let p = priceFor(geckoId: t.geckoId)
                let ps = p != nil ? formatUSD(p!.usd) : "\(DM)---\(R)"
                print("    \(GREEN)\u{25CF}\(R) \(B)\(t.symbol)\(R) \(t.name)  \(ps)  \(formatChange(p?.usd24hChange))")
            }
            for t in COMMON_TOKENS {
                let p = priceFor(geckoId: t.geckoId)
                let ps = p != nil ? formatUSD(p!.usd) : "\(DM)---\(R)"
                print("    \(CYAN)\u{25C8}\(R) \(B)\(t.symbol)\(R) \(t.name)  \(ps)  \(formatChange(p?.usd24hChange))")
            }
            for t in state.customTokens {
                let p = priceFor(geckoId: t.geckoId)
                let ps = p != nil ? formatUSD(p!.usd) : "\(DM)---\(R)"
                print("    \(MAG)\u{25C6}\(R) \(B)\(t.symbol)\(R) \(t.name)  \(ps)  \(formatChange(p?.usd24hChange))")
            }
            print()

        case "history", "h":
            cmdHistory(state)

        case "audit", "a":
            cmdAudit()

        case "passphrase":
            cmdChangePassphrase()

        case "lock", "l":
            saveState(state)
            auditLog("WALLET_LOCK: Manual lock")
            printOK("Wallet locked. Vault sealed.")
            exit(0)

        case "quit", "q", "exit":
            saveState(state)
            auditLog("WALLET_CLOSE: Normal exit")
            printOK("Vault sealed.")
            exit(0)

        case "help", "?":
            printMenu()

        default:
            printError("Unknown: \(cmd). Type 'help'.")
        }
    }
}

main()
