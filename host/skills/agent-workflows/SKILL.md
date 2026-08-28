---
name: agent-workflows
description: "Implement Claude agent workflow patterns: basic prompt chains, evaluator-optimizer loops, and orchestrator-workers from the Anthropic cookbook."
metadata:
  {
    "openclaw": {
      "emoji": "🔁",
      "always": false
    },
    "l7": {
      "suite": "Herald",
      "does": "automate",
      "tagline": "Claude agent workflow patterns",
      "entity_id": "skill.agent-workflows",
      "version": "v1",
      "source": "ai-playground"
    }
  }
---

# Agent Workflows (Anthropic patterns)

Source: `/Users/rnir_hrc_avd/Documents/Obsidian Vault/00 AI Playground/anthropic-cookbook/patterns/agents`

## Patterns

### 1. Basic workflows
- Sequential prompt chaining
- Branching by intermediate results
- File: `basic_workflows.ipynb`

### 2. Evaluator–optimizer
- Generator produces candidate
- Evaluator scores / critiques
- Loop until threshold or max iters
- File: `evaluator_optimizer.ipynb`

### 3. Orchestrator–workers
- Orchestrator decomposes task
- Workers execute subtasks in parallel or sequence
- Synthesize final answer
- File: `orchestrator_workers.ipynb`

## Workflow

1. Classify task complexity.
2. Pick the simplest pattern that fits.
3. Open the matching notebook; adapt cells, do not rewrite from scratch.
4. Keep prompts in `patterns/agents/prompts` style — short, role-clear.
5. Add evaluation criteria before adding more agents.

## Rules

- Prefer one agent with tools over multi-agent when possible.
- Always define stop conditions for loops.
- Log intermediate scores for evaluator-optimizer.

## L7 Declaration (Seven Seals)

- Capability 🔧: Agent workflow patterns (prompt chaining, eval-optimize, orchestrate)
- Data 📦: Notebook patterns + util helpers under patterns/agents
- Policy/Intent 🧭: Start simple; escalate to multi-agent only when needed
- Presentation 🧩: Step diagrams + runnable notebook cells
- Orchestration 🔗: Basic → evaluator-optimizer → orchestrator-workers
- Time/Versioning 🕒: v1 (birth 2026-07-21)
- Identity/Security 🛡️: No secrets in prompts; API keys via env

### Entity

- entity_id: skill.agent-workflows
- entity_type: tool
- owner: founder
- status: active
- lineage: ai-playground → anthropic-cookbook
- domain: .work
