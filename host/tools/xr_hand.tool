name: xr_hand
description: Stream hand joint positions and skeletal tracking data
does: analyze
server: universal-xr
mcp_tool: xr.hand.track

needs:
  device: string

optional:
  hand: string
  frequency: number

gives:
  joints: array
  confidence: number
  hand: string
  timestamp: number

pii: false
approval: false
audit: true
output: json
runs: stream
version: v1
