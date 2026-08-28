---
name: financial-ratios
description: "Calculate and interpret financial ratios from statement data or the playground CSV via `l7 skills ratios` (profitability, liquidity, leverage, efficiency, valuation)."
metadata:
  {
    "openclaw": {
      "emoji": "📈",
      "always": false
    },
    "l7": {
      "suite": "Codex",
      "does": "analyze",
      "tagline": "Executable financial ratios",
      "entity_id": "skill.financial-ratios",
      "version": "v1",
      "source": "ai-playground",
      "executable": true
    }
  }
---

# Financial Ratios (executable)

## Command

```bash
# Demo (sample CSV)
l7 skills ratios --period Q4_2024 --industry technology
# Real JSON (fails if incomplete)
l7 skills ratios --data ~/.l7/programs/skill-runtime/packages/financial/fixtures/statements_complete.json
```

Runtime: `/Users/rnir_hrc_avd/.l7/programs/skill-runtime/l7skills.py`
Package: `/Users/rnir_hrc_avd/.l7/programs/skill-runtime/packages/financial/`

## What it computes

- Profitability: ROE, ROA, gross/operating/net margins
- Liquidity: current, quick, cash
- Leverage: D/E, interest coverage, DSCR
- Efficiency: asset/inventory/receivables turnover, DSO
- Valuation: P/E, P/B, P/S, EV/EBITDA, PEG, EPS

## Data

Sample: `/Users/rnir_hrc_avd/.l7/programs/skill-runtime/packages/financial/data/financial_statements.csv`

CSV periods: Q1–Q4 2023/2024. Mapping is explicit in `csv_to_statements.py` — some balance-sheet detail is **proxied** (cash/AR/inventory shares of current assets). Call that out in analysis.

## Workflow

1. Choose period + industry benchmark set.
2. Run `l7 skills ratios`.
3. Read `result.summary` then category ratios.
4. Cross-check industry_benchmarks for flags.
5. For multi-period trend, re-run Q1..Q4 and compare ROE/margins.

## Result contract

Normalized L7 envelope: success/result/error/meta with audit append to `~/.l7/state/skill-runtime/audit.jsonl`.

## L7 Declaration (Seven Seals)

- Capability 🔧: Executable ratio calculator + industry benchmarks
- Data 📦: CSV/JSON financial statements; sample_data/financial_statements.csv
- Policy/Intent 🧭: Never invent missing line items; flag approximations from CSV mapping
- Presentation 🧩: JSON envelope with ratios, interpretations, summary
- Orchestration 🔗: load period → calculate → interpret → audit
- Time/Versioning 🕒: v1 (birth 2026-07-21)
- Identity/Security 🛡️: Financial data treated sensitive; audit=true

### Entity

- entity_id: skill.financial-ratios
- entity_type: tool
- owner: founder
- status: active
- lineage: ai-playground + skill-runtime
- domain: .work
