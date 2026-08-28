# L7_WAY

**L7_WAY is the common language for MCP systems.**
It exists to bring order to tool chaos by enforcing a single, stable contract for discovery, selection, and execution of tools.

## Why L7_WAY
Tool ecosystems grow fast and fracture faster. L7_WAY stops divergence by requiring every tool, service, workflow, UI, or project to declare itself using the same seven dimensions. The gateway uses these declarations to route, validate, and evolve the system without breaking clients.

## Core Promise
- **Order without rigidity**: consistent structure, flexible tools.
- **Swappable by design**: replace tools without rewriting UI.
- **Gateway-first**: a universal entry point for all tools.

## Live gateway
`l7 gateway` means `npm start` / `node serve.js` on `127.0.0.1:18793` (`L7_PORT`). That is the only product HTTP listener in this repo. It is not the stale Swift binary (`archive/host/gateway-server.swift`, port 18789 / OpenClaw) and not `~/.l7/l7-gateway` (Mac egress valve; Phase 3).

**Founder Loop is not the gateway.** `start.sh` is a founder convenience wrapper, not the architecture.

| How to run | What it is |
|---|---|
| `npm start` or `./scripts/run-gateway.sh` | Node control plane only. No Tailscale, SSH, or workers. Health: `GET http://127.0.0.1:18793/health` |
| `./scripts/run-founder-loop.sh` | Operator plumbing: Tailscale Serve of `:18793`, SSH reverse tunnel + docker-bridge, Avli workers if `~/avli_cloud/workers/start.sh` exists, optional forge on `:7378` |
| `./start.sh` | Calls gateway, then founder-loop |
| `./scripts/founder-loop-smoke.sh` | Loop smoke (gateway tests stay in `test/server-v1.test.js` and `test/one-listener.test.js`) |

Env, if present, is loaded from an open vault mount and from `.env` / `.env.local`. Do not Tailscale-serve worker ports (`:18792`, `:18794`, `:18795`, `:18798`) or forge `:7378`. Do not start `~/avli_cloud/start.sh`.

## Required Reading (for every new project)
- `ARCHITECTURE.md`
- `BOOK_OF_LAW.md`
- `RAG_INTELLIGENCE.md`
- `L7_CONTRACTS.md`
- `TOOL_REGISTRY.md`
- `ENFORCEMENT.md`
- `schema/v1/common-lingua.schema.json`

## Codex Directive
For every new project or session, read this repo first. Do not bypass the gateway or skip L7 declarations.

## Files
- `ARCHITECTURE.md` — system articulation and rules.
- `BOOK_OF_LAW.md` — laws of the empire.
- `RAG_INTELLIGENCE.md` — gateway intelligence layer.
- `L7_CONTRACTS.md` — enforcement contracts.
- `TOOL_REGISTRY.md` — tool discovery rules.
- `ENFORCEMENT.md` — compliance requirements.
- `schema/v1/` — executable 7D contract. `L7_SCHEMA.json` is generated from `common-lingua.schema.json`.
- `ENTITY_REGISTRY.md` — required entity metadata and lifecycle.
- `REGISTRY_SCHEMA.json` — registry schema.
- `ENTITY_TEMPLATE.md` — entity declaration template.
- `PROJECT_LIFECYCLE.md` — life and decommission protocol.
- `HERO_JOURNEY.md` — narrative doctrine.
- `APPRENTICE_PROTOCOL.md` — onboarding doctrine.
- `L7_CLI_SPEC.md` — CLI spec for legions.
- `daemon/` — enforcement script and install instructions.
