name: kinesis_flow
suite: Kinesis
tagline: "Predict the next move"
does: analyze
server: l7-media
mcp_tool: kinesis.optical
description: "Optical flow analysis that tracks every pixel's journey between frames. Reveals motion fields, predicts trajectories, and detects anomalies in movement patterns."
needs:
  source: string
  window_size: number
gives:
  flow_field: array
  trajectories: array
  anomalies: array
  dominant_direction: object
pii: false
approval: false
audit: true
output: json
runs: stream
version: v1
icon: wind
color: "#8b5cf6"
