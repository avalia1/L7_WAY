name: agent_workflows
suite: Herald
tagline: "Claude agent workflow patterns"
does: automate
server: l7-gateway
mcp_tool: skill.agent-workflows
description: "Implement Claude agent workflow patterns: basic prompt chains, evaluator-optimizer loops, and orchestrator-workers from the Anthropic cookbook."
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
l7_skill: agent-workflows
source: ai-playground
