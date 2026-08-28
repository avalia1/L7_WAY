---
name: prompt-engineering
description: "Apply prompt engineering techniques from the Prompt Engineering Guide: basic/advanced usage, reliability, adversarial robustness, and application patterns."
metadata:
  {
    "openclaw": {
      "emoji": "✍️",
      "always": false
    },
    "l7": {
      "suite": "Codex",
      "does": "analyze",
      "tagline": "Prompt Engineering Guide techniques",
      "entity_id": "skill.prompt-engineering",
      "version": "v1",
      "source": "ai-playground"
    }
  }
---

# Prompt Engineering

Root: `/Users/rnir_hrc_avd/Documents/Obsidian Vault/00 AI Playground/Prompt-Engineering-Guide`

## Core guides

- `guides/prompts-intro.md`
- `guides/prompts-basic-usage.md`
- `guides/prompts-advanced-usage.md`
- `guides/prompts-reliability.md`
- `guides/prompts-adversarial.md`
- `guides/prompts-applications.md`
- `guides/prompts-chatgpt.md`
- `guides/prompts-miscellaneous.md`

## Workflow

1. State the task + success criteria.
2. Start with basic usage patterns.
3. Add advanced techniques (CoT, few-shot, self-consistency) only if needed.
4. Hard-test with reliability + adversarial guides.
5. Save winning prompts as skill references, not one-offs.

## L7 Declaration (Seven Seals)

- Capability 🔧: Prompt design techniques and reliability patterns
- Data 📦: guides/*.md + pages mdx + notebooks
- Policy/Intent 🧭: Prefer tested techniques over clever hacks
- Presentation 🧩: Technique cards with examples
- Orchestration 🔗: Problem → technique → evaluate → harden
- Time/Versioning 🕒: v1 (birth 2026-07-21)
- Identity/Security 🛡️: Adversarial guides for injection resistance

### Entity

- entity_id: skill.prompt-engineering
- entity_type: tool
- owner: founder
- status: active
- lineage: ai-playground → Prompt-Engineering-Guide
- domain: .work
