#!/bin/zsh
# ================================================================
# L7-CALL-SPEAK — routes l7-voice TTS through BlackHole 2ch
# ================================================================
#
# For the outbound Google Voice call pipeline: plays text through
# BlackHole instead of the real speakers, so Chrome (with BlackHole
# selected as its mic input on voice.google.com) picks it up as
# call audio. Restores the previous output device when done, even
# on failure — never leaves system audio stuck routed into a black
# hole.
#
# USAGE:
#   l7-call-speak.sh "text to speak"
#
# Requires L7_VOICE_ENGINE=eleven and L7_VOICE_ELEVEN_KEY/_VOICE set
# (see ~/.l7/l7-voice.sh header) — falls back to macOS `say` through
# BlackHole otherwise, which still works for testing the audio path.
# ================================================================

set -uo pipefail

BLACKHOLE="BlackHole 2ch"
SWITCH="/opt/homebrew/bin/SwitchAudioSource"
VOICE_SCRIPT="$HOME/.l7/l7-voice.sh"

[[ $# -eq 0 ]] && { echo "usage: l7-call-speak.sh \"text\"" >&2; exit 2; }

if ! "$SWITCH" -a | grep -qF "$BLACKHOLE"; then
    echo "l7-call-speak: BlackHole 2ch not found — is it installed and registered?" >&2
    exit 1
fi

ORIG_OUTPUT=$("$SWITCH" -c -t output)

cleanup() {
    "$SWITCH" -t output -s "$ORIG_OUTPUT" >/dev/null
}
trap cleanup EXIT

"$SWITCH" -t output -s "$BLACKHOLE" >/dev/null
"$VOICE_SCRIPT" speak "$@"
