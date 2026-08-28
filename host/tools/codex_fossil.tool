name: codex_fossil
suite: Codex
tagline: "Every version, preserved"
does: data
server: l7-media
mcp_tool: codex.snapshot
description: "Automatic versioning and snapshot management. Every change creates a fossil record. Browse, compare, and restore any point in an artifact's history."
needs:
  artifact: string
  domain: string
  action: string
gives:
  snapshot_id: string
  diff: object
  history: array
pii: false
approval: false
audit: true
output: json
runs: once
version: v1
icon: history
color: "#a855f7"
