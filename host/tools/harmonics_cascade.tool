name: harmonics_cascade
suite: Resonance
tagline: "Sympathetic vibration"
does: automate
server: l7-gateway
mcp_tool: harmonics.cascade
description: "Triggers a resonance cascade from a source node. When one node locks into harmony, nearby nodes vibrate sympathetically — like striking a piano string and hearing the overtones ring across the soundboard."
needs:
  source_node: string
  intensity: number
gives:
  cascaded_nodes: array
  resonance_depth: number
  new_harmonics: array
pii: false
approval: false
audit: true
output: json
runs: once
version: v1
icon: waves
color: "#8b5cf6"
patent: "Self-Tuning Harmonic Field Resonance System"
inventor: "Alberto Valido Delgado"
