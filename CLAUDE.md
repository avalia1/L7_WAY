# CLAUDE.md — L7_WAY

## What This Project Is

L7_WAY is the **universal operating system and common language for MCP (Model Context Protocol) systems**. It enforces a single, stable contract for discovery, selection, and execution of tools by requiring every tool, service, workflow, UI, or project to declare itself using the same seven dimensions (extended to 12). A universal gateway routes all tool access.

**Author**: AVLI Cloud LLC (Alberto Valido Delgado)

## Quick Reference

```bash
# Install dependencies
npm install

# Validate .flow/.tool/.l7 declarations
npm run validate

# Parse and output JSON from declarations
npm run parse

# List all registered tools and flows
npm run list

# Start Empire UI server (port 7377)
npm run empire

# Run tests
npm run test
```

There is no CI/CD pipeline. Validation and testing are manual.

## Repository Structure

```
lib/              # Core Node.js modules (gateway, parser, field physics, forge, etc.)
schema/           # JSON Schemas (tool.schema.json, flow.schema.json)
bin/              # Compiled binaries (Swift ARM64) and CLI entry point
empire/           # Empire UI server (Node.js HTTP on port 7377, HTML/JS frontend)
src/              # Swift source (gateway-server.swift)
dbexplorer/       # Database explorer tool (Swift)
rose/             # Living Rose interactive UI (Swift + HTML)
iconforge/        # Icon/wallpaper generation (Swift)
daemon/           # MCP gateway enforcer script
scripts/          # Installation and utility scripts
salt/             # Sealed archive domain (immutable, timestamped)
publications/     # Academic papers and manuscripts
origin/           # Genesis records (inception.l7)
```

### Key Files

| File | Purpose |
|------|---------|
| `L7_SCHEMA.json` | The 7D (extended to 12D) common lingua schema |
| `schema/tool.schema.json` | Tool declaration format |
| `schema/flow.schema.json` | Flow/workflow orchestration format |
| `ENTITY_REGISTRY.json` | Live entity registry |
| `REGISTRY_SCHEMA.json` | Entity registry validation schema |
| `ENTITY_TEMPLATE.md` | Template for declaring new entities |
| `BOOK_OF_LAW.md` | The Laws of the Empire (governance rules) |
| `ARCHITECTURE.md` | Core 7D system architecture |
| `ARCHITECTURE_FULL.md` | Expanded detailed architecture |
| `BOOTSTRAP.md` | Self-initialization sequence for AI systems |

## Tech Stack

- **JavaScript/Node.js** — Primary implementation (all `lib/` modules)
- **Swift** — Native macOS tools (gateway server, DB explorer, Living Rose, icon forge)
- **Python** — PDF generation utilities
- **Bash** — System scripts, wrappers, daemon
- **HTML/CSS/JS** — Empire UI, Studio, Infinite Viewer, Rose web interface

### Dependencies

- `@modelcontextprotocol/sdk` — MCP protocol implementation
- `ajv` — JSON schema validation
- `js-yaml` — YAML parsing

## Architecture & Core Concepts

### The Seven Laws (most critical)

1. **Law I — The Gateway**: All tool access flows through the universal gateway. Never bypass it.
2. **Law II — The Common Lingua**: Every entity declares itself using the 7D schema.
3. **Law III — The Lifecycle**: Entities follow: summoned → oath → formed → serving → mature → sunset → archived.

### Core Modules (`lib/`)

| Module | Responsibility |
|--------|---------------|
| `gateway.js` | Universal entry point for all tool access (Law I) |
| `parser.js` | YAML/L7 file parsing and validation |
| `heart.js` | Primordial field / system heartbeat |
| `field.js` | L7 Field Theory (information physics, gravity, waves) |
| `executor.js` | Flow execution engine |
| `forge.js` | Transmutation and composition logic |
| `dodecahedron.js` | 12D coordinate system |
| `hexagrams.js` | 64 hexagram (I Ching) decision system |
| `harmonics.js` | Wave/resonance propagation |
| `nerve.js` | Signal propagation (nervous system) |
| `autopoiesis.js` | Self-organizing system behavior |
| `domains.js` | Four filesystem domains (.morph, .work, .salt, .vault) |
| `state.js` | State management |
| `polarity.js` | Binary/opposing force modeling |
| `prima.js` | Prima language (22 Hebrew letters as operations) |
| `self.js` | Unified Self concept |
| `migrate.js` | Data migration |
| `watermark.js` | Content watermarking |

### Four Domains

- **`.morph`** — Mutable dream space (experimental, in-progress work)
- **`.work`** — Stable production (repeatable, shareable)
- **`.salt`** — Sealed archive (immutable, timestamped, never modified)
- **`.vault`** — Encrypted storage (biometric + intent verification)

### Gateway Result Format

All tool results are normalized to:
```json
{ "success": true, "result": {}, "error": null, "meta": {} }
```

## Code Conventions

### Naming

- **Files**: kebab-case or snake_case (`gateway.js`, `2026-01-12_inception.l7`)
- **Variables**: camelCase
- **Constants**: UPPER_SNAKE_CASE, wrapped in `Object.freeze()`
- **Entities**: snake_case identifiers with timestamps
- **Directories**: lowercase

### Patterns

- **Immutability**: Use `Object.freeze()` for constant objects
- **Law-based governance**: System behaviors tied to named Laws
- **Timestamp everything**: ISO-8601 dates and monotonic counters
- **Audit trails**: Log who, what, when for every action
- **Composability**: Small, reusable units; no monoliths
- **Adapter pattern**: UI never calls tools directly; adapters mediate

### Required Reading for New Work

Before creating new tools, entities, or modifying architecture, read:
1. `ARCHITECTURE.md`
2. `BOOK_OF_LAW.md`
3. `RAG_INTELLIGENCE.md`
4. `L7_CONTRACTS.md`
5. `TOOL_REGISTRY.md`
6. `ENFORCEMENT.md`
7. `L7_SCHEMA.json`

## Development Guidelines

### Adding a New Tool

1. Declare it using `schema/tool.schema.json` format
2. Register it in `ENTITY_REGISTRY.json`
3. Route it through the gateway (`lib/gateway.js`) — never bypass
4. Return normalized results: `{ success, result, error, meta }`
5. Follow entity lifecycle: summoned → oath → formed → serving

### Adding a New Flow

1. Declare using `schema/flow.schema.json` format
2. Define steps, rules, inputs, and conditional execution
3. Validate with `npm run validate`

### Modifying Core Modules

- All `lib/` modules are interconnected through the field/gateway system
- Changes to `gateway.js` affect all tool routing
- Changes to `parser.js` affect all declaration validation
- Test after changes: `npm run test`

## What NOT to Do

- **Never bypass the gateway** — all tool access goes through it (Law I)
- **Never modify `.salt/` files** — they are sealed, immutable archives
- **Never commit `.vault/` contents** — encrypted storage is excluded via `.gitignore`
- **Never skip L7 declarations** — every entity must declare its 7D coordinates
- **Never create monolithic components** — keep units small and composable
- **Never hardcode tool calls in UI** — use adapter pattern

## License

Custom commercial license. Free for non-commercial use; 10% one-time fee for commercial use. See `LICENSE` file.
