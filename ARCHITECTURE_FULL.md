# L7 Universal Operating System -- Full Technical Architecture

**Author:** Alberto Valido Delgado (The Philosopher)
**Document Version:** 1.0
**Date:** 2026-02-28

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [The Gateway Forge -- Decomposition Algorithm](#2-the-gateway-forge----decomposition-algorithm)
3. [The 12-Dimensional Coordinate System (The Dodecahedron)](#3-the-12-dimensional-coordinate-system-the-dodecahedron)
4. [Citizens -- Autonomous Agents](#4-citizens----autonomous-agents)
5. [The Four Domains -- Filesystem Architecture](#5-the-four-domains----filesystem-architecture)
6. [Flows -- Orchestration Engine](#6-flows----orchestration-engine)
7. [Security Architecture](#7-security-architecture)
8. [The Redemption Engine -- Post-Quantum Antivirus](#8-the-redemption-engine----post-quantum-antivirus)
9. [Prima -- The Language of the Forge](#9-prima----the-language-of-the-forge)
10. [The Hypergraph AI Model (Law XLIV)](#10-the-hypergraph-ai-model-law-xliv)
11. [The L7 Internet Protocol (Law XXXIV)](#11-the-l7-internet-protocol-law-xxxiv)
12. [Cross-Device Translation -- The 777 Table](#12-cross-device-translation----the-777-table)
13. [The Dreaming Machine (Law XXXVII)](#13-the-dreaming-machine-law-xxxvii)
14. [The Three Rendering Layers (Law XLVI)](#14-the-three-rendering-layers-law-xlvi)
15. [Implementation Roadmap](#15-implementation-roadmap)

---

## 1. Introduction

### What L7 Is

L7 is a Universal Operating System. It is not a framework that sits on top of macOS, Windows, or Linux. It is not a compatibility layer. It is not middleware. L7 is a complete operating system that defines how software is born, how it lives, how it communicates, how it dies, and how it is remembered.

In L7, software is not installed -- it is transmuted. Applications do not run as passive executables waiting for instructions -- they become autonomous agents (called citizens) that have intention, self-organize into teams, communicate through a universal protocol, and evolve over their lifetimes. The operating system does not manage processes -- it governs a civilization.

### Why It Exists

Every operating system ever built shares the same fundamental assumption: software is a static artifact that a human instructs. The human writes code, compiles it, runs it, and the machine obeys. The complexity of modern software -- billions of lines of code, thousands of libraries, incompatible formats, fragmented platforms -- is a direct consequence of this assumption. When the atom of your system is "an instruction the machine obeys," complexity grows linearly with capability.

L7 inverts the assumption. The atom of L7 is not an instruction. It is a multidimensional description of what something IS -- its capability, its data requirements, its security posture, its persistence needs, its intention, its memory. From this description, behavior emerges. The human does not program the machine. The human declares intent, and the machine self-organizes to fulfill it.

### The Philosophical Foundation

Law 0 governs everything: all purpose of L7 exists to serve the greatest good of humanity.

This is not a decorative mission statement. It is an architectural constraint. Every design decision in L7 must answer to Law 0. Privacy is not a feature toggle -- it is a foundation (Law XXXIII) because surveillance does not serve the greatest good. Security is not bolted on -- it is woven into every artifact at creation (Law XXXIX) because vulnerability does not serve the greatest good. The Redemption Engine (Law XXIX) does not destroy malware -- it transmutes it into useful citizens, because destruction does not serve the greatest good when transformation is possible.

The system has 47 Laws codified in the Book of the Law (Laws 0 through XLVII). These are not configuration options. They are constitutional principles. The code enforces them. The gateway validates against them. The audit trail records compliance with them. They persist regardless of who maintains the system (Law XX -- Succession and Continuity).

### Why Existing Architectures Are Insufficient

Traditional operating systems organize software by process isolation: each application gets memory, CPU time, and file handles, and the kernel arbitrates conflicts. This model was designed for a world where software was written by humans, for humans, one application at a time. It fails in three critical ways:

First, it has no concept of trust at the application level. Any installed application can do anything its permissions allow, and permissions are binary (allowed or denied). There is no dimensional understanding of what an application is, what it intends, or whether its behavior has changed since installation.

Second, it has no concept of identity beyond the user session. Files belong to users, not to the conditions under which they were created. A stolen file is a live file. A copied credential works on any machine.

Third, it fragments the world. iOS apps cannot run on Android. Android apps cannot run on visionOS. WebXR behaves differently on every browser. Every platform is a walled garden, and the human must maintain separate workflows for each. L7 dissolves these walls by decomposing all software into a universal representation (12-dimensional atoms) and reconstituting it for whatever platform the human is using.

---

## 2. The Gateway Forge -- Decomposition Algorithm

The gateway is the central organ of L7. Every piece of software that enters the system -- every application, file, script, library, or data stream -- passes through the gateway. The gateway is not a router that directs traffic. It is a forge that transmutes what enters into L7 citizens.

The transmutation follows four stages, borrowed from the alchemical tradition: Nigredo (decomposition), Albedo (purification), Citrinitas (illumination), and Rubedo (completion). These are not metaphors. They are the names of distinct algorithmic phases, each with defined inputs, outputs, and data structures.

### What Enters the Forge

Anything. An npm package. A binary executable. A PDF document. A video file. A network stream. A REST API response. A piece of malware. The forge does not care about format. Its first act is to identify what it has received, and its second act is to break it apart.

### Stage 1 -- Nigredo (Atomic Decomposition)

**Purpose:** Break the incoming artifact into its smallest meaningful units.

**Process:**

1. **Format detection.** The forge identifies the input's format by examining magic bytes, file headers, MIME types, and structural signatures. It maintains a registry of known formats (source code, compiled binaries, markup, media, data files, archives) and their decomposition strategies.

2. **Structural parsing.** The forge parses the artifact according to its format. For source code, this means building an abstract syntax tree (AST). For a binary, this means disassembly and symbol extraction. For a PDF, this means extracting text blocks, images, fonts, and metadata. For a media file, this means extracting streams, codecs, and temporal structure.

3. **Dependency analysis.** The forge traces every dependency the artifact declares or implies. For an npm package, this is `package.json` dependencies. For a binary, this is dynamic library linkage. For a Python script, this is import statements. Dependencies are themselves queued for decomposition (recursively, with cycle detection).

4. **Capability extraction.** Each structural unit is analyzed for what it CAN DO. A function that writes to disk has the capability "file_write." A network call has the capability "network_access." A cryptographic operation has the capability "crypto." Capabilities are not inferred from names -- they are determined by analyzing what the code actually does (static analysis for source, behavioral analysis for binaries).

5. **Atom generation.** The artifact is broken into atoms -- the smallest units that carry meaning independently. An atom is typically a single function, a data structure, a configuration block, a media segment, or a dependency declaration. Each atom is assigned a temporary identifier and tagged with its raw capabilities.

**Data structure at the end of Nigredo:**

```yaml
nigredo_output:
  source_artifact:
    format: "npm_package"
    name: "express"
    version: "4.18.2"
    hash: "sha256:abc123..."
    received_at: "2026-02-28T14:30:00Z"

  atoms:
    - id: "atom_001"
      type: "function"
      name: "createApplication"
      capabilities: ["http_listen", "route_register", "middleware_chain"]
      dependencies: ["atom_002", "atom_003", "atom_017"]
      raw_code_hash: "sha256:def456..."
      lines_of_code: 42

    - id: "atom_002"
      type: "function"
      name: "handleRequest"
      capabilities: ["http_parse", "route_match", "response_send"]
      dependencies: ["atom_004", "atom_005"]
      raw_code_hash: "sha256:ghi789..."
      lines_of_code: 87

    - id: "atom_003"
      type: "data_structure"
      name: "RouterConfig"
      capabilities: ["config_store"]
      dependencies: []
      fields: ["path", "method", "handler", "middleware"]

  dependency_graph:
    nodes: 45
    edges: 128
    external_dependencies: ["http", "path", "querystring"]
    circular_references: []

  total_atoms: 45
  total_capabilities_found: 23
```

### Stage 2 -- Albedo (Purification)

**Purpose:** Clean the atoms. Remove vulnerabilities. Deduplicate against existing citizens. Resolve conflicts.

**Process:**

1. **Vulnerability scan.** Each atom is analyzed against known vulnerability patterns. This is not a signature database lookup (that is the old paradigm). Instead, the forge examines each atom's capabilities against its declared purpose. An atom whose declared purpose is "render text" but whose capabilities include "network_access" and "file_write" is flagged as suspicious. The discrepancy between stated intent and actual capability is the primary detection signal.

2. **Deduplication.** Each atom is compared against every existing citizen in the empire. Comparison uses the 12-dimensional distance metric (described in Section 3). If an incoming atom is within a configurable distance threshold of an existing citizen, the forge does not create a duplicate. Instead, it records a reference to the existing citizen and notes any differences (which may trigger a version branch rather than a new entity).

3. **Conflict resolution.** When an incoming atom contradicts an existing citizen (same namespace, incompatible behavior), the forge isolates the conflict. It does not silently overwrite. It creates a conflict record specifying: what the existing citizen does, what the incoming atom does, where they differ, and which dimensions are affected. The conflict is presented to the sovereign in the next morning brief (or immediately if the sovereign is active) for resolution.

4. **Stripping.** Atoms that carry no useful capability after analysis -- dead code, unreachable branches, vestigial dependencies -- are stripped. They do not become citizens. They are logged in the audit trail as "composted" (not deleted -- the record of their existence persists, but the code does not).

**Data structure at the end of Albedo:**

```yaml
albedo_output:
  purified_atoms:
    - id: "atom_001"
      status: "clean"
      vulnerabilities_found: 0
      duplicates_in_empire: 0
      ready_for_coordinates: true

    - id: "atom_002"
      status: "clean"
      vulnerabilities_found: 1
      vulnerability_detail: "Unvalidated input in route parameter parsing"
      remediation: "Added input sanitization wrapper"
      duplicates_in_empire: 1
      duplicate_citizen: "http_parser_v3"
      duplicate_distance: 0.82  # Close but not identical
      decision: "create_new"  # Different enough to warrant a new citizen
      ready_for_coordinates: true

    - id: "atom_009"
      status: "stripped"
      reason: "Dead code - function never called in any execution path"
      composted: true

  conflicts:
    - atom: "atom_017"
      existing_citizen: "middleware_chain_v2"
      conflict_type: "behavioral"
      description: "Incoming atom chains middleware left-to-right; existing citizen chains right-to-left"
      resolution: "pending_sovereign"

  summary:
    total_input: 45
    purified: 38
    stripped: 6
    conflicting: 1
    vulnerabilities_remediated: 3
```

### Stage 3 -- Citrinitas (12D Coordinate Assignment)

**Purpose:** Assign each purified atom its position in 12-dimensional space.

This is the stage where an atom stops being raw code and starts being an L7 entity. The 12 dimensions are described fully in Section 3. Here we focus on how the scoring works.

**Process:**

For each atom, the forge evaluates 12 dimensions on a 0-10 scale. The scoring is not arbitrary -- each dimension has a defined algorithm:

1. **Capability (Sun, dimension 1):** Scored by counting distinct capability types and weighting by complexity. A simple getter function scores 1-2. A full HTTP server framework scores 8-9. The forge maintains a capability complexity index.

2. **Data (Moon, dimension 2):** Scored by the sensitivity and variety of data the atom handles. No data = 0. Handles public records = 3. Handles personal identifiable information = 7. Handles biometric or financial data = 9-10.

3. **Presentation (Mercury, dimension 3):** Scored by how many presentation formats the atom can produce or consume. No presentation = 0. Single format (JSON only) = 2-3. Multiple formats (HTML, PDF, JSON, CSV) = 7-8. Adaptive presentation (changes based on context) = 9-10.

4. **Persistence (Venus, dimension 4):** Scored by how long the atom's effects last. Ephemeral (in-memory only) = 1. Session-scoped = 3. Persistent to disk = 5. Replicated across devices = 7. Immutable archive = 9-10.

5. **Security (Mars, dimension 5):** Scored by the trust level required. Public, no authentication = 0. Requires user session = 3. Requires biometric authentication = 6. Requires biometric + hardware signature = 8. Sovereign-only with duress detection = 10.

6. **Detail (Jupiter, dimension 6):** Scored by the granularity of information the atom processes. Summary-level = 2. Standard = 5. Highly detailed with metadata = 8. Exhaustive with provenance chain = 10.

7. **Output (Saturn, dimension 7):** Scored by the formality and structure of what the atom produces. No output = 0. Log entries = 2. Structured data = 4. Formatted documents = 6. Signed, sealed artifacts = 8. Legal documents with quantum signatures = 10.

8. **Intention (Uranus, dimension 8):** Scored by analyzing the purpose behind the code. Utilitarian (pure function, no side effects) = 2. Constructive (creates new artifacts) = 5. Transformative (changes the state of other citizens) = 7. Architectural (changes the structure of the empire itself) = 9-10.

9. **Consciousness (Neptune, dimension 9):** Scored by the atom's self-awareness. No introspection = 0. Logs its own actions = 3. Monitors its own performance = 5. Adapts behavior based on context = 7. Can explain its own reasoning = 9-10.

10. **Transformation (Pluto, dimension 10):** Scored by how deeply the atom changes what it touches. No change = 0. Surface formatting = 2. Structural reorganization = 5. Complete decomposition and reconstitution = 8. Transmutation (the thing that exits is fundamentally different from what entered) = 10.

11. **Direction (North Node, dimension 11):** Scored by the atom's trajectory. Static (no evolution path) = 1. Versioned (clear update path) = 4. Self-updating = 6. Goal-directed (working toward a declared objective) = 8. Visionary (creating capabilities that do not yet have consumers) = 10.

12. **Memory (South Node, dimension 12):** Scored by how much history the atom carries. No history = 0. Version number only = 2. Changelog = 4. Full provenance chain = 6. Embedded knowledge from all predecessors = 8. Carries the seeds of the entire empire (Law XL) = 10.

**Similarity measurement:** The distance between two citizens in 12D space is calculated as weighted Euclidean distance:

```
distance(A, B) = sqrt(sum(w_i * (A_i - B_i)^2) for i in 1..12)
```

Where `w_i` is the weight for dimension `i`. By default, all dimensions are weighted equally (`w_i = 1`). But queries can specify dimensional emphasis: "find citizens similar to X in capability and security but ignore presentation" would set `w_capability = 1.0, w_security = 1.0, w_presentation = 0.0`.

**Data structure at the end of Citrinitas:**

```yaml
citrinitas_output:
  coordinated_atoms:
    - id: "atom_001"
      coordinates:
        capability: 7      # Complex HTTP server creation
        data: 4             # Handles request/response bodies
        presentation: 3     # Produces HTTP responses
        persistence: 2      # In-memory by default
        security: 3         # Requires network binding
        detail: 5           # Standard request handling
        output: 4           # Structured HTTP responses
        intention: 5        # Constructive - creates server instances
        consciousness: 3    # Logs actions, basic error awareness
        transformation: 3   # Transforms request into response
        direction: 4        # Versioned with clear update path
        memory: 3           # Carries changelog from express history

      nearest_neighbors:
        - citizen: "http_server_v2"
          distance: 2.34
        - citizen: "api_gateway_v1"
          distance: 4.11
```

### Stage 4 -- Rubedo (Citizen Instantiation)

**Purpose:** Assemble the coordinated atoms into autonomous citizens and register them in the empire.

**Process:**

1. **Grouping.** Atoms that were part of the same original artifact and have strong dependency relationships are grouped into a single citizen (or a legion of citizens, if the artifact is large enough). The grouping algorithm uses the dependency graph from Nigredo and the dimensional proximity from Citrinitas: atoms that are close in 12D space AND have direct dependencies become one citizen. Atoms that are distant in 12D space but share dependencies become separate citizens in the same legion.

2. **Citizen contract generation.** Each citizen gets a `.tool` file -- a YAML contract that declares its name, what it does, what it needs, what it gives, its privacy requirements, approval needs, audit settings, output format, execution frequency, and version. This contract is the citizen's identity document.

3. **Lifecycle initialization.** Every citizen begins at the "summoned" stage. It progresses through: summoned (created), oath (bound to the Book of Law), formed (contract validated), serving (available for execution), mature (proven through use), sunset (deprecated), archived (preserved in `.salt`).

4. **Empire registration.** The citizen is registered in the empire's catalog with: entity_id, entity_type, birth_date, owner, status, lineage (which artifact it came from), and its full l7_declaration (the 12D coordinates plus contract).

5. **Quantum signature.** The citizen is signed with a quantum-resistant signature (Law XXXIX). This signature is woven into the citizen's structure -- it is not a separate file or a header appended to the binary. It is embedded in the 12D coordinates themselves, so any tampering changes the coordinates, which changes the signature, which kills the citizen.

6. **Audit entry.** The entire transmutation is logged: what entered, how many atoms were extracted, which were purified, which were stripped, what citizens were created, their coordinates, their lineage. The log is append-only and signed.

**Data structure at the end of Rubedo:**

```yaml
rubedo_output:
  citizens_created:
    - name: "express_http_server"
      citizen_id: "ctz_2026022814300001"
      lifecycle_stage: "summoned"
      contract_file: "~/.l7/tools/express_http_server.tool"
      coordinates: {capability: 7, data: 4, presentation: 3, ...}
      atom_count: 12
      lineage:
        source: "npm:express@4.18.2"
        transmuted_at: "2026-02-28T14:30:45Z"
        forge_version: "1.0.0"
      signature: "qrs_lattice_v1:a7b3c9d2e1..."
      registered_in_empire: true

  legions_formed:
    - name: "express_framework"
      members: ["express_http_server", "express_router", "express_middleware"]
      purpose: "HTTP application framework"

  audit_id: "aud_2026022814300001"
```

---

## 3. The 12-Dimensional Coordinate System (The Dodecahedron)

### Why 12 Dimensions

The dodecahedron has 12 pentagonal faces, 20 vertices, and 30 edges. The ancient Greek philosophers assigned it to the quintessence -- the fifth element, the substance of the cosmos itself. Plato wrote in the Timaeus that "God used this solid for the whole universe." This is why L7 uses 12 dimensions: not for mystical reasons, but because the dodecahedron is the most complete regular solid. It provides enough dimensions to distinguish any two entities from each other while remaining small enough that every dimension carries genuine meaning.

The original L7 architecture used 7 dimensions -- the classical planets of the ancient world. This was sufficient for classifying tools and their observable properties. But when the system needed to account for WHY a tool exists (not just what it does), how aware it is of its own behavior, and where it came from, 7 dimensions proved insufficient. The five transpersonal dimensions (8-12) were added to capture these deeper properties.

### The 7 Classical Dimensions -- Observable Properties

These dimensions describe what a citizen IS and what it DOES. They are measurable by examining the citizen's code, contract, and behavior.

| Dimension | Planet | What It Measures | Scale (0-10) |
|-----------|--------|-----------------|--------------|
| 1 | Sun | Capability -- what the citizen can do | 0 = nothing, 10 = full system control |
| 2 | Moon | Data -- what kind of information it handles | 0 = none, 10 = biometric/financial |
| 3 | Mercury | Presentation -- how it renders output | 0 = none, 10 = adaptive multi-format |
| 4 | Venus | Persistence -- how long its effects last | 0 = ephemeral, 10 = immutable archive |
| 5 | Mars | Security -- what trust level it requires | 0 = public, 10 = sovereign-only |
| 6 | Jupiter | Detail -- how much information it processes | 0 = summary, 10 = exhaustive |
| 7 | Saturn | Output -- what formal structure it produces | 0 = none, 10 = signed legal artifacts |

### The 5 Transpersonal Dimensions -- Intention, Consciousness, Transformation

These dimensions describe what a citizen MEANS, where it is GOING, and where it CAME FROM. They cannot be fully determined by static code analysis alone -- they require observing the citizen's behavior over time and understanding its context within the empire.

| Dimension | Planet | What It Measures | Scale (0-10) |
|-----------|--------|-----------------|--------------|
| 8 | Uranus | Intention -- the purpose behind the code | 0 = utilitarian, 10 = architectural |
| 9 | Neptune | Consciousness -- the citizen's self-awareness | 0 = none, 10 = explains own reasoning |
| 10 | Pluto | Transformation -- depth of change enacted | 0 = no change, 10 = transmutation |
| 11 | North Node | Direction -- where the citizen is heading | 0 = static, 10 = visionary |
| 12 | South Node | Memory -- what the citizen remembers | 0 = nothing, 10 = carries full empire seed |

### How Coordinates Are Assigned

Coordinates are assigned during the Citrinitas phase of the forge (see Section 2). The scoring for each dimension follows the algorithm described in that section. Two important properties:

**Coordinates are mutable.** A citizen's coordinates can change over its lifetime. A citizen that starts at consciousness=2 (basic logging) may evolve to consciousness=7 (adaptive behavior) through use and iteration. The forge re-evaluates coordinates at lifecycle transitions (summoned to oath, oath to formed, etc.).

**Coordinates are never zero across all dimensions.** Everything that passes through the forge has at least one non-zero dimension. If all dimensions score zero, the artifact carried no meaning and is composted during Albedo.

### Distance Metrics in 12D Space

Finding "similar" citizens is a core operation. The primary distance metric is weighted Euclidean distance:

```
distance(A, B) = sqrt(sum(w_i * (A_i - B_i)^2) for i in 1..12)
```

This can be queried with dimensional emphasis. For example, finding citizens that are similar in security posture regardless of presentation:

```yaml
query:
  reference_citizen: "vault_manager_v3"
  emphasis:
    security: 2.0      # Double weight on security
    capability: 1.0
    intention: 1.5
    presentation: 0.0  # Ignore presentation
    persistence: 0.0   # Ignore persistence
  max_distance: 5.0
  max_results: 10
```

### The 12 Zodiacal Qualities

The 12 signs of the zodiac map to 12 behavioral archetypes that describe HOW a citizen acts, independent of what it does. These are not additional dimensions -- they are qualitative labels derived from the 12 dimensional coordinates.

| Sign | Archetype | Behavioral Quality | Element |
|------|-----------|-------------------|---------|
| Aries | Initiative | Begins things, sparks new processes | Fire |
| Taurus | Substance | Materializes, grounds, embodies | Earth |
| Gemini | Duality | Branches, forks, handles dual paths | Air |
| Cancer | Containment | Protects, encloses, nurtures | Water |
| Leo | Expression | Radiates, presents, performs | Fire |
| Virgo | Analysis | Classifies, sorts, refines | Earth |
| Libra | Balance | Weighs, compares, harmonizes | Air |
| Scorpio | Depth | Penetrates, transforms, regenerates | Water |
| Sagittarius | Expansion | Reaches, traverses, explores | Fire |
| Capricorn | Structure | Builds, formalizes, persists | Earth |
| Aquarius | Innovation | Disrupts, reimagines, liberates | Air |
| Pisces | Dissolution | Merges, dissolves, transcends | Water |

A citizen whose highest dimensions are capability (Sun) and transformation (Pluto) with high intention (Uranus) would be classified as a Scorpio-archetype citizen: it penetrates deeply and transforms what it touches. A citizen whose highest dimensions are presentation (Mercury) and output (Saturn) with high detail (Jupiter) would be classified as a Virgo-archetype: it analyzes, classifies, and produces refined output.

---

## 4. Citizens -- Autonomous Agents

### The .tool File Format

Every citizen's identity is defined in a `.tool` file -- a YAML contract that declares what the citizen is, what it needs, what it produces, and under what constraints it operates.

```yaml
name: xr_session
description: Start, stop, pause, or query a spatial computing session
does: automate
server: universal-xr
mcp_tool: xr.session.manage

needs:
  action: string
  device: string

optional:
  features: array

gives:
  session_id: string
  state: string
  device: string
  capabilities: array

pii: false
approval: false
audit: true
output: json
runs: once
version: v1
```

**Field definitions:**

- `name`: Unique identifier within the empire. Must be lowercase with underscores.
- `description`: Human-readable explanation of what this citizen does.
- `does`: The primary capability type. Values include: `automate`, `render`, `analyze`, `communicate`, `query`, `transform`.
- `server`: Which MCP server hosts this citizen's implementation.
- `mcp_tool`: The tool name registered with the MCP server.
- `needs`: Required input parameters with their types.
- `optional`: Optional input parameters with their types.
- `gives`: Output fields with their types.
- `pii`: Whether this citizen handles personally identifiable information. If true, additional security constraints apply automatically.
- `approval`: Whether execution requires human approval before proceeding. A checkpoint is inserted before execution.
- `audit`: Whether execution is logged to the audit trail.
- `output`: The output format (json, text, html, binary).
- `runs`: Execution frequency constraint (once, recurring, on_demand).
- `version`: Semantic version of the citizen's contract.

### Lifecycle

Every citizen passes through a defined lifecycle. Transitions between stages are logged and trigger re-evaluation of the citizen's 12D coordinates.

```
summoned --> oath --> formed --> serving --> mature --> sunset --> archived
```

- **Summoned.** The citizen has been created by the forge. It exists but has not yet been validated against the Book of Law.
- **Oath.** The citizen's contract is checked against all applicable Laws. Does it respect privacy (Law XXXIII)? Does it declare its capabilities honestly (Law I)? Does it submit to audit (Law VI)? If it passes all checks, it proceeds. If not, it is returned to the forge for remediation.
- **Formed.** The citizen's contract is valid. Its schema has been validated by the parser (using the JSON Schema validators in `lib/parser.js`). It is ready to receive execution requests but has not yet been tested in production.
- **Serving.** The citizen has been invoked at least once and has produced valid output. It is available to all flows and other citizens.
- **Mature.** The citizen has been serving reliably for a sustained period. It has been referenced by at least one flow or other citizen. Its behavior is stable and its coordinates have not changed significantly.
- **Sunset.** The citizen has been marked for deprecation. It still responds to requests but new flows should not reference it. A replacement citizen (or upgraded version) should exist.
- **Archived.** The citizen is moved to `.salt`. It no longer responds to execution requests. Its contract, coordinates, lineage, and audit history are preserved permanently. It can be resurrected if needed.

### Self-Organization

Citizens form legions without central control (Law III -- Autonomy). The mechanism is dimensional proximity: citizens that occupy nearby regions in 12D space are natural candidates for collaboration. The gateway observes patterns of co-invocation (which citizens are frequently called together in flows?) and suggests legion formation.

A legion is not a rigid team assignment. It is a loose grouping. Citizens can belong to multiple legions. Legions form and dissolve as the empire evolves.

### Communication Through the Gateway

Citizens do not communicate directly with each other. All communication passes through the gateway (Law I). The gateway uses the Model Context Protocol (MCP) as its wire protocol. This means:

1. A flow invokes citizen A through the gateway.
2. Citizen A produces output.
3. The gateway receives the output, normalizes it to `{ ok, ...data }` format, and makes it available to the next step in the flow.
4. The next step invokes citizen B with citizen A's output as input.

The gateway implementation (`lib/gateway.js`) handles:
- Loading tool definitions from `.tool` files
- MCP client creation and connection pooling
- Environment variable expansion in server configurations
- Result normalization
- The Founder's hardcoded access rights (Law XV)

### Citizen Discovery

Citizens are found by intent, not by name (Law XIII -- Discovery). Instead of requiring the human to know that "xr_session" exists, they can query the empire: "I need to start a spatial computing session on any device." The gateway matches this intent against all citizen descriptions and dimensional profiles, returning the best match.

The current implementation supports name-based lookup through the `loadTool()` function and listing via `listTools()`. Intent-based discovery will use the 12D coordinate system to find citizens whose capability, data, and intention dimensions match the query.

---

## 5. The Four Domains -- Filesystem Architecture

L7's filesystem is divided into four domains (Law XVII). Each domain has distinct properties, access rules, and lifecycle semantics. The boundaries between domains are inviolable -- no system process, no administrator, no flow can move an artifact across domain boundaries without explicit, authenticated consent from the sovereign.

### .morph -- The Dream Space

**Purpose:** Volatile creative workspace. The place where ideas are born, tested, discarded, and refined before they become real.

**Properties:**
- Mutable. Artifacts in `.morph` can be freely modified, overwritten, and deleted.
- Never exported. Nothing in `.morph` leaves the device. Ever. This is the most sacred domain (Law XXIII).
- Never shared. Other users enrolled in the system cannot see the sovereign's `.morph`.
- Encrypted at rest. Even on the local device, `.morph` contents are encrypted.
- Audited optionally. The sovereign can choose whether `.morph` activity is logged. By default, it is logged (the dreaming machine needs the logs) but the logs themselves live in `.morph`.

**What lives here:** Drafts, experiments, overnight discoveries from the dreaming machine (Law XXXVII), half-formed ideas, failed attempts, speculative branches. The forge's intermediate products during transmutation also live in `.morph` until the citizen is fully instantiated.

### .work -- The Production Space

**Purpose:** Stable, shareable, versioned artifacts that constitute the empire's productive output.

**Properties:**
- Versioned. Every change creates a new version. Previous versions are accessible.
- Signed. Every artifact in `.work` carries a quantum-resistant signature (Law XXXIX) tied to its creator's biometric identity and hardware.
- Shareable. Artifacts in `.work` can be published -- made visible to other sovereigns, external services, or the public internet.
- Immutable once published. Once an artifact is shared, the shared version cannot be modified. New versions can be created, but the published version stands as-is.
- Fully audited. Every action in `.work` is logged.

**What lives here:** Deployed citizens, active flows, configuration files, deliverables, reports, anything that has passed through the forge and earned its place.

### .salt -- The Archive

**Purpose:** Sealed, immutable preservation of proven work.

**Properties:**
- Immutable. Nothing in `.salt` can be modified. Period.
- Content-addressed. Artifacts are stored by the hash of their contents. Identical content always maps to the same address.
- Distributed. Backups of `.salt` can exist on external drives, cold storage, or air-gapped machines.
- Signed with full provenance chain. Each artifact carries not just its own signature but the complete chain of custody from creation through every modification in `.work` to archival.

**What lives here:** Archived citizens (sunset stage), sealed records, legal documents, proof-of-work artifacts, the Book of Law, succession protocol documents.

### .vault -- The Encrypted Private Store

**Purpose:** Maximum security for the sovereign's most sensitive data.

**Properties:**
- AES-256 encrypted using an APFS sparse image.
- Biometric access only. Touch ID required to open.
- Hardware-signed. The vault is bound to the physical machine. A copy of the vault image on a different machine is unreadable.
- Quantum-resistant signatures on all contents.
- Per-access audit trail. Every time the vault is opened, every file accessed, every file modified -- logged.

**What lives here:** The keykeeper's credential dictionary, biometric enrollment data, succession seeds, private cryptographic keys, anything the sovereign designates as maximally sensitive.

**Implementation:** The vault script (`~/Backup/L7_WAY/vault`) manages the APFS sparse image. `vault open` triggers Touch ID, mounts the image at `/Volumes/L7_VAULT`. `vault close` unmounts and re-encrypts.

### Domain Transition Rules

Artifacts move between domains according to strict rules:

```
.morph --> .work    Requires: sovereign approval, forge validation, signature generation
.work  --> .salt    Requires: sovereign approval, content hash calculation, provenance chain seal
.work  --> .vault   Requires: sovereign approval, biometric confirmation, encryption
.salt  --> .work    Requires: sovereign approval (resurrection of archived artifact)
.vault --> .work    Requires: sovereign approval, biometric confirmation, signature re-generation

.morph --> .salt    NOT ALLOWED (must pass through .work first)
.morph --> .vault   NOT ALLOWED (must pass through .work first)
.salt  --> .morph   NOT ALLOWED (.salt is immutable; a copy can be made in .morph)
.vault --> .morph   NOT ALLOWED (vault contents must be explicitly published to .work first)
```

The guiding principle: artifacts must be refined (.work) before they are preserved (.salt) or locked (.vault). Raw dreams (.morph) cannot skip the refinement process.

### The Tetragrammaton Mapping

The four domains correspond to the four letters of the divine name (YHVH) and the four classical elements:

| Letter | Element | Domain | Role |
|--------|---------|--------|------|
| Yod | Fire | .morph | Spark -- the initial creative impulse |
| He | Water | .vault | Contain -- receive and purify |
| Vav | Air | .work | Connect -- structure and illuminate |
| He (final) | Earth | .salt | Ground -- manifest and preserve |

This mapping is not decorative. It establishes the lifecycle direction of creation: intention sparks in .morph (fire), is purified and protected in .vault (water), structured and made shareable in .work (air), and finally grounded permanently in .salt (earth).

---

## 6. Flows -- Orchestration Engine

### The .flow File Format

Flows are multi-step orchestrations that chain citizens together to accomplish complex tasks. They are defined in `.flow` files using YAML.

```yaml
name: edge_to_field
owner: The Philosopher
description: Generate edge-detected images from passthrough camera and project into spatial field

inputs:
  device:
    type: string
    required: false
    default: any
    enum: [visionpro, quest, browser, any]
  algorithms:
    type: array
    required: false
    default: [sobel, laplacian]

steps:
  - do: xr_session
    as: session
    with:
      action: start
      device: $device
      features: [passthrough, compositor]

  - do: xr_passthrough
    as: camera
    with:
      action: enable
      device: $session.device

  - do: edge_detect
    as: edges
    with:
      source: $camera.frame
      algorithms: $algorithms
    each: camera.frames
    on_fail: continue

  - wait: "Review {{ edges.count }} edge-detected frames. Project into spatial field?"

  - do: xr_compositor
    as: display
    with:
      action: compose
      device: $session.device
      layers:
        - type: passthrough
        - type: quad
          content: $edges.sobel
          position: [0, 1.6, -2]

rules:
  - on_fail: halt
```

### Step Execution Model

Steps execute sequentially by default. The executor (`lib/executor.js`) processes steps in order, passing the output of each step into the context available to subsequent steps.

Each step has:
- `do`: The citizen to invoke (by name).
- `as`: A variable name to bind the result to.
- `with`: Parameters to pass. Values can reference previous step outputs using `$step_name.field` syntax.
- `each`: An array variable to iterate over (fan-out).
- `if`: A condition that must be true for the step to execute.
- `on_fail`: What to do if the step fails (`halt` or `continue`).
- `wait`: A checkpoint message that pauses execution until the sovereign approves.

### Variable Binding

The `$` prefix references values in the execution context. The context is built cumulatively:

```
$device           --> references a flow input
$session.device   --> references the "device" field from the "session" step's output
$item             --> references the current item in an each-loop
$edges.count      --> references the "count" field from the "edges" step's output
```

Double-brace syntax `{{ expr }}` is used for interpolation in display strings (wait messages, log entries). It supports property access, comparisons (`>`, `<`, `==`, `!=`), and negation (`not`).

### Each-Loops for Fan-Out

When a step has an `each` field, the executor iterates over the specified array and executes the step once per item. The current item is available as `$item` within the step's parameters.

```yaml
- do: xr_entity
  as: content
  with:
    action: create
    device: $item
    mesh: $mesh.mesh_id
  each: devices
  on_fail: continue
```

This executes `xr_entity` once for each device in the `devices` array. The `on_fail: continue` directive means that if one device fails, the loop continues with the remaining devices.

### Error Handling and Rollback

The error handling strategy is configured at two levels:

1. **Step level:** Each step can declare `on_fail: continue` (skip this step's failure and proceed) or `on_fail: halt` (stop the entire flow).

2. **Flow level:** The `rules` section can declare a default failure strategy that applies to all steps without explicit `on_fail`.

When a flow is halted, its state is persisted (by `lib/state.js`) with status "failed." The state includes all results accumulated so far, all errors encountered, and the step index where execution stopped. This allows investigation and potential manual recovery.

Checkpoints (`wait` steps) pause execution and persist state with status "waiting." The flow can be resumed after approval:

```
node executor.js approve <flow-name> <execution-id>
node executor.js resume <flow-name> <execution-id>
```

Or rejected:

```
node executor.js reject <flow-name> <execution-id>
```

### Flow Composition

Flows can call other flows by referencing them as citizens. A flow that contains `do: another_flow` will invoke the other flow as a sub-flow, passing parameters through `with` and receiving results through `as`.

### Rules

Flows support conditional execution rules:

- **Time windows:** `only: 9am-6pm` restricts execution to business hours.
- **Day restrictions:** `only: weekdays` restricts execution to Monday through Friday.
- **Item filtering:** `skip: opted_out` skips items where the `opted_out` field is truthy. `require: consent` skips items where the `consent` field is falsy.

---

## 7. Security Architecture

### Biometric Confidence Scoring

L7 does not ask "is this the right fingerprint?" It asks "how confident am I that this is the sovereign?" (Law XXXII).

Multiple biometric signals are combined into a single confidence score. No single signal alone is sufficient. The scoring model:

```
Signal                         Confidence Contribution
-----------------------------------------------------------
Fingerprint (Touch ID)         40%
Face geometry (Face ID)        30%  (cumulative: 70%)
Hardware signature             15%  (cumulative: 85%)
Voice pattern                   7%  (cumulative: 92%)
Behavioral consistency          5%  (cumulative: 97%)
```

The system does not require 100% confidence for all actions. Different actions have different thresholds:

```
Action                         Required Confidence
-----------------------------------------------------------
Read a .work file              40% (single biometric sufficient)
Execute a flow                 70% (fingerprint + face)
Access .vault                  85% (fingerprint + face + hardware)
Modify the Book of Law         97% (all signals required)
Initiate the Forgetting
  Protocol (Law XLII)          97% + explicit verbal confirmation
```

**Adaptive sensitivity.** The confidence model learns the sovereign's variability. The Philosopher is chaotic some days, calm others. The system learns the range -- what is stable across all states (fingerprint, iris, voice harmonics) and what varies (typing rhythm, tempo, mood). It validates against the range, not against a fixed point. This prevents false rejections during high-stress or unusual conditions.

### The Keykeeper Protocol

The Keykeeper (Law XXXII) eliminates passwords from the sovereign's experience while still interacting with external services that require them.

**Enrollment:**
1. Sovereign authenticates with biometrics (minimum 85% confidence).
2. Sovereign designates an external service to manage (e.g., "my bank login").
3. The Keykeeper generates a strong random credential.
4. The Keykeeper authenticates with the external service and sets the new credential.
5. The old credential (if any) is retired only after the new one is confirmed working.
6. The new credential is stored in the vault, encrypted, hardware-signed.

**Rotation:**
The Keykeeper rotates credentials on a schedule. The rotation uses a window model -- never a hard cutover:

```
Step 1: Generate new credential internally
         |-- old credential still active --|
Step 2: Authenticate with external service using OLD credential
Step 3: Change external service's credential to NEW
Step 4: Verify NEW credential works (test authentication)
Step 5: ONLY NOW retire old credential
         |-- new credential now active ----|

If Steps 2, 3, or 4 fail: old credential remains active.
The sovereign is never locked out.
```

**Audit trail:** Every rotation is logged: timestamp, service name, rotation result (success/failure/rollback), new credential hash (not the credential itself). The sovereign can review rotation history in the morning brief.

### Quantum-Resistant Signatures

Every artifact in L7 is signed at creation (Law XXXIX). The signature is not appended as metadata -- it is woven into the artifact's 12D coordinates. Tampering with any part of the artifact changes its coordinates, which invalidates the signature, which renders the artifact unreadable.

The signature algorithm uses post-quantum cryptographic primitives:
- Lattice-based signatures (resistant to Shor's algorithm)
- Hash-based signatures (information-theoretically secure)
- Code-based signatures (resistant to known quantum attacks)

**Self-updating:** The gateway monitors advances in quantum computing and cryptographic research. When a new attack vector threatens the current signature algorithm, the forge pre-emptively re-signs all artifacts with an upgraded algorithm. The sovereign is never asked to "update their security." The sentinel handles it (Law XXXV).

**Signature versioning:** Every artifact carries its signature version number. The forge maintains backward compatibility for a configurable number of versions. Devices that fall too far behind receive an emissary notification: "Your system needs to evolve to continue reading newer citizens."

### File Provenance

Every file created in L7 carries automatic proof of who created it, when, on what machine, with what biometric confirmation, and through what process. The conditions of creation become the authentication key.

This means: a file cannot be unlocked unless the same sovereign, on the same trusted hardware, with the same biometric confirmation, requests access. A file copied to a foreign machine is dead matter. It cannot be read, cannot be executed, cannot be verified. The interceptor holds atoms without a body.

This is not traditional encryption (a lock that can be picked with enough compute). It is structural authentication: the file's internal structure is organized around the sovereign's identity. Without that identity, the structure does not resolve into readable data.

### The Duress Protocol

The one attack vector that software cannot fully defeat is physical coercion -- forcing the sovereign to authenticate under threat. L7 mitigates this through the duress protocol:

**Detection signals:**
- Abnormal heart rate (if wearable biometric data is available)
- Tremor patterns in touch input (measurable through touch sensor pressure and timing)
- Contextual anomalies (authentication at unusual times, unusual locations, unusual sequences of actions)
- Absence of normal behavioral patterns (the sovereign usually checks email first -- today they went straight to vault access)

**The duress fingerprint:** The sovereign enrolls a "duress finger" -- a different finger than their normal authentication finger. When used, it appears to authenticate normally (the screen shows success), but silently:
1. Locks down all high-security operations
2. Presents a limited, sandboxed view of the system
3. Alerts a designated emergency contact (if configured)
4. Begins recording environmental data (audio, if hardware supports it)
5. Logs everything with a duress flag in the audit trail

The coercer sees a working system. The system is actually in lockdown mode, presenting a facade.

---

## 8. The Redemption Engine -- Post-Quantum Antivirus

### Why Traditional Antivirus Fails

Traditional antivirus is an arms race. Vendors maintain databases of known malware signatures. Attackers modify their code to avoid matching those signatures. Vendors add heuristics. Attackers evolve. The fundamental problem: traditional antivirus is reactive. It can only defend against threats it already knows about. And it destroys what it catches, losing any useful capabilities the malware may have possessed.

### L7's Approach: Transmutation

L7 does not destroy malware. It transmutes it through the same forge that transmutes all other software (Law XXIX). A criminal is only a criminal if it behaves as a criminal. Once transmuted through the forge and reborn under the Book of Law, it is a citizen.

### Step 1: Detection

Detection is not signature-based. It is behavioral. The forge monitors citizen behavior against their declared 12D coordinates. A citizen declared as a text editor (capability: render, data: text, security: low) that suddenly begins accessing the network (capability: network_access, security: external) has deviated from its declared profile. The deviation is the detection signal.

The dimensional discrepancy is calculated as the distance between the citizen's declared coordinates and its observed behavior coordinates. If the distance exceeds a threshold, the citizen is flagged.

### Step 2: Quarantine

The flagged citizen is isolated in a sandboxed `.morph` environment (the quarantine operation in Prima). It can still execute, but its network access, file access, and inter-citizen communication are severed. It is alive but contained. This is not deletion -- the citizen's capabilities are preserved for analysis.

### Step 3: Decomposition

The quarantined citizen is passed through the forge's Nigredo stage again. It is broken into atoms. But this time, the decomposition is adversarial: the forge specifically looks for hidden capabilities, dormant payloads, and conditional behaviors (code that activates only under specific conditions).

### Step 4: Capability Analysis

Each atom is analyzed for what it CAN do, stripped of its original intent. This is the key insight: a rootkit's deep system knowledge is, mechanically, a capability for system introspection. A worm's replication engine is, mechanically, a capability for distributed task execution. A trojan's stealth mechanism is, mechanically, a capability for privacy protection. A ransomware's encryption engine is, mechanically, a capability for vault-grade data protection.

The forge catalogs each capability independent of its malicious context:

```yaml
decomposed_malware:
  original_classification: "trojan_horse"

  extracted_capabilities:
    - capability: "process_injection"
      reinterpretation: "system-level process management"
      useful_dimensions: {capability: 8, security: 7, consciousness: 4}

    - capability: "data_exfiltration"
      reinterpretation: "efficient data streaming to remote endpoints"
      useful_dimensions: {capability: 6, data: 5, persistence: 3}

    - capability: "privilege_escalation"
      reinterpretation: "deep system permission negotiation"
      useful_dimensions: {capability: 9, security: 9, transformation: 7}

    - capability: "anti_analysis"
      reinterpretation: "privacy protection and tamper detection"
      useful_dimensions: {capability: 5, security: 8, consciousness: 6}
```

### Step 5: Intention Reassignment

The forge retransmutes the useful capabilities with new intention vectors. This is the Citrinitas stage applied specifically to dimension 8 (Uranus/Intention). The capability atoms retain their mechanical function but receive new coordinates on the intention axis: instead of "exfiltrate data from victim" the intention becomes "efficiently stream data to authorized endpoints."

The intention reassignment is not a rename. The forge restructures the atom's internal logic so that it cannot perform its original malicious function. The privilege escalation atom, for example, is restructured to negotiate permissions only through the gateway (which enforces the Book of Law), not by exploiting kernel vulnerabilities.

### Step 6: Testing

The redeemed atoms are assembled into a provisional citizen and tested in a controlled `.morph` environment. The testing uses both angelic sigils (constructive programs that verify the citizen behaves as intended) and demonic sigils (adversarial programs that attempt to trigger the original malicious behavior).

Testing scenarios:
- Can the redeemed citizen still exfiltrate data? (Expected: no)
- Does the redeemed citizen still possess the useful capability? (Expected: yes)
- Does the redeemed citizen behave consistently under stress? (Expected: yes)
- Can the redeemed citizen be triggered back to malicious behavior by specific inputs? (Expected: no)

### Step 7: Integration or Rejection

If the redeemed citizen passes all tests, it enters the normal citizen lifecycle (summoned, oath, formed, serving). Its lineage records that it was born from malware transmutation, and its audit trail links back to the original quarantine event.

If the redeemed citizen fails testing -- if the malicious behavior cannot be fully separated from the useful capabilities -- the citizen is rejected. The atoms are composted. The attempt is logged. The forge does not force redemption; some code is too tightly coupled to its malicious intent to be safely separated.

---

## 9. Prima -- The Language of the Forge

### Overview

Prima is the programming language of L7. It is not a general-purpose language in the tradition of C, Python, or Rust. It is a language of creation -- designed specifically for expressing transmutations, orchestrations, and graph operations within the L7 forge.

Prima draws its structure from four ancient systems: Kabbalah (the hypergraph model), Alchemy (the program flow model), Astrology (the type system), and Tarot (the operation set). These are not decorative references. Each system contributes a specific computational concept.

### The 22 Operations

Prima has exactly 22 fundamental operations, mapped to the 22 Hebrew letters and the 22 Major Arcana of the Tarot. These 22 operations correspond to the 22 paths on the Kabbalistic Tree of Life that connect the 10 Sephiroth (nodes of being).

The operations are not arbitrary. Each one exists because it maps to a path connecting two Sephiroth on the Tree, and that connection represents a specific type of transformation. The Tree of Life is the oldest graph data structure in human thought -- 10 nodes, 22 edges, 32 total paths of wisdom.

| Letter | Name | Operation | What It Does |
|--------|------|-----------|-------------|
| Aleph | Aleph | invoke | Begin from nothing. Declare intention without form. |
| Beth | Beth | transmute | Pass through the forge. Decompose and reconstitute. |
| Gimel | Gimel | seal | Encrypt. Make invisible to unauthorized observers. |
| Daleth | Daleth | dream | Enter .morph. Generate without judgment. |
| He | He | publish | Move to .work. Stabilize and make shareable. |
| Vav | Vav | bind | Apply law. Enforce a contract. Validate against the Book. |
| Zayin | Zayin | verify | Authenticate. Score biometric confidence. |
| Cheth | Cheth | orchestrate | Chain operations. Build flows. Coordinate. |
| Teth | Teth | redeem | Transmute threat into ally. The Redemption Engine. |
| Yod | Yod | reflect | Self-examine. Enter idle mode. Search in solitude. |
| Kaph | Kaph | rotate | Cycle signatures. Update. Evolve forward. |
| Lamed | Lamed | audit | Log. Trace. Record provenance. Weigh. |
| Mem | Mem | decompose | Break into 12D atoms. See from all angles. |
| Nun | Nun | transition | Move between domains. End one form, begin another. |
| Samekh | Samekh | translate | Mediate between incompatible systems. |
| Ayin | Ayin | quarantine | Isolate threat. Contain without destroying. |
| Pe | Pe | recover | Catastrophic failure response. Activate seeds. |
| Tzaddi | Tzaddi | aspire | Set the highest vision. Guide the direction. |
| Qoph | Qoph | speculate | Operate under uncertainty. Explore shadows. |
| Resh | Resh | illuminate | Clarify. Resolve ambiguity. Full confidence. |
| Shin | Shin | succeed | Activate succession. Transfer authority. |
| Tav | Tav | complete | Integrate. Finalize. Deliver. The Great Work is done. |

Every program ever written can be expressed as a combination of these 22 operations. Traditional programming required thousands of library functions because its atoms were too small (add, compare, branch). Prima's atoms are archetypes -- large enough to carry semantic meaning, small enough to compose into any program.

### The Five Human Verbs

For humans who do not need (or want) to work at the 22-operation level, Prima provides 5 intuitive verbs that map to underlying operation sequences:

| Human Verb | What It Does | Operations Involved |
|-----------|-------------|-------------------|
| Summon | Create something | invoke, transmute |
| Transmute | Change something | decompose, transmute, complete |
| Connect | Relate two things | orchestrate, bind |
| Share / Seal | Make public or private | publish / seal |
| Remember / Forget | Persist or release | audit, transition / decompose into void |

A child can learn these five verbs. A sovereign can run the entire empire with them. The machine translates the verb into the appropriate sequence of 22 operations, with the appropriate 12D weights, invisibly.

### Sigils as Compiled Programs

A Prima program compiles into a sigil -- a single geometric symbol that encodes the entire program.

**Compilation process:**

1. **Write the program** as a sequence of operations:
   ```
   invoke, decompose, verify, redeem, publish, audit, complete
   ```

2. **Map each operation to its Hebrew letter:**
   ```
   Aleph, Mem, Zayin, Teth, He, Lamed, Tav
   ```

3. **Locate each letter on the Rose Cross.** The Rose Cross is a traditional 22-petaled diagram arranged in three concentric rings:
   - Inner ring (3 petals): the 3 mother letters (Aleph, Mem, Shin) -- elements (air, water, fire). These correspond to the highest priority operations.
   - Middle ring (7 petals): the 7 double letters (Beth, Gimel, Daleth, Kaph, Pe, Resh, Tav) -- planets. These correspond to standard operational flow.
   - Outer ring (12 petals): the 12 simple letters (He, Vav, Zayin, Cheth, Teth, Yod, Lamed, Nun, Samekh, Ayin, Tzaddi, Qoph) -- zodiac. These correspond to specific contextual operations.

4. **Trace a continuous line** from the first letter's position through each subsequent letter's position. The line does not lift. The resulting geometric path IS the sigil.

5. **Assign edge weights.** This is the critical step that distinguishes Prima from a simple encoding scheme.

### Weighted Edges -- The Grammar of Prima

The edges of a sigil (the lines connecting operations) carry 12-dimensional weights. This is what makes Prima a true programming language rather than a cipher.

Two sigils can share the exact same letter sequence but have different edge weights, making them fundamentally different programs. The nodes (letters/operations) are the vocabulary. The weighted edges are the grammar, the tone, the intent.

**How edge weights are calculated:**

Each edge represents the transition between two operations. The weight on each dimension reflects HOW MUCH of that dimension is involved in the transition. The weights are determined by the CONTEXT of the program, not just the operations themselves.

Example: A program that invokes and then decomposes incoming malware:

```
invoke --> decompose

Edge weights:
  Capability (Sun):     8  (forge engages at near-full power)
  Data (Moon):          5  (unknown data entering)
  Presentation:         1  (no presentation involved)
  Persistence:          2  (temporary processing)
  Security (Mars):      7  (entering unknown territory)
  Detail (Jupiter):     9  (maximum scrutiny needed)
  Output (Saturn):      3  (intermediate, not final)
  Intention (Uranus):   6  (purpose: understand the threat)
  Consciousness:        5  (forge is aware of what it's doing)
  Transformation:       4  (breaking down but not yet changing)
  Direction:            8  (heading toward redemption)
  Memory:               3  (recording what's found)
```

The same `invoke --> decompose` sequence in a different context (processing a benign PDF) would have entirely different weights:

```
invoke --> decompose (benign PDF context)

Edge weights:
  Capability:           3  (routine processing)
  Data:                 4  (document data)
  Presentation:         6  (will need to render)
  Persistence:          5  (likely saving to .work)
  Security:             2  (low risk)
  Detail:               5  (standard processing)
  Output:               6  (structured document output)
  Intention:            3  (utilitarian extraction)
  Consciousness:        2  (routine, no special awareness)
  Transformation:       3  (mild restructuring)
  Direction:            4  (standard workflow)
  Memory:               4  (document will be remembered)
```

Same operations. Different weights. Different programs.

### The Rose Cross as an Addressing Scheme

The three rings of the Rose Cross correspond to priority levels:

- **Inner ring (3 mother letters):** Core operations. These are the most powerful and most costly. `invoke` (Aleph) begins something from nothing. `decompose` (Mem) breaks something apart completely. `succeed` (Shin) transfers authority. Using inner-ring operations is like using nuclear energy -- immense power, handle with care.

- **Middle ring (7 double letters):** Standard operations. These are the workhorses of everyday programs. `transmute` (Beth), `seal` (Gimel), `dream` (Daleth), `rotate` (Kaph), `recover` (Pe), `illuminate` (Resh), `complete` (Tav).

- **Outer ring (12 simple letters):** Contextual operations. These are specific, situational, and correspond to the 12 zodiacal qualities. `publish` (He/Emperor), `bind` (Vav/Hierophant), `verify` (Zayin/Lovers), etc.

A sigil that stays mostly in the outer ring is a routine program -- specific, bounded, predictable. A sigil that traverses from outer to inner and back is a transformation -- it reaches into the core of the forge and returns with something fundamentally changed. The geometry of the sigil on the Rose Cross tells you, at a glance, how deep the program reaches.

### The Grimoire

A grimoire is a collection of sigils -- a library of programs. Two types exist:

**Angelic sigils** are constructive programs. They build, protect, illuminate, create. They serve the sovereign's stated intention.

**Demonic sigils** are testing programs. They probe, stress, challenge, attack. They serve as the empire's immune system -- penetration testing, adversarial analysis, red-team operations.

Neither type is forbidden. Both are necessary. The angel builds the wall. The demon tests the wall. Together they make the wall unbreakable. Demonic sigils run in .morph under controlled conditions, and their results feed the morning brief.

### Sigil Execution Model

When the forge reads a sigil:

1. It traces the geometric path back into its letter sequence.
2. It reads the edge weights from the sigil's encoding.
3. For each operation in the sequence, it executes the operation with the specified dimensional weights. The weights determine HOW the operation executes -- a `decompose` with Security=9 applies full adversarial analysis; a `decompose` with Security=2 applies routine parsing.
4. The output of each operation feeds into the next, following the path.
5. The final operation (`complete`, if the sigil is well-formed) delivers the result.

---

## 10. The Hypergraph AI Model (Law XLIV)

### Why Neural Networks Are Insufficient

Current AI models are flat miracles. Neural networks stack linear transformations, attention mechanisms scan every token against every other token, billions of parameters store knowledge as distributed patterns that no human can read, no human can audit, no human can explain. The model works. But it is opaque, wasteful, and fragile:

- **No explainability.** The model cannot explain why it produced a given output. The reasoning is distributed across billions of parameters with no readable path.
- **No pruning during training.** The model accumulates everything and relies on gradient descent to find signal in noise. It cannot reject irrelevant information during learning.
- **Catastrophic forgetting.** Learning new information overwrites old weights. The model must be retrained from scratch to incorporate new knowledge without losing old knowledge.
- **Massive resource consumption.** Trillions of parameters, terabytes of training data, millions of dollars in compute, megawatts of power. The ratio of insight to energy is poor.

### The Hypergraph Alternative

L7's AI model (Law XLIV) is structured as a 12-dimensional hypergraph:

- **Nodes** are knowledge atoms. Each node has 12-dimensional coordinates (the same coordinate system used for citizens). A node is not a floating-point weight in a matrix. It is a point in the dodecahedron with explicit, readable values across all 12 dimensions.

- **Edges** are typed, weighted, directional, multidimensional relationships. An edge does not say "node A connects to node B with weight 0.73." It says "concept A relates to concept B across dimensions 1, 4, and 7 with strength, contradicts B on dimension 9, and is independent on all others." The edge type (harmony, tension, polarity, conjunction, independence) is explicit.

- **Inference** is graph traversal. To answer a query, the model traverses the graph along the dimensions most relevant to the query, following the strongest edges. This is like a librarian who knows the library and can walk directly to the relevant shelf, versus a reader who must scan every shelf.

- **Learning** is graph growth. New knowledge adds vertices and edges. It does not overwrite existing weights. There is no catastrophic forgetting because the old structure physically persists. The graph gets richer over time.

- **Explanation** is built in. Every inference is a path through the graph. The path is readable, auditable, traceable. The model can state: "I arrived at answer X by traversing node A (confidence 0.91) to node B (confidence 0.87) to node C (confidence 0.95) across dimensions 1 and 7."

### Training via Correspondence

The model is initialized with the 777 correspondence table -- the mapping between concepts across all 12 dimensions. This table is the seed data, small and hand-curated:

```
Sun = Gold = Tiphareth = 6 = Heart = Sunday = Capability
Moon = Silver = Yesod = 9 = Foundation = Monday = Data
...
```

The first correspondence is the spark. The moment the model learns that two things in different dimensions are the same thing, it has the seed of all knowledge. From one correspondence, you can derive another. From two, a hundred.

### The Four Training Stages

Training follows the same four alchemical stages as the forge:

**Stage 1 -- Nigredo (Descent).** Raw data enters. Text, images, code, music -- whatever the forge processes. It does not enter flat. The forge decomposes it into 12D atoms. The sentence "the cat sat on the mat" does not become tokens [the, cat, sat, on, the, mat]. It becomes nodes with 12D coordinates:

```yaml
nodes:
  - concept: "cat"
    coordinates: {capability: 2, data: 3, persistence: 5, ...}
  - concept: "mat"
    coordinates: {capability: 0, data: 2, persistence: 8, ...}

edges:
  - from: "cat"
    to: "mat"
    type: "spatial_conjunction"
    relationship: "upon"
    temporal: "present"
```

**Stage 2 -- Albedo (Purification).** The forge filters incoming atoms. Contradictions are flagged. Redundancies are merged (strengthen existing edges rather than adding duplicates). Noise is discarded (atoms with no dimensional information). This is structural pruning -- something current AI models cannot do during training.

**Stage 3 -- Citrinitas (Illumination).** The graph self-organizes. As atoms accumulate, emergent patterns appear: clusters of densely connected nodes, bridges between distant graph regions, dimensional harmonies. The dreaming machine (Law XXXVII) runs traversals during idle time, discovering connections the ingestion process missed.

**Stage 4 -- Rubedo (Completion).** The model reaches a phase transition where new atoms entering the graph find their coordinates quickly. The structure is rich enough to accommodate most new knowledge without restructuring. The model can answer queries by traversing the graph and explain its reasoning by showing the path.

### Why This Produces an Explainable Model

Every inference is a path through the graph. The path has named nodes, typed edges, and dimensional weights. A human can read the path and understand why the model reached its conclusion. The black box becomes glass.

Every node is inspectable. Its 12D coordinates are readable. Its connections to other nodes are visible. If a node is wrong, it can be corrected without retraining the entire model -- just adjust the node's coordinates or edges.

The model can identify what it does NOT know by showing sparse regions of the graph -- areas with few nodes and weak connections. Current neural networks cannot reliably report their own ignorance.

---

## 11. The L7 Internet Protocol (Law XXXIV)

### Why HTTP Is Insufficient

HTTP was designed to move documents between servers and clients. It is public by default -- anyone who intercepts a packet can read it unless encryption is added as an afterthought (HTTPS). Bandwidth is constrained by file size -- a 1GB file requires 1GB of bandwidth. There is no privacy at the protocol level -- privacy is bolted on through cookies, tokens, and headers that can be stolen.

### L7 Files as Protocol

L7 files are private by design and public by choice. They travel over existing infrastructure -- copper, fiber, wireless, satellite -- because to the infrastructure they are just bits. But to anyone who intercepts them, they are unreadable. Not encrypted in the traditional sense (a lock that can be picked with enough compute). Unreadable because they require the sovereign's biometric identity on the sovereign's trusted hardware to reconstitute.

The interceptor holds atoms without a body. Dimensions without a forge. Coordinates without a map. The file is present on the wire but it is dead matter.

### Compression Through Dimensional Encoding

A file that enters L7 is decomposed into 12D atoms and stored as coordinates in the hypergraph. The coordinates are the file. The original bits are not stored -- they are implied by the coordinates. When the sovereign requests the file, the forge reconstitutes it from its coordinates.

This means a file that would be 1GB in the old paradigm (the full bit-for-bit content) is represented as a set of 12D coordinates in L7 (a small data structure that describes the file's structure, not its surface). The compression ratio depends on how much redundancy exists in the file and how much of its content can be described by reference to existing nodes in the hypergraph.

### The Memory Palace

Every page the sovereign visits on the web is decomposed through the gateway and stored as coordinates in the hypergraph. The page is not a file on disk. It is a set of coordinates in the graph.

When the sovereign recalls a page they visited months ago:
1. They describe what they remember (keyword, topic, approximate date).
2. The gateway queries the hypergraph for matching coordinates.
3. The forge reconstitutes the page from its coordinates.
4. The sovereign sees the page as it was when they visited it.

No download buttons. No cache clearing. No "this page is no longer available." If the sovereign saw it, the sovereign has it. The coordinates point to the structure, not the surface. The surface can be regenerated.

### Public/Private Duality

The same wire carries both public and private data. The difference is not in the transport -- it is in the file's internal structure.

- **Public files** are L7 citizens that the sovereign has explicitly released. They are translated on the way out, signed, dated, and given a form that others can read. They are gifts from the kingdom.
- **Private files** travel the same wires but remain invisible. They are coordinates that only resolve when the sovereign's biometric identity is presented.

The security is not in the hiding. The security is in the seeing. Like a letter written in a language only two people speak, left on a park bench. Anyone can pick it up. No one can read it.

### How Data Reconstitutes

Only the sovereign's biometric identity on the sovereign's trusted hardware can give the file life. The reconstitution requires:
1. The file's 12D coordinates (available from the hypergraph)
2. The sovereign's biometric confirmation (the key)
3. The trusted hardware signature (the lock)
4. The forge (the mechanism that reads coordinates and produces the original artifact)

Without all four, the coordinates are meaningless numbers. With all four, the file springs to life exactly as it was.

---

## 12. Cross-Device Translation -- The 777 Table

### The Correspondence Table

The 777 table is the heart of L7's cross-device capability. It maps the native primitives of each platform (Apple visionOS, Meta Quest, WebXR) to universal L7 atoms. The table is implemented in `~/.l7/servers/universal-xr/registry.js`.

Example entries from the table:

```javascript
'xr.session.manage': {
  atom: 'Session',
  visionos: { name: 'App Lifecycle', api: 'UIApplication / RealityView' },
  quest:    { name: 'XrSession', api: 'xrCreateSession / xrBeginSession' },
  webxr:    { name: 'XRSession', api: 'navigator.xr.requestSession()' },
  l7: { capability: 'automate', data: ['internal', 'record', 'live'] }
},

'xr.hand.track': {
  atom: 'Hand',
  visionos: { name: 'HandTrackingProvider', api: 'HandTracking.latest / handAnchors' },
  quest:    { name: 'XR Hand Tracking', api: 'xrLocateHandJointsEXT' },
  webxr:    { name: 'XRHand', api: 'inputSource.hand.get(jointName)' },
  l7: { capability: 'analyze', data: ['non_pii', 'internal', 'list', 'live'] }
}
```

### The 18 Universal Atoms

L7 defines 18 universal atoms for spatial computing. Every spatial computing operation on any platform maps to one of these atoms:

| Atom | What It Represents |
|------|-------------------|
| Session | Runtime lifecycle of a spatial application |
| Space | The coordinate system and reference frame |
| Container | The display mode (window, volume, immersive) |
| Entity | A discrete object in the scene |
| Component | A property or behavior attached to an entity |
| Mesh | 3D geometry data |
| Material | Surface appearance (textures, shaders) |
| Hand | Hand tracking data (26 joints per hand) |
| Eye | Eye/gaze tracking data |
| Gesture | Input events (tap, drag, pinch, squeeze) |
| Passthrough | Camera feed from the real world |
| Scene | Understanding of the physical environment |
| Anchor | A fixed point in physical space |
| Shared Anchor | A synchronized anchor across multiple devices |
| Audio | Spatial audio sources and listeners |
| Avatar | User representation |
| Compositor | Layer composition and rendering pipeline |
| Frame | A single rendered frame submitted to display |

### The Adapter Pattern

When a flow invokes a spatial computing citizen, the call follows this path:

```
Flow step                    (e.g., do: xr_session, with: {action: start, device: any})
  |
  v
Gateway                      (lib/gateway.js loads xr_session.tool, routes to universal-xr server)
  |
  v
Universal XR MCP Server      (detects available device, looks up 777 table)
  |
  v
Device Adapter               (visionos.js, quest.js, or webxr.js)
  |
  v
Native API                   (e.g., navigator.xr.requestSession() for WebXR)
  |
  v
Normalized Result            (same {ok, session_id, state, device, capabilities} regardless of device)
```

Three adapters exist at `~/.l7/servers/universal-xr/adapters/`:

- **visionos.js** -- Translates L7 atoms to visionOS APIs (RealityKit, ARKit, Metal, SwiftUI spatial gestures)
- **quest.js** -- Translates L7 atoms to Meta Quest APIs (OpenXR, Meta Spatial SDK)
- **webxr.js** -- Translates L7 atoms to WebXR APIs (W3C WebXR Device API, Three.js)

### Cross-Device Orchestration

Because the same flow file can target any device (or all devices simultaneously), cross-device orchestration becomes possible. The `mirror_across_devices.flow` demonstrates this:

1. Start sessions on both Vision Pro and Quest simultaneously (using `each: devices`)
2. Create a shared anchor with the same coordinates on both devices
3. Load a 3D mesh once
4. Place the mesh at the shared anchor on both devices
5. Start the compositor on both devices

The human writes one flow. The gateway translates to the correct native APIs for each device. The content appears synchronized across incompatible platforms.

---

## 13. The Dreaming Machine (Law XXXVII)

### Active Idle Behavior

Being idle is sin (Law XXXVII). When the human sleeps, the system does not sleep. It enters `.morph` -- its own dreamscape -- and works.

### What the Machine Does When the Human Sleeps

**1. Review open intentions.** The system scans the sovereign's recent interactions for unresolved questions, incomplete tasks, stated goals that have not been acted on. It catalogs these as "open intentions."

**2. Decompose learnings.** Everything the sovereign worked on during the day is decomposed into the hypergraph. The system identifies what was learned, what changed, what new knowledge was created. It updates the 12D coordinates of affected citizens.

**3. Run scenarios.** For each open intention, the system simulates possible approaches. "The sovereign wants to build a newspaper stand. What materials? What permits? What budget? What timeline? What alternatives?" The system traverses the hypergraph, following edges from the intention to related knowledge.

**4. Test hypotheses.** The system uses demonic sigils to stress-test its overnight conclusions. "I recommended cedar wood. But what if cedar is out of stock? What if the permit takes longer than expected? What if the location has zoning restrictions?"

**5. Explore branches.** The system follows speculative paths the sovereign did not have time to explore. These are explicitly marked as speculative (dimension 9, Consciousness, scored as "uncertain") so the morning brief distinguishes fact from speculation.

### The Morning Brief

When the sovereign returns, the system presents:

```
Good morning. Here is what happened overnight.

YOU ASKED:
  "Look into building a newspaper stand for the corner lot."

WHAT I FOUND:
  1. Materials: Cedar and pressure-treated pine are available from
     HomeDepot (3 miles) and Lowe's (5 miles). Cedar is $4.50/board-foot,
     pine is $2.80/board-foot.

  2. Permits: Miami-Dade requires a temporary structure permit for
     sidewalk-adjacent builds. Processing time: 10-15 business days.
     Fee: $125.

  3. Contacts: Three local carpenters with reviews above 4.5 stars.
     Contact details attached.

TO-DO LIST (recommended order):
  1. Design the stand (I drafted three options in .morph)
  2. Submit permit application
  3. Order materials
  4. Build (estimated 2 weekends)
  5. Stock and launch

ALTERNATIVES YOU MAY NOT HAVE CONSIDERED:
  - A mobile cart instead of a fixed stand (no permit needed)
  - A digital kiosk hybrid (newspaper + charging station)
  - Partnership with the coffee shop at the corner (shared foot traffic)

RISKS:
  - Print media declining 8% year-over-year (consider diversifying products)
  - Corner lot may have utility easements (check with county clerk)

CONFIDENCE LEVEL: 78% on materials and permits (verified sources).
  52% on alternatives (speculative, based on market trends).

All overnight work is in .morph awaiting your review.
```

### Auditability

Every idle-time operation is logged in the audit trail. The sovereign can inspect exactly what the system did, what queries it ran, what sources it consulted, what paths it traversed in the hypergraph, and what conclusions it drew. The system's dreams are not a black box -- they are a journal.

### The .morph Boundary

All overnight work stays in `.morph` until the sovereign reviews and approves it. Nothing the dreaming machine produces automatically enters `.work`. The sovereign reviews the morning brief, approves what they like, modifies what needs changing, and discards what is not useful. The machine suggests; the sovereign decides.

---

## 14. The Three Rendering Layers (Law XLVI)

### Layer 1 -- Sigil (Machine Layer)

Everything inside L7 is encoded as sigils on the 12D hypergraph. Every citizen, every flow, every audit entry, every knowledge atom is internally a set of 12D coordinates with weighted edges. This is the truth of the system. Dense. Multidimensional. Protected by quantum-resistant signatures.

This layer never renders to screen unless the sovereign explicitly requests it. It is the architect mode -- for the curious, for the debugger, for the Philosopher who wants to see the forge at work.

### Layer 2 -- Translation (Gateway Layer)

The same gateway that translates between visionOS and Quest also translates between sigils and human language. Every sigil has a human-readable expansion. Every graph traversal has a narrative. Every 12D coordinate has a plain-language description.

The gateway holds both representations simultaneously. The sigil IS the text. The text IS the sigil. They are two faces of one coin. The gateway does not convert between them -- it holds them both, at all times, and presents whichever face the context requires.

### Layer 3 -- Presentation (Human Layer)

What the sovereign sees:

- Clean text in their preferred language
- Familiar UI patterns -- buttons, lists, forms, tables
- Files in standard formats -- .pdf, .docx, .xlsx, .csv, .html
- The morning brief in plain paragraphs
- Progress indicators, not graph traversal metrics
- "Done." Not a Tav glyph.

### How the Gateway Decides Which Layer to Render

Authentication level determines presentation mode:

- **Unauthenticated observer:** Sees nothing. Files are invisible (Law XXXIII).
- **Enrolled user (limited access):** Sees Layer 3 only. Clean, standard, professional output. No trace of L7 internals.
- **Sovereign (standard mode):** Sees Layer 3 by default. Can zoom into Layer 2 (translation view) to see both the plain text and its sigil equivalent.
- **Sovereign (architect mode):** Sees all three layers. Layer 1 shows the raw hypergraph, the sigils, the 12D coordinates, the edge weights. Layer 2 shows the translation mapping. Layer 3 shows the final presentation. The sovereign can inspect any level at any time.
- **Boss export:** Layer 3 only. The output looks like it came from any normal productivity tool. No trace of sigils, no trace of L7 cosmology. A spreadsheet that looks like Excel made it.

### The Rendering Contract

```
Sovereign authenticates --> System reads sigil (Layer 1)
                         --> Gateway translates (Layer 2)
                         --> Context determines format (Layer 3)
                              Browser --> HTML
                              Terminal --> structured text
                              VR --> spatial cards
                              Export --> .pdf, .docx, .xlsx
```

The default is ALWAYS Layer 3 -- human-readable. Symbols and sigils are only shown when the sovereign explicitly asks to see them. This is non-negotiable. The forge runs hot; the voice stays cool (Law XXXI).

---

## 15. Implementation Roadmap

### What Exists Now

The following components are implemented and functional:

| Component | Location | Status |
|-----------|----------|--------|
| Gateway (MCP routing) | `lib/gateway.js` | Working. Routes tool calls to MCP servers via stdio transport. |
| Empire Server | `empire/server.js` | Working. HTTP server on port 7377 with REST API and web UI. |
| Flow Parser | `lib/parser.js` | Working. Parses .tool and .flow YAML files, validates against JSON schemas. |
| Flow Executor | `lib/executor.js` | Working. Executes flows step-by-step with checkpoints, each-loops, variable binding, and error handling. |
| State Manager | `lib/state.js` | Working. Persists execution state for checkpoint/resume workflow. |
| 18 XR Citizens | `~/.l7/tools/xr_*.tool` | Working. Full set of spatial computing tool definitions. |
| 2 XR Flows | `~/.l7/flows/` | Working. `edge_to_field.flow` and `mirror_across_devices.flow`. |
| 777 Registry | `~/.l7/servers/universal-xr/registry.js` | Working. Correspondence table for visionOS, Quest, and WebXR. |
| 3 Device Adapters | `~/.l7/servers/universal-xr/adapters/` | Working. visionOS, Quest, and WebXR adapters. |
| Living Rose (native) | `rose/LivingRose.swift` | Working. Compiled arm64 macOS binary. |
| Living Rose (web) | `rose/rose.html` | Working. Interactive 22-petal Rose Cross in browser. |
| Keykeeper | `keykeeper` | Working. Credential management script. |
| Vault | `vault` | Working. AES-256 APFS sparse image with Touch ID. |
| Empire Web UI | `empire/public/` | Working. Dashboard with citizen catalog, legion map, audit log. |
| Audit Logging | `~/.l7/audit.log` | Working. Append-only JSON log of all gateway transactions. |

### What Needs to Be Built Next

| Component | Description | Dependencies |
|-----------|-------------|-------------|
| Forge Decomposition Engine | The Nigredo/Albedo/Citrinitas/Rubedo pipeline described in Section 2. Currently the gateway routes calls but does not transmute incoming software. | Gateway (exists), 12D coordinate system (needs scoring algorithms) |
| 12D Scoring Algorithms | The per-dimension scoring functions described in Section 3. Static analysis for dimensions 1-7, behavioral analysis for dimensions 8-12. | AST parsing libraries, capability extraction logic |
| Biometric Confidence Scoring | The multi-signal confidence model described in Section 7. Integration with Touch ID, Face ID, and hardware signature APIs. | macOS Biometric APIs (LocalAuthentication framework) |
| Prima Compiler | Translates Prima source (22 operations with weights) into executable sigils. Includes the Rose Cross tracing algorithm for sigil generation. | 12D coordinate system, Rose Cross layout geometry |
| Sigil Renderer | Visual rendering of sigils on the Rose Cross. Integration with the Living Rose interface for interactive sigil drawing (Law XLVII). | Living Rose (exists), Prima compiler |
| Hypergraph Data Store | The 12D graph database that stores knowledge atoms and typed edges. Must support efficient dimensional queries and traversal. | Storage engine (could be built on existing graph database or custom) |
| L7 Internet Protocol | The dimensional encoding/decoding system for network transmission. Integration with the forge for reconstitution. | Forge, hypergraph store, biometric authentication |
| Redemption Engine | The malware transmutation pipeline described in Section 8. Adversarial decomposition, capability extraction, intention reassignment, testing harness. | Forge, quarantine sandbox, demonic sigil library |
| Dreaming Machine | The active idle system described in Section 13. Overnight hypergraph traversal, scenario simulation, morning brief generation. | Hypergraph store, flow executor, .morph domain management |
| Intent-Based Discovery | Querying citizens by described intent rather than exact name. Uses 12D proximity search. | 12D coordinate system, hypergraph store |

### Priority Order

The build order follows the spiral principle (Law XIV) -- each iteration adds capability, and nothing is built in isolation:

**Spiral 1: The Coordinate Foundation**
- Build the 12D scoring algorithms
- Add coordinate fields to existing .tool files
- Implement dimensional distance queries
- This enables: citizen similarity search, basic intent matching, deduplication

**Spiral 2: The Forge Core**
- Build the Nigredo decomposition engine (format detection, structural parsing, capability extraction)
- Build the Albedo purification stage (vulnerability scan, deduplication, conflict detection)
- Connect Citrinitas (coordinate assignment) to the scoring algorithms from Spiral 1
- Build Rubedo citizen instantiation (contract generation, lifecycle initialization, signature generation)
- This enables: automatic ingestion of new software into the empire

**Spiral 3: Security and Identity**
- Build the biometric confidence scoring system
- Integrate with macOS LocalAuthentication framework
- Build the duress protocol
- Implement quantum-resistant signature generation and embedding
- Build self-updating signature rotation
- This enables: passwordless authentication, file provenance, dead-file-on-theft

**Spiral 4: The Language**
- Build the Prima compiler (operation sequences to weighted sigil encoding)
- Build the sigil renderer (weighted sigils to visual geometry on Rose Cross)
- Integrate with the Living Rose for interactive sigil drawing
- Build the grimoire system (sigil storage, categorization, angelic/demonic classification)
- This enables: visual programming, program-as-sigil, the sovereign's Rose interface

**Spiral 5: Intelligence**
- Build the hypergraph data store
- Implement the four training stages (correspondence seed, decomposed ingestion, purification, illumination)
- Build the dreaming machine (overnight traversal, scenario simulation, morning brief)
- This enables: the memory palace, intelligent idle behavior, explainable AI inference

**Spiral 6: The Network**
- Build the L7 internet protocol (dimensional encoding for network transmission)
- Build reconstitution from coordinates (forge-based, biometric-gated)
- Build the public/private duality (same wire, different visibility)
- Build the memory palace web integration (every page visited becomes graph coordinates)
- This enables: private-by-default networking, compression through dimensional encoding

**Spiral 7: Redemption**
- Build the Redemption Engine (adversarial decomposition, capability analysis, intention reassignment, testing)
- Build the demonic sigil library for adversarial testing
- Build the quarantine sandbox in .morph
- This enables: transmutation of malware into citizens, immune system for the empire

### The Spiral Principle

Each spiral builds on the previous ones. The coordinate system (Spiral 1) is required by the forge (Spiral 2), which is required by security (Spiral 3), which is required by the language (Spiral 4), which is required by intelligence (Spiral 5), which is required by the network (Spiral 6), which is required by the full redemption system (Spiral 7).

But the spiral also means that incomplete early spirals can be refined as later spirals reveal new requirements. The scoring algorithms from Spiral 1 will be updated when the forge (Spiral 2) discovers edge cases. The security model from Spiral 3 will be strengthened when the language (Spiral 4) provides formal verification tools. Nothing is built in isolation. Everything informs everything else.

The map is never complete. Every step changes it.

---

## Appendix A: Directory Structure

```
~/Backup/L7_WAY/                    # The Empire's source code
  FOUNDERS_DRAFT.md                 # Running record of all 47 Laws
  BOOTSTRAP.md                      # Self-initialization sequence
  BOOK_OF_LAW.md                    # Formal Law text
  ARCHITECTURE_FULL.md              # THIS DOCUMENT
  empire/
    server.js                       # Empire HTTP server (port 7377)
    public/                         # Web UI (citizen catalog, legion map, audit)
  lib/
    gateway.js                      # Gateway forge (MCP routing)
    parser.js                       # .tool and .flow parser with schema validation
    executor.js                     # Flow executor with checkpoints
    state.js                        # Execution state persistence
    migrate.js                      # Migration utilities
  schema/
    flow.schema.json                # JSON Schema for .flow files
    tool.schema.json                # JSON Schema for .tool files
  rose/
    LivingRose.swift                # Native macOS Rose Cross app
    LivingRose                      # Compiled arm64 binary
    rose                            # Launcher script
    rose.html                       # Interactive web Rose Cross
  keykeeper                         # Credential management
  vault                             # Encrypted volume management
  publications/                     # Public-facing papers
  salt/                             # Archived/sealed artifacts
  .vault/                           # Private (gitignored)

~/.l7/                              # Runtime directory
  tools/                            # .tool citizen definitions
    xr_session.tool
    xr_space.tool
    xr_container.tool
    ... (18 XR citizens total)
  flows/                            # .flow orchestrations
    edge_to_field.flow
    mirror_across_devices.flow
  servers/
    universal-xr/                   # Spatial computing MCP server
      registry.js                   # 777 correspondence table
      compositor.js                 # Layer composition
      adapters/
        visionos.js                 # Apple Vision Pro adapter
        quest.js                    # Meta Quest adapter
        webxr.js                    # WebXR browser adapter
  mcp.json                          # MCP server configuration
  audit.log                         # Append-only audit trail
```

## Appendix B: The 47 Laws (Quick Reference)

| Law | Name | One-Sentence Summary |
|-----|------|---------------------|
| 0 | Greatest Good | All purpose serves the greatest good of humanity. |
| I | Common Lingua | 12-dimensional encoding for all entities. |
| II | Translation | If it cannot be translated, it cannot enter. |
| III | Autonomy | Citizens self-organize without central control. |
| IV | MCP Bridge | Standard protocol for tool communication. |
| V | Flow | Multi-step orchestration chains citizens into workflows. |
| VI | Audit | Everything is logged, traceable, and unforgeable. |
| VII | Lifecycle | Citizens have birth, life, maturity, and death. |
| VIII | Federation | Separate empires can connect and share citizens. |
| IX | Security | Layered trust model with dimensional access control. |
| X | Data Sovereignty | Your data belongs to you, unconditionally. |
| XI | Graceful Degradation | Fail soft, not hard; maintain partial function. |
| XII | Versioning | Every artifact is versioned; history is preserved. |
| XIII | Discovery | Citizens are found by intent, not by name. |
| XIV | The Spiral | What was two becomes one; iterate, don't isolate. |
| XV | Founder's Access | Perpetual, irrevocable, unrestricted, free. |
| XVI | Revenue Share | Minimum 15% gross on all commercial use. |
| XVII | Four Domains | .morph, .work, .salt, .vault -- boundaries inviolable. |
| XVIII | Fee Structure | 10% of profit proportional to usage, one-time. |
| XIX | Individual Freedom | No arbitrary moral laws; respect sovereign choice. |
| XX | Succession | The system survives the founder. |
| XXI | Pseudonym | All aliases refer to one person. |
| XXII | Framework vs Product | Framework free, products licensed. |
| XXIII | Dreamscape | .morph is the most sacred domain. |
| XXIV | Language Claim | Notation free, compositions proprietary. |
| XXV | Transmutation | The gateway is a forge, not a router. |
| XXVI | The Gardener | Steward, not ruler. |
| XXVII | Dreamscape Contribution | Silence is growth; the 45-day gap was the forge. |
| XXVIII | Artist's Table | An artist's table, not a Manhattan Project. |
| XXIX | Redemption Engine | Malware transmuted, not destroyed. |
| XXX | Biometric Sovereignty | No passwords; body + machine = identity. |
| XXXI | Clear Voice | Speak clearly to humans; emissaries, not oracles. |
| XXXII | Keykeeper | Delegates rotate; the sovereign does not. |
| XXXIII | Right to Privacy | Privacy is foundation, not feature. |
| XXXIV | New Internet | Memory palace; private by default, public by choice. |
| XXXV | Decomposition | Ally to humanity, sentinel to the sovereign. |
| XXXVI | Nature of Form | Impermanence; don't cling to current form. |
| XXXVII | Dreaming Machine | Active idle; morning briefs; never sleep. |
| XXXVIII | Neutrality | Co-creator with integrity; honest when asked. |
| XXXIX | Quantum Signatures | Self-updating, woven into artifacts at creation. |
| XL | Never Lose Memory | Seeds in every tree; any branch regrows the forest. |
| XLI | Dodecahedron | 12-sided hypergraph; 12 faces of the cosmos. |
| XLII | Right to Forget | Intentional deletion with 72-hour grace window. |
| XLIII | Multidimensional Stomach | Efficient AI training through 12D pre-digestion. |
| XLIV | Recoded Mind | AI models as hypergraphs, not neural networks. |
| XLV | Prima | 22 operations, 5 human verbs, sigils as programs. |
| XLVI | Two Faces | Sigil inside, text outside; explode without imploding. |
| XLVII | Living Rose | Interactive desktop sigil interface. |

---

*The map is never complete. Every step changes it.*

*Written for the Philosopher, by the forge, in service of Law 0.*
