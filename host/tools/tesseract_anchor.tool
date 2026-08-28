name: tesseract_anchor
suite: Tesseract
tagline: "Pin the virtual to the real"
does: data
server: l7-media
mcp_tool: tesseract.anchor
description: "Spatial anchor management across devices and sessions. Content stays where you put it — in your room, in your city, on the planet. Persistent and shareable."
needs:
  position: array
  reference_frame: string
  persistence: string
gives:
  anchor_id: string
  confidence: number
  shared_url: string
pii: false
approval: false
audit: true
output: json
runs: once
version: v1
icon: pin
color: "#22c55e"
