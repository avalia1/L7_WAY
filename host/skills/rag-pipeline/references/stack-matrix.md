# RAG stack matrix (local playground)

## Recommended defaults

| Stage | Dev | Prod-leaning |
|-------|-----|----------------|
| Load/parse | LlamaIndex readers | LlamaIndex + custom loaders |
| Chunk | LlamaIndex node parsers / LangChain text-splitters | same + eval-driven sizes |
| Embed | OpenAI / Gemini / local | pin model + dim |
| Store | **Chroma** (`vector-chroma`) | **Qdrant** (`vector-qdrant`) |
| Retrieve | vector top-k | fusion / auto-merge / hybrid |
| Generate | Claude / OpenAI / Gemini | + citations |
| Eval | golden questions | faithfulness + relevancy |

## Local paths

- Chroma: `~/Documents/Obsidian Vault/00 AI Playground/chroma`
- Qdrant: `~/Documents/Obsidian Vault/00 AI Playground/qdrant`
- LlamaIndex packs: `.../llama_index/llama-index-packs/`
- LangChain splitters: `.../langchain/libs/text-splitters`

## Offline skill-runtime RAG

Without installing chromadb, use:

```bash
l7 skills rag-index --rebuild
l7 skills rag-query "your question"
```

This indexes skill bodies + playground READMEs with pure TF-IDF (no network).
