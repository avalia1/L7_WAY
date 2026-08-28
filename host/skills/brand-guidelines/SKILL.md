---
name: brand-guidelines
description: "Apply and inspect corporate brand guidelines (colors, fonts, Excel/PPT/PDF style configs) from the Anthropic brand skill via `l7 skills brand`."
metadata:
  {
    "openclaw": {
      "emoji": "🎨",
      "always": false
    },
    "l7": {
      "suite": "Flux",
      "does": "render",
      "tagline": "Corporate brand package",
      "entity_id": "skill.brand-guidelines",
      "version": "v1",
      "source": "ai-playground",
      "executable": true
    }
  }
---

# Brand Guidelines (executable)

## Command

```bash
l7 skills brand
```

Package: `/Users/rnir_hrc_avd/.l7/programs/skill-runtime/packages/brand/`
Reference: `/Users/rnir_hrc_avd/.l7/programs/skill-runtime/packages/brand/REFERENCE.md`

## Workflow

1. Inspect palette/fonts via CLI.
2. Pass style dicts into document generation.
3. Validate with validate_brand.py when producing final decks.

## L7 Declaration (Seven Seals)

- Capability 🔧: Brand tokens + document style configs
- Data 📦: BrandFormatter COLORS/FONTS/COMPANY + REFERENCE.md
- Policy/Intent 🧭: Do not claim real-world trademark ownership for sample Acme brand
- Presentation 🧩: Style dicts suitable for doc generators
- Orchestration 🔗: load brand → format target surface → validate
- Time/Versioning 🕒: v1 (birth 2026-07-21)
- Identity/Security 🛡️: Sample brand only; no network

### Entity

- entity_id: skill.brand-guidelines
- entity_type: tool
- owner: founder
- status: active
- lineage: ai-playground + skill-runtime
- domain: .work
