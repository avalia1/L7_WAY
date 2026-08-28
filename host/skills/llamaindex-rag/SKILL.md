---
name: llamaindex-rag
description: "Build RAG systems with LlamaIndex: indices, query engines, retrievers, and llama-index-packs (fusion, auto-merging, chroma autoretrieval)."
metadata:
  {
    "openclaw": {
      "emoji": "🦙",
      "always": false
    },
    "l7": {
      "suite": "Codex",
      "does": "search",
      "tagline": "LlamaIndex RAG & packs",
      "entity_id": "skill.llamaindex-rag",
      "version": "v1",
      "source": "ai-playground"
    }
  }
---

# LlamaIndex RAG

Root: `/Users/rnir_hrc_avd/Documents/Obsidian Vault/00 AI Playground/llama_index`

## Core

- `llama-index-core` — indices, retrievers, query engines
- `llama-index-packs` — reusable recipes
- `llama-index-integrations` — vector stores, LLMs, embeddings
- `docs/` — notebooks & guides

## High-value packs (local)

- chroma-autoretrieval
- fusion-retriever
- auto-merging-retriever
- dense-x-retrieval
- agent-search-retriever

## Workflow

1. Load documents → node parse → embed.
2. Build index appropriate to corpus size.
3. Start with vector retriever; add fusion/auto-merge if recall weak.
4. Attach query engine; only then wrap in an agent.
5. Measure faithfulness / relevancy before shipping.

## L7 Declaration (Seven Seals)

- Capability 🔧: Document indices, retrieval, query engines, packs
- Data 📦: llama-index-core + packs + integrations
- Policy/Intent 🧭: Evaluate retrieval quality before agent wrappers
- Presentation 🧩: Index → retrieve → synthesize
- Orchestration 🔗: Ingest → index → query engine → response
- Time/Versioning 🕒: v1 (birth 2026-07-21)
- Identity/Security 🛡️: Local docs stay local unless user allows upload

### Entity

- entity_id: skill.llamaindex-rag
- entity_type: tool
- owner: founder
- status: active
- lineage: ai-playground → llama_index
- domain: .work
