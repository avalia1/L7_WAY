---
name: vector-chroma
description: "Use Chroma for embedding storage, collections, metadata filters, and local LLM memory — from the local chroma codebase and examples."
metadata:
  {
    "openclaw": {
      "emoji": "🧬",
      "always": false
    },
    "l7": {
      "suite": "Codex",
      "does": "search",
      "tagline": "Chroma embedding database",
      "entity_id": "skill.vector-chroma",
      "version": "v1",
      "source": "ai-playground"
    }
  }
---

# Vector Chroma

Root: `/Users/rnir_hrc_avd/Documents/Obsidian Vault/00 AI Playground/chroma`

## Quick path

```bash
pip install chromadb
```

Examples: `/Users/rnir_hrc_avd/Documents/Obsidian Vault/00 AI Playground/chroma/examples`

## Workflow

1. Create client (ephemeral or persistent).
2. Create/get collection with embedding function.
3. Upsert documents + metadata + ids.
4. Query with text or embeddings + where filters.
5. Integrate with LangChain / LlamaIndex retrievers.

## When vs Qdrant

- Chroma: fast local/dev, simple DX
- Qdrant: production scale, advanced filtering, Rust core (see `vector-qdrant`)

## L7 Declaration (Seven Seals)

- Capability 🔧: Vector collections, embeddings, metadata query
- Data 📦: chromadb client/server + examples
- Policy/Intent 🧭: Ephemeral for experiments; persistent path for real data
- Presentation 🧩: Collection/query code snippets
- Orchestration 🔗: embed → upsert → query → rerank optional
- Time/Versioning 🕒: v1 (birth 2026-07-21)
- Identity/Security 🛡️: No PII in shared collections without approval

### Entity

- entity_id: skill.vector-chroma
- entity_type: tool
- owner: founder
- status: active
- lineage: ai-playground → chroma
- domain: .work
