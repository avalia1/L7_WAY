name: vector_chroma
suite: Codex
tagline: "Chroma embedding database"
does: search
server: l7-gateway
mcp_tool: skill.vector-chroma
description: "Use Chroma for embedding storage, collections, metadata filters, and local LLM memory — from the local chroma codebase and examples."
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
l7_skill: vector-chroma
source: ai-playground
