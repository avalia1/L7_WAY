name: xr_frame
description: Submit rendered frames to the spatial display pipeline
does: render
server: universal-xr
mcp_tool: xr.frame.submit

needs:
  device: string

optional:
  frame_id: string
  layers: array
  prediction_time: number

gives:
  frame_id: string
  presented: boolean
  timing: object
  dropped: boolean

pii: false
approval: false
audit: true
output: json
runs: stream
version: v1
