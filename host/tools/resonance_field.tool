name: resonance_field
suite: Resonance
tagline: "Sound has a place"
does: render
server: l7-media
mcp_tool: resonance.spatial
description: "3D spatial audio engine. Places sound sources in three-dimensional space with physically accurate propagation, reflection, and occlusion."
needs:
  audio_source: string
  position: array
  room_geometry: object
gives:
  spatialized_audio: stream
  reverb_profile: object
  listener_position: array
pii: false
approval: false
audit: true
output: json
runs: stream
version: v1
icon: speaker
color: "#ef4444"
