name: watermark_verify
suite: Codex
tagline: "Prove the origin"
does: analyze
server: l7-gateway
mcp_tool: watermark.verify
description: "Verifies content provenance. Checks for watermark presence, validates SHA-256 integrity hash, cross-references with the content registry. Answers the question: was this created by this system?"
needs:
  content: string
  content_type: string
gives:
  verified: boolean
  creator: string
  timestamp: string
  integrity: boolean
  registry_match: boolean
pii: false
approval: false
audit: true
output: json
runs: once
version: v1
icon: shield-check
color: "#f59e0b"
patent: "Digital Content Provenance and Watermarking System"
inventor: "Alberto Valido Delgado"
