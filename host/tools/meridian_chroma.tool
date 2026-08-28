name: meridian_chroma
suite: Meridian
tagline: "Feel the color"
does: analyze
server: l7-media
mcp_tool: meridian.chroma
description: "Extracts the emotional palette of any visual. Returns not just hex codes but the psychological weight, cultural resonance, and harmonic relationships between colors."
needs:
  source: string
  depth: string
gives:
  palette: array
  harmony: object
  mood: string
  cultural_notes: array
pii: false
approval: false
audit: true
output: json
runs: once
version: v1
icon: palette
color: "#f59e0b"
