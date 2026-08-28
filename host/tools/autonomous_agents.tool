name: autonomous_agents
suite: Herald
tagline: "AutoGPT agent platform"
does: automate
server: l7-gateway
mcp_tool: skill.autonomous-agents
description: "Design and run autonomous agent graphs with AutoGPT platform (blocks, workflows) and classic AutoGPT agent loops."
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
l7_skill: autonomous-agents
source: ai-playground
