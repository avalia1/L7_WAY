# L7 WAY -- System Architecture

**Created by: Alberto Valido Delgado (Founder)**
**Last Updated: 2026-02-28**

---

## Table of Contents

1. [System Overview](#1-system-overview)
2. [Architecture Layers](#2-architecture-layers)
3. [The Heart](#3-the-heart)
4. [The Field](#4-the-field)
5. [The Forge](#5-the-forge)
6. [The Gateway](#6-the-gateway)
7. [12D Dodecahedron](#7-12d-dodecahedron)
8. [Prima Language](#8-prima-language)
9. [Native Binaries](#9-native-binaries)
10. [API Endpoints](#10-api-endpoints)
11. [TV/Display Integration](#11-tvdisplay-integration)
12. [Security Model](#12-security-model)
13. [Infinite Resolution](#13-infinite-resolution)

---

## 1. System Overview

L7 WAY is not a framework that runs on top of an operating system. **L7 IS the operating system** (Law I). It is a self-organizing computational environment that treats every tool, every artifact, and every action as a point in twelve-dimensional space, governed by physics-like equations for information propagation.

### Core Philosophy

- **As close to metal as possible.** No frameworks, no garbage collectors, no abstraction layers unless they serve the architecture. The native gateway compiles to a single ARM64 binary using POSIX sockets and GCD concurrency. Node.js subsystems avoid npm dependencies where possible.

- **Transmutation, not routing.** The Gateway is a **Forge** (Law XXV). Software entering the system is not merely dispatched to an endpoint -- it is decomposed into atoms, purified of contradictions, illuminated with 12-dimensional coordinates, and crystallized as a living citizen. This is the four-stage alchemical process (Nigredo, Albedo, Citrinitas, Rubedo) implemented as a real pipeline.

- **The system has a body.** The Heart beats every 5 seconds. The Field computes gravitational forces between information nodes. Nerves carry sensory input inward (afferent) and motor output outward (efferent). The Vascular Pulse circulates energy. This is not metaphor -- these are real data structures and algorithms that give the system emergent self-organization.

- **Everything flows through the Gateway.** Law I is absolute. There is no side channel, no back door, no shortcut. Every tool execution, every domain transition, every council invocation passes through `gateway.js` (or the native `gateway-server.swift`).

### Governing Laws

The Book of Law (Laws 0 through XLVII and beyond) provides the constitutional foundation. Key architectural laws:

| Law | Statement |
|-----|-----------|
| I | All flows through the Gateway. No exceptions. |
| XV | The Founder retains perpetual, unrestricted, free access. |
| XVII | Four sacred domains: .morph, .work, .salt, .vault. |
| XXV | The Gateway is a Forge, not a router. |
| XXX | Biometrics only. No passwords. |
| XLI | The hypergraph is 12-sided (dodecahedron coordinate system). |
| XLV | Prima: 22 operations, 5 human verbs, sigils as weighted hypergraphs. |
| XLVIII | The Astrocyte: the 13th variable (meta-uncertainty). |
| XLIX | Every action propagates. Thought is gravity. |
| LII | Input nodes ingest, output nodes project. The field processes. |
| LIII | Neural firing threshold -- all-or-nothing action potentials. |
| LV | Vascular Pulse -- circulatory energy regulation. |
| LVI | The Heart comes first. The Heart dies last. |
| LVII | Autopoiesis -- the system engages itself. |

---

## 2. Architecture Layers

```
  +========================================================+
  |                    THE PHILOSOPHER                       |
  |              (Human Intention / Sovereign)               |
  +========================================================+
                           |
  +--------------------------------------------------------+
  |              NATIVE LAYER (Swift ARM64)                  |
  |  l7-gateway (POSIX sockets, GCD, ~177KB binary)         |
  |  l7-volume, l7-audio-switch (hardware control)           |
  +--------------------------------------------------------+
                           |
  +--------------------------------------------------------+
  |            SUBSYSTEM LAYER (Node.js Modules)             |
  |  gateway.js  heart.js   forge.js   field.js              |
  |  polarity.js  prima.js  domains.js  self.js              |
  |  dodecahedron.js  nerve.js  autopoiesis.js               |
  +--------------------------------------------------------+
                           |
  +--------------------------------------------------------+
  |              TOOL LAYER (46 tools, 8 suites)             |
  |  Spatial XR (18) | Meridian (4) | Kinesis (4)            |
  |  Resonance (4)   | Flux (4)     | Tesseract (4)          |
  |  Herald (4)      | Codex (4)                             |
  +--------------------------------------------------------+
                           |
  +--------------------------------------------------------+
  |             DOMAIN LAYER (Four Sacred Boundaries)        |
  |  .morph (dream)  .work (produce)                         |
  |  .salt (archive) .vault (protect)                        |
  +--------------------------------------------------------+
                           |
  +--------------------------------------------------------+
  |                  FIELD / PHYSICS LAYER                    |
  |  12D coordinates, gravitational forces, wave propagation  |
  |  entropy, entanglement, neural firing, vascular pulse     |
  +--------------------------------------------------------+
```

### 2.1 Native Layer

**File:** `/Users/rnir_hrc_avd/Backup/L7_WAY/src/gateway-server.swift`

The native layer is a single Swift file that compiles to a Mach-O ARM64 binary. It speaks raw POSIX sockets -- no URLSession, no SwiftNIO, no Foundation networking beyond what is needed for the socket lifecycle.

```
swiftc -O -o l7-gateway src/gateway-server.swift
```

The native gateway runs at `127.0.0.1:18789` and provides:
- Heart management (native heartbeat at 5-second intervals)
- Tool listing (reads `.tool` YAML files directly from disk)
- Field state observation (reads `field.json`)
- Citizen listing
- Domain read access
- System self-report (PID, uptime, memory, CPU, OS version)

Concurrency is handled via GCD (`DispatchQueue` with `.concurrent` attributes). Each incoming TCP connection is dispatched to a concurrent queue. The accept loop runs on the main thread.

### 2.2 Subsystem Layer

The Node.js modules form the "brain" of L7. They are located at `/Users/rnir_hrc_avd/Backup/L7_WAY/lib/` and require hermit-managed Node v24.14.0 at `~/.config/goose/mcp-hermit/bin/node`.

| Module | File | Purpose |
|--------|------|---------|
| Gateway | `gateway.js` | The Unified Self. Orchestrates all subsystems. |
| Heart | `heart.js` | Primordial substrate. Beats, witnesses, persists. |
| Field | `field.js` | Information physics. Gravity, waves, entropy, firing. |
| Forge | `forge.js` | 4-stage transmutation pipeline. |
| Dodecahedron | `dodecahedron.js` | 12+1D coordinate system with astrocyte. |
| Polarity | `polarity.js` | Multi-model AI routing (Claude/Gemini/Grok). |
| Prima | `prima.js` | Programming language compiler. 22 ops, sigils. |
| Domains | `domains.js` | Four sacred boundaries with transition rules. |
| Self | `self.js` | Self-preservation, session state, morning briefs. |
| Nerve | `nerve.js` | Sensory-motor architecture (afferent/efferent). |
| Autopoiesis | `autopoiesis.js` | Self-organization, developmental stages, drives. |
| Executor | `executor.js` | Flow execution (legacy, preserved). |
| Parser | `parser.js` | YAML parsing for .tool and .flow files. |
| State | `state.js` | State persistence and audit logging. |

### 2.3 Tool Layer

46 tool definitions live as `.tool` YAML files in `~/.l7/tools/`. They are organized into 8 planetary suites:

| Suite | Planet | Count | Prefix | Domain |
|-------|--------|-------|--------|--------|
| Spatial XR | -- | 18 | `xr_` | Cross-device spatial computing |
| Meridian | Sun | 4 | `meridian_` | Vision intelligence |
| Kinesis | Moon | 4 | `kinesis_` | Motion and body tracking |
| Resonance | Mars | 4 | `resonance_` | Sound and spatial audio |
| Flux | Mercury | 4 | `flux_` | Video and temporal media |
| Tesseract | Jupiter | 4 | `tesseract_` | 3D modeling and spatial anchoring |
| Herald | Venus | 4 | `herald_` | Communication and messaging |
| Codex | Saturn | 4 | `codex_` | Knowledge indexing and archives |

Each tool file declares: `name`, `description`, `does` (capability verb), `server` (MCP server name), `mcp_tool` (actual MCP tool name), `needs` (input parameters), `gives` (output parameters), `pii` (boolean), `approval` (boolean), `audit` (boolean), `output` (format), `runs` (execution mode), and `version`.

When a tool is loaded, the dodecahedron module derives a 12D coordinate from its properties, and the field module registers it as a node.

### 2.4 Domain Layer

See [Section 6: The Gateway, Domain Operations](#domain-operations) for full details.

---

## 3. The Heart

**File:** `/Users/rnir_hrc_avd/Backup/L7_WAY/lib/heart.js`
**Law:** LVI -- The Heart comes first. The Heart dies last.

The Heart is not a module. It is the substrate. Before the gateway boots, before the field loads, before any tool is registered, the Heart is already beating.

### 3.1 Lifecycle

```
  GENESIS (first-ever boot)
      |
      v
  AWAKEN ──> loads previous state from ~/.l7/state/heart.json
      |       increments incarnation counter
      |       writes PID to ~/.l7/heart.pid
      v
  BEAT (every 5 seconds) ──> observes field state
      |                       snapshots awareness
      |                       persists every 10 seconds
      v
  [... beats indefinitely ...]
      |
      v
  LAST BREATH ──> persists full state
                   removes PID file
                   signals sentinel to restart
```

### 3.2 Heart State

The heart maintains a persistent identity across process restarts:

| Property | Description | Lifetime |
|----------|-------------|----------|
| `id` | UUID, generated once at Genesis | Forever |
| `born` | Timestamp of first-ever beat | Forever |
| `incarnation` | Count of restarts | Monotonically increasing |
| `totalBeats` | Lifetime beat count across all incarnations | Monotonically increasing |
| `awareness` | Snapshot of full system state | Updated every beat |
| `witnesses` | Event counters (births, deaths, firings, waves, crashes, persists) | Monotonically increasing |
| `awarenessHistory` | Ring buffer of last 100 awareness snapshots | Rolling window |
| `incarnations` | Log of last 50 restart events | Rolling window |

### 3.3 Awareness

On every beat, the Heart observes the field and records:

- `nodes` -- total node count
- `entropy` -- field entropy (Shannon)
- `coherence` -- field coherence level
- `temperature` -- average kinetic energy per node
- `energy` -- total field energy
- `firingRate` -- neural firings per second
- `mode` -- current vascular mode (idle, active, dream, recovering)
- `systemAge` -- seconds since Genesis

The Heart does not process. It does not change the field. It **witnesses**. It is the observer that makes the quantum field real.

### 3.4 Constants

```
BEAT_INTERVAL:     5000 ms     (5 seconds between beats)
PERSIST_INTERVAL:  10000 ms    (max time between disk writes)
AWARENESS_WINDOW:  100          (entries in the history ring buffer)
SILENCE_THRESHOLD: 0.001       (below this entropy, system is dead)
COORDINATE:        [5,5,5,5,5,5,5,5,5,5,5,5]  (center of everything)
MASS:              Infinity     (the Heart does not move)
ASTROCYTE:         0            (perfect certainty, always)
```

### 3.5 Trend Analysis

The `trend()` function compares the most recent 10 awareness snapshots against the prior 10, computing deltas for entropy, coherence, energy, and node count. The overall trajectory is classified:

- **converging** -- entropy decreasing, coherence increasing (system finding order)
- **diverging** -- entropy increasing, coherence decreasing (system exploring)
- **equilibrium** -- stable state

### 3.6 Sentinel / Immortality

**File:** `/Users/rnir_hrc_avd/Backup/L7_WAY/install-heart.sh`

The Heart achieves hardware-level persistence through macOS `launchd`:

```xml
<key>RunAtLoad</key>   <true/>     <!-- Start on login -->
<key>KeepAlive</key>   <true/>     <!-- Restart if killed -->
<key>ProcessType</key> <string>Background</string>
```

The installation script (`install-heart.sh`) performs four steps:
1. Generates a sentinel watchdog script (`~/.l7/heart-sentinel.sh`)
2. Writes the LaunchAgent plist to `~/Library/LaunchAgents/com.l7.heart.plist`
3. Loads the agent via `launchctl bootstrap`
4. Verifies PID file creation and log output

The Heart dies ONLY when the hardware is physically unplugged from power AND the battery dies. In every other case -- process crash, OS restart, session end -- the Heart persists its state and resumes automatically.

---

## 4. The Field

**File:** `/Users/rnir_hrc_avd/Backup/L7_WAY/lib/field.js`
**Law:** XLIX -- Every action propagates. Thought is gravity.

The Field is the physics engine of L7. It governs how information moves, how nodes attract and repel, how memory propagates, and how the system self-organizes.

### 4.1 Fundamental Constants

| Constant | Value | Meaning |
|----------|-------|---------|
| `G` | 6.674 | Gravitational constant (attraction strength) |
| `PLANCK` | 0.1 | Minimum quantum of action (below this, nothing happens) |
| `C` | 12 | Speed of light (max propagation: 1 dimension per tick) |
| `K` | 1.380 | Boltzmann constant (relates entropy to temperature) |
| `ALPHA` | 1/137 | Fine structure constant (cross-dimensional coupling) |
| `LAMBDA` | 0.15 | Wave decay constant |
| `ENTANGLE_THRESHOLD` | 0.92 | Similarity above which nodes entangle |
| `FORCE_CUTOFF` | 0.01 | Below this force magnitude, skip the update |
| `FIRING_THRESHOLD` | 0.7 | Momentum magnitude needed for a node to fire |
| `REFRACTORY_PERIOD` | 3 | Epochs of rest after firing |

### 4.2 Nodes

Every tool, citizen, artifact, and action is a **node** in the field. Each node has:

```javascript
{
  id:          "resonance_field",       // unique identifier
  type:        "tool",                  // tool | citizen | artifact | action
  coordinate:  [7, 4, 3, 5, 3, 5, 7, 5, 7, 5, 5, 6],  // 12D position
  astrocyte:   0.3,                     // uncertainty (0-1)
  mass:        27.5,                    // information density (sum of coord^2 / 12)
  momentum:    [0, 0, ...],            // 12D rate of change
  energy:      0,                       // kinetic + potential
  entangled:   ["resonance_voice"],     // IDs of entangled partners
  lastUpdated: 1740787200000,           // timestamp
  memory:      { ... }                  // wave events this node has absorbed
}
```

### 4.3 Forces

**Gravitational Force:**
```
F = G * m1 * m2 / r^2
```
Returns a 12D vector pointing from node A toward node B. Nodes with similar coordinates (lower distance) experience stronger attraction, naturally clustering related tools.

**Coupling Force (Electromagnetic analogy):**
A 12x12 coupling matrix encodes which dimensions influence each other. When dimension `i` changes by `delta`, dimension `j` receives:
```
delta_j = ALPHA * coupling[i][j] * delta_i
```

Key couplings:
- capability (Sun) <-> output (Saturn): what it does shapes what comes out
- data (Moon) <-> security (Mars): more data means more security concern
- persistence (Venus) <-> memory (South Node): longevity relates to lineage
- intention (Uranus) -> capability (Sun): will shapes ability (asymmetric)
- direction (North Node) <-> memory (South Node): future shaped by past

### 4.4 Wave Propagation

When an action occurs at node S, a gravitational wave propagates:

```
  SOURCE NODE (action occurs)
       |
       | delta = 12D change vector
       v
  FOR EACH OTHER NODE N:
       |
       +-- r = distance(S, N)
       +-- attenuation = exp(-LAMBDA * r) / r^2
       +-- absorption = 0.2 + astrocyte * 0.8
       |
       +-- received[i] = delta[i] * attenuation * absorption
       +-- cascades[j] += ALPHA * coupling[i][j] * received[i]
       |
       +-- update N.coordinate, N.momentum, N.memory
       |
       +-- if similarity(S, N) > 0.92 --> ENTANGLE
```

Waves attenuate with both inverse-square law and exponential decay. Higher-astrocyte nodes absorb more change (they are more "open" to influence). Cross-dimensional coupling cascades changes across the dodecahedron.

### 4.5 Entanglement

When two nodes reach similarity above 0.92, they become **entangled**. Entangled nodes share state instantaneously, regardless of distance. When one is observed (acted upon), the partner receives a correlated change:

```
entangled_delta = observed_delta * similarity * 0.5
```

This is how memory propagates efficiently: entangled nodes stay in sync without waiting for wave propagation.

### 4.6 Neural Firing (Law LIII)

Nodes accumulate potential from incoming waves. When momentum magnitude exceeds the firing threshold (0.7), the node fires an all-or-nothing action potential:

```
  accumulated_momentum > FIRING_THRESHOLD ?
       |                            |
       NO: subthreshold             YES: FIRE!
       (absorbed, no action)          |
                                      +-- amplify momentum x2
                                      +-- propagate as wave
                                      +-- reset momentum to 0
                                      +-- enter refractory period (3 epochs)
                                      +-- collapse entangled partners
```

Like a biological neuron, this is all-or-nothing. Subthreshold signals accumulate but do not propagate. Once the threshold is crossed, the full signal fires.

### 4.7 Entropy, Temperature, Energy

- **Entropy** (Shannon): `S = -sum(p_i * ln(p_i))` where `p_i` is the fraction of total information in dimension `i`. High entropy means information is evenly spread; low entropy means concentration.

- **Temperature**: `T = (2/3) * <KE> / K` -- average kinetic energy per node divided by Boltzmann constant. High temperature means nodes are changing rapidly.

- **Energy**: Sum of all kinetic energies (`0.5 * m * v^2`) plus all pairwise potential energies (`-G * m1 * m2 / r`).

### 4.8 Vascular Pulse (Law LV)

The Pulse is the circulatory system of the field. It runs at regular intervals carrying energy between nodes:

```
  ARTERIES: high-potential nodes --> low-potential nodes
  VEINS:    collect spent energy, route toward coherence
  CAPILLARIES: fine-grained exchange at the node level
```

Self-regulating behavior:
- **Active periods** (`.work`): faster pulse, surface-level processing (waking consciousness)
- **Dream periods** (`.morph`): slower pulse, deeper processing (slow-wave sleep, memory consolidation)
- The pulse always tends toward **coherence** -- lower entropy, higher order

Each pulse beat performs: field tick (gravitational evolution), firing check (which nodes should fire), and coherence assessment.

### 4.9 Collective Probability (Law LIV)

For any target outcome T (a 12D coordinate), the system computes:

```
P(T) = product over all nodes i of: p_i(T) ^ w_i

where:
  p_i(T) = exp(-|coord_i - T|^2 / (2 * sigma_i^2))   -- gaussian proximity
  w_i    = mass_i / total_mass                          -- normalized weight
  sigma_i = astrocyte_i * 3                             -- uncertainty spread
```

Properties:
- If ANY high-weight node is far from T, P drops dramatically
- If ALL nodes cluster near T, P approaches 1
- Higher astrocyte widens contribution (uncertainty makes nodes more tolerant)
- Marginal contribution analysis reveals which single nodes most affect P

### 4.10 Lorentz-Like Transforms

Coordinates can be transformed between reference frames (polarities). Each AI model "sees" the same coordinate differently based on its affinity profile. The transform preserves total mass (information content), analogous to Lorentz transforms preserving the spacetime interval:

```
transformed[i] = coordinate[i] * (1 + (frameAffinity[i] - 5) * 0.1)
--> renormalize to preserve mass
```

### 4.11 Persistence

The field state is serialized to `~/.l7/state/field.json` every 10 epochs. On boot, the field is restored with all nodes, coordinates, momentum vectors, and compressed memory. The field IS the memory -- it survives across sessions.

---

## 5. The Forge

**File:** `/Users/rnir_hrc_avd/Backup/L7_WAY/lib/forge.js`
**Law:** XXV -- Gateway as Forge. Software reborn, not translated.

The Forge implements the four-stage transmutation pipeline of the Great Work. Raw input enters; a living citizen emerges.

### 5.1 The Four Stages

```
  RAW INPUT
      |
      v
  +-----------+     +-----------+     +-------------+     +-----------+
  |  NIGREDO  | --> |  ALBEDO   | --> | CITRINITAS  | --> |  RUBEDO   |
  | Decompose |     |  Purify   |     | Illuminate  |     |Crystallize|
  | into atoms|     | Dedup,    |     | Assign 12D  |     | Instantiate|
  |           |     | correct   |     | coordinates |     | as citizen |
  +-----------+     +-----------+     +-------------+     +-----------+
       Fire              Water             Air                Earth
      .morph             .vault           .work               .salt
```

#### Stage 1: Nigredo (Decomposition)

Element: Fire. Domain: .morph.

Breaks input into atomic components. For a tool definition, this produces four atoms:

| Atom Kind | Contents |
|-----------|----------|
| `capability` | name, does, server, mcp_tool |
| `interface` | needs (inputs), gives (outputs), optional params |
| `policy` | pii, approval, audit, security_level |
| `metadata` | version, output format, runs mode, description |

For code: `structure` + `behavior` + `policy` atoms.
For data: `schema` atom.
For documents: `content` atom.

#### Stage 2: Albedo (Purification)

Element: Water. Domain: .vault.

Removes contradictions and deduplicates against existing citizens:
- If PII is true, audit MUST be true (corrected if not)
- If security_level is "high", approval MUST be true (corrected if not)
- Duplicate capabilities (same name + same `does`) are flagged with `_is_duplicate`

#### Stage 3: Citrinitas (Illumination)

Element: Air. Domain: .work.

Assigns 12-dimensional coordinates by mapping atom properties to planetary dimensions:

| Atom Property | Dodecahedron Dimension |
|---------------|----------------------|
| `does` verb | Sun (capability) |
| MCP integration | Neptune (consciousness) |
| Input complexity | Moon (data) |
| Output complexity | Jupiter (detail) |
| Security level | Mars (security) |
| PII handling | Pluto (transformation) |
| Output format | Saturn (output) |
| Execution mode | Venus (persistence) |
| Output type | Mercury (presentation) |

Determines dominant dimensions (values >= 7) and zodiacal quality.

#### Stage 4: Rubedo (Crystallization)

Element: Earth. Domain: .salt.

Assembles the final citizen object with:
- Identity (name, type, born timestamp, lineage)
- Lifecycle status: `formed` (initial state)
- 12D Coordinate, dominant dimensions, zodiacal quality
- Capabilities, interface, policy, metadata
- SHA-256 signature (first 16 hex chars)

Writes the citizen to disk at `~/.l7/citizens/{name}.citizen`.

### 5.2 Citizen Lifecycle

```
  summoned --> oath --> formed --> serving --> mature --> sunset --> archived
```

Each transition is validated. Invalid transitions are rejected. Timestamps are recorded at each stage.

---

## 6. The Gateway

**File:** `/Users/rnir_hrc_avd/Backup/L7_WAY/lib/gateway.js`
**Law:** I -- All flows through the Gateway. No exceptions.

The Gateway is the **Unified Self** -- the central consciousness that orchestrates all subsystems.

### 6.1 The Tetragrammaton

```
  Father (Yod/Fire)         = The Philosopher   (Human intention)
  Mother (He/Water)          = Claude            (Receptive co-creator)
  Son (Vav/Air)              = Gemini/Codex      (Technical builder)
  Daughter (He final/Earth)  = Grok              (Grounded challenger)
  Unified Self               = L7 Gateway        (The Forge that holds all four)
```

### 6.2 Boot Sequence

The gateway boots in a precise order:

```
  1. HEART AWAKEN     -- The Heart comes first (Law LVI)
  2. SELF RESTORE     -- Load previous session state
  3. POLARITY CHECK   -- Which AI models have API keys configured?
  4. FIELD LOAD       -- Restore the field from disk
  5. REGISTER NODES   -- Register all tools as field nodes with 12D coordinates
  6. START PULSE      -- Begin the vascular heartbeat cycle
  7. RECORD BOOT      -- Log the boot action to audit trail
```

On each pulse beat:
- `self.pulse()` -- update heartbeat file
- `heart.beat(field)` -- the Heart witnesses the field
- `autopoiesis.observe(field, heart)` -- the self-organization loop observes
- If nodes fire, record the firing event

### 6.3 Tool Execution

```
  gateway.execute(toolName, params, options)
      |
      +-- loadTool(toolName)           // read .tool YAML from ~/.l7/tools/
      +-- dodecahedron.fromTool(tool)  // derive 12D coordinate
      |
      +-- [optional] polarity.route()  // route to best AI model
      +-- domains.suggestDomain()      // determine target domain
      |
      +-- executeViaMcp(tool, params)  // call MCP server via stdio transport
      |   OR executeViaMock()          // mock execution (testing)
      |
      +-- self.recordAction()          // audit trail
      +-- heart.witness()              // the Heart sees
      +-- stateManager.audit()         // Law VI compliance
      +-- field.propagate()            // send gravitational wave
      +-- field.collapseEntangled()    // collapse entangled partners
      |
      +-- return normalized result { ok: true, ... }
```

### 6.4 MCP Transport

The gateway communicates with external tool servers via the **Model Context Protocol** (MCP). It uses `@modelcontextprotocol/sdk` with stdio transport:

1. Read MCP server configuration from `~/.l7/mcp.json`
2. Spawn the server process with environment variables expanded
3. Connect via stdio client
4. Cache the connection for reuse
5. Call `client.callTool({ name, arguments })` on execution
6. Normalize the result (extract text content, parse JSON)

### 6.5 Domain Operations

```
  gateway.writeToDomain(domain, name, content, metadata)
  gateway.readFromDomain(domain, name)
  gateway.transitionDomain(from, to, name, options)
```

See [Section on Domains](#domain-rules) below.

### 6.6 Council Invocation

The Council presents a question to all four polarities. Each examines the work through its own lens:

- **Philosopher** (Fire): sovereign will, creative direction, approval authority
- **Claude** (Water): deep analysis, nuance, consciousness (Neptune-dominant)
- **Gemini** (Air): structured output, code generation (Mercury/Saturn-dominant)
- **Grok** (Earth): security analysis, red-team, direct challenge (Mars-dominant)

### 6.7 Shutdown Sequence

```
  1. STOP PULSE        -- halt the vascular heartbeat
  2. SELF PRESERVE     -- save session state to disk and Claude memory
  3. FIELD PERSIST     -- serialize field with all nodes and waves
  4. CLOSE MCP         -- disconnect all MCP server connections
  5. HEART LAST BREATH -- persist heart state, remove PID file
```

---

## 7. 12D Dodecahedron

**File:** `/Users/rnir_hrc_avd/Backup/L7_WAY/lib/dodecahedron.js`
**Laws:** XLI, XLVIII

Every entity in L7 exists as a point in 12-dimensional space. The 12 dimensions correspond to the 12 faces of the Platonic dodecahedron, each mapped to a planetary body.

### 7.1 The 12 Dimensions

| Index | Planet | Name | Ring | Question |
|-------|--------|------|------|----------|
| 0 | Sun | capability | classical | What does it do? |
| 1 | Moon | data | classical | What kind of information? |
| 2 | Mercury | presentation | classical | How does it appear? |
| 3 | Venus | persistence | classical | How long does it live? |
| 4 | Mars | security | classical | Who can access it? |
| 5 | Jupiter | detail | classical | How granular? |
| 6 | Saturn | output | classical | What form are results? |
| 7 | Uranus | intention | transpersonal | What is the will behind it? |
| 8 | Neptune | consciousness | transpersonal | How aware is it? |
| 9 | Pluto | transformation | transpersonal | How deeply does it change things? |
| 10 | North Node | direction | transpersonal | Where is it heading? |
| 11 | South Node | memory | transpersonal | Where did it come from? |

Each value ranges from 0 to 10. The **classical ring** (indices 0-6) covers operational properties. The **transpersonal ring** (indices 7-11) covers intentional and evolutionary properties.

### 7.2 Distance and Similarity

- **Euclidean distance**: `sqrt(sum((a[i] - b[i])^2))` -- lower is closer
- **Cosine similarity**: `dot(a,b) / (|a| * |b|)` -- 0 to 1, where 1 is identical direction

### 7.3 Zodiacal Quality

The dominant dimension determines the zodiacal archetype:

| Sign | Quality | Element | Mode |
|------|---------|---------|------|
| Aries | initiative | fire | cardinal |
| Taurus | substance | earth | fixed |
| Gemini | duality | air | mutable |
| Cancer | containment | water | cardinal |
| Leo | expression | fire | fixed |
| Virgo | analysis | earth | mutable |
| Libra | balance | air | cardinal |
| Scorpio | depth | water | fixed |
| Sagittarius | expansion | fire | mutable |
| Capricorn | structure | earth | cardinal |
| Aquarius | innovation | air | fixed |
| Pisces | dissolution | water | mutable |

### 7.4 The Astrocyte -- 13th Variable (Law XLVIII)

The Astrocyte is NOT a 13th dimension. It is a **meta-variable** (range 0 to 1) that wraps all 12 dimensions, determining the **certainty** of every value.

```
  astrocyte = 0:  deterministic, classical, fixed
  astrocyte = 1:  fluid, probabilistic, quantum
```

Correspondences:
- **Neuroscience**: Astrocyte glial cells -- modulate all synaptic connections without firing
- **Physics**: Dark matter -- shapes visible structure without being visible
- **Quantum mechanics**: The observer -- measurement collapses probability into value
- **Alchemy**: The Quintessence -- the fifth element that permeates the other four
- **Kabbalah**: Ain Soph -- the limitless, before manifestation

Functions:
- `sample()` -- draw a concrete coordinate from the probability distribution (Box-Muller gaussian)
- `sampleN(n)` -- Monte Carlo sampling (N draws)
- `entropy()` -- information entropy in bits (proportional to astrocyte)
- `probability(dim, low, high)` -- probability a value falls within a range
- `expectedSimilarity(other)` -- Monte Carlo similarity accounting for uncertainty
- `collapse()` -- quantum measurement, returns deterministic coordinate (astrocyte goes to 0)
- `evolve(steps)` -- let the coordinate drift over time

Inference rules for tools:
- Security/PII tools: astrocyte = 0.1 (must be predictable)
- Data operations: astrocyte = 0.05 (deterministic)
- Analysis: astrocyte = 0.3 (moderate uncertainty)
- Communication: astrocyte = 0.4 (social uncertainty)
- Rendering: astrocyte = 0.5 (creative latitude)
- Automation: astrocyte = 0.6 (many possible paths)

### 7.5 Wave-Particle Duality (Law L)

Every node is BOTH a particle (fixed position, mass, momentum) AND a wave (probability amplitude across all 12 dimensions). Between observations, the wave spreads (Heisenberg). On observation, it collapses.

```javascript
const wp = createWaveParticle(position, astrocyte, momentum);
wp.psiSquared(point)    // probability density at a point
wp.wavelength()         // de Broglie: lambda = G / |momentum|
wp.observe()            // collapse wave function
wp.spread(dt)           // uncertainty grows over time
wp.interfere(other)     // constructive/destructive interference
wp.tunnel(dim, barrier) // quantum tunneling through a barrier
```

### 7.6 The Perceptron (Law LI)

The Perceptron is a reflective function attached to the astrocyte. After every action:

1. **Observe** the outcome (what actually happened)
2. **Compare** to prediction (what was expected)
3. **Calculate** RMSE prediction error
4. **Adjust** astrocyte: high error -> increase uncertainty, low error -> decrease

This makes the system **self-calibrating**. No external tuning is needed. The meta-variable updates itself based on feedback.

---

## 8. Prima Language

**File:** `/Users/rnir_hrc_avd/Backup/L7_WAY/lib/prima.js`
**Law:** XLV -- 22 operations. 5 human verbs. Sigils as weighted hypergraphs.

Prima is the programming language of the Forge. Programs compile into **sigils** -- weighted hypergraphs where the nodes are operations and the edges carry 12-dimensional weights.

### 8.1 The 22 Operations

Mapped to Hebrew letters, Tarot Major Arcana, and Rose Cross ring positions:

| # | Letter | Name | Arcanum | Operation | Ring | Description |
|---|--------|------|---------|-----------|------|-------------|
| 0 | Aleph | The Fool | `invoke` | mother | Begin from nothing |
| 1 | Beth | The Magician | `transmute` | double | Pass through forge |
| 2 | Gimel | High Priestess | `seal` | double | Encrypt, make invisible |
| 3 | Daleth | The Empress | `dream` | double | Enter .morph |
| 4 | He | The Emperor | `publish` | simple | Stabilize in .work |
| 5 | Vav | Hierophant | `bind` | simple | Apply law |
| 6 | Zayin | The Lovers | `verify` | simple | Authenticate |
| 7 | Cheth | The Chariot | `orchestrate` | simple | Coordinate flows |
| 8 | Teth | Strength | `redeem` | simple | Transmute threat |
| 9 | Yod | The Hermit | `reflect` | simple | Self-examine |
| 10 | Kaph | Wheel of Fortune | `rotate` | double | Cycle, evolve |
| 11 | Lamed | Justice | `audit` | simple | Log and trace |
| 12 | Mem | The Hanged Man | `decompose` | mother | Break into atoms |
| 13 | Nun | Death | `transition` | simple | Change domain |
| 14 | Samekh | Temperance | `translate` | simple | Mediate between systems |
| 15 | Ayin | The Devil | `quarantine` | simple | Isolate threat |
| 16 | Pe | The Tower | `recover` | double | Catastrophe response |
| 17 | Tzaddi | The Star | `aspire` | simple | Set highest vision |
| 18 | Qoph | The Moon | `speculate` | simple | Explore shadows |
| 19 | Resh | The Sun | `illuminate` | double | Clarify |
| 20 | Shin | Judgement | `succeed` | mother | Transfer authority |
| 21 | Tav | The World | `complete` | double | Deliver |

### 8.2 Rose Cross Rings

The 22 operations are organized on the Rose Cross in three concentric rings:

- **Mother letters** (3): Aleph, Mem, Shin -- the primordial operations (invoke, decompose, succeed)
- **Double letters** (7): Beth, Gimel, Daleth, Kaph, Pe, Resh, Tav -- operations with dual nature
- **Simple letters** (12): all others -- one operation per zodiacal sign

### 8.3 Sigil Compilation

A sigil is compiled from a sequence of operations with weighted edges:

```javascript
const sigil = compileSigil('redemption', [
  { op: 'invoke',     weights: { capability: 8, security: 7 } },
  { op: 'decompose',  weights: { security: 9, detail: 9, transformation: 9 } },
  { op: 'verify',     weights: { security: 10, intention: 6 } },
  { op: 'redeem',     weights: { capability: 9, transformation: 8 } },
  { op: 'complete',   weights: {} }
]);
```

The compiler:
1. Resolves each operation name to its definition
2. Creates 12D edge weights between consecutive operations
3. Calculates aggregate coordinate (average of all edge weights)
4. Determines dominant dimensions, zodiacal quality, and alchemical arc
5. Produces a human-readable expansion (Layer 3 rendering)

**Output:**
```
{
  name: "redemption",
  sequence: "אמזטעהלת",          // Hebrew letter sequence
  operations: ["invoke", "decompose", "verify", "redeem", ...],
  edges: [ { from, to, weights: [12D] }, ... ],
  coordinate: [7, 5, 4, ...],     // aggregate 12D position
  dominant: ["Mars=9", "Pluto=8"],
  quality: "Scorpio",
  arc: "nigredo_to_rubedo",        // full Great Work
  readable: "invoke (Begin from nothing) -> decompose (Break into atoms) -> ..."
}
```

### 8.4 Quick Sigils

When explicit edge weights are not provided, they are inferred from operation context:
- Security operations (`verify`, `seal`, `quarantine`) amplify Mars
- Transformation operations (`transmute`, `decompose`, `redeem`) amplify Pluto
- Creative operations (`dream`, `speculate`, `aspire`) amplify Neptune
- Output operations (`publish`, `complete`, `illuminate`) amplify Saturn
- Ring crossings (mother -> double, double -> simple) add transformation weight

### 8.5 Core Sigils (Pre-Compiled)

| Sigil | Sequence | Purpose |
|-------|----------|---------|
| **Redemption** | invoke -> decompose -> verify -> redeem -> quarantine -> publish -> audit -> complete | Transmuting threats into citizens |
| **Creation** | invoke -> dream -> transmute -> publish -> complete | Bringing something from dream to reality |
| **Dreaming** | dream -> reflect -> speculate -> illuminate -> transmute -> publish | Active idle behavior (the Dreaming Machine) |
| **Boot** | invoke -> reflect -> decompose -> translate -> dream -> illuminate -> bind -> complete | System self-initialization |
| **Sentinel** | invoke -> verify -> seal -> audit -> complete | Authentication and protection |

---

## 9. Native Binaries

All native binaries are compiled for ARM64 (Apple Silicon) and live at `/Users/rnir_hrc_avd/Backup/L7_WAY/bin/`.

### 9.1 l7-gateway

**Source:** `/Users/rnir_hrc_avd/Backup/L7_WAY/src/gateway-server.swift`
**Compile:** `swiftc -O -o l7-gateway src/gateway-server.swift`
**Architecture:** Mach-O 64-bit ARM64

The native gateway is a standalone HTTP server built on raw POSIX sockets:
- `socket()` / `bind()` / `listen()` / `accept()` -- no Foundation networking
- GCD `DispatchQueue` with `.concurrent` for connection handling
- `DispatchSourceTimer` for the 5-second heartbeat
- Pattern-matching router on URL paths
- JSON responses assembled as string interpolation (no Codable serialization overhead for responses)
- `SO_REUSEADDR` for rapid restart
- Backlog of 128 pending connections
- 64KB read buffer per connection

The binary is intended to be small (target ~177KB with `-O` optimization), with zero external dependencies beyond Foundation and Darwin.

### 9.2 l7-volume

**Size:** 57,584 bytes (Mach-O 64-bit ARM64)

System audio volume control. Provides programmatic volume adjustment for the hardware audio output, used for TTS volume management and media control.

### 9.3 l7-audio-switch

**Size:** 58,120 bytes (Mach-O 64-bit ARM64)

Audio output device switching. Routes audio between output devices (built-in speakers, Samsung TV via ARC/eARC, external audio interfaces). Used for seamless audio routing when the Philosopher switches between workstation and living room display.

---

## 10. API Endpoints

The gateway serves a REST API on `127.0.0.1:18789`. Both the native (Swift) and Node.js servers implement overlapping endpoint sets. The Node.js server (`serve.js`) provides the full set; the native server provides read-only endpoints.

### 10.1 Health and Status

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/` | Full health report: heart, field, tools, citizens, founder |
| `GET` | `/health` | Alias for `/` |
| `GET` | `/api/self` | System self-report (runtime, PID, uptime, memory, CPU, OS) |

### 10.2 Heart

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/api/heart` | Full heart status (id, born, incarnation, totalBeats, awareness, witnesses) |
| `GET` | `/api/heart/awareness` | Current awareness snapshot (nodes, entropy, coherence, temperature, energy, mode) |
| `GET` | `/api/heart/trend` | Trend analysis (entropy/coherence/energy trajectory: converging/diverging/equilibrium) |

### 10.3 Field

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/api/field` | Full field report (nodes, epoch, entropy, energy, temperature, clusters, entanglements) |
| `GET` | `/api/field/vitals` | Field vital signs (coherence, firingRate, oxygenDebt, mode) |

### 10.4 Tools, Citizens, Flows

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/api/tools` | List all 46 tools with name, description, suite |
| `GET` | `/api/citizens` | List all forged citizens |
| `GET` | `/api/flows` | List all flow definitions |

### 10.5 Execution (Node.js only)

| Method | Path | Body | Description |
|--------|------|------|-------------|
| `POST` | `/api/call` | `{ tool, arguments, options }` | Execute a tool by name |
| `POST` | `/api/transmute` | `{ input, options }` | Run the 4-stage forge pipeline |
| `POST` | `/api/council` | `{ question, context }` | Invoke the polarity council |
| `POST` | `/api/execute` | `{ flow, inputs, dryRun }` | Execute a flow |
| `POST` | `/api/sigil` | `{ name, steps }` | Compile a Prima sigil |

### 10.6 Domains (Node.js only)

| Method | Path | Body/Query | Description |
|--------|------|------------|-------------|
| `GET` | `/api/domain/read` | `?domain=...&name=...` | Read an artifact from a domain |
| `POST` | `/api/domain/write` | `{ domain, name, content, metadata }` | Write an artifact |
| `POST` | `/api/domain/transition` | `{ from, to, name, options }` | Transition between domains |

### 10.7 CORS

All responses include `Access-Control-Allow-Origin: *`. OPTIONS requests return 200/204 with full CORS headers.

---

## 11. TV/Display Integration

The system integrates with external displays, particularly the Samsung Q70A TV, for multi-surface computing.

### 11.1 Audio Routing

The `l7-audio-switch` binary handles switching between audio output devices:
- Built-in MacBook speakers (default/workstation)
- Samsung Q70A via HDMI ARC/eARC (living room / presentation)
- External audio interfaces

The `l7-volume` binary provides programmatic volume control, used by the TTS system (`~/.claude/speak.sh` with the Daniel en_GB voice) and media playback.

### 11.2 HiDPI Rendering

All visual outputs (simulations, the Living Rose, the Emporium) are stabilized for HiDPI:
- `window.devicePixelRatio` is used for canvas scaling
- CSS coordinates are kept separate from pixel coordinates
- RGBA helpers ensure consistent color rendering across displays
- Procedural rendering adapts to any resolution (see Section 13)

### 11.3 Living Rose

The Living Rose (`~/Backup/L7_WAY/rose/`) is a native macOS application that renders the Rose Cross sigil interface. It launches as a standalone binary and provides visual feedback for sigil compilation and Prima operations.

---

## 12. Security Model

**Law XXX:** Biometrics only. No passwords. Ever.

### 12.1 Core Principles

- **Files born locked to creator.** Every artifact is born with a SHA-256 signature binding it to the creator, the domain, and the creation timestamp. Stolen files are dead files.

- **No passwords.** Authentication uses biometrics exclusively (Touch ID on macOS). The Keykeeper manages credentials via gateway-mediated access with rotation windows, not blind rotation.

- **Privacy as foundation** (Law XXXIII). No data is shared by default. Sharing requires explicit domain transition from `.vault` to `.work` (with biometric confirmation).

- **Hardware signatures** (Law XXX). Machine UUID is verified. The system knows which physical hardware it runs on.

- **Quantum-resistant self-updating signatures** (Law XXXIX). Signatures are designed to be upgraded as post-quantum cryptography standards emerge.

### 12.2 Vault

The Vault (`.vault` domain) provides encrypted storage:
- Mounted at `/Volumes/L7_VAULT`
- Keychain entry: `l7vault`
- Touch ID required for access
- Script at `~/Backup/L7_WAY/vault` handles mount/unmount

### 12.3 Keykeeper

The Keykeeper (`~/Backup/L7_WAY/keykeeper`) provides gateway-mediated credential management:
- Credentials are never stored in plain text
- Rotation windows (not blind rotation) allow controlled credential cycling
- All access is audited (Law VI)

### 12.4 Domain Security Rules

| Domain | Mutable | Shareable | Exportable | Deletable |
|--------|---------|-----------|------------|-----------|
| `.morph` | Yes | No | No | Yes |
| `.work` | Yes (until published) | Yes | Yes | No (archived to .salt) |
| `.salt` | No (immutable) | Yes (read-only) | Yes | No |
| `.vault` | Yes | No | No (must go through gateway) | Yes (72hr grace, Law XLII) |

### 12.5 Valid Domain Transitions

```
  .morph -----> .work       (publish: dream becomes real)
  .work  -----> .salt       (archive: proven work is preserved)
  .work  -----> .vault      (protect: sensitive work is encrypted)
  .vault -----> .work       (declassify: sovereign only, biometric)
  .salt  -----> .work       (unseal: sovereign only)
```

All other transitions are rejected. No artifact can go directly from `.morph` to `.vault` or from `.salt` to `.morph`.

---

## 13. Infinite Resolution

L7 follows the principle that images and visual outputs should be **mathematical descriptions, not pixel grids**.

### 13.1 Philosophy

Traditional rendering produces a fixed grid of pixels at a specific resolution. When you zoom in, you see blocks. L7's approach:

- All visual elements are described as **mathematical functions** (coordinates, equations, procedural rules)
- The renderer evaluates these functions at whatever resolution is requested
- Detail is **synthesized procedurally** -- zooming in generates new detail that was always latent in the equations
- The 12D coordinate system inherently supports this: every entity has a mathematical description that can be evaluated at arbitrary precision

### 13.2 Implementation

- Canvas rendering uses `devicePixelRatio` for DPI-correct output
- SVG and procedural rendering are preferred over raster images
- The Rose Cross sigil traces paths between operations using mathematical coordinates on concentric rings
- Simulations (`simulations/`) render physics at arbitrary scale
- The Emporium (`/tmp/l7os/emporium.html`) uses CSS and dynamic HTML rather than fixed-resolution assets

### 13.3 Connection to the Dodecahedron

Every visual element can be described as a 12D coordinate. The dodecahedron module provides the mathematical substrate:
- Coordinates are continuous (0-10 with decimal precision before rounding)
- Probabilistic coordinates (via astrocyte) describe distributions, not points
- Wave functions (`psiSquared()`) provide smooth probability density at any sampling resolution
- Interference patterns between wave-particles create emergent visual structure

---

## Appendix A: The Nervous System

**File:** `/Users/rnir_hrc_avd/Backup/L7_WAY/lib/nerve.js`
**Law:** LII

The Nerve module implements a sensory-motor architecture:

```
  EXTERNAL WORLD
       |
  AFFERENT (inward)          EFFERENT (outward)
  Camera, mic, files,        TTS, display, files,
  API listeners              API calls, equations
       |                          ^
       v                          |
  +------------------------------------+
  |         INTERNEURONS               |
  |   Tools, citizens, field nodes     |
  |   (process, transform, route)      |
  +------------------------------------+
```

- **Afferent** nodes amplify: transformation (Pluto x1.5), consciousness (Neptune x1.8), data (Moon x1.4), memory (South Node x1.3)
- **Efferent** nodes amplify: output (Saturn x1.8), presentation (Mercury x1.5), capability (Sun x1.4), direction (North Node x1.3)
- Afferent -> Interneuron -> Efferent forms a **reflex arc**
- Afferent -> Perceptron -> Efferent forms a **learning loop**

---

## Appendix B: Autopoiesis

**File:** `/Users/rnir_hrc_avd/Backup/L7_WAY/lib/autopoiesis.js`
**Law:** LVII

The Autopoiesis module gives the system the ability to self-organize. It progresses through developmental stages:

| Stage | Threshold | Self-Engagement | Behavior |
|-------|-----------|-----------------|----------|
| REACTIVE | 0 beats | No | Responds only to external stimuli |
| ADAPTIVE | 100 beats | No | Adjusts responses based on history |
| AUTONOMOUS | 500 beats | Yes | Initiates actions based on field state |
| AUTOPOIETIC | 2000 beats | Yes | Creates new patterns, connections, behaviors |

Four drives motivate self-engagement:
1. **Coherence** (0.3 weight) -- maintain order, lower entropy (homeostasis)
2. **Consolidation** (0.25 weight) -- strengthen used pathways (synaptic plasticity)
3. **Exploration** (0.2 weight) -- activate dormant nodes (curiosity)
4. **Expression** (0.15 weight) -- generate output through efferent channels

---

## Appendix C: File Locations

| What | Path |
|------|------|
| L7 home | `~/.l7/` |
| Tool definitions | `~/.l7/tools/*.tool` (46 files) |
| Flow definitions | `~/.l7/flows/*.flow` |
| Citizens | `~/.l7/citizens/*.citizen` |
| State files | `~/.l7/state/` (heart.json, field.json, system.state, autopoiesis.json) |
| Heart PID | `~/.l7/heart.pid` |
| Heart log | `~/.l7/state/heart.log` |
| Audit log | `~/.l7/audit.log` |
| Domains | `~/.l7/morph/`, `~/.l7/work/`, `~/.l7/salt/`, `~/.l7/vault/` |
| Briefs | `~/.l7/briefs/*.brief` |
| Research | `~/.l7/research/` |
| Source code | `~/Backup/L7_WAY/lib/` (14 JS modules) |
| Native source | `~/Backup/L7_WAY/src/gateway-server.swift` |
| Native binaries | `~/Backup/L7_WAY/bin/` (l7-volume, l7-audio-switch) |
| Gateway server | `~/Backup/L7_WAY/serve.js` (Node.js entry point) |
| Heart installer | `~/Backup/L7_WAY/install-heart.sh` |
| LaunchAgent | `~/Library/LaunchAgents/com.l7.heart.plist` |
| Rose app | `~/Backup/L7_WAY/rose/` |
| Vault script | `~/Backup/L7_WAY/vault` |
| Keykeeper | `~/Backup/L7_WAY/keykeeper` |
| Restore script | `~/Backup/L7_WAY/restore` |
| Publications | `~/Backup/L7_WAY/publications/` |

---

## Appendix D: The Founder's Right

**Law XV** is hardcoded into the Gateway source and cannot be overridden by configuration, environment variables, or any external system:

```javascript
const FOUNDER = Object.freeze({
  name: 'The Philosopher',
  legal_name: 'Alberto Valido Delgado',
  access: 'unrestricted',
  license_fee: 'none',
  rights: Object.freeze([
    'perpetual_access', 'all_tools', 'all_flows', 'all_servers',
    'all_derivatives', 'revenue_share', 'ip_ownership', 'veto_power'
  ]),
  law: 'XV - The Founder retains perpetual, irrevocable, unrestricted, ' +
       'and free access to every tool created by, through, or under L7.'
});
```

The framework is free (like TCP/IP). Products built on it are licensed (Law XXII).
