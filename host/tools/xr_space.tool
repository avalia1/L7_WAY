name: xr_space
description: Create and query coordinate spaces for spatial reference frames
does: render
server: universal-xr
mcp_tool: xr.space.manage

needs:
  action: string
  type: string

optional:
  device: string
  reference: string
  bounds: object

gives:
  space_id: string
  type: string
  origin: array
  bounds: object

pii: false
approval: false
audit: true
output: json
runs: once
version: v1
