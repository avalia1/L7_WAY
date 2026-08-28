---
name: openai-patterns
description: "Implement common OpenAI API patterns from the local openai-cookbook: embeddings, agents SDK, codex, deep research, guardrails, and structured workflows."
metadata:
  {
    "openclaw": {
      "emoji": "📗",
      "always": false
    },
    "l7": {
      "suite": "Herald",
      "does": "analyze",
      "tagline": "OpenAI cookbook recipes",
      "entity_id": "skill.openai-patterns",
      "version": "v1",
      "source": "ai-playground"
    }
  }
---

# OpenAI Patterns

Root: `/Users/rnir_hrc_avd/Documents/Obsidian Vault/00 AI Playground/openai-cookbook`

## High-signal example areas

- embeddings / clustering / code search
- `agents_sdk/`, `agentkit/`
- `codex/`, `deep_research_api/`
- guardrails: `Developing_hallucination_guardrails.ipynb`
- Assistants / realtime / batch processing notebooks

## Workflow

1. Search `examples/` for the closest recipe.
2. Copy pattern; swap models carefully.
3. Add evaluation (LLM-as-judge notebooks exist).
4. For agents, prefer Agents SDK examples over legacy Assistants when possible.

## L7 Declaration (Seven Seals)

- Capability 🔧: OpenAI API recipe library
- Data 📦: examples/ notebooks and apps
- Policy/Intent 🧭: Use env OPENAI_API_KEY; never commit keys
- Presentation 🧩: Notebook-driven examples
- Orchestration 🔗: Pick recipe → adapt → evaluate
- Time/Versioning 🕒: v1 (birth 2026-07-21)
- Identity/Security 🛡️: Guardrail notebooks for hallucination control

### Entity

- entity_id: skill.openai-patterns
- entity_type: tool
- owner: founder
- status: active
- lineage: ai-playground → openai-cookbook
- domain: .work
