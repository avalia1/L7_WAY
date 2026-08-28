---
name: autonomous-agents
description: "Design and run autonomous agent graphs with AutoGPT platform (blocks, workflows) and classic AutoGPT agent loops."
metadata:
  {
    "openclaw": {
      "emoji": "🤖",
      "always": false
    },
    "l7": {
      "suite": "Herald",
      "does": "automate",
      "tagline": "AutoGPT agent platform",
      "entity_id": "skill.autonomous-agents",
      "version": "v1",
      "source": "ai-playground"
    }
  }
---

# Autonomous Agents (AutoGPT)

Root: `/Users/rnir_hrc_avd/Documents/Obsidian Vault/00 AI Playground/AutoGPT`

## Layout

- `autogpt_platform/` — modern platform (blocks, backend, frontend)
- `classic/` — classic AutoGPT agent
- `docs/` — architecture & usage

## Workflow

1. Prefer platform graphs for repeatable workflows.
2. Use classic agent only for exploratory autonomy.
3. Enumerate tools/blocks before enabling autonomy.
4. Require approval gates for write/send/deploy actions.
5. Log every external action.

## L7 alignment

Map platform blocks to L7 tools (`does`, `needs`, `gives`, `approval`).

## L7 Declaration (Seven Seals)

- Capability 🔧: Autonomous agent platform / graph execution
- Data 📦: autogpt_platform + classic agent code
- Policy/Intent 🧭: Human approval for external side effects
- Presentation 🧩: Block/graph workflows
- Orchestration 🔗: Platform graph vs classic loop
- Time/Versioning 🕒: v1 (birth 2026-07-21)
- Identity/Security 🛡️: Credential isolation; audit actions

### Entity

- entity_id: skill.autonomous-agents
- entity_type: tool
- owner: founder
- status: active
- lineage: ai-playground → AutoGPT
- domain: .work
