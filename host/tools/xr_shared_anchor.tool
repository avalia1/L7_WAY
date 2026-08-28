name: xr_shared_anchor
description: Share spatial anchors across users and devices for co-located experiences
does: communicate
server: universal-xr
mcp_tool: xr.anchor.share

needs:
  action: string

optional:
  device: string
  anchor_id: string
  position: array
  group_id: string
  peers: array

gives:
  anchor_id: string
  group_id: string
  shared_with: array
  sync_state: string

pii: false
approval: false
audit: true
output: json
runs: once
version: v1
