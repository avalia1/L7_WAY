name: codex_scribe
suite: Codex
tagline: "Knowledge writes itself"
does: automate
server: l7-media
mcp_tool: codex.generate
description: "Intelligent document generation. Assembles documentation, reports, and manuscripts from structured data, code analysis, and natural language prompts."
needs:
  topic: string
  sources: array
  format: string
  style: string
gives:
  document: string
  table_of_contents: array
  word_count: number
  citations: array
pii: false
approval: false
audit: true
output: json
runs: once
version: v1
icon: pen
color: "#a855f7"
