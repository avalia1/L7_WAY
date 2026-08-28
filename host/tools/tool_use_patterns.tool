name: tool_use_patterns
suite: Herald
tagline: "Tool use & structured calling"
does: automate
server: l7-gateway
mcp_tool: skill.tool-use-patterns
description: "Design tool-using agents: parallel tools, tool choice, Pydantic schemas, memory tools, structured JSON extraction, and vision+tools from Anthropic and OpenAI cookbooks."
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
l7_skill: tool-use-patterns
source: ai-playground
