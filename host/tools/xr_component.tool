name: xr_component
description: Attach, detach, and query components on spatial entities
does: analyze
server: universal-xr
mcp_tool: xr.component.manage

needs:
  action: string
  entity_id: string

optional:
  device: string
  component_type: string
  properties: object

gives:
  component_id: string
  type: string
  entity_id: string
  properties: object

pii: false
approval: false
audit: true
output: json
runs: once
version: v1
