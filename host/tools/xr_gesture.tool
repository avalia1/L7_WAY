name: xr_gesture
description: Detect and classify spatial gestures from hand and controller input
does: analyze
server: universal-xr
mcp_tool: xr.gesture.detect

needs:
  device: string

optional:
  gestures: array
  threshold: number

gives:
  gesture: string
  confidence: number
  hand: string
  position: array
  timestamp: number

pii: false
approval: false
audit: true
output: json
runs: stream
version: v1
