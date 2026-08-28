name: xr_audio
description: Place and control spatialized audio sources in the 3D scene
does: render
server: universal-xr
mcp_tool: xr.audio.manage

needs:
  action: string

optional:
  device: string
  source_id: string
  file: string
  position: array
  volume: number
  loop: boolean
  spatial: boolean
  rolloff: string

gives:
  source_id: string
  state: string
  position: array
  duration: number

pii: false
approval: false
audit: true
output: json
runs: once
version: v1
