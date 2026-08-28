#!/usr/bin/env bash
# Shared operator env for gateway and founder-loop.
# Loads files if present. Never prints values (secrets stay off the console).
# shellcheck shell=bash

L7_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
: "${L7_VAULT_MOUNT:=/Volumes/L7_VAULT}"
: "${L7_PORT:=18793}"
: "${L7_BIND:=127.0.0.1}"

l7_load_env_file() {
  local f="$1"
  [ -f "$f" ] || return 0
  set +eu
  set -a
  # shellcheck disable=SC1090
  . "$f"
  set +a
  set -eu
  echo "l7-env: loaded $(basename "$f")" >&2
}

# Vault first (if already mounted — do not run ./vault open).
# Then repo .env / .env.local so local overrides win.
l7_load_env() {
  l7_load_env_file "${L7_VAULT_MOUNT}/.env"
  l7_load_env_file "${L7_VAULT_MOUNT}/.env.local"
  l7_load_env_file "${L7_ROOT}/.env"
  l7_load_env_file "${L7_ROOT}/.env.local"
  export L7_PORT="${L7_PORT:-18793}"
  export L7_BIND="${L7_BIND:-127.0.0.1}"
}

l7_gateway_base() {
  echo "http://127.0.0.1:${L7_PORT}"
}

# Health: /health (serve.js) or /v1/tools (if a later contract adds it).
l7_gateway_healthy() {
  local base
  base="$(l7_gateway_base)"
  curl -sf "${base}/health" >/dev/null 2>&1 && return 0
  curl -sf "${base}/v1/tools" >/dev/null 2>&1 && return 0
  return 1
}
