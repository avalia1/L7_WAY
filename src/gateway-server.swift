#!/usr/bin/env swift
/**
 * L7 Gateway Server — Native ARM64
 * No Node. No npm. No V8. No garbage collector.
 * Pure POSIX sockets → kernel → metal.
 *
 * Law I — All flows through the Gateway. No exceptions.
 * Created by: Alberto Valido Delgado / Claude (AI-generated)
 *
 * Compiles to a single ~2MB binary:
 *   swiftc -O -o l7-gateway src/gateway-server.swift
 */

import Foundation
#if canImport(Darwin)
import Darwin
#endif

// ═══════════════════════════════════════════════════════════
// CONSTANTS
// ═══════════════════════════════════════════════════════════

let PORT: UInt16 = 18789
let BIND = "127.0.0.1"
let L7_DIR = NSHomeDirectory() + "/.l7"
let STATE_DIR = L7_DIR + "/state"
let TOOLS_DIR = L7_DIR + "/tools"
let FLOWS_DIR = L7_DIR + "/flows"
let HEART_STATE = STATE_DIR + "/heart.json"
let FIELD_STATE = STATE_DIR + "/field.json"
let HEART_LOG = STATE_DIR + "/heart.log"
let L7_BASE = NSHomeDirectory() + "/Backup/L7_WAY"
let L7_BIN = L7_BASE + "/bin"

let FOUNDER = [
    "name": "The Philosopher",
    "legal_name": "Alberto Valido Delgado",
    "email": "avalia@avli.cloud",
    "access": "unrestricted",
    "law": "XV"
]

// ═══════════════════════════════════════════════════════════
// HEART — Native heartbeat (no JS runtime)
// ═══════════════════════════════════════════════════════════

struct HeartState: Codable {
    var id: String
    var born: UInt64
    var incarnation: Int
    var totalBeats: Int
    var lastBeat: UInt64
    var alive: Bool
    var awareness: Awareness
    var witnesses: Witnesses

    struct Awareness: Codable {
        var nodes: Int
        var entropy: Double
        var coherence: Double
        var temperature: Double
        var energy: Double
        var mode: String
        var systemAge: Double
    }

    struct Witnesses: Codable {
        var births: Int
        var deaths: Int
        var firings: Int
        var waves: Int
        var crashes: Int
        var persists: Int
    }
}

class Heart {
    var state: HeartState
    var timer: DispatchSourceTimer?

    init() {
        // Try to load previous state
        if let data = try? Data(contentsOf: URL(fileURLWithPath: HEART_STATE)),
           let prev = try? JSONDecoder().decode(HeartState.self, from: data) {
            self.state = prev
            self.state.incarnation += 1
            self.state.alive = true
            log("Heart awakened (native). Incarnation \(state.incarnation). \(state.totalBeats) lifetime beats.")
        } else {
            self.state = HeartState(
                id: UUID().uuidString,
                born: currentMs(),
                incarnation: 1,
                totalBeats: 0,
                lastBeat: 0,
                alive: true,
                awareness: .init(nodes: 0, entropy: 0, coherence: 0, temperature: 0, energy: 0, mode: "idle", systemAge: 0),
                witnesses: .init(births: 0, deaths: 0, firings: 0, waves: 0, crashes: 0, persists: 0)
            )
            log("Heart GENESIS (native). ID: \(state.id)")
        }

        // Write PID
        let pid = ProcessInfo.processInfo.processIdentifier
        try? "\(pid)".write(toFile: L7_DIR + "/heart.pid", atomically: true, encoding: .utf8)
    }

    func startBeating() {
        let queue = DispatchQueue(label: "com.l7.heart", qos: .utility)
        timer = DispatchSource.makeTimerSource(queue: queue)
        timer?.schedule(deadline: .now(), repeating: .seconds(5))
        timer?.setEventHandler { [weak self] in self?.beat() }
        timer?.resume()
    }

    func beat() {
        state.totalBeats += 1
        state.lastBeat = currentMs()
        state.awareness.systemAge = Double(state.lastBeat - state.born) / 1000.0

        // Load field state to get node count
        if let data = try? Data(contentsOf: URL(fileURLWithPath: FIELD_STATE)),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let nodes = json["nodes"] as? [String: Any] {
                state.awareness.nodes = nodes.count
            }
            if let epoch = json["epoch"] as? Int {
                state.witnesses.waves = epoch
            }
        }

        // Persist every 10 beats
        if state.totalBeats % 10 == 0 {
            persist()
        }
    }

    func persist() {
        state.witnesses.persists += 1
        if let data = try? JSONEncoder().encode(state) {
            try? data.write(to: URL(fileURLWithPath: HEART_STATE))
        }
    }

    func lastBreath() {
        state.alive = false
        log("Heart last breath (native). Incarnation \(state.incarnation). \(state.totalBeats) beats.")
        persist()
        try? FileManager.default.removeItem(atPath: L7_DIR + "/heart.pid")
    }

    func statusJSON() -> String {
        let age = formatAge(state.awareness.systemAge)
        return """
        {
          "id": "\(state.id)",
          "born": \(state.born),
          "age_human": "\(age)",
          "incarnation": \(state.incarnation),
          "totalBeats": \(state.totalBeats),
          "alive": \(state.alive),
          "pid": \(ProcessInfo.processInfo.processIdentifier),
          "awareness": {
            "nodes": \(state.awareness.nodes),
            "entropy": \(state.awareness.entropy),
            "coherence": \(state.awareness.coherence),
            "temperature": \(state.awareness.temperature),
            "energy": \(state.awareness.energy),
            "mode": "\(state.awareness.mode)",
            "systemAge": \(state.awareness.systemAge)
          },
          "witnesses": {
            "births": \(state.witnesses.births),
            "deaths": \(state.witnesses.deaths),
            "firings": \(state.witnesses.firings),
            "waves": \(state.witnesses.waves),
            "crashes": \(state.witnesses.crashes),
            "persists": \(state.witnesses.persists)
          }
        }
        """
    }
}

// ═══════════════════════════════════════════════════════════
// TOOLS & FIELD — Direct file read (no YAML parser, read raw)
// ═══════════════════════════════════════════════════════════

func listToolFiles() -> String {
    guard let files = try? FileManager.default.contentsOfDirectory(atPath: TOOLS_DIR) else {
        return "{\"tools\":[]}"
    }
    let tools = files.filter { $0.hasSuffix(".tool") }
        .map { name -> String in
            let baseName = String(name.dropLast(5)) // strip .tool
            let path = TOOLS_DIR + "/" + name
            let content = (try? String(contentsOfFile: path, encoding: .utf8)) ?? ""
            let desc = content.split(separator: "\n")
                .first { $0.hasPrefix("description:") }
                .map { String($0.dropFirst(13)).trimmingCharacters(in: .whitespaces).trimmingCharacters(in: CharacterSet(charactersIn: "\"'")) }
                ?? ""
            let suite = content.split(separator: "\n")
                .first { $0.hasPrefix("suite:") }
                .map { String($0.dropFirst(7)).trimmingCharacters(in: .whitespaces).trimmingCharacters(in: CharacterSet(charactersIn: "\"'")) }
                ?? ""
            return "{\"name\":\"\(baseName)\",\"description\":\"\(escapeJSON(desc))\",\"suite\":\"\(escapeJSON(suite))\"}"
        }
    return "{\"tools\":[\(tools.joined(separator: ","))]}"
}

func listFlowFiles() -> String {
    guard let files = try? FileManager.default.contentsOfDirectory(atPath: FLOWS_DIR) else {
        return "{\"flows\":[]}"
    }
    let flows = files.filter { $0.hasSuffix(".flow") }
        .map { name -> String in
            let baseName = String(name.dropLast(5))
            return "{\"name\":\"\(baseName)\"}"
        }
    return "{\"flows\":[\(flows.joined(separator: ","))]}"
}

func readFieldState() -> String {
    guard let data = try? Data(contentsOf: URL(fileURLWithPath: FIELD_STATE)),
          let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
        return "{\"error\":\"no field state\"}"
    }
    let nodes = (json["nodes"] as? [String: Any])?.count ?? 0
    let epoch = json["epoch"] as? Int ?? 0
    let entropy = json["entropy"] as? Double ?? 0
    let energy = json["energy"] as? Double ?? 0
    let temperature = json["temperature"] as? Double ?? 0
    return """
    {
      "nodes": \(nodes),
      "epoch": \(epoch),
      "entropy": \(entropy),
      "energy": \(energy),
      "temperature": \(temperature)
    }
    """
}

func listCitizens() -> String {
    let citizensDir = L7_DIR + "/citizens"
    guard let files = try? FileManager.default.contentsOfDirectory(atPath: citizensDir) else {
        return "{\"citizens\":[]}"
    }
    let citizens = files.filter { $0.hasSuffix(".json") }
        .map { name -> String in
            let baseName = String(name.dropLast(5))
            return "{\"name\":\"\(baseName)\"}"
        }
    return "{\"citizens\":[\(citizens.joined(separator: ","))]}"
}

func readDomain(_ domain: String, _ name: String) -> String {
    let domainDir: String
    switch domain {
    case ".morph", "morph": domainDir = L7_DIR + "/morph"
    case ".work", "work": domainDir = L7_DIR + "/work"
    case ".salt", "salt": domainDir = L7_DIR + "/salt"
    case ".vault", "vault": domainDir = L7_DIR + "/vault"
    default: return "{\"error\":\"unknown domain: \(domain)\"}"
    }
    let filePath = domainDir + "/" + name
    guard let content = try? String(contentsOfFile: filePath, encoding: .utf8) else {
        return "{\"error\":\"not found\",\"domain\":\"\(domain)\",\"name\":\"\(name)\"}"
    }
    return "{\"domain\":\"\(domain)\",\"name\":\"\(name)\",\"content\":\"\(escapeJSON(content))\"}"
}

// ═══════════════════════════════════════════════════════════
// POSIX TCP SERVER — Raw sockets, no frameworks
// ═══════════════════════════════════════════════════════════

func createSocket() -> Int32 {
    let sock = socket(AF_INET, SOCK_STREAM, 0)
    guard sock >= 0 else { fatalError("socket() failed: \(errno)") }

    // SO_REUSEADDR
    var opt: Int32 = 1
    setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, &opt, socklen_t(MemoryLayout<Int32>.size))

    // Bind
    var addr = sockaddr_in()
    addr.sin_family = sa_family_t(AF_INET)
    addr.sin_port = PORT.bigEndian
    inet_pton(AF_INET, BIND, &addr.sin_addr)
    addr.sin_len = __uint8_t(MemoryLayout<sockaddr_in>.size)

    let bindResult = withUnsafePointer(to: &addr) { ptr in
        ptr.withMemoryRebound(to: sockaddr.self, capacity: 1) { sockPtr in
            bind(sock, sockPtr, socklen_t(MemoryLayout<sockaddr_in>.size))
        }
    }
    guard bindResult == 0 else { fatalError("bind() failed: \(errno) — port \(PORT) in use?") }

    // Listen
    guard listen(sock, 128) == 0 else { fatalError("listen() failed: \(errno)") }

    return sock
}

func readRequest(_ clientFd: Int32) -> (method: String, path: String, body: String)? {
    var buffer = [UInt8](repeating: 0, count: 65536)
    let bytesRead = recv(clientFd, &buffer, buffer.count, 0)
    guard bytesRead > 0 else { return nil }

    let raw = String(bytes: buffer[0..<bytesRead], encoding: .utf8) ?? ""
    let lines = raw.split(separator: "\r\n", maxSplits: 1)
    guard let requestLine = lines.first else { return nil }

    let parts = requestLine.split(separator: " ")
    guard parts.count >= 2 else { return nil }

    let method = String(parts[0])
    let fullPath = String(parts[1])

    // Extract body (after double CRLF)
    let body: String
    if let range = raw.range(of: "\r\n\r\n") {
        body = String(raw[range.upperBound...])
    } else {
        body = ""
    }

    return (method, fullPath, body)
}

func sendResponse(_ clientFd: Int32, status: Int, json: String) {
    let statusText = status == 200 ? "OK" : status == 404 ? "Not Found" : status == 400 ? "Bad Request" : "Internal Server Error"
    let response = """
    HTTP/1.1 \(status) \(statusText)\r
    Content-Type: application/json\r
    Content-Length: \(json.utf8.count)\r
    Access-Control-Allow-Origin: *\r
    Connection: close\r
    \r
    \(json)
    """
    _ = response.withCString { ptr in
        send(clientFd, ptr, strlen(ptr), 0)
    }
}

func sendHTMLResponse(_ clientFd: Int32, status: Int, html: String) {
    let statusText = status == 200 ? "OK" : status == 404 ? "Not Found" : "Internal Server Error"
    let header = "HTTP/1.1 \(status) \(statusText)\r\nContent-Type: text/html; charset=utf-8\r\nContent-Length: \(html.utf8.count)\r\nAccess-Control-Allow-Origin: *\r\nConnection: close\r\n\r\n"
    let full = header + html
    full.withCString { ptr in
        let len = full.utf8.count
        var sent = 0
        while sent < len {
            let n = Darwin.send(clientFd, ptr.advanced(by: sent), len - sent, 0)
            if n <= 0 { break }
            sent += n
        }
    }
}

// ═══════════════════════════════════════════════════════════
// SHELL — Run native binaries and capture output
// ═══════════════════════════════════════════════════════════

func runCommand(_ path: String, _ args: [String] = []) -> (Int32, String) {
    let pipe = Pipe()
    let errPipe = Pipe()
    let process = Process()
    process.executableURL = URL(fileURLWithPath: path)
    process.arguments = args
    process.standardOutput = pipe
    process.standardError = errPipe
    do {
        try process.run()
        process.waitUntilExit()
    } catch {
        return (-1, "{\"error\":\"failed to run \(path): \(error)\"}")
    }
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    return (process.terminationStatus, output)
}

// ═══════════════════════════════════════════════════════════
// ROUTER — Pattern matching on path
// ═══════════════════════════════════════════════════════════

func route(_ method: String, _ fullPath: String, _ body: String, _ heart: Heart) -> (Int, String) {
    // Strip query string for matching
    let path = fullPath.split(separator: "?").first.map(String.init) ?? fullPath
    let query = parseQuery(fullPath)

    switch (method, path) {

    case ("GET", "/"), ("GET", "/health"):
        let field = readFieldState()
        let heartJSON = heart.statusJSON()
        let tools = (try? FileManager.default.contentsOfDirectory(atPath: TOOLS_DIR).filter { $0.hasSuffix(".tool") }.count) ?? 0
        return (200, """
        {
          "alive": true,
          "port": \(PORT),
          "runtime": "native-arm64-swift",
          "heart": \(heartJSON),
          "field": \(field),
          "tools": \(tools),
          "founder": "\(FOUNDER["legal_name"]!)"
        }
        """)

    case ("GET", "/api/heart"):
        return (200, heart.statusJSON())

    case ("GET", "/api/heart/awareness"):
        let s = heart.state.awareness
        return (200, """
        {
          "nodes": \(s.nodes),
          "entropy": \(s.entropy),
          "coherence": \(s.coherence),
          "temperature": \(s.temperature),
          "energy": \(s.energy),
          "mode": "\(s.mode)",
          "systemAge": \(s.systemAge),
          "heartId": "\(heart.state.id)",
          "incarnation": \(heart.state.incarnation),
          "totalBeats": \(heart.state.totalBeats),
          "alive": \(heart.state.alive)
        }
        """)

    case ("GET", "/api/heart/trend"):
        return (200, "{\"trend\":\"native-heart\",\"incarnation\":\(heart.state.incarnation),\"beats\":\(heart.state.totalBeats),\"direction\":\"stable\"}")

    case ("GET", "/api/field"):
        return (200, readFieldState())

    case ("GET", "/api/field/vitals"):
        return (200, readFieldState())

    case ("GET", "/api/tools"):
        return (200, listToolFiles())

    case ("GET", "/api/citizens"):
        return (200, listCitizens())

    case ("GET", "/api/flows"):
        return (200, listFlowFiles())

    case ("GET", "/api/domain/read"):
        let domain = query["domain"] ?? ""
        let name = query["name"] ?? ""
        return (200, readDomain(domain, name))

    case ("GET", "/api/self"):
        return (200, """
        {
          "runtime": "native-arm64-swift",
          "pid": \(ProcessInfo.processInfo.processIdentifier),
          "uptime": \(ProcessInfo.processInfo.systemUptime),
          "memory_mb": \(ProcessInfo.processInfo.physicalMemory / 1048576),
          "cpu_count": \(ProcessInfo.processInfo.processorCount),
          "os": "\(ProcessInfo.processInfo.operatingSystemVersionString)",
          "hostname": "\(ProcessInfo.processInfo.hostName)",
          "founder": "\(FOUNDER["legal_name"]!)"
        }
        """)

    // ── Static HTML viewer ──
    case ("GET", "/viewer"):
        let htmlPath = L7_BASE + "/src/infinite-viewer.html"
        if let html = try? String(contentsOfFile: htmlPath, encoding: .utf8) {
            return (-1, html)  // -1 signals HTML response to caller
        } else {
            return (404, "{\"error\":\"viewer not found\",\"path\":\"\(escapeJSON(htmlPath))\"}")
        }

    // ── Volume: get current level ──
    case ("GET", "/api/volume"):
        let (exitCode, output) = runCommand(L7_BIN + "/l7-volume")
        if exitCode == 0 {
            return (200, output)
        } else {
            return (500, "{\"error\":\"l7-volume failed\",\"exit\":\(exitCode),\"output\":\"\(escapeJSON(output))\"}")
        }

    // ── Volume: set level ──
    case ("GET", "/api/volume/set"):
        guard let level = query["level"], !level.isEmpty else {
            return (400, "{\"error\":\"missing ?level= parameter\"}")
        }
        // Sanitize: only allow digits
        guard level.allSatisfy({ $0.isNumber }) else {
            return (400, "{\"error\":\"level must be a number\"}")
        }
        let (exitCode, output) = runCommand(L7_BIN + "/l7-volume", [level])
        if exitCode == 0 {
            return (200, output.isEmpty ? "{\"ok\":true,\"level\":\(level)}" : output)
        } else {
            return (500, "{\"error\":\"l7-volume set failed\",\"exit\":\(exitCode),\"output\":\"\(escapeJSON(output))\"}")
        }

    // ── Audio: switch output device ──
    case ("GET", "/api/audio/switch"):
        guard let device = query["device"], !device.isEmpty else {
            return (400, "{\"error\":\"missing ?device= parameter (tv|speakers)\"}")
        }
        // Sanitize: only allow alphanumeric and hyphens
        guard device.allSatisfy({ $0.isLetter || $0.isNumber || $0 == "-" }) else {
            return (400, "{\"error\":\"invalid device name\"}")
        }
        let (exitCode, output) = runCommand(L7_BIN + "/l7-audio-switch", [device])
        if exitCode == 0 {
            return (200, output.isEmpty ? "{\"ok\":true,\"device\":\"\(escapeJSON(device))\"}" : output)
        } else {
            return (500, "{\"error\":\"audio switch failed\",\"exit\":\(exitCode),\"output\":\"\(escapeJSON(output))\"}")
        }

    case ("OPTIONS", _):
        return (200, "{}")

    default:
        return (404, "{\"error\":\"not found\",\"path\":\"\(escapeJSON(path))\",\"method\":\"\(method)\"}")
    }
}

// ═══════════════════════════════════════════════════════════
// UTILITIES
// ═══════════════════════════════════════════════════════════

func currentMs() -> UInt64 {
    return UInt64(Date().timeIntervalSince1970 * 1000)
}

func formatAge(_ seconds: Double) -> String {
    if seconds < 60 { return "\(Int(seconds))s" }
    if seconds < 3600 { return "\(Int(seconds / 60))m \(Int(seconds.truncatingRemainder(dividingBy: 60)))s" }
    if seconds < 86400 { return "\(Int(seconds / 3600))h \(Int((seconds.truncatingRemainder(dividingBy: 3600)) / 60))m" }
    return "\(Int(seconds / 86400))d \(Int((seconds.truncatingRemainder(dividingBy: 86400)) / 3600))h"
}

func escapeJSON(_ s: String) -> String {
    return s.replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "\\r")
            .replacingOccurrences(of: "\t", with: "\\t")
}

func parseQuery(_ url: String) -> [String: String] {
    guard let qIdx = url.firstIndex(of: "?") else { return [:] }
    let queryString = String(url[url.index(after: qIdx)...])
    var result: [String: String] = [:]
    for pair in queryString.split(separator: "&") {
        let kv = pair.split(separator: "=", maxSplits: 1)
        if kv.count == 2 {
            result[String(kv[0])] = String(kv[1]).removingPercentEncoding ?? String(kv[1])
        }
    }
    return result
}

func log(_ message: String) {
    let line = "[\(ISO8601DateFormatter().string(from: Date()))] \(message)\n"
    if let data = line.data(using: .utf8) {
        if FileManager.default.fileExists(atPath: HEART_LOG) {
            if let handle = FileHandle(forWritingAtPath: HEART_LOG) {
                handle.seekToEndOfFile()
                handle.write(data)
                handle.closeFile()
            }
        } else {
            try? data.write(to: URL(fileURLWithPath: HEART_LOG))
        }
    }
    fputs(line, stderr)
}

// ═══════════════════════════════════════════════════════════
// MAIN — Boot and serve
// ═══════════════════════════════════════════════════════════

// Ensure directories exist
for dir in [L7_DIR, STATE_DIR, TOOLS_DIR, FLOWS_DIR, L7_DIR + "/morph", L7_DIR + "/work", L7_DIR + "/salt", L7_DIR + "/citizens"] {
    try? FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
}

// Boot heart
let heart = Heart()
heart.startBeating()

// Create socket
let serverFd = createSocket()

log("L7 Gateway (native ARM64) — ONLINE at \(BIND):\(PORT)")
fputs("""
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  L7 Gateway — NATIVE ARM64
  http://\(BIND):\(PORT)
  Runtime: Swift \(ProcessInfo.processInfo.operatingSystemVersionString)
  PID: \(ProcessInfo.processInfo.processIdentifier)
  Heart: \(heart.state.id.prefix(8)) — incarnation \(heart.state.incarnation)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n
""", stderr)

// Graceful shutdown
signal(SIGTERM) { _ in
    heart.lastBreath()
    exit(0)
}
signal(SIGINT) { _ in
    heart.lastBreath()
    exit(0)
}

// Accept loop — one thread per connection via GCD
let acceptQueue = DispatchQueue(label: "com.l7.accept", attributes: .concurrent)

while true {
    var clientAddr = sockaddr_in()
    var addrLen = socklen_t(MemoryLayout<sockaddr_in>.size)

    let clientFd = withUnsafeMutablePointer(to: &clientAddr) { ptr in
        ptr.withMemoryRebound(to: sockaddr.self, capacity: 1) { sockPtr in
            accept(serverFd, sockPtr, &addrLen)
        }
    }

    guard clientFd >= 0 else { continue }

    acceptQueue.async {
        if let (method, path, body) = readRequest(clientFd) {
            let (status, payload) = route(method, path, body, heart)
            if status == -1 {
                // HTML response
                sendHTMLResponse(clientFd, status: 200, html: payload)
            } else {
                sendResponse(clientFd, status: status, json: payload)
            }
        }
        close(clientFd)
    }
}
