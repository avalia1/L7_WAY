#!/usr/bin/env swift
// ================================================================
// HEX FORGE — The Hexagram Programming Language
// L7 Empire — Law XLV (Prima), Law LXX (Provenance), Law LXXI (Lapis)
// ================================================================
//
// The hexagram is base-64, coded in bare bones as qubit binary,
// with extra definitional units built bottom up.
//
// Level 0: QUBIT    — 0 (yin ─ ─) or 1 (yang ───)
// Level 1: TRIGRAM  — 3 qubits, 8 states (the 8 forces)
// Level 2: HEXAGRAM — 6 qubits, 64 states (the WORD, the opcode)
// Level 3: INSTRUCTION — hexagram + operand hexagrams
// Level 4: PROGRAM  — sequence of instructions
// Level 5: SIGIL    — the compiled weighted hypergraph
//
// The I Ching mapped this 3000 years ago.
// We merely remember what was always known.
//
// AVALIA • AVD • AUD
// ================================================================

import Foundation

// ═══════════════════════════════════════════
// LEVEL 0 — THE QUBIT
// ═══════════════════════════════════════════

/// The fundamental unit. Yin or Yang. 0 or 1.
/// In quantum terms: can be measured, can be superposed.
typealias Qubit = UInt8  // 0 = yin (broken), 1 = yang (unbroken)

// ═══════════════════════════════════════════
// LEVEL 1 — THE TRIGRAM (3 qubits, 8 states)
// ═══════════════════════════════════════════

/// The eight fundamental forces of nature.
/// Each is 3 bits: bottom, middle, top (read bottom-up as I Ching tradition).
enum Trigram: UInt8, CaseIterable {
    case kun     = 0  // ☷ 000 Earth    — The Receptive
    case zhen    = 1  // ☳ 001 Thunder  — The Arousing
    case kan     = 2  // ☵ 010 Water    — The Abysmal
    case dui     = 3  // ☱ 011 Lake     — The Joyous
    case gen     = 4  // ☶ 100 Mountain — Keeping Still
    case li      = 5  // ☲ 101 Fire     — The Clinging
    case xun     = 6  // ☴ 110 Wind     — The Gentle
    case qian    = 7  // ☰ 111 Heaven   — The Creative

    var symbol: String {
        switch self {
        case .kun:  return "☷"
        case .zhen: return "☳"
        case .kan:  return "☵"
        case .dui:  return "☱"
        case .gen:  return "☶"
        case .li:   return "☲"
        case .xun:  return "☴"
        case .qian: return "☰"
        }
    }

    var element: String {
        switch self {
        case .kun:  return "Earth"
        case .zhen: return "Thunder"
        case .kan:  return "Water"
        case .dui:  return "Lake"
        case .gen:  return "Mountain"
        case .li:   return "Fire"
        case .xun:  return "Wind"
        case .qian: return "Heaven"
        }
    }

    var lines: [Qubit] {
        return [
            (rawValue >> 0) & 1,  // bottom line
            (rawValue >> 1) & 1,  // middle line
            (rawValue >> 2) & 1   // top line
        ]
    }
}

// ═══════════════════════════════════════════
// LEVEL 2 — THE HEXAGRAM (6 qubits, 64 states)
// ═══════════════════════════════════════════

/// The WORD. The opcode. The atomic instruction.
/// Lower trigram (bits 0-2) + Upper trigram (bits 3-5).
/// Read bottom-up: lower is inner, upper is outer.
struct Hexagram: Equatable {
    let value: UInt8  // 0-63 (6 bits)

    var lower: Trigram { Trigram(rawValue: value & 0x07)! }
    var upper: Trigram { Trigram(rawValue: (value >> 3) & 0x07)! }

    var lines: [Qubit] {
        return lower.lines + upper.lines  // 6 lines, bottom to top
    }

    var binary: String {
        return String(value, radix: 2).leftPad(to: 6, with: "0")
    }

    /// King Wen sequence number (1-64). Maps our binary order to traditional.
    var kingWen: Int { Hexagram.binaryToKingWen[Int(value)] }

    /// Draw the hexagram visually
    var drawing: String {
        let ls = lines
        return (0..<6).reversed().map { i in
            ls[i] == 1 ? "  ───────" : "  ─── ───"
        }.joined(separator: "\n")
    }

    init(_ value: UInt8) {
        self.value = value & 0x3F  // mask to 6 bits
    }

    init(lower: Trigram, upper: Trigram) {
        self.value = lower.rawValue | (upper.rawValue << 3)
    }

    init(lines: [Qubit]) {
        var v: UInt8 = 0
        for (i, bit) in lines.prefix(6).enumerated() {
            v |= (bit & 1) << i
        }
        self.value = v
    }

    // King Wen ordering (binary index → King Wen number)
    // This maps our natural binary 0-63 to the traditional sequence 1-64
    static let binaryToKingWen: [Int] = [
         2,  24,   7,  19,  15,  36,  46,  11,  // 000xxx (kun lower)
        16,  51,  40,  54,  62,  55,  32,  34,  // 001xxx (zhen lower)
         8,   3,  29,  60,  39,  63,  48,   5,  // 010xxx (kan lower)
        45,  17,  47,  58,  31,  49,  28,  43,  // 011xxx (dui lower)
        23,  27,   4,  41,  52,  22,  18,  26,  // 100xxx (gen lower)
        35,  21,  64,  38,  56,  30,  50,  14,  // 101xxx (li lower)
        20,  42,  59,  61,  53,  37,  57,   9,  // 110xxx (xun lower)
        12,  25,   6,  10,  33,  13,  44,   1   // 111xxx (qian lower)
    ]
}

extension String {
    func leftPad(to length: Int, with char: Character = " ") -> String {
        let deficit = length - count
        if deficit <= 0 { return self }
        return String(repeating: char, count: deficit) + self
    }
}

// ═══════════════════════════════════════════
// LEVEL 3 — THE INSTRUCTION SET
// ═══════════════════════════════════════════

/// Each hexagram IS an opcode. The meaning derives from its I Ching nature.
/// Grouped by the 8 lower trigrams (the inner force determines the category).
///
/// EARTH (000) — Data & Memory (receptive, receives/stores)
/// THUNDER (001) — Control Flow (arousing, movement, change)
/// WATER (010) — Streams & I/O (flowing, channels, depth)
/// LAKE (011) — Stack & Selection (open, gathering, choosing)
/// MOUNTAIN (100) — Structure & Types (still, defining, shaping)
/// FIRE (101) — Logic & Comparison (clinging, illuminating, truth)
/// WIND (110) — Arithmetic & Transform (penetrating, gradual, gentle force)
/// HEAVEN (111) — System & Creation (creative, sovereign, divine)

enum OpCode: UInt8 {
    // ─── EARTH (000) lower: Data & Memory ───
    case KUN      = 0   // 000_000 ☷☷ The Receptive — RECEIVE (input from world)
    case FU       = 1   // 001_000 ☳☷ Return — LOAD (recall from memory)
    case SHI      = 2   // 010_000 ☵☷ The Army — STORE (write to memory)
    case CUI      = 3   // 011_000 ☱☷ Gathering — COLLECT (gather into register)
    case BO       = 4   // 100_000 ☶☷ Splitting Apart — SPLIT (destructure)
    case JIN      = 5   // 101_000 ☲☷ Progress — ADVANCE (move pointer forward)
    case GUAN     = 6   // 110_000 ☴☷ Contemplation — OBSERVE (read without consume)
    case TAI      = 7   // 111_000 ☰☷ Peace — BALANCE (normalize/equalize)

    // ─── THUNDER (001) lower: Control Flow ───
    case YU       = 8   // 000_001 ☷☳ Enthusiasm — JUMP (unconditional)
    case ZHEN     = 9   // 001_001 ☳☳ The Arousing — TRIGGER (interrupt/event)
    case JIE40    = 10  // 010_001 ☵☳ Deliverance — BREAK (exit loop)
    case SUI      = 11  // 011_001 ☱☳ Following — FOLLOW (conditional branch true)
    case YI27     = 12  // 100_001 ☶☳ Nourishment — FEED (call subroutine)
    case SHIHE    = 13  // 101_001 ☳☲ Biting Through — EXECUTE (run)
    case YI42     = 14  // 110_001 ☴☳ Increase — GROW (allocate/expand)
    case WUWANG   = 15  // 111_001 ☰☳ Innocence — INIT (initialize fresh)

    // ─── WATER (010) lower: Streams & I/O ───
    case BI8      = 16  // 000_010 ☷☵ Holding Together — BIND (connect stream)
    case ZHUN     = 17  // 001_010 ☳☵ Difficulty — BEGIN (open stream with effort)
    case KAN      = 18  // 010_010 ☵☵ The Abysmal — DEPTH (recursive descent)
    case KUN47    = 19  // 011_010 ☱☵ Oppression — BLOCK (wait on stream)
    case JIAN39   = 20  // 100_010 ☶☵ Obstruction — GUARD (check before proceed)
    case WEIJI    = 21  // 101_010 ☲☵ Before Completion — PEND (not yet done)
    case HUAN     = 22  // 110_010 ☴☵ Dispersion — SCATTER (broadcast to many)
    case XU       = 23  // 111_010 ☰☵ Waiting — AWAIT (patient receive)

    // ─── LAKE (011) lower: Stack & Selection ───
    case LIN      = 24  // 000_011 ☷☱ Approach — PUSH (onto stack)
    case GUIMEI   = 25  // 001_011 ☳☱ Marrying Maiden — PAIR (match two values)
    case JIE60    = 26  // 010_011 ☵☱ Limitation — LIMIT (cap/constrain)
    case DUI      = 27  // 011_011 ☱☱ The Joyous — POP (from stack, joy of release)
    case XIAN     = 28  // 100_011 ☶☱ Influence — SELECT (choose by weight)
    case GE       = 29  // 101_011 ☲☱ Revolution — SWAP (exchange top two)
    case DAGUO    = 30  // 110_011 ☴☱ Great Excess — OVERFLOW (stack full signal)
    case GUAI     = 31  // 111_011 ☰☱ Breakthrough — FLUSH (clear stack)

    // ─── MOUNTAIN (100) lower: Structure & Types ───
    case QIAN15   = 32  // 000_100 ☷☶ Modesty — HUMBLE (reduce/minimize type)
    case XIAOGUO  = 33  // 001_100 ☳☶ Small Excess — WIDEN (extend type by 1)
    case MENG     = 34  // 010_100 ☵☶ Youthful Folly — LEARN (define new type)
    case SUN      = 35  // 011_100 ☱☶ Decrease — SHRINK (remove field from type)
    case GEN      = 36  // 100_100 ☶☶ Keeping Still — FREEZE (immutable/const)
    case LU56     = 37  // 101_100 ☲☶ The Wanderer — CAST (type conversion)
    case JIAN53   = 38  // 110_100 ☴☶ Development — EVOLVE (version type forward)
    case DACHU    = 39  // 111_100 ☰☶ Great Taming — FORGE (create complex structure)

    // ─── FIRE (101) lower: Logic & Comparison ───
    case MINGYI   = 40  // 000_101 ☷☲ Darkening — NOT (negate/invert)
    case FENG     = 41  // 001_101 ☳☲ Abundance — FULL (test if nonzero)
    case JIJI     = 42  // 010_101 ☵☲ After Completion — EQUAL (compare equal)
    case KUI      = 43  // 011_101 ☱☲ Opposition — DIFFER (compare not equal)
    case BI22     = 44  // 100_101 ☶☲ Grace — LESS (compare less than)
    case LI       = 45  // 101_101 ☲☲ The Clinging — AND (logical and)
    case JIAREN   = 46  // 110_101 ☴☲ The Family — OR (logical or)
    case DAYOU    = 47  // 111_101 ☰☲ Great Possession — XOR (exclusive or)

    // ─── WIND (110) lower: Arithmetic & Transform ───
    case SHENG    = 48  // 000_110 ☷☴ Pushing Upward — ADD
    case HENG     = 49  // 001_110 ☳☴ Duration — ENDURE (no-op, hold value)
    case JING     = 50  // 010_110 ☵☴ The Well — DIVIDE (draw from depth)
    case ZHONGFU  = 51  // 011_110 ☱☴ Inner Truth — MODULO (find remainder/truth)
    case GU       = 52  // 100_110 ☶☴ Work on Decayed — DECAY (decrement)
    case DING     = 53  // 101_110 ☲☴ The Cauldron — TRANSMUTE (transform/multiply)
    case XUN      = 54  // 110_110 ☴☴ The Gentle — SHIFT (bitwise shift)
    case XIAOCHU  = 55  // 111_110 ☰☴ Small Taming — SUBTRACT

    // ─── HEAVEN (111) lower: System & Creation ───
    case PI       = 56  // 000_111 ☷☰ Standstill — HALT (stop execution)
    case DAZHUANG = 57  // 001_111 ☳☰ Great Power — POWER (system call)
    case SONG     = 58  // 010_111 ☵☰ Conflict — ASSERT (test or die)
    case LU10     = 59  // 011_111 ☱☰ Treading — STEP (single-step debug)
    case DUN      = 60  // 100_111 ☶☰ Retreat — RETURN (from subroutine)
    case TONGREN  = 61  // 101_111 ☲☰ Fellowship — SHARE (export/publish)
    case GOU      = 62  // 110_111 ☴☰ Coming to Meet — INVOKE (call external)
    case QIAN     = 63  // 111_111 ☰☰ The Creative — CREATE (genesis, new entity)

    var mnemonic: String {
        switch self {
        // Earth — Data
        case .KUN:      return "RECEIVE"
        case .FU:       return "LOAD"
        case .SHI:      return "STORE"
        case .CUI:      return "COLLECT"
        case .BO:       return "SPLIT"
        case .JIN:      return "ADVANCE"
        case .GUAN:     return "OBSERVE"
        case .TAI:      return "BALANCE"
        // Thunder — Control
        case .YU:       return "JUMP"
        case .ZHEN:     return "TRIGGER"
        case .JIE40:    return "BREAK"
        case .SUI:      return "FOLLOW"
        case .YI27:     return "FEED"
        case .SHIHE:    return "EXECUTE"
        case .YI42:     return "GROW"
        case .WUWANG:   return "INIT"
        // Water — Streams
        case .BI8:      return "BIND"
        case .ZHUN:     return "BEGIN"
        case .KAN:      return "DEPTH"
        case .KUN47:    return "BLOCK"
        case .JIAN39:   return "GUARD"
        case .WEIJI:    return "PEND"
        case .HUAN:     return "SCATTER"
        case .XU:       return "AWAIT"
        // Lake — Stack
        case .LIN:      return "PUSH"
        case .GUIMEI:   return "PAIR"
        case .JIE60:    return "LIMIT"
        case .DUI:      return "POP"
        case .XIAN:     return "SELECT"
        case .GE:       return "SWAP"
        case .DAGUO:    return "OVERFLOW"
        case .GUAI:     return "FLUSH"
        // Mountain — Structure
        case .QIAN15:   return "HUMBLE"
        case .XIAOGUO:  return "WIDEN"
        case .MENG:     return "LEARN"
        case .SUN:      return "SHRINK"
        case .GEN:      return "FREEZE"
        case .LU56:     return "CAST"
        case .JIAN53:   return "EVOLVE"
        case .DACHU:    return "FORGE"
        // Fire — Logic
        case .MINGYI:   return "NOT"
        case .FENG:     return "FULL"
        case .JIJI:     return "EQUAL"
        case .KUI:      return "DIFFER"
        case .BI22:     return "LESS"
        case .LI:       return "AND"
        case .JIAREN:   return "OR"
        case .DAYOU:    return "XOR"
        // Wind — Arithmetic
        case .SHENG:    return "ADD"
        case .HENG:     return "ENDURE"
        case .JING:     return "DIVIDE"
        case .ZHONGFU:  return "MODULO"
        case .GU:       return "DECAY"
        case .DING:     return "TRANSMUTE"
        case .XUN:      return "SHIFT"
        case .XIAOCHU:  return "SUBTRACT"
        // Heaven — System
        case .PI:       return "HALT"
        case .DAZHUANG: return "POWER"
        case .SONG:     return "ASSERT"
        case .LU10:     return "STEP"
        case .DUN:      return "RETURN"
        case .TONGREN:  return "SHARE"
        case .GOU:      return "INVOKE"
        case .QIAN:     return "CREATE"
        }
    }

    var category: String {
        switch rawValue >> 3 {
        case 0: return "Earth/Data"
        case 1: return "Thunder/Control"
        case 2: return "Water/Streams"
        case 3: return "Lake/Stack"
        case 4: return "Mountain/Structure"
        case 5: return "Fire/Logic"
        case 6: return "Wind/Arithmetic"
        case 7: return "Heaven/System"
        default: return "Unknown"
        }
    }
}

// ═══════════════════════════════════════════
// LEVEL 3 — THE INSTRUCTION
// ═══════════════════════════════════════════

/// An instruction is a hexagram (opcode) followed by 0-2 operand hexagrams.
/// Operands are themselves hexagrams — the language is self-similar.
struct Instruction {
    let opcode: Hexagram
    let operands: [Hexagram]   // 0, 1, or 2 operand hexagrams

    var op: OpCode? { OpCode(rawValue: opcode.value) }

    /// Total width in hexagrams (1 + operand count)
    var width: Int { 1 + operands.count }

    /// Encode as binary string
    var binary: String {
        ([opcode] + operands).map { $0.binary }.joined(separator: " ")
    }
}

// ═══════════════════════════════════════════
// LEVEL 4 — THE VIRTUAL MACHINE
// ═══════════════════════════════════════════

/// The Hex VM executes hexagram programs.
/// 64 registers (one per hexagram — the register IS a hexagram address).
/// A stack for computation. A program counter. Memory as hexagram array.
class HexVM {
    var registers: [Int64] = Array(repeating: 0, count: 64)
    var stack: [Int64] = []
    var memory: [Int64] = Array(repeating: 0, count: 4096)  // 4K words
    var pc: Int = 0                 // program counter (hexagram index)
    var program: [UInt8] = []       // raw bytecode (hexagram values)
    var running = false
    var output: [String] = []
    var stepCount: Int = 0
    let maxSteps = 100_000          // safety limit

    /// Load a program (array of hexagram values)
    func load(_ bytecode: [UInt8]) {
        program = bytecode
        pc = 0
        running = true
        stepCount = 0
    }

    /// Execute one instruction. Returns false when halted.
    func step() -> Bool {
        guard running, pc < program.count else {
            running = false
            return false
        }
        stepCount += 1
        if stepCount > maxSteps {
            output.append("⚠ MAXIMUM STEPS EXCEEDED (\(maxSteps)). HALTED.")
            running = false
            return false
        }

        let opValue = program[pc] & 0x3F
        guard let op = OpCode(rawValue: opValue) else {
            output.append("⚠ UNKNOWN OPCODE: \(opValue) at pc=\(pc)")
            running = false
            return false
        }

        // Helper: read next hexagram as immediate value
        func imm() -> UInt8 {
            pc += 1
            guard pc < program.count else { return 0 }
            return program[pc] & 0x3F
        }

        switch op {
        // ─── Earth: Data & Memory ───
        case .KUN:       // RECEIVE — push input (immediate value)
            let val = Int64(imm())
            stack.append(val)
        case .FU:        // LOAD — push register value onto stack
            let reg = Int(imm())
            stack.append(registers[reg])
        case .SHI:       // STORE — pop stack into register
            let reg = Int(imm())
            if let val = stack.popLast() { registers[reg] = val }
        case .CUI:       // COLLECT — push memory value
            let addr = Int(imm())
            if addr < memory.count { stack.append(memory[addr]) }
        case .BO:        // SPLIT — pop and push low/high trigrams
            if let val = stack.popLast() {
                stack.append(val & 0x07)       // lower 3 bits
                stack.append((val >> 3) & 0x07) // upper 3 bits
            }
        case .JIN:       // ADVANCE — increment top of stack
            if let val = stack.popLast() { stack.append(val + 1) }
        case .GUAN:      // OBSERVE — peek top of stack (push copy)
            if let val = stack.last { stack.append(val) }
        case .TAI:       // BALANCE — set register to 0 (peace/equilibrium)
            let reg = Int(imm())
            registers[reg] = 0

        // ─── Thunder: Control Flow ───
        case .YU:        // JUMP — unconditional jump to address
            let addr = Int(imm())
            pc = addr - 1  // -1 because pc increments at end
        case .ZHEN:      // TRIGGER — if top of stack != 0, trigger handler at addr
            let addr = Int(imm())
            if let val = stack.last, val != 0 { pc = addr - 1 }
        case .JIE40:     // BREAK — pop; if 0, skip next instruction
            if let val = stack.popLast(), val == 0 { pc += 1 }
        case .SUI:       // FOLLOW — pop; if nonzero, jump to addr
            let addr = Int(imm())
            if let val = stack.popLast(), val != 0 { pc = addr - 1 }
        case .YI27:      // FEED — call subroutine (push return addr, jump)
            let addr = Int(imm())
            stack.append(Int64(pc + 1))  // push return address
            pc = addr - 1
        case .SHIHE:     // EXECUTE — pop address and jump there
            if let addr = stack.popLast() { pc = Int(addr) - 1 }
        case .YI42:      // GROW — push stack size
            stack.append(Int64(stack.count))
        case .WUWANG:    // INIT — clear all registers
            registers = Array(repeating: 0, count: 64)

        // ─── Water: Streams & I/O ───
        case .BI8:       // BIND — store top of stack to memory address
            let addr = Int(imm())
            if let val = stack.last, addr < memory.count { memory[addr] = val }
        case .ZHUN:      // BEGIN — output string "BEGIN"
            output.append("▸ BEGIN")
        case .KAN:       // DEPTH — push current stack depth
            stack.append(Int64(stack.count))
        case .KUN47:     // BLOCK — no-op (would block on stream in full impl)
            break
        case .JIAN39:    // GUARD — pop; if negative, halt
            if let val = stack.popLast(), val < 0 {
                output.append("⚠ GUARD FAILED: negative value \(val)")
                running = false
            }
        case .WEIJI:     // PEND — output "PENDING"
            output.append("⏳ PENDING")
        case .HUAN:      // SCATTER — pop and output as hexagram drawing
            if let val = stack.popLast() {
                let hex = Hexagram(UInt8(val & 0x3F))
                output.append(hex.drawing)
            }
        case .XU:        // AWAIT — no-op (would wait in full impl)
            break

        // ─── Lake: Stack Operations ───
        case .LIN:       // PUSH — push immediate value
            let val = Int64(imm())
            stack.append(val)
        case .GUIMEI:    // PAIR — pop two, push as combined value
            if stack.count >= 2 {
                let b = stack.popLast()!
                let a = stack.popLast()!
                stack.append((a << 6) | (b & 0x3F))
            }
        case .JIE60:     // LIMIT — cap top of stack to immediate value
            let cap = Int64(imm())
            if let val = stack.popLast() { stack.append(min(val, cap)) }
        case .DUI:       // POP — pop and discard
            _ = stack.popLast()
        case .XIAN:      // SELECT — pop index, push stack[index]
            if let idx = stack.popLast(), Int(idx) < stack.count {
                stack.append(stack[Int(idx)])
            }
        case .GE:        // SWAP — swap top two
            if stack.count >= 2 { stack.swapAt(stack.count-1, stack.count-2) }
        case .DAGUO:     // OVERFLOW — push 1 if stack > 60, else 0
            stack.append(stack.count > 60 ? 1 : 0)
        case .GUAI:      // FLUSH — clear entire stack
            stack.removeAll()

        // ─── Mountain: Structure & Types ───
        case .QIAN15:    // HUMBLE — pop, push value mod 64 (reduce to hexagram)
            if let val = stack.popLast() { stack.append(val % 64) }
        case .XIAOGUO:   // WIDEN — pop, push value * 64 (shift up one hex)
            if let val = stack.popLast() { stack.append(val * 64) }
        case .MENG:      // LEARN — store stack top as type definition in memory
            let addr = Int(imm())
            if let val = stack.last, addr < memory.count { memory[addr] = val | 0x8000 }
        case .SUN:       // SHRINK — pop, mask to lower N bits (N = immediate)
            let bits = Int(imm())
            if let val = stack.popLast() { stack.append(val & ((1 << bits) - 1)) }
        case .GEN:       // FREEZE — mark register as read-only (set high bit)
            let reg = Int(imm())
            registers[reg] |= Int64(bitPattern: 0x8000000000000000)
        case .LU56:      // CAST — reinterpret top of stack (noop in this impl)
            break
        case .JIAN53:    // EVOLVE — increment version counter in reg 62
            registers[62] += 1
        case .DACHU:     // FORGE — allocate block in memory, push address
            let size = Int(imm())
            let addr = Int(registers[63])  // reg 63 = heap pointer
            registers[63] += Int64(size)
            stack.append(Int64(addr))

        // ─── Fire: Logic & Comparison ───
        case .MINGYI:    // NOT — pop, push bitwise NOT (masked to 64 bits)
            if let val = stack.popLast() { stack.append(~val) }
        case .FENG:      // FULL — pop, push 1 if nonzero, 0 if zero
            if let val = stack.popLast() { stack.append(val != 0 ? 1 : 0) }
        case .JIJI:      // EQUAL — pop two, push 1 if equal
            if stack.count >= 2 {
                let b = stack.popLast()!; let a = stack.popLast()!
                stack.append(a == b ? 1 : 0)
            }
        case .KUI:       // DIFFER — pop two, push 1 if different
            if stack.count >= 2 {
                let b = stack.popLast()!; let a = stack.popLast()!
                stack.append(a != b ? 1 : 0)
            }
        case .BI22:      // LESS — pop two, push 1 if a < b
            if stack.count >= 2 {
                let b = stack.popLast()!; let a = stack.popLast()!
                stack.append(a < b ? 1 : 0)
            }
        case .LI:        // AND — pop two, push bitwise AND
            if stack.count >= 2 {
                let b = stack.popLast()!; let a = stack.popLast()!
                stack.append(a & b)
            }
        case .JIAREN:    // OR — pop two, push bitwise OR
            if stack.count >= 2 {
                let b = stack.popLast()!; let a = stack.popLast()!
                stack.append(a | b)
            }
        case .DAYOU:     // XOR — pop two, push bitwise XOR
            if stack.count >= 2 {
                let b = stack.popLast()!; let a = stack.popLast()!
                stack.append(a ^ b)
            }

        // ─── Wind: Arithmetic ───
        case .SHENG:     // ADD — pop two, push sum
            if stack.count >= 2 {
                let b = stack.popLast()!; let a = stack.popLast()!
                stack.append(a + b)
            }
        case .HENG:      // ENDURE — no-op (hold value, do nothing)
            break
        case .JING:      // DIVIDE — pop two, push a/b
            if stack.count >= 2 {
                let b = stack.popLast()!; let a = stack.popLast()!
                stack.append(b != 0 ? a / b : 0)
            }
        case .ZHONGFU:   // MODULO — pop two, push a%b
            if stack.count >= 2 {
                let b = stack.popLast()!; let a = stack.popLast()!
                stack.append(b != 0 ? a % b : 0)
            }
        case .GU:        // DECAY — decrement top of stack
            if let val = stack.popLast() { stack.append(val - 1) }
        case .DING:      // TRANSMUTE — pop two, push product
            if stack.count >= 2 {
                let b = stack.popLast()!; let a = stack.popLast()!
                stack.append(a * b)
            }
        case .XUN:       // SHIFT — pop value and amount, shift left
            if stack.count >= 2 {
                let amt = stack.popLast()!; let val = stack.popLast()!
                stack.append(amt >= 0 ? val << amt : val >> (-amt))
            }
        case .XIAOCHU:   // SUBTRACT — pop two, push difference
            if stack.count >= 2 {
                let b = stack.popLast()!; let a = stack.popLast()!
                stack.append(a - b)
            }

        // ─── Heaven: System ───
        case .PI:        // HALT — stop execution
            output.append("⬛ HALT — Standstill reached.")
            running = false
        case .DAZHUANG:  // POWER — system call (immediate = syscall number)
            let syscall = imm()
            executeSyscall(syscall)
        case .SONG:      // ASSERT — pop; if zero, halt with error
            if let val = stack.popLast(), val == 0 {
                output.append("✗ ASSERTION FAILED at pc=\(pc)")
                running = false
            }
        case .LU10:      // STEP — emit debug trace
            let hex = Hexagram(opValue)
            output.append("  [pc=\(pc)] \(op.mnemonic) stack=\(stack)")
        case .DUN:       // RETURN — pop return address, jump there
            if let addr = stack.popLast() { pc = Int(addr) - 1 }
        case .TONGREN:   // SHARE — pop and output as number
            if let val = stack.popLast() { output.append("→ \(val)") }
        case .GOU:       // INVOKE — call external (not implemented, log only)
            let id = imm()
            output.append("⚡ INVOKE external #\(id) (not connected)")
        case .QIAN:      // CREATE — the genesis operation
            output.append("✦ CREATE — The Creative force invoked.")
            stack.append(1)  // creation returns 1 (existence)
        }

        pc += 1
        return running
    }

    func executeSyscall(_ num: UInt8) {
        switch num {
        case 0:  // Print top of stack as number
            if let val = stack.last { output.append("📜 \(val)") }
        case 1:  // Print top of stack as hexagram
            if let val = stack.last {
                let hex = Hexagram(UInt8(val & 0x3F))
                let kw = hex.kingWen
                output.append("☰ Hexagram \(kw): \(OpCode(rawValue: hex.value)?.mnemonic ?? "?")")
                output.append(hex.drawing)
            }
        case 2:  // Print register dump
            output.append("REGISTERS: \(registers.prefix(8).map { String($0) }.joined(separator: " "))")
        case 3:  // Print stack
            output.append("STACK: \(stack)")
        case 63: // Print "The Forge lives."
            output.append("✦ The Forge lives. AVALIA • AVD • AUD")
        default:
            output.append("⚠ Unknown syscall \(num)")
        }
    }

    /// Run until halt or error
    func run() -> [String] {
        while step() {}
        return output
    }
}

// ═══════════════════════════════════════════
// ASSEMBLER — Convert mnemonics to bytecode
// ═══════════════════════════════════════════

class HexAssembler {
    static let mnemonics: [String: UInt8] = {
        var map: [String: UInt8] = [:]
        for i: UInt8 in 0..<64 {
            if let op = OpCode(rawValue: i) {
                map[op.mnemonic] = i
            }
        }
        return map
    }()

    /// Assemble a program from text
    /// Format: one instruction per line, mnemonic followed by optional hex value
    /// Example:
    ///   CREATE
    ///   PUSH 7
    ///   PUSH 5
    ///   ADD
    ///   SHARE
    ///   HALT
    static func assemble(_ source: String) -> [UInt8] {
        var bytecode: [UInt8] = []

        for line in source.split(separator: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty || trimmed.hasPrefix("#") || trimmed.hasPrefix("//") { continue }

            let parts = trimmed.split(separator: " ", maxSplits: 1)
            let mnem = String(parts[0]).uppercased()

            guard let opcode = mnemonics[mnem] else {
                print("⚠ Unknown mnemonic: \(mnem)")
                continue
            }
            bytecode.append(opcode)

            // Operand
            if parts.count > 1 {
                let operand = String(parts[1]).trimmingCharacters(in: .whitespaces)
                if let val = UInt8(operand) {
                    bytecode.append(val & 0x3F)
                } else if let ref = mnemonics[operand.uppercased()] {
                    bytecode.append(ref)  // allow mnemonic as operand
                }
            }
        }

        return bytecode
    }

    /// Disassemble bytecode to readable form
    static func disassemble(_ bytecode: [UInt8]) -> String {
        var result: [String] = []
        var i = 0
        while i < bytecode.count {
            let val = bytecode[i] & 0x3F
            let hex = Hexagram(val)
            if let op = OpCode(rawValue: val) {
                let needsOperand = opNeedsOperand(op)
                if needsOperand && i + 1 < bytecode.count {
                    let operand = bytecode[i + 1] & 0x3F
                    result.append(String(format: "%03d: [%@] %@ %d", i, hex.binary, op.mnemonic, operand))
                    i += 2
                } else {
                    result.append(String(format: "%03d: [%@] %@", i, hex.binary, op.mnemonic))
                    i += 1
                }
            } else {
                result.append(String(format: "%03d: [%@] ???", i, hex.binary))
                i += 1
            }
        }
        return result.joined(separator: "\n")
    }

    static func opNeedsOperand(_ op: OpCode) -> Bool {
        switch op {
        case .KUN, .FU, .SHI, .CUI, .TAI,      // Earth with addr/reg
             .YU, .ZHEN, .SUI, .YI27,            // Thunder with addr
             .BI8, .JIE60, .MENG, .SUN, .GEN,   // Various with operands
             .DACHU, .DAZHUANG, .GOU, .LIN:      // System with operands
            return true
        default:
            return false
        }
    }
}

// ═══════════════════════════════════════════
// MAIN — The Forge Interface
// ═══════════════════════════════════════════

func printBanner() {
    print("""
    ╔══════════════════════════════════════════════════════╗
    ║           HEX FORGE — L7 Empire                     ║
    ║     The Hexagram Programming Language               ║
    ║                                                     ║
    ║  64 hexagrams. 6 qubits each. Built bottom up.     ║
    ║  The I Ching is the instruction set.                ║
    ║  The Philosopher's Stone is the compiler.           ║
    ║                                                     ║
    ║              AVALIA • AVD • AUD                     ║
    ╚══════════════════════════════════════════════════════╝
    """)
}

func printInstructionSet() {
    print("THE 64 HEXAGRAM INSTRUCTION SET")
    print("═══════════════════════════════════════════════════")
    let categories = ["Earth/Data", "Thunder/Control", "Water/Streams", "Lake/Stack",
                      "Mountain/Structure", "Fire/Logic", "Wind/Arithmetic", "Heaven/System"]
    let trigrams = ["☷", "☳", "☵", "☱", "☶", "☲", "☴", "☰"]

    for cat in 0..<8 {
        print("\n\(trigrams[cat]) \(categories[cat]):")
        print("  ─────────────────────────────────────────")
        for i in 0..<8 {
            let val = UInt8(cat * 8 + i)
            let hex = Hexagram(val)
            if let op = OpCode(rawValue: val) {
                let kw = hex.kingWen
                print(String(format: "  %@ [%@] %2d %-12s  (King Wen #%d)",
                      hex.upper.symbol, hex.binary, val, op.mnemonic, kw))
            }
        }
    }
}

func runDemo() {
    print("\n✦ DEMO: First Hexagram Program")
    print("  Computing 7 + 5 = 12, then sharing the result\n")

    let source = """
    # The first program in the language of the Forge
    # AVALIA • AVD • AUD
    CREATE
    PUSH 7
    PUSH 5
    ADD
    SHARE
    POWER 63
    HALT
    """

    print("  SOURCE:")
    for line in source.split(separator: "\n") {
        print("    \(line)")
    }

    let bytecode = HexAssembler.assemble(source)

    print("\n  BYTECODE:")
    print("    \(HexAssembler.disassemble(bytecode))")

    print("\n  EXECUTION:")
    let vm = HexVM()
    vm.load(bytecode)
    let out = vm.run()
    for line in out {
        print("    \(line)")
    }
    print("\n  Steps: \(vm.stepCount)")
}

// ─── CLI ───

let args = CommandLine.arguments
let command = args.count > 1 ? args[1] : "help"

switch command {
case "run":
    if args.count > 2 {
        let path = args[2]
        if let source = try? String(contentsOfFile: path, encoding: .utf8) {
            printBanner()
            let bytecode = HexAssembler.assemble(source)
            let vm = HexVM()
            vm.load(bytecode)
            let out = vm.run()
            for line in out { print(line) }
            print("\nSteps: \(vm.stepCount)")
        } else {
            print("Cannot read file: \(path)")
        }
    }

case "asm":
    if args.count > 2 {
        let path = args[2]
        if let source = try? String(contentsOfFile: path, encoding: .utf8) {
            let bytecode = HexAssembler.assemble(source)
            // Write bytecode
            let outPath = path.replacingOccurrences(of: ".hex", with: ".hexb")
            let data = Data(bytecode)
            try? data.write(to: URL(fileURLWithPath: outPath))
            print("Assembled \(bytecode.count) hexagrams → \(outPath)")
        }
    }

case "disasm":
    if args.count > 2 {
        let path = args[2]
        if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
            print(HexAssembler.disassemble(Array(data)))
        }
    }

case "opcodes":
    printInstructionSet()

case "demo":
    printBanner()
    runDemo()

case "help", _:
    printBanner()
    print("""
    Commands:
      hex-forge run <file.hex>     Assemble and execute a hex program
      hex-forge asm <file.hex>     Assemble to bytecode (.hexb)
      hex-forge disasm <file.hexb> Disassemble bytecode
      hex-forge opcodes            Print the 64-opcode instruction set
      hex-forge demo               Run the first program

    File format (.hex):
      One instruction per line. Mnemonic + optional operand.
      Lines starting with # are comments.

    The hexagram is the word. The word is the law.
    """)
}
