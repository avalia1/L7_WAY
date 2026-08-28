name: flux_splice
suite: Flux
tagline: "Stories assemble themselves"
does: render
server: l7-media
mcp_tool: flux.compose
description: "Intelligent video composition. Detects scene boundaries, matches audio to visual rhythm, and assembles sequences with professional transitions and pacing."
needs:
  clips: array
  style: string
  music_track: string
gives:
  composed_video: stream
  edit_decision_list: array
  scene_count: number
pii: false
approval: false
audit: true
output: json
runs: once
version: v1
icon: scissors
color: "#06b6d4"
