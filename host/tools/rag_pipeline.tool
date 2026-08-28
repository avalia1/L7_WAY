name: rag_pipeline
suite: Codex
tagline: "Cross-stack RAG design"
does: search
server: l7-gateway
mcp_tool: skill.rag-pipeline
description: "Design end-to-end RAG pipelines by composing local playground stacks: chunking, embeddings, Chroma/Qdrant stores, LlamaIndex/LangChain retrieval, and evaluation."
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
l7_skill: rag-pipeline
source: ai-playground
