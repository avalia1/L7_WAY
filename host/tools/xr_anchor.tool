name: xr_anchor
description: Create, persist, and query spatial anchors in the physical world
does: automate
server: universal-xr
mcp_tool: xr.anchor.manage

needs:
  action: string

optional:
  device: string
  anchor_id: string
  position: array
  rotation: array
  persist: boolean
  label: string

gives:
  anchor_id: string
  position: array
  rotation: array
  tracking_state: string
  persisted: boolean

pii: false
approval: false
audit: true
output: json
runs: once
version: v1
