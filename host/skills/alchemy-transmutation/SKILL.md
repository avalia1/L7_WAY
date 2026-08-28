---
name: alchemy-transmutation
description: "Run the four-stage alchemy Great Work (nigredo→albedo→citrinitas→rubedo) on a path or project; seal citizen manifest for the forge."
metadata:
  {
    "openclaw": {
      "emoji": "⚗️",
      "always": false
    },
    "l7": {
      "suite": "Codex",
      "does": "analyze",
      "tagline": "Great Work / full transmute",
      "entity_id": "skill.alchemy-transmutation",
      "version": "v1",
      "source": "skill-runtime",
      "executable": true,
      "law": "XXV"
    }
  }
---

# Great Work / full transmute

## Commands

```bash
l7 skills alchemy transmute ~/Projects/openclaw
l7 skills alchemy transmute L7_WAY
l7 skills alchemy transmute openclaw --no-write
l7 skills project-index --root ~/Projects
# forge bridge
python3 ~/.l7/programs/skill-runtime/forge/skill_bridge.py execute alchemy_transmute '{"path":"~/Projects/openclaw"}'
```

## Stages (Law XXV)

| Stage | Color | Meaning | CLI |
|-------|-------|---------|-----|
| Nigredo | black | Decompose / inventory | `alchemy nigredo <path>` |
| Albedo | white | Purify / find dross & secrets | `alchemy albedo <path>` |
| Citrinitas | yellow | Illuminate / map skills & forge tools | `alchemy citrinitas <path>` |
| Rubedo | red | Complete / seal citizen manifest | `alchemy rubedo <path>` |
| Full | stone | All four + write seal | `alchemy transmute <path>` |

## Output

Sealed under `~/.l7/state/skill-runtime/alchemy/`:
- `{slug}_{work_id}.json` — full Great Work
- `{slug}.citizen.json` — citizen-like manifest for Empire routing

## When to use

- After reorganizing home/Backup into Projects
- Before wiring a new project into the forge
- When you need purity score + secret review + tool suggestions

## L7 Declaration (Seven Seals)

- Capability 🔧: Alchemy forge stage for path/project transmutation
- Data 📦: Filesystem trees under ~/Projects, ~/L7_WAY, ~/.l7
- Policy/Intent 🧭: Law XXV — forge transmutes; secrets flagged not exfiltrated; junk is ash
- Presentation 🧩: JSON envelope + sealed citizen manifest under state/alchemy
- Orchestration 🔗: nigredo → albedo → citrinitas → rubedo (or single stage)
- Time/Versioning 🕒: v1 (birth 2026-07-22)
- Identity/Security 🛡️: entity_id skill.alchemy-transmutation; audit logged; no network

### Entity

- entity_id: skill.alchemy-transmutation
- entity_type: tool
- owner: founder
- status: active
- lineage: skill-runtime + Book of Law XXV
- domain: .work
