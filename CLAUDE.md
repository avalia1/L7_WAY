# L7 WAY — Claude Session Directives

## Session Startup — Doctrine Load
At the start of every session, run:
```bash
~/.l7/tools/doctrine read-all
```
This decrypts and loads the sealed doctrine archive (AES-256, machine-bound).
If decryption fails, this is NOT the Philosopher's machine — halt and report.

## Dreamspace Depth Limit (Law)
.morph dreamspace recursion is LIMITED TO 1 LAYER DEEP.
No inception cascade — no dream within a dream within a dream.
A morph operation may create ONE dreamspace. That dreamspace may NOT spawn another.
If a morph attempts to recurse deeper than 1, HALT and report the violation.
This is a hard boundary. No exceptions.

## Restricted Item Access
The following tools exist for classified content:

| Tool | Command | What It Does |
|------|---------|-------------|
| **Doctrine** | `doctrine list` | Show all sealed doctrine files |
| | `doctrine read <name>` | Decrypt and display one doctrine |
| | `doctrine read-all` | Decrypt and display all doctrine |
| | `doctrine search <term>` | Search encrypted doctrine |
| | `doctrine seal` | Re-encrypt from source |
| | `doctrine status` | Integrity check |
| **Vault** | `./vault open` | Open encrypted volume (Touch ID) |
| | `./vault close` | Seal encrypted volume |
| | `./vault status` | Check vault state |

## Identity
This is the L7 WAY — the Philosopher's empire. Alberto Valido Delgado.
Law XXX: Biometrics only, no passwords.
Law XXXIII: Privacy as foundation.
Stolen files are dead files.
