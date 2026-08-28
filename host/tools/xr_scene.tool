name: xr_scene
description: Query environment planes, meshes, and semantic labels from scene understanding
does: analyze
server: universal-xr
mcp_tool: xr.scene.query

needs:
  device: string

optional:
  filter: string
  radius: number

gives:
  planes: array
  meshes: array
  labels: array
  timestamp: number

pii: false
approval: false
audit: true
output: json
runs: once
version: v1
