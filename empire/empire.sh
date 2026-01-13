#!/usr/bin/env bash
set -euo pipefail

PORT="${EMPIRE_PORT:-7377}"
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

open "http://localhost:${PORT}" >/dev/null 2>&1 || true

if command -v tmux >/dev/null 2>&1; then
  tmux new-session -d -s empire "$SHELL"
  tmux split-window -h -t empire "EMPIRE_PORT=${PORT} node ${BASE_DIR}/server.js"
  tmux attach -t empire
else
  echo "tmux not found; starting server in background."
  EMPIRE_PORT="${PORT}" node "${BASE_DIR}/server.js" &
  SERVER_PID=$!
  echo "Empire server running at http://localhost:${PORT}"
  echo "Open another terminal for CLI usage, or install tmux for split view."
  trap 'kill ${SERVER_PID}' EXIT
  exec "$SHELL"
fi
