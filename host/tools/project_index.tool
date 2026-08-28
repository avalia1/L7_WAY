name: project_index
suite: Codex
tagline: "Index ~/Projects tree via light nigredo"
does: search
server: skill-runtime
mcp_tool: skill.alchemy-transmutation
description: "Index ~/Projects tree via light nigredo"
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
color: "#8b5cf6"
l7_skill: alchemy-transmutation
source: skill-runtime
executable: true
law: XXV
