# Anthropic agent workflow patterns (local)

Source notebook root:

`~/Documents/Obsidian Vault/00 AI Playground/anthropic-cookbook/patterns/agents/`

## Pattern selection

| Pattern | File | Use when |
|---------|------|----------|
| Prompt chaining | `basic_workflows.ipynb` | Linear multi-step transform |
| Routing | `basic_workflows.ipynb` | Classify then branch |
| Parallelization | `basic_workflows.ipynb` | Independent subcalls to merge |
| Evaluator–optimizer | `evaluator_optimizer.ipynb` | Quality loop with critique |
| Orchestrator–workers | `orchestrator_workers.ipynb` | Dynamic decomposition + workers |

## Design rules (from Building Effective Agents)

1. Start with the simplest pattern that works.
2. Add evaluation criteria before adding agents.
3. Prefer tools on one agent over multi-agent chatter.
4. Always define stop conditions (max iters / score threshold).
5. Keep worker prompts narrow; keep orchestrator responsible for synthesis.

## Related L7 skills

- `tool-use-patterns` — tool schemas + memory tools
- `multiagent-autogen` — conversational multi-agent teams
- `rag-pipeline` — retrieval before generation
