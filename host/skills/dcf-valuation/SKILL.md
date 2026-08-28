---
name: dcf-valuation
description: "Run a discounted cash flow valuation (WACC, projections, terminal value, equity value) via `l7 skills dcf` using the pure-Python DCF package."
metadata:
  {
    "openclaw": {
      "emoji": "🧮",
      "always": false
    },
    "l7": {
      "suite": "Codex",
      "does": "analyze",
      "tagline": "Executable DCF model",
      "entity_id": "skill.dcf-valuation",
      "version": "v1",
      "source": "ai-playground",
      "executable": true
    }
  }
---

# DCF Valuation (executable)

## Command

```bash
# Demo
l7 skills dcf --company Acme
# Real JSON
l7 skills dcf --data ~/.l7/programs/skill-runtime/packages/financial/fixtures/dcf_case_complete.json
```

Implementation: `/Users/rnir_hrc_avd/.l7/programs/skill-runtime/packages/financial/dcf_model.py` (numpy-free).

## Model steps

1. Historical financials (revenue, EBITDA, capex, NWC)
2. Assumptions (growth, margins, tax, terminal growth)
3. WACC via CAPM + after-tax cost of debt
4. Project FCF
5. Terminal value (Gordon growth or exit multiple)
6. Discount → enterprise value → equity / share

## Workflow

1. Run default sample to verify runtime.
2. Replace history/assumptions for real companies.
3. Stress WACC and terminal growth; report terminal_percent.
4. Never present point EV without assumptions list.

## L7 Declaration (Seven Seals)

- Capability 🔧: DCF enterprise + equity valuation
- Data 📦: Historical revenue/EBITDA/capex/NWC series; default sample history
- Policy/Intent 🧭: Surface assumptions; no silent defaults in narrative summaries
- Presentation 🧩: JSON valuation + text summary
- Orchestration 🔗: history → assumptions → WACC → project FCF → TV → EV/equity
- Time/Versioning 🕒: v1 (birth 2026-07-21)
- Identity/Security 🛡️: Model outputs are estimates; audit logged

### Entity

- entity_id: skill.dcf-valuation
- entity_type: tool
- owner: founder
- status: active
- lineage: ai-playground + skill-runtime
- domain: .work
