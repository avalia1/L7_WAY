# L7_WAY

**L7_WAY is the common language for MCP systems.**
It exists to bring order to tool chaos by enforcing a single, stable contract for discovery, selection, and execution of tools.

## Why L7_WAY
Tool ecosystems grow fast and fracture faster. L7_WAY stops divergence by requiring every tool, service, workflow, UI, or project to declare itself using the same seven dimensions. The gateway uses these declarations to route, validate, and evolve the system without breaking clients.

## Core Promise
- **Order without rigidity**: consistent structure, flexible tools.
- **Swappable by design**: replace tools without rewriting UI.
- **Gateway-first**: a universal entry point for all tools.

## Required Reading (for every new project)
- `ARCHITECTURE.md`
- `TOOL_REGISTRY.md`
- `ENFORCEMENT.md`
- `L7_SCHEMA.json`

## Codex Directive
For every new project or session, read this repo first. Do not bypass the gateway or skip L7 declarations.

## Files
- `ARCHITECTURE.md` — system articulation and rules.
- `TOOL_REGISTRY.md` — tool discovery rules.
- `ENFORCEMENT.md` — compliance requirements.
- `L7_SCHEMA.json` — finite L7 schema.
- `daemon/` — enforcement script and install instructions.
