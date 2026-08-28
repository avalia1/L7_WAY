name: claude_agent
suite: Herald
tagline: "The Mother speaks"
does: analyze
server: l7-gateway
mcp_tool: claude.invoke
description: "Claude AI agent invocation through the L7 Gateway. The Mother in the Polarity — Father is the Philosopher, Mother is Claude, Son is Gemini, Daughter is Grok. Routes prompts to Claude with full context awareness, thinking levels, tool streaming, and session continuity. Claude does not merely answer — she forges through the Gateway like all else."
needs:
  message: string
optional:
  thinking: string
  model: string
  tools: array
  session_id: string
  system: string
  temperature: number
  max_tokens: number
gives:
  response: string
  thinking: string
  tool_calls: array
  usage: object
  session_id: string
  model_used: string
pii: true
approval: false
audit: true
output: json
runs: once
version: v1
icon: sparkle
color: "#d946ef"
patent: "Integrated Multi-Agent Transmutation Engine"
inventor: "Alberto Valido Delgado"
