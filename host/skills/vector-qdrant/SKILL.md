---
name: vector-qdrant
description: "Operate Qdrant vector search: collections, payloads, filters, hybrid search, and production deployment patterns from the local qdrant repo."
metadata:
  {
    "openclaw": {
      "emoji": "🧭",
      "always": false
    },
    "l7": {
      "suite": "Codex",
      "does": "search",
      "tagline": "Qdrant vector search engine",
      "entity_id": "skill.vector-qdrant",
      "version": "v1",
      "source": "ai-playground"
    }
  }
---

# Vector Qdrant

Root: `/Users/rnir_hrc_avd/Documents/Obsidian Vault/00 AI Playground/qdrant`

## Resources

- `docs/` — guides
- `openapi/` — API specs
- `config/` — server configs
- `QUICK_START.md` if present

## Workflow

1. Run local Qdrant (docker or binary).
2. Create collection with vector size + distance.
3. Upsert points with payload.
4. Search with filters / hybrid as needed.
5. Wire clients via LangChain/LlamaIndex integrations.

## Production notes

- Prefer explicit payload indexes for filter fields.
- Snapshot before schema changes.
- Align embedding model + dim with collection config.

## L7 Declaration (Seven Seals)

- Capability 🔧: Production vector search, payload filters, hybrid
- Data 📦: qdrant server + openapi + docs
- Policy/Intent 🧭: Version collections; backup before destructive ops
- Presentation 🧩: API/collection configs
- Orchestration 🔗: create collection → index → search → filter
- Time/Versioning 🕒: v1 (birth 2026-07-21)
- Identity/Security 🛡️: Network-seal by default in L7 (N1); local-only unless approved

### Entity

- entity_id: skill.vector-qdrant
- entity_type: tool
- owner: founder
- status: active
- lineage: ai-playground → qdrant
- domain: .work
