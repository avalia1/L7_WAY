# L7 Skills — Operator Runbook

**When in doubt:** `l7 skills doctor` then `l7 skills route "your task"`.

## Daily commands

| Need | Command |
|------|---------|
| Health | `l7 skills doctor` |
| Find skill | `l7 skills route "multi-agent research with RAG"` |
| Read skill | `l7 skills show financial-ratios` |
| Doctrine / L7 Q&A | `l7 skills rag-query "What is Law XV?" --profile real-corpus -k 5` |
| Rebuild doctrine index | `l7 skills rag-index --rebuild --profile real-corpus` |
| Golden RAG eval | `l7 skills rag-eval --profile real-corpus` |
| Finance **demo** (sample CSV) | `l7 skills ratios --period Q4_2024 --industry technology` |
| Finance **real** JSON | `l7 skills ratios --data ~/path/statements.json --industry technology` |
| DCF **demo** | `l7 skills dcf --company SampleCo` |
| DCF **real** JSON | `l7 skills dcf --data ~/path/dcf_case.json --company Acme` |
| Brand tokens | `l7 skills brand` |
| Full regression | `l7 skills e2e` |

Direct Python (same CLI):

```bash
python3 ~/.l7/programs/skill-runtime/l7skills.py doctor
```

## Founder prompts (start here)

1. `l7 skills rag-query "What is Law XV about founder access?" --profile real-corpus`
2. `l7 skills rag-query "what two factors are needed before the system allows a write" --profile real-corpus`
3. `l7 skills route "build a local RAG pipeline with chroma"`
4. `l7 skills ratios --data ~/.l7/programs/skill-runtime/packages/financial/fixtures/statements_complete.json`
5. `l7 skills doctor && l7 skills rag-eval --profile real-corpus`

## Real vs demo finance

| Mode | How | Trust |
|------|-----|--------|
| **Demo** | No `--data`, or CSV sample period | Illustrative; proxies labeled |
| **Real** | `--data path.json` matching schema | Fails if required fields missing |

Schema: `packages/financial/schemas/statements.v1.json`  
DCF case schema: `packages/financial/schemas/dcf_case.v1.json`  
Examples: `packages/financial/fixtures/`

## Corpus profiles

Config: `~/.l7/state/skill-runtime/corpus.json`

```bash
# list profiles (via doctor / file)
cat ~/.l7/state/skill-runtime/corpus.json

# index a profile (roots from config + optional --root)
l7 skills rag-index --rebuild --profile real-corpus
l7 skills rag-index --rebuild --profile founder-notes --root /path/to/notes
```

Do **not** point roots at empty folders or `.vault` / secrets.

## Forge (M2) — execute tools without hand CLI

```bash
# Start HTTP forge (port 7378)
l7 forge

# One-shot
l7 forge tools
l7 forge exec financial_ratios '{"period":"Q4_2024"}'
l7 forge exec rag_pipeline '{"action":"query","query":"Law XV","profile":"real-corpus","k":3}'

# HTTP
curl -s http://127.0.0.1:7378/health
curl -s http://127.0.0.1:7378/tools | head
curl -s -X POST http://127.0.0.1:7378/execute \
  -H 'Content-Type: application/json' \
  -d '{"tool":"financial_ratios","params":{"period":"Q4_2024"}}'
```

Empire (if running on 7377) uses the same gateway path:  
`POST /api/execute` with `{ "tool": "financial_ratios", "params": { ... } }`.

## Weekly gate

```bash
l7 skills e2e && l7 skills rag-eval --profile real-corpus
python3 ~/.l7/programs/skill-runtime/forge/test_forge.py
```

Expect: e2e ALL PASSED; rag strict high; forge tests OK (see ROADMAP metrics).

## When something breaks

1. `l7 skills doctor` — validation errors?  
2. `l7 skills validate` — skill/tool/citizen gaps?  
3. `tail -20 ~/.l7/state/skill-runtime/audit.jsonl`  
4. Unit: `python3 ~/.l7/programs/skill-runtime/tests/test_runtime.py`  

## Further development

See `ROADMAP.md` (M1 daily → M2 forge → M3 domain).

## Alchemy (Law XXV)

```bash
# Inventory all Projects
python3 l7skills.py project-index --root ~/Projects

# Full Great Work on a project (seals under state/alchemy)
python3 l7skills.py alchemy transmute ~/Projects/openclaw
python3 l7skills.py alchemy transmute ~/L7_WAY

# Single stages
python3 l7skills.py alchemy nigredo PATH
python3 l7skills.py alchemy albedo PATH
python3 l7skills.py alchemy citrinitas PATH
python3 l7skills.py alchemy rubedo PATH

# Via forge bridge
python3 forge/skill_bridge.py execute alchemy_transmute '{"path":"~/Projects/openclaw"}'
python3 forge/skill_bridge.py execute project_index '{"root":"'"$HOME"'/Projects","limit":40}'
```
