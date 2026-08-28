name: xr_material
description: Create and modify PBR materials, shaders, and surface properties
does: render
server: universal-xr
mcp_tool: xr.material.manage

needs:
  action: string

optional:
  device: string
  material_id: string
  type: string
  color: string
  metallic: number
  roughness: number
  texture: string
  opacity: number
  shader: string

gives:
  material_id: string
  type: string
  properties: object

pii: false
approval: false
audit: true
output: json
runs: once
version: v1
