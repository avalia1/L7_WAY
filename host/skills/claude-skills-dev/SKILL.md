---
name: claude-skills-dev
description: "Create and package Claude/OpenClaw Agent Skills (SKILL.md, progressive disclosure, scripts, references) using Anthropic skills cookbook patterns."
metadata:
  {
    "openclaw": {
      "emoji": "📦",
      "always": false
    },
    "l7": {
      "suite": "Codex",
      "does": "automate",
      "tagline": "Build Agent Skills the right way",
      "entity_id": "skill.claude-skills-dev",
      "version": "v1",
      "source": "ai-playground"
    }
  }
---

# Claude / Agent Skills Development

Source: `/Users/rnir_hrc_avd/Documents/Obsidian Vault/00 AI Playground/anthropic-cookbook/skills`

## Layout (Agent Skills open standard)

```
skill-name/
  SKILL.md          # required frontmatter + instructions
  scripts/          # optional deterministic code
  references/       # optional deep docs
  assets/           # optional templates/media
```

## Progressive disclosure

1. **Name + description only** at session start (cheap)
2. **Full SKILL.md** when triggered
3. **references/scripts** only when needed

## Cookbook notebooks

- `notebooks/01_skills_introduction.ipynb`
- `notebooks/02_skills_financial_applications.ipynb`
- `notebooks/03_skills_custom_development.ipynb`

## Example custom skills

- `custom_skills/analyzing-financial-statements/`
- `custom_skills/applying-brand-guidelines/`
- `custom_skills/creating-financial-models/`

## L7 Way extras

When shipping into L7, also declare:

- `.tool` file under `~/.l7/tools/`
- citizen JSON under `~/.l7/citizens/`
- Seven seals (Capability, Data, Policy, Presentation, Orchestration, Time, Identity)

## Workflow

1. Write short `description` with trigger nouns/verbs.
2. Keep body actionable (steps, not essays).
3. Move long material to `references/`.
4. Prefer CLI/scripts over prose for deterministic ops.
5. Validate frontmatter YAML.

## L7 Declaration (Seven Seals)

- Capability 🔧: Author SKILL.md packages with progressive disclosure
- Data 📦: skills notebooks + custom_skills examples
- Policy/Intent 🧭: Lean SKILL.md; long docs in references/
- Presentation 🧩: Skill folder layout + frontmatter
- Orchestration 🔗: Tier1 name/desc → Tier2 SKILL.md → Tier3 references/scripts
- Time/Versioning 🕒: v1 (birth 2026-07-21)
- Identity/Security 🛡️: No secrets in skills; scripts must be reviewable

### Entity

- entity_id: skill.claude-skills-dev
- entity_type: tool
- owner: founder
- status: active
- lineage: ai-playground → anthropic-cookbook
- domain: .work
