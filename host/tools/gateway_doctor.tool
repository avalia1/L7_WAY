name: gateway_doctor
suite: Gateway
tagline: "Physician, heal thyself"
does: analyze
server: l7-gateway
mcp_tool: gateway.doctor
description: "System diagnostics and health check for the entire L7 Empire. Inspects all ashrams, validates tool schemas, checks server availability, audits atom declarations, verifies binary integrity, reviews sentinel logs, and reports on the state of every domain (.morph, .work, .salt, .vault). Includes deep audit mode for security review and auto-fix for known issues. The Empire's immune system made visible."
needs:
  action: string
optional:
  deep: boolean
  fix: boolean
  scope: string
  ashram: string
gives:
  status: string
  ashrams: array
  tools_valid: number
  tools_invalid: number
  servers_reachable: array
  warnings: array
  errors: array
  recommendations: array
  audit_hash: string
pii: false
approval: false
audit: true
output: json
runs: once
version: v1
icon: stethoscope
color: "#22c55e"
owner: Alberto Valido Delgado
birth_date: "2026-08-28"
l7:
  capability: analyze
  data:
    pii: non_pii
    source: internal
    shape: summary
    freshness: live
  policyIntent:
    mode: live
    risk: low
    requireApproval: false
    compliance: standard
  presentation:
    ui: table
    output: json
    density: detailed
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
