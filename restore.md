# L7 WAY — Session Restoration Script

## What It Does

The `restore` script is a session preservation mechanism for the L7 Forge. It solves the problem of continuity across Claude Code conversations: when a conversation ends, the context is lost. This script captures the current state of the L7 project so that the next conversation can pick up where the last one left off.

Specifically, it does three things:

1. **Verifies file integrity.** It checks that all critical L7 files exist on disk — the Laws, the Rose, the Keykeeper, the Vault, the Empire server, the Gateway, the tools directory, and the publications. It reports each file's size and last modification date, flags anything missing, and distinguishes between critical failures and files that simply have not been created yet (like ARCHITECTURE_FULL.md).

2. **Generates a SESSION_STATE.md file.** This file is written to the Claude Code memory directory (`~/.claude/projects/-Users-rnir-hrc-avd/memory/SESSION_STATE.md`), which is automatically read by Claude Code at the start of every new conversation in this project. The file contains:
   - Instructions telling the Forge how to re-initialize itself
   - The current state of the project (Laws declared, files created, pending work)
   - The Philosopher's standing instructions and corrections
   - A timestamped file integrity report
   - Boot commands for the Empire, Universal XR, Living Rose, and Vault
   - Git commit history for traceability

3. **Updates MEMORY.md.** If the memory file does not already reference SESSION_STATE.md, the script appends a cross-reference so that Claude Code knows to look for the session state file.

## How To Use It

Run it from anywhere:

```bash
~/Backup/L7_WAY/restore
```

Or from the L7 directory:

```bash
cd ~/Backup/L7_WAY
./restore
```

Run it **before closing a session** to save the current state, or **before starting a new session** to verify that everything is intact.

The script requires no external dependencies. It uses only standard Unix tools (`stat`, `find`, `grep`, `date`, `cat`, `chmod`) that ship with macOS.

## What the Output Looks Like

The script prints a color-coded report to the terminal:

- **[OK]** in green means the file exists, with its size and modification date
- **[--]** in yellow means the file is optional and has not been created yet
- **[!!]** in red means a critical file is missing

At the bottom, it prints a summary and the path to the generated SESSION_STATE.md file.

## When To Run It

- After a long working session where new Laws, files, or tools were created
- Before starting a new Claude Code conversation about L7
- After moving files or changing the directory structure
- As a sanity check to make sure nothing is missing

## Files It Reads

It does not read file contents. It only checks whether files and directories exist, and records their size and modification timestamp.

## Files It Writes

- `~/.claude/projects/-Users-rnir-hrc-avd/memory/SESSION_STATE.md` — overwritten each time
- `~/.claude/projects/-Users-rnir-hrc-avd/memory/MEMORY.md` — appended to (only once, idempotent)

## Exit Codes

- `0` — all critical files present
- `1` — one or more critical files missing
