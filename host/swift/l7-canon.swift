// ══════════════════════════════════════════════════════════════
// L7 CANON — The Empire Database
// Native SQLite. Universal format. Cross-device compatible.
//
// Replaces scattered JSON/YAML/MD with one canonical database.
// Every piece of empire metadata in one queryable file.
//
// Law I    — All flows through the Gateway. No exceptions.
// Law XV   — The Founder has perpetual, unrestricted access.
// Law XXII — Framework FREE, Products LICENSED.
// Law XXX  — Biometrics only. No passwords.
//
// Creator: Alberto Valido Delgado
// System: L7 Universal OS
// License: Proprietary
// ══════════════════════════════════════════════════════════════

import Foundation
import SQLite3
import LocalAuthentication

// ─── Configuration ───────────────────────────────

let L7_DIR = ProcessInfo.processInfo.environment["L7_DIR"]
    ?? NSHomeDirectory() + "/.l7"
let CANON_DIR = L7_DIR + "/canon"
let EMPIRE_DB = CANON_DIR + "/empire.db"
let MANIFEST_DIR = L7_DIR + "/manifest"
let CANON_LOG = CANON_DIR + "/audit.log"
let VERSION = "1.0.0"
let SQLITE_TRANSIENT_PTR = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

// ─── Security: Anti-Debug ───────────────────────
func verifyNotTraced() -> Bool {
    var info = kinfo_proc()
    var size = MemoryLayout<kinfo_proc>.stride
    var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
    let r = sysctl(&mib, 4, &info, &size, nil, 0)
    if r == 0 && (info.kp_proc.p_flag & P_TRACED) != 0 {
        canonLog("SECURITY: Debugger detected — ABORT")
        return false
    }
    return true
}

// ─── Security: Audit Log (permanent, append-only) ───
func canonLog(_ entry: String) {
    let line = "[\(ISO8601DateFormatter().string(from: Date()))] \(entry)\n"
    if let handle = FileHandle(forWritingAtPath: CANON_LOG) {
        handle.seekToEndOfFile()
        handle.write(line.data(using: .utf8)!)
        handle.closeFile()
    } else {
        FileManager.default.createFile(atPath: CANON_LOG, contents: line.data(using: .utf8))
        chmod(CANON_LOG, 0o600)
    }
}

// ─── Security: Biometric ONLY (Law XXX) ───
func authenticateCanon() -> Bool {
    let ctx = LAContext()
    ctx.localizedFallbackTitle = "" // No password fallback
    var err: NSError?
    guard ctx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &err) else {
        canonLog("AUTH_FAIL: Biometrics unavailable")
        return false
    }
    let sem = DispatchSemaphore(value: 0)
    var ok = false
    ctx.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                       localizedReason: "L7 Canon — Empire Database requires your seal") { r, _ in
        ok = r; sem.signal()
    }
    sem.wait()
    canonLog(ok ? "AUTH_OK: Canon access" : "AUTH_FAIL: Biometric denied")
    return ok
}

// ANSI
let R  = "\u{1b}[0m"
let B  = "\u{1b}[1m"
let D  = "\u{1b}[2m"
let RED = "\u{1b}[91m"
let GRN = "\u{1b}[92m"
let YLW = "\u{1b}[93m"
let BLU = "\u{1b}[94m"
let MAG = "\u{1b}[95m"
let CYN = "\u{1b}[96m"

let STAGES = ["nigredo", "albedo", "citrinitas", "rubedo"]
let DOMAINS = ["morph", "work", "salt", "vault"]
let DIM_NAMES = ["Sun", "Moon", "Mercury", "Venus", "Mars", "Jupiter",
                 "Saturn", "Uranus", "Neptune", "Pluto", "N.Node", "S.Node"]

// ─── SQLite Wrapper ──────────────────────────────

class Canon {
    var db: OpaquePointer?
    let path: String

    init(_ path: String) { self.path = path }

    func open() -> Bool {
        let dir = (path as NSString).deletingLastPathComponent
        try? FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
        return sqlite3_open(path, &db) == SQLITE_OK
    }

    func close() {
        if db != nil { sqlite3_close(db); db = nil }
    }

    func exec(_ sql: String) {
        var err: UnsafeMutablePointer<CChar>?
        if sqlite3_exec(db, sql, nil, nil, &err) != SQLITE_OK {
            if let e = err { fputs("  SQL: \(String(cString: e))\n", stderr); sqlite3_free(e) }
        }
    }

    func query(_ sql: String) -> [[String: String]] {
        var stmt: OpaquePointer?
        var results: [[String: String]] = []
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
            var err: UnsafeMutablePointer<CChar>?
            sqlite3_exec(db, "", nil, nil, &err)
            return results
        }
        let cols = sqlite3_column_count(stmt)
        while sqlite3_step(stmt) == SQLITE_ROW {
            var row: [String: String] = [:]
            for i in 0..<cols {
                let name = String(cString: sqlite3_column_name(stmt, i))
                if let val = sqlite3_column_text(stmt, i) {
                    row[name] = String(cString: val)
                }
            }
            results.append(row)
        }
        sqlite3_finalize(stmt)
        return results
    }

    func count(_ table: String) -> Int {
        let r = query("SELECT COUNT(*) as c FROM \(table)")
        return Int(r.first?["c"] ?? "0") ?? 0
    }

    func scalar(_ sql: String) -> String {
        let r = query(sql)
        return r.first?.values.first ?? ""
    }
}

func esc(_ s: String) -> String {
    s.replacingOccurrences(of: "'", with: "''")
}

func pad(_ s: String, _ w: Int) -> String {
    if s.count >= w { return String(s.prefix(w)) }
    return s + String(repeating: " ", count: w - s.count)
}

// ─── Schema ──────────────────────────────────────

func createSchema(_ db: Canon) {
    db.exec("""
    CREATE TABLE IF NOT EXISTS founder (
        id INTEGER PRIMARY KEY, name TEXT NOT NULL, legal_name TEXT NOT NULL,
        email TEXT, github TEXT, created TEXT DEFAULT CURRENT_TIMESTAMP
    );
    CREATE TABLE IF NOT EXISTS aliases (
        id INTEGER PRIMARY KEY AUTOINCREMENT, founder_id INTEGER REFERENCES founder(id),
        alias TEXT NOT NULL UNIQUE, context TEXT, platform TEXT
    );
    CREATE TABLE IF NOT EXISTS products (
        id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL UNIQUE,
        classification TEXT, description TEXT, license TEXT DEFAULT 'L7 Proprietary',
        created TEXT, status TEXT DEFAULT 'placeholder', source_path TEXT,
        price_free TEXT, price_pro TEXT, price_enterprise TEXT,
        pricing_notes TEXT, revenue_model TEXT, domain TEXT DEFAULT 'work',
        publisher TEXT DEFAULT 'Avli Cloud',
        production_seal TEXT,
        license_terms TEXT DEFAULT 'Law XVI sliding scale; Law XV founder perpetual access; Law XXII framework free, products licensed'
    );
    CREATE TABLE IF NOT EXISTS projects (
        id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL UNIQUE,
        origin TEXT, domain TEXT, astrocyte REAL DEFAULT 0.5,
        files INTEGER DEFAULT 0, size INTEGER DEFAULT 0, binaries INTEGER DEFAULT 0,
        coordinate TEXT, signature TEXT, path TEXT
    );
    CREATE TABLE IF NOT EXISTS edges (
        id INTEGER PRIMARY KEY AUTOINCREMENT, source TEXT NOT NULL, target TEXT NOT NULL,
        type TEXT, note TEXT, weight REAL DEFAULT 1.0
    );
    CREATE TABLE IF NOT EXISTS symlinks (
        id INTEGER PRIMARY KEY AUTOINCREMENT, from_path TEXT NOT NULL,
        to_path TEXT NOT NULL, domain TEXT, verified INTEGER DEFAULT 1
    );
    CREATE TABLE IF NOT EXISTS versions (
        id INTEGER PRIMARY KEY AUTOINCREMENT, project TEXT NOT NULL,
        tag TEXT, path TEXT, date TEXT, domain TEXT
    );
    CREATE TABLE IF NOT EXISTS hexagrams (
        id INTEGER PRIMARY KEY, king_wen INTEGER UNIQUE,
        upper_idx INTEGER, lower_idx INTEGER,
        chinese TEXT, english TEXT, weight_role TEXT,
        forge_stage TEXT, primary_dim TEXT, secondary_dim TEXT
    );
    CREATE TABLE IF NOT EXISTS trigrams (
        id INTEGER PRIMARY KEY, name TEXT, symbol TEXT,
        element TEXT, image TEXT, nature TEXT
    );
    CREATE TABLE IF NOT EXISTS ifa_odu (
        id INTEGER PRIMARY KEY, name TEXT, meaning TEXT,
        weight_role TEXT, quality TEXT
    );
    CREATE TABLE IF NOT EXISTS geomantic_figures (
        id INTEGER PRIMARY KEY, name TEXT, planet TEXT,
        neural_role TEXT, quality TEXT
    );
    CREATE TABLE IF NOT EXISTS provenance (
        id INTEGER PRIMARY KEY AUTOINCREMENT, file TEXT NOT NULL,
        hash TEXT, chain_hash TEXT, timestamp TEXT DEFAULT CURRENT_TIMESTAMP,
        signer TEXT DEFAULT 'Alberto Valido Delgado'
    );
    CREATE INDEX IF NOT EXISTS idx_projects_domain ON projects(domain);
    CREATE INDEX IF NOT EXISTS idx_projects_origin ON projects(origin);
    CREATE INDEX IF NOT EXISTS idx_edges_source ON edges(source);
    CREATE INDEX IF NOT EXISTS idx_edges_target ON edges(target);
    CREATE INDEX IF NOT EXISTS idx_products_status ON products(status);
    CREATE TABLE IF NOT EXISTS license_enforcement (
        id INTEGER PRIMARY KEY AUTOINCREMENT, rule TEXT NOT NULL UNIQUE,
        rate REAL, description TEXT, law_reference TEXT
    );
    CREATE TABLE IF NOT EXISTS pseudonym_resolution (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pseudonym TEXT NOT NULL UNIQUE,
        legal_entity TEXT NOT NULL DEFAULT 'Alberto Valido Delgado',
        note TEXT
    );
    CREATE TABLE IF NOT EXISTS sigils (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        sequence TEXT NOT NULL,
        operations TEXT NOT NULL,
        edge_count INTEGER DEFAULT 0,
        coordinate TEXT,
        dominant TEXT,
        quality TEXT,
        arc TEXT,
        q64_address INTEGER,
        hexagram_num INTEGER,
        readable TEXT,
        immutable INTEGER DEFAULT 1,
        founder_only INTEGER DEFAULT 1,
        created TEXT DEFAULT CURRENT_TIMESTAMP
    );
    CREATE TABLE IF NOT EXISTS sigil_edges (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sigil_name TEXT NOT NULL REFERENCES sigils(name),
        edge_idx INTEGER NOT NULL,
        from_op TEXT NOT NULL,
        to_op TEXT NOT NULL,
        weights TEXT
    );
    CREATE TABLE IF NOT EXISTS app_provenance (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        app_name TEXT NOT NULL,
        source TEXT NOT NULL DEFAULT 'Avli Cloud',
        creator TEXT NOT NULL DEFAULT 'Alberto Valido Delgado',
        type TEXT DEFAULT 'app',
        binary_path TEXT,
        binary_size INTEGER,
        architecture TEXT DEFAULT 'arm64',
        compile_date TEXT,
        sigil_name TEXT,
        q64_address INTEGER,
        production_seal TEXT DEFAULT 'RUBEDO',
        license_terms TEXT DEFAULT '12% LICENSE. Not a subscription. 12% on app sales.',
        immutable_engine INTEGER DEFAULT 1,
        founder_only_modification INTEGER DEFAULT 1,
        note TEXT
    );
    CREATE INDEX IF NOT EXISTS idx_sigils_name ON sigils(name);
    CREATE INDEX IF NOT EXISTS idx_provenance_app ON app_provenance(app_name);
    """)
}

// ─── Canonical Data Population ───────────────────

func populateFounder(_ db: Canon) {
    db.exec("""
    INSERT OR IGNORE INTO founder (id, name, legal_name, email, github)
    VALUES (1, 'The Philosopher', 'Alberto Valido Delgado', 'avalia@proton.me', 'avalia1')
    """)
    let aliases: [(String, String, String)] = [
        ("Alberto Valido Delgado", "legal name", "all"),
        ("The Philosopher", "Father / Yod / Fire — title in L7", "l7"),
        ("valido", "surname handle", "general"),
        ("avalia", "primary alias", "general"),
        ("1991", "birth year cipher", "l7"),
        ("avalia1", "github username", "github"),
        ("avalia333", "numeric alias (creation)", "social"),
        ("avalia777", "numeric alias (completion)", "social"),
        ("Avli Cloud", "business entity (pending FL)", "legal"),
    ]
    for (a, c, p) in aliases {
        db.exec("INSERT OR IGNORE INTO aliases (founder_id, alias, context, platform) VALUES (1, '\(esc(a))', '\(esc(c))', '\(esc(p))')")
    }
}

func populateProducts(_ db: Canon) {
    // (name, classification, description, license, created, status, source_path,
    //  price_free, price_pro, price_enterprise, pricing_notes, revenue_model, domain)
    let products: [(String, String, String, String, String, String, String,
                     String, String, String, String, String, String)] = [
        ("Gateway + Forge",
         "Software Engine — Node.js/Swift",
         "The Unified Self and Transmutation Engine. Core of L7. Gateway orchestrates all tools; Forge implements 4-stage transmutation (Nigredo→Albedo→Citrinitas→Rubedo).",
         "L7 Proprietary (Law XVI)", "2026-01", "verified", "Backup/L7_WAY/lib/",
         "Framework free", "$99/mo (Professional)", "$999/mo (Enterprise)",
         "SDK per Law XVI sliding scale", "subscription + revenue share", "work"),

        ("L7 Way Framework",
         "Software Framework — Node.js",
         "Core framework: 19 modules, 11,896 lines. Gateway, Flow engine, Empire server. github.com/avalia1/L7_WAY",
         "L7 Proprietary (Law XVI)", "2026-01-12", "verified", "Backup/L7_WAY/",
         "Non-commercial free", "$100/mo (Email support)", "$1K-$25K one-time + $500/mo",
         "Commercial: 10% profit share", "profit share + support", "work"),

        ("Living Rose",
         "Native macOS App — Swift",
         "Interactive Prima Language Visualization. 22 ops mapped to Hebrew letters/Tarot. 61KB arm64.",
         "L7 Proprietary", "2026-02-28", "verified", "Backup/L7_WAY/rose/",
         "Free (direct download)", "$4.99 (App Store)", "Volume licensing",
         "Phase 1→direct; Phase 3→App Store Q3 2026", "app store + volume", "morph"),

        ("Prima Language",
         "Programming Language — Spec + Compiler",
         "Graph-centric language rooted in Kabbalah/Alchemy/Astrology/Tarot. Programs compile into weighted hypergraph sigils.",
         "L7 Proprietary (Law XVI)", "2026-02", "verified", "Backup/L7_WAY/lib/prima.js",
         "Spec + compiler free", "Per Law XVI", "$10K one-time",
         "Consulting $250/hr; Custom ops $500; Training $5K", "licensing + consulting", "morph"),

        ("Icon Library",
         "Digital Artwork — 119 Icons",
         "Complete icon system: 83 PNG + 36 ICNS. Zero stock art. Codex, Domain, Planetary, Elemental categories.",
         "L7 Proprietary", "2026-02", "verified", "~/.l7/icons/",
         "Bundled free", "$29.99 (PNG+ICNS) / $49.99 (all)", "$99-$999 commercial",
         "Custom icons $50-$2500+", "asset licensing", "work"),

        ("Keykeeper",
         "Security Tool — Shell + Keychain",
         "Gateway-Mediated Credential Management. Biometrics Only (Law XXX). Touch ID, machine UUID, auto-rotation.",
         "L7 Proprietary", "2026-02", "verified", "Backup/L7_WAY/keykeeper",
         "Personal free", "$29.99/yr (Professional)", "$99/yr per seat (Enterprise)",
         "Team $799-$9999/yr; Security review $500/hr", "subscription + consulting", "vault"),

        ("Simulations",
         "Interactive HTML5/Canvas — 5 Simulations",
         "quantum-gravity-proof, solar-hexagram, emerald-tablet-os, shadow-theater, morph-runtime. Zero dependencies.",
         "L7 Proprietary", "2026-02", "verified", "Backup/L7_WAY/simulations/",
         "Academic free", "$500/yr embed", "$2500-$10K exhibition",
         "Educational free-$2000/yr", "exhibition + embed", "morph"),

        ("The Emporium",
         "Web App — HTML5 App Store",
         "46 tools across 8 suites: Spatial XR(18), Meridian(4), Kinesis(4), Resonance(4), Flux(4), Tesseract(4), Herald(4), Codex(4).",
         "L7 Proprietary (Law XVI)", "2026-02-28", "verified", "~/.l7/tools/",
         "Non-commercial free", "$50/mo (Team 10)", "$500/mo (Enterprise)",
         "Marketplace fees: 15% on paid tools", "marketplace + subscription", "work"),

        ("L7 Universal OS",
         "Web App — HTML5/CSS3 OS Interface",
         "Web-based OS: Studio(58K), Infinite Viewer(33K), DB Browser(21K), Time Machine(18K). L7 IS the operating system.",
         "L7 Proprietary", "2026-02", "verified", "/tmp/l7os/universal.html",
         "Personal free (local)", "$9.99/mo (Pro)", "$49.99/mo per seat",
         "Storage $2.99/10GB; On-premises $25K-$75K", "subscription + on-premises", "work"),

        ("L7 Forge",
         "Native arm64 Binary — Swift",
         "On-device quantum computing: Q64 register (262,144 states). Council dialectic. Heart persistence. 266KB binary.",
         "L7 Proprietary", "2026-03-06", "verified", "~/.l7/l7-forge.swift",
         "Included with L7 Way", "Per Law XVI", "Per Law XVI",
         "arm64-apple-macos14.0", "bundled", "work"),

        ("L7 Canon",
         "Native arm64 Binary — Swift/SQLite",
         "Empire database engine. SQLite registry replacing scattered JSON/YAML/MD. Product catalog, project index, edge map, provenance.",
         "L7 Proprietary", "2026-03-06", "verified", "~/.l7/l7-canon.swift",
         "Included with L7 Way", "Per Law XVI", "Per Law XVI",
         "The canonical format for L7", "bundled", "work"),

        ("DIAL-Training",
         "Native macOS App — Swift",
         "DIAL Training dashboard. arm64 binary (107KB) + Public variant (123KB).",
         "L7 Proprietary", "2026-02", "compiled", "Backup/L7_WAY/apps/DIAL-Training",
         "Internal", "Per Law XVI", "Per Law XVI",
         "Internal + public variants", "licensing", "work"),

        ("L7-Resonance-Studio",
         "Native macOS App — Swift",
         "Resonance studio for L7 harmonics. arm64 binary (124KB) + Public variant.",
         "L7 Proprietary", "2026-02", "compiled", "Backup/L7_WAY/apps/L7-Resonance-Studio",
         "Internal", "Per Law XVI", "Per Law XVI",
         "Internal + public variants", "licensing", "morph"),

        ("NCLS-Dashboard",
         "Native macOS App — Swift",
         "NCLS outreach dashboard. arm64 binary (123KB) + Public variant.",
         "L7 Proprietary", "2026-02", "compiled", "Backup/L7_WAY/apps/NCLS-Dashboard",
         "Internal", "Per Law XVI", "Per Law XVI",
         "Internal + public variants", "licensing", "work"),

        // Placeholder products — reserved namespace
        ("AI Cluster", "Reserved", "AI cluster computing infrastructure", "L7 Proprietary", "", "placeholder", "", "", "", "", "", "", "work"),
        ("AVLI Cloud", "Reserved", "Cloud infrastructure platform (Avli Cloud)", "L7 Proprietary", "", "placeholder", "", "", "", "", "", "", "work"),
        ("Browsy", "Reserved", "Browser-based tool/interface", "L7 Proprietary", "", "placeholder", "", "", "", "", "", "", "work"),
        ("Fracttalix", "Reserved", "Fractal visualization/computation engine", "L7 Proprietary", "", "placeholder", "", "", "", "", "", "", "morph"),
        ("LTA-7 Framework", "Reserved", "L7 Technology Architecture framework", "L7 Proprietary", "", "placeholder", "", "", "", "", "", "", "work"),
        ("NCLS Pipeline", "Reserved", "NCLS data processing pipeline", "L7 Proprietary", "", "placeholder", "", "", "", "", "", "", "work"),
        ("PERSI", "Reserved", "Persistence/storage engine", "L7 Proprietary", "", "placeholder", "", "", "", "", "", "", "work"),
        ("Tri-Model CLI", "Reserved", "Multi-model CLI interface (Claude/Gemini/Grok)", "L7 Proprietary", "", "placeholder", "", "", "", "", "", "", "work"),
    ]
    for p in products {
        let seal: String
        switch p.5 {  // status
        case "verified":
            seal = "RUBEDO — Transmuted through Empire Forge. Production sealed \(p.4). Publisher: Avli Cloud."
        case "compiled":
            seal = "RUBEDO — Compiled arm64 binary. Production sealed \(p.4). Publisher: Avli Cloud."
        default:
            seal = "NIGREDO — Reserved namespace. Awaiting transmutation."
        }
        db.exec("""
        INSERT OR IGNORE INTO products (name, classification, description, license, created, status, source_path,
            price_free, price_pro, price_enterprise, pricing_notes, revenue_model, domain,
            publisher, production_seal, license_terms)
        VALUES ('\(esc(p.0))','\(esc(p.1))','\(esc(p.2))','\(esc(p.3))','\(esc(p.4))','\(esc(p.5))','\(esc(p.6))',
                '\(esc(p.7))','\(esc(p.8))','\(esc(p.9))','\(esc(p.10))','\(esc(p.11))','\(esc(p.12))',
                'Avli Cloud', '\(esc(seal))',
                '12% LICENSE on OS and app sales. Not a subscription. Law XV: Founder perpetual free access. Law XXX: Biometrics only. All pseudonyms resolve to Alberto Valido Delgado.')
        """)
    }
}

func populateHexagrams(_ db: Canon) {
    // All 64 hexagrams: (KW#, upper, lower, chinese, english, role, stageIdx, primaryDim, secondaryDim)
    let data: [(Int,Int,Int,String,String,String,Int,Int,Int)] = [
        (1,7,7,"Qian","The Creative","attention_query",0,0,7),
        (2,0,0,"Kun","The Receptive","token_embedding",0,1,3),
        (3,2,1,"Zhun","Difficulty at Beginning","cross_attention_init",3,9,10),
        (4,4,2,"Meng","Youthful Folly","positional_encoding",0,11,2),
        (5,2,7,"Xu","Waiting","attention_mask",3,3,8),
        (6,7,2,"Song","Conflict","adversarial_robustness",3,4,9),
        (7,0,2,"Shi","The Army","vocab_projection",0,0,4),
        (8,2,0,"Bi","Holding Together","embedding_norm",0,1,8),
        (9,6,7,"Xiao Chu","Small Taming","small_adapter",2,5,7),
        (10,7,3,"Lu","Treading","attention_bias",1,4,6),
        (11,0,7,"Tai","Peace","layer_norm",1,8,3),
        (12,7,0,"Pi","Standstill","frozen_embedding",3,3,11),
        (13,7,5,"Tong Ren","Fellowship","attention_multihead",1,8,0),
        (14,5,7,"Da You","Great Possession","output_projection",3,6,0),
        (15,0,4,"Qian","Modesty","rms_norm",1,5,8),
        (16,1,0,"Yu","Enthusiasm","rotary_encoding",0,10,2),
        (17,3,1,"Sui","Following","causal_mask",1,10,11),
        (18,4,6,"Gu","Work on Decayed","weight_decay",1,9,11),
        (19,0,3,"Lin","Approach","warmup_schedule",0,10,3),
        (20,6,0,"Guan","Contemplation","self_attention_early",1,8,1),
        (21,5,1,"Shi He","Biting Through","activation_function",2,9,0),
        (22,4,5,"Bi","Grace","layer_scale",1,2,5),
        (23,4,0,"Bo","Splitting Apart","dropout",1,9,4),
        (24,0,1,"Fu","Return","residual_connection",2,11,10),
        (25,7,1,"Wu Wang","Innocence","weight_init",0,7,0),
        (26,4,7,"Da Chu","Great Taming","large_adapter",2,0,5),
        (27,4,1,"Yi","Nourishment","adapter_down",2,1,5),
        (28,3,6,"Da Guo","Great Excess","adapter_up",2,6,9),
        (29,2,2,"Kan","The Abysmal","hidden_state",3,1,8),
        (30,5,5,"Li","The Clinging","attention_score",1,0,9),
        (31,3,4,"Xian","Influence","attention_key",1,7,8),
        (32,1,6,"Heng","Duration","ffn_down",2,3,6),
        (33,7,4,"Dun","Retreat","negative_bias",3,4,11),
        (34,1,7,"Da Zhuang","Great Power","rotary_base_freq",0,0,4),
        (35,5,0,"Jin","Progress","logits",3,6,10),
        (36,0,5,"Ming Yi","Darkening of Light","masked_attention",1,4,8),
        (37,6,5,"Jia Ren","The Family","attention_output",1,6,8),
        (38,5,3,"Kui","Opposition","cross_attention",1,9,2),
        (39,2,4,"Jian","Obstruction","regularization",1,4,5),
        (40,1,2,"Jie","Deliverance","gradient_checkpoint",2,9,10),
        (41,4,3,"Sun","Decrease","pruning",1,9,5),
        (42,6,1,"Yi","Increase","ffn_residual",2,0,10),
        (43,3,7,"Guai","Breakthrough","token_selection",3,7,6),
        (44,7,6,"Gou","Coming to Meet","input_projection",0,1,7),
        (45,3,0,"Cui","Gathering Together","output_softmax",3,6,1),
        (46,0,6,"Sheng","Pushing Upward","upsample",2,10,5),
        (47,3,2,"Kun","Oppression","quantization_loss",3,3,4),
        (48,2,6,"Jing","The Well","kv_cache",3,11,1),
        (49,3,5,"Ge","Revolution","ffn_up",2,9,0),
        (50,5,6,"Ding","The Cauldron","ffn_gate",2,0,9),
        (51,1,1,"Zhen","The Arousing","frequency_component",0,2,10),
        (52,4,4,"Gen","Keeping Still","frozen_weights",3,3,4),
        (53,6,4,"Jian","Development","progressive_training",2,10,3),
        (54,1,3,"Gui Mei","Marrying Maiden","cross_model_transfer",2,7,9),
        (55,1,5,"Feng","Abundance","wide_ffn",2,5,0),
        (56,5,4,"Lu","The Wanderer","attention_head_specific",1,2,10),
        (57,6,6,"Xun","The Gentle","gradient_flow",2,10,8),
        (58,3,3,"Dui","The Joyous","attention_value",1,7,0),
        (59,6,2,"Huan","Dispersion","attention_dropout",1,9,2),
        (60,2,3,"Jie","Limitation","context_window",1,4,3),
        (61,6,3,"Zhong Fu","Inner Truth","alignment_score",1,8,7),
        (62,1,4,"Xiao Guo","Small Excess","bias_term",2,5,6),
        (63,2,5,"Ji Ji","After Completion","post_attention_norm",3,6,11),
        (64,5,2,"Wei Ji","Before Completion","pre_ffn_norm",3,10,0),
    ]
    db.exec("BEGIN TRANSACTION")
    for h in data {
        let stage = STAGES[h.6]
        let pDim = DIM_NAMES[h.7]
        let sDim = DIM_NAMES[h.8]
        db.exec("""
        INSERT OR IGNORE INTO hexagrams (id, king_wen, upper_idx, lower_idx, chinese, english, weight_role, forge_stage, primary_dim, secondary_dim)
        VALUES (\(h.0), \(h.0), \(h.1), \(h.2), '\(esc(h.3))', '\(esc(h.4))', '\(esc(h.5))', '\(stage)', '\(pDim)', '\(sDim)')
        """)
    }
    db.exec("COMMIT")
}

func populateTrigrams(_ db: Canon) {
    let data: [(Int, String, String, String, String, String)] = [
        (0, "Kun",  "☷", "earth", "Earth",    "receptive"),
        (1, "Zhen", "☳", "wood",  "Thunder",  "arousing"),
        (2, "Kan",  "☵", "water", "Water",    "abysmal"),
        (3, "Dui",  "☱", "metal", "Lake",     "joyous"),
        (4, "Gen",  "☶", "earth", "Mountain", "still"),
        (5, "Li",   "☲", "fire",  "Fire",     "clinging"),
        (6, "Xun",  "☴", "wood",  "Wind",     "gentle"),
        (7, "Qian", "☰", "metal", "Heaven",   "creative"),
    ]
    for t in data {
        db.exec("INSERT OR IGNORE INTO trigrams VALUES (\(t.0), '\(t.1)', '\(t.2)', '\(t.3)', '\(t.4)', '\(t.5)')")
    }
}

func populateIfaOdu(_ db: Canon) {
    let data: [(Int, String, String, String, String)] = [
        (0,  "Ogbe",     "light, clarity, purity",          "primary_weights",     "strongest signal"),
        (1,  "Oyeku",    "darkness, mystery, potential",     "bias_terms",          "hidden influence"),
        (2,  "Iwori",    "inversion, seeing within",        "inverse_weights",     "reflection"),
        (3,  "Odi",      "blockage, gestation",             "gate_weights",        "selective passage"),
        (4,  "Irosun",   "ancestry, vision",                "attention_weights",   "backward-looking"),
        (5,  "Owonrin",  "chaos, transformation",           "transform_weights",   "unpredictable"),
        (6,  "Obara",    "abundance, generosity",           "expansion_weights",   "amplifying"),
        (7,  "Okanran",  "conflict, assertion",             "contrastive_weights", "discriminating"),
        (8,  "Ogunda",   "clearing, path-making",           "projection_weights",  "directional"),
        (9,  "Osa",      "change, swift movement",          "residual_weights",    "transitional"),
        (10, "Ika",      "limitation, boundary",            "norm_weights",        "constraining"),
        (11, "Oturupon", "sickness, immunity",              "dropout_mask",        "selective removal"),
        (12, "Otura",    "wisdom, spiritual insight",       "embedding_weights",   "deep encoding"),
        (13, "Irete",    "pressing forward, printing",      "output_weights",      "manifesting"),
        (14, "Ose",      "conquest, achievement",           "score_weights",       "evaluating"),
        (15, "Ofun",     "death, rebirth, completion",      "final_weights",       "terminal"),
    ]
    for o in data {
        db.exec("INSERT OR IGNORE INTO ifa_odu VALUES (\(o.0), '\(esc(o.1))', '\(esc(o.2))', '\(esc(o.3))', '\(esc(o.4))')")
    }
}

func populateGeomantic(_ db: Canon) {
    let data: [(Int, String, String, String, String)] = [
        (0,  "Via",            "Moon",    "data_flow",        "mobile"),
        (1,  "Cauda Draconis", "S.Node",  "output_gate",      "exit"),
        (2,  "Puer",           "Mars",    "forward_pass",     "active"),
        (3,  "Fortuna Minor",  "Sun",     "shortcut",         "swift"),
        (4,  "Puella",         "Venus",   "value_projection", "receptive"),
        (5,  "Amissio",        "Venus",   "dropout",          "losing"),
        (6,  "Carcer",         "Saturn",  "attention_mask",   "bound"),
        (7,  "Laetitia",       "Jupiter", "upscale",          "rising"),
        (8,  "Caput Draconis", "N.Node",  "input_gate",       "entry"),
        (9,  "Conjunctio",     "Mercury", "concatenation",    "joining"),
        (10, "Acquisitio",     "Jupiter", "residual_add",     "gaining"),
        (11, "Rubeus",         "Mars",    "activation",       "volatile"),
        (12, "Fortuna Major",  "Sun",     "layer_norm",       "stable"),
        (13, "Albus",          "Mercury", "softmax",          "clear"),
        (14, "Tristitia",      "Saturn",  "downscale",        "sinking"),
        (15, "Populus",        "Moon",    "batch_norm",       "passive"),
    ]
    for g in data {
        db.exec("INSERT OR IGNORE INTO geomantic_figures VALUES (\(g.0), '\(esc(g.1))', '\(esc(g.2))', '\(esc(g.3))', '\(esc(g.4))')")
    }
}

func populateCoreSigils(_ db: Canon) {
    // The 5 core sigils — immutable, founder-only (Law XLV)
    // Sigil Engine is IMMUTABLE. Only Alberto Valido Delgado may modify.
    let sigils: [(String, String, String, Int, String, String, String, String)] = [
        ("redemption", "\u{05D0}\u{05DE}\u{05D6}\u{05D8}\u{05E2}\u{05D4}\u{05DC}\u{05EA}",
         "invoke,decompose,verify,redeem,quarantine,publish,audit,complete", 7,
         "capability=6,security=6", "Capricorn", "citrinitas_to_rubedo",
         "invoke (Begin from nothing) \u{2192} decompose (Break into atoms) \u{2192} verify (Authenticate) \u{2192} redeem (Transmute threat) \u{2192} quarantine (Isolate threat) \u{2192} publish (Stabilize in .work) \u{2192} audit (Log and trace) \u{2192} complete (Deliver)"),

        ("creation", "\u{05D0}\u{05D3}\u{05D1}\u{05D4}\u{05EA}",
         "invoke,dream,transmute,publish,complete", 4,
         "transformation=7,presentation=6", "Pisces", "citrinitas_to_rubedo",
         "invoke (Begin from nothing) \u{2192} dream (Enter .morph) \u{2192} transmute (Pass through forge) \u{2192} publish (Stabilize in .work) \u{2192} complete (Deliver)"),

        ("dreaming", "\u{05D3}\u{05D9}\u{05E7}\u{05E8}\u{05D1}\u{05D4}",
         "dream,reflect,speculate,illuminate,transmute,publish", 5,
         "transformation=7,output=6", "Pisces", "citrinitas_to_rubedo",
         "dream (Enter .morph) \u{2192} reflect (Self-examine) \u{2192} speculate (Explore shadows) \u{2192} illuminate (Clarify) \u{2192} transmute (Pass through forge) \u{2192} publish (Stabilize in .work)"),

        ("boot", "\u{05D0}\u{05D9}\u{05DE}\u{05E1}\u{05D3}\u{05E8}\u{05D5}\u{05EA}",
         "invoke,reflect,decompose,translate,dream,illuminate,bind,complete", 7,
         "transformation=7,output=6", "Pisces", "citrinitas_to_rubedo",
         "invoke (Begin from nothing) \u{2192} reflect (Self-examine) \u{2192} decompose (Break into atoms) \u{2192} translate (Mediate between systems) \u{2192} dream (Enter .morph) \u{2192} illuminate (Clarify) \u{2192} bind (Apply law) \u{2192} complete (Deliver)"),

        ("sentinel", "\u{05D0}\u{05D6}\u{05D2}\u{05DC}\u{05EA}",
         "invoke,verify,seal,audit,complete", 4,
         "security=8,detail=7", "Leo", "citrinitas_to_rubedo",
         "invoke (Begin from nothing) \u{2192} verify (Authenticate) \u{2192} seal (Encrypt, make invisible) \u{2192} audit (Log and trace) \u{2192} complete (Deliver)")
    ]

    db.exec("BEGIN TRANSACTION")
    for s in sigils {
        db.exec("""
        INSERT OR IGNORE INTO sigils (name, sequence, operations, edge_count, dominant, quality, arc, readable, immutable, founder_only)
        VALUES ('\(esc(s.0))', '\(esc(s.1))', '\(esc(s.2))', \(s.3), '\(esc(s.4))', '\(esc(s.5))', '\(esc(s.6))', '\(esc(s.7))', 1, 1)
        """)
    }
    db.exec("COMMIT")
}

func populateAppProvenance(_ db: Canon) {
    // ALL apps and tools trace to Avli Cloud / Alberto Valido Delgado
    // The sigil engine is immutable — only the Founder may modify
    let apps: [(String, String, String, String, String, String)] = [
        ("L7 Forge",          "app",  "~/.l7/l7-forge",          "arm64", "2026-03-06", "sentinel"),
        ("L7 Canon",          "app",  "~/.l7/l7-canon",          "arm64", "2026-03-06", "redemption"),
        ("L7 Gallery",        "app",  "~/.l7/l7-gallery",        "arm64", "2026-03-06", "creation"),
        ("Living Rose",       "app",  "Backup/L7_WAY/rose/LivingRose", "arm64", "2026-02-28", "creation"),
        ("Prima VM",          "app",  "Backup/L7_WAY/vm/prima",  "arm64", "2026-02-28", "boot"),
        ("Gateway",           "engine", "Backup/L7_WAY/lib/gateway.js", "node", "2026-01-12", "redemption"),
        ("Forge Engine",      "engine", "Backup/L7_WAY/lib/forge.js", "node", "2026-01-12", "redemption"),
        ("Prima Compiler",    "engine", "Backup/L7_WAY/lib/prima.js", "node", "2026-02-28", "creation"),
        ("Dodecahedron",      "engine", "Backup/L7_WAY/lib/dodecahedron.js", "node", "2026-02-28", "boot"),
        ("Hexagrams/Q64",     "engine", "Backup/L7_WAY/lib/hexagrams.js", "node", "2026-02-28", "boot"),
        ("Polarity Council",  "engine", "Backup/L7_WAY/lib/polarity.js", "node", "2026-02-28", "dreaming"),
        ("DIAL-Training",     "app",  "Backup/L7_WAY/apps/DIAL-Training", "arm64", "2026-02", "sentinel"),
        ("NCLS-Dashboard",    "app",  "Backup/L7_WAY/apps/NCLS-Dashboard", "arm64", "2026-02", "sentinel"),
        ("L7-Resonance-Studio","app", "Backup/L7_WAY/apps/L7-Resonance-Studio", "arm64", "2026-02", "dreaming"),
        ("The Emporium",      "webapp", "/tmp/l7os/emporium.html", "html5", "2026-02-28", "creation"),
        ("Universal OS",      "webapp", "/tmp/l7os/universal.html", "html5", "2026-02", "boot"),
        ("Keykeeper",         "tool", "Backup/L7_WAY/keykeeper", "shell", "2026-02", "sentinel"),
        ("Vault",             "tool", "Backup/L7_WAY/vault",     "shell", "2026-02", "sentinel"),
        ("quantum-gravity-proof", "simulation", "Backup/L7_WAY/simulations/quantum-gravity-proof.html", "html5", "2026-02", "dreaming"),
        ("solar-hexagram",    "simulation", "Backup/L7_WAY/simulations/solar-hexagram.html", "html5", "2026-02", "dreaming"),
        ("emerald-tablet-os", "simulation", "Backup/L7_WAY/simulations/emerald-tablet-os.html", "html5", "2026-02", "creation"),
        ("shadow-theater",    "simulation", "Backup/L7_WAY/simulations/shadow-theater.html", "html5", "2026-02", "dreaming"),
        ("morph-runtime",     "simulation", "Backup/L7_WAY/simulations/morph-runtime.html", "html5", "2026-02", "creation"),
        ("scribe",            "simulation", "Backup/L7_WAY/simulations/scribe.html", "html5", "2026-03", "creation"),
    ]

    db.exec("BEGIN TRANSACTION")
    for a in apps {
        db.exec("""
        INSERT OR IGNORE INTO app_provenance (app_name, type, binary_path, architecture, compile_date, sigil_name,
            source, creator, production_seal, license_terms, immutable_engine, founder_only_modification)
        VALUES ('\(esc(a.0))', '\(esc(a.1))', '\(esc(a.2))', '\(esc(a.3))', '\(esc(a.4))', '\(esc(a.5))',
                'Avli Cloud', 'Alberto Valido Delgado', 'RUBEDO',
                '12% LICENSE on OS and app sales. Not a subscription. Sigil engine immutable. Only modifiable by Founder (Law XV).',
                1, 1)
        """)
    }
    db.exec("COMMIT")
}

// ─── JSON Manifest Import ────────────────────────

func loadJSON(_ filename: String) -> Any? {
    let path = MANIFEST_DIR + "/" + filename
    guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else { return nil }
    return try? JSONSerialization.jsonObject(with: data)
}

func importProjects(_ db: Canon) {
    guard let dict = loadJSON("PROJECT_INDEX.json") as? [String: Any] else {
        print("  \(D)No PROJECT_INDEX.json found\(R)")
        return
    }
    db.exec("BEGIN TRANSACTION")
    var count = 0
    for (name, info) in dict {
        guard let p = info as? [String: Any] else { continue }
        let origin = (p["origin"] as? String) ?? "UNKNOWN"
        let domain = (p["domain"] as? String) ?? "work"
        let astrocyte = (p["astrocyte"] as? Double) ?? 0.5
        let files = (p["files"] as? Int) ?? 0
        let size = (p["size"] as? Int64) ?? Int64((p["size"] as? Double) ?? 0)
        let binaries = (p["binaries"] as? Int) ?? 0
        let coord: String
        if let arr = p["coordinate"] as? [Any] {
            coord = "[" + arr.map { "\($0)" }.joined(separator: ",") + "]"
        } else { coord = "" }
        let sig = (p["signature"] as? String) ?? ""
        db.exec("""
        INSERT OR IGNORE INTO projects (name, origin, domain, astrocyte, files, size, binaries, coordinate, signature)
        VALUES ('\(esc(name))', '\(esc(origin))', '\(esc(domain))', \(astrocyte), \(files), \(size), \(binaries), '\(coord)', '\(esc(sig))')
        """)
        count += 1
    }
    db.exec("COMMIT")
    print("  Imported \(count) projects")
}

func importEdges(_ db: Canon) {
    guard let dict = loadJSON("EDGE_MAP.json") as? [String: Any] else {
        print("  \(D)No EDGE_MAP.json found\(R)")
        return
    }
    db.exec("BEGIN TRANSACTION")
    var count = 0

    // Core module imports
    if let core = dict["core_modules"] as? [String: Any],
       let imports = core["imports"] as? [String: Any] {
        for (modName, modInfo) in imports {
            if let info = modInfo as? [String: Any],
               let deps = info["imports"] as? [String] {
                for dep in deps {
                    db.exec("INSERT INTO edges (source, target, type, note) VALUES ('\(esc(modName))', '\(esc(dep))', 'import', 'core module dependency')")
                    count += 1
                }
            }
        }
    }

    // Content references
    if let content = dict["content_references"] as? [String: Any],
       let edges = content["edges"] as? [[String: Any]] {
        for e in edges {
            let from = (e["from"] as? String) ?? ""
            let to = (e["to"] as? String) ?? ""
            let type = (e["type"] as? String) ?? "reference"
            let note = (e["note"] as? String) ?? ""
            db.exec("INSERT INTO edges (source, target, type, note) VALUES ('\(esc(from))', '\(esc(to))', '\(esc(type))', '\(esc(note))')")
            count += 1
        }
    }

    // Symlinks
    if let sym = dict["symlinks"] as? [String: Any],
       let byDomain = sym["by_domain"] as? [String: Any] {
        for (domain, links) in byDomain {
            if let linkArr = links as? [[String: Any]] {
                for link in linkArr {
                    let from = (link["from"] as? String) ?? ""
                    let to = (link["to"] as? String) ?? ""
                    db.exec("INSERT OR IGNORE INTO symlinks (from_path, to_path, domain) VALUES ('\(esc(from))', '\(esc(to))', '\(esc(domain))')")
                    // Also add as edge
                    db.exec("INSERT INTO edges (source, target, type, note) VALUES ('\(esc(from))', '\(esc(to))', 'symlink', '\(esc(domain)) domain')")
                    count += 1
                }
            }
        }
    }

    // Version chains
    if let vc = dict["version_chains"] as? [String: Any],
       let chains = vc["chains"] as? [[String: Any]] {
        for chain in chains {
            let project = (chain["project"] as? String) ?? ""
            if let vers = chain["versions"] as? [[String: Any]] {
                var prevTag = ""
                for v in vers {
                    let tag = (v["tag"] as? String) ?? ""
                    let path = (v["path"] as? String) ?? ""
                    let date = (v["date"] as? String) ?? ""
                    let domain = (v["domain"] as? String) ?? "salt"
                    db.exec("INSERT INTO versions (project, tag, path, date, domain) VALUES ('\(esc(project))', '\(esc(tag))', '\(esc(path))', '\(esc(date))', '\(esc(domain))')")
                    if !prevTag.isEmpty {
                        db.exec("INSERT INTO edges (source, target, type, note) VALUES ('\(esc(project)):\(esc(prevTag))', '\(esc(project)):\(esc(tag))', 'version_chain', 'temporal sequence')")
                        count += 1
                    }
                    prevTag = tag
                }
            }
        }
    }

    // Shared dependencies
    if let shared = dict["shared_dependencies"] as? [String: Any],
       let packages = shared["packages"] as? [[String: Any]] {
        for pkg in packages {
            let name = (pkg["name"] as? String) ?? ""
            if let projects = pkg["projects"] as? [String] {
                for proj in projects {
                    db.exec("INSERT INTO edges (source, target, type, note) VALUES ('\(esc(proj))', '\(esc(name))', 'shared_dependency', 'npm package')")
                    count += 1
                }
            }
        }
    }

    db.exec("COMMIT")
    print("  Imported \(count) edges")
}

// ─── Display Functions ───────────────────────────

func showBanner() {
    print("""
    \(B)\(CYN)
    ╔══════════════════════════════════════════════╗
    ║     L7 EMPIRE CANON — Universal Registry    ║
    ╚══════════════════════════════════════════════╝\(R)
    """)
}

func showStats(_ db: Canon) {
    let projects = db.count("projects")
    let products = db.count("products")
    let edges = db.count("edges")
    let hexagrams = db.count("hexagrams")
    let aliases = db.count("aliases")
    let symlinks = db.count("symlinks")
    let versions = db.count("versions")
    let trigrams = db.count("trigrams")
    let odu = db.count("ifa_odu")
    let geo = db.count("geomantic_figures")

    let verifiedProducts = db.query("SELECT COUNT(*) as c FROM products WHERE status = 'verified'")
    let verified = Int(verifiedProducts.first?["c"] ?? "0") ?? 0
    let placeholders = db.query("SELECT COUNT(*) as c FROM products WHERE status = 'placeholder'")
    let placeholder = Int(placeholders.first?["c"] ?? "0") ?? 0

    let domainCounts = db.query("SELECT domain, COUNT(*) as c FROM projects GROUP BY domain ORDER BY domain")

    let empireCount = db.query("SELECT COUNT(*) as c FROM projects WHERE origin = 'EMPIRE'")
    let empire = Int(empireCount.first?["c"] ?? "0") ?? 0
    let foreignCount = db.query("SELECT COUNT(*) as c FROM projects WHERE origin = 'FOREIGN'")
    let foreign = Int(foreignCount.first?["c"] ?? "0") ?? 0

    print("""

    \(B)Empire Statistics\(R)
    \(D)─────────────────────────────────────────\(R)
    \(CYN)Projects:\(R)     \(B)\(projects)\(R)  \(D)(\(empire) Empire, \(foreign) Foreign)\(R)
    \(CYN)Products:\(R)     \(B)\(products)\(R)  \(D)(\(verified) verified, \(placeholder) placeholder)\(R)
    \(CYN)Edges:\(R)        \(B)\(edges)\(R)
    \(CYN)Hexagrams:\(R)    \(B)\(hexagrams)\(R)  \(D)(+ \(trigrams) trigrams, \(odu) Odu, \(geo) geomantic)\(R)
    \(CYN)Aliases:\(R)      \(B)\(aliases)\(R)
    \(CYN)Symlinks:\(R)     \(B)\(symlinks)\(R)
    \(CYN)Versions:\(R)     \(B)\(versions)\(R)

    \(B)Domains:\(R)
    """)
    for d in domainCounts {
        let domain = d["domain"] ?? "?"
        let count = d["c"] ?? "0"
        let icon: String
        switch domain {
            case "morph": icon = "\(MAG)◆\(R)"
            case "work":  icon = "\(GRN)◆\(R)"
            case "salt":  icon = "\(YLW)◆\(R)"
            case "vault": icon = "\(RED)◆\(R)"
            default:      icon = "◆"
        }
        print("      \(icon) \(domain): \(count) projects")
    }

    let sigils = db.count("sigils")
    let provenance = db.count("app_provenance")

    if sigils > 0 || provenance > 0 {
        print("\n    \(B)Provenance & Sigils:\(R)")
        if sigils > 0 { print("    \(MAG)Sigils:\(R)       \(B)\(sigils)\(R)  \(D)(immutable, founder-only)\(R)") }
        if provenance > 0 { print("    \(MAG)Provenance:\(R)   \(B)\(provenance)\(R)  \(D)(all → Avli Cloud)\(R)") }
    }

    let sizeResult = db.query("SELECT SUM(size) as s FROM projects")
    if let totalSize = Int64(sizeResult.first?["s"] ?? "0") {
        let gb = Double(totalSize) / 1_073_741_824
        print("\n    \(D)Total indexed: \(String(format: "%.1f", gb)) GB\(R)")
    }
    print("    \(D)Database: \(EMPIRE_DB)\(R)")
    print()
}

func showProducts(_ db: Canon) {
    let products = db.query("SELECT name, status, classification, price_free, price_pro, price_enterprise, domain FROM products ORDER BY status DESC, name")
    print("\n    \(B)Product Catalog — \(products.count) Products\(R)")
    print("    \(D)─────────────────────────────────────────────────────────────────────────\(R)")
    print("    \(D)\(pad("NAME",22)) \(pad("STATUS",10)) \(pad("CLASSIFICATION",28)) \(pad("FREE TIER",14))\(R)")
    print("    \(D)─────────────────────────────────────────────────────────────────────────\(R)")
    for p in products {
        let name = p["name"] ?? ""
        let status = p["status"] ?? ""
        let cls = p["classification"] ?? ""
        let free = p["price_free"] ?? ""
        let statusColor = status == "verified" ? GRN : (status == "compiled" ? BLU : D)
        print("    \(statusColor)\(pad(name,22))\(R) \(pad(status,10)) \(pad(cls,28)) \(pad(free,14))")
    }
    print()
}

func showProductDetail(_ db: Canon, _ name: String) {
    let results = db.query("SELECT * FROM products WHERE name LIKE '%\(esc(name))%' LIMIT 1")
    guard let p = results.first else {
        print("  Product '\(name)' not found. Try: products")
        return
    }
    print("""

    \(B)\(CYN)\(p["name"] ?? "")\(R)
    \(D)Published by \(B)\(p["publisher"] ?? "Avli Cloud")\(R)
    \(D)─────────────────────────────────────────\(R)
    \(B)Classification:\(R)  \(p["classification"] ?? "")
    \(B)Status:\(R)          \(p["status"] ?? "")
    \(B)Created:\(R)         \(p["created"] ?? "")
    \(B)Domain:\(R)          \(p["domain"] ?? "")
    \(B)License:\(R)         \(p["license"] ?? "")
    \(B)Source:\(R)          \(p["source_path"] ?? "")

    \(B)Description:\(R)
      \(p["description"] ?? "")

    \(B)Pricing:\(R)
      Free:       \(p["price_free"] ?? "—")
      Pro:        \(p["price_pro"] ?? "—")
      Enterprise: \(p["price_enterprise"] ?? "—")

    \(B)Notes:\(R)           \(p["pricing_notes"] ?? "")
    \(B)Revenue Model:\(R)   \(p["revenue_model"] ?? "")

    \(B)\(GRN)Production Seal:\(R)
      \(p["production_seal"] ?? "—")

    \(B)License Terms:\(R)
      \(p["license_terms"] ?? "—")
    """)
}

func showProjects(_ db: Canon) {
    let projects = db.query("SELECT name, origin, domain, astrocyte, files, coordinate FROM projects ORDER BY domain, name")
    print("\n    \(B)Project Index — \(projects.count) Projects\(R)")
    print("    \(D)─────────────────────────────────────────────────────────────\(R)")
    print("    \(D)\(pad("NAME",24)) \(pad("ORIGIN",8)) \(pad("DOMAIN",6)) \(pad("ASTRO",6)) FILES\(R)")
    print("    \(D)─────────────────────────────────────────────────────────────\(R)")
    for p in projects {
        let name = String((p["name"] ?? "").prefix(24))
        let origin = p["origin"] ?? ""
        let domain = p["domain"] ?? ""
        let astro = p["astrocyte"] ?? ""
        let files = p["files"] ?? "0"
        let originColor = origin == "EMPIRE" ? GRN : (origin == "FOREIGN" ? YLW : D)
        print("    \(originColor)\(pad(name,24))\(R) \(pad(origin,8)) \(pad(domain,6)) \(pad(astro,6)) \(files)")
    }
    print()
}

func showProjectDetail(_ db: Canon, _ name: String) {
    let results = db.query("SELECT * FROM projects WHERE name LIKE '%\(esc(name))%' LIMIT 1")
    guard let p = results.first else {
        print("  Project '\(name)' not found. Try: projects")
        return
    }
    let edges = db.query("SELECT * FROM edges WHERE source LIKE '%\(esc(p["name"] ?? ""))%' OR target LIKE '%\(esc(p["name"] ?? ""))%' LIMIT 10")
    print("""

    \(B)\(CYN)\(p["name"] ?? "")\(R)
    \(D)─────────────────────────────────────────\(R)
    \(B)Origin:\(R)     \(p["origin"] ?? "")
    \(B)Domain:\(R)     \(p["domain"] ?? "")
    \(B)Astrocyte:\(R)  \(p["astrocyte"] ?? "")
    \(B)Files:\(R)      \(p["files"] ?? "0")
    \(B)Size:\(R)       \(formatBytes(Int64(p["size"] ?? "0") ?? 0))
    \(B)Coordinate:\(R) \(p["coordinate"] ?? "")
    \(B)Signature:\(R)  \(p["signature"] ?? "")
    """)
    if !edges.isEmpty {
        print("    \(B)Edges:\(R)")
        for e in edges {
            print("      \(e["source"] ?? "") → \(e["target"] ?? "") [\(e["type"] ?? "")]")
        }
    }
    print()
}

func showDomain(_ db: Canon, _ domain: String) {
    guard DOMAINS.contains(domain) else {
        print("  Unknown domain. Options: morph, work, salt, vault")
        return
    }
    let projects = db.query("SELECT name, origin, files FROM projects WHERE domain = '\(domain)' ORDER BY name")
    let products = db.query("SELECT name, status FROM products WHERE domain = '\(domain)' ORDER BY name")
    print("\n    \(B)Domain: .\(domain)\(R)")
    print("    \(D)─────────────────────────────────────────\(R)")
    if !projects.isEmpty {
        print("    \(B)Projects (\(projects.count)):\(R)")
        for p in projects { print("      \(p["origin"] == "EMPIRE" ? GRN : YLW)•\(R) \(p["name"] ?? "")  \(D)(\(p["files"] ?? "0") files)\(R)") }
    }
    if !products.isEmpty {
        print("    \(B)Products (\(products.count)):\(R)")
        for p in products { print("      \(p["status"] == "verified" ? GRN : D)•\(R) \(p["name"] ?? "")  [\(p["status"] ?? "")]") }
    }
    print()
}

func showAliases(_ db: Canon) {
    let founder = db.query("SELECT * FROM founder WHERE id = 1").first
    let aliases = db.query("SELECT alias, context, platform FROM aliases ORDER BY id")
    print("""

    \(B)\(CYN)Founder: \(founder?["legal_name"] ?? "")\(R)
    \(D)─────────────────────────────────────────\(R)
    \(B)Name:\(R)    \(founder?["name"] ?? "")
    \(B)Email:\(R)   \(founder?["email"] ?? "")
    \(B)GitHub:\(R)  \(founder?["github"] ?? "")

    \(B)Aliases (\(aliases.count)):\(R)
    """)
    for a in aliases {
        print("      \(CYN)•\(R) \(B)\(a["alias"] ?? "")\(R)")
        print("        \(D)\(a["context"] ?? "") — \(a["platform"] ?? "")\(R)")
    }
    print()
}

func showEdges(_ db: Canon, _ filter: String? = nil) {
    let sql: String
    if let f = filter {
        sql = "SELECT source, target, type, note FROM edges WHERE source LIKE '%\(esc(f))%' OR target LIKE '%\(esc(f))%' ORDER BY type LIMIT 30"
    } else {
        sql = "SELECT source, target, type, note FROM edges ORDER BY type LIMIT 30"
    }
    let edges = db.query(sql)
    let total = db.count("edges")
    print("\n    \(B)Edges\(filter.map { " matching '\($0)'" } ?? "") — showing \(edges.count) of \(total)\(R)")
    print("    \(D)─────────────────────────────────────────────────────────────\(R)")
    for e in edges {
        let note = e["note"] ?? ""
        let truncNote = String(note.prefix(50))
        print("    \(CYN)\(e["source"] ?? "")\(R) → \(GRN)\(e["target"] ?? "")\(R)  \(D)[\(e["type"] ?? "")]")
        if !truncNote.isEmpty { print("      \(D)\(truncNote)\(R)") }
    }
    print()
}

func showHexagrams(_ db: Canon, _ filter: String? = nil) {
    let sql: String
    if let f = filter {
        sql = "SELECT * FROM hexagrams WHERE chinese LIKE '%\(esc(f))%' OR english LIKE '%\(esc(f))%' OR weight_role LIKE '%\(esc(f))%' ORDER BY king_wen"
    } else {
        sql = "SELECT * FROM hexagrams ORDER BY king_wen"
    }
    let hexagrams = db.query(sql)
    print("\n    \(B)Hexagrams — \(hexagrams.count) entries\(R)")
    print("    \(D)─────────────────────────────────────────────────────────────────────\(R)")
    print("    \(D)\(pad("KW",4)) \(pad("CHINESE",10)) \(pad("ENGLISH",24)) \(pad("WEIGHT ROLE",24)) \(pad("STAGE",10))\(R)")
    print("    \(D)─────────────────────────────────────────────────────────────────────\(R)")
    for h in hexagrams {
        let kw = pad(h["king_wen"] ?? "", 4)
        let ch = pad(String((h["chinese"] ?? "").prefix(10)), 10)
        let en = pad(String((h["english"] ?? "").prefix(24)), 24)
        let role = pad(String((h["weight_role"] ?? "").prefix(24)), 24)
        let stage = pad(h["forge_stage"] ?? "", 10)
        print("    \(kw) \(CYN)\(ch)\(R) \(en) \(GRN)\(role)\(R) \(D)\(stage)\(R)")
    }
    print()
}

func searchCanon(_ db: Canon, _ term: String) {
    print("\n    \(B)Search: '\(term)'\(R)")
    print("    \(D)─────────────────────────────────────────\(R)")

    let products = db.query("SELECT name, status FROM products WHERE name LIKE '%\(esc(term))%' OR description LIKE '%\(esc(term))%'")
    if !products.isEmpty {
        print("    \(B)Products (\(products.count)):\(R)")
        for p in products { print("      • \(p["name"] ?? "")  [\(p["status"] ?? "")]") }
    }

    let projects = db.query("SELECT name, domain, origin FROM projects WHERE name LIKE '%\(esc(term))%'")
    if !projects.isEmpty {
        print("    \(B)Projects (\(projects.count)):\(R)")
        for p in projects { print("      • \(p["name"] ?? "")  [\(p["domain"] ?? "").\(p["origin"] ?? "")]") }
    }

    let edges = db.query("SELECT source, target, type FROM edges WHERE note LIKE '%\(esc(term))%' OR source LIKE '%\(esc(term))%' OR target LIKE '%\(esc(term))%' LIMIT 10")
    if !edges.isEmpty {
        print("    \(B)Edges (\(edges.count)):\(R)")
        for e in edges { print("      • \(e["source"] ?? "") → \(e["target"] ?? "")  [\(e["type"] ?? "")]") }
    }

    let hexagrams = db.query("SELECT king_wen, chinese, english, weight_role FROM hexagrams WHERE chinese LIKE '%\(esc(term))%' OR english LIKE '%\(esc(term))%' OR weight_role LIKE '%\(esc(term))%'")
    if !hexagrams.isEmpty {
        print("    \(B)Hexagrams (\(hexagrams.count)):\(R)")
        for h in hexagrams { print("      • #\(h["king_wen"] ?? "") \(h["chinese"] ?? "") — \(h["english"] ?? "")  [\(h["weight_role"] ?? "")]") }
    }

    let provApps = db.query("SELECT app_name, type, source FROM app_provenance WHERE app_name LIKE '%\(esc(term))%' OR type LIKE '%\(esc(term))%' OR note LIKE '%\(esc(term))%'")
    if !provApps.isEmpty {
        print("    \(B)Provenance (\(provApps.count)):\(R)")
        for a in provApps { print("      • \(a["app_name"] ?? "")  [\(a["type"] ?? "")] → \(a["source"] ?? "")") }
    }

    let sigils = db.query("SELECT name, arc, dominant FROM sigils WHERE name LIKE '%\(esc(term))%' OR operations LIKE '%\(esc(term))%'")
    if !sigils.isEmpty {
        print("    \(B)Sigils (\(sigils.count)):\(R)")
        for s in sigils { print("      • \(s["name"] ?? "")  [\(s["arc"] ?? "")] dominant: \(s["dominant"] ?? "")") }
    }

    if products.isEmpty && projects.isEmpty && edges.isEmpty && hexagrams.isEmpty && provApps.isEmpty && sigils.isEmpty {
        print("    \(D)No results found.\(R)")
    }
    print()
}

func runSQL(_ db: Canon, _ sql: String) {
    let results = db.query(sql)
    if results.isEmpty {
        print("  \(D)(no results)\(R)")
        return
    }
    let cols = Array(results.first!.keys).sorted()
    print("  \(D)\(cols.joined(separator: " | "))\(R)")
    print("  \(D)\(String(repeating: "─", count: cols.count * 15))\(R)")
    for row in results.prefix(50) {
        let vals = cols.map { String((row[$0] ?? "").prefix(20)) }
        print("  \(vals.joined(separator: " | "))")
    }
    if results.count > 50 { print("  \(D)... \(results.count - 50) more rows\(R)") }
    print()
}

func exportJSON(_ db: Canon) {
    let exportPath = CANON_DIR + "/empire-export.json"
    var data: [String: Any] = [:]

    data["exported"] = ISO8601DateFormatter().string(from: Date())
    data["version"] = VERSION

    // Products
    var products: [[String: String]] = []
    for p in db.query("SELECT * FROM products") { products.append(p) }
    data["products"] = products

    // Projects
    var projects: [[String: String]] = []
    for p in db.query("SELECT * FROM projects") { projects.append(p) }
    data["projects"] = projects

    // Aliases
    var aliases: [[String: String]] = []
    for a in db.query("SELECT * FROM aliases") { aliases.append(a) }
    data["aliases"] = aliases

    if let jsonData = try? JSONSerialization.data(withJSONObject: data, options: [.prettyPrinted, .sortedKeys]),
       let jsonString = String(data: jsonData, encoding: .utf8) {
        try? jsonString.write(toFile: exportPath, atomically: true, encoding: .utf8)
        print("  Exported to \(exportPath)")
    } else {
        print("  Export failed")
    }
}

func formatBytes(_ bytes: Int64) -> String {
    if bytes > 1_073_741_824 { return String(format: "%.1f GB", Double(bytes) / 1_073_741_824) }
    if bytes > 1_048_576 { return String(format: "%.1f MB", Double(bytes) / 1_048_576) }
    if bytes > 1024 { return String(format: "%.1f KB", Double(bytes) / 1024) }
    return "\(bytes) B"
}

// ─── Pricing Report ──────────────────────────────

func showPricingReport(_ db: Canon) {
    print("""

    \(B)\(CYN)AVLI CLOUD — License & Revenue Terms\(R)
    \(D)═══════════════════════════════════════════════════════════\(R)

    \(B)Publisher:\(R) Avli Cloud
    \(B)Founder:\(R)   Alberto Valido Delgado (The Philosopher)
    \(B)System:\(R)    L7 Universal OS
    \(B)Law XV:\(R)    Founder perpetual, irrevocable, unrestricted free access
    \(B)Law XVI:\(R)   12% License — on OS and on sale of apps (revised 2026-03-06)
    \(B)Law XXX:\(R)   Biometrics only — no passwords

    \(B)\(GRN)Universal License (Law XVI revised):\(R)
    \(D)─────────────────────────────────────────\(R)
      \(GRN)FREE TO USE\(R) — all L7 software, tools, and frameworks
      \(YLW)12% License Fee\(R) — charged on L7 Universal OS usage
      \(YLW)12% on app sales\(R) — charged on sale of any app in the app store
      \(D)Once the license is obtained: 12% of commercial revenue on the sale of the app.\(R)
      \(D)This is a LICENSE, not a subscription. One rate. One rule. Simple.\(R)
      \(RED)License is REVOCABLE\(R) \(D)in violation of license terms.\(R)
      \(D)Apps created under a previous license remain under that license.\(R)
      \(D)Apps originating from this machine are branded \(B)Avli Cloud\(R)\(D).\(R)

    """)

    let products = db.query("SELECT name, price_free, price_pro, price_enterprise, status FROM products WHERE status != 'placeholder' ORDER BY name")
    print("    \(B)Active Products:\(R)")
    print("    \(D)─────────────────────────────────────────────────────────────────────\(R)")
    for p in products {
        print("    \(B)\(p["name"] ?? "")\(R)")
        print("      Free:       \(GRN)\(p["price_free"] ?? "—")\(R)")
        print("      Pro:        \(YLW)\(p["price_pro"] ?? "—")\(R)")
        print("      Enterprise: \(CYN)\(p["price_enterprise"] ?? "—")\(R)")
        print()
    }

    print("    \(B)Reserved Product Namespaces:\(R)")
    let placeholders = db.query("SELECT name, description FROM products WHERE status = 'placeholder' ORDER BY name")
    for p in placeholders {
        print("      \(D)• \(p["name"] ?? "") — \(p["description"] ?? "")\(R)")
    }
    print()
}

// ─── Provenance & Sigils Display ─────────────────

func showProvenance(_ db: Canon, _ filter: String? = nil) {
    let sql: String
    if let f = filter {
        sql = "SELECT * FROM app_provenance WHERE app_name LIKE '%\(esc(f))%' OR type LIKE '%\(esc(f))%' OR note LIKE '%\(esc(f))%' ORDER BY type, app_name"
    } else {
        sql = "SELECT * FROM app_provenance ORDER BY type, app_name"
    }
    let apps = db.query(sql)
    print("\n    \(B)App Provenance — \(apps.count) entries\(filter.map { " matching '\($0)'" } ?? "")\(R)")
    print("    \(D)All software created by \(B)Alberto Valido Delgado\(R)\(D) — Published by \(B)Avli Cloud\(R)")
    print("    \(D)═══════════════════════════════════════════════════════════════════\(R)")
    print("    \(D)\(pad("APP",28)) \(pad("TYPE",12)) \(pad("ARCH",6)) \(pad("SEAL",8)) LICENSE\(R)")
    print("    \(D)───────────────────────────────────────────────────────────────────\(R)")
    for a in apps {
        let name = pad(String((a["app_name"] ?? "").prefix(28)), 28)
        let type = pad(a["type"] ?? "", 12)
        let arch = pad(a["architecture"] ?? "", 6)
        let seal = a["production_seal"] ?? ""
        let sealColor = seal == "RUBEDO" ? GRN : (seal == "CITRINITAS" ? YLW : D)
        let license = a["license_terms"] ?? ""
        print("    \(sealColor)\(name)\(R) \(type) \(arch) \(sealColor)\(pad(seal,8))\(R) \(D)\(license)\(R)")
    }
    let immutable = db.query("SELECT COUNT(*) as c FROM app_provenance WHERE immutable_engine = 1")
    let founderOnly = db.query("SELECT COUNT(*) as c FROM app_provenance WHERE founder_only_modification = 1")
    print("\n    \(D)Immutable engine: \(immutable.first?["c"] ?? "0") | Founder-only modification: \(founderOnly.first?["c"] ?? "0")\(R)")
    print()
}

func showSigils(_ db: Canon) {
    let sigils = db.query("SELECT * FROM sigils ORDER BY id")
    print("\n    \(B)\(MAG)Core Sigils — \(sigils.count) entries (immutable, founder-only)\(R)")
    print("    \(D)═══════════════════════════════════════════════════════════\(R)")
    for s in sigils {
        let name = s["name"] ?? ""
        let ops = s["operations"] ?? ""
        let arc = s["arc"] ?? ""
        let dom = s["dominant"] ?? ""
        let qual = s["quality"] ?? ""
        let hexNum = s["hexagram_num"] ?? ""
        let q64 = s["q64_address"] ?? ""
        let readable = s["readable"] ?? ""
        print("    \(B)\(MAG)\(name)\(R)")
        print("      \(CYN)Operations:\(R) \(ops)")
        print("      \(CYN)Arc:\(R) \(arc)  \(CYN)Dominant:\(R) \(dom)  \(CYN)Quality:\(R) \(qual)")
        print("      \(CYN)Hexagram:\(R) #\(hexNum)  \(CYN)Q64:\(R) \(q64)")
        if !readable.isEmpty { print("      \(D)\(readable)\(R)") }
        print()
    }
    // Show edges for each sigil
    for s in sigils {
        let name = s["name"] ?? ""
        let edges = db.query("SELECT * FROM sigil_edges WHERE sigil_name = '\(esc(name))' ORDER BY edge_idx")
        if !edges.isEmpty {
            print("    \(D)Edges for \(name):\(R)")
            for e in edges {
                print("      \(D)[\(e["edge_idx"] ?? "")] \(e["from_op"] ?? "") → \(e["to_op"] ?? "")\(R)")
            }
            print()
        }
    }
}

// ─── Browser REPL ────────────────────────────────

func repl(_ db: Canon) {
    showBanner()
    showStats(db)

    print("    \(D)Commands: stats, products, product <n>, projects, project <n>,")
    print("    domain <d>, aliases, edges [filter], hexagrams [filter],")
    print("    provenance [filter], sigils, pricing, search <term>,")
    print("    sql <query>, export, quit\(R)")
    print()

    while true {
        print("\(B)\(CYN)  l7>\(R) ", terminator: "")
        fflush(stdout)
        guard let line = readLine()?.trimmingCharacters(in: .whitespaces), !line.isEmpty else { continue }
        let parts = line.split(separator: " ", maxSplits: 1)
        let cmd = String(parts[0]).lowercased()
        let arg = parts.count > 1 ? String(parts[1]) : nil

        switch cmd {
        case "quit", "exit", "q":
            print("  \(D)Canon closed.\(R)")
            return
        case "stats":
            showStats(db)
        case "products":
            showProducts(db)
        case "product":
            if let a = arg { showProductDetail(db, a) }
            else { print("  Usage: product <name>") }
        case "projects":
            showProjects(db)
        case "project":
            if let a = arg { showProjectDetail(db, a) }
            else { print("  Usage: project <name>") }
        case "domain":
            if let a = arg { showDomain(db, a.lowercased()) }
            else { print("  Usage: domain <morph|work|salt|vault>") }
        case "aliases":
            showAliases(db)
        case "edges":
            showEdges(db, arg)
        case "hexagrams", "hex":
            showHexagrams(db, arg)
        case "provenance", "prov":
            showProvenance(db, arg)
        case "sigils":
            showSigils(db)
        case "pricing":
            showPricingReport(db)
        case "search":
            if let a = arg { searchCanon(db, a) }
            else { print("  Usage: search <term>") }
        case "sql":
            if let a = arg { runSQL(db, a) }
            else { print("  Usage: sql <SELECT ...>") }
        case "export":
            exportJSON(db)
        case "help":
            print("""
              \(B)Commands:\(R)
                stats                Overview statistics
                products             All products with pricing
                product <name>       Product detail
                pricing              Full pricing report
                projects             All projects with coordinates
                project <name>       Project detail with edges
                domain <name>        Items in domain (morph/work/salt/vault)
                aliases              Founder aliases
                edges [filter]       Browse edges (optional filter)
                hexagrams [filter]   Browse hexagrams (optional filter)
                provenance [filter]  App provenance (all → Avli Cloud)
                sigils               Core sigils (immutable, founder-only)
                search <term>        Search across all tables
                sql <query>          Raw SQL query
                export               Export to JSON
                quit                 Exit
            """)
        default:
            print("  Unknown command: \(cmd). Type 'help' for commands.")
        }
    }
}

// ─── License & Pseudonym Enforcement ─────────────

func populateLicenseAndPseudonyms(_ db: Canon) {
    db.exec("""
    INSERT OR IGNORE INTO license_enforcement (rule, rate, description, law_reference) VALUES
    ('universal', 0.12, '12% LICENSE FEE on L7 Universal OS. 12% on sale of any app on the app store. Once licensed: 12% of commercial revenue on app sales. This is a LICENSE, not a subscription. LICENSE IS REVOCABLE in violation of terms.', 'Law XVI (revised 2026-03-06)'),
    ('derivative_works', 0.12, 'Apps built on L7 Universal OS: 12% license fee on the sale of the app. Same 12% rate for all derivative works. Apps created under previous license terms remain under those terms.', 'Law XVI (revised 2026-03-06)'),
    ('founder_exempt', 0.0, 'Founder (Alberto Valido Delgado) has perpetual, irrevocable, unrestricted, free access to all L7 tools and derivatives. All pseudonyms are one legal entity.', 'Law XV'),
    ('revocability', 0.0, 'License is REVOCABLE upon violation of license terms. Apps created under a previous license remain under that license. Apps originating from the Founder machine are branded Avli Cloud.', 'Law XVI (revised 2026-03-06)'),
    ('machine_origin', 0.0, 'All apps created on the Founder machine (this system) and originating directly from the Founder are branded as Avli Cloud. Machine identity verified by hardware UUID (Law XXX).', 'Law XXX + Law XVI')
    """)

    let pseudonyms: [(String, String)] = [
        ("Alberto Valido Delgado", "Legal name — primary identity for all revenue, IP, and legal matters"),
        ("The Philosopher", "Title within L7 system — same legal entity"),
        ("valido", "Surname handle — same legal entity"),
        ("avalia", "Primary alias — same legal entity, used across platforms"),
        ("1991", "Birth year cipher — same legal entity"),
        ("avalia1", "GitHub username — same legal entity, code contributions"),
        ("avalia333", "Social alias — same legal entity"),
        ("avalia777", "Social alias — same legal entity"),
        ("Avli Cloud", "Business entity — owned by Alberto Valido Delgado"),
    ]
    for (p, n) in pseudonyms {
        db.exec("INSERT OR IGNORE INTO pseudonym_resolution (pseudonym, legal_entity, note) VALUES ('\(esc(p))', 'Alberto Valido Delgado', '\(esc(n))')")
    }
}

// ─── Initialize & Populate ───────────────────────

func initializeCanon() -> Canon {
    let db = Canon(EMPIRE_DB)
    guard db.open() else {
        print("  \(RED)Failed to open database at \(EMPIRE_DB)\(R)")
        exit(1)
    }

    // Check if already populated
    let existing = db.count("products")
    if existing > 0 {
        return db
    }

    print("  \(CYN)═══ Building Empire Canon ═══\(R)")
    print()

    createSchema(db)
    print("  Schema created")

    populateFounder(db)
    print("  Founder + \(db.count("aliases")) aliases")

    populateProducts(db)
    print("  \(db.count("products")) products cataloged")

    populateHexagrams(db)
    print("  \(db.count("hexagrams")) hexagrams encoded")

    populateTrigrams(db)
    print("  \(db.count("trigrams")) trigrams")

    populateIfaOdu(db)
    print("  \(db.count("ifa_odu")) Ifá Odu")

    populateGeomantic(db)
    print("  \(db.count("geomantic_figures")) geomantic figures")

    populateCoreSigils(db)
    print("  \(db.count("sigils")) core sigils (immutable, founder-only)")

    populateAppProvenance(db)
    print("  \(db.count("app_provenance")) app provenance records → Avli Cloud")

    importProjects(db)
    importEdges(db)

    populateLicenseAndPseudonyms(db)
    print("  License enforcement + pseudonym resolution")

    // Record provenance
    db.exec("""
    INSERT INTO provenance (file, hash, signer)
    VALUES ('empire.db', 'genesis', 'Alberto Valido Delgado')
    """)

    print()
    print("  \(GRN)Empire Canon built: \(EMPIRE_DB)\(R)")
    print()
    return db
}

func rebuildCanon(_ db: Canon) {
    // Drop and rebuild
    for table in ["products", "projects", "edges", "symlinks", "versions",
                  "hexagrams", "trigrams", "ifa_odu", "geomantic_figures",
                  "aliases", "founder", "provenance",
                  "sigils", "sigil_edges", "app_provenance",
                  "license_enforcement", "pseudonym_resolution"] {
        db.exec("DROP TABLE IF EXISTS \(table)")
    }
    createSchema(db)
    populateFounder(db)
    populateProducts(db)
    populateHexagrams(db)
    populateTrigrams(db)
    populateIfaOdu(db)
    populateGeomantic(db)
    populateCoreSigils(db)
    populateAppProvenance(db)
    importProjects(db)
    importEdges(db)
    populateLicenseAndPseudonyms(db)
    db.exec("INSERT INTO provenance (file, hash, signer) VALUES ('empire.db', 'rebuild-\(ISO8601DateFormatter().string(from: Date()))', 'Alberto Valido Delgado')")
    print("  \(GRN)Canon rebuilt.\(R)")
}

// ─── CLI Main ────────────────────────────────────

// ─── Security Checks (consistent across all ashrams) ───
guard verifyNotTraced() else {
    fputs("Debugger detected. Canon refuses to operate.\n", stderr)
    exit(1)
}
canonLog("CANON_OPEN: pid=\(getpid()) uid=\(getuid())")

if !authenticateCanon() {
    fputs("Authentication failed. Law XXX: Biometrics ONLY.\n", stderr)
    exit(1)
}

let args = CommandLine.arguments

if args.contains("--version") {
    print("L7 Canon v\(VERSION) — Empire Database Engine")
    print("Creator: Alberto Valido Delgado")
    print("Database: \(EMPIRE_DB)")
    exit(0)
}

if args.contains("--help") {
    print("""
    L7 Canon — The Empire Database

    Usage: l7 canon [command]

    Commands:
      (none)            Interactive browser
      --stats           Print statistics
      --products        List all products
      --product <name>  Product detail
      --pricing         Full pricing report
      --projects        List all projects
      --aliases         Show founder aliases
      --hexagrams       List all hexagrams
      --provenance      App provenance (all → Avli Cloud)
      --sigils          Core sigils (immutable, founder-only)
      --search <term>   Search across all tables
      --sql <query>     Execute SQL query
      --export          Export to JSON
      --rebuild         Force rebuild from manifests
      --version         Show version
      --help            Show this help
    """)
    exit(0)
}

let db = initializeCanon()

if args.contains("--rebuild") {
    rebuildCanon(db)
    showStats(db)
} else if args.contains("--stats") {
    showStats(db)
} else if args.contains("--products") {
    showProducts(db)
} else if args.contains("--pricing") {
    showPricingReport(db)
} else if args.contains("--projects") {
    showProjects(db)
} else if args.contains("--aliases") {
    showAliases(db)
} else if args.contains("--hexagrams") {
    showHexagrams(db)
} else if args.contains("--provenance") {
    showProvenance(db)
} else if args.contains("--sigils") {
    showSigils(db)
} else if let idx = args.firstIndex(of: "--product"), idx + 1 < args.count {
    showProductDetail(db, args[idx + 1])
} else if let idx = args.firstIndex(of: "--search"), idx + 1 < args.count {
    showSearchResults(db, args[idx + 1])
} else if let idx = args.firstIndex(of: "--sql"), idx + 1 < args.count {
    runSQL(db, args[idx + 1])
} else if args.contains("--export") {
    exportJSON(db)
} else {
    repl(db)
}

func showSearchResults(_ db: Canon, _ term: String) {
    searchCanon(db, term)
}

db.close()
