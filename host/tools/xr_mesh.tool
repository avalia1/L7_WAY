name: xr_mesh
description: Load, generate, and query 3D geometry and models
does: render
server: universal-xr
mcp_tool: xr.mesh.manage

needs:
  action: string

optional:
  device: string
  source: string
  format: string
  primitive: string
  dimensions: object
  lod: number

gives:
  mesh_id: string
  vertex_count: number
  format: string
  bounds: object

pii: false
approval: false
audit: true
output: json
runs: once
version: v1
