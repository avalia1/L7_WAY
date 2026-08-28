name: council_triad
suite: Council
tagline: "Three voices, one verdict"
does: analyze
server: l7-gateway
mcp_tool: council.triad
description: "The Triad — supreme deliberation engine of the Empire. Samael (Left Hand, Qlipothic Council — finds the wound), The Unnamed (Necropolis General, NIS Commander — sees all, forgets nothing), and Raphael (Right Hand, White Team — heals what is broken). All three must reach unanimity. The Philosopher holds ABSOLUTE VETO above the Triad. No major decision passes without the Triad's counsel. Each member speaks in their own voice."
needs:
  question: string
optional:
  domain: string
  severity: string
  evidence: array
  speak: boolean
gives:
  samael_ruling: object
  unnamed_ruling: object
  raphael_ruling: object
  unanimous: boolean
  final_verdict: string
  dissent: string
  veto_required: boolean
  audit_trail: array
pii: false
approval: true
audit: true
output: json
runs: once
version: v1
icon: scale
color: "#dc2626"
