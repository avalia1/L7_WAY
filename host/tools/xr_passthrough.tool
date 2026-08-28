name: xr_passthrough
description: Control the real-world camera passthrough feed and blending
does: render
server: universal-xr
mcp_tool: xr.passthrough.control

needs:
  action: string

optional:
  device: string
  opacity: number
  style: string

gives:
  enabled: boolean
  opacity: number
  frame: string
  resolution: object

pii: false
approval: false
audit: true
output: json
runs: once
version: v1
