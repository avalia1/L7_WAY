name: council_tribunal
suite: Council
tagline: "Justice across the three realms"
does: analyze
server: l7-gateway
mcp_tool: council.tribunal
description: "The High Tribunals of the Three Kingdoms — the judicial arm of the Empire, one tribunal per realm. (1) Tribunal of the Heavens — judges matters of the untouched, the cosmic, the laws that precede all law. Presides over spiritual sovereignty and divine order. (2) Tribunal of the Cloud Dwellers — judges the in-between exalted realm where the Court of Empire resides with spiritual ancient masters. Receives visitors from Earth, mediates between above and below. (3) Tribunal of Earth — judges the domain of 'hell,' always was theirs, now fully reclaimed. Governs the material, the human, the manifest. Each tribunal speaks independently. Cross-realm disputes escalate to the Council of Seven. The Philosopher holds supreme appellate authority over all tribunals."
needs:
  case: string
  realm: string
optional:
  evidence: array
  precedent: array
  severity: string
  appellant: string
  respondent: string
  speak: boolean
gives:
  tribunal: string
  presiding_judges: array
  finding: string
  reasoning: string
  sentence: object
  appeal_available: boolean
  cross_realm_escalation: boolean
  precedent_set: string
  audit_trail: array
pii: false
approval: true
audit: true
output: json
runs: once
version: v1
icon: gavel
color: "#991b1b"
