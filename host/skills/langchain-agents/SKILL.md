---
name: langchain-agents
description: "Build reliable agents and chains with LangChain: core LCEL, langchain v1 agents, partners, text splitters, and standard tests."
metadata:
  {
    "openclaw": {
      "emoji": "🦜",
      "always": false
    },
    "l7": {
      "suite": "Herald",
      "does": "automate",
      "tagline": "LangChain reliable agents",
      "entity_id": "skill.langchain-agents",
      "version": "v1",
      "source": "ai-playground"
    }
  }
---

# LangChain Agents

Root: `/Users/rnir_hrc_avd/Documents/Obsidian Vault/00 AI Playground/langchain`

## Key libs

- `libs/core` — LCEL runnables
- `libs/langchain` / `libs/langchain_v1` — agent abstractions
- `libs/partners` — model/provider integrations
- `libs/text-splitters` — chunking
- `libs/standard-tests` — conformance tests

## Workflow

1. Compose with LCEL (`|` pipes) for deterministic chains.
2. Use agent abstractions only when tool choice is dynamic.
3. Split documents via text-splitters before retrieval.
4. Prefer partner packages for provider-specific features.
5. Check standard-tests patterns for reliability.

## With local vectors

Pair with `vector-chroma` or `vector-qdrant` + retriever runnables.

## L7 Declaration (Seven Seals)

- Capability 🔧: LangChain agents, LCEL, partner integrations
- Data 📦: libs/core, langchain, langchain_v1, partners
- Policy/Intent 🧭: Use documented LCEL patterns; pin model names
- Presentation 🧩: Chain/graph code samples
- Orchestration 🔗: Runnable sequences + agent loops
- Time/Versioning 🕒: v1 (birth 2026-07-21)
- Identity/Security 🛡️: Env-based keys; no secrets in chains

### Entity

- entity_id: skill.langchain-agents
- entity_type: tool
- owner: founder
- status: active
- lineage: ai-playground → langchain
- domain: .work
