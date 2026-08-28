name: vector_qdrant
suite: Codex
tagline: "Qdrant vector search engine"
does: search
server: l7-gateway
mcp_tool: skill.vector-qdrant
description: "Operate Qdrant vector search: collections, payloads, filters, hybrid search, and production deployment patterns from the local qdrant repo."
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
l7_skill: vector-qdrant
source: ai-playground
