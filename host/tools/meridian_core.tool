name: meridian_core
suite: Meridian
tagline: "The edge of perception"
does: analyze
server: l7-media
mcp_tool: meridian.contour
description: "Maps visual boundaries into navigable contour intelligence. Not just edges — cognitive boundaries that reveal the structure hiding inside any image."
needs:
  source: string
  sensitivity: number
  method: string
gives:
  contours: array
  depth_map: image
  structure_score: number
pii: false
approval: false
audit: true
output: json
runs: once
version: v1
icon: eye
color: "#f59e0b"
