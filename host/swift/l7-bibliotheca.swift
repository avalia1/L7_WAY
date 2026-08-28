// ══════════════════════════════════════════════════════════════
// L7 BIBLIOTHECA ARCANA — The Library of Alexandria Reborn
// Native macOS reader for magical and esoteric literature.
// Biometric gate for Left Hand (R) texts. No network required.
//
// The Three Paths (Law LX):
//   ☀ W (White/Right Hand) — Open. Spiritual, philosophical.
//   ☽ G (Grey/Middle)      — Controlled. Hermetic, astrological.
//   🜂 R (Red/Left Hand)    — SEALED. Philosopher fingerprint ONLY.
//
// Law LXIII — All Left Hand texts bound to Philosopher's eyes.
// Law XXX  — Biometrics only. No passwords.
//
// Creator: Alberto Valido Delgado (Constantine)
// Publisher: Avli Cloud
// License: Proprietary — Law XVI + 12% unauthorized use penalty
// ══════════════════════════════════════════════════════════════

import Foundation
import LocalAuthentication

// ─── Configuration ───
let L7_DIR = ProcessInfo.processInfo.environment["L7_DIR"]
    ?? NSHomeDirectory() + "/.l7"
let LIBRARY_DIR = L7_DIR + "/library"
let TEXTS_DIR = LIBRARY_DIR + "/texts"
let SEALED_DIR = LIBRARY_DIR + "/sealed"
let INDEX_PATH = LIBRARY_DIR + "/INDEX.json"
let OUTPUT_DIR = L7_DIR + "/bibliotheca"
let OUTPUT_HTML = OUTPUT_DIR + "/bibliotheca.html"
let AUDIT_LOG = OUTPUT_DIR + "/audit.log"
let VERSION = "1.0.0"

// ─── Security: Anti-Debug ───
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

// ─── Security: Audit Log ───
func auditLog(_ entry: String) {
    let line = "[\(ISO8601DateFormatter().string(from: Date()))] \(entry)\n"
    if let handle = FileHandle(forWritingAtPath: AUDIT_LOG) {
        handle.seekToEndOfFile()
        handle.write(line.data(using: .utf8)!)
        handle.closeFile()
    } else {
        FileManager.default.createFile(atPath: AUDIT_LOG, contents: line.data(using: .utf8))
        chmod(AUDIT_LOG, 0o600)
    }
}

// ─── Biometric Gate (Law XXX — no password fallback) ───
func authenticate(reason: String) -> Bool {
    let context = LAContext()
    context.localizedFallbackTitle = ""
    var error: NSError?

    guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
        fputs("  Biometric authentication unavailable: \(error?.localizedDescription ?? "unknown")\n", stderr)
        fputs("  Law XXX: No passwords. Biometrics ONLY.\n", stderr)
        auditLog("AUTH_FAIL: Biometrics unavailable")
        return false
    }

    let sem = DispatchSemaphore(value: 0)
    var authenticated = false
    context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                           localizedReason: reason) { success, _ in
        authenticated = success
        sem.signal()
    }
    sem.wait()

    auditLog(authenticated ? "AUTH_OK: \(reason)" : "AUTH_FAIL: \(reason)")
    return authenticated
}

// ─── Data Structures ───

struct LibraryText: Codable {
    let title: String
    let author: String?
    let year: String?
    let tradition: String?
    let source_url: String?
    let path_classification: String?
    let classification_reason: String?
    let date_ingested: String?
    let file_path: String?
    let file_size: Int?
    let binding: String?

    var pathClass: String { path_classification ?? "W" }
    var isBound: Bool { pathClass == "R" }
    var pathSymbol: String {
        switch pathClass {
        case "W": return "☀"
        case "G": return "☽"
        case "R": return "🜂"
        default:  return "?"
        }
    }
    var pathColor: String {
        switch pathClass {
        case "W": return "#f0e68c"
        case "G": return "#c0c0c0"
        case "R": return "#dc2626"
        default:  return "#888888"
        }
    }
    var pathName: String {
        switch pathClass {
        case "W": return "White (Right Hand)"
        case "G": return "Grey (Middle)"
        case "R": return "Red (Left Hand) — SEALED"
        default:  return "Unclassified"
        }
    }
}

// ─── Library Scanner ───

func loadIndex() -> [String: LibraryText] {
    guard let data = FileManager.default.contents(atPath: INDEX_PATH),
          let arr = try? JSONDecoder().decode([String: LibraryText].self, from: data) else {
        return [:]
    }
    return arr
}

func loadMetaFiles() -> [String: LibraryText] {
    var texts: [String: LibraryText] = [:]
    let fm = FileManager.default
    guard let items = try? fm.contentsOfDirectory(atPath: TEXTS_DIR) else { return texts }

    for item in items where item.hasSuffix(".meta.json") {
        let stem = String(item.dropLast(".meta.json".count))
        let path = (TEXTS_DIR as NSString).appendingPathComponent(item)
        guard let data = fm.contents(atPath: path),
              let meta = try? JSONDecoder().decode(LibraryText.self, from: data) else { continue }
        texts[stem] = meta
    }
    return texts
}

func textContent(_ stem: String) -> String? {
    let txtPath = (TEXTS_DIR as NSString).appendingPathComponent("\(stem).txt")
    if FileManager.default.fileExists(atPath: txtPath) {
        return try? String(contentsOfFile: txtPath, encoding: .utf8)
    }
    return nil
}

func formatSize(_ bytes: Int) -> String {
    if bytes > 1_000_000 { return String(format: "%.1f MB", Double(bytes) / 1_000_000) }
    if bytes > 1_000 { return String(format: "%.0f KB", Double(bytes) / 1_000) }
    return "\(bytes) B"
}

// ─── HTML Generator ───

func generateHTML(texts: [String: LibraryText], authenticated: Bool) -> String {
    // Group by classification
    let white = texts.filter { $0.value.pathClass == "W" }.sorted { $0.value.title < $1.value.title }
    let grey = texts.filter { $0.value.pathClass == "G" }.sorted { $0.value.title < $1.value.title }
    let red = texts.filter { $0.value.pathClass == "R" }.sorted { $0.value.title < $1.value.title }

    var textCards = ""

    func card(_ stem: String, _ t: LibraryText) -> String {
        let hasContent = textContent(stem) != nil
        let sizeStr = t.file_size.map { formatSize($0) } ?? ""
        let authorStr = t.author ?? "Unknown"
        let yearStr = t.year ?? ""
        let traditionStr = t.tradition ?? ""
        let reasonStr = t.classification_reason ?? ""

        let locked = t.isBound && !authenticated
        let readAction = locked
            ? "onclick=\"alert('🜂 SEALED — Law LXIII\\nPhilosopher fingerprint required.\\nUse: l7 bibliotheca read \(stem)');\""
            : hasContent
                ? "onclick=\"showText('\(stem.replacingOccurrences(of: "'", with: "\\'"))')\""
                : "onclick=\"alert('Text not yet ingested.\\nUse: ingest script to acquire.')\""

        return """
        <div class="card path-\(t.pathClass.lowercased()) \(locked ? "locked" : "")" \(readAction)>
            <div class="card-path" style="color:\(t.pathColor)">\(t.pathSymbol) \(t.pathName)</div>
            <div class="card-title">\(t.title)</div>
            <div class="card-meta">\(authorStr)\(yearStr.isEmpty ? "" : " (\(yearStr))")</div>
            <div class="card-tradition">\(traditionStr)</div>
            <div class="card-reason">\(reasonStr)</div>
            <div class="card-size">\(sizeStr)\(locked ? " 🔒" : hasContent ? " 📖" : " ⊘")</div>
        </div>
        """
    }

    // White section
    textCards += "<h2 class=\"section-header white\">☀ WHITE PATH — Right Hand (Open)</h2>\n<div class=\"cards\">\n"
    for (stem, t) in white { textCards += card(stem, t) }
    textCards += "</div>\n"

    // Grey section
    textCards += "<h2 class=\"section-header grey\">☽ GREY PATH — Middle (Controlled)</h2>\n<div class=\"cards\">\n"
    for (stem, t) in grey { textCards += card(stem, t) }
    textCards += "</div>\n"

    // Red section
    textCards += "<h2 class=\"section-header red\">🜂 RED PATH — Left Hand (Sealed)</h2>\n<div class=\"cards\">\n"
    for (stem, t) in red { textCards += card(stem, t) }
    textCards += "</div>\n"

    let textDataEntries = texts.compactMap { (stem, t) -> String? in
        guard let content = textContent(stem) else { return nil }
        if t.isBound && !authenticated { return nil }
        let escaped = content
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "`", with: "\\`")
            .replacingOccurrences(of: "$", with: "\\$")
            .prefix(200_000)
        return "'\(stem.replacingOccurrences(of: "'", with: "\\'"))': `\(escaped)`"
    }
    let textDataJS = "const TEXTS = {\n\(textDataEntries.joined(separator: ",\n"))\n};"

    return """
    <!DOCTYPE html>
    <html lang="en">
    <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Bibliotheca Arcana — The Library of Alexandria Reborn</title>
    <style>
    :root {
        --bg: #0a0a0f;
        --surface: #12121a;
        --border: #1f1f2e;
        --text: #d8d4c8;
        --text-dim: #6b6860;
        --gold: #d4af37;
        --white-path: #f0e68c;
        --grey-path: #c0c0c0;
        --red-path: #dc2626;
        --reader-bg: #0e0e14;
    }

    * { margin: 0; padding: 0; box-sizing: border-box; }

    body {
        background: var(--bg);
        color: var(--text);
        font-family: 'Palatino', 'Georgia', 'Times New Roman', serif;
        min-height: 100vh;
    }

    /* ─── Header ─── */
    header {
        text-align: center;
        padding: 30px 20px 20px;
        border-bottom: 1px solid rgba(212, 175, 55, 0.2);
    }

    header h1 {
        font-size: 28px;
        letter-spacing: 6px;
        color: var(--gold);
        font-weight: 400;
        text-transform: uppercase;
    }

    header .subtitle {
        font-size: 12px;
        color: var(--text-dim);
        letter-spacing: 3px;
        margin-top: 6px;
    }

    header .stats {
        font-size: 11px;
        color: var(--text-dim);
        margin-top: 10px;
        letter-spacing: 1px;
    }

    /* ─── Search ─── */
    .search-bar {
        max-width: 600px;
        margin: 20px auto;
        padding: 0 20px;
    }

    .search-bar input {
        width: 100%;
        padding: 12px 18px;
        background: var(--surface);
        border: 1px solid var(--border);
        border-radius: 8px;
        color: var(--text);
        font-family: inherit;
        font-size: 14px;
        outline: none;
        transition: border-color 0.3s;
    }

    .search-bar input:focus {
        border-color: var(--gold);
    }

    .search-bar input::placeholder { color: var(--text-dim); }

    /* ─── Section Headers ─── */
    .section-header {
        padding: 15px 30px;
        font-size: 16px;
        letter-spacing: 3px;
        font-weight: 400;
        border-bottom: 1px solid var(--border);
        margin-top: 10px;
    }

    .section-header.white { color: var(--white-path); }
    .section-header.grey { color: var(--grey-path); }
    .section-header.red { color: var(--red-path); }

    /* ─── Cards ─── */
    .cards {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
        gap: 16px;
        padding: 20px 30px;
    }

    .card {
        background: var(--surface);
        border: 1px solid var(--border);
        border-radius: 10px;
        padding: 18px;
        cursor: pointer;
        transition: all 0.3s;
        position: relative;
        overflow: hidden;
    }

    .card:hover {
        border-color: var(--gold);
        transform: translateY(-2px);
        box-shadow: 0 4px 20px rgba(212, 175, 55, 0.1);
    }

    .card.locked {
        opacity: 0.7;
    }

    .card.locked::after {
        content: '🔒 SEALED';
        position: absolute;
        top: 10px;
        right: 10px;
        font-size: 10px;
        color: var(--red-path);
        letter-spacing: 2px;
    }

    .card.path-w { border-left: 3px solid var(--white-path); }
    .card.path-g { border-left: 3px solid var(--grey-path); }
    .card.path-r { border-left: 3px solid var(--red-path); }

    .card-path {
        font-size: 10px;
        letter-spacing: 2px;
        text-transform: uppercase;
        margin-bottom: 8px;
    }

    .card-title {
        font-size: 16px;
        color: var(--gold);
        margin-bottom: 6px;
        line-height: 1.3;
    }

    .card-meta {
        font-size: 12px;
        color: var(--text-dim);
    }

    .card-tradition {
        font-size: 11px;
        color: var(--text-dim);
        font-style: italic;
        margin-top: 4px;
    }

    .card-reason {
        font-size: 10px;
        color: var(--text-dim);
        margin-top: 4px;
        opacity: 0.7;
    }

    .card-size {
        font-size: 10px;
        color: var(--text-dim);
        margin-top: 8px;
        text-align: right;
    }

    /* ─── Reader View ─── */
    #reader {
        display: none;
        position: fixed;
        top: 0; left: 0;
        width: 100%; height: 100%;
        background: var(--reader-bg);
        z-index: 100;
        overflow-y: auto;
    }

    #reader .reader-header {
        position: sticky;
        top: 0;
        background: var(--bg);
        padding: 15px 30px;
        border-bottom: 1px solid var(--border);
        display: flex;
        justify-content: space-between;
        align-items: center;
        z-index: 101;
    }

    #reader .reader-title {
        color: var(--gold);
        font-size: 16px;
        letter-spacing: 2px;
    }

    #reader .reader-close {
        background: none;
        border: 1px solid var(--border);
        color: var(--text);
        padding: 8px 16px;
        border-radius: 6px;
        cursor: pointer;
        font-family: inherit;
        font-size: 12px;
        letter-spacing: 2px;
    }

    #reader .reader-close:hover {
        border-color: var(--gold);
        color: var(--gold);
    }

    #reader .reader-content {
        max-width: 800px;
        margin: 30px auto;
        padding: 0 30px 60px;
        font-size: 15px;
        line-height: 1.8;
        white-space: pre-wrap;
        word-wrap: break-word;
        color: var(--text);
    }

    /* ─── Footer ─── */
    footer {
        text-align: center;
        padding: 30px;
        color: var(--text-dim);
        font-size: 11px;
        letter-spacing: 2px;
        border-top: 1px solid var(--border);
        margin-top: 30px;
    }

    /* ─── Scrollbar ─── */
    ::-webkit-scrollbar { width: 8px; }
    ::-webkit-scrollbar-track { background: var(--bg); }
    ::-webkit-scrollbar-thumb { background: var(--border); border-radius: 4px; }
    ::-webkit-scrollbar-thumb:hover { background: var(--gold); }
    </style>
    </head>
    <body>

    <header>
        <h1>Bibliotheca Arcana</h1>
        <div class="subtitle">The Library of Alexandria — Reborn</div>
        <div class="stats">
            \(texts.count) texts · \(white.count) White · \(grey.count) Grey · \(red.count) Red\(authenticated ? " · 🔓 Philosopher Authenticated" : " · 🔒 Left Hand Sealed")
        </div>
    </header>

    <div class="search-bar">
        <input type="text" id="search" placeholder="Search the Bibliotheca... (title, author, tradition)" oninput="filterCards(this.value)">
    </div>

    <main id="library">
    \(textCards)
    </main>

    <div id="reader">
        <div class="reader-header">
            <span class="reader-title" id="reader-title"></span>
            <button class="reader-close" onclick="closeReader()">✕ CLOSE</button>
        </div>
        <div class="reader-content" id="reader-content"></div>
    </div>

    <footer>
        Through the will of Sofia · So mote it be · v\(VERSION)
    </footer>

    <script>
    \(textDataJS)

    function showText(stem) {
        if (!TEXTS[stem]) {
            alert('Text not loaded. Use CLI: l7 bibliotheca read ' + stem);
            return;
        }
        document.getElementById('reader-title').textContent = stem.replace(/_/g, ' ').toUpperCase();
        document.getElementById('reader-content').textContent = TEXTS[stem];
        document.getElementById('reader').style.display = 'block';
        document.getElementById('reader').scrollTop = 0;
    }

    function closeReader() {
        document.getElementById('reader').style.display = 'none';
    }

    function filterCards(query) {
        const q = query.toLowerCase();
        document.querySelectorAll('.card').forEach(card => {
            const text = card.textContent.toLowerCase();
            card.style.display = text.includes(q) ? '' : 'none';
        });
    }

    document.addEventListener('keydown', e => {
        if (e.key === 'Escape') closeReader();
        if (e.key === '/' && document.activeElement.tagName !== 'INPUT') {
            e.preventDefault();
            document.getElementById('search').focus();
        }
    });
    </script>
    </body>
    </html>
    """
}

// ─── CLI Interface ───

func printBanner() {
    print("""

      ╔══════════════════════════════════════════════════╗
      ║                                                  ║
      ║       BIBLIOTHECA ARCANA v\(VERSION)               ║
      ║       The Library of Alexandria — Reborn         ║
      ║                                                  ║
      ║       ☀ White  ☽ Grey  🜂 Red                     ║
      ║       Law LX · Law LXIII · Law XXX              ║
      ║                                                  ║
      ╚══════════════════════════════════════════════════╝
    """)
}

func main() {
    let args = CommandLine.arguments

    // Anti-debug
    guard verifyNotTraced() else {
        fputs("SECURITY VIOLATION: Debugger detected. Abort.\n", stderr)
        exit(1)
    }

    // Ensure output directory
    try? FileManager.default.createDirectory(atPath: OUTPUT_DIR, withIntermediateDirectories: true)

    let command = args.count > 1 ? args[1] : "open"

    switch command {
    case "open", "browse":
        printBanner()
        let texts = loadMetaFiles()
        print("  Loaded \(texts.count) texts from \(TEXTS_DIR)")

        // Authenticate for Left Hand access
        let hasRed = texts.values.contains { $0.pathClass == "R" }
        var authed = false
        if hasRed {
            print("  🜂 Left Hand texts detected — requesting biometric seal...")
            authed = authenticate(reason: "Bibliotheca Arcana — Left Hand Path access (Law LXIII)")
            if authed {
                print("  🔓 Philosopher authenticated. All paths open.")
            } else {
                print("  🔒 Left Hand texts remain sealed.")
            }
        }

        let html = generateHTML(texts: texts, authenticated: authed)
        try! html.write(toFile: OUTPUT_HTML, atomically: true, encoding: .utf8)
        chmod(OUTPUT_HTML, authed ? 0o600 : 0o644)

        print("  Generated: \(OUTPUT_HTML)")
        auditLog("OPEN: \(texts.count) texts, auth=\(authed)")

        // Open in browser
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        task.arguments = [OUTPUT_HTML]
        try? task.run()
        print("  Bibliotheca opened in browser.")

    case "list":
        let texts = loadMetaFiles()
        let sorted = texts.sorted { $0.value.title < $1.value.title }
        for (stem, t) in sorted {
            let size = t.file_size.map { formatSize($0) } ?? "?"
            print("  \(t.pathSymbol) [\(t.pathClass)] \(t.title) (\(t.author ?? "?"), \(t.year ?? "?")) — \(size)")
        }
        print("\n  Total: \(texts.count) texts")

    case "read":
        guard args.count > 2 else {
            fputs("  Usage: l7 bibliotheca read <stem>\n", stderr)
            exit(1)
        }
        let stem = args[2]
        let texts = loadMetaFiles()
        guard let meta = texts[stem] else {
            fputs("  Text not found: \(stem)\n", stderr)
            exit(1)
        }

        // Left Hand requires authentication
        if meta.isBound {
            print("  🜂 Left Hand text — requesting biometric seal (Law LXIII)...")
            guard authenticate(reason: "Read Left Hand text: \(meta.title)") else {
                fputs("  ❌ Authentication failed. Text remains sealed.\n", stderr)
                auditLog("READ_DENIED: \(stem)")
                exit(1)
            }
            auditLog("READ_GRANTED: \(stem)")
        }

        if let content = textContent(stem) {
            print(content)
        } else {
            fputs("  Text file not found. May be sealed. Check \(SEALED_DIR)/\(stem).sealed.json\n", stderr)
        }

    case "search":
        guard args.count > 2 else {
            fputs("  Usage: l7 bibliotheca search <query>\n", stderr)
            exit(1)
        }
        let query = args[2...].joined(separator: " ").lowercased()
        let texts = loadMetaFiles()

        print("  Searching for: \"\(query)\"")
        print()

        var found = 0
        for (stem, meta) in texts.sorted(by: { $0.value.title < $1.value.title }) {
            // Skip bound texts in search results (show title only)
            if meta.isBound {
                if meta.title.lowercased().contains(query) {
                    print("  🜂 \(meta.title) [SEALED — authenticate to search content]")
                    found += 1
                }
                continue
            }

            if meta.title.lowercased().contains(query) ||
               (meta.author ?? "").lowercased().contains(query) ||
               (meta.tradition ?? "").lowercased().contains(query) {
                print("  \(meta.pathSymbol) \(meta.title) — \(meta.author ?? "?")")
                found += 1
            }
        }
        print("\n  Found: \(found) matches")

    case "status":
        let texts = loadMetaFiles()
        let w = texts.values.filter { $0.pathClass == "W" }.count
        let g = texts.values.filter { $0.pathClass == "G" }.count
        let r = texts.values.filter { $0.pathClass == "R" }.count
        let totalSize = texts.values.compactMap { $0.file_size }.reduce(0, +)

        printBanner()
        print("  ☀ White (Right Hand):  \(w) texts")
        print("  ☽ Grey (Middle):       \(g) texts")
        print("  🜂 Red (Left Hand):     \(r) texts (SEALED)")
        print("  ─────────────────────────────")
        print("  Total:                 \(texts.count) texts")
        print("  Size:                  \(formatSize(totalSize))")
        print("  Index:                 \(INDEX_PATH)")
        print("  Sealed:                \(SEALED_DIR)")
        print()

    case "help", "--help", "-h":
        printBanner()
        print("""
          Commands:
            open     — Generate and open the library browser (default)
            list     — List all texts with classifications
            read     — Read a specific text (biometric gate for R)
            search   — Search across titles and metadata
            status   — Show library statistics
            help     — This message

          Examples:
            l7 bibliotheca               # Open browser
            l7 bibliotheca list          # List all texts
            l7 bibliotheca read kybalion # Read the Kybalion
            l7 bibliotheca search alchemy
        """)

    default:
        fputs("  Unknown command: \(command). Use 'help' for usage.\n", stderr)
        exit(1)
    }
}

main()
