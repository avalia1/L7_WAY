name: codex_memory
suite: Codex
tagline: "The salt remembers"
does: search
server: l7-gateway
mcp_tool: codex.memory
description: "Semantic vector memory for the Empire. Index artifacts into high-dimensional embeddings, search by meaning not just keyword, track memory status across all domains. Built on the .salt archive — everything remembered is everything preserved. Supports index, search, status, forget operations."
needs:
  action: string
optional:
  query: string
  artifact: string
  domain: string
  limit: number
  threshold: number
gives:
  results: array
  similarity_scores: array
  index_status: object
  memory_count: number
  domains_indexed: array
pii: false
approval: false
audit: true
output: json
runs: once
version: v1
icon: brain
color: "#f59e0b"
