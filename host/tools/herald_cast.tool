name: herald_cast
suite: Herald
tagline: "One message, every channel"
does: communicate
server: l7-media
mcp_tool: herald.broadcast
description: "Multi-channel broadcasting. Adapts content for each destination — email, Slack, SMS, push notification, RSS — from a single source of truth."
needs:
  content: object
  channels: array
  audience: string
gives:
  delivery_report: array
  reach: number
  failures: array
pii: false
approval: true
audit: true
output: json
runs: once
version: v1
icon: megaphone
color: "#ec4899"
owner: Alberto Valido Delgado
birth_date: "2026-08-28"
l7:
  capability: communicate
  data:
    pii: non_pii
    source: mixed
    shape: list
    freshness: live
  policyIntent:
    mode: live
    risk: medium
    requireApproval: true
    compliance: standard
  presentation:
    ui: card
    output: json
    density: standard
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
