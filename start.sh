#!/usr/bin/env bash
# Founder convenience. This is not the architecture.
#   Gateway:      scripts/run-gateway.sh  (or npm start)
#   Founder Loop: scripts/run-founder-loop.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
GW_PID=""

cleanup() {
  if [ -n "${GW_PID}" ]; then
    kill "${GW_PID}" 2>/dev/null || true
    wait "${GW_PID}" 2>/dev/null || true
  fi
}
trap cleanup EXIT INT TERM

echo "start.sh: convenience wrapper — gateway then founder-loop"
"${ROOT}/scripts/run-gateway.sh" &
GW_PID=$!
"${ROOT}/scripts/run-founder-loop.sh"
wait "${GW_PID}"
