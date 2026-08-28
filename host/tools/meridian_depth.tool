name: meridian_depth
suite: Meridian
tagline: "Distance is information"
does: analyze
server: l7-media
mcp_tool: meridian.depth
description: "Stereoscopic depth estimation from any image source. Reconstructs the z-axis that cameras flatten, giving flat media a spatial dimension."
needs:
  source: string
  model: string
gives:
  depth_map: image
  point_cloud: array
  near_plane: number
  far_plane: number
pii: false
approval: false
audit: true
output: json
runs: once
version: v1
icon: layers
color: "#f59e0b"
