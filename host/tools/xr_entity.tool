name: xr_entity
description: Create, destroy, and query entities in the spatial scene graph
does: render
server: universal-xr
mcp_tool: xr.entity.manage

needs:
  action: string

optional:
  device: string
  entity_id: string
  mesh: string
  material: string
  position: array
  rotation: array
  scale: array
  anchor: string
  parent: string
  components: array

gives:
  entity_id: string
  state: string
  transform: object
  children: array

pii: false
approval: false
audit: true
output: json
runs: once
version: v1
