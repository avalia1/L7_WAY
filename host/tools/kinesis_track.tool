name: kinesis_track
suite: Kinesis
tagline: "Your body speaks volumes"
does: analyze
server: l7-media
mcp_tool: kinesis.body
description: "Full-body motion capture from any camera source. Tracks 33 skeletal joints in real-time, producing animation-ready data streams."
needs:
  source: string
  skeleton_model: string
gives:
  joints: array
  pose: object
  velocity: array
  confidence: number
pii: false
approval: false
audit: true
output: json
runs: stream
version: v1
icon: body
color: "#8b5cf6"
