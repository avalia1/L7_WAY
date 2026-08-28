name: beta
does: communicate
server: l7-gateway
description: Composition step B (fixture). Reads from A.
version: v1
needs:
  from: string
gives:
  from: string
l7:
  capability: communicate
  data: { pii: non_pii, source: internal, shape: record, freshness: live }
  policyIntent: { mode: test, risk: low, requireApproval: false, compliance: standard }
  presentation: { ui: card, output: json, density: compact }
  orchestration: { flow: single, trigger: manual, retry: none }
  timeVersioning: { toolVersion: v1, schemaVersion: v1, lifecycle: active }
  identitySecurity: { role: operator, auth: token, audit: on }
