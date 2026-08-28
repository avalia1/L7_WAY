name: codex_amber
suite: Codex
tagline: "Sealed in eternity"
does: data
server: l7-media
mcp_tool: codex.preserve
description: "Data preservation engine. Seals artifacts with cryptographic signatures, timestamps, and integrity proofs. Once in amber, it cannot be altered — only verified."
needs:
  artifact: string
  domain: string
  seal_type: string
gives:
  sealed_hash: string
  timestamp: string
  certificate: object
  verification_url: string
pii: false
approval: true
audit: true
output: json
runs: once
version: v1
icon: shield
color: "#a855f7"
