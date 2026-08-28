name: l7_empire
suite: Codex
tagline: "Operate inside the L7 empire"
does: search
server: l7-gateway
mcp_tool: skill.l7-empire
description: "Operate L7 itself: skills CLI, tools/citizens, gateway/forge laws, ashrams, audit, and how AI Playground skills plug into ~/.l7."
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
l7_skill: l7-empire
source: ai-playground
executable: true
