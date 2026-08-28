name: tesseract_scene
suite: Tesseract
tagline: "Compose realities"
does: render
server: l7-media
mcp_tool: tesseract.scene
description: "Scene composition engine. Places entities, lights, cameras, and physics in a unified 3D environment. Outputs to any renderer — WebGL, Metal, Vulkan."
needs:
  entities: array
  lighting: object
  camera: object
gives:
  scene_graph: object
  render_target: string
  entity_count: number
pii: false
approval: false
audit: true
output: json
runs: once
version: v1
icon: globe
color: "#22c55e"
