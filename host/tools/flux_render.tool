name: flux_render
suite: Flux
tagline: "Every frame, transformed"
does: render
server: l7-media
mcp_tool: flux.process
description: "Real-time video processing pipeline. Applies chains of visual transformations — style transfer, colorgrade, stabilization, super-resolution — at frame rate."
needs:
  source: string
  pipeline: array
  output_format: string
gives:
  processed_stream: stream
  frame_rate: number
  latency_ms: number
pii: false
approval: false
audit: true
output: json
runs: stream
version: v1
icon: film
color: "#06b6d4"
