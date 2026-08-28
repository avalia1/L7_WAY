name: watermark_provenance
suite: Codex
tagline: "Every creation has an author"
does: data
server: l7-gateway
mcp_tool: watermark.stamp
description: "Content provenance and watermarking system. Embeds visible and invisible watermarks in text, images, video, and audio. Steganographic encoding in pixel LSBs, ultrasonic audio markers, text metadata footers. All content registered with SHA-256 integrity hash."
needs:
  content_type: string
  content: string
  metadata: object
gives:
  watermarked: boolean
  registry_id: string
  hash: string
  creator: string
pii: false
approval: false
audit: true
output: json
runs: once
version: v1
icon: fingerprint
color: "#f59e0b"
patent: "Digital Content Provenance and Watermarking System"
inventor: "Alberto Valido Delgado"
