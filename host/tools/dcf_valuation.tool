name: dcf_valuation
suite: Codex
tagline: "Executable DCF model"
does: analyze
server: l7-gateway
mcp_tool: skill.dcf-valuation
description: "Run a discounted cash flow valuation (WACC, projections, terminal value, equity value) via `l7 skills dcf` using the pure-Python DCF package."
needs:
  task: string
optional:
  period: string
  industry: string
  company: string
  query: string
gives:
  result: object
  summary: string
pii: false
approval: false
audit: true
output: json
runs: once
version: v1
icon: bolt
color: "#22c55e"
l7_skill: dcf-valuation
source: ai-playground
executable: true
