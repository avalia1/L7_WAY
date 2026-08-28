name: kinesis_mirror
suite: Kinesis
tagline: "Your digital twin, alive"
does: render
server: l7-media
mcp_tool: kinesis.avatar
description: "Drives a 3D avatar from motion capture data in real time. The digital twin moves as you move, breathes as you breathe. Supports custom avatar meshes."
needs:
  motion_source: string
  avatar_mesh: string
gives:
  animated_mesh: object
  blend_shapes: array
  frame_rate: number
pii: true
approval: false
audit: true
output: json
runs: stream
version: v1
icon: mirror
color: "#8b5cf6"
