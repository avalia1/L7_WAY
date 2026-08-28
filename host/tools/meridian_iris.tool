name: meridian_iris
suite: Meridian
tagline: "Name everything you see"
does: analyze
server: l7-media
mcp_tool: meridian.recognize
description: "Scene understanding that names, classifies, and relates every object in view. Builds a semantic graph of what's present and how things relate spatially."
needs:
  source: string
  detail_level: string
gives:
  objects: array
  scene_graph: object
  summary: string
  confidence: number
pii: false
approval: false
audit: true
output: json
runs: once
version: v1
icon: scan
color: "#f59e0b"
