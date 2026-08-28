name: xr_avatar
description: Load and animate user avatar representations across devices
does: render
server: universal-xr
mcp_tool: xr.avatar.manage

needs:
  action: string

optional:
  device: string
  avatar_id: string
  style: string
  expression: string
  animation: string

gives:
  avatar_id: string
  state: string
  style: string
  skeleton: object

pii: true
approval: false
audit: true
output: json
runs: once
version: v1
