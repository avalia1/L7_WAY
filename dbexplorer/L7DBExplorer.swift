// ============================================================
// L7 Database Explorer — Native macOS SQLite Browser
// Morph Technology: transmute filesystem databases into vision
//
// "Each graph contains the previous ones."
// Built on the same forge as the Living Rose.
// ============================================================

import Cocoa
import WebKit
import SQLite3

// ============================================================
// SQLite Bridge — native C API, no dependencies
// ============================================================

class SQLiteBridge {
    private var db: OpaquePointer?
    private(set) var path: String = ""

    func open(_ filePath: String) -> Bool {
        close()
        let flags = SQLITE_OPEN_READONLY | SQLITE_OPEN_NOMUTEX
        if sqlite3_open_v2(filePath, &db, flags, nil) == SQLITE_OK {
            path = filePath
            return true
        }
        return false
    }

    func close() {
        if let db = db { sqlite3_close(db) }
        db = nil
        path = ""
    }

    func tables() -> [(name: String, type: String, count: Int)] {
        guard db != nil else { return [] }
        var result: [(String, String, Int)] = []
        let rows = query("SELECT name, type FROM sqlite_master WHERE type IN ('table','view') ORDER BY type, name")
        for row in rows.values {
            let name = row[0] as? String ?? ""
            let type = row[1] as? String ?? ""
            var count = 0
            let cr = query("SELECT COUNT(*) FROM \"\(name.replacingOccurrences(of: "\"", with: "\"\""))\"")
            if let first = cr.values.first, let c = first[0] as? Int { count = c }
            result.append((name, type, count))
        }
        return result
    }

    func schema() -> String {
        guard db != nil else { return "" }
        let rows = query("SELECT sql FROM sqlite_master WHERE sql IS NOT NULL ORDER BY type, name")
        return rows.values.compactMap { ($0[0] as? String).map { $0 + ";" } }.joined(separator: "\n\n")
    }

    struct QueryResult {
        var columns: [String] = []
        var values: [[Any?]] = []
        var error: String?
        var elapsed: Double = 0
    }

    func query(_ sql: String) -> QueryResult {
        var result = QueryResult()
        guard let db = db else { result.error = "No database open"; return result }

        let start = CFAbsoluteTimeGetCurrent()
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) != SQLITE_OK {
            result.error = String(cString: sqlite3_errmsg(db))
            return result
        }
        defer { sqlite3_finalize(stmt) }

        let colCount = sqlite3_column_count(stmt)
        for i in 0..<colCount {
            let name = sqlite3_column_name(stmt, i).map { String(cString: $0) } ?? "col\(i)"
            result.columns.append(name)
        }

        while sqlite3_step(stmt) == SQLITE_ROW {
            var row: [Any?] = []
            for i in 0..<colCount {
                switch sqlite3_column_type(stmt, i) {
                case SQLITE_NULL:
                    row.append(nil)
                case SQLITE_INTEGER:
                    row.append(Int(sqlite3_column_int64(stmt, i)))
                case SQLITE_FLOAT:
                    row.append(sqlite3_column_double(stmt, i))
                case SQLITE_TEXT:
                    let text = String(cString: sqlite3_column_text(stmt, i))
                    row.append(text)
                case SQLITE_BLOB:
                    let bytes = sqlite3_column_bytes(stmt, i)
                    row.append("[BLOB \(bytes)B]")
                default:
                    row.append(nil)
                }
            }
            result.values.append(row)
        }

        result.elapsed = (CFAbsoluteTimeGetCurrent() - start) * 1000
        return result
    }

    deinit { close() }
}

// ============================================================
// Message Handler — bridge between WebView JS and native Swift
// ============================================================

class NativeBridge: NSObject, WKScriptMessageHandler {
    let bridge = SQLiteBridge()
    weak var webView: WKWebView?
    var catalogPath: String

    init(catalogPath: String) {
        self.catalogPath = catalogPath
    }

    func userContentController(_ controller: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let body = message.body as? [String: Any],
              let action = body["action"] as? String else { return }

        switch action {
        case "loadCatalog":
            loadCatalog()
        case "openDatabase":
            if let path = body["path"] as? String {
                openDatabase(path)
            }
        case "runQuery":
            if let sql = body["sql"] as? String {
                runQuery(sql)
            }
        case "getSchema":
            getSchema()
        case "exportCSV":
            if let table = body["table"] as? String {
                exportCSV(table)
            }
        case "reveal":
            if let path = body["path"] as? String {
                NSWorkspace.shared.selectFile(path, inFileViewerRootedAtPath: "")
            }
        default:
            break
        }
    }

    private func loadCatalog() {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: catalogPath))
            let json = String(data: data, encoding: .utf8) ?? "[]"
            callback("onCatalogLoaded", json)
        } catch {
            callback("onCatalogLoaded", "[]")
        }
    }

    private func openDatabase(_ path: String) {
        if bridge.open(path) {
            let tables = bridge.tables()
            var arr: [[String: Any]] = []
            for t in tables {
                arr.append(["name": t.name, "type": t.type, "count": t.count])
            }
            let json = toJSON(arr)
            callback("onDatabaseOpened", "{\"path\":\(toJSON(path)),\"tables\":\(json)}")
        } else {
            callback("onDatabaseError", toJSON("Cannot open: \(path)"))
        }
    }

    private func runQuery(_ sql: String) {
        let result = bridge.query(sql)
        if let err = result.error {
            callback("onQueryError", toJSON(err))
            return
        }
        let rows: [[Any?]] = result.values
        var jsonRows: [[String: Any?]] = []
        for row in rows {
            var obj: [String: Any?] = [:]
            for (i, col) in result.columns.enumerated() {
                obj[col] = row[i]
            }
            jsonRows.append(obj)
        }
        // Build result JSON manually for speed
        var json = "{\"columns\":\(toJSON(result.columns)),\"values\":["
        for (ri, row) in rows.enumerated() {
            if ri > 0 { json += "," }
            json += "["
            for (ci, val) in row.enumerated() {
                if ci > 0 { json += "," }
                if val == nil { json += "null" }
                else if let n = val as? Int { json += "\(n)" }
                else if let d = val as? Double { json += "\(d)" }
                else if let s = val as? String { json += toJSON(s) }
                else { json += toJSON(String(describing: val!)) }
            }
            json += "]"
        }
        json += "],\"elapsed\":\(result.elapsed),\"count\":\(rows.count)}"
        callback("onQueryResult", json)
    }

    private func getSchema() {
        let schema = bridge.schema()
        callback("onSchemaResult", toJSON(schema))
    }

    private func exportCSV(_ table: String) {
        let result = bridge.query("SELECT * FROM \"\(table.replacingOccurrences(of: "\"", with: "\"\""))\"")
        if result.error != nil { return }

        var csv = result.columns.map { "\"\($0)\"" }.joined(separator: ",") + "\n"
        for row in result.values {
            csv += row.map { val -> String in
                if val == nil { return "" }
                let s = String(describing: val!)
                return "\"\(s.replacingOccurrences(of: "\"", with: "\"\""))\""
            }.joined(separator: ",") + "\n"
        }

        let panel = NSSavePanel()
        panel.nameFieldStringValue = "\(table).csv"
        panel.allowedContentTypes = [.commaSeparatedText]
        if panel.runModal() == .OK, let url = panel.url {
            try? csv.write(to: url, atomically: true, encoding: .utf8)
        }
    }

    private func callback(_ fn: String, _ data: String) {
        DispatchQueue.main.async { [weak self] in
            self?.webView?.evaluateJavaScript("\(fn)(\(data))", completionHandler: nil)
        }
    }

    private func toJSON(_ value: Any) -> String {
        if let s = value as? String {
            let escaped = s
                .replacingOccurrences(of: "\\", with: "\\\\")
                .replacingOccurrences(of: "\"", with: "\\\"")
                .replacingOccurrences(of: "\n", with: "\\n")
                .replacingOccurrences(of: "\r", with: "\\r")
                .replacingOccurrences(of: "\t", with: "\\t")
            return "\"\(escaped)\""
        }
        if let arr = value as? [String] {
            return "[\(arr.map { toJSON($0) }.joined(separator: ","))]"
        }
        if let arr = value as? [[String: Any]] {
            let items = arr.map { dict -> String in
                let pairs = dict.map { "\(toJSON($0.key)):\(toJSON($0.value))" }
                return "{\(pairs.joined(separator: ","))}"
            }
            return "[\(items.joined(separator: ","))]"
        }
        if let n = value as? Int { return "\(n)" }
        if let d = value as? Double { return "\(d)" }
        return "null"
    }
}

// ============================================================
// Drag & Drop Support
// ============================================================

class DropWebView: WKWebView {
    var onFileDrop: ((String) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        registerForDraggedTypes([.fileURL])
    }

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .copy
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let urls = sender.draggingPasteboard.readObjects(forClasses: [NSURL.self]) as? [URL],
              let url = urls.first else { return false }
        onFileDrop?(url.path)
        return true
    }
}

// ============================================================
// App Delegate — windowed app with native SQLite bridge
// ============================================================

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var webView: WKWebView!
    var nativeBridge: NativeBridge!

    func applicationDidFinishLaunching(_ notification: Notification) {
        let screen = NSScreen.main ?? NSScreen.screens[0]
        let w: CGFloat = min(1400, screen.frame.width * 0.85)
        let h: CGFloat = min(900, screen.frame.height * 0.85)
        let x = (screen.frame.width - w) / 2
        let y = (screen.frame.height - h) / 2

        window = NSWindow(
            contentRect: NSRect(x: x, y: y, width: w, height: h),
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "L7 Database Explorer"
        window.titlebarAppearsTransparent = true
        window.backgroundColor = NSColor(red: 0.04, green: 0.04, blue: 0.06, alpha: 1.0)
        window.minSize = NSSize(width: 800, height: 500)
        window.isReleasedWhenClosed = false

        // Setup WebView with native bridge
        let catalogDir = NSString(string: "~/.l7/databases").expandingTildeInPath
        let catalogPath = (catalogDir as NSString).appendingPathComponent("catalog-unique.json")
        nativeBridge = NativeBridge(catalogPath: catalogPath)

        let config = WKWebViewConfiguration()
        config.preferences.setValue(true, forKey: "developerExtrasEnabled")
        config.userContentController.add(nativeBridge, name: "native")

        webView = WKWebView(frame: window.contentView!.bounds, configuration: config)
        webView.autoresizingMask = [.width, .height]
        webView.setValue(false, forKey: "drawsBackground")
        nativeBridge.webView = webView

        // Register for drag and drop
        webView.registerForDraggedTypes([.fileURL])

        window.contentView?.addSubview(webView)

        // Load the HTML interface
        let html = generateHTML()
        webView.loadHTMLString(html, baseURL: URL(fileURLWithPath: catalogDir))

        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        // Setup menu
        setupMenu()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func setupMenu() {
        let mainMenu = NSMenu()

        let appMenu = NSMenu()
        appMenu.addItem(withTitle: "About L7 Database Explorer", action: #selector(showAbout), keyEquivalent: "")
        appMenu.addItem(.separator())
        appMenu.addItem(withTitle: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        let appItem = NSMenuItem()
        appItem.submenu = appMenu
        mainMenu.addItem(appItem)

        let fileMenu = NSMenu(title: "File")
        fileMenu.addItem(withTitle: "Open Database...", action: #selector(openFile), keyEquivalent: "o")
        fileMenu.addItem(.separator())
        fileMenu.addItem(withTitle: "Close", action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w")
        let fileItem = NSMenuItem()
        fileItem.submenu = fileMenu
        mainMenu.addItem(fileItem)

        let editMenu = NSMenu(title: "Edit")
        editMenu.addItem(withTitle: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        editMenu.addItem(withTitle: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")
        let editItem = NSMenuItem()
        editItem.submenu = editMenu
        mainMenu.addItem(editItem)

        NSApp.mainMenu = mainMenu
    }

    @objc func openFile() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.database, .data]
        panel.allowsOtherFileTypes = true
        panel.message = "Select a SQLite database"
        if panel.runModal() == .OK, let url = panel.url {
            let path = url.path
            webView.evaluateJavaScript("openDatabaseNative('\(path.replacingOccurrences(of: "'", with: "\\'"))')", completionHandler: nil)
        }
    }

    @objc func showAbout() {
        let alert = NSAlert()
        alert.messageText = "L7 Database Explorer"
        alert.informativeText = "Morph Technology — Filesystem Archaeology\n\n511 databases cataloged across 127 domains.\nNative SQLite3 bridge, no dependencies.\n\n\"Each graph contains the previous ones.\""
        alert.alertStyle = .informational
        alert.runModal()
    }

    func generateHTML() -> String {
        return """
        <!DOCTYPE html>
        <html lang="en">
        <head>
        <meta charset="UTF-8">
        <style>
        :root{--bg:#0a0a0f;--bg2:#12121a;--bg3:#1a1a25;--gold:#c4a882;--gold-b:#d4a84b;--text:#a8a8b0;--dim:#666680;--red:#c44040;--green:#40c480;--blue:#4080c4;--purple:#8040c4;--cyan:#40a0c4;--orange:#c48040}
        *{margin:0;padding:0;box-sizing:border-box}
        body{background:var(--bg);color:var(--text);font-family:-apple-system,'SF Pro Text','Helvetica Neue',sans-serif;font-size:12px;height:100vh;overflow:hidden;display:flex;flex-direction:column;-webkit-user-select:none}
        .mono{font-family:'SF Mono','Menlo',monospace}
        header{padding:8px 16px;background:var(--bg2);border-bottom:1px solid #222235;display:flex;justify-content:space-between;align-items:center;-webkit-app-region:drag}
        header h1{font-family:'SF Pro Display',Georgia,serif;font-size:15px;color:var(--gold);font-weight:500;letter-spacing:1.5px}
        header .stats{color:var(--dim);font-size:11px;-webkit-app-region:no-drag}
        .main{flex:1;display:flex;overflow:hidden}
        .sidebar{width:300px;overflow-y:auto;border-right:1px solid #222235;display:flex;flex-direction:column;flex-shrink:0}
        .sidebar::-webkit-scrollbar{width:6px}
        .sidebar::-webkit-scrollbar-thumb{background:#333350;border-radius:3px}
        .sb-search{padding:8px;border-bottom:1px solid #222235}
        .sb-search input{width:100%;background:var(--bg3);border:1px solid #333350;color:var(--text);padding:6px 10px;border-radius:6px;font-family:inherit;font-size:12px;-webkit-user-select:text}
        .sb-search input:focus{border-color:var(--gold);outline:none}
        .sb-sort{padding:4px 8px;border-bottom:1px solid #222235;display:flex;gap:4px}
        .sb-sort button{background:var(--bg3);border:1px solid #333350;color:var(--dim);padding:2px 8px;border-radius:4px;cursor:pointer;font-size:10px}
        .sb-sort button:hover{color:var(--gold)}
        .sb-sort button.active{background:var(--gold);color:var(--bg);border-color:var(--gold)}
        .db-list{flex:1;overflow-y:auto;padding:2px 0}
        .db-list::-webkit-scrollbar{width:6px}
        .db-list::-webkit-scrollbar-thumb{background:#333350;border-radius:3px}
        .db-group{margin-bottom:1px}
        .db-gh{padding:5px 8px;color:var(--gold);font-size:10px;cursor:pointer;display:flex;justify-content:space-between;background:var(--bg2);border-radius:0}
        .db-gh:hover{background:var(--bg3)}
        .db-gh .cnt{color:var(--dim)}
        .db-gh .arr{color:var(--dim);width:12px;text-align:center;flex-shrink:0}
        .db-item{padding:5px 8px 5px 20px;cursor:pointer;display:flex;align-items:center;gap:6px;white-space:nowrap;border-radius:0}
        .db-item:hover{background:var(--bg3)}
        .db-item.active{background:#1a1a30;border-left:2px solid var(--gold);padding-left:18px}
        .db-item .ic{color:var(--blue);flex-shrink:0;font-size:13px}
        .db-item .nm{flex:1;overflow:hidden;text-overflow:ellipsis;font-size:11px}
        .db-item .sz{color:var(--dim);font-size:10px;flex-shrink:0}
        .content{flex:1;display:flex;flex-direction:column;overflow:hidden}
        .db-info{padding:6px 12px;background:var(--bg2);border-bottom:1px solid #222235;display:flex;align-items:center;gap:8px;flex-wrap:wrap}
        .db-info .path{color:var(--dim);font-size:11px;flex:1;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;font-family:'SF Mono','Menlo',monospace;-webkit-user-select:text}
        .db-info button{background:var(--bg3);border:1px solid #333350;color:var(--gold);padding:3px 10px;border-radius:4px;cursor:pointer;font-size:11px}
        .db-info button:hover{background:#252535}
        .tables-bar{padding:6px 12px;background:var(--bg2);border-bottom:1px solid #222235;display:flex;gap:4px;flex-wrap:wrap;overflow-x:auto}
        .table-btn{background:var(--bg3);border:1px solid #333350;color:var(--text);padding:4px 10px;border-radius:4px;cursor:pointer;font-size:11px;white-space:nowrap}
        .table-btn:hover{border-color:var(--gold);color:var(--gold)}
        .table-btn.active{background:var(--gold);color:var(--bg);border-color:var(--gold)}
        .table-btn .tc{color:var(--dim);font-size:9px;margin-left:4px}
        .table-btn.active .tc{color:rgba(0,0,0,0.5)}
        .query-bar{padding:8px 12px;background:var(--bg2);border-bottom:1px solid #222235;display:flex;gap:8px}
        .query-bar textarea{flex:1;background:var(--bg3);border:1px solid #333350;color:var(--text);padding:6px 10px;border-radius:4px;font-family:'SF Mono','Menlo',monospace;font-size:12px;resize:none;height:52px;-webkit-user-select:text}
        .query-bar textarea:focus{border-color:var(--gold);outline:none}
        .query-bar .qb{display:flex;flex-direction:column;gap:4px}
        .query-bar button{background:var(--bg3);border:1px solid #333350;color:var(--gold);padding:4px 14px;border-radius:4px;cursor:pointer;font-size:11px}
        .query-bar button:hover{background:#252535}
        .query-bar button.run{background:var(--gold);color:var(--bg);border-color:var(--gold);font-weight:500}
        .results{flex:1;overflow:auto;padding:0}
        .results::-webkit-scrollbar{width:6px;height:6px}
        .results::-webkit-scrollbar-thumb{background:#333350;border-radius:3px}
        .results table{border-collapse:collapse;width:100%;font-size:11px;font-family:'SF Mono','Menlo',monospace}
        .results th{background:var(--bg2);color:var(--gold);padding:5px 10px;text-align:left;position:sticky;top:0;border-bottom:1px solid #333350;white-space:nowrap;cursor:pointer;user-select:none;font-weight:500;font-size:10px;text-transform:uppercase;letter-spacing:0.5px}
        .results th:hover{background:var(--bg3)}
        .results td{padding:4px 10px;border-bottom:1px solid #1a1a25;max-width:400px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
        .results tr:hover td{background:rgba(196,168,130,0.03)}
        .results td.num{text-align:right;color:var(--cyan)}
        .results td.null{color:var(--dim);font-style:italic}
        .results td.blob{color:var(--purple)}
        .statusbar{padding:4px 16px;background:var(--bg2);border-top:1px solid #222235;display:flex;justify-content:space-between;font-size:10px;color:var(--dim)}
        .empty-state{display:flex;flex-direction:column;align-items:center;justify-content:center;height:100%;color:var(--dim);text-align:center;padding:40px}
        .empty-state h2{color:var(--gold);font-family:'SF Pro Display',Georgia,serif;font-size:20px;font-weight:400;margin-bottom:8px}
        .empty-state .sub{font-size:12px;margin-bottom:24px;line-height:1.6}
        .drop-zone{border:2px dashed #333350;border-radius:12px;padding:40px 60px;cursor:pointer;transition:all 0.2s}
        .drop-zone:hover,.drop-zone.over{border-color:var(--gold);background:rgba(196,168,130,0.03)}
        .schema-view{padding:16px;font-family:'SF Mono','Menlo',monospace;font-size:11px;line-height:1.7;-webkit-user-select:text;white-space:pre-wrap;color:var(--text)}
        </style>
        </head>
        <body>
        <header>
          <h1>L7 DATABASE EXPLORER</h1>
          <div class="stats" id="stats">Loading...</div>
        </header>
        <div class="main">
          <div class="sidebar">
            <div class="sb-search"><input type="text" id="db-search" placeholder="Search databases... (/)" /></div>
            <div class="sb-sort">
              <button class="active" onclick="sortCatalog('size',this)">Size</button>
              <button onclick="sortCatalog('name',this)">Name</button>
              <button onclick="sortCatalog('count',this)">Count</button>
            </div>
            <div class="db-list" id="db-list"></div>
          </div>
          <div class="content">
            <div class="db-info" id="db-info" style="display:none">
              <span class="path" id="db-path"></span>
              <button onclick="showSchema()">Schema</button>
              <button onclick="native('exportCSV',{table:currentTable})">Export</button>
              <button onclick="native('reveal',{path:currentDbPath})">Reveal</button>
            </div>
            <div class="tables-bar" id="tables-bar" style="display:none"></div>
            <div class="query-bar" id="query-bar" style="display:none">
              <textarea id="query" class="mono" placeholder="SELECT * FROM table_name LIMIT 100;"></textarea>
              <div class="qb">
                <button class="run" onclick="runQuery()">Run &#x2318;&#x21A9;</button>
                <button onclick="clearResults()">Clear</button>
              </div>
            </div>
            <div class="results" id="results">
              <div class="empty-state" id="empty-state">
                <h2>Database Explorer</h2>
                <div class="sub">Native SQLite3 browser for L7 filesystem archaeology<br/>511 databases across 127 domains — no content leaves your machine</div>
                <div class="drop-zone" id="drop-zone">
                  Drop a .sqlite / .db file here<br/><span style="font-size:10px;color:var(--dim)">or select from the sidebar &middot; &#x2318;O to open</span>
                </div>
              </div>
            </div>
          </div>
        </div>
        <div class="statusbar">
          <span id="status-left">Ready</span>
          <span id="status-right">L7 Morph Technology</span>
        </div>

        <script>
        let catalog = [];
        let groups = {};
        let currentTable = '';
        let currentDbPath = '';
        let sortMode = 'size';
        let sortCol = -1;
        let sortAsc = true;
        let expandedGroups = new Set();

        function native(action, params = {}) {
          window.webkit.messageHandlers.native.postMessage({action, ...params});
        }

        function fmtS(b) {
          if (!b) return '0';
          if (b < 1024) return b + 'B';
          if (b < 1048576) return (b / 1024).toFixed(0) + 'K';
          if (b < 1073741824) return (b / 1048576).toFixed(1) + 'M';
          return (b / 1073741824).toFixed(1) + 'G';
        }

        function esc(s) { return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }

        // ---- Catalog & Sidebar ----

        function onCatalogLoaded(data) {
          catalog = typeof data === 'string' ? JSON.parse(data) : data;
          buildGroups();
          renderSidebar();
          document.getElementById('stats').textContent = catalog.length + ' databases | ' + Object.keys(groups).length + ' groups';
        }

        function buildGroups() {
          groups = {};
          for (const db of catalog) {
            const d = db.dir || '';
            const parts = d.split('/');
            let domain;
            const libIdx = parts.indexOf('Library');
            const bakIdx = parts.indexOf('Backup');
            if (libIdx >= 0) domain = parts.slice(libIdx, libIdx + 3).join('/');
            else if (bakIdx >= 0) domain = parts.slice(bakIdx, bakIdx + 2).join('/');
            else domain = parts.slice(0, 2).join('/') || 'root';
            if (!groups[domain]) groups[domain] = [];
            groups[domain].push(db);
          }
        }

        function sortCatalog(mode, btn) {
          sortMode = mode;
          document.querySelectorAll('.sb-sort button').forEach(b => b.classList.remove('active'));
          btn.classList.add('active');
          renderSidebar();
        }

        function renderSidebar(filter) {
          const q = (filter || document.getElementById('db-search').value || '').toLowerCase();
          const list = document.getElementById('db-list');
          let entries = Object.entries(groups);

          if (sortMode === 'size') entries.sort((a,b) => b[1].reduce((s,d)=>s+d.size,0) - a[1].reduce((s,d)=>s+d.size,0));
          else if (sortMode === 'name') entries.sort((a,b) => a[0].localeCompare(b[0]));
          else if (sortMode === 'count') entries.sort((a,b) => b[1].length - a[1].length);

          let h = '';
          for (const [group, dbs] of entries) {
            const filtered = q ? dbs.filter(d => d.name.toLowerCase().includes(q) || d.dir.toLowerCase().includes(q) || group.toLowerCase().includes(q)) : dbs;
            if (!filtered.length) continue;
            const totalSz = filtered.reduce((s,d) => s + d.size, 0);
            const isOpen = expandedGroups.has(group) || !!q;
            h += '<div class="db-group">';
            h += '<div class="db-gh" onclick="toggleGroup(\\'' + group.replace(/'/g,"\\\\'") + '\\')">';
            h += '<span class="arr">' + (isOpen ? '▾' : '▸') + '</span>';
            h += '<span style="flex:1;overflow:hidden;text-overflow:ellipsis">' + esc(group) + '</span>';
            h += '<span class="cnt">' + filtered.length + ' · ' + fmtS(totalSz) + '</span></div>';
            if (isOpen) {
              const sorted = [...filtered].sort((a,b) => b.size - a.size);
              for (const db of sorted) {
                const active = db.path === currentDbPath ? ' active' : '';
                h += '<div class="db-item' + active + '" onclick="openDatabaseNative(\\'' + db.path.replace(/'/g,"\\\\'") + '\\')" title="' + esc(db.path) + '">';
                h += '<span class="ic">\\u{1F5C3}</span>';
                h += '<span class="nm">' + esc(db.name) + '</span>';
                h += '<span class="sz">' + fmtS(db.size) + '</span></div>';
              }
            }
            h += '</div>';
          }
          list.innerHTML = h || '<div style="padding:20px;text-align:center;color:var(--dim)">No databases found</div>';
        }

        function toggleGroup(g) {
          if (expandedGroups.has(g)) expandedGroups.delete(g);
          else expandedGroups.add(g);
          renderSidebar();
        }

        // ---- Database Operations ----

        function openDatabaseNative(path) {
          currentDbPath = path;
          document.getElementById('status-left').textContent = 'Opening ' + path.split('/').pop() + '...';
          native('openDatabase', {path});
        }

        function onDatabaseOpened(data) {
          const info = typeof data === 'string' ? JSON.parse(data) : data;
          currentDbPath = info.path;
          document.getElementById('db-info').style.display = 'flex';
          document.getElementById('db-path').textContent = info.path;
          document.getElementById('query-bar').style.display = 'flex';
          document.getElementById('empty-state').style.display = 'none';

          const bar = document.getElementById('tables-bar');
          bar.style.display = 'flex';
          let th = '';
          for (const t of info.tables) {
            const icon = t.type === 'view' ? '&#x1F441;' : '';
            th += '<button class="table-btn" onclick="selectTable(\\'' + t.name.replace(/'/g,"\\\\'") + '\\',this)">' + icon + ' ' + esc(t.name) + '<span class="tc">' + t.count + '</span></button>';
          }
          bar.innerHTML = th;

          if (info.tables.length > 0) {
            selectTable(info.tables[0].name, bar.querySelector('.table-btn'));
          }
          document.getElementById('status-left').textContent = info.tables.length + ' tables';
          renderSidebar();
        }

        function onDatabaseError(msg) {
          document.getElementById('status-left').textContent = 'Error: ' + msg;
        }

        function selectTable(name, btn) {
          currentTable = name;
          document.querySelectorAll('.table-btn').forEach(b => b.classList.remove('active'));
          if (btn) btn.classList.add('active');
          document.getElementById('query').value = 'SELECT * FROM "' + name + '" LIMIT 200;';
          sortCol = -1;
          runQuery();
        }

        function runQuery() {
          const sql = document.getElementById('query').value.trim();
          if (!sql) return;
          native('runQuery', {sql});
        }

        function onQueryResult(data) {
          const r = typeof data === 'string' ? JSON.parse(data) : data;
          renderTable(r.columns, r.values);
          document.getElementById('status-left').textContent = r.count + ' rows (' + r.elapsed.toFixed(1) + 'ms)';
        }

        function onQueryError(msg) {
          document.getElementById('results').innerHTML = '<div style="padding:20px;color:var(--red)">Error: ' + esc(msg) + '</div>';
          document.getElementById('status-left').textContent = 'Query error';
        }

        function renderTable(columns, values) {
          let h = '<table><thead><tr>';
          for (let i = 0; i < columns.length; i++) {
            const arrow = sortCol === i ? (sortAsc ? ' \\u25B2' : ' \\u25BC') : '';
            h += '<th onclick="sortByCol(' + i + ')">' + esc(columns[i]) + arrow + '</th>';
          }
          h += '</tr></thead><tbody>';

          const rows = sortCol >= 0 ? [...values].sort((a,b) => {
            const va = a[sortCol], vb = b[sortCol];
            if (va === null) return 1;
            if (vb === null) return -1;
            if (typeof va === 'number' && typeof vb === 'number') return sortAsc ? va - vb : vb - va;
            return sortAsc ? String(va).localeCompare(String(vb)) : String(vb).localeCompare(String(va));
          }) : values;

          for (const row of rows) {
            h += '<tr>';
            for (const val of row) {
              if (val === null) h += '<td class="null">NULL</td>';
              else if (typeof val === 'number') h += '<td class="num">' + val + '</td>';
              else if (String(val).startsWith('[BLOB')) h += '<td class="blob">' + esc(val) + '</td>';
              else {
                const s = String(val);
                h += '<td title="' + esc(s) + '">' + esc(s.length > 200 ? s.slice(0, 200) + '...' : s) + '</td>';
              }
            }
            h += '</tr>';
          }
          h += '</tbody></table>';
          document.getElementById('results').innerHTML = h;
        }

        function sortByCol(i) {
          if (sortCol === i) sortAsc = !sortAsc;
          else { sortCol = i; sortAsc = true; }
          runQuery();
        }

        function showSchema() {
          native('getSchema');
        }

        function onSchemaResult(schema) {
          document.getElementById('results').innerHTML = '<div class="schema-view">' + esc(schema) + '</div>';
          document.getElementById('status-left').textContent = 'Schema view';
        }

        function clearResults() {
          document.getElementById('results').innerHTML = '';
          sortCol = -1;
          document.getElementById('status-left').textContent = 'Cleared';
        }

        // ---- Keyboard ----

        document.addEventListener('keydown', e => {
          if ((e.metaKey || e.ctrlKey) && e.key === 'Enter') { e.preventDefault(); runQuery(); }
          if (e.key === '/' && !e.ctrlKey && !e.metaKey && document.activeElement.tagName !== 'TEXTAREA') {
            e.preventDefault(); document.getElementById('db-search').focus();
          }
          if (e.key === 'Escape') {
            document.getElementById('db-search').value = '';
            renderSidebar();
          }
        });

        document.getElementById('db-search').addEventListener('input', e => renderSidebar(e.target.value));

        // Load catalog on init
        native('loadCatalog');
        </script>
        </body>
        </html>
        """
    }
}

// ============================================================
// Main — Launch the app
// ============================================================

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
