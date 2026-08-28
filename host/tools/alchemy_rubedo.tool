name: alchemy_rubedo
suite: Codex
tagline: "Rubedo seal citizen manifest"
does: analyze
server: skill-runtime
mcp_tool: skill.alchemy-rubedo
description: "Rubedo seal citizen manifest"
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
color: "#dc2626"
l7_skill: alchemy-rubedo
source: skill-runtime
executable: true
law: XXV
