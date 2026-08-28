---
name: financial-analysis
description: "Run financial ratio analysis, brand-guideline application, and DCF/sensitivity modeling using Anthropic custom skill scripts and sample financial data."
metadata:
  {
    "openclaw": {
      "emoji": "📊",
      "always": false
    },
    "l7": {
      "suite": "Codex",
      "does": "analyze",
      "tagline": "Financial skill packages",
      "entity_id": "skill.financial-analysis",
      "version": "v1",
      "source": "ai-playground"
    }
  }
---

# Financial Analysis Skills

Root: `/Users/rnir_hrc_avd/Documents/Obsidian Vault/00 AI Playground/anthropic-cookbook/skills`

## Packages

### analyzing-financial-statements
- `calculate_ratios.py`, `interpret_ratios.py`
- Profitability, liquidity, leverage, efficiency, valuation

### applying-brand-guidelines
- `apply_brand.py`, `validate_brand.py`, `REFERENCE.md`

### creating-financial-models
- `dcf_model.py`, `sensitivity_analysis.py`

## Sample data

- `sample_data/financial_statements.csv`
- `sample_data/portfolio_holdings.json`
- `sample_data/budget_template.csv`
- `sample_data/quarterly_metrics.json`

## Workflow

1. Load statements (CSV/JSON).
2. Run calculator scripts from the skill folder.
3. Interpret vs industry norms.
4. Export structured summary; never invent missing line items.

## L7 Declaration (Seven Seals)

- Capability 🔧: Financial ratios, brand application, DCF models
- Data 📦: sample_data CSVs/JSON + custom skill scripts
- Policy/Intent 🧭: Validate inputs; flag missing line items
- Presentation 🧩: Tables + Excel-oriented outputs
- Orchestration 🔗: Load data → calculate → interpret → report
- Time/Versioning 🕒: v1 (birth 2026-07-21)
- Identity/Security 🛡️: Treat financials as sensitive; audit=true

### Entity

- entity_id: skill.financial-analysis
- entity_type: tool
- owner: founder
- status: active
- lineage: ai-playground → anthropic-cookbook
- domain: .work
