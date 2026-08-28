name: tesseract_portal
suite: Tesseract
tagline: "Step between worlds"
does: render
server: l7-media
mcp_tool: tesseract.portal
description: "Cross-device spatial projection. What renders on Vision Pro also appears on Quest also appears in browser — same content, adapted to each medium's strengths."
needs:
  content: object
  target_devices: array
  sync_mode: string
gives:
  projections: array
  sync_status: object
  latency_ms: number
pii: false
approval: false
audit: true
output: json
runs: stream
version: v1
icon: portal
color: "#22c55e"
