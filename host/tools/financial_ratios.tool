name: financial_ratios
suite: Codex
tagline: "Executable financial ratios"
does: analyze
server: l7-gateway
mcp_tool: skill.financial-ratios
description: "Calculate and interpret financial ratios from statement data or the playground CSV via `l7 skills ratios` (profitability, liquidity, leverage, efficiency, valuation)."
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
l7_skill: financial-ratios
source: ai-playground
executable: true
