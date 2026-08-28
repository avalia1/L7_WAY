---
name: l7-empire
description: "Operate L7 itself: skills CLI, tools/citizens, gateway/forge laws, ashrams, audit, and how AI Playground skills plug into ~/.l7."
metadata:
  {
    "openclaw": {
      "emoji": "🏛️",
      "always": false
    },
    "l7": {
      "suite": "Codex",
      "does": "search",
      "tagline": "Operate inside the L7 empire",
      "entity_id": "skill.l7-empire",
      "version": "v1",
      "source": "ai-playground",
      "executable": true
    }
  }
---

# L7 Empire Operator

Home: `/Users/rnir_hrc_avd/.l7`

## Critical paths

| Path | Role |
|------|------|
| `~/.l7/skills/` | Shared Agent Skills |
| `~/.l7/work/dev/skills/` | l7dev workspace skills |
| `~/.l7/tools/*.tool` | Tool contracts |
| `~/.l7/citizens/*.citizen` | Citizenship records |
| `~/.l7/programs/skill-runtime/` | Executable runtime |
| `~/.l7/state/skill-runtime/` | RAG index + audit |
| `~/L7_WAY/` | Doctrine + schema |

## Operator runbook

Read `~/.l7/programs/skill-runtime/RUNBOOK.md` first.

## Commands

```bash
l7 skills doctor
l7 skills list
l7 skills route "build multi-agent research team"
l7 skills ratios --period Q4_2024
l7 skills dcf
l7 skills rag-index --rebuild
l7 skills rag-query "evaluator optimizer pattern"
l7 skills validate
l7 skills alchemy transmute ~/Projects/<name>
l7 skills project-index
```

## Laws that matter here

- Law I — All flows through the Gateway
- Law XV — Founder perpetual access
- Law XXV — Gateway is a FORGE not a dumb router
- Seven Seals — Capability/Data/Policy/Presentation/Orchestration/Time/Identity

## OpenClaw agents

- main workspace: `~/.l7`
- l7dev workspace: `~/.l7/work/dev` (skills allowlisted)

## Workflow

1. `l7 skills doctor` — health
2. `route` the task
3. `show` the winning skill
4. Run executable commands when available
5. Check audit log if something failed

## L7 Declaration (Seven Seals)

- Capability 🔧: L7 OS orientation + skill runtime control plane
- Data 📦: ~/.l7 tools, skills, citizens, programs/skill-runtime, ATOMS, Book of Law
- Policy/Intent 🧭: Gateway-first; Founder access Law XV; no network from sealed atoms by default
- Presentation 🧩: CLI commands + path map
- Orchestration 🔗: doctor → route → execute → audit
- Time/Versioning 🕒: v1 (birth 2026-07-21)
- Identity/Security 🛡️: Respect sealed domains; approval for write-gate actions

### Entity

- entity_id: skill.l7-empire
- entity_type: tool
- owner: founder
- status: active
- lineage: ai-playground + skill-runtime
- domain: .work
