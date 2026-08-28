name: echo
suite: Gateway
tagline: "Say it back"
does: communicate
server: "http://127.0.0.1:18792/"
mcp_tool: echo
description: "loopback echo worker"
needs:
  message: string
gives:
  message: string
pii: false
approval: false
audit: true
output: json
runs: once
version: v1
owner: Alberto Valido Delgado
birth_date: "2026-08-28"
l7:
  capability: communicate
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
