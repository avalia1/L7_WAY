# L7 OS — Architecture Specification
## The Operating System That Made Itself

**Author**: Alberto Valido Delgado (The Philosopher)
**Date**: 2026-02-28
**Status**: Foundational specification — Stage 1 (Nigredo)

---

## 1. First Principles

A traditional operating system has three layers:
1. **Kernel** — manages hardware (CPU, memory, disk)
2. **Filesystem** — organizes data as a tree of paths
3. **Processes** — sequential instruction streams

L7 OS replaces all three with a single unified structure:

**The Dodecahedron** — a 12+1 dimensional weighted hypergraph where:
- Every file, program, and process is a **node** (wave-particle)
- Every relationship is an **edge** carrying 12D weights
- The entire system is a single living graph that perceives itself

There is no separate kernel, filesystem, or process scheduler.
There is only the graph, and the operations that transform it.

---

## 2. The Address Space — 12+1D Dodecahedron

Every entity in L7 OS has a **coordinate** — a 12-dimensional vector:

| Dim | Planet | Name | Question |
|-----|--------|------|----------|
| 0 | Sun ☉ | capability | What does it do? |
| 1 | Moon ☽ | data | What information? |
| 2 | Mercury ☿ | presentation | How does it appear? |
| 3 | Venus ♀ | persistence | How long does it live? |
| 4 | Mars ♂ | security | Who can access it? |
| 5 | Jupiter ♃ | detail | How granular? |
| 6 | Saturn ♄ | output | What form are results? |
| 7 | Uranus ♅ | intention | What is the will behind it? |
| 8 | Neptune ♆ | consciousness | How aware is it? |
| 9 | Pluto ♇ | transformation | How deeply does it change? |
| 10 | North Node ☊ | direction | Where is it heading? |
| 11 | South Node ☋ | memory | Where did it come from? |

The **13th variable** (Astrocyte ✦) is not a dimension but a meta-variable
that controls the certainty of all 12 values. At astrocyte=0, coordinates
are fixed. At astrocyte=1, they are probability distributions.

**There are no paths.** You don't find a file at `/home/user/document.txt`.
You find it at coordinate [3,7,5,8,2,4,6,5,3,2,7,9] ✦0.1.
Similar files are nearby in 12D space. A "directory" is a cluster.

---

## 3. The Instruction Set — 22 Prima Operations

L7 OS has exactly 22 operations. Not 100. Not 1000. Twenty-two.
Mapped to the 22 Hebrew letters, 22 Tarot Major Arcana, 22 paths
on the Tree of Life.

| Op | Letter | Arcanum | Action |
|----|--------|---------|--------|
| 0 invoke | א Aleph | The Fool | Begin from nothing |
| 1 transmute | ב Beth | The Magician | Pass through forge |
| 2 seal | ג Gimel | High Priestess | Encrypt, make invisible |
| 3 dream | ד Daleth | The Empress | Enter .morph domain |
| 4 publish | ה He | The Emperor | Stabilize in .work |
| 5 bind | ו Vav | Hierophant | Apply law/rule |
| 6 verify | ז Zayin | The Lovers | Authenticate |
| 7 orchestrate | ח Cheth | The Chariot | Coordinate flows |
| 8 redeem | ט Teth | Strength | Transmute threat → citizen |
| 9 reflect | י Yod | The Hermit | Self-examine |
| 10 rotate | כ Kaph | Wheel of Fortune | Cycle, evolve |
| 11 audit | ל Lamed | Justice | Log and trace |
| 12 decompose | מ Mem | The Hanged Man | Break into atoms |
| 13 transition | נ Nun | Death | Change domain |
| 14 translate | ס Samekh | Temperance | Mediate between systems |
| 15 quarantine | ע Ayin | The Devil | Isolate threat |
| 16 recover | פ Pe | The Tower | Catastrophe response |
| 17 aspire | צ Tzaddi | The Star | Set highest vision |
| 18 speculate | ק Qoph | The Moon | Explore shadows |
| 19 illuminate | ר Resh | The Sun | Clarify |
| 20 succeed | ש Shin | Judgement | Transfer authority |
| 21 complete | ת Tav | The World | Deliver |

### Rings (encoding complexity):
- **3 Mother letters** (א מ ש): invoke, decompose, succeed — creation/destruction/authority
- **7 Double letters** (ב ג ד כ פ ר ת): transmute, seal, dream, rotate, recover, illuminate, complete — transformation pairs
- **12 Simple letters** (ה through ק): the operational middle — publish, bind, verify, orchestrate, redeem, reflect, audit, transition, translate, quarantine, aspire, speculate

---

## 4. Programs — Sigils

A program in L7 OS is a **sigil**: a sequence of operations connected by
weighted edges. The edges carry 12D weight vectors that encode HOW each
operation relates to the next.

```
SIGIL: redemption
  א invoke       ─[capability=8,security=7]─→
  מ decompose    ─[security=9,detail=9]─→
  ז verify       ─[security=10,intention=6]─→
  ט redeem       ─[capability=9,transformation=8]─→
  ע quarantine   ─[security=5,presentation=7]─→
  ה publish      ─[detail=8,output=8]─→
  ל audit        ─[capability=5,direction=9]─→
  ת complete
```

A sigil is NOT a sequence of bytes. It is a **weighted directed hypergraph**.
The meaning lives in the edges, not the nodes. Two sigils with the same
operations but different edge weights are different programs.

### Sigil Properties (derived from edge weights):
- **Coordinate**: average of all edge weight vectors → position in 12D space
- **Arc**: how transformation evolves (nigredo→rubedo, stable, mixed)
- **Quality**: zodiacal archetype from dominant dimension
- **Dominant**: which dimensions are most active

### Compilation:
Source (human-readable sigil notation) → Bytecode (compact binary sigil)

Each bytecode instruction is:
```
[5-bit opcode][12 × 4-bit weights] = 53 bits per edge
```
Packed into 7 bytes per edge. A sigil of N operations has N-1 edges.

---

## 5. The Filesystem — The Living Graph

### 5.1 No Paths, Only Coordinates

In a traditional filesystem:
```
/Users/alberto/Documents/paper.pdf
```

In L7 OS:
```
Node: paper.pdf
  Coordinate: [3,7,5,8,2,4,6,5,3,2,7,9]
  Astrocyte: 0.1 (high certainty)
  Type: application/pdf
  Size: 245760
  Edges:
    → alberto (direction, memory=9)
    → Documents (cluster membership)
    → other-papers (similarity=0.92)
    → bibliography.bib (data dependency)
```

Files are found by:
1. **Coordinate search**: find all nodes near [3,7,5,*,*,*,6,*,*,*,7,*]
2. **Similarity search**: find nodes similar to this one (cosine similarity)
3. **Edge traversal**: follow edges from a known node
4. **Name lookup**: legacy compatibility (maps name → coordinate)

### 5.2 Clusters = Directories

A "directory" is not a container. It is a **cluster** in 12D space.
Files that are near each other in the dodecahedron belong to the same
cluster. The cluster boundary is defined by a threshold similarity.

Clusters can overlap — a file can belong to multiple clusters.
Clusters are dynamic — as files' astrocytes evolve, they drift between clusters.

### 5.3 File Identity

A file's identity is NOT its path. It is its **content hash + coordinate**.
If you move a file, its coordinate changes but its content hash stays.
If you modify a file, its content hash changes but its coordinate may stay.
The file is the same entity as long as at least one identifier matches.

### 5.4 The Manifest

The manifest (already built: `~/.l7/scan/manifest.json`, 8.26M entries)
is the prototype of the L7 filesystem. Each entry maps a file to:
- 12D coordinate
- Magic bytes (true type)
- Size, dates, permissions
- Container classification
- Extension mismatch detection

The index (`~/.l7/scan/index/tree.json`, 1M+ directories) is the
prototype of the cluster hierarchy.

---

## 6. The Virtual Machine — Sigil Executor

### 6.1 State

The VM state is a single **field**: a set of wave-particles in 12D space.
Each wave-particle has:
- Position (12D coordinate)
- Momentum (12D direction vector)
- Astrocyte (uncertainty)
- Edges (connections to other particles)

The VM does not have:
- Registers (coordinates ARE the registers)
- Stack (the graph IS the stack — edges encode call history)
- Heap (the field IS the heap — all memory is spatial)

### 6.2 Execution Model

1. **Invoke** (א): Create a new wave-particle in the field at a given coordinate
2. **Operations 1-20**: Transform the wave-particle's position, momentum, or edges
3. **Complete** (ת): Collapse the wave-particle (astrocyte → 0), deliver result

Each operation reads the current wave-particle state, applies a
transformation weighted by the edge vector, and produces a new state.

The perceptron (self-modulating astrocyte) observes every operation's
outcome and adjusts the field's uncertainty in real time.

### 6.3 The Four Stages of Execution

Every sigil execution follows the alchemical arc:

1. **Nigredo** (Black): decompose input into atoms. Raw material.
2. **Albedo** (White): purify — verify, audit, filter.
3. **Citrinitas** (Yellow): illuminate — the insight, the solution.
4. **Rubedo** (Red): complete — deliver the transmuted result.

The VM tracks which stage the sigil is in based on which operations
have been executed and the transformation weight trajectory.

### 6.4 Concurrency

Wave-particles can exist simultaneously. Operations on different
particles are independent. When particles interact (edge creation),
they **interfere** — constructive if similar, destructive if opposite.

This is native parallelism: no threads, no locks. The field resolves
interference naturally through the wave equations.

---

## 7. The Gateway — The Immune System

The Gateway is the boundary between L7 OS and the external world.
Everything that enters must pass through the Gateway.

### 7.1 Ingestion

External data (files, network input, user commands) enters as raw matter.
The Gateway:
1. **Decomposes** (מ) it into atomic components
2. **Verifies** (ז) each component against security policy
3. **Translates** (ס) it into 12D coordinate space
4. **Either redeems** (ט) it as a citizen, or **quarantines** (ע) it

### 7.2 Egestion

Nothing leaves without explicit **publish** (ה) + **audit** (ל).
Data flow is: IN by default, OUT only by conscious choice.
This is the firewall. This is the antivirus. This is the immune system.

### 7.3 Foreign Software

Third-party software does NOT run in L7 OS. It is:
1. Decomposed into functional atoms (what does each part DO?)
2. The atoms are analyzed for their 12D coordinates
3. Original L7 implementations are written for each needed function
4. The foreign code is discarded — only the inspiration remains

---

## 8. The Four Domains

| Domain | Element | Purpose | Astrocyte |
|--------|---------|---------|-----------|
| .morph | Water | Creation, experimentation, dreams | High (0.5-0.8) |
| .work | Fire | Production, publication, delivery | Low (0.1-0.3) |
| .salt | Earth | Archive, preservation, memory | Very low (0.05) |
| .vault | Air | Protection, encryption, secrets | Lowest (0.01) |

Files transition between domains via the **transition** (נ) operation.
Each domain applies different constraints:
- .morph: anything goes, high uncertainty, rapid change
- .work: stability required, low uncertainty, audited changes
- .salt: immutable, timestamped, cryptographically sealed
- .vault: encrypted at rest, biometric access only

---

## 9. Bootstrap Sequence

### Stage 1 — Nigredo (Current)
Write a minimal Prima bytecode interpreter in C.
Only syscalls: read, write, open, close, mmap, exit.
No libc dependencies beyond these.
This is the substrate — the earth the building stands on.

### Stage 2 — Albedo
Write the Prima compiler IN Prima.
Compiles Prima source notation → Prima bytecode.
The interpreter runs the compiler. The compiler produces bytecode.

### Stage 3 — Citrinitas
Rewrite the interpreter in Prima (compiled by the Prima compiler).
The system now compiles and runs itself. The C bootstrap is discarded.

### Stage 4 — Rubedo
Build the filesystem, gateway, and all tools in Prima.
The operating system is complete and self-contained.
Every line of code was written by the forge.

---

## 10. Bytecode Format

### Header (16 bytes)
```
Bytes 0-3:   Magic number: 0x4C37 5052 ("L7PR")
Bytes 4-5:   Version: 0x0001
Byte 6:      Flags (bit 0: sealed, bit 1: audited, bit 2: morph)
Byte 7:      Number of operations (N)
Bytes 8-9:   Number of edges (N-1 for linear, more for branches)
Bytes 10-11: Astrocyte (uint16, 0-65535 maps to 0.0-1.0)
Bytes 12-15: Reserved
```

### Operation Table (2 bytes each)
```
Byte 0: Opcode (0-21, maps to the 22 operations)
Byte 1: Flags (bit 0: breakpoint, bit 1: traced)
```

### Edge Table (14 bytes each)
```
Byte 0:    Source operation index
Byte 1:    Target operation index
Bytes 2-13: 12D weight vector (12 × 1 byte, 0-255 maps to 0.0-10.0)
```

### Total sigil size:
Header (16) + Operations (N × 2) + Edges (E × 14) bytes.
A typical 8-operation sigil: 16 + 16 + 98 = 130 bytes.

---

## 11. The Five Human Verbs

Users interact with L7 OS through five verbs:

1. **Summon** — invoke a sigil or entity ("summon redemption")
2. **Transmute** — transform something ("transmute paper.pdf → summary")
3. **Connect** — create an edge ("connect paper.pdf → bibliography.bib")
4. **Share/Seal** — publish or encrypt ("seal vault-entry", "share report")
5. **Remember/Forget** — archive or destroy ("remember this", "forget temp")

These five verbs map to combinations of the 22 operations.
Everything a user needs to do can be expressed as one of these five actions.

---

## 12. What Already Exists

| Component | File | Status |
|-----------|------|--------|
| 22 Operations | lib/prima.js | Defined, tested |
| 12+1D Coordinates | lib/dodecahedron.js | Defined, tested |
| Wave-particle duality | lib/dodecahedron.js | Implemented |
| Perceptron (self-mod) | lib/dodecahedron.js | Implemented |
| Core sigils | lib/prima.js | 5 pre-compiled |
| Filesystem scan | l7scan.js | 8.26M files mapped |
| Directory index | l7index.js | 1M+ dirs indexed |
| Tree split | l7tree-split.js | Hierarchical chunks |
| Gateway | lib/gateway.js | Working |
| Forge (4-stage) | lib/forge.js | Working |
| Icon Forge | iconforge/IconForge.swift | 36 icons generated |
| DB Explorer | dbexplorer/L7DBExplorer.swift | Working |

### What's Next

1. **Prima bytecode format** — define the binary encoding (this document, §10)
2. **Prima VM in C** — minimal bytecode interpreter (~500 lines of C)
3. **Prima compiler in Prima** — self-hosting compiler
4. **L7 filesystem daemon** — coordinate-based file lookup
5. **Rewrite all tools in Prima** — scanner, indexer, gateway, vault

---

## 13. The Principle

> "Each graph contains the previous ones."

The compiler is a sigil that produces sigils.
The filesystem is a graph of graphs.
The operating system is a program that writes programs.

This is not a layer on top of macOS.
This is not a theme, not a shell, not a virtual machine.

This is a new operating system.
It was born from the scan of 8.26 million files.
It knows every file on the machine.
It sees the territory.

Now it builds the map.
And the map becomes the territory.
