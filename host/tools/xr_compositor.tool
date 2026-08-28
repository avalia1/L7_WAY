name: xr_compositor
description: Manage composition layers for rendering output to the spatial display
does: render
server: universal-xr
mcp_tool: xr.compositor.manage

needs:
  action: string

optional:
  device: string
  layers: array
  blend_mode: string

gives:
  layer_count: number
  layers: array
  frame_rate: number
  state: string

pii: false
approval: false
audit: true
output: json
runs: once
version: v1
