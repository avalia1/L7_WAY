#!/usr/bin/env bash
# Install L7_WAY host/ sources into the Mac prefix (~/.l7 by default).
# Prefix is install-only: binaries, copied tools, state, logs, secrets.
# Does not copy secrets or Mach-O. Does not compile Swift (dispatcher compiles on first use).
set -euo pipefail

HOST="$(cd "$(dirname "$0")" && pwd)"
L7_WAY="$(cd "$HOST/.." && pwd)"
PREFIX="${L7_PREFIX:-$HOME/.l7}"

mkdir -p "$PREFIX/state" "$PREFIX/canon" "$PREFIX/wallet" "$PREFIX/sentinel"
chmod 700 "$PREFIX/wallet" "$PREFIX/sentinel"

rsync_tree() {
  local name="$1"
  [ -d "$HOST/$name" ] || return 0
  mkdir -p "$PREFIX/$name"
  rsync -a \
    --exclude 'secrets/' \
    --exclude 'audit.log' \
    --exclude '*.pid' \
    "$HOST/$name/" "$PREFIX/$name/"
}

rsync_tree tools
rsync_tree flows
rsync_tree skills
rsync_tree programs

install -m 755 "$HOST/l7" "$PREFIX/l7"
printf '%s\n' "$L7_WAY" > "$PREFIX/L7_WAY_ROOT"

echo "Installed L7 prefix $PREFIX from $L7_WAY (l7 gateway = Node :18793)"
