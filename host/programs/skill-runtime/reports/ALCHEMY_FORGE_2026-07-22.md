# Alchemy + Forge applied to reorganized home

**Date:** 2026-07-22  
**Law:** XXV — Gateway is a FORGE; transmute, do not merely route  
**Input:** `~/Projects` (from Backup merge) + `~/L7_WAY`

## What shipped

### Alchemy package
- `packages/alchemy/transmuter.py` — nigredo / albedo / citrinitas / rubedo / transmute
- Sealed writes: `~/.l7/state/skill-runtime/alchemy/`

### Skills (5)
| Skill | Stage |
|-------|-------|
| `alchemy-transmutation` | Full Great Work |
| `alchemy-nigredo` | Inventory |
| `alchemy-albedo` | Purity / secrets |
| `alchemy-citrinitas` | Skill + forge map |
| `alchemy-rubedo` | Citizen seal |

### Forge tools
`alchemy_transmute`, `alchemy_transmutation` (multi-action), `alchemy_nigredo`, `alchemy_albedo`, `alchemy_citrinitas`, `alchemy_rubedo`, `project_index`

### CLI
```bash
l7 skills alchemy transmute <path>
l7 skills alchemy nigredo|albedo|citrinitas|rubedo <path>
l7 skills project-index [--root ~/Projects]
python3 forge/skill_bridge.py execute alchemy_transmute '{"path":"~/Projects/openclaw"}'
```

### Corpus
Profile `home-projects` → roots `~/L7_WAY` + `~/Projects` (with junk/secret excludes).

## Great Work results (sealed)

| Subject | Files (capped 50k) | Purity | Notes |
|---------|-------------------|--------|-------|
| `~/L7_WAY` | 50001 (trunc) | 0.96 | doctrine citizen sealed |
| `~/Projects` | 50001 / ~3.8GB | 0.0 | 202 junk dirs, 148 secret-name hits — expected dump |
| `~/Projects/openclaw` | 33 | 0.98 | clean small project |
| skill-runtime | — | high | runtime self-transmuted |

### project-index highlights
- **33** top-level entries under `~/Projects`
- Heavy: `Persi` ~2GB, `macbook-pro-backup` ~1.5GB, `icloud-drive-archive` ~1.6GB, `go` ~628MB
- High secret-name counts: macbook-pro-backup (72), Persi (66), go (41) — **name patterns only**, contents not read
- Active-ish code: `eco_dev` (git, 16 secret names, 192 junk), `nc-life-scripts`, `ncls-outreach-figma`, `openclaw`

## Tests
- `python3 -m unittest forge.test_forge` — **10/10 OK** (includes alchemy + project_index)
- `l7 skills doctor` — **25 skills**, 94 tools, 30 citizens, validation clean

## How it works (operator path)

1. **Nigredo** — walk tree, count files/ext/junk/secret-names  
2. **Albedo** — purity score + recommended actions  
3. **Citrinitas** — match `~/.l7/skills` + suggest forge tools  
4. **Rubedo** — write `project.*.citizen` stamp for Empire routing  
5. **Forge** — `TOOL_MAP` → `skill_bridge` → `l7skills alchemy …` envelope

## Next (optional)
- Cap purity scoring for large trees with better normalization
- Domain-specific RAG over L7_WAY md only (skip binary backups)
- OpenClaw must-call-forge for alchemy tools (B2)
