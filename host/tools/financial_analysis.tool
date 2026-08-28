name: financial_analysis
suite: Codex
tagline: "Financial skill packages"
does: analyze
server: l7-gateway
mcp_tool: skill.financial-analysis
description: "Run financial ratio analysis, brand-guideline application, and DCF/sensitivity modeling using Anthropic custom skill scripts and sample financial data."
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
l7_skill: financial-analysis
source: ai-playground
