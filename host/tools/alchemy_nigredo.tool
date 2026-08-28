name: alchemy_nigredo
suite: Codex
tagline: "Nigredo inventory of path/project"
does: analyze
server: skill-runtime
mcp_tool: skill.alchemy-nigredo
description: "Nigredo inventory of path/project"
needs:
  path: string
optional:
  action: string
  no_write: boolean
  root: string
  limit: number
gives:
  result: object
  stages: object
  manifest: object
pii: false
approval: false
audit: true
output: json
runs: once
version: v1
icon: flask
color: "#1f2937"
l7_skill: alchemy-nigredo
source: skill-runtime
executable: true
law: XXV
