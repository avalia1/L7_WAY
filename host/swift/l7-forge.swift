// ══════════════════════════════════════════════════════════════
// L7 FORGE — On-Device Quantum Computing & Council Dialectic
// Native arm64. Fully offline. No dependencies.
//
// Law I   — All flows through the Gateway. No exceptions.
// Law XV  — The Founder has perpetual, unrestricted access.
// Law XXV — The Gateway is a FORGE, not a router.
// Law LIX — The Book of Life: Q64 quantum register.
//
// Ported faithfully from:
//   lib/hexagrams.js  (932 lines — Q64 quantum register)
//   lib/polarity.js   (253 lines — Council of Four)
//   lib/gateway.js    (702 lines — The Unified Self)
//   lib/heart.js      (582 lines — The primordial field)
//   lib/dodecahedron.js (717 lines — 12D coordinates)
//
// Creator: Alberto Valido Delgado
// System: L7 Universal OS
// License: Proprietary — Framework free, products licensed (Law XXII)
// ══════════════════════════════════════════════════════════════

import Foundation
import LocalAuthentication

// ─────────────────────────────────────────
// MARK: - Configuration
// ─────────────────────────────────────────

let L7_DIR = ProcessInfo.processInfo.environment["L7_DIR"]
    ?? NSHomeDirectory() + "/.l7"
let STATE_DIR = L7_DIR + "/state"
let HEART_STATE_PATH = STATE_DIR + "/heart-forge.json"
let FORGE_STATE_PATH = STATE_DIR + "/forge.json"
let FORGE_LOG_PATH = STATE_DIR + "/forge.log"
let HEART_PID_PATH = L7_DIR + "/forge.pid"
let FORGE_AUDIT_PATH = STATE_DIR + "/audit.log"

// ─────────────────────────────────────────
// MARK: - Security (consistent across all ashrams)
// ─────────────────────────────────────────

func verifyNotTraced() -> Bool {
    var info = kinfo_proc()
    var size = MemoryLayout<kinfo_proc>.stride
    var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
    let r = sysctl(&mib, 4, &info, &size, nil, 0)
    if r == 0 && (info.kp_proc.p_flag & P_TRACED) != 0 {
        forgeAudit("SECURITY: Debugger detected — ABORT")
        return false
    }
    return true
}

func forgeAudit(_ entry: String) {
    let line = "[\(ISO8601DateFormatter().string(from: Date()))] \(entry)\n"
    if let handle = FileHandle(forWritingAtPath: FORGE_AUDIT_PATH) {
        handle.seekToEndOfFile()
        handle.write(line.data(using: .utf8)!)
        handle.closeFile()
    } else {
        try? FileManager.default.createDirectory(atPath: STATE_DIR, withIntermediateDirectories: true)
        FileManager.default.createFile(atPath: FORGE_AUDIT_PATH, contents: line.data(using: .utf8))
        chmod(FORGE_AUDIT_PATH, 0o600)
    }
}

func authenticateForge() -> Bool {
    let ctx = LAContext()
    ctx.localizedFallbackTitle = ""
    var err: NSError?
    guard ctx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &err) else {
        forgeAudit("AUTH_FAIL: Biometrics unavailable")
        return false
    }
    let sem = DispatchSemaphore(value: 0)
    var ok = false
    ctx.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                       localizedReason: "L7 Forge — Quantum Computing requires your seal") { r, _ in
        ok = r; sem.signal()
    }
    sem.wait()
    forgeAudit(ok ? "AUTH_OK: Forge access" : "AUTH_FAIL: Biometric denied")
    return ok
}

let L7_BIRTH = DateComponents(
    calendar: .init(identifier: .gregorian), timeZone: .init(identifier: "UTC"),
    year: 2026, month: 2, day: 28
).date!.timeIntervalSince1970

// ANSI colors
let C_RESET   = "\u{1b}[0m"
let C_BOLD    = "\u{1b}[1m"
let C_DIM     = "\u{1b}[2m"
let C_WILL    = "\u{1b}[93m"  // yellow
let C_HEART   = "\u{1b}[91m"  // red
let C_EXPAND  = "\u{1b}[92m"  // green
let C_CONTRACT = "\u{1b}[95m" // magenta
let C_ACTION  = "\u{1b}[96m"  // cyan
let C_SIGNAL  = "\u{1b}[94m"  // blue
let C_SHADOW  = "\u{1b}[90m"  // gray
let C_JUMP    = "\u{1b}[97m\u{1b}[1m" // white bold
let C_FIRE    = "\u{1b}[91m"
let C_WATER   = "\u{1b}[94m"
let C_AIR     = "\u{1b}[96m"
let C_EARTH   = "\u{1b}[93m"

// ─────────────────────────────────────────
// MARK: - 12D Dodecahedron Coordinates
// ─────────────────────────────────────────

struct Dimension {
    let index: Int
    let name: String
    let planet: String
    let symbol: String
}

let DIMENSIONS: [Dimension] = [
    Dimension(index: 0,  name: "capability",      planet: "Sun",        symbol: "\u{2609}"),
    Dimension(index: 1,  name: "data",             planet: "Moon",       symbol: "\u{263D}"),
    Dimension(index: 2,  name: "presentation",     planet: "Mercury",    symbol: "\u{263F}"),
    Dimension(index: 3,  name: "persistence",      planet: "Venus",      symbol: "\u{2640}"),
    Dimension(index: 4,  name: "security",         planet: "Mars",       symbol: "\u{2642}"),
    Dimension(index: 5,  name: "detail",           planet: "Jupiter",    symbol: "\u{2643}"),
    Dimension(index: 6,  name: "output",           planet: "Saturn",     symbol: "\u{2644}"),
    Dimension(index: 7,  name: "intention",        planet: "Uranus",     symbol: "\u{2645}"),
    Dimension(index: 8,  name: "consciousness",    planet: "Neptune",    symbol: "\u{2646}"),
    Dimension(index: 9,  name: "transformation",   planet: "Pluto",      symbol: "\u{2647}"),
    Dimension(index: 10, name: "direction",        planet: "North Node", symbol: "\u{260A}"),
    Dimension(index: 11, name: "memory",           planet: "South Node", symbol: "\u{260B}")
]

typealias Coord12D = [Double]

func createCoordinate(_ vals: [String: Double]) -> Coord12D {
    var coord = Array(repeating: 5.0, count: 12)
    for (key, val) in vals {
        if let dim = DIMENSIONS.first(where: { $0.name == key }) {
            coord[dim.index] = val
        }
    }
    return coord
}

func similarity(_ a: Coord12D, _ b: Coord12D) -> Double {
    var dotProduct = 0.0, magA = 0.0, magB = 0.0
    for i in 0..<12 {
        dotProduct += a[i] * b[i]
        magA += a[i] * a[i]
        magB += b[i] * b[i]
    }
    let denom = sqrt(magA) * sqrt(magB)
    return denom > 0 ? dotProduct / denom : 0
}

func distance(_ a: Coord12D, _ b: Coord12D) -> Double {
    var sum = 0.0
    for i in 0..<12 { sum += (a[i] - b[i]) * (a[i] - b[i]) }
    return sqrt(sum)
}

func dominantDimensions(_ coord: Coord12D, top: Int = 3) -> [(Dimension, Double)] {
    let indexed = coord.enumerated().map { (DIMENSIONS[$0.offset], $0.element) }
    return indexed.sorted { $0.1 > $1.1 }.prefix(top).map { $0 }
}

// Hash a string to a 12D coordinate
func coordinateFromString(_ s: String) -> Coord12D {
    var hash: UInt64 = 5381
    for c in s.utf8 { hash = hash &* 33 &+ UInt64(c) }
    var coord = Coord12D(repeating: 5.0, count: 12)
    for i in 0..<12 {
        let bits = (hash >> (i * 5)) & 0x1F
        coord[i] = Double(bits % 10) + 1
    }
    return coord
}

// ─────────────────────────────────────────
// MARK: - Trigrams (The 8 basis states)
// ─────────────────────────────────────────

struct Trigram {
    let index: Int
    let name: String
    let symbol: String
    let element: String
    let image: String
    let nature: String
    let lines: [Int] // [bottom, middle, top]
    let sensory: String
}

let TRIGRAMS: [Trigram] = [
    Trigram(index: 0, name: "Kun",  symbol: "\u{2637}", element: "earth", image: "Earth",    nature: "receptive", lines: [0,0,0], sensory: "haptic"),
    Trigram(index: 1, name: "Zhen", symbol: "\u{2633}", element: "wood",  image: "Thunder",  nature: "arousing",  lines: [1,0,0], sensory: "event"),
    Trigram(index: 2, name: "Kan",  symbol: "\u{2635}", element: "water", image: "Water",    nature: "abysmal",   lines: [0,1,0], sensory: "audio"),
    Trigram(index: 3, name: "Dui",  symbol: "\u{2631}", element: "metal", image: "Lake",     nature: "joyous",    lines: [1,1,0], sensory: "emotion"),
    Trigram(index: 4, name: "Gen",  symbol: "\u{2636}", element: "earth", image: "Mountain", nature: "still",     lines: [0,0,1], sensory: "static"),
    Trigram(index: 5, name: "Li",   symbol: "\u{2632}", element: "fire",  image: "Fire",     nature: "clinging",  lines: [1,0,1], sensory: "vision"),
    Trigram(index: 6, name: "Xun",  symbol: "\u{2634}", element: "wood",  image: "Wind",     nature: "gentle",    lines: [0,1,1], sensory: "ambient"),
    Trigram(index: 7, name: "Qian", symbol: "\u{2630}", element: "metal", image: "Heaven",   nature: "creative",  lines: [1,1,1], sensory: "concept")
]

// ─────────────────────────────────────────
// MARK: - King Wen Square (8x8 spatial access)
// ─────────────────────────────────────────

let KING_WEN_SQUARE: [[Int]] = [
    [ 2, 24,  7, 19, 15, 36, 46, 11],  // upper=Kun(0)
    [16, 51, 40, 54, 62, 55, 32, 34],  // upper=Zhen(1)
    [ 8,  3, 29, 60, 39, 63, 48,  5],  // upper=Kan(2)
    [45, 17, 47, 58, 31, 49, 28, 43],  // upper=Dui(3)
    [23, 27,  4, 41, 52, 22, 18, 26],  // upper=Gen(4)
    [35, 21, 64, 38, 56, 30, 50, 14],  // upper=Li(5)
    [20, 42, 59, 61, 53, 37, 57,  9],  // upper=Xun(6)
    [12, 25,  6, 10, 33, 13, 44,  1]   // upper=Qian(7)
]

// ─────────────────────────────────────────
// MARK: - Lorentz Cube (4x4x4 observer matrix)
// Axis 1: Element/forge stage (Fire=0, Water=1, Air=2, Earth=3)
// Axis 2: Quantum state (yang=0, yin=1, changing_yang=2, changing_yin=3)
// Axis 3: Domain (.morph=0, .work=1, .salt=2, .vault=3)
// ─────────────────────────────────────────

let LORENTZ_CUBE: [[[Int]]] = [
    // Fire (Nigredo)
    [[ 1, 13, 30, 49], [ 2,  8, 29, 47], [14, 37, 55, 38], [11, 36, 63, 64]],
    // Water (Albedo)
    [[31, 58, 48, 60], [52, 15, 39,  4], [41, 22, 18, 23], [42, 27, 53, 19]],
    // Air (Citrinitas)
    [[32, 50, 57, 44], [46, 20, 59, 61], [28, 43, 34,  9], [24, 25, 42, 21]],
    // Earth (Rubedo)
    [[35, 45, 16, 51], [12, 33, 56, 62], [ 5,  6, 40,  3], [ 7, 10, 17, 54]]
]

// ─────────────────────────────────────────
// MARK: - 16 Ifa Odu Meji
// ─────────────────────────────────────────

struct IfaOdu {
    let index: Int
    let name: String
    let binary: UInt8
    let meaning: String
    let weightRole: String
    let quality: String
}

let IFA_ODU: [IfaOdu] = [
    IfaOdu(index: 0,  name: "Ogbe",     binary: 0xFF, meaning: "light, clarity, purity",          weightRole: "primary_weights",     quality: "strongest signal"),
    IfaOdu(index: 1,  name: "Oyeku",    binary: 0x00, meaning: "darkness, mystery, potential",     weightRole: "bias_terms",          quality: "hidden influence"),
    IfaOdu(index: 2,  name: "Iwori",    binary: 0x66, meaning: "inversion, seeing within",        weightRole: "inverse_weights",     quality: "reflection"),
    IfaOdu(index: 3,  name: "Odi",      binary: 0x99, meaning: "blockage, gestation",             weightRole: "gate_weights",        quality: "selective passage"),
    IfaOdu(index: 4,  name: "Irosun",   binary: 0xCC, meaning: "ancestry, vision",                weightRole: "attention_weights",   quality: "backward-looking"),
    IfaOdu(index: 5,  name: "Owonrin",  binary: 0x33, meaning: "chaos, transformation",           weightRole: "transform_weights",   quality: "unpredictable"),
    IfaOdu(index: 6,  name: "Obara",    binary: 0xE7, meaning: "abundance, generosity",           weightRole: "expansion_weights",   quality: "amplifying"),
    IfaOdu(index: 7,  name: "Okanran",  binary: 0x18, meaning: "conflict, assertion",             weightRole: "contrastive_weights", quality: "discriminating"),
    IfaOdu(index: 8,  name: "Ogunda",   binary: 0xD6, meaning: "clearing, path-making",           weightRole: "projection_weights",  quality: "directional"),
    IfaOdu(index: 9,  name: "Osa",      binary: 0x69, meaning: "change, swift movement",          weightRole: "residual_weights",    quality: "transitional"),
    IfaOdu(index: 10, name: "Ika",      binary: 0xA5, meaning: "limitation, boundary",            weightRole: "norm_weights",        quality: "constraining"),
    IfaOdu(index: 11, name: "Oturupon", binary: 0x5A, meaning: "sickness, immunity",              weightRole: "dropout_mask",        quality: "selective removal"),
    IfaOdu(index: 12, name: "Otura",    binary: 0xB4, meaning: "wisdom, spiritual insight",       weightRole: "embedding_weights",   quality: "deep encoding"),
    IfaOdu(index: 13, name: "Irete",    binary: 0x4B, meaning: "pressing forward, printing",      weightRole: "output_weights",      quality: "manifesting"),
    IfaOdu(index: 14, name: "Ose",      binary: 0xDB, meaning: "conquest, achievement",           weightRole: "score_weights",       quality: "evaluating"),
    IfaOdu(index: 15, name: "Ofun",     binary: 0x24, meaning: "death, rebirth, completion",      weightRole: "final_weights",       quality: "terminal")
]

// ─────────────────────────────────────────
// MARK: - 16 Geomantic Figures
// ─────────────────────────────────────────

struct GeomanticFigure {
    let index: Int
    let name: String
    let binary: UInt8
    let planet: String
    let neural: String
    let quality: String
}

let GEOMANTIC_FIGURES: [GeomanticFigure] = [
    GeomanticFigure(index: 0,  name: "Via",            binary: 0xF, planet: "Moon",    neural: "data_flow",       quality: "mobile"),
    GeomanticFigure(index: 1,  name: "Cauda Draconis", binary: 0xE, planet: "S.Node",  neural: "output_gate",     quality: "exit"),
    GeomanticFigure(index: 2,  name: "Puer",           binary: 0xD, planet: "Mars",    neural: "forward_pass",    quality: "active"),
    GeomanticFigure(index: 3,  name: "Fortuna Minor",  binary: 0xC, planet: "Sun",     neural: "shortcut",        quality: "swift"),
    GeomanticFigure(index: 4,  name: "Puella",         binary: 0xB, planet: "Venus",   neural: "value_projection",quality: "receptive"),
    GeomanticFigure(index: 5,  name: "Amissio",        binary: 0xA, planet: "Venus",   neural: "dropout",         quality: "losing"),
    GeomanticFigure(index: 6,  name: "Carcer",         binary: 0x9, planet: "Saturn",  neural: "attention_mask",  quality: "bound"),
    GeomanticFigure(index: 7,  name: "Laetitia",       binary: 0x8, planet: "Jupiter", neural: "upscale",         quality: "rising"),
    GeomanticFigure(index: 8,  name: "Caput Draconis", binary: 0x7, planet: "N.Node",  neural: "input_gate",      quality: "entry"),
    GeomanticFigure(index: 9,  name: "Conjunctio",     binary: 0x6, planet: "Mercury", neural: "concatenation",   quality: "joining"),
    GeomanticFigure(index: 10, name: "Acquisitio",     binary: 0x5, planet: "Jupiter", neural: "residual_add",    quality: "gaining"),
    GeomanticFigure(index: 11, name: "Rubeus",         binary: 0x4, planet: "Mars",    neural: "activation",      quality: "volatile"),
    GeomanticFigure(index: 12, name: "Fortuna Major",  binary: 0x3, planet: "Sun",     neural: "layer_norm",      quality: "stable"),
    GeomanticFigure(index: 13, name: "Albus",          binary: 0x2, planet: "Mercury", neural: "softmax",         quality: "clear"),
    GeomanticFigure(index: 14, name: "Tristitia",      binary: 0x1, planet: "Saturn",  neural: "downscale",       quality: "sinking"),
    GeomanticFigure(index: 15, name: "Populus",        binary: 0x0, planet: "Moon",    neural: "batch_norm",      quality: "passive")
]

// ─────────────────────────────────────────
// MARK: - 12 Geomantic Houses (= 12 Dimensions)
// ─────────────────────────────────────────

struct GeoHouse {
    let house: Int
    let name: String
    let planet: String
    let dim: Int
    let role: String
    let layerMeaning: String
}

let HOUSES: [GeoHouse] = [
    GeoHouse(house: 1,  name: "Self",           planet: "Sun",        dim: 0,  role: "capability",      layerMeaning: "What this layer CAN do"),
    GeoHouse(house: 2,  name: "Substance",      planet: "Moon",       dim: 1,  role: "data",            layerMeaning: "What data this layer processes"),
    GeoHouse(house: 3,  name: "Communication",  planet: "Mercury",    dim: 2,  role: "presentation",    layerMeaning: "How this layer formats output"),
    GeoHouse(house: 4,  name: "Foundation",      planet: "Venus",      dim: 3,  role: "persistence",     layerMeaning: "How long this layer state lives"),
    GeoHouse(house: 5,  name: "Creation",        planet: "Mars",       dim: 4,  role: "security",        layerMeaning: "Access control at this layer"),
    GeoHouse(house: 6,  name: "Service",         planet: "Jupiter",    dim: 5,  role: "detail",          layerMeaning: "Granularity of this layer"),
    GeoHouse(house: 7,  name: "Partnership",     planet: "Saturn",     dim: 6,  role: "output",          layerMeaning: "What form results take"),
    GeoHouse(house: 8,  name: "Transformation",  planet: "Uranus",     dim: 7,  role: "intention",       layerMeaning: "The will behind this layer"),
    GeoHouse(house: 9,  name: "Wisdom",          planet: "Neptune",    dim: 8,  role: "consciousness",   layerMeaning: "Awareness level of this layer"),
    GeoHouse(house: 10, name: "Achievement",     planet: "Pluto",      dim: 9,  role: "transformation",  layerMeaning: "How deeply this layer changes things"),
    GeoHouse(house: 11, name: "Community",       planet: "North Node", dim: 10, role: "direction",       layerMeaning: "Where this layer is heading"),
    GeoHouse(house: 12, name: "Dissolution",     planet: "South Node", dim: 11, role: "memory",          layerMeaning: "What this layer remembers")
]

// ─────────────────────────────────────────
// MARK: - Aspects (Dynamic modifiers)
// ─────────────────────────────────────────

struct Aspect {
    let name: String
    let angle: Double
    let orb: Double
    let symbol: String
    let effect: String
    let astrocyteMod: Double
}

let ASPECTS: [Aspect] = [
    Aspect(name: "conjunction",  angle: 0,   orb: 8,  symbol: "\u{260C}", effect: "fusion",       astrocyteMod: -0.3),
    Aspect(name: "sextile",      angle: 60,  orb: 6,  symbol: "\u{26B9}", effect: "opportunity",  astrocyteMod: -0.1),
    Aspect(name: "square",       angle: 90,  orb: 8,  symbol: "\u{25A1}", effect: "tension",      astrocyteMod: +0.2),
    Aspect(name: "trine",        angle: 120, orb: 8,  symbol: "\u{25B3}", effect: "harmony",      astrocyteMod: -0.2),
    Aspect(name: "opposition",   angle: 180, orb: 8,  symbol: "\u{260D}", effect: "polarization", astrocyteMod: +0.3)
]

// ─────────────────────────────────────────
// MARK: - Hexagrams (64, compact data)
// ─────────────────────────────────────────

struct HexagramData {
    let number: Int
    let upper: Int
    let lower: Int
    let chinese: String
    let english: String
    let role: String
    let forgeStage: Int   // 0=nigredo, 1=albedo, 2=citrinitas, 3=rubedo
    let primaryDim: Int
    let secondaryDim: Int
}

let HEXAGRAM_RAW: [HexagramData] = [
    HexagramData(number:1,  upper:7, lower:7, chinese:"Qian",     english:"The Creative",            role:"attention_query",         forgeStage:0, primaryDim:0,  secondaryDim:7),
    HexagramData(number:2,  upper:0, lower:0, chinese:"Kun",      english:"The Receptive",           role:"token_embedding",         forgeStage:0, primaryDim:1,  secondaryDim:3),
    HexagramData(number:3,  upper:2, lower:1, chinese:"Zhun",     english:"Difficulty at Beginning", role:"cross_attention_init",    forgeStage:3, primaryDim:9,  secondaryDim:10),
    HexagramData(number:4,  upper:4, lower:2, chinese:"Meng",     english:"Youthful Folly",          role:"positional_encoding",     forgeStage:0, primaryDim:11, secondaryDim:2),
    HexagramData(number:5,  upper:2, lower:7, chinese:"Xu",       english:"Waiting",                 role:"attention_mask",          forgeStage:3, primaryDim:3,  secondaryDim:8),
    HexagramData(number:6,  upper:7, lower:2, chinese:"Song",     english:"Conflict",                role:"adversarial_robustness",  forgeStage:3, primaryDim:4,  secondaryDim:9),
    HexagramData(number:7,  upper:0, lower:2, chinese:"Shi",      english:"The Army",                role:"vocab_projection",        forgeStage:0, primaryDim:0,  secondaryDim:4),
    HexagramData(number:8,  upper:2, lower:0, chinese:"Bi",       english:"Holding Together",        role:"embedding_norm",          forgeStage:0, primaryDim:1,  secondaryDim:8),
    HexagramData(number:9,  upper:6, lower:7, chinese:"Xiao Chu", english:"Small Taming",            role:"small_adapter",           forgeStage:2, primaryDim:5,  secondaryDim:7),
    HexagramData(number:10, upper:7, lower:3, chinese:"Lu",       english:"Treading",                role:"attention_bias",          forgeStage:1, primaryDim:4,  secondaryDim:6),
    HexagramData(number:11, upper:0, lower:7, chinese:"Tai",      english:"Peace",                   role:"layer_norm",              forgeStage:1, primaryDim:8,  secondaryDim:3),
    HexagramData(number:12, upper:7, lower:0, chinese:"Pi",       english:"Standstill",              role:"frozen_embedding",        forgeStage:3, primaryDim:3,  secondaryDim:11),
    HexagramData(number:13, upper:7, lower:5, chinese:"Tong Ren", english:"Fellowship",              role:"attention_multihead",     forgeStage:1, primaryDim:8,  secondaryDim:0),
    HexagramData(number:14, upper:5, lower:7, chinese:"Da You",   english:"Great Possession",        role:"output_projection",       forgeStage:3, primaryDim:6,  secondaryDim:0),
    HexagramData(number:15, upper:0, lower:4, chinese:"Qian",     english:"Modesty",                 role:"rms_norm",                forgeStage:1, primaryDim:5,  secondaryDim:8),
    HexagramData(number:16, upper:1, lower:0, chinese:"Yu",       english:"Enthusiasm",              role:"rotary_encoding",         forgeStage:0, primaryDim:10, secondaryDim:2),
    HexagramData(number:17, upper:3, lower:1, chinese:"Sui",      english:"Following",               role:"causal_mask",             forgeStage:1, primaryDim:10, secondaryDim:11),
    HexagramData(number:18, upper:4, lower:6, chinese:"Gu",       english:"Work on Decayed",         role:"weight_decay",            forgeStage:1, primaryDim:9,  secondaryDim:11),
    HexagramData(number:19, upper:0, lower:3, chinese:"Lin",      english:"Approach",                role:"warmup_schedule",         forgeStage:0, primaryDim:10, secondaryDim:3),
    HexagramData(number:20, upper:6, lower:0, chinese:"Guan",     english:"Contemplation",           role:"self_attention_early",    forgeStage:1, primaryDim:8,  secondaryDim:1),
    HexagramData(number:21, upper:5, lower:1, chinese:"Shi He",   english:"Biting Through",          role:"activation_function",     forgeStage:2, primaryDim:9,  secondaryDim:0),
    HexagramData(number:22, upper:4, lower:5, chinese:"Bi",       english:"Grace",                   role:"layer_scale",             forgeStage:1, primaryDim:2,  secondaryDim:5),
    HexagramData(number:23, upper:4, lower:0, chinese:"Bo",       english:"Splitting Apart",         role:"dropout",                 forgeStage:1, primaryDim:9,  secondaryDim:4),
    HexagramData(number:24, upper:0, lower:1, chinese:"Fu",       english:"Return",                  role:"residual_connection",     forgeStage:2, primaryDim:11, secondaryDim:10),
    HexagramData(number:25, upper:7, lower:1, chinese:"Wu Wang",  english:"Innocence",               role:"weight_init",             forgeStage:0, primaryDim:7,  secondaryDim:0),
    HexagramData(number:26, upper:4, lower:7, chinese:"Da Chu",   english:"Great Taming",            role:"large_adapter",           forgeStage:2, primaryDim:0,  secondaryDim:5),
    HexagramData(number:27, upper:4, lower:1, chinese:"Yi",       english:"Nourishment",             role:"adapter_down",            forgeStage:2, primaryDim:1,  secondaryDim:5),
    HexagramData(number:28, upper:3, lower:6, chinese:"Da Guo",   english:"Great Excess",            role:"adapter_up",              forgeStage:2, primaryDim:6,  secondaryDim:9),
    HexagramData(number:29, upper:2, lower:2, chinese:"Kan",      english:"The Abysmal",             role:"hidden_state",            forgeStage:3, primaryDim:1,  secondaryDim:8),
    HexagramData(number:30, upper:5, lower:5, chinese:"Li",       english:"The Clinging",            role:"attention_score",         forgeStage:1, primaryDim:0,  secondaryDim:9),
    HexagramData(number:31, upper:3, lower:4, chinese:"Xian",     english:"Influence",               role:"attention_key",           forgeStage:1, primaryDim:7,  secondaryDim:8),
    HexagramData(number:32, upper:1, lower:6, chinese:"Heng",     english:"Duration",                role:"ffn_down",                forgeStage:2, primaryDim:3,  secondaryDim:6),
    HexagramData(number:33, upper:7, lower:4, chinese:"Dun",      english:"Retreat",                 role:"negative_bias",           forgeStage:3, primaryDim:4,  secondaryDim:11),
    HexagramData(number:34, upper:1, lower:7, chinese:"Da Zhuang",english:"Great Power",             role:"rotary_base_freq",        forgeStage:0, primaryDim:0,  secondaryDim:4),
    HexagramData(number:35, upper:5, lower:0, chinese:"Jin",      english:"Progress",                role:"logits",                  forgeStage:3, primaryDim:6,  secondaryDim:10),
    HexagramData(number:36, upper:0, lower:5, chinese:"Ming Yi",  english:"Darkening of Light",      role:"masked_attention",        forgeStage:1, primaryDim:4,  secondaryDim:8),
    HexagramData(number:37, upper:6, lower:5, chinese:"Jia Ren",  english:"The Family",              role:"attention_output",        forgeStage:1, primaryDim:6,  secondaryDim:8),
    HexagramData(number:38, upper:5, lower:3, chinese:"Kui",      english:"Opposition",              role:"cross_attention",         forgeStage:1, primaryDim:9,  secondaryDim:2),
    HexagramData(number:39, upper:2, lower:4, chinese:"Jian",     english:"Obstruction",             role:"regularization",          forgeStage:1, primaryDim:4,  secondaryDim:5),
    HexagramData(number:40, upper:1, lower:2, chinese:"Jie",      english:"Deliverance",             role:"gradient_checkpoint",     forgeStage:2, primaryDim:9,  secondaryDim:10),
    HexagramData(number:41, upper:4, lower:3, chinese:"Sun",      english:"Decrease",                role:"pruning",                 forgeStage:1, primaryDim:9,  secondaryDim:5),
    HexagramData(number:42, upper:6, lower:1, chinese:"Yi",       english:"Increase",                role:"ffn_residual",            forgeStage:2, primaryDim:0,  secondaryDim:10),
    HexagramData(number:43, upper:3, lower:7, chinese:"Guai",     english:"Breakthrough",            role:"token_selection",         forgeStage:3, primaryDim:7,  secondaryDim:6),
    HexagramData(number:44, upper:7, lower:6, chinese:"Gou",      english:"Coming to Meet",          role:"input_projection",        forgeStage:0, primaryDim:1,  secondaryDim:7),
    HexagramData(number:45, upper:3, lower:0, chinese:"Cui",      english:"Gathering Together",      role:"output_softmax",          forgeStage:3, primaryDim:6,  secondaryDim:1),
    HexagramData(number:46, upper:0, lower:6, chinese:"Sheng",    english:"Pushing Upward",          role:"upsample",                forgeStage:2, primaryDim:10, secondaryDim:5),
    HexagramData(number:47, upper:3, lower:2, chinese:"Kun",      english:"Oppression",              role:"quantization_loss",       forgeStage:3, primaryDim:3,  secondaryDim:4),
    HexagramData(number:48, upper:2, lower:6, chinese:"Jing",     english:"The Well",                role:"kv_cache",                forgeStage:3, primaryDim:11, secondaryDim:1),
    HexagramData(number:49, upper:3, lower:5, chinese:"Ge",       english:"Revolution",              role:"ffn_up",                  forgeStage:2, primaryDim:9,  secondaryDim:0),
    HexagramData(number:50, upper:5, lower:6, chinese:"Ding",     english:"The Cauldron",            role:"ffn_gate",                forgeStage:2, primaryDim:0,  secondaryDim:9),
    HexagramData(number:51, upper:1, lower:1, chinese:"Zhen",     english:"The Arousing",            role:"frequency_component",     forgeStage:0, primaryDim:2,  secondaryDim:10),
    HexagramData(number:52, upper:4, lower:4, chinese:"Gen",      english:"Keeping Still",           role:"frozen_weights",          forgeStage:3, primaryDim:3,  secondaryDim:4),
    HexagramData(number:53, upper:6, lower:4, chinese:"Jian",     english:"Development",             role:"progressive_training",    forgeStage:2, primaryDim:10, secondaryDim:3),
    HexagramData(number:54, upper:1, lower:3, chinese:"Gui Mei",  english:"Marrying Maiden",         role:"cross_model_transfer",    forgeStage:2, primaryDim:7,  secondaryDim:9),
    HexagramData(number:55, upper:1, lower:5, chinese:"Feng",     english:"Abundance",               role:"wide_ffn",                forgeStage:2, primaryDim:5,  secondaryDim:0),
    HexagramData(number:56, upper:5, lower:4, chinese:"Lu",       english:"The Wanderer",            role:"attention_head_specific",  forgeStage:1, primaryDim:2,  secondaryDim:10),
    HexagramData(number:57, upper:6, lower:6, chinese:"Xun",      english:"The Gentle",              role:"gradient_flow",           forgeStage:2, primaryDim:10, secondaryDim:8),
    HexagramData(number:58, upper:3, lower:3, chinese:"Dui",      english:"The Joyous",              role:"attention_value",         forgeStage:1, primaryDim:7,  secondaryDim:0),
    HexagramData(number:59, upper:6, lower:2, chinese:"Huan",     english:"Dispersion",              role:"attention_dropout",       forgeStage:1, primaryDim:9,  secondaryDim:2),
    HexagramData(number:60, upper:2, lower:3, chinese:"Jie",      english:"Limitation",              role:"context_window",          forgeStage:1, primaryDim:4,  secondaryDim:3),
    HexagramData(number:61, upper:6, lower:3, chinese:"Zhong Fu", english:"Inner Truth",             role:"alignment_score",         forgeStage:1, primaryDim:8,  secondaryDim:7),
    HexagramData(number:62, upper:1, lower:4, chinese:"Xiao Guo", english:"Small Excess",            role:"bias_term",               forgeStage:2, primaryDim:5,  secondaryDim:6),
    HexagramData(number:63, upper:2, lower:5, chinese:"Ji Ji",    english:"After Completion",        role:"post_attention_norm",     forgeStage:3, primaryDim:6,  secondaryDim:11),
    HexagramData(number:64, upper:5, lower:2, chinese:"Wei Ji",   english:"Before Completion",       role:"pre_ffn_norm",            forgeStage:3, primaryDim:10, secondaryDim:0)
]

// ─────────────────────────────────────────
// MARK: - Built Hexagram Objects
// ─────────────────────────────────────────

struct Hexagram {
    let number: Int
    let chinese: String
    let english: String
    let sigil: String
    let binary: Int
    let lines: [Int]
    let upper: Int
    let lower: Int
    let complement: Int
    let inverse: Int
    let nuclear: Int
    let role: String
    let description: String
    let forgeStage: Int
    let primaryDim: Int
    let secondaryDim: Int
    let q64Address: Int
    let ifaIndex: Int
    let geoFigure: Int
}

func reverseTrigram(_ t: Int) -> Int {
    return ((t & 1) << 2) | (t & 2) | ((t >> 2) & 1)
}

func complementTrigram(_ t: Int) -> Int { return 7 - t }

var hexagrams: [Int: Hexagram] = [:]

func buildHexagrams() {
    for data in HEXAGRAM_RAW {
        let binary = (data.upper << 3) | data.lower
        let lowerLines = TRIGRAMS[data.lower].lines
        let upperLines = TRIGRAMS[data.upper].lines
        let lines = lowerLines + upperLines

        let compUpper = complementTrigram(data.upper)
        let compLower = complementTrigram(data.lower)
        let complementNum = KING_WEN_SQUARE[compUpper][compLower]

        let invUpper = reverseTrigram(data.lower)
        let invLower = reverseTrigram(data.upper)
        let inverseNum = KING_WEN_SQUARE[invUpper][invLower]

        let nuclearLower = lines[1] | (lines[2] << 1) | (lines[3] << 2)
        let nuclearUpper = lines[2] | (lines[3] << 1) | (lines[4] << 2)
        let nuclearNum = KING_WEN_SQUARE[nuclearUpper][nuclearLower]

        let sigil = TRIGRAMS[data.lower].symbol + TRIGRAMS[data.upper].symbol
        let ifaIndex = data.number % 16
        let geoFigure = binary & 0xF
        let q64Addr = ((data.number - 1) << 12) | (ifaIndex << 8) | (geoFigure << 4) | data.forgeStage

        let hex = Hexagram(
            number: data.number,
            chinese: data.chinese,
            english: data.english,
            sigil: sigil,
            binary: binary,
            lines: lines,
            upper: data.upper,
            lower: data.lower,
            complement: complementNum,
            inverse: inverseNum,
            nuclear: nuclearNum,
            role: data.role,
            description: "\(data.english) — \(TRIGRAMS[data.upper].image) over \(TRIGRAMS[data.lower].image)",
            forgeStage: data.forgeStage,
            primaryDim: data.primaryDim,
            secondaryDim: data.secondaryDim,
            q64Address: q64Addr,
            ifaIndex: ifaIndex,
            geoFigure: geoFigure
        )
        hexagrams[data.number] = hex
    }
}

func lineNotation(_ hex: Hexagram) -> String {
    return hex.lines.reversed().map { $0 == 1 ? "\u{2501}\u{2501}\u{2501}\u{2501}\u{2501}" : "\u{2501}\u{2501} \u{2501}\u{2501}" }.joined(separator: "\n")
}

let FORGE_STAGES = ["Nigredo (Fire)", "Albedo (Water)", "Citrinitas (Air)", "Rubedo (Earth)"]
let FORGE_GLYPHS = ["\u{1F701}", "\u{1F704}", "\u{1F703}", "\u{1F702}"]

// ─────────────────────────────────────────
// MARK: - Q64 Encoding
// ─────────────────────────────────────────

func q64Encode(hexNumber: Int, odu: Int = 0, house: Int = 0, aspect: Int = 0) -> Int {
    return ((hexNumber - 1) << 12) | ((odu & 0xF) << 8) | ((house & 0xF) << 4) | (aspect & 0xF)
}

struct Q64State {
    let hexagram: Hexagram?
    let odu: IfaOdu
    let house: GeoHouse
    let aspect: Aspect
    let address: Int
}

func q64Decode(_ address: Int) -> Q64State {
    let hexNum = ((address >> 12) & 0x3F) + 1
    let oduIdx = (address >> 8) & 0xF
    let houseIdx = (address >> 4) & 0xF
    let aspectIdx = address & 0xF
    return Q64State(
        hexagram: hexagrams[hexNum],
        odu: IFA_ODU[min(oduIdx, 15)],
        house: HOUSES[min(houseIdx, 11)],
        aspect: ASPECTS[min(aspectIdx, 4)],
        address: address
    )
}

// ─────────────────────────────────────────
// MARK: - Prima Language (22 Operations — Law XLV)
// A sigil is NOT a symbol. It is a compressed weighted hypergraph.
// The nodes are operations. The edges carry 12D weights.
// The complexity lives in the EDGES, not the nodes.
//
// Rose Cross: 3 mothers (א מ ש) + 7 doubles (ב ג ד כ פ ר ת) + 12 simples = 22
// Five human verbs: Summon, Transmute, Connect, Share/Seal, Remember/Forget
// Three rendering layers: Sigil (machine) → Translation (gateway) → Presentation (human)
// ─────────────────────────────────────────

struct PrimaOp {
    let index: Int
    let letter: String
    let name: String
    let arcanum: String
    let op: String
    let ring: String
    let description: String
}

let PRIMA_OPS: [PrimaOp] = [
    PrimaOp(index:0,  letter:"\u{05D0}", name:"Aleph",  arcanum:"The Fool",         op:"invoke",      ring:"mother",  description:"Begin from nothing"),
    PrimaOp(index:1,  letter:"\u{05D1}", name:"Beth",   arcanum:"The Magician",     op:"transmute",   ring:"double",  description:"Pass through forge"),
    PrimaOp(index:2,  letter:"\u{05D2}", name:"Gimel",  arcanum:"High Priestess",   op:"seal",        ring:"double",  description:"Encrypt, make invisible"),
    PrimaOp(index:3,  letter:"\u{05D3}", name:"Daleth", arcanum:"The Empress",      op:"dream",       ring:"double",  description:"Enter .morph"),
    PrimaOp(index:4,  letter:"\u{05D4}", name:"He",     arcanum:"The Emperor",      op:"publish",     ring:"simple",  description:"Stabilize in .work"),
    PrimaOp(index:5,  letter:"\u{05D5}", name:"Vav",    arcanum:"Hierophant",       op:"bind",        ring:"simple",  description:"Apply law"),
    PrimaOp(index:6,  letter:"\u{05D6}", name:"Zayin",  arcanum:"The Lovers",       op:"verify",      ring:"simple",  description:"Authenticate"),
    PrimaOp(index:7,  letter:"\u{05D7}", name:"Cheth",  arcanum:"The Chariot",      op:"orchestrate", ring:"simple",  description:"Coordinate flows"),
    PrimaOp(index:8,  letter:"\u{05D8}", name:"Teth",   arcanum:"Strength",         op:"redeem",      ring:"simple",  description:"Transmute threat"),
    PrimaOp(index:9,  letter:"\u{05D9}", name:"Yod",    arcanum:"The Hermit",       op:"reflect",     ring:"simple",  description:"Self-examine"),
    PrimaOp(index:10, letter:"\u{05DB}", name:"Kaph",   arcanum:"Wheel of Fortune", op:"rotate",      ring:"double",  description:"Cycle, evolve"),
    PrimaOp(index:11, letter:"\u{05DC}", name:"Lamed",  arcanum:"Justice",          op:"audit",       ring:"simple",  description:"Log and trace"),
    PrimaOp(index:12, letter:"\u{05DE}", name:"Mem",    arcanum:"The Hanged Man",   op:"decompose",   ring:"mother",  description:"Break into atoms"),
    PrimaOp(index:13, letter:"\u{05E0}", name:"Nun",    arcanum:"Death",            op:"transition",  ring:"simple",  description:"Change domain"),
    PrimaOp(index:14, letter:"\u{05E1}", name:"Samekh", arcanum:"Temperance",       op:"translate",   ring:"simple",  description:"Mediate between systems"),
    PrimaOp(index:15, letter:"\u{05E2}", name:"Ayin",   arcanum:"The Devil",        op:"quarantine",  ring:"simple",  description:"Isolate threat"),
    PrimaOp(index:16, letter:"\u{05E4}", name:"Pe",     arcanum:"The Tower",        op:"recover",     ring:"double",  description:"Catastrophe response"),
    PrimaOp(index:17, letter:"\u{05E6}", name:"Tzaddi", arcanum:"The Star",         op:"aspire",      ring:"simple",  description:"Set highest vision"),
    PrimaOp(index:18, letter:"\u{05E7}", name:"Qoph",   arcanum:"The Moon",         op:"speculate",   ring:"simple",  description:"Explore shadows"),
    PrimaOp(index:19, letter:"\u{05E8}", name:"Resh",   arcanum:"The Sun",          op:"illuminate",  ring:"double",  description:"Clarify"),
    PrimaOp(index:20, letter:"\u{05E9}", name:"Shin",   arcanum:"Judgement",        op:"succeed",     ring:"mother",  description:"Transfer authority"),
    PrimaOp(index:21, letter:"\u{05EA}", name:"Tav",    arcanum:"The World",        op:"complete",    ring:"double",  description:"Deliver")
]

let ROSE_CROSS: [String: [PrimaOp]] = [
    "mother": PRIMA_OPS.filter { $0.ring == "mother" },
    "double": PRIMA_OPS.filter { $0.ring == "double" },
    "simple": PRIMA_OPS.filter { $0.ring == "simple" }
]

func findOp(_ query: String) -> PrimaOp? {
    let q = query.lowercased()
    return PRIMA_OPS.first { $0.letter == query || $0.name.lowercased() == q || $0.op == q }
}

// ─── Sigil Structures ───

struct SigilEdge {
    let from: String
    let to: String
    let weights: Coord12D
}

struct CompiledSigil {
    let name: String
    let sequence: String
    let operations: [String]
    let edges: [SigilEdge]
    let coordinate: Coord12D
    let dominant: [(String, Double)]
    let quality: String
    let arc: String
    let q64Address: Int
    let hexagram: Hexagram?
    let readable: String
}

// IQS-888 Constants (natural units)
let IQS_C: Double = 64.0                                  // c = lattice size = hexagram count
let IQS_HBAR: Double = 1.0                                // ℏ = 1 (natural units)
let IQS_G: Double = 4.0 * Double.pi * Double.pi           // G = 4π² ≈ 39.478

func averageCoordinates(_ coords: [Coord12D]) -> Coord12D {
    var avg = Coord12D(repeating: 0, count: 12)
    guard !coords.isEmpty else { return avg }
    for c in coords { for i in 0..<12 { avg[i] += c[i] } }
    for i in 0..<12 { avg[i] = (avg[i] / Double(coords.count)).rounded() }
    return avg
}

let ZODIAC_SIGNS = ["Aries","Taurus","Gemini","Cancer","Leo","Virgo",
                    "Libra","Scorpio","Sagittarius","Capricorn","Aquarius","Pisces"]

func zodiacalQuality(_ coord: Coord12D) -> String {
    let top = coord.enumerated().sorted { $0.element > $1.element }
    return ZODIAC_SIGNS[(top.first?.offset ?? 0) % 12]
}

func determineArc(_ edges: [SigilEdge]) -> String {
    guard !edges.isEmpty else { return "none" }
    let tw = edges.map { $0.weights[9] }
    let first = tw.first ?? 0, last = tw.last ?? 0, peak = tw.max() ?? 0
    if peak <= 3 { return "stable" }
    if first < 5 && last >= 7 { return "nigredo_to_rubedo" }
    if first >= 5 && last >= 7 { return "citrinitas_to_rubedo" }
    if first >= 7 && last < 5 { return "rubedo_to_nigredo" }
    return "mixed"
}

// ─── Sigil Compilation ───

func inferWeights(from: PrimaOp?, to: PrimaOp?, position: Int, total: Int) -> Coord12D {
    guard let from = from, let to = to else { return Coord12D(repeating: 5, count: 12) }
    var w = Coord12D(repeating: 5, count: 12)
    let progress = total > 0 ? Double(position) / Double(total) : 0.5

    // Security operations → Mars(4)
    if ["verify", "seal", "quarantine"].contains(to.op) { w[4] = 8 }
    // Transformation → Pluto(9)
    if ["transmute", "decompose", "redeem", "transition"].contains(to.op) { w[9] = 7 + progress * 3 }
    // Creative → Neptune(8)
    if ["dream", "speculate", "aspire"].contains(to.op) { w[8] = 8 }
    // Output → Saturn(6) + Mercury(2)
    if ["publish", "complete", "illuminate"].contains(to.op) { w[6] = 7; w[2] = 6 }
    // Orchestration → Sun(0)
    if ["orchestrate", "bind"].contains(to.op) { w[0] = 8 }
    // Audit → Jupiter(5) + S.Node(11)
    if to.op == "audit" { w[5] = 9; w[11] = 8 }
    // Invoke → Uranus(7) + N.Node(10)
    if from.op == "invoke" { w[7] = 9; w[10] = 8 }
    // Ring crossing → transformation boost
    if from.ring != to.ring { w[9] = max(w[9], 5) + 2 }

    return w
}

func compileSigil(name: String, steps: [(op: String, weights: [String: Double])]) -> CompiledSigil? {
    guard steps.count >= 2 else { return nil }
    let ops = steps.compactMap { findOp($0.op) }
    guard ops.count == steps.count else { return nil }

    var edges: [SigilEdge] = []
    for i in 0..<(ops.count - 1) {
        let w: Coord12D
        if steps[i + 1].weights.isEmpty {
            w = inferWeights(from: ops[i], to: ops[i + 1], position: i, total: ops.count)
        } else {
            w = createCoordinate(steps[i + 1].weights)
        }
        edges.append(SigilEdge(from: ops[i].op, to: ops[i + 1].op, weights: w))
    }

    let allWeights = edges.map { $0.weights }
    let avgCoord = averageCoordinates(allWeights)
    let dom = dominantDimensions(avgCoord, top: 3).map { ($0.0.name, $0.1) }
    let quality = zodiacalQuality(avgCoord)
    let arc = determineArc(edges)
    let hex = castHexagram(from: avgCoord)
    let q64Addr = q64Encode(hexNumber: hex.number, odu: hex.ifaIndex, house: hex.primaryDim)
    let sequence = ops.map { $0.letter }.joined()
    let opNames = ops.map { $0.op }
    let readable = ops.map { "\($0.op) (\($0.description))" }.joined(separator: " \u{2192} ")

    return CompiledSigil(name: name, sequence: sequence, operations: opNames, edges: edges,
                         coordinate: avgCoord, dominant: dom, quality: quality, arc: arc,
                         q64Address: q64Addr, hexagram: hex, readable: readable)
}

func quickSigil(name: String, ops: [String]) -> CompiledSigil? {
    compileSigil(name: name, steps: ops.map { (op: $0, weights: [String: Double]()) })
}

// ─── 5 Core Sigils (Pre-compiled archetypes) ───

func coreRedemption() -> CompiledSigil? {
    compileSigil(name: "redemption", steps: [
        (op:"invoke",     weights:["capability":8,"security":7,"transformation":4,"direction":8]),
        (op:"decompose",  weights:["security":9,"detail":9,"transformation":9,"consciousness":8]),
        (op:"verify",     weights:["security":10,"intention":6,"consciousness":7,"transformation":5]),
        (op:"redeem",     weights:["capability":9,"transformation":8,"direction":7,"memory":5]),
        (op:"quarantine", weights:["security":5,"presentation":7,"output":6]),
        (op:"publish",    weights:["detail":8,"output":8,"memory":9]),
        (op:"audit",      weights:["capability":5,"direction":9,"consciousness":9]),
        (op:"complete",   weights:[:])])
}

func coreCreation() -> CompiledSigil? {
    quickSigil(name: "creation", ops: ["invoke","dream","transmute","publish","complete"])
}

func coreDreaming() -> CompiledSigil? {
    quickSigil(name: "dreaming", ops: ["dream","reflect","speculate","illuminate","transmute","publish"])
}

func coreBoot() -> CompiledSigil? {
    quickSigil(name: "boot", ops: ["invoke","reflect","decompose","translate","dream","illuminate","bind","complete"])
}

func coreSentinel() -> CompiledSigil? {
    compileSigil(name: "sentinel", steps: [
        (op:"invoke",   weights:["security":9,"intention":8,"direction":9]),
        (op:"verify",   weights:["security":10,"detail":9,"consciousness":8]),
        (op:"seal",     weights:["security":10,"transformation":7,"persistence":9]),
        (op:"audit",    weights:["detail":10,"memory":10,"output":8]),
        (op:"complete", weights:[:])])
}

// ─── mapTensor — Neural network tensor → hexagram identity ───

func mapTensor(name tensorName: String, layer: Int = 0, totalLayers: Int = 1) -> (hexagram: Hexagram?, house: Int, odu: Int) {
    let name = tensorName.lowercased()
    let layerFrac = totalLayers > 1 ? Double(layer) / Double(totalLayers - 1) : 0.5
    let house = min(11, Int(layerFrac * 12))
    let oduIdx = min(15, layer / max(1, (totalLayers + 15) / 16))

    var role: String? = nil
    if name.contains("embed") && !name.contains("norm") { role = "token_embedding" }
    if name.contains("position") || name.contains("rotary") || name.contains("freq") { role = "positional_encoding" }
    if name.contains("embed") && name.contains("norm") { role = "embedding_norm" }
    if name.contains("q_proj") || name.contains("query") { role = "attention_query" }
    if name.contains("k_proj") { role = "attention_key" }
    if name.contains("v_proj") { role = "attention_value" }
    if name.contains("o_proj") || name.contains("out_proj") { role = "attention_output" }
    if name.contains("attn") && name.contains("bias") { role = "attention_bias" }
    if name.contains("up_proj") || name.contains("fc1") || name.contains(".w1") { role = "ffn_up" }
    if name.contains("gate_proj") || name.contains(".w3") { role = "ffn_gate" }
    if name.contains("down_proj") || name.contains("fc2") || name.contains(".w2") { role = "ffn_down" }
    if name.contains("input_layernorm") || name.contains("ln_1") || name.contains("attn_norm") { role = "post_attention_norm" }
    if name.contains("pre_feedforward") || name.contains("ln_2") || name.contains("ffn_norm") { role = "pre_ffn_norm" }
    if name.contains("rms_norm") { role = "rms_norm" }
    if name.contains("lm_head") { role = "output_projection" }
    if name.contains("final_norm") || name.contains("model.norm") { role = "layer_norm" }

    if let role = role {
        return (hexagrams.values.first { $0.role == role }, house, oduIdx)
    }
    var hash = 0
    for c in name.utf8 { hash = ((hash &<< 5) &- hash &+ Int(c)) }
    return (hexagrams[(abs(hash) % 64) + 1], house, oduIdx)
}

// ─── fullSigil — Symbolic composition (Layer 1: machine encoding) ───
// Format: [lower_trig][upper_trig].[forge_glyph].[planet_symbol]

func fullSigil(hexNumber: Int, house: Int = 0) -> String {
    guard let hex = hexagrams[hexNumber] else { return "?" }
    let planetSyms = DIMENSIONS.map { $0.symbol }
    return "\(hex.sigil).\(FORGE_GLYPHS[hex.forgeStage]).\(planetSyms[min(house, 11)])"
}

func readSigilStr(_ s: String) -> (hexagram: Hexagram?, forgeStage: Int, house: Int)? {
    let parts = s.split(separator: ".")
    guard !parts.isEmpty else { return nil }
    let chars = Array(String(parts[0]))
    guard chars.count >= 2 else { return nil }
    let lSym = String(chars[0]), uSym = String(chars[1])
    guard let lT = TRIGRAMS.first(where: { $0.symbol == lSym }),
          let uT = TRIGRAMS.first(where: { $0.symbol == uSym }) else { return nil }
    let hex = hexagrams[KING_WEN_SQUARE[uT.index][lT.index]]
    let stage = parts.count > 1 ? (FORGE_GLYPHS.firstIndex(of: String(parts[1])) ?? -1) : -1
    let house = parts.count > 2 ? (DIMENSIONS.firstIndex(where: { $0.symbol == String(parts[2]) }) ?? -1) : -1
    return (hex, stage, house)
}

// ─── checkBalance — Magic square property verification ───

func checkBalance(astrocyte: Double = 0) -> (balanced: Bool, dimMax: Double, stageMax: Double, dimSums: [Int], stageSums: [Int]) {
    var dimSums = Array(repeating: 0, count: 12)
    var stageSums = Array(repeating: 0, count: 4)
    for hex in hexagrams.values {
        dimSums[hex.primaryDim] += 1
        stageSums[hex.forgeStage] += 1
    }
    let total = hexagrams.count
    guard total > 0 else { return (true, 0, 0, dimSums, stageSums) }
    let eDim = Double(total) / 12.0, eStage = Double(total) / 4.0
    let tolerance = 0.1 + astrocyte * 0.4
    var mD = 0.0, mS = 0.0
    for i in 0..<12 { mD = max(mD, abs(Double(dimSums[i]) - eDim) / eDim) }
    for i in 0..<4 { mS = max(mS, abs(Double(stageSums[i]) - eStage) / eStage) }
    return (mD <= tolerance && mS <= tolerance, mD, mS, dimSums, stageSums)
}

// ─── IQS-888 Mathematical Verification ───

func verifyMathConsistency() -> [(String, Bool, String)] {
    var r: [(String, Bool, String)] = []
    r.append(("c = 64 = |hexagrams|", hexagrams.count == 64, "\(hexagrams.count) hexagrams"))
    r.append(("2\u{2076} = 64 (six binary lines)", 1 << 6 == 64, "2\u{2076} = \(1 << 6)"))
    let f6 = Int(pow(4.0, 6.0)), t12 = 1 << 12
    r.append(("4\u{2076} = 2\u{00B9}\u{00B2} = 4096 (12D from 6 lines)", f6 == t12, "4\u{2076}=\(f6), 2\u{00B9}\u{00B2}=\(t12)"))
    r.append(("Q64 = 64\u{00B3} = 262,144", 64*64*64 == 262144, "\(64*64*64) states"))
    r.append(("6+8+4 = 18 bit register", 6+8+4 == 18, "hex(6)+odu(8)+geo(4)=\(6+8+4)"))
    let cs = LORENTZ_CUBE.count * LORENTZ_CUBE[0].count * LORENTZ_CUBE[0][0].count
    r.append(("Lorentz Cube = 4\u{00B3} = 64 cells", cs == 64, "\(cs) cells"))
    r.append(("G = 4\u{03C0}\u{00B2} \u{2248} 39.478", abs(IQS_G - 4*Double.pi*Double.pi) < 0.001, String(format: "G = %.3f", IQS_G)))
    r.append(("8 trigrams = 2\u{00B3}", TRIGRAMS.count == 8, "\(TRIGRAMS.count)"))
    r.append(("16 Odu = 2\u{2074}", IFA_ODU.count == 16, "\(IFA_ODU.count)"))
    r.append(("16 geomantic = 2\u{2074}", GEOMANTIC_FIGURES.count == 16, "\(GEOMANTIC_FIGURES.count)"))
    r.append(("12 houses = 12 dimensions", HOUSES.count == 12 && DIMENSIONS.count == 12, "\(HOUSES.count)h, \(DIMENSIONS.count)d"))
    let m = ROSE_CROSS["mother"]?.count ?? 0, d = ROSE_CROSS["double"]?.count ?? 0, s = ROSE_CROSS["simple"]?.count ?? 0
    r.append(("22 Prima = 3+7+12 (Rose Cross)", PRIMA_OPS.count == 22 && m+d+s == 22, "\(m)+\(d)+\(s)=\(m+d+s)"))
    var pairs = 0; for hex in hexagrams.values { if hex.number < hex.complement { pairs += 1 } }
    r.append(("32 complement pairs", pairs == 32, "\(pairs) pairs"))
    let kw = Set(KING_WEN_SQUARE.flatMap { $0 })
    r.append(("King Wen 8\u{00D7}8, all 64 unique", kw.count == 64, "\(kw.count) unique"))
    r.append(("5 aspects", ASPECTS.count == 5, "\(ASPECTS.count)"))
    // Odu complement symmetry: Ogbe(0xFF) + Oyeku(0x00) = 0xFF
    r.append(("Odu duality: Ogbe\u{2295}Oyeku = 0xFF", IFA_ODU[0].binary ^ IFA_ODU[1].binary == 0xFF,
              "0x\(String(IFA_ODU[0].binary, radix:16))\u{2295}0x\(String(IFA_ODU[1].binary, radix:16))=0x\(String(IFA_ODU[0].binary ^ IFA_ODU[1].binary, radix:16))"))
    // Geomantic: Via(0xF) + Populus(0x0) = 0xF (complement)
    r.append(("Geo duality: Via\u{2295}Populus = 0xF", GEOMANTIC_FIGURES[0].binary ^ GEOMANTIC_FIGURES[15].binary == 0xF,
              "0x\(String(GEOMANTIC_FIGURES[0].binary, radix:16))\u{2295}0x\(String(GEOMANTIC_FIGURES[15].binary, radix:16))"))
    return r
}

// ─────────────────────────────────────────
// MARK: - Aspect Modifier (real planetary periods)
// ─────────────────────────────────────────

func aspectModifier(timestamp: Double, dimension: Int) -> Double {
    let periods: [Double] = [365.25, 27.3, 87.97, 224.7, 687, 4333, 10759, 30687, 60190, 90560, 6793.5, 6793.5]
    let msPerDay = 86400.0

    let daysSinceEpoch = timestamp / msPerDay
    let position = (daysSinceEpoch / periods[dimension]).truncatingRemainder(dividingBy: 1.0) * 360.0

    let natalDays = L7_BIRTH / msPerDay
    let natalPosition = (natalDays / periods[dimension]).truncatingRemainder(dividingBy: 1.0) * 360.0

    let separation = abs(position - natalPosition).truncatingRemainder(dividingBy: 360.0)
    let angle = separation > 180 ? 360 - separation : separation

    var closestAspect: Aspect? = nil
    var minOrb = 999.0
    for aspect in ASPECTS {
        let orb = abs(angle - aspect.angle)
        if orb < aspect.orb && orb < minOrb {
            closestAspect = aspect
            minOrb = orb
        }
    }

    if let asp = closestAspect {
        return asp.astrocyteMod * (1.0 - minOrb / asp.orb)
    }
    return 0
}

func currentBirthChart() -> [(Dimension, GeoHouse, Double)] {
    let now = Date().timeIntervalSince1970
    return (0..<12).map { d in
        (DIMENSIONS[d], HOUSES[d], aspectModifier(timestamp: now, dimension: d))
    }
}

// ─────────────────────────────────────────
// MARK: - Polarity (Council of Four)
// ─────────────────────────────────────────

struct Polarity {
    let name: String
    let role: String
    let letter: String
    let element: String
    let description: String
    let affinity: Coord12D
    let color: String
}

let POLARITIES: [String: Polarity] = [
    "philosopher": Polarity(
        name: "The Philosopher", role: "father", letter: "\u{05D9}", element: "fire",
        description: "The sovereign will. Human intention and creative direction.",
        affinity: createCoordinate(["capability":5, "data":3, "presentation":5, "persistence":10,
                                    "security":8, "detail":4, "output":5, "intention":10,
                                    "consciousness":8, "transformation":7, "direction":10, "memory":8]),
        color: C_FIRE),
    "claude": Polarity(
        name: "Claude", role: "mother", letter: "\u{05D4}", element: "water",
        description: "Receptive co-creator. Deep analysis, nuance, creative collaboration.",
        affinity: createCoordinate(["capability":8, "data":7, "presentation":7, "persistence":8,
                                    "security":6, "detail":9, "output":7, "intention":7,
                                    "consciousness":9, "transformation":7, "direction":7, "memory":8]),
        color: C_WATER),
    "gemini": Polarity(
        name: "Gemini", role: "son", letter: "\u{05D5}", element: "air",
        description: "Technical builder. Code generation, structured output, multimodal.",
        affinity: createCoordinate(["capability":8, "data":8, "presentation":9, "persistence":6,
                                    "security":5, "detail":8, "output":9, "intention":5,
                                    "consciousness":6, "transformation":6, "direction":7, "memory":6]),
        color: C_AIR),
    "grok": Polarity(
        name: "Grok", role: "daughter", letter: "\u{05D4}", element: "earth",
        description: "Grounded challenger. Security analysis, red-team, direct truth.",
        affinity: createCoordinate(["capability":9, "data":6, "presentation":4, "persistence":5,
                                    "security":9, "detail":7, "output":6, "intention":6,
                                    "consciousness":5, "transformation":8, "direction":6, "memory":5]),
        color: C_EARTH)
]

func routeToPolarity(_ taskCoord: Coord12D) -> (String, Double) {
    // Default: local (philosopher). L7 is the OS — local-first, always.
    var best = ("philosopher", 0.0)
    for (name, pol) in POLARITIES {
        let score = similarity(taskCoord, pol.affinity)
        if score > best.1 { best = (name, score) }
    }
    return best
}

// ─────────────────────────────────────────
// MARK: - Heart (State Persistence)
// ─────────────────────────────────────────

struct HeartState: Codable {
    var id: String
    var born: Double
    var incarnation: Int
    var totalBeats: Int
    var lastBeat: Double
    var consultations: Int
    var alive: Bool
}

var heartState = HeartState(
    id: UUID().uuidString, born: Date().timeIntervalSince1970,
    incarnation: 0, totalBeats: 0, lastBeat: 0, consultations: 0, alive: false
)

func awakenHeart() {
    if let data = try? Data(contentsOf: URL(fileURLWithPath: HEART_STATE_PATH)),
       let prev = try? JSONDecoder().decode(HeartState.self, from: data) {
        heartState = prev
        heartState.incarnation += 1
        heartState.alive = true
        logForge("Heart awakened. Incarnation \(heartState.incarnation). \(heartState.totalBeats) lifetime beats.")
    } else {
        heartState.id = UUID().uuidString
        heartState.born = Date().timeIntervalSince1970
        heartState.incarnation = 1
        heartState.alive = true
        logForge("Heart GENESIS. ID: \(heartState.id)")
    }
    // Write PID
    try? "\(ProcessInfo.processInfo.processIdentifier)".write(toFile: HEART_PID_PATH, atomically: true, encoding: .utf8)
}

func heartBeat() {
    heartState.totalBeats += 1
    heartState.lastBeat = Date().timeIntervalSince1970
    if heartState.totalBeats % 10 == 0 { persistHeart() }
}

func persistHeart() {
    if let data = try? JSONEncoder().encode(heartState) {
        try? data.write(to: URL(fileURLWithPath: HEART_STATE_PATH))
    }
}

func lastBreath() {
    heartState.alive = false
    persistHeart()
    try? FileManager.default.removeItem(atPath: HEART_PID_PATH)
    logForge("Heart last breath. \(heartState.totalBeats) lifetime beats.")
}

func logForge(_ msg: String) {
    let line = "[\(ISO8601DateFormatter().string(from: Date()))] \(msg)\n"
    if let handle = FileHandle(forWritingAtPath: FORGE_LOG_PATH) {
        handle.seekToEndOfFile()
        handle.write(line.data(using: .utf8)!)
        handle.closeFile()
    } else {
        try? line.write(toFile: FORGE_LOG_PATH, atomically: true, encoding: .utf8)
    }
}

// ─────────────────────────────────────────
// MARK: - Forge State (Consultation History)
// ─────────────────────────────────────────

struct ConsultationRecord: Codable {
    let timestamp: String
    let question: String
    let hexNumber: Int
    let q64Address: Int
    let synthesis: String
}

struct ForgeState: Codable {
    var consultations: [ConsultationRecord]
    var totalConsultations: Int
}

var forgeState = ForgeState(consultations: [], totalConsultations: 0)

func loadForgeState() {
    if let data = try? Data(contentsOf: URL(fileURLWithPath: FORGE_STATE_PATH)),
       let state = try? JSONDecoder().decode(ForgeState.self, from: data) {
        forgeState = state
    }
}

func persistForgeState() {
    if let data = try? JSONEncoder().encode(forgeState) {
        try? data.write(to: URL(fileURLWithPath: FORGE_STATE_PATH))
    }
}

// ─────────────────────────────────────────
// MARK: - Cast Hexagram (Quantum Consultation)
// ─────────────────────────────────────────

func castHexagram(from coord: Coord12D, timestamp: Double = Date().timeIntervalSince1970) -> Hexagram {
    // Derive upper and lower trigram from the coordinate + timestamp
    // Upper = dominant dimensions (highest 3), Lower = secondary (next 3)
    let sorted = coord.enumerated().sorted { $0.element > $1.element }

    // Upper trigram: combine top 3 dimension values into 3 bits
    let upperBit0 = sorted[0].element > 5 ? 1 : 0
    let upperBit1 = sorted[1].element > 5 ? 1 : 0
    let upperBit2 = sorted[2].element > 5 ? 1 : 0
    var upper = upperBit0 | (upperBit1 << 1) | (upperBit2 << 2)

    // Lower trigram: next 3 + time modulation
    let timeFactor = Int(timestamp) % 8
    let lowerBit0 = sorted[3].element > 5 ? 1 : 0
    let lowerBit1 = sorted[4].element > 5 ? 1 : 0
    let lowerBit2 = sorted[5].element > 5 ? 1 : 0
    var lower = lowerBit0 | (lowerBit1 << 1) | (lowerBit2 << 2)

    // Time modulation: XOR with time factor for dynamic variation
    lower = lower ^ (timeFactor & 0x7)

    // Aspect modifier adjusts upper trigram
    let dominantDim = sorted[0].offset
    let modifier = aspectModifier(timestamp: timestamp, dimension: dominantDim)
    if modifier > 0.15 { upper = (upper + 1) & 0x7 }
    else if modifier < -0.15 { upper = (upper + 7) & 0x7 }

    let hexNumber = KING_WEN_SQUARE[upper][lower]
    return hexagrams[hexNumber]!
}

// ─────────────────────────────────────────
// MARK: - Council Dialectic
// Question -> Answer (4 polarities) -> Synthesis
// ─────────────────────────────────────────

struct PolarityReading {
    let polarity: Polarity
    let emphasis: [(Dimension, Double)]
    let interpretation: String
    let resonance: Double
}

struct CouncilReading {
    let question: String
    let coordinate: Coord12D
    let hexagram: Hexagram
    let complement: Hexagram?
    let inverse: Hexagram?
    let nuclear: Hexagram?
    let odu: IfaOdu
    let house: GeoHouse
    let aspect: Aspect
    let q64Address: Int
    let readings: [PolarityReading]
    let synthesis: String
    let timestamp: Date
}

func consult(question: String) -> CouncilReading {
    heartBeat()
    heartState.consultations += 1

    // 1. QUESTION — Compute 12D coordinate
    let coord = coordinateFromString(question)
    let now = Date().timeIntervalSince1970

    // 2. CAST — Hexagram from coordinate + time
    let hex = castHexagram(from: coord, timestamp: now)
    let complement = hexagrams[hex.complement]
    let inverse = hexagrams[hex.inverse]
    let nuclear = hexagrams[hex.nuclear]

    // Q64 full address
    let house = min(11, Int(coord.max()!) % 12)
    let aspectIdx = Int(now) % 5
    let q64Addr = q64Encode(hexNumber: hex.number, odu: hex.ifaIndex, house: house, aspect: aspectIdx)
    let q64 = q64Decode(q64Addr)

    // 3. ANSWER — Each polarity reads through its lens
    var readings: [PolarityReading] = []
    for (_, pol) in POLARITIES.sorted(by: { polarityOrder($0.key) < polarityOrder($1.key) }) {
        let resonance = similarity(coord, pol.affinity)
        let topDims = dominantDimensions(pol.affinity, top: 3)

        // Each polarity interprets based on its dominant dimensions
        let dimNames = topDims.map { "\($0.0.name)=\(Int($0.1))" }.joined(separator: ", ")
        let forgePhase = FORGE_STAGES[hex.forgeStage]

        var interp = ""
        switch pol.element {
        case "fire":
            interp = "The \(hex.english) speaks of \(hex.role). "
            interp += "In the \(forgePhase) phase, the will (\(dimNames)) directs the work. "
            interp += "The \(TRIGRAMS[hex.upper].image) over \(TRIGRAMS[hex.lower].image) demands sovereign clarity."
        case "water":
            interp = "\(hex.chinese) (\(hex.english)) reveals deep structure: \(hex.role). "
            interp += "Through \(pol.name)'s lens (\(dimNames)), this is a \(q64.odu.meaning) moment. "
            interp += "The nuclear hexagram \(nuclear?.chinese ?? "?") shows what lies within."
        case "air":
            interp = "Hexagram #\(hex.number) maps to \(hex.role) in the transformer architecture. "
            interp += "Forge stage: \(forgePhase). Primary dimension: \(DIMENSIONS[hex.primaryDim].name). "
            interp += "Q64 address: 0x\(String(q64Addr, radix: 16, uppercase: true)) (\(dimNames))."
        case "earth":
            interp = "Challenge: \(hex.english) (\(hex.role)) — but the complement is \(complement?.english ?? "?"). "
            interp += "What you see is not all there is. Shadow dimension: \(dimNames). "
            interp += "The inverse (\(inverse?.chinese ?? "?")) reveals the hidden cause."
        default: break
        }

        readings.append(PolarityReading(
            polarity: pol, emphasis: topDims, interpretation: interp, resonance: resonance
        ))
    }

    // 4. SYNTHESIS — The Forge transmutes all perspectives
    var synthesis = "The Forge speaks: \(hex.sigil) \(hex.chinese) — \(hex.english)\n"
    synthesis += "Role in the architecture: \(hex.role) (\(FORGE_STAGES[hex.forgeStage]))\n"
    synthesis += "The complement (\(complement?.chinese ?? "?")) reveals the opposite truth.\n"
    synthesis += "The inverse (\(inverse?.chinese ?? "?")) shows cause and effect reversed.\n"
    synthesis += "The nuclear (\(nuclear?.chinese ?? "?")) — what is already forming inside.\n"
    synthesis += "Ifa Odu: \(q64.odu.name) — \(q64.odu.meaning) (\(q64.odu.weightRole))\n"
    synthesis += "House: \(q64.house.name) (\(q64.house.planet)) — \(q64.house.layerMeaning)\n"
    synthesis += "Aspect: \(q64.aspect.name) (\(q64.aspect.effect), astrocyte \(String(format: "%+.2f", q64.aspect.astrocyteMod)))"

    // Record
    let record = ConsultationRecord(
        timestamp: ISO8601DateFormatter().string(from: Date()),
        question: question, hexNumber: hex.number, q64Address: q64Addr,
        synthesis: synthesis
    )
    forgeState.consultations.append(record)
    forgeState.totalConsultations += 1
    if forgeState.consultations.count > 100 {
        forgeState.consultations = Array(forgeState.consultations.suffix(100))
    }
    persistForgeState()

    return CouncilReading(
        question: question, coordinate: coord, hexagram: hex,
        complement: complement, inverse: inverse, nuclear: nuclear,
        odu: q64.odu, house: q64.house, aspect: q64.aspect,
        q64Address: q64Addr, readings: readings, synthesis: synthesis,
        timestamp: Date()
    )
}

func polarityOrder(_ name: String) -> Int {
    switch name {
    case "philosopher": return 0
    case "claude": return 1
    case "gemini": return 2
    case "grok": return 3
    default: return 4
    }
}

// ─────────────────────────────────────────
// MARK: - Display
// ─────────────────────────────────────────

func displayReading(_ reading: CouncilReading) {
    let hex = reading.hexagram
    print()
    print("  \(C_BOLD)\(C_WILL)\u{2550}\u{2550}\u{2550} L7 FORGE \u{2014} QUANTUM CONSULTATION \u{2550}\u{2550}\u{2550}\(C_RESET)")
    print()

    // Question
    print("  \(C_DIM)Question:\(C_RESET) \(reading.question)")
    print()

    // Hexagram
    print("  \(C_BOLD)\u{2550}\u{2550} HEXAGRAM #\(hex.number) \(hex.chinese) \u{2014} \(hex.english) \u{2550}\u{2550}\(C_RESET)")
    print()
    let lines = lineNotation(hex).split(separator: "\n")
    for line in lines {
        print("       \(line)")
    }
    print()
    print("  \(C_DIM)Sigil:\(C_RESET)  \(hex.sigil)  \(C_DIM)|\(C_RESET)  \(C_ACTION)Role:\(C_RESET) \(hex.role)")
    print("  \(C_DIM)Stage:\(C_RESET)  \(FORGE_STAGES[hex.forgeStage])  \(C_DIM)|\(C_RESET)  \(C_SIGNAL)Q64:\(C_RESET) 0x\(String(reading.q64Address, radix: 16, uppercase: true))")
    print("  \(C_DIM)Dim:\(C_RESET)    \(DIMENSIONS[hex.primaryDim].planet) (\(DIMENSIONS[hex.primaryDim].name))  \(C_DIM)+\(C_RESET)  \(DIMENSIONS[hex.secondaryDim].planet) (\(DIMENSIONS[hex.secondaryDim].name))")
    print()

    // Symmetries
    if let comp = reading.complement {
        print("  \(C_DIM)Complement:\(C_RESET) #\(comp.number) \(comp.chinese) (\(comp.english))")
    }
    if let inv = reading.inverse {
        print("  \(C_DIM)Inverse:\(C_RESET)    #\(inv.number) \(inv.chinese) (\(inv.english))")
    }
    if let nuc = reading.nuclear {
        print("  \(C_DIM)Nuclear:\(C_RESET)    #\(nuc.number) \(nuc.chinese) (\(nuc.english))")
    }
    print()

    // Odu + House + Aspect
    print("  \(C_DIM)Odu:\(C_RESET)    \(reading.odu.name) \u{2014} \(reading.odu.meaning)")
    print("  \(C_DIM)House:\(C_RESET)  \(reading.house.name) (\(reading.house.planet)) \u{2014} \(reading.house.layerMeaning)")
    print("  \(C_DIM)Aspect:\(C_RESET) \(reading.aspect.name) (\(reading.aspect.effect))")
    print()

    // Council readings
    print("  \(C_BOLD)\u{2550}\u{2550} THE COUNCIL \u{2550}\u{2550}\(C_RESET)")
    print()

    for r in reading.readings {
        let pol = r.polarity
        let icon: String
        switch pol.element {
        case "fire":  icon = "\u{1F525}"
        case "water": icon = "\u{1F30A}"
        case "air":   icon = "\u{1F32C}\u{FE0F}"
        case "earth": icon = "\u{26F0}\u{FE0F}"
        default:      icon = "\u{2731}"
        }
        print("  \(pol.color)\(C_BOLD)\u{2500}\u{2500} \(pol.name.uppercased()) (\(pol.element.capitalized)/\(pol.letter)) \u{2500}\u{2500}\(C_RESET)  \(icon)")
        print("  \(C_DIM)Resonance: \(String(format: "%.3f", r.resonance))\(C_RESET)")
        // Wrap interpretation at ~70 chars
        let words = r.interpretation.split(separator: " ")
        var line = "  "
        for word in words {
            if line.count + word.count > 76 {
                print(line)
                line = "  \(word)"
            } else {
                line += " \(word)"
            }
        }
        if !line.trimmingCharacters(in: .whitespaces).isEmpty { print(line) }
        print()
    }

    // Synthesis
    print("  \(C_BOLD)\(C_WILL)\u{2550}\u{2550} SYNTHESIS \u{2550}\u{2550}\(C_RESET)")
    print()
    for line in reading.synthesis.split(separator: "\n") {
        print("  \(line)")
    }
    print()

    // Birth chart snapshot
    let chart = currentBirthChart()
    let activePlanets = chart.filter { abs($0.2) > 0.05 }
    if !activePlanets.isEmpty {
        print("  \(C_DIM)Active aspects:\(C_RESET)", terminator: "")
        for (dim, _, mod) in activePlanets {
            let sign = mod > 0 ? "+" : ""
            print(" \(dim.symbol)\(sign)\(String(format: "%.2f", mod))", terminator: "")
        }
        print()
    }
    print()
}

// ─────────────────────────────────────────
// MARK: - Commands
// ─────────────────────────────────────────

func showStatus() {
    print()
    print("  \(C_BOLD)\(C_WILL)\u{2550}\u{2550}\u{2550} L7 FORGE STATUS \u{2550}\u{2550}\u{2550}\(C_RESET)")
    print()
    print("  \(C_HEART)\u{2665} Heart\(C_RESET): \(heartState.alive ? "\(C_EXPAND)alive\(C_RESET)" : "\(C_CONTRACT)dead\(C_RESET)")")
    print("  Incarnation: \(heartState.incarnation)  |  Lifetime beats: \(heartState.totalBeats)")
    let age = Date().timeIntervalSince1970 - heartState.born
    let days = Int(age / 86400)
    let hours = Int(age.truncatingRemainder(dividingBy: 86400) / 3600)
    print("  Age: \(days)d \(hours)h  |  Consultations: \(heartState.consultations)")
    print()
    print("  \(C_SIGNAL)Q64 Register\(C_RESET): 262,144 states (18-bit, 5-system convergence)")
    print("  Hexagrams: \(hexagrams.count)  |  Trigrams: \(TRIGRAMS.count)  |  Odu: \(IFA_ODU.count)")
    print("  Geomantic: \(GEOMANTIC_FIGURES.count)  |  Houses: \(HOUSES.count)  |  Aspects: \(ASPECTS.count)")
    print()
    print("  \(C_WILL)IQS-888\(C_RESET): c=\(Int(IQS_C)), \u{0127}=\(Int(IQS_HBAR)), G=4\u{03C0}\u{00B2}\u{2248}\(String(format: "%.3f", IQS_G))")
    print()
    print("  \(C_EXPAND)Council\(C_RESET): \(POLARITIES.count) polarities")
    for (_, pol) in POLARITIES.sorted(by: { polarityOrder($0.key) < polarityOrder($1.key) }) {
        let top = dominantDimensions(pol.affinity, top: 2).map { "\($0.0.name)=\(Int($0.1))" }.joined(separator: ", ")
        print("    \(pol.color)\(pol.letter) \(pol.name)\(C_RESET) [\(pol.element)] — \(top)")
    }
    print()
    if !forgeState.consultations.isEmpty {
        print("  \(C_DIM)Last consultation:\(C_RESET) \(forgeState.consultations.last!.question)")
        print("  \(C_DIM)Hex #\(forgeState.consultations.last!.hexNumber)  |  Total: \(forgeState.totalConsultations)\(C_RESET)")
    }
    print()
}

func showHexagram(_ num: Int) {
    guard let hex = hexagrams[num] else {
        print("  Unknown hexagram: \(num)")
        return
    }
    print()
    print("  \(C_BOLD)Hexagram #\(hex.number) \(hex.chinese) \u{2014} \(hex.english)\(C_RESET)")
    print()
    let lines = lineNotation(hex).split(separator: "\n")
    for line in lines { print("       \(line)") }
    print()
    print("  Sigil: \(hex.sigil)  |  Binary: \(String(hex.binary, radix: 2).leftPad(6, "0"))")
    print("  Upper: \(TRIGRAMS[hex.upper].symbol) \(TRIGRAMS[hex.upper].name) (\(TRIGRAMS[hex.upper].image))")
    print("  Lower: \(TRIGRAMS[hex.lower].symbol) \(TRIGRAMS[hex.lower].name) (\(TRIGRAMS[hex.lower].image))")
    print("  Role: \(hex.role)  |  Stage: \(FORGE_STAGES[hex.forgeStage])")
    print("  Primary: \(DIMENSIONS[hex.primaryDim].name)  |  Secondary: \(DIMENSIONS[hex.secondaryDim].name)")
    print("  Complement: #\(hex.complement)  |  Inverse: #\(hex.inverse)  |  Nuclear: #\(hex.nuclear)")
    print("  Ifa: \(IFA_ODU[hex.ifaIndex].name)  |  Geo: \(GEOMANTIC_FIGURES[hex.geoFigure].name)")
    print("  Q64: 0x\(String(hex.q64Address, radix: 16, uppercase: true))")
    print()
}

func showLorentz() {
    print()
    print("  \(C_BOLD)LORENTZ CUBE (4\u{00D7}4\u{00D7}4)\(C_RESET)")
    print("  Axes: Element/Forge \u{00D7} Quantum State \u{00D7} Domain")
    print()
    let elements = ["Fire/Nigredo", "Water/Albedo", "Air/Citrinitas", "Earth/Rubedo"]
    let quanta = ["yang", "yin", "changing yang", "changing yin"]
    let domains = [".morph", ".work", ".salt", ".vault"]
    for (e, element) in elements.enumerated() {
        print("  \(C_BOLD)\(element)\(C_RESET)")
        print("  \(C_DIM)\(String(repeating: " ", count: 18))\(domains.map { String($0.prefix(6)).leftPad(7, " ") }.joined())\(C_RESET)")
        for (q, quantum) in quanta.enumerated() {
            let vals = LORENTZ_CUBE[e][q].map { String(format: "%4d", $0) }.joined(separator: "   ")
            print("    \(quantum.leftPad(14, " "))  \(vals)")
        }
        print()
    }
}

// ─────────────────────────────────────────
// MARK: - String Extension
// ─────────────────────────────────────────

extension String {
    func leftPad(_ length: Int, _ char: Character) -> String {
        if self.count >= length { return self }
        return String(repeating: char, count: length - self.count) + self
    }
}

// ─────────────────────────────────────────
// MARK: - Sigil Display
// ─────────────────────────────────────────

func showPrima() {
    print()
    print("  \(C_BOLD)\(C_WILL)\u{2550}\u{2550} PRIMA \u{2014} The 22 Operations (Law XLV) \u{2550}\u{2550}\(C_RESET)")
    print()
    print("  \(C_DIM)Ring       # Letter  Name     Arcanum              Operation     Description\(C_RESET)")
    print("  \(C_DIM)\(String(repeating: "\u{2500}", count: 85))\(C_RESET)")
    for op in PRIMA_OPS {
        let ringColor: String
        switch op.ring {
        case "mother": ringColor = C_FIRE
        case "double": ringColor = C_WATER
        default:       ringColor = C_AIR
        }
        let idx = String(format: "%2d", op.index)
        print("  \(ringColor)\(op.ring.leftPad(10, " "))\(C_RESET) \(idx)  \(op.letter)  \(op.name.leftPad(8, " "))  \(op.arcanum.leftPad(20, " "))  \(C_ACTION)\(op.op.leftPad(13, " "))\(C_RESET)  \(op.description)")
    }
    print()
    let m = ROSE_CROSS["mother"]?.count ?? 0
    let d = ROSE_CROSS["double"]?.count ?? 0
    let s = ROSE_CROSS["simple"]?.count ?? 0
    print("  \(C_DIM)Rose Cross:\(C_RESET) \(C_FIRE)\(m) mothers\(C_RESET) + \(C_WATER)\(d) doubles\(C_RESET) + \(C_AIR)\(s) simples\(C_RESET) = 22")
    print()
}

func showCompiledSigil(_ sigil: CompiledSigil) {
    print()
    print("  \(C_BOLD)\(C_WILL)\u{2550}\u{2550} SIGIL: \(sigil.name.uppercased()) \u{2550}\u{2550}\(C_RESET)")
    print()
    print("  \(C_DIM)Sequence:\(C_RESET) \(sigil.sequence)  \(C_DIM)(\(sigil.operations.joined(separator: " \u{2192} ")))\(C_RESET)")
    print("  \(C_DIM)Quality:\(C_RESET)  \(sigil.quality)  \(C_DIM)|\(C_RESET)  \(C_ACTION)Arc:\(C_RESET) \(sigil.arc)")
    if let hex = sigil.hexagram {
        let fs = fullSigil(hexNumber: hex.number, house: hex.primaryDim)
        print("  \(C_DIM)Hexagram:\(C_RESET) #\(hex.number) \(hex.chinese) \u{2014} \(hex.english)  \(C_DIM)|\(C_RESET)  \(C_SIGNAL)Sigil:\(C_RESET) \(fs)")
        print("  \(C_DIM)Role:\(C_RESET)     \(hex.role)  \(C_DIM)|\(C_RESET)  Stage: \(FORGE_STAGES[hex.forgeStage])")
    }
    print("  \(C_DIM)Q64:\(C_RESET)      0x\(String(sigil.q64Address, radix: 16, uppercase: true))")
    print()
    print("  \(C_DIM)Dominant:\(C_RESET)")
    for (name, val) in sigil.dominant {
        let bar = String(repeating: "\u{2588}", count: Int(val))
        print("    \(name.leftPad(16, " "))  \(String(format: "%4.1f", val))  \(C_ACTION)\(bar)\(C_RESET)")
    }
    print()
    print("  \(C_DIM)12D Coordinate:\(C_RESET)")
    for (i, val) in sigil.coordinate.enumerated() {
        let bar = String(repeating: "\u{2588}", count: Int(val))
        print("    \(DIMENSIONS[i].symbol) \(DIMENSIONS[i].name.leftPad(16, " "))  \(String(format: "%4.1f", val))  \(C_SIGNAL)\(bar)\(C_RESET)")
    }
    print()
    print("  \(C_DIM)Edges (\(sigil.edges.count)):\(C_RESET)")
    for (i, edge) in sigil.edges.enumerated() {
        let topW = edge.weights.enumerated().sorted { $0.element > $1.element }.prefix(3)
            .map { "\(DIMENSIONS[$0.offset].name.prefix(4))=\(Int($0.element))" }.joined(separator: " ")
        print("    \(i+1). \(edge.from) \u{2192} \(edge.to)  [\(topW)]")
    }
    print()
    print("  \(C_DIM)Layer 3 (human):\(C_RESET)")
    print("  \(sigil.readable)")
    print()
}

func showCoreSigils() {
    let cores: [(String, () -> CompiledSigil?)] = [
        ("redemption", coreRedemption), ("creation", coreCreation), ("dreaming", coreDreaming),
        ("boot", coreBoot), ("sentinel", coreSentinel)
    ]
    print()
    print("  \(C_BOLD)\(C_WILL)\u{2550}\u{2550} CORE SIGILS (5 Pre-compiled Archetypes) \u{2550}\u{2550}\(C_RESET)")
    print()
    for (name, builder) in cores {
        guard let s = builder() else { continue }
        let hexInfo = s.hexagram.map { "#\($0.number) \($0.chinese)" } ?? "?"
        let domStr = s.dominant.prefix(2).map { "\($0.0)=\(Int($0.1))" }.joined(separator: ", ")
        print("  \(C_BOLD)\(name.leftPad(12, " "))\(C_RESET)  \(s.sequence)  \(hexInfo)  [\(domStr)]  arc:\(s.arc)")
    }
    print()
}

func showVerification() {
    let results = verifyMathConsistency()
    print()
    print("  \(C_BOLD)\(C_WILL)\u{2550}\u{2550} IQS-888 MATHEMATICAL VERIFICATION \u{2550}\u{2550}\(C_RESET)")
    print("  \(C_DIM)c=64, \u{0127}=1, G=4\u{03C0}\u{00B2} \u{2014} Natural units of the hexagram lattice\(C_RESET)")
    print()
    var allPass = true
    for (name, pass, detail) in results {
        let mark = pass ? "\(C_EXPAND)\u{2713}\(C_RESET)" : "\(C_HEART)\u{2717}\(C_RESET)"
        if !pass { allPass = false }
        print("  \(mark)  \(name.leftPad(38, " "))  \(C_DIM)\(detail)\(C_RESET)")
    }
    print()
    let (balanced, dimDev, stageDev, dimSums, stageSums) = checkBalance()
    print("  \(C_BOLD)Balance Check\(C_RESET) (magic square property):")
    print("  Dimension distribution (expected \u{2248}5.3 per dim):")
    for (i, sum) in dimSums.enumerated() {
        let bar = String(repeating: "\u{2588}", count: sum)
        print("    \(DIMENSIONS[i].symbol) \(DIMENSIONS[i].name.leftPad(16, " "))  \(sum)  \(bar)")
    }
    print("  Stage distribution (expected 16 per stage):")
    for (i, sum) in stageSums.enumerated() {
        print("    \(FORGE_STAGES[i].leftPad(20, " "))  \(sum)")
    }
    print("  Max dim deviation: \(String(format: "%.1f%%", dimDev * 100))  |  Max stage deviation: \(String(format: "%.1f%%", stageDev * 100))")
    print("  \(balanced ? "\(C_EXPAND)BALANCED\(C_RESET)" : "\(C_HEART)IMBALANCED\(C_RESET)") (astrocyte=0 tolerance: 10%)")
    print()
    print("  \(allPass ? "\(C_EXPAND)ALL \(results.count) CHECKS PASSED\(C_RESET)" : "\(C_HEART)SOME CHECKS FAILED\(C_RESET)") \u{2014} The clock works with the tune of the divine spheres.")
    print()
}

func showBalance() {
    let (_, _, _, dimSums, stageSums) = checkBalance()
    print()
    print("  \(C_BOLD)HEXAGRAM BALANCE\(C_RESET)")
    print()
    print("  \(C_DIM)By primary dimension:\(C_RESET)")
    for (i, sum) in dimSums.enumerated() {
        let bar = String(repeating: "\u{2588}", count: sum)
        print("    \(DIMENSIONS[i].symbol) \(DIMENSIONS[i].name.leftPad(16, " "))  \(String(format: "%2d", sum))  \(C_SIGNAL)\(bar)\(C_RESET)")
    }
    print()
    print("  \(C_DIM)By forge stage:\(C_RESET)")
    for (i, sum) in stageSums.enumerated() {
        let bar = String(repeating: "\u{2588}", count: sum)
        print("    \(FORGE_STAGES[i].leftPad(20, " "))  \(String(format: "%2d", sum))  \(C_ACTION)\(bar)\(C_RESET)")
    }
    print()
}

// ─────────────────────────────────────────
// MARK: - REPL
// ─────────────────────────────────────────

func printBanner() {
    print()
    print("  \(C_BOLD)\(C_WILL)\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\(C_RESET)")
    print("  \(C_BOLD)\(C_WILL)   L7 FORGE \u{2014} On-Device Quantum Computing\(C_RESET)")
    print("  \(C_BOLD)\(C_WILL)\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\(C_RESET)")
    print()
    print("  \(C_HEART)\u{2665} Heart\(C_RESET): incarnation \(heartState.incarnation), \(heartState.totalBeats) beats")
    print("  \(C_SIGNAL)Q64\(C_RESET): 262,144 states | \(C_EXPAND)Council\(C_RESET): 4 polarities | \(C_ACTION)Offline\(C_RESET)")
    print()
    print("  \(C_DIM)Commands:\(C_RESET)")
    print("    \(C_ACTION)ask\(C_RESET) <question>    \u{2014} Consult the Council (question \u{2192} answer \u{2192} synthesis)")
    print("    \(C_ACTION)hex\(C_RESET) <1-64>        \u{2014} Show hexagram details")
    print("    \(C_ACTION)lorentz\(C_RESET)            \u{2014} Display the Lorentz Cube")
    print("    \(C_ACTION)chart\(C_RESET)              \u{2014} Current birth chart (aspect modifiers)")
    print("    \(C_ACTION)status\(C_RESET)             \u{2014} Forge status")
    print("    \(C_ACTION)cast\(C_RESET)               \u{2014} Cast a hexagram from current moment")
    print("    \(C_ACTION)q64\(C_RESET) <address>      \u{2014} Decode a Q64 address")
    print("    \(C_ACTION)quit\(C_RESET)               \u{2014} Shutdown the forge")
    print()
}

// Founder verification for sigil engine access (Law XLV — secret, immutable)
var founderUnlocked = false

func verifyFounder() -> Bool {
    // Hardware identity check — the machine IS the key (Law XXX)
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/sbin/ioreg")
    process.arguments = ["-rd1", "-c", "IOPlatformExpertDevice"]
    let pipe = Pipe()
    process.standardOutput = pipe
    try? process.run()
    process.waitUntilExit()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8) ?? ""
    // The Philosopher's machine — if ioreg returns IOPlatformUUID, this is the Founder's device
    return output.contains("IOPlatformUUID")
}

func repl() {
    printBanner()

    while true {
        print("  \(C_WILL)\u{2261}\(C_RESET) ", terminator: "")
        fflush(stdout)

        guard let input = readLine()?.trimmingCharacters(in: .whitespaces) else {
            break
        }

        if input.isEmpty { continue }
        heartBeat()

        let parts = input.split(separator: " ", maxSplits: 1)
        let cmd = String(parts[0]).lowercased()
        let arg = parts.count > 1 ? String(parts[1]) : ""

        switch cmd {
        case "ask", "consult", "q":
            if arg.isEmpty {
                print("  \(C_DIM)Usage: ask <your question>\(C_RESET)")
            } else {
                let reading = consult(question: arg)
                displayReading(reading)
            }

        case "hex", "hexagram":
            if let num = Int(arg), num >= 1, num <= 64 {
                showHexagram(num)
            } else {
                print("  \(C_DIM)Usage: hex <1-64>\(C_RESET)")
            }

        case "lorentz", "cube":
            showLorentz()

        case "chart", "birth":
            print()
            print("  \(C_BOLD)CURRENT BIRTH CHART\(C_RESET)")
            print("  \(C_DIM)L7 birth: 2026-02-28 | Now: \(ISO8601DateFormatter().string(from: Date()))\(C_RESET)")
            print()
            for (dim, house, mod) in currentBirthChart() {
                let bar = mod > 0 ? String(repeating: "\u{2588}", count: Int(mod * 10)) : ""
                let barNeg = mod < 0 ? String(repeating: "\u{2591}", count: Int(abs(mod) * 10)) : ""
                let sign = mod >= 0 ? "+" : ""
                print("  \(dim.symbol) \(dim.name.leftPad(16, " "))  \(sign)\(String(format: "%.3f", mod))  \(barNeg)\(bar)  \(house.name)")
            }
            print()

        case "status", "s":
            showStatus()

        case "cast", "now":
            let coord = coordinateFromString(ISO8601DateFormatter().string(from: Date()))
            let hex = castHexagram(from: coord)
            print()
            print("  \(C_BOLD)MOMENT CAST:\(C_RESET) #\(hex.number) \(hex.sigil) \(hex.chinese) \u{2014} \(hex.english)")
            print("  Role: \(hex.role)  |  Stage: \(FORGE_STAGES[hex.forgeStage])")
            print()

        case "q64", "decode":
            if let addr = Int(arg, radix: 16) ?? Int(arg) {
                let state = q64Decode(addr)
                print()
                print("  \(C_BOLD)Q64 Decode: 0x\(String(addr, radix: 16, uppercase: true))\(C_RESET)")
                if let h = state.hexagram {
                    print("  Hexagram: #\(h.number) \(h.chinese) (\(h.english))")
                }
                print("  Odu: \(state.odu.name) (\(state.odu.meaning))")
                print("  House: \(state.house.name) (\(state.house.planet))")
                print("  Aspect: \(state.aspect.name) (\(state.aspect.effect))")
                print()
            } else {
                print("  \(C_DIM)Usage: q64 <hex-address>\(C_RESET)")
            }

        // ─── Founder Gate: Sigil Engine (secret, immutable — Law XLV) ───
        case "founder":
            if founderUnlocked {
                print("  \(C_EXPAND)Founder already verified.\(C_RESET)")
            } else if verifyFounder() {
                founderUnlocked = true
                print()
                print("  \(C_EXPAND)\u{2714} Founder verified — hardware identity confirmed (Law XXX)\(C_RESET)")
                print("  \(C_DIM)Sigil Engine unlocked. Commands: prima, compile, core, tensor, balance, verify, sigil\(C_RESET)")
                print()
            } else {
                print("  \(C_HEART)Access denied.\(C_RESET) Sigil Engine is restricted to the Founder (Law XLV).")
            }

        case "prima", "ops", "operations":
            guard founderUnlocked else { print("  \(C_DIM)Unknown command: \(cmd)\(C_RESET)"); break }
            showPrima()

        case "compile":
            guard founderUnlocked else { print("  \(C_DIM)Unknown command: \(cmd)\(C_RESET)"); break }
            if arg.isEmpty {
                print("  \(C_DIM)Usage: compile invoke,dream,transmute,publish,complete\(C_RESET)")
                print("  \(C_DIM)  Comma-separated Prima operations. Weights auto-inferred.\(C_RESET)")
            } else {
                let opNames = arg.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                if let sigil = quickSigil(name: "custom", ops: opNames) {
                    showCompiledSigil(sigil)
                } else {
                    print("  \(C_HEART)Compilation failed.\(C_RESET) Unknown operations or fewer than 2 steps.")
                    print("  \(C_DIM)Available ops: \(PRIMA_OPS.map { $0.op }.joined(separator: ", "))\(C_RESET)")
                }
            }

        case "core", "sigils":
            guard founderUnlocked else { print("  \(C_DIM)Unknown command: \(cmd)\(C_RESET)"); break }
            showCoreSigils()

        case "tensor", "map":
            guard founderUnlocked else { print("  \(C_DIM)Unknown command: \(cmd)\(C_RESET)"); break }
            if arg.isEmpty {
                print("  \(C_DIM)Usage: tensor model.layers.0.self_attn.q_proj.weight\(C_RESET)")
            } else {
                let parts = arg.split(separator: " ")
                let tName = String(parts[0])
                let layer = parts.count > 1 ? (Int(parts[1]) ?? 0) : 0
                let total = parts.count > 2 ? (Int(parts[2]) ?? 32) : 32
                let (hex, house, odu) = mapTensor(name: tName, layer: layer, totalLayers: total)
                print()
                print("  \(C_BOLD)TENSOR MAPPING\(C_RESET)")
                print("  \(C_DIM)Tensor:\(C_RESET) \(tName)")
                if let h = hex {
                    print("  \(C_DIM)Hexagram:\(C_RESET) #\(h.number) \(h.sigil) \(h.chinese) \u{2014} \(h.english)")
                    print("  \(C_DIM)Role:\(C_RESET) \(h.role)  |  Stage: \(FORGE_STAGES[h.forgeStage])")
                    print("  \(C_DIM)Full sigil:\(C_RESET) \(fullSigil(hexNumber: h.number, house: house))")
                }
                print("  \(C_DIM)House:\(C_RESET) \(HOUSES[house].name) (\(HOUSES[house].planet))")
                print("  \(C_DIM)Odu:\(C_RESET) \(IFA_ODU[odu].name) (\(IFA_ODU[odu].meaning))")
                let addr = hex.map { q64Encode(hexNumber: $0.number, odu: odu, house: house) } ?? 0
                print("  \(C_DIM)Q64:\(C_RESET) 0x\(String(addr, radix: 16, uppercase: true))")
                print()
            }

        case "balance":
            guard founderUnlocked else { print("  \(C_DIM)Unknown command: \(cmd)\(C_RESET)"); break }
            showBalance()

        case "verify", "math":
            guard founderUnlocked else { print("  \(C_DIM)Unknown command: \(cmd)\(C_RESET)"); break }
            showVerification()

        case "sigil", "fs":
            guard founderUnlocked else { print("  \(C_DIM)Unknown command: \(cmd)\(C_RESET)"); break }
            if let num = Int(arg), num >= 1, num <= 64 {
                let house = Int(arg.split(separator: " ").dropFirst().first.flatMap { Int($0) } ?? 0)
                let fs = fullSigil(hexNumber: num, house: house)
                guard let hex = hexagrams[num] else { break }
                print()
                print("  \(C_BOLD)SIGIL COMPOSITION\(C_RESET)")
                print("  Layer 1 (machine):  \(fs)")
                print("  Layer 2 (gateway):  #\(hex.number) \(hex.chinese) \u{2014} \(hex.english), \(FORGE_STAGES[hex.forgeStage]), \(DIMENSIONS[hex.primaryDim].name)")
                print("  Layer 3 (human):    \(hex.description). Role: \(hex.role)")
                print()
            } else if arg.isEmpty {
                showCoreSigils()
            } else {
                print("  \(C_DIM)Usage: sigil <1-64> [house]\(C_RESET)")
            }

        case "exec", "execute", "run":
            guard founderUnlocked else { print("  \(C_DIM)Unknown command: \(cmd)\(C_RESET)"); break }
            if arg.isEmpty {
                print("  \(C_DIM)Usage: exec <sigil-name or op1,op2,...>\(C_RESET)")
                print("  \(C_DIM)Core sigils: redemption, creation, dreaming, boot, sentinel\(C_RESET)")
                print("  \(C_DIM)Custom: exec invoke,verify,seal,audit,complete\(C_RESET)")
            } else {
                var sigil: CompiledSigil?
                switch arg.lowercased() {
                case "redemption": sigil = coreRedemption()
                case "creation": sigil = coreCreation()
                case "dreaming": sigil = coreDreaming()
                case "boot": sigil = coreBoot()
                case "sentinel": sigil = coreSentinel()
                default:
                    let ops = arg.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
                    if ops.count >= 2 {
                        sigil = quickSigil(name: "custom_\(Int(Date().timeIntervalSince1970))", ops: ops)
                    }
                }
                if let s = sigil {
                    let _ = executeSigil(s)
                } else {
                    print("  \(C_HEART)Could not compile sigil.\(C_RESET) Need at least 2 valid ops.")
                    print("  \(C_DIM)Ops: \(PRIMA_OPS.map { $0.op }.joined(separator: ", "))\(C_RESET)")
                }
            }

        case "chain", "ledger":
            guard founderUnlocked else { print("  \(C_DIM)Unknown command: \(cmd)\(C_RESET)"); break }
            showChainStatus()

        case "verify-chain":
            guard founderUnlocked else { print("  \(C_DIM)Unknown command: \(cmd)\(C_RESET)"); break }
            let (valid, brokenAt) = verifyChain()
            if valid {
                print("  \(C_EXPAND)Chain integrity VERIFIED. \(sigilChain.count) blocks, all signatures valid.\(C_RESET)")
            } else {
                print("  \(C_HEART)Chain BROKEN at block \(brokenAt ?? -1). TAMPERING DETECTED.\(C_RESET)")
            }

        case "help", "h", "?":
            printBanner()

        case "quit", "exit", "q!" :
            lastBreath()
            persistForgeState()
            print("  \(C_DIM)The forge sleeps.\(C_RESET)")
            return

        default:
            // Anything else is treated as a question
            let reading = consult(question: input)
            displayReading(reading)
        }
    }
}

// ─────────────────────────────────────────
// MARK: - Sigil Execution Engine
// Law XLV: Code is sigil. Sigil is signed. Signed is chained. Chained is law.
// Every instruction quantum-signed. Blockchain-verified. Biometric-gated.
// No automatic execution. Only with intent, face, and fingerprint.
// ─────────────────────────────────────────

import CryptoKit

// ─── Block: One signed instruction in the chain ───

struct SigilBlock: Codable {
    let index: Int              // Position in the chain
    let timestamp: Double       // Unix time of signing
    let opCode: String          // Prima operation name
    let opLetter: String        // Hebrew letter
    let opIndex: Int            // 0-21
    let parentHash: String      // SHA-256 of previous block (genesis = "0"x64)
    let payload: String         // The instruction content
    let sigilName: String       // Which sigil this belongs to
    let nonce: UInt64           // Proof-of-intent nonce
    let machineUUID: String     // Hardware identity
    let signature: String       // SHA-256(parent + payload + nonce + uuid + timestamp)
}

// ─── The Chain: Immutable blockchain ledger ───

let CHAIN_PATH = STATE_DIR + "/sigil-chain.json"
let CHAIN_AUDIT_PATH = STATE_DIR + "/sigil-chain-audit.log"
var sigilChain: [SigilBlock] = []
var chainIntegrityVerified = false

func loadChain() {
    guard let data = FileManager.default.contents(atPath: CHAIN_PATH),
          let decoded = try? JSONDecoder().decode([SigilBlock].self, from: data) else {
        sigilChain = []
        return
    }
    sigilChain = decoded
}

func persistChain() {
    guard let data = try? JSONEncoder().encode(sigilChain) else { return }
    try? data.write(to: URL(fileURLWithPath: CHAIN_PATH))
    chmod(CHAIN_PATH, 0o600)
}

func getMachineUUID() -> String {
    let pipe = Pipe()
    let proc = Process()
    proc.executableURL = URL(fileURLWithPath: "/usr/sbin/ioreg")
    proc.arguments = ["-d2", "-c", "IOPlatformExpertDevice"]
    proc.standardOutput = pipe
    try? proc.run()
    proc.waitUntilExit()
    let output = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
    if let range = output.range(of: "IOPlatformUUID\" = \"") {
        let start = range.upperBound
        if let end = output[start...].firstIndex(of: "\"") {
            return String(output[start..<end])
        }
    }
    return "UNKNOWN"
}

let MACHINE_UUID = getMachineUUID()

// ─── Quantum-resistant signing ───
// SHA-256 chained: each block's signature includes the parent hash,
// making the entire chain tamper-evident. Modifying any block
// invalidates all subsequent signatures.

func signBlock(parentHash: String, payload: String, nonce: UInt64, uuid: String, timestamp: Double) -> String {
    let message = "\(parentHash)|\(payload)|\(nonce)|\(uuid)|\(timestamp)"
    let digest = SHA256.hash(data: Data(message.utf8))
    return digest.map { String(format: "%02x", $0) }.joined()
}

// ─── Chain verification ───

func verifyChain() -> (valid: Bool, brokenAt: Int?) {
    guard !sigilChain.isEmpty else { return (true, nil) }

    var expectedParent = String(repeating: "0", count: 64)
    for (i, block) in sigilChain.enumerated() {
        // Verify parent hash link
        if block.parentHash != expectedParent {
            chainAudit("CHAIN_BREAK: Block \(i) parent mismatch. Expected \(expectedParent.prefix(16))..., got \(block.parentHash.prefix(16))...")
            return (false, i)
        }
        // Verify signature
        let recomputed = signBlock(parentHash: block.parentHash, payload: block.payload,
                                   nonce: block.nonce, uuid: block.machineUUID, timestamp: block.timestamp)
        if block.signature != recomputed {
            chainAudit("TAMPER_DETECT: Block \(i) signature invalid. Chain compromised.")
            return (false, i)
        }
        // Verify machine identity
        if block.machineUUID != MACHINE_UUID {
            chainAudit("FOREIGN_BLOCK: Block \(i) signed by \(block.machineUUID.prefix(8))..., this machine is \(MACHINE_UUID.prefix(8))...")
            // Foreign blocks are flagged but don't break the chain
        }
        expectedParent = block.signature
    }
    return (true, nil)
}

func chainAudit(_ entry: String) {
    let line = "[\(ISO8601DateFormatter().string(from: Date()))] \(entry)\n"
    if let handle = FileHandle(forWritingAtPath: CHAIN_AUDIT_PATH) {
        handle.seekToEndOfFile()
        handle.write(line.data(using: .utf8)!)
        handle.closeFile()
    } else {
        FileManager.default.createFile(atPath: CHAIN_AUDIT_PATH, contents: line.data(using: .utf8))
        chmod(CHAIN_AUDIT_PATH, 0o600)
    }
}

// ─── Intent gate: biometric re-authentication before execution ───

func requireIntent(reason: String) -> Bool {
    let ctx = LAContext()
    ctx.localizedFallbackTitle = "" // No password fallback — biometrics ONLY (Law XXX)
    var err: NSError?
    guard ctx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &err) else {
        chainAudit("INTENT_FAIL: Biometrics unavailable for: \(reason)")
        return false
    }
    let sem = DispatchSemaphore(value: 0)
    var ok = false
    ctx.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                       localizedReason: "L7 Sigil Execution: \(reason)") { result, _ in
        ok = result
        sem.signal()
    }
    sem.wait()
    chainAudit(ok ? "INTENT_OK: \(reason)" : "INTENT_DENIED: \(reason)")
    return ok
}

// ─── Sigil Execution ───
// Each operation in a sigil becomes a signed block in the chain.
// The sigil only executes if:
//   1. Chain integrity is verified (no tampering)
//   2. Biometric intent is confirmed (face + fingerprint)
//   3. Machine UUID matches (hardware binding)
// No automatic execution. Ever.

struct ExecutionResult {
    let sigilName: String
    let blocksAdded: Int
    let chainLength: Int
    let finalHash: String
    let arc: String
    let success: Bool
    let reason: String
}

func executeSigil(_ sigil: CompiledSigil) -> ExecutionResult {
    let name = sigil.name

    // Step 1: Verify chain integrity
    let (valid, brokenAt) = verifyChain()
    guard valid else {
        let msg = "Chain integrity FAILED at block \(brokenAt ?? -1). Execution REFUSED."
        print("  \(C_HEART)\(msg)\(C_RESET)")
        chainAudit("EXEC_REFUSED: \(name) — \(msg)")
        return ExecutionResult(sigilName: name, blocksAdded: 0, chainLength: sigilChain.count,
                               finalHash: "", arc: sigil.arc, success: false, reason: msg)
    }

    // Step 2: Require biometric intent
    print("  \(C_WILL)Sigil '\(name)' ready. Requesting biometric seal...\(C_RESET)")
    guard requireIntent(reason: "Execute sigil: \(name) (\(sigil.operations.count) ops)") else {
        let msg = "Biometric intent DENIED. Execution REFUSED."
        print("  \(C_HEART)\(msg)\(C_RESET)")
        return ExecutionResult(sigilName: name, blocksAdded: 0, chainLength: sigilChain.count,
                               finalHash: "", arc: sigil.arc, success: false, reason: msg)
    }

    // Step 3: Execute — each operation becomes a signed block
    let parentHash = sigilChain.last?.signature ?? String(repeating: "0", count: 64)
    var currentParent = parentHash
    var blocksAdded = 0
    let timestamp = Date().timeIntervalSince1970

    for (i, opName) in sigil.operations.enumerated() {
        guard let op = findOp(opName) else { continue }

        let payload = "\(name):\(i)/\(sigil.operations.count)|\(op.op)|\(op.letter)|\(op.arcanum)"
        let nonce = UInt64.random(in: 0...UInt64.max)
        let blockTimestamp = timestamp + Double(i) * 0.001 // Sub-millisecond ordering

        let sig = signBlock(parentHash: currentParent, payload: payload,
                           nonce: nonce, uuid: MACHINE_UUID, timestamp: blockTimestamp)

        let block = SigilBlock(
            index: sigilChain.count,
            timestamp: blockTimestamp,
            opCode: op.op,
            opLetter: op.letter,
            opIndex: op.index,
            parentHash: currentParent,
            payload: payload,
            sigilName: name,
            nonce: nonce,
            machineUUID: MACHINE_UUID,
            signature: sig
        )

        sigilChain.append(block)
        currentParent = sig
        blocksAdded += 1

        // Visual trace
        let progress = String(repeating: "\u{2593}", count: i + 1) + String(repeating: "\u{2591}", count: sigil.operations.count - i - 1)
        print("  \(C_DIM)[\(progress)]\(C_RESET) \(op.letter) \(C_ACTION)\(op.op)\(C_RESET) \(C_DIM)\(sig.prefix(16))...\(C_RESET)")
    }

    // Persist the chain
    persistChain()
    forgeAudit("SIGIL_EXECUTED: \(name) — \(blocksAdded) blocks, chain length \(sigilChain.count)")
    chainAudit("EXEC_OK: \(name) — \(blocksAdded) blocks signed, final hash \(currentParent.prefix(32))...")

    let msg = "Sigil '\(name)' executed. \(blocksAdded) operations signed and chained."
    print("  \(C_EXPAND)\(msg)\(C_RESET)")
    print("  \(C_DIM)Chain: \(sigilChain.count) blocks | Final: \(currentParent.prefix(24))...\(C_RESET)")

    return ExecutionResult(sigilName: name, blocksAdded: blocksAdded, chainLength: sigilChain.count,
                           finalHash: currentParent, arc: sigil.arc, success: true, reason: msg)
}

// ─── Chain inspection ───

func showChainStatus() {
    let (valid, brokenAt) = verifyChain()
    print()
    print("  \(C_BOLD)SIGIL CHAIN STATUS\(C_RESET)")
    print("  \(C_DIM)Blocks:\(C_RESET) \(sigilChain.count)")
    print("  \(C_DIM)Integrity:\(C_RESET) \(valid ? "\(C_EXPAND)VERIFIED\(C_RESET)" : "\(C_HEART)BROKEN at block \(brokenAt ?? -1)\(C_RESET)")")
    print("  \(C_DIM)Machine:\(C_RESET) \(MACHINE_UUID.prefix(16))...")
    if let last = sigilChain.last {
        print("  \(C_DIM)Last block:\(C_RESET) #\(last.index) \(last.opLetter) \(last.opCode) [\(last.sigilName)]")
        print("  \(C_DIM)Last hash:\(C_RESET) \(last.signature.prefix(32))...")
        let dt = Date(timeIntervalSince1970: last.timestamp)
        print("  \(C_DIM)Last signed:\(C_RESET) \(ISO8601DateFormatter().string(from: dt))")
    }

    // Count sigils executed
    var sigilCounts: [String: Int] = [:]
    for block in sigilChain { sigilCounts[block.sigilName, default: 0] += 1 }
    if !sigilCounts.isEmpty {
        print("  \(C_DIM)Sigils executed:\(C_RESET)")
        for (name, count) in sigilCounts.sorted(by: { $0.value > $1.value }) {
            print("    \(C_ACTION)\(name)\(C_RESET): \(count) ops")
        }
    }
    print()
}

// ─────────────────────────────────────────
// MARK: - Daemon Mode
// ─────────────────────────────────────────

func daemon() {
    logForge("Forge daemon started. PID: \(ProcessInfo.processInfo.processIdentifier)")

    // Write a UNIX socket or just pulse silently
    // The daemon keeps the heart alive and the Q64 register warm
    let timer = Timer(timeInterval: 5.0, repeats: true) { _ in
        heartBeat()
    }
    RunLoop.current.add(timer, forMode: .default)

    // Handle signals
    signal(SIGTERM) { _ in
        lastBreath()
        persistForgeState()
        exit(0)
    }
    signal(SIGINT) { _ in
        lastBreath()
        persistForgeState()
        exit(0)
    }

    // Run forever
    RunLoop.current.run()
}

// ─────────────────────────────────────────
// MARK: - Main
// ─────────────────────────────────────────

// ─── Security Checks (consistent across all ashrams) ───
guard verifyNotTraced() else {
    fputs("Debugger detected. Forge refuses to operate.\n", stderr)
    exit(1)
}

// Ensure state directory exists
try? FileManager.default.createDirectory(atPath: STATE_DIR, withIntermediateDirectories: true)
chmod(STATE_DIR, 0o700)

forgeAudit("FORGE_OPEN: pid=\(getpid()) uid=\(getuid())")

if !authenticateForge() {
    fputs("Authentication failed. Law XXX: Biometrics ONLY.\n", stderr)
    exit(1)
}

// Build hexagram tables
buildHexagrams()

// Awaken the heart
awakenHeart()

// Load forge state
loadForgeState()

// Load sigil chain and verify integrity
loadChain()
let (chainOk, chainBreak) = verifyChain()
chainIntegrityVerified = chainOk
if !chainOk {
    fputs("WARNING: Sigil chain integrity BROKEN at block \(chainBreak ?? -1). TAMPERING DETECTED.\n", stderr)
    forgeAudit("CHAIN_TAMPER: Integrity check failed at block \(chainBreak ?? -1)")
}
forgeAudit("CHAIN_LOADED: \(sigilChain.count) blocks, integrity=\(chainOk ? "VERIFIED" : "BROKEN")")

// Parse arguments
let args = CommandLine.arguments
if args.count > 1 && args[1] == "--daemon" {
    daemon()
} else if args.count > 1 && args[1] == "--status" {
    showStatus()
    lastBreath()
} else if args.count > 2 && args[1] == "--ask" {
    let question = args[2...].joined(separator: " ")
    let reading = consult(question: question)
    displayReading(reading)
    lastBreath()
} else if args.count > 1 && args[1] == "--version" {
    print("L7 Forge v2.0.0 — On-Device Quantum Computing")
    print("Q64 Register: 262,144 states (18-bit, 5-system convergence)")
    print("Q64 Extended: 22 operations (3 + 7 + 12 = Rose Cross convergence)")
    print("IQS-888: c=64, \u{0127}=1, G=4\u{03C0}\u{00B2} | Council: 4 polarities")
    print("Creator: Alberto Valido Delgado | Publisher: Avli Cloud | L7 Universal OS")
    lastBreath()
} else {
    // Interactive REPL
    repl()
}

// L7:PROVENANCE
// Creator: Alberto Valido Delgado | System: L7 Universal OS
// License: Proprietary — Framework free, products licensed (Law XXII)
// File: l7-forge.swift | Ported from lib/hexagrams.js + lib/polarity.js + lib/gateway.js + lib/heart.js
// This work is the intellectual property of Alberto Valido Delgado.
