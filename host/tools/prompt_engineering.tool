name: prompt_engineering
suite: Codex
tagline: "Prompt Engineering Guide techniques"
does: analyze
server: l7-gateway
mcp_tool: skill.prompt-engineering
description: "Apply prompt engineering techniques from the Prompt Engineering Guide: basic/advanced usage, reliability, adversarial robustness, and application patterns."
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
l7_skill: prompt-engineering
source: ai-playground
