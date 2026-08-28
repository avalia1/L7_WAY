name: tesseract_forge
suite: Tesseract
tagline: "From nothing, form"
does: render
server: l7-media
mcp_tool: tesseract.generate
description: "3D model generation from text descriptions, images, or point clouds. Produces watertight meshes with UV maps, ready for any engine."
needs:
  prompt: string
  source_type: string
  detail_level: string
gives:
  mesh: object
  texture_maps: array
  vertex_count: number
  format: string
pii: false
approval: false
audit: true
output: json
runs: once
version: v1
icon: cube
color: "#22c55e"
