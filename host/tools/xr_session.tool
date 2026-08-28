name: xr_session
description: Start, stop, pause, or query a spatial computing session
does: automate
server: universal-xr
mcp_tool: xr.session.manage

needs:
  action: string
  device: string

optional:
  features: array

gives:
  session_id: string
  state: string
  device: string
  capabilities: array

pii: false
approval: false
audit: true
output: json
runs: once
version: v1
