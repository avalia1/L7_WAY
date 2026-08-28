# host/ — versioned Mac sources

**L7_WAY is the project.** `~/.l7` is the prefix: binaries, copied tools, state, logs, and secrets. Install with `./host/install.sh`. After install, the dispatcher (`$PREFIX/l7`) compiles Swift from this tree on first use.

## Commands

| Command | What it is |
|---|---|
| `l7 gateway` | Node control plane on `127.0.0.1:18793` (`scripts/run-gateway.sh` / `npm start`) |
| `l7 egress` | Swift pf / Touch ID valve, compiled from `host/swift/l7-gateway.swift` into `~/.l7/l7-egress` |

`l7 claw` is an alias of `l7 egress`, not of the Node gateway.

## Install

```bash
./host/install.sh
```

Default prefix is `$HOME/.l7` (override with `L7_PREFIX`). The installer writes the repo path to `$PREFIX/L7_WAY_ROOT`, copies `tools/`, `flows/`, `skills/`, and `programs/`, and installs `host/l7` as `$PREFIX/l7`. It does not compile Swift.

## Not in git

Secrets, `audit.log`, Mach-O binaries, and `*.pid` stay in the prefix. They are never imported.
