name: flux_tempo
suite: Flux
tagline: "Bend time"
does: render
server: l7-media
mcp_tool: flux.time
description: "Time manipulation engine. Smooth slow-motion via frame interpolation, time-lapse compression, reverse playback, and temporal echo effects."
needs:
  source: string
  speed_factor: number
  interpolation: string
gives:
  processed_video: stream
  original_duration: number
  new_duration: number
pii: false
approval: false
audit: true
output: json
runs: once
version: v1
icon: clock
color: "#06b6d4"
