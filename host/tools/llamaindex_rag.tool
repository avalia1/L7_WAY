name: llamaindex_rag
suite: Codex
tagline: "LlamaIndex RAG & packs"
does: search
server: l7-gateway
mcp_tool: skill.llamaindex-rag
description: "Build RAG systems with LlamaIndex: indices, query engines, retrievers, and llama-index-packs (fusion, auto-merging, chroma autoretrieval)."
needs:
  task: string
optional:
  context: string
  path: string
gives:
  guidance: string
  paths: array
  next_steps: array
pii: false
approval: false
audit: true
output: text
runs: once
version: v1
icon: book
color: #6366f1
l7_skill: llamaindex-rag
source: ai-playground
