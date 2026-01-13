#!/usr/bin/env bash
set -euo pipefail

APP_BUNDLE_ID="com.apple.TextEdit"

if ! command -v duti >/dev/null 2>&1; then
  if command -v brew >/dev/null 2>&1; then
    brew install duti
  else
    echo "duti is required but not installed. Install Homebrew or duti manually." >&2
    exit 1
  fi
fi

# Register .l7 extension and markdown UTI to TextEdit
# This keeps .l7 files openable by any text editor, with a safe default

duti -s "${APP_BUNDLE_ID}" .l7 all
# Associate Markdown UTI to improve rendering/preview defaults

duti -s "${APP_BUNDLE_ID}" net.daringfireball.markdown all

echo "Registered .l7 files to ${APP_BUNDLE_ID}."
