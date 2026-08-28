name: studio_synth
suite: Resonance
tagline: "Sound from thought"
does: render
server: l7-gateway
mcp_tool: studio.synthesize
description: "Interactive audio synthesis engine. Multiple oscillator types, real-time effects chain (reverb, delay, filter), piano keyboard interface, loop recording. Creates music interactively — painting with sound."
needs:
  type: string
  frequency: number
  effects: array
  duration: number
gives:
  audio_buffer: stream
  waveform: array
  spectrum: array
pii: false
approval: false
audit: true
output: stream
runs: stream
version: v1
icon: music
color: "#ec4899"
patent: "Integrated Audio-Visual Synthesis Engine"
inventor: "Alberto Valido Delgado"
