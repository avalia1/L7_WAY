#!/bin/zsh
# Quick toggle / summon for Daimon Bar
# Recommended hotkey: Cmd+Shift+D

BAR_PID=$(pgrep -f daimon-bar.py)

if [[ -n "$BAR_PID" ]]; then
    # Already running — bring it to front
    osascript -e 'tell application "Python" to activate' 2>/dev/null || true
else
    nohup python3 "$HOME/.l7/daimon-bar.py" >/dev/null 2>&1 &
fi
