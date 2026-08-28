#!/usr/bin/env bash
# L7 gateway — Node control plane only.
# No Tailscale, no SSH, no workers, no forge.
# Health: GET http://127.0.0.1:18793/health
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck disable=SC1091
. "${SCRIPT_DIR}/_env.sh"
l7_load_env

cd "$L7_ROOT"

echo "run-gateway: Node control plane on ${L7_BIND}:${L7_PORT}"
echo "run-gateway: this is the gateway. Founder Loop is scripts/run-founder-loop.sh"

if command -v npm >/dev/null 2>&1 && [ -f package.json ]; then
  exec npm start
fi
exec node serve.js
