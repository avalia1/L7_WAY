// ======================================================================
// L7 FOUNDATION — Offline On-Device Inference (Apple Intelligence)
// Wraps Apple's FoundationModels framework. No network required.
//
// Modes:
//   l7-foundation chat "<prompt>"              one-shot CLI response, prints to stdout
//   l7-foundation serve [--port N]             OpenAI-compatible local HTTP server
//   l7-foundation [app]                        native windowed chat UI
//   l7-foundation code <file> "<instr>" [--apply]   quick single-file edit (on-device)
//     Small-context by design: this model can't hold a whole codebase. Give it
//     one file and one focused instruction. Prints a unified diff; only writes
//     the file when --apply is passed.
//
// Creator: Alberto Valido Delgado
// System: L7 Universal OS
// ======================================================================

import Foundation
import FoundationModels
import Network
import AppKit

// ─────────────────────────────────────────
// MARK: - Core inference
// ─────────────────────────────────────────

enum FoundationCoreError: Error, CustomStringConvertible {
    case unavailable(String)
    case generationFailed(String)

    var description: String {
        switch self {
        case .unavailable(let reason): return "on-device model unavailable: \(reason)"
        case .generationFailed(let reason): return "generation failed: \(reason)"
        }
    }
}

func respondOnDevice(prompt: String, system: String? = nil) async throws -> String {
    let model = SystemLanguageModel.default
    guard case .available = model.availability else {
        throw FoundationCoreError.unavailable("\(model.availability)")
    }
    let session: LanguageModelSession
    if let system = system, !system.isEmpty {
        session = LanguageModelSession(instructions: system)
    } else {
        session = LanguageModelSession()
    }
    do {
        let response = try await session.respond(to: prompt)
        return response.content
    } catch {
        throw FoundationCoreError.generationFailed("\(error)")
    }
}

// ─────────────────────────────────────────
// MARK: - Mode: chat (one-shot CLI)
// ─────────────────────────────────────────

func runChatMode(args: [String]) async {
    var prompt = args.joined(separator: " ")
    if prompt.isEmpty {
        // Fall back to stdin
        var lines: [String] = []
        while let line = readLine(strippingNewline: true) {
            lines.append(line)
        }
        prompt = lines.joined(separator: "\n")
    }
    guard !prompt.isEmpty else {
        FileHandle.standardError.write("usage: l7-foundation chat \"<prompt>\"  (or pipe prompt via stdin)\n".data(using: .utf8)!)
        exit(1)
    }
    do {
        let text = try await respondOnDevice(prompt: prompt)
        print(text)
    } catch {
        FileHandle.standardError.write("error: \(error)\n".data(using: .utf8)!)
        exit(1)
    }
}

// ─────────────────────────────────────────
// MARK: - Mode: code (quick single-file edit, on-device)
// ─────────────────────────────────────────

let codeMaxFileChars = 6000

func stripCodeFences(_ text: String) -> String {
    var s = text.trimmingCharacters(in: .whitespacesAndNewlines)
    if s.hasPrefix("```") {
        if let firstNewline = s.firstIndex(of: "\n") {
            s = String(s[s.index(after: firstNewline)...])
        }
        if s.hasSuffix("```") {
            s = String(s[s.startIndex..<s.index(s.endIndex, offsetBy: -3)])
        }
    }
    return s
}

func runDiff(originalPath: String, revisedPath: String) -> String {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/diff")
    process.arguments = ["-u", originalPath, revisedPath]
    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = pipe
    do {
        try process.run()
        process.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8) ?? ""
    } catch {
        return "(diff unavailable: \(error))"
    }
}

func runCodeMode(args: [String]) async {
    var apply = false
    var positional: [String] = []
    for a in args {
        if a == "--apply" { apply = true } else { positional.append(a) }
    }
    guard let filePath = positional.first else {
        FileHandle.standardError.write("usage: l7-foundation code <file> \"<instruction>\" [--apply]\n".data(using: .utf8)!)
        exit(1)
    }
    let instruction = positional.dropFirst().joined(separator: " ")
    guard !instruction.isEmpty else {
        FileHandle.standardError.write("usage: l7-foundation code <file> \"<instruction>\" [--apply]\n".data(using: .utf8)!)
        exit(1)
    }
    guard let original = try? String(contentsOfFile: filePath, encoding: .utf8) else {
        FileHandle.standardError.write("error: cannot read \(filePath)\n".data(using: .utf8)!)
        exit(1)
    }
    guard original.count <= codeMaxFileChars else {
        FileHandle.standardError.write("""
        error: \(filePath) is \(original.count) chars, over the \(codeMaxFileChars)-char cap for this mode.
        This is a small on-device model (~4K token context) meant for single small files —
        not a full codebase. For larger/multi-file work, use `l7 dev` instead.
        """.data(using: .utf8)!)
        exit(1)
    }

    let system = """
    You are a precise code editor performing a minimal, surgical edit. You are given \
    the complete contents of one file and an instruction. Apply ONLY what the \
    instruction asks for. Keep every existing line, function, and definition unless \
    the instruction explicitly says to change or remove it — this is an addition or \
    modification to the file, never a replacement of the whole file's purpose. \
    Output ONLY the complete revised file content — no explanation, no markdown code \
    fences, no commentary.
    """
    let userPrompt = "Instruction: \(instruction)\n\nFile: \(filePath)\n\n\(original)"

    do {
        let raw = try await respondOnDevice(prompt: userPrompt, system: system)
        let revised = stripCodeFences(raw)

        let tmpPath = NSTemporaryDirectory() + "l7-foundation-revised-\(UUID().uuidString).tmp"
        try revised.write(toFile: tmpPath, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(atPath: tmpPath) }

        let diff = runDiff(originalPath: filePath, revisedPath: tmpPath)
        if diff.isEmpty {
            print("No changes proposed.")
            return
        }
        print(diff)

        if apply {
            try revised.write(toFile: filePath, atomically: true, encoding: .utf8)
            print("\nApplied to \(filePath)")
        } else {
            let proposedPath = filePath + ".l7-proposed"
            try revised.write(toFile: proposedPath, atomically: true, encoding: .utf8)
            print("\nProposed revision written to \(proposedPath) (not applied). Re-run with --apply to write in place.")
        }
    } catch {
        FileHandle.standardError.write("error: \(error)\n".data(using: .utf8)!)
        exit(1)
    }
}

// ─────────────────────────────────────────
// MARK: - Mode: serve (OpenAI-compatible local HTTP server)
// ─────────────────────────────────────────

struct ChatMessage: Decodable {
    let role: String
    let content: String
}

struct ChatRequest: Decodable {
    let model: String?
    let messages: [ChatMessage]
}

func buildPrompt(from messages: [ChatMessage]) -> (system: String?, prompt: String) {
    var system: String? = nil
    var turns: [String] = []
    for m in messages {
        switch m.role {
        case "system":
            system = (system.map { $0 + "\n" } ?? "") + m.content
        case "user":
            turns.append(m.content)
        case "assistant":
            turns.append("(previous assistant reply: \(m.content))")
        default:
            turns.append(m.content)
        }
    }
    return (system, turns.joined(separator: "\n\n"))
}

func chatCompletionJSON(model: String, content: String) -> Data {
    let payload: [String: Any] = [
        "id": "chatcmpl-l7foundation-\(UUID().uuidString.prefix(12))",
        "object": "chat.completion",
        "created": Int(Date().timeIntervalSince1970),
        "model": model,
        "choices": [[
            "index": 0,
            "message": ["role": "assistant", "content": content],
            "finish_reason": "stop"
        ]],
        "usage": ["prompt_tokens": 0, "completion_tokens": 0, "total_tokens": 0]
    ]
    return (try? JSONSerialization.data(withJSONObject: payload)) ?? Data()
}

func modelsListJSON() -> Data {
    let payload: [String: Any] = [
        "object": "list",
        "data": [[
            "id": "apple-foundation-on-device",
            "object": "model",
            "owned_by": "apple-foundation-models"
        ]]
    ]
    return (try? JSONSerialization.data(withJSONObject: payload)) ?? Data()
}

func httpResponse(status: String, body: Data, contentType: String = "application/json") -> Data {
    var head = "HTTP/1.1 \(status)\r\n"
    head += "Content-Type: \(contentType)\r\n"
    head += "Content-Length: \(body.count)\r\n"
    head += "Connection: close\r\n\r\n"
    var data = head.data(using: .utf8)!
    data.append(body)
    return data
}

func parseHTTPRequest(_ raw: Data) -> (method: String, path: String, body: Data)? {
    guard let headerEnd = raw.range(of: Data("\r\n\r\n".utf8)) else { return nil }
    let headerData = raw.subdata(in: raw.startIndex..<headerEnd.lowerBound)
    let body = raw.subdata(in: headerEnd.upperBound..<raw.endIndex)
    guard let headerStr = String(data: headerData, encoding: .utf8) else { return nil }
    let lines = headerStr.components(separatedBy: "\r\n")
    guard let requestLine = lines.first else { return nil }
    let parts = requestLine.components(separatedBy: " ")
    guard parts.count >= 2 else { return nil }
    return (method: parts[0], path: parts[1], body: body)
}

func handleConnection(_ connection: NWConnection) {
    connection.start(queue: .main)
    var buffer = Data()

    func receiveMore() {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 1 << 20) { data, _, isComplete, error in
            if let data = data, !data.isEmpty {
                buffer.append(data)
            }
            if let error = error {
                _ = error
                connection.cancel()
                return
            }
            // Try to parse; if we have full headers, check Content-Length for body completeness.
            if let parsed = parseHTTPRequest(buffer) {
                let headerStr = String(data: buffer, encoding: .utf8) ?? ""
                var expectedLen = 0
                for line in headerStr.components(separatedBy: "\r\n") {
                    if line.lowercased().hasPrefix("content-length:") {
                        let val = line.split(separator: ":", maxSplits: 1)[1].trimmingCharacters(in: .whitespaces)
                        expectedLen = Int(val) ?? 0
                    }
                }
                if parsed.body.count >= expectedLen {
                    dispatch(parsed, on: connection)
                    return
                }
            }
            if isComplete {
                connection.cancel()
                return
            }
            receiveMore()
        }
    }
    receiveMore()
}

func dispatch(_ req: (method: String, path: String, body: Data), on connection: NWConnection) {
    let path = req.path.split(separator: "?").first.map(String.init) ?? req.path

    if req.method == "GET" && path == "/v1/models" {
        let resp = httpResponse(status: "200 OK", body: modelsListJSON())
        connection.send(content: resp, completion: .contentProcessed { _ in connection.cancel() })
        return
    }

    if req.method == "POST" && path == "/v1/chat/completions" {
        guard let chatReq = try? JSONDecoder().decode(ChatRequest.self, from: req.body) else {
            let err = "{\"error\":\"invalid request body\"}".data(using: .utf8)!
            let resp = httpResponse(status: "400 Bad Request", body: err)
            connection.send(content: resp, completion: .contentProcessed { _ in connection.cancel() })
            return
        }
        let (system, prompt) = buildPrompt(from: chatReq.messages)
        Task {
            do {
                let content = try await respondOnDevice(prompt: prompt, system: system)
                let body = chatCompletionJSON(model: chatReq.model ?? "apple-foundation-on-device", content: content)
                let resp = httpResponse(status: "200 OK", body: body)
                connection.send(content: resp, completion: .contentProcessed { _ in connection.cancel() })
            } catch {
                let err = "{\"error\":\"\(error)\"}".data(using: .utf8)!
                let resp = httpResponse(status: "500 Internal Server Error", body: err)
                connection.send(content: resp, completion: .contentProcessed { _ in connection.cancel() })
            }
        }
        return
    }

    let notFound = "{\"error\":\"not found\"}".data(using: .utf8)!
    let resp = httpResponse(status: "404 Not Found", body: notFound)
    connection.send(content: resp, completion: .contentProcessed { _ in connection.cancel() })
}

func runServeMode(args: [String]) {
    var port: UInt16 = 8991
    if let idx = args.firstIndex(of: "--port"), idx + 1 < args.count, let p = UInt16(args[idx + 1]) {
        port = p
    }
    guard let nwPort = NWEndpoint.Port(rawValue: port) else {
        FileHandle.standardError.write("invalid port\n".data(using: .utf8)!)
        exit(1)
    }
    let params = NWParameters.tcp
    guard let listener = try? NWListener(using: params, on: nwPort) else {
        FileHandle.standardError.write("failed to bind port \(port)\n".data(using: .utf8)!)
        exit(1)
    }
    listener.newConnectionHandler = { connection in
        handleConnection(connection)
    }
    listener.stateUpdateHandler = { state in
        switch state {
        case .ready:
            print("l7-foundation serving on http://localhost:\(port)/v1  (offline, on-device)")
        case .failed(let error):
            FileHandle.standardError.write("listener failed: \(error)\n".data(using: .utf8)!)
            exit(1)
        default:
            break
        }
    }
    listener.start(queue: .main)
    RunLoop.main.run()
}

// ─────────────────────────────────────────
// MARK: - Mode: app (native windowed chat)
// ─────────────────────────────────────────

final class ChatWindowController: NSObject, NSTextFieldDelegate {
    let window: NSWindow
    let scrollView: NSScrollView
    let textView: NSTextView
    let inputField: NSTextField

    override init() {
        let contentRect = NSRect(x: 0, y: 0, width: 560, height: 640)
        window = NSWindow(contentRect: contentRect,
                           styleMask: [.titled, .closable, .miniaturizable, .resizable],
                           backing: .buffered, defer: false)
        window.title = "L7 Foundation — On-Device"
        window.center()

        textView = NSTextView(frame: NSRect(x: 0, y: 0, width: 560, height: 580))
        textView.isEditable = false
        textView.font = NSFont.systemFont(ofSize: 13)
        textView.textContainerInset = NSSize(width: 8, height: 8)

        scrollView = NSScrollView(frame: NSRect(x: 0, y: 60, width: 560, height: 580))
        scrollView.documentView = textView
        scrollView.hasVerticalScroller = true
        scrollView.autoresizingMask = [.width, .height]

        inputField = NSTextField(frame: NSRect(x: 8, y: 12, width: 544, height: 36))
        inputField.placeholderString = "Ask the on-device model, then press Return…"
        inputField.autoresizingMask = [.width]

        super.init()

        inputField.delegate = self
        window.contentView?.addSubview(scrollView)
        window.contentView?.addSubview(inputField)
        window.makeKeyAndOrderFront(nil)
        window.makeFirstResponder(inputField)
    }

    func append(_ text: String) {
        textView.textStorage?.append(NSAttributedString(string: text + "\n\n"))
        textView.scrollToEndOfDocument(nil)
    }

    func controlTextDidEndEditing(_ obj: Notification) {
        guard let field = obj.object as? NSTextField,
              let event = NSApp.currentEvent,
              event.type == .keyDown, event.keyCode == 36 // Return
        else { return }
        let prompt = field.stringValue
        guard !prompt.isEmpty else { return }
        field.stringValue = ""
        append("You: \(prompt)")
        Task {
            do {
                let reply = try await respondOnDevice(prompt: prompt)
                await MainActor.run { self.append("L7 Foundation: \(reply)") }
            } catch {
                await MainActor.run { self.append("Error: \(error)") }
            }
        }
    }
}

final class FoundationAppDelegate: NSObject, NSApplicationDelegate {
    var controller: ChatWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        controller = ChatWindowController()
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

func runAppMode() {
    let app = NSApplication.shared
    let delegate = FoundationAppDelegate()
    app.delegate = delegate
    app.run()
}

// ─────────────────────────────────────────
// MARK: - Entry point
// ─────────────────────────────────────────

let argv = Array(CommandLine.arguments.dropFirst())
let mode = argv.first ?? "app"

switch mode {
case "chat":
    let rest = Array(argv.dropFirst())
    let sema = DispatchSemaphore(value: 0)
    Task {
        await runChatMode(args: rest)
        sema.signal()
    }
    sema.wait()
case "code":
    let rest = Array(argv.dropFirst())
    let sema = DispatchSemaphore(value: 0)
    Task {
        await runCodeMode(args: rest)
        sema.signal()
    }
    sema.wait()
case "serve":
    runServeMode(args: Array(argv.dropFirst()))
case "app":
    runAppMode()
default:
    // Unknown first arg: treat the whole argv as a chat prompt for convenience.
    let sema = DispatchSemaphore(value: 0)
    Task {
        await runChatMode(args: argv)
        sema.signal()
    }
    sema.wait()
}
