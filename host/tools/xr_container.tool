name: xr_container
description: Spawn and manage windows, volumes, and immersive containers
does: render
server: universal-xr
mcp_tool: xr.container.manage

needs:
  action: string
  type: string

optional:
  device: string
  size: object
  position: array
  style: string

gives:
  container_id: string
  type: string
  state: string
  bounds: object

pii: false
approval: false
audit: true
output: json
runs: once
version: v1
