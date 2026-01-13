# Empire (Lightweight .l7 IDE)

Empire is a split-view workflow: terminal on one side, browser on the other. It renders `.l7` citizens in a minimal UI.

## Start
```bash
/Users/alberto_work/L7_WAY/empire/empire.sh
```

## Notes
- Uses Node.js for a tiny local server on port `7377` (override with `EMPIRE_PORT`).
- If `tmux` is installed, it opens a split session (CLI + server).
- Without `tmux`, it starts the server and drops you into a shell.
