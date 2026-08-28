name: multiagent_autogen
suite: Herald
tagline: "AutoGen multi-agent systems"
does: automate
server: l7-gateway
mcp_tool: skill.multiagent-autogen
description: "Build multi-agent applications with Microsoft AutoGen: agentchat, core runtime, Magentic-One, extensions, and studio workflows."
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
l7_skill: multiagent-autogen
source: ai-playground
