---
name: multiagent-autogen
description: "Build multi-agent applications with Microsoft AutoGen: agentchat, core runtime, Magentic-One, extensions, and studio workflows."
metadata:
  {
    "openclaw": {
      "emoji": "👥",
      "always": false
    },
    "l7": {
      "suite": "Herald",
      "does": "automate",
      "tagline": "AutoGen multi-agent systems",
      "entity_id": "skill.multiagent-autogen",
      "version": "v1",
      "source": "ai-playground"
    }
  }
---

# Multi-Agent AutoGen

Root: `/Users/rnir_hrc_avd/Documents/Obsidian Vault/00 AI Playground/autogen`

## Key packages (Python)

- `python/packages/autogen-agentchat` — high-level multi-agent chat
- `python/packages/autogen-core` — runtime primitives
- `python/packages/autogen-ext` — model/tool extensions
- `python/packages/autogen-magentic-one` — Magentic-One team
- `python/packages/autogen-studio` — UI/studio
- `python/packages/magentic-one-cli` — CLI

## When to use

- Multiple specialized roles (researcher, coder, critic)
- Tool-using teams with human-in-the-loop
- Magentic-One style orchestrated problem solving

## Workflow

1. Define agent roles and system messages.
2. Choose team pattern (round-robin, selector, Magentic-One).
3. Attach tools/models via autogen-ext.
4. Set max turns / termination.
5. Review traces before productionizing.

## Contrast

- Prefer LangChain for single-agent LCEL graphs.
- Prefer AutoGen when agents must converse and hand off.

## L7 Declaration (Seven Seals)

- Capability 🔧: Multi-agent orchestration (AutoGen)
- Data 📦: autogen-agentchat/core/ext/magentic-one packages
- Policy/Intent 🧭: Define termination conditions; bound token spend
- Presentation 🧩: Agent roles + message flow
- Orchestration 🔗: Team chat / Magentic-One hierarchical
- Time/Versioning 🕒: v1 (birth 2026-07-21)
- Identity/Security 🛡️: Sandbox code-exec agents; approval for external actions

### Entity

- entity_id: skill.multiagent-autogen
- entity_type: tool
- owner: founder
- status: active
- lineage: ai-playground → autogen
- domain: .work
