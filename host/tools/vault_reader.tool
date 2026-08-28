name: vault_reader
suite: Codex
tagline: "The Sealed Library"
does: read
server: l7-forge
mcp_tool: codex.vault_reader
description: "Unified reader for all classified content — doctrine (AES-256 encrypted, machine-bound), salt (immutable archive), vault (biometric-gated). Read-only. Fingerprint to enter. Nothing leaves."
needs:
  action: string
  target: string
gives:
  content: string
  metadata: object
  integrity: object
pii: false
approval: true
audit: true
output: text
runs: interactive
version: v1
icon: lock
color: "#10b981"
security:
  biometric: required
  biometric_types:
    - fingerprint
    - face
    - iris
  intent_verification: true
  hardware_signature: verified
  password_fallback: never
  encryption:
    algorithm: AES-256-CBC
    key_derivation: SHA-256(machine_UUID + DOCTRINE_SALT_42)
    key_source: hardware_bound
    key_rotation: 900s
    satellite_sync: true
    satellite_rotation: 3600s
  network:
    allowed: none
    traffic_verification: mandatory
    data_exfiltration: blocked
  execution:
    mode: lockdown
    data_in: blocked
    data_out: blocked
    vault_access: optional_reauth
  anti_debug: true
  anti_tamper: true
classification: restricted
access_tier: 2
domains_accessed:
  - salt
  - vault
  - doctrine
