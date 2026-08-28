---
name: rag-pipeline
description: "Design end-to-end RAG pipelines by composing local playground stacks: chunking, embeddings, Chroma/Qdrant stores, LlamaIndex/LangChain retrieval, and evaluation."
metadata:
  {
    "openclaw": {
      "emoji": "🔗",
      "always": false
    },
    "l7": {
      "suite": "Codex",
      "does": "search",
      "tagline": "Cross-stack RAG design",
      "entity_id": "skill.rag-pipeline",
      "version": "v1",
      "source": "ai-playground"
    }
  }
---

# RAG Pipeline (cross-stack)

Playground root: `/Users/rnir_hrc_avd/Documents/Obsidian Vault/00 AI Playground`


## Commands

```bash
l7 skills rag-index --rebuild --profile real-corpus
l7 skills rag-query "question" --profile real-corpus
l7 skills rag-eval --profile real-corpus
```

## Canonical stages

1. **Ingest** — load docs (LlamaIndex readers / LangChain loaders)
2. **Chunk** — text-splitters / node parsers
3. **Embed** — OpenAI / Gemini / local embeddings
4. **Store** — Chroma (dev) or Qdrant (prod)
5. **Retrieve** — vector / hybrid / fusion / auto-merge
6. **Generate** — Claude / OpenAI / Gemini with citations
7. **Eval** — faithfulness, relevancy, guardrails

## Default recommendations

| Stage | Local skill / repo |
|-------|--------------------|
| Indices & packs | `llamaindex-rag` |
| Chains / agents | `langchain-agents` |
| Dev vectors | `vector-chroma` |
| Prod vectors | `vector-qdrant` |
| Prompting | `prompt-engineering` |
| Tool agents on top | `tool-use-patterns` / `agent-workflows` |

## Workflow

1. Define corpus + questions (golden set).
2. Stand up store (Chroma first).
3. Build retriever; measure hit rate.
4. Only then attach generator + agent tools.
5. Promote to Qdrant when scale/filters demand it.

## L7 Declaration (Seven Seals)

- Capability 🔧: Unified RAG architecture across local stacks
- Data 📦: Pointers into chroma, qdrant, llama_index, langchain, cookbooks
- Policy/Intent 🧭: Measure retrieval before generation quality
- Presentation 🧩: Pipeline stages + stack choices
- Orchestration 🔗: ingest→chunk→embed→store→retrieve→generate→eval
- Time/Versioning 🕒: v1 (birth 2026-07-21)
- Identity/Security 🛡️: Keep corpora local; PII redaction before embed when needed

### Entity

- entity_id: skill.rag-pipeline
- entity_type: tool
- owner: founder
- status: active
- lineage: ai-playground → chroma, qdrant, llama_index, langchain, anthropic-cookbook, openai-cookbook
- domain: .work
