name: flux_stream
suite: Flux
tagline: "Live to everywhere"
does: communicate
server: l7-media
mcp_tool: flux.broadcast
description: "Multi-destination live broadcasting. Takes any video source and streams simultaneously to platforms, devices, and recording — with per-destination quality adaptation."
needs:
  source: string
  destinations: array
  quality: string
gives:
  stream_urls: array
  viewer_count: number
  bitrate: object
  health: object
pii: false
approval: true
audit: true
output: json
runs: stream
version: v1
icon: broadcast
color: "#06b6d4"
