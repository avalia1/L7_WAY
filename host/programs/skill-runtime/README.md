# L7 Skill Runtime

Executable control plane for AI Playground skills installed into the L7 empire.

## Install location

```
~/.l7/programs/skill-runtime/
  l7skills.py              # CLI entry
  runtime/                 # loader, validator, execute, audit
  packages/
    financial/             # ratios, DCF, CSV adapter, sample data
    brand/                 # brand guidelines
    rag/                   # pure-Python TF-IDF RAG
  tests/
```

## Docs

- **[RUNBOOK.md](./RUNBOOK.md)** — daily operator commands  
- **[ROADMAP.md](./ROADMAP.md)** — phased development plan (M1 done)

## CLI (via l7)

```bash
l7 skills doctor
l7 skills route "multi agent research team"
# Finance: demo vs real JSON
l7 skills ratios --period Q4_2024
l7 skills ratios --data ~/.l7/programs/skill-runtime/packages/financial/fixtures/statements_complete.json
l7 skills dcf --company Acme
l7 skills dcf --data ~/.l7/programs/skill-runtime/packages/financial/fixtures/dcf_case_complete.json
l7 skills corpus
l7 skills rag-index --rebuild --profile real-corpus
l7 skills rag-query "What is Law XV?" --profile real-corpus
l7 skills e2e
# Forge (M2)
l7 forge exec financial_ratios '{"period":"Q4_2024"}'
l7 forge   # HTTP :7378  POST /execute
```

Direct:

```bash
python3 ~/.l7/programs/skill-runtime/l7skills.py doctor
python3 ~/.l7/programs/skill-runtime/forge/skill_bridge.py execute financial_ratios '{}'
```

## Result contract

Every executable path returns:

```json
{
  "success": true,
  "result": {},
  "error": "",
  "meta": {
    "execution_time_ms": 0,
    "timestamp": "ISO-8601",
    "entity_id": "skill.*",
    "tool": "..."
  }
}
```

## Audit

- `~/.l7/state/skill-runtime/audit.jsonl`
- mirrored lines in `~/.l7/audit.log`

## Tests

```bash
python3 ~/.l7/programs/skill-runtime/tests/test_runtime.py
```

## L7 Way compliance

| Layer | Location |
|-------|----------|
| Agent Skills | `~/.l7/skills/*/SKILL.md` |
| Tools | `~/.l7/tools/*.tool` |
| Citizens | `~/.l7/citizens/*.citizen` |
| Runtime | this directory |
| Doctrine registry | `~/Backup/L7_WAY/AI_PLAYGROUND_SKILLS.md` |

## Further development

See **[ROADMAP.md](./ROADMAP.md)** for the phased plan (daily use → forge integration → retrieval → domain skills → ops).
