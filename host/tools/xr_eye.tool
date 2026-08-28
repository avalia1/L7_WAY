name: xr_eye
description: Stream gaze direction and eye tracking data
does: analyze
server: universal-xr
mcp_tool: xr.eye.track

needs:
  device: string

optional:
  frequency: number

gives:
  gaze_origin: array
  gaze_direction: array
  confidence: number
  fixation_point: array
  timestamp: number

pii: true
approval: false
audit: true
output: json
runs: stream
version: v1
