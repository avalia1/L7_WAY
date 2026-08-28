// ══════════════════════════════════════════════════════════════
// L7 GALLERY — The Alchemist's Cabinet
// Native offline media browser. Biometric gate. No network.
//
// Data cannot leave this device for any unauthorized use.
// All media under biometric signature (Touch ID / Law XXX).
//
// The Council of Seven governs the visual domain:
//   ☉ Sun     — Capability, the Icons (Gold)
//   ☽ Moon    — Data, the Personal (Silver)
//   ☿ Mercury — Communication, the Screenshots (Quicksilver)
//   ♀ Venus   — Beauty, the Creative (Copper)
//   ♂ Mars    — Action, the Work (Iron)
//   ♃ Jupiter — Expansion, the Archive (Tin)
//   ♄ Saturn  — Structure, the Vault (Lead)
//
// Creator: Alberto Valido Delgado
// Publisher: Avli Cloud
// License: Proprietary — Law XVI + 12% unauthorized use penalty
// ══════════════════════════════════════════════════════════════

import Foundation
import LocalAuthentication

// ─── Configuration ───────────────────────────────

let L7_DIR = ProcessInfo.processInfo.environment["L7_DIR"]
    ?? NSHomeDirectory() + "/.l7"
let HOME = NSHomeDirectory()
let GALLERY_DIR = L7_DIR + "/gallery"
let GALLERY_HTML = GALLERY_DIR + "/gallery.html"
let VERSION = "1.0.0"

// ─── Biometric Gate ──────────────────────────────

// ─── Security: Anti-Debug ───────────────────────
func verifyNotTraced() -> Bool {
    var info = kinfo_proc()
    var size = MemoryLayout<kinfo_proc>.stride
    var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
    let r = sysctl(&mib, 4, &info, &size, nil, 0)
    if r == 0 && (info.kp_proc.p_flag & P_TRACED) != 0 {
        galleryLog("SECURITY: Debugger detected — ABORT")
        return false
    }
    return true
}

// ─── Security: Audit Log (permanent, append-only) ───
let GALLERY_LOG = L7_DIR + "/gallery/audit.log"

func galleryLog(_ entry: String) {
    let line = "[\(ISO8601DateFormatter().string(from: Date()))] \(entry)\n"
    if let handle = FileHandle(forWritingAtPath: GALLERY_LOG) {
        handle.seekToEndOfFile()
        handle.write(line.data(using: .utf8)!)
        handle.closeFile()
    } else {
        FileManager.default.createFile(atPath: GALLERY_LOG, contents: line.data(using: .utf8))
        chmod(GALLERY_LOG, 0o600)
    }
}

// ─── Security: Biometric ONLY (no password fallback) ───
func authenticate() -> Bool {
    let context = LAContext()
    context.localizedFallbackTitle = "" // No password fallback — Law XXX
    var error: NSError?

    guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
        fputs("  Biometric authentication unavailable: \(error?.localizedDescription ?? "unknown")\n", stderr)
        fputs("  Law XXX: No passwords. Biometrics ONLY. No fallback.\n", stderr)
        galleryLog("AUTH_FAIL: Biometrics unavailable")
        return false
    }

    let sem = DispatchSemaphore(value: 0)
    var authenticated = false
    context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                           localizedReason: "L7 Gallery — The Alchemist's Cabinet requires your seal") { success, _ in
        authenticated = success
        sem.signal()
    }
    sem.wait()

    galleryLog(authenticated ? "AUTH_OK: Gallery access" : "AUTH_FAIL: Biometric denied")
    return authenticated
}

// ─── Media Scanner ───────────────────────────────

struct MediaItem {
    let path: String
    let name: String
    let type: String   // image, audio, video
    let ext: String
    let size: Int64
    let modified: Date
    let domain: String
    let council: String  // planetary attribution
}

let IMAGE_EXTS = Set(["png", "jpg", "jpeg", "gif", "webp", "bmp", "tiff", "icns", "heic"])
let AUDIO_EXTS = Set(["mp3", "wav", "m4a", "aac", "flac", "ogg", "aiff"])
let VIDEO_EXTS = Set(["mp4", "mov", "avi", "mkv", "webm", "m4v"])

func classifyType(_ ext: String) -> String? {
    let e = ext.lowercased()
    if IMAGE_EXTS.contains(e) { return "image" }
    if AUDIO_EXTS.contains(e) { return "audio" }
    if VIDEO_EXTS.contains(e) { return "video" }
    return nil
}

func classifyDomain(_ path: String) -> String {
    if path.contains("/.l7/vault") || path.contains("/vault/") { return "vault" }
    if path.contains("/.l7/morph") || path.contains("/rose/") || path.contains("/simulations/") { return "morph" }
    if path.contains("/.l7/salt") || path.contains("/Backup/") && path.contains("RECOVERY") { return "salt" }
    if path.contains("/.l7/icons") { return "work" }
    if path.contains("/Desktop/") || path.contains("/Downloads/") { return "salt" }
    if path.contains("/Audio/") { return "work" }
    return "work"
}

func classifyCouncil(_ path: String, _ type: String) -> String {
    if path.contains("/icons/") { return "sun" }         // ☉ capability
    if path.contains("/Audio/") { return "moon" }         // ☽ data/personal
    if path.contains("/Desktop/") { return "mercury" }    // ☿ communication
    if path.contains("/rose/") || path.contains("/simulations/") { return "venus" } // ♀ beauty
    if path.contains("/apps/") || path.contains("/work/") { return "mars" }         // ♂ action
    if path.contains("/Backup/") || path.contains("/salt/") { return "jupiter" }    // ♃ archive
    if path.contains("/vault/") || path.contains("/.ssh/") { return "saturn" }      // ♄ structure
    if type == "audio" { return "moon" }
    if type == "video" { return "mars" }
    return "mercury"
}

func scanDirectory(_ dir: String, maxItems: Int = 500) -> [MediaItem] {
    var items: [MediaItem] = []
    let fm = FileManager.default
    guard let enumerator = fm.enumerator(atPath: dir) else { return items }

    while let file = enumerator.nextObject() as? String {
        if items.count >= maxItems { break }
        let ext = (file as NSString).pathExtension.lowercased()
        guard let type = classifyType(ext) else { continue }

        let fullPath = (dir as NSString).appendingPathComponent(file)
        guard let attrs = try? fm.attributesOfItem(atPath: fullPath) else { continue }
        let size = (attrs[.size] as? Int64) ?? 0
        let modified = (attrs[.modificationDate] as? Date) ?? Date.distantPast

        // Skip tiny files and system files
        if size < 100 { continue }
        if file.hasPrefix(".") || file.contains("/.") { continue }

        let domain = classifyDomain(fullPath)
        let council = classifyCouncil(fullPath, type)

        items.append(MediaItem(
            path: fullPath,
            name: (file as NSString).lastPathComponent,
            type: type, ext: ext, size: size,
            modified: modified, domain: domain, council: council
        ))
    }
    return items
}

// ─── HTML Gallery Generator ──────────────────────

func generateGallery(_ items: [MediaItem]) -> String {
    let counts = Dictionary(grouping: items, by: { $0.type }).mapValues { $0.count }
    let domainCounts = Dictionary(grouping: items, by: { $0.domain }).mapValues { $0.count }
    let councilCounts = Dictionary(grouping: items, by: { $0.council }).mapValues { $0.count }
    let totalSize = items.reduce(Int64(0)) { $0 + $1.size }
    let sizeStr: String
    if totalSize > 1_073_741_824 { sizeStr = String(format: "%.1f GB", Double(totalSize) / 1_073_741_824) }
    else if totalSize > 1_048_576 { sizeStr = String(format: "%.1f MB", Double(totalSize) / 1_048_576) }
    else { sizeStr = "\(totalSize / 1024) KB" }

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"

    // Group items by council
    let byCouncil = Dictionary(grouping: items, by: { $0.council })
    let councilOrder = ["sun", "moon", "mercury", "venus", "mars", "jupiter", "saturn"]

    var mediaCards = ""
    for council in councilOrder {
        guard let sectionItems = byCouncil[council], !sectionItems.isEmpty else { continue }
        let info = councilInfo(council)
        let sorted = sectionItems.sorted { $0.modified > $1.modified }

        mediaCards += """
        <section class="council-section" id="section-\(council)">
          <h2 class="council-header \(council)">
            <span class="planet-symbol">\(info.symbol)</span>
            \(info.name) — \(info.title)
            <span class="count">\(sorted.count)</span>
          </h2>
          <div class="media-grid">
        """

        for item in sorted.prefix(100) {
            let escapedPath = item.path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? item.path
            let fileUrl = "file://\(escapedPath)"
            let sizeKB = item.size / 1024
            let dateStr = dateFormatter.string(from: item.modified)
            let domainBadge = domainBadgeHTML(item.domain)

            if item.type == "image" {
                mediaCards += """
                <div class="media-card \(council)" onclick="showLightbox('\(fileUrl)')">
                  <div class="thumb-container">
                    <img src="\(fileUrl)" loading="lazy" alt="\(escHTML(item.name))">
                  </div>
                  <div class="card-info">
                    <span class="card-name">\(escHTML(String(item.name.prefix(24))))</span>
                    <span class="card-meta">\(sizeKB)KB \(domainBadge)</span>
                  </div>
                </div>
                """
            } else if item.type == "audio" {
                mediaCards += """
                <div class="media-card audio \(council)">
                  <div class="audio-icon">☽</div>
                  <div class="card-info">
                    <span class="card-name">\(escHTML(String(item.name.prefix(30))))</span>
                    <audio controls preload="none"><source src="\(fileUrl)"></audio>
                    <span class="card-meta">\(sizeKB)KB · \(dateStr) \(domainBadge)</span>
                  </div>
                </div>
                """
            } else if item.type == "video" {
                mediaCards += """
                <div class="media-card video \(council)">
                  <video controls preload="none" width="100%"><source src="\(fileUrl)"></video>
                  <div class="card-info">
                    <span class="card-name">\(escHTML(item.name))</span>
                    <span class="card-meta">\(sizeKB)KB · \(dateStr) \(domainBadge)</span>
                  </div>
                </div>
                """
            }
        }

        if sorted.count > 100 {
            mediaCards += "<div class='overflow-note'>+ \(sorted.count - 100) more items in this domain</div>"
        }

        mediaCards += "</div></section>"
    }

    // Build council nav
    var councilNav = ""
    for c in councilOrder {
        let info = councilInfo(c)
        let count = councilCounts[c] ?? 0
        if count > 0 {
            councilNav += "<a href='#section-\(c)' class='council-nav-item \(c)'><span class='nav-symbol'>\(info.symbol)</span> \(info.name) <span class='nav-count'>\(count)</span></a>"
        }
    }

    return """
    <!DOCTYPE html>
    <html lang="en">
    <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>L7 Gallery — The Alchemist's Cabinet</title>
    <style>
    :root {
      --nigredo: #0a0a0f;
      --albedo: #e0d5b7;
      --citrinitas: #c4a747;
      --rubedo: #8b0000;
      --parchment: #f0e6cc;
      --ink: #1a1a2e;
      --sun: #FFD700;
      --moon: #C0C0C0;
      --mercury: #87CEEB;
      --venus: #98FB98;
      --mars: #FF6347;
      --jupiter: #9370DB;
      --saturn: #708090;
      --morph: #9b59b6;
      --work: #27ae60;
      --salt: #f39c12;
      --vault: #c0392b;
    }
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      background: var(--nigredo);
      color: var(--albedo);
      font-family: 'Palatino Linotype', 'Book Antiqua', Palatino, Georgia, serif;
      min-height: 100vh;
      background-image:
        radial-gradient(ellipse at 20% 50%, rgba(196,167,71,0.03) 0%, transparent 50%),
        radial-gradient(ellipse at 80% 20%, rgba(139,0,0,0.03) 0%, transparent 50%),
        radial-gradient(ellipse at 50% 80%, rgba(147,112,219,0.03) 0%, transparent 50%);
    }

    /* ─── Header ─── */
    .header {
      text-align: center;
      padding: 40px 20px 20px;
      border-bottom: 1px solid rgba(196,167,71,0.3);
    }
    .header h1 {
      font-size: 2.2em;
      color: var(--citrinitas);
      letter-spacing: 0.15em;
      text-shadow: 0 0 20px rgba(196,167,71,0.3);
    }
    .header .subtitle {
      color: var(--moon);
      font-size: 0.9em;
      margin-top: 5px;
      font-style: italic;
    }
    .header .sigils {
      font-size: 1.5em;
      letter-spacing: 0.5em;
      margin: 15px 0;
      color: var(--citrinitas);
      opacity: 0.7;
    }
    .stats-bar {
      display: flex;
      justify-content: center;
      gap: 30px;
      margin: 15px 0;
      flex-wrap: wrap;
    }
    .stat {
      text-align: center;
    }
    .stat-value {
      font-size: 1.4em;
      color: var(--citrinitas);
      font-weight: bold;
    }
    .stat-label {
      font-size: 0.75em;
      color: var(--moon);
      text-transform: uppercase;
      letter-spacing: 0.1em;
    }

    /* ─── Council Navigation ─── */
    .council-nav {
      display: flex;
      justify-content: center;
      gap: 8px;
      padding: 15px 20px;
      flex-wrap: wrap;
      border-bottom: 1px solid rgba(196,167,71,0.15);
    }
    .council-nav-item {
      padding: 6px 14px;
      border-radius: 20px;
      text-decoration: none;
      font-size: 0.85em;
      border: 1px solid rgba(196,167,71,0.2);
      transition: all 0.3s;
      color: var(--albedo);
    }
    .council-nav-item:hover { border-color: var(--citrinitas); background: rgba(196,167,71,0.1); }
    .council-nav-item.sun { border-color: var(--sun); }
    .council-nav-item.moon { border-color: var(--moon); }
    .council-nav-item.mercury { border-color: var(--mercury); }
    .council-nav-item.venus { border-color: var(--venus); }
    .council-nav-item.mars { border-color: var(--mars); }
    .council-nav-item.jupiter { border-color: var(--jupiter); }
    .council-nav-item.saturn { border-color: var(--saturn); }
    .nav-symbol { font-size: 1.1em; }
    .nav-count { opacity: 0.5; font-size: 0.8em; }

    /* ─── Council Sections ─── */
    .council-section { padding: 20px; max-width: 1400px; margin: 0 auto; }
    .council-header {
      font-size: 1.3em;
      padding: 10px 0;
      margin-bottom: 15px;
      border-bottom: 1px solid rgba(196,167,71,0.2);
      display: flex;
      align-items: center;
      gap: 10px;
    }
    .council-header.sun { color: var(--sun); border-color: var(--sun); }
    .council-header.moon { color: var(--moon); border-color: var(--moon); }
    .council-header.mercury { color: var(--mercury); border-color: var(--mercury); }
    .council-header.venus { color: var(--venus); border-color: var(--venus); }
    .council-header.mars { color: var(--mars); border-color: var(--mars); }
    .council-header.jupiter { color: var(--jupiter); border-color: var(--jupiter); }
    .council-header.saturn { color: var(--saturn); border-color: var(--saturn); }
    .planet-symbol { font-size: 1.5em; }
    .count { opacity: 0.4; font-size: 0.7em; margin-left: auto; }

    /* ─── Media Grid ─── */
    .media-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
      gap: 12px;
    }

    /* ─── Media Cards ─── */
    .media-card {
      background: rgba(26,26,46,0.8);
      border: 1px solid rgba(196,167,71,0.15);
      border-radius: 8px;
      overflow: hidden;
      cursor: pointer;
      transition: all 0.3s;
    }
    .media-card:hover {
      border-color: var(--citrinitas);
      transform: translateY(-2px);
      box-shadow: 0 4px 20px rgba(196,167,71,0.15);
    }
    .media-card.sun:hover { border-color: var(--sun); box-shadow: 0 4px 20px rgba(255,215,0,0.15); }
    .media-card.moon:hover { border-color: var(--moon); }
    .media-card.venus:hover { border-color: var(--venus); box-shadow: 0 4px 20px rgba(152,251,152,0.15); }
    .media-card.mars:hover { border-color: var(--mars); box-shadow: 0 4px 20px rgba(255,99,71,0.15); }

    .thumb-container {
      width: 100%;
      height: 140px;
      overflow: hidden;
      display: flex;
      align-items: center;
      justify-content: center;
      background: rgba(0,0,0,0.3);
    }
    .thumb-container img {
      max-width: 100%;
      max-height: 100%;
      object-fit: contain;
    }
    .card-info {
      padding: 8px 10px;
      display: flex;
      flex-direction: column;
      gap: 2px;
    }
    .card-name {
      font-size: 0.75em;
      color: var(--albedo);
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }
    .card-meta {
      font-size: 0.65em;
      color: var(--moon);
      opacity: 0.6;
    }

    /* Audio cards */
    .media-card.audio {
      display: flex;
      align-items: center;
      gap: 12px;
      padding: 12px;
      grid-column: span 2;
    }
    .audio-icon { font-size: 2em; color: var(--moon); }
    .media-card.audio audio { width: 100%; max-width: 300px; height: 30px; }

    /* Video cards */
    .media-card.video {
      grid-column: span 2;
    }
    .media-card.video video { width: 100%; border-radius: 8px 8px 0 0; }

    /* Domain badges */
    .badge { padding: 1px 6px; border-radius: 8px; font-size: 0.7em; }
    .badge-morph { background: rgba(155,89,182,0.3); color: var(--morph); }
    .badge-work { background: rgba(39,174,96,0.3); color: var(--work); }
    .badge-salt { background: rgba(243,156,18,0.3); color: var(--salt); }
    .badge-vault { background: rgba(192,57,43,0.3); color: var(--vault); }

    .overflow-note {
      grid-column: 1 / -1;
      text-align: center;
      padding: 15px;
      color: var(--moon);
      opacity: 0.5;
      font-style: italic;
    }

    /* ─── Lightbox ─── */
    .lightbox {
      display: none;
      position: fixed;
      top: 0; left: 0; right: 0; bottom: 0;
      background: rgba(0,0,0,0.95);
      z-index: 1000;
      cursor: pointer;
      align-items: center;
      justify-content: center;
    }
    .lightbox.active { display: flex; }
    .lightbox img {
      max-width: 95vw;
      max-height: 95vh;
      object-fit: contain;
      border: 1px solid rgba(196,167,71,0.3);
      border-radius: 4px;
    }

    /* ─── Footer ─── */
    .footer {
      text-align: center;
      padding: 30px 20px;
      border-top: 1px solid rgba(196,167,71,0.15);
      margin-top: 40px;
    }
    .footer .seal {
      color: var(--citrinitas);
      font-size: 0.85em;
      letter-spacing: 0.1em;
    }
    .footer .license {
      color: var(--moon);
      font-size: 0.65em;
      opacity: 0.5;
      margin-top: 8px;
      max-width: 600px;
      margin-left: auto;
      margin-right: auto;
    }
    .footer .sigils {
      font-size: 1.2em;
      color: var(--citrinitas);
      opacity: 0.4;
      letter-spacing: 0.4em;
      margin-top: 10px;
    }
    </style>
    </head>
    <body>

    <div class="header">
      <div class="sigils">☉ ☽ ☿ ♀ ♂ ♃ ♄</div>
      <h1>THE ALCHEMIST'S CABINET</h1>
      <div class="subtitle">L7 Gallery — Offline Media Browser — Biometrically Sealed</div>
      <div class="stats-bar">
        <div class="stat"><div class="stat-value">\(items.count)</div><div class="stat-label">Media</div></div>
        <div class="stat"><div class="stat-value">\(counts["image"] ?? 0)</div><div class="stat-label">Images</div></div>
        <div class="stat"><div class="stat-value">\(counts["audio"] ?? 0)</div><div class="stat-label">Audio</div></div>
        <div class="stat"><div class="stat-value">\(counts["video"] ?? 0)</div><div class="stat-label">Video</div></div>
        <div class="stat"><div class="stat-value">\(sizeStr)</div><div class="stat-label">Total</div></div>
        <div class="stat"><div class="stat-value">\(domainCounts.count)</div><div class="stat-label">Domains</div></div>
      </div>
    </div>

    <nav class="council-nav">
      \(councilNav)
    </nav>

    \(mediaCards)

    <div class="footer">
      <div class="seal">AVLI CLOUD LLC — Production Sealed</div>
      <div class="license">
        All media on this device is the property of Alberto Valido Delgado.
        Unauthorized use carries a 12% flat revenue share penalty (Law XVI enforcement).
        All pseudonyms (valido, avalia, avalia1, avalia333, avalia777, 1991)
        resolve to one legal entity. Data cannot leave this device without authorization.
        Law XXX: Biometrics only.
      </div>
      <div class="sigils">☉ ☽ ☿ ♀ ♂ ♃ ♄</div>
    </div>

    <div class="lightbox" id="lightbox" onclick="closeLightbox()">
      <img id="lightbox-img" src="" alt="Full size">
    </div>

    <script>
    function showLightbox(src) {
      document.getElementById('lightbox-img').src = src;
      document.getElementById('lightbox').classList.add('active');
    }
    function closeLightbox() {
      document.getElementById('lightbox').classList.remove('active');
    }
    document.addEventListener('keydown', e => { if (e.key === 'Escape') closeLightbox(); });
    </script>

    </body>
    </html>
    """
}

// ─── Helpers ─────────────────────────────────────

struct CouncilInfo {
    let name: String
    let symbol: String
    let title: String
}

func councilInfo(_ key: String) -> CouncilInfo {
    switch key {
    case "sun":     return CouncilInfo(name: "Sol", symbol: "☉", title: "The Icons of Capability")
    case "moon":    return CouncilInfo(name: "Luna", symbol: "☽", title: "The Personal Archive")
    case "mercury": return CouncilInfo(name: "Mercurius", symbol: "☿", title: "The Communications")
    case "venus":   return CouncilInfo(name: "Venus", symbol: "♀", title: "The Creative Works")
    case "mars":    return CouncilInfo(name: "Mars", symbol: "♂", title: "The Active Projects")
    case "jupiter": return CouncilInfo(name: "Jupiter", symbol: "♃", title: "The Archive Expansion")
    case "saturn":  return CouncilInfo(name: "Saturn", symbol: "♄", title: "The Sealed Vault")
    default:        return CouncilInfo(name: key, symbol: "?", title: "Unknown")
    }
}

func domainBadgeHTML(_ domain: String) -> String {
    return "<span class='badge badge-\(domain)'>.\(domain)</span>"
}

func escHTML(_ s: String) -> String {
    s.replacingOccurrences(of: "&", with: "&amp;")
     .replacingOccurrences(of: "<", with: "&lt;")
     .replacingOccurrences(of: ">", with: "&gt;")
     .replacingOccurrences(of: "\"", with: "&quot;")
}

// ─── Main ────────────────────────────────────────

let args = CommandLine.arguments

if args.contains("--version") {
    print("L7 Gallery v\(VERSION) — The Alchemist's Cabinet")
    print("Creator: Alberto Valido Delgado | Publisher: Avli Cloud")
    print("Offline only. Biometric gate. No network.")
    exit(0)
}

if args.contains("--help") {
    print("""
    L7 Gallery — The Alchemist's Cabinet

    Native offline media browser with biometric protection.
    Data cannot leave this device for any unauthorized use.

    Usage: l7 gallery [options]

    Options:
      (none)          Authenticate, scan, generate, and open gallery
      --scan-only     Just scan and report media counts (no HTML)
      --no-open       Generate gallery but don't open in browser
      --version       Show version
      --help          Show this help

    Council of Seven:
      ☉ Sol       — Icons, capability assets
      ☽ Luna      — Personal recordings, data
      ☿ Mercurius — Screenshots, communications
      ♀ Venus     — Creative works, beauty
      ♂ Mars      — Active project media
      ♃ Jupiter   — Archive expansion
      ♄ Saturn    — Sealed vault items
    """)
    exit(0)
}

// ─── Authenticate ────────────────────────────────

print()
print("  \u{1b}[93m☉ ☽ ☿ ♀ ♂ ♃ ♄\u{1b}[0m")
print("  \u{1b}[1m\u{1b}[93mTHE ALCHEMIST'S CABINET\u{1b}[0m")
print("  \u{1b}[2mL7 Gallery — Biometric Gate\u{1b}[0m")
print()

// ─── Security Checks (consistent across all ashrams) ───
guard verifyNotTraced() else {
    print("  \u{1b}[91mDebugger detected. Gallery refuses to operate.\u{1b}[0m")
    exit(1)
}
galleryLog("GALLERY_OPEN: pid=\(getpid()) uid=\(getuid())")

// Remove --no-auth bypass — biometrics ALWAYS required (Law XXX)
print("  \u{1b}[2mRequesting biometric seal (Law XXX)...\u{1b}[0m")
if !authenticate() {
    print("  \u{1b}[91mAuthentication failed. Access denied.\u{1b}[0m")
    print("  \u{1b}[2mLaw XXX: No passwords. Biometrics ONLY.\u{1b}[0m")
    exit(1)
}
print("  \u{1b}[92mSealed. Access granted.\u{1b}[0m")
print()

// ─── Scan Media ──────────────────────────────────

print("  \u{1b}[2mScanning empire media...\u{1b}[0m")

var allItems: [MediaItem] = []

let scanDirs: [(String, Int)] = [
    (L7_DIR + "/icons", 200),
    (HOME + "/Audio", 100),
    (HOME + "/Backup/L7_WAY/rose", 50),
    (HOME + "/Backup/L7_WAY/simulations", 50),
    (HOME + "/Backup/L7_WAY/apps", 50),
    (HOME + "/Desktop", 300),
    (HOME + "/Downloads", 200),
    (HOME + "/Pictures", 100),
]

for (dir, limit) in scanDirs {
    let items = scanDirectory(dir, maxItems: limit)
    if !items.isEmpty {
        let dirName = (dir as NSString).lastPathComponent
        print("    \u{1b}[96m•\u{1b}[0m \(dirName): \(items.count) media files")
    }
    allItems.append(contentsOf: items)
}

// Sort by modified date (newest first)
allItems.sort { $0.modified > $1.modified }

let imageCount = allItems.filter { $0.type == "image" }.count
let audioCount = allItems.filter { $0.type == "audio" }.count
let videoCount = allItems.filter { $0.type == "video" }.count

print()
print("  \u{1b}[1mFound: \(allItems.count) media files\u{1b}[0m")
print("    Images: \(imageCount)  Audio: \(audioCount)  Video: \(videoCount)")
print()

if args.contains("--scan-only") {
    print("  \u{1b}[2mScan complete. Use without --scan-only to generate gallery.\u{1b}[0m")
    exit(0)
}

// ─── Generate Gallery ────────────────────────────

print("  \u{1b}[2mGenerating gallery...\u{1b}[0m")

try? FileManager.default.createDirectory(atPath: GALLERY_DIR, withIntermediateDirectories: true)
let html = generateGallery(allItems)
try? html.write(toFile: GALLERY_HTML, atomically: true, encoding: .utf8)

let htmlSize = (try? FileManager.default.attributesOfItem(atPath: GALLERY_HTML))?[.size] as? Int64 ?? 0
print("  \u{1b}[92mGallery generated:\u{1b}[0m \(GALLERY_HTML) (\(htmlSize / 1024)KB)")

if !args.contains("--no-open") {
    print("  \u{1b}[2mOpening in browser...\u{1b}[0m")
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
    process.arguments = [GALLERY_HTML]
    try? process.run()
    process.waitUntilExit()
}

print()
print("  \u{1b}[93m☉ ☽ ☿ ♀ ♂ ♃ ♄\u{1b}[0m")
print("  \u{1b}[2mAvli Cloud — All rights reserved.\u{1b}[0m")
print("  \u{1b}[2mData cannot leave this device. Law XXX.\u{1b}[0m")
print()
