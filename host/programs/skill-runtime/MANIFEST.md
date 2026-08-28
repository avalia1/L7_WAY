# Skill Runtime Manifest (saved inventory)

**Date:** 2026-07-22

## Top-level

```
programs/skill-runtime/
  l7skills.py
  RUNBOOK.md
  ROADMAP.md
  README.md
  MANIFEST.md
  reports/FINDINGS_2026-07-22.md
  demos/MAGISTERIUM_BRIEF_2026-07-22.json
  runtime/          # loader, execute, validator, audit, corpus_config
  packages/
    financial/      # ratios, dcf, schemas, fixtures, load_statements
    brand/
    rag/            # simple_rag, eval_cases, corpus/real
  forge/
    skill_bridge.py
    forge_server.py
    TOOL_MAP.json
    test_forge.py
  scripts/e2e_offline.sh
  tests/test_runtime.py
```

## Related outside this tree

- `~/.l7/skills/` — 20 skills  
- `~/.l7/tools/*.tool` — contracts  
- `~/.l7/citizens/*` — several `serving` via forge  
- `~/.l7/state/skill-runtime/` — corpus.json, rag indexes, audits  
- `~/Backup/L7_WAY/lib/gateway.js` — forge-first execute  
- `~/Backup/L7_WAY/empire/server.js` — POST tool execute  
- `~/Backup/L7_WAY/AI_PLAYGROUND_SKILLS.md`  
