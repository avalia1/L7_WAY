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

## CLI (via l7)

```bash
l7 skills doctor
l7 skills list
l7 skills show rag-pipeline
l7 skills route "multi agent research team"
l7 skills validate
l7 skills ratios --period Q4_2024 --industry technology
l7 skills dcf --company Acme
l7 skills brand
l7 skills rag-index --rebuild
l7 skills rag-query "evaluator optimizer pattern"
```

Direct:

```bash
python3 ~/.l7/programs/skill-runtime/l7skills.py doctor
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
