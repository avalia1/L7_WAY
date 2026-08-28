name: alchemy_albedo
suite: Codex
tagline: "Albedo purity / dross / secrets review"
does: analyze
server: skill-runtime
mcp_tool: skill.alchemy-albedo
description: "Albedo purity / dross / secrets review"
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
color: "#e5e7eb"
l7_skill: alchemy-albedo
source: skill-runtime
executable: true
law: XXV
