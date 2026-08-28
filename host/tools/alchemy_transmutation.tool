name: alchemy_transmutation
suite: Codex
tagline: "Alchemy multi-action forge tool (stages + transmute)"
does: analyze
server: skill-runtime
mcp_tool: skill.alchemy-transmutation
description: "Alchemy multi-action forge tool (stages + transmute)"
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
color: "#a855f7"
l7_skill: alchemy-transmutation
source: skill-runtime
executable: true
law: XXV
