name: codex_skill
suite: Codex
tagline: "Know thyself, know thy tools"
does: search
server: l7-gateway
mcp_tool: codex.skill
description: "Tool and skill management for the L7 ecosystem. List, inspect, validate, install, and deprecate tools across all suites. Reads .tool schema, checks server availability, verifies atom declarations. The Empire's self-awareness of its own capabilities."
needs:
  action: string
optional:
  tool_name: string
  suite: string
  filter: object
  source: string
gives:
  tools: array
  tool_info: object
  validation: object
  suite_summary: object
  installed_count: number
pii: false
approval: false
audit: true
output: json
runs: once
version: v1
icon: wrench
color: "#6366f1"
