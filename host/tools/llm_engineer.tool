name: llm_engineer
suite: Codex
tagline: "LLM course learning path"
does: analyze
server: l7-gateway
mcp_tool: skill.llm-engineer
description: "Follow the LLM course path: fundamentals, scientist (training/fine-tuning), and engineer (applications + deployment) using the local llm-course materials."
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
l7_skill: llm-engineer
source: ai-playground
