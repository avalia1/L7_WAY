# L7 ATOMS — Fundamental Primitives

Every system in the empire decomposes into these atoms.
Every app recombines from these atoms through the Forge.
No atom exists in isolation. No app owns an atom exclusively.
Each app is an ashram — it borrows atoms for its session, returns them at exit.

---

## AUTH (6 atoms)

| Atom | Symbol | Weight | Used By |
|------|--------|--------|---------|
| fingerprint | A1 | required | wallet, sentinel, vault, config |
| face | A2 | required for config | config, vault |
| voice | A3 | required for config | config, vault |
| passphrase | A4 | required | wallet, sentinel |
| intent | A5 | continuous | all (behavioral model) |
| coercion-detect | A6 | continuous | all (ambient, silent) |

Combination rules:
- READ: A1 or A4 (one factor minimum)
- WRITE: A1 + A4 (dual factor)
- CONFIG: A1 + A2 + A3 + A5 + A6 (full triad + behavioral)
- LOCKDOWN: A1 + A4 + A6 (dual + coercion clear)

## SENSE (5 atoms)

| Atom | Symbol | Mode | Stores |
|------|--------|------|--------|
| camera-eye | S1 | ambient | ephemeral (RAM) |
| mic-ear | S2 | ambient | ephemeral (RAM) |
| process-watch | S3 | on-demand | ephemeral (RAM) |
| network-watch | S4 | on-demand | ephemeral (RAM) |
| permission-watch | S5 | on-demand | ephemeral (RAM) |

All SENSE atoms are READ-ONLY. They observe but do not persist.
Only the AUDIT atom records what SENSE atoms detect.

## MEMORY (4 atoms)

| Atom | Symbol | Lifetime | Access |
|------|--------|----------|--------|
| ephemeral | M1 | process lifetime | RAM only, no disk |
| permanent-log | M2 | forever | append-only, never deleted |
| encrypted-rest | M3 | until decrypted | hardware-bound, biometric |
| founder-kind | M4 | persistent | resurfaces context, anticipates need |

Rules:
- Scan results = M1 (ephemeral)
- Audit entries = M2 (permanent)
- Keys, secrets = M3 (encrypted at rest)
- Session history, morning briefs = M4 (kind memory)

## GATE (4 atoms)

| Atom | Symbol | Auth Level | Action |
|------|--------|------------|--------|
| read-gate | G1 | initial auth | observe, scan, display |
| write-gate | G2 | escalated re-auth | kill, modify, configure |
| config-gate | G3 | full triad | edit config files, system settings |
| emergency-gate | G4 | single biometric | lockdown only (break glass) |

## ENCODE (5 atoms)

| Atom | Symbol | Script | Base |
|------|--------|--------|------|
| aramaic | E1 | ancient Aramaic | consonantal |
| sumerian | E2 | cuneiform | logographic |
| greek | E3 | classical Greek | alphabetic |
| egyptian | E4 | hieroglyphic | pictographic |
| cyrillic | E5 | Cyrillic | alphabetic |

Encoding rule: data at rest is encoded through trigram-64 system.
Each 6-bit block maps to one of 64 hexagram symbols.
Display layer renders in the chosen ancient script.
Auto-decode on authenticated demand — transparent to Founder.

## NETWORK (3 atoms)

| Atom | Symbol | State | Allowed |
|------|--------|-------|---------|
| sealed | N1 | default | zero connections |
| local-import | N2 | manual | read from local file |
| kill-switch | N3 | emergency | disable Wi-Fi, flush DNS, kill conns |

No atom permits outgoing connections. Ever.

## ISOLATION (3 atoms)

| Atom | Symbol | Rule |
|------|--------|------|
| ashram | I1 | each app is self-contained |
| no-ipc | I2 | no inter-process communication |
| transparent-channel | I3 | if a channel exists, it is visible and auditable |

---

## RECOMBINATION TABLE

| App | AUTH | SENSE | MEMORY | GATE | ENCODE | NETWORK | ISOLATION |
|-----|------|-------|--------|------|--------|---------|-----------|
| Wallet | A1+A4 | - | M1+M2+M3 | G1+G2 | E1-E5 | N1+N2 | I1+I2+I3 |
| Sentinel | A1+A4 | S1-S5 | M1+M2 | G1+G2+G4 | - | N1+N3 | I1+I2+I3 |
| Vault | A1+A2+A3 | S1+S2 | M2+M3 | G3 | E1-E5 | N1 | I1+I2 |
| Config | A1+A2+A3+A5+A6 | S1+S2 | M2+M3 | G3 | E1-E5 | N1 | I1+I2 |
| Forge | A1+A4 | S3 | M1+M2+M4 | G1+G2 | - | N1 | I1+I3 |
| Canon | A1 | - | M2+M4 | G1 | - | N1 | I1+I2 |
| Gallery | A1 | - | M1+M4 | G1 | E1-E5 | N1 | I1+I2 |

---

## THE RECOMBINATION PRINCIPLE

Any new app is built by selecting atoms from each category.
The Forge assembles atoms into a functioning ashram.
No app can request atoms it hasn't declared.
No atom leaks between ashrams.
The Founder sees all atoms, all combinations, all channels.
