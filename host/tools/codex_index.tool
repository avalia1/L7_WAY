name: codex_index
suite: Codex
tagline: "Find anything, instantly"
does: analyze
server: l7-media
mcp_tool: codex.search
description: "Semantic search across all L7 domains. Not keyword matching — meaning matching. Ask a question in natural language, get the artifact that answers it."
needs:
  query: string
  domains: array
  limit: number
gives:
  results: array
  relevance_scores: array
  suggestions: array
pii: false
approval: false
audit: true
output: json
runs: once
version: v1
icon: search
color: "#a855f7"
