name: openai_patterns
suite: Herald
tagline: "OpenAI cookbook recipes"
does: analyze
server: l7-gateway
mcp_tool: skill.openai-patterns
description: "Implement common OpenAI API patterns from the local openai-cookbook: embeddings, agents SDK, codex, deep research, guardrails, and structured workflows."
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
l7_skill: openai-patterns
source: ai-playground
