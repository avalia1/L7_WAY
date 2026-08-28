name: alchemy_citrinitas
suite: Codex
tagline: "Citrinitas skill and forge tool mapping"
does: search
server: skill-runtime
mcp_tool: skill.alchemy-citrinitas
description: "Citrinitas skill and forge tool mapping"
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
color: "#eab308"
l7_skill: alchemy-citrinitas
source: skill-runtime
executable: true
law: XXV
