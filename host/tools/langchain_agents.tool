name: langchain_agents
suite: Herald
tagline: "LangChain reliable agents"
does: automate
server: l7-gateway
mcp_tool: skill.langchain-agents
description: "Build reliable agents and chains with LangChain: core LCEL, langchain v1 agents, partners, text splitters, and standard tests."
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
l7_skill: langchain-agents
source: ai-playground
