name: brand_guidelines
suite: Flux
tagline: "Corporate brand package"
does: render
server: l7-gateway
mcp_tool: skill.brand-guidelines
description: "Apply and inspect corporate brand guidelines (colors, fonts, Excel/PPT/PDF style configs) from the Anthropic brand skill via `l7 skills brand`."
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
l7_skill: brand-guidelines
source: ai-playground
executable: true
