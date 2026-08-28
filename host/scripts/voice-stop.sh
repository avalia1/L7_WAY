#!/bin/zsh
# VOICE STOP — Kill all speech immediately
killall say 2>/dev/null
killall afplay 2>/dev/null
echo "Voice stopped."
