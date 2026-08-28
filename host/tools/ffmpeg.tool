name: ffmpeg
suite: Gateway
tagline: "Assemble frames"
does: render
server: "http://127.0.0.1:18795/"
mcp_tool: ffmpeg.assemble
description: "loopback ffmpeg assemble worker"
needs:
  images: array
  output: string
gives:
  path: string
pii: false
approval: false
audit: true
output: json
runs: once
version: v1
owner: Alberto Valido Delgado
birth_date: "2026-08-28"
l7:
  capability: render
  data:
    pii: non_pii
    source: internal
    shape: record
    freshness: live
  policyIntent:
    mode: test
    risk: low
    requireApproval: false
    compliance: standard
  presentation:
    ui: card
    output: json
    density: compact
  orchestration:
    flow: single
    trigger: manual
    retry: none
  timeVersioning:
    toolVersion: v1
    schemaVersion: v1
    lifecycle: active
  identitySecurity:
    role: operator
    auth: token
    audit: on
