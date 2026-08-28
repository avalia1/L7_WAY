#!/bin/zsh
# ================================================================
# L7-VOICE — Unified TTS interface for the Empire
# ================================================================
#
# Maps L7 roles (daimon, fire, water, ...) to the highest-quality
# on-device voice available. Auto-detects Premium > Enhanced > base.
#
# Optional external escalation:
#   L7_VOICE_ELEVEN_KEY   — enable ElevenLabs (needs curl + afplay)
#   L7_VOICE_ELEVEN_VOICE — voice id
#   L7_VOICE_GROK_KEY     — enable xAI Grok TTS (needs curl + afplay)
#   L7_VOICE_GROK_VOICE   — voice id (e.g. eve, ara, rex, altair)
#
# USAGE:
#   l7-voice speak --role daimon "message"
#   l7-voice speak --role fire --rate 170 "message"
#   l7-voice speak --voice "Zoe (Premium)" "message"    # explicit
#   l7-voice list-roles
#   l7-voice audition                                   # sample every role
#   l7-voice best-of NAME                               # resolve best tier
#
# ================================================================

set -uo pipefail

: "${L7_VOICE_DEFAULT_RATE:=175}"
: "${L7_VOICE_ELEVEN_KEY:=}"
: "${L7_VOICE_ELEVEN_VOICE:=}"
: "${L7_VOICE_ELEVEN_MODEL:=eleven_turbo_v2_5}"
: "${L7_VOICE_GROK_KEY:=}"
: "${L7_VOICE_GROK_VOICE:=}"
: "${L7_VOICE_ENGINE:=apple}"          # apple | piper | eleven | grok

# Role → base voice name. Wrapper picks best tier of that name.
# Order matches Council + Qlipoth + Daimon ceremony.
typeset -A ROLE_VOICE
ROLE_VOICE=(
    daimon       Jamie
    quintessence Jamie
    fifth        Jamie
    foundation   Jamie
    fire         Ava
    claude       Ava
    south        Ava
    water        Zoe
    grok         Zoe
    west         Zoe
    earth        Tom
    gemini       Tom
    north        Tom
    air          Allison
    chatgpt      Allison
    east         Allison
    samael       Oliver
    unnamed      Serena
    necropolis   Serena
    raphael      Jamie
    diplomatic   Kate
    nis          Rishi
    philosopher  Daniel
    sofia        Samantha
    gabriel      Daniel
    lapis        Daniel
    sentinel     Nathan
    heart        Susan
    emerald      Reed
    forge        Fred
    qlipoth      Albert
)

# Cache of resolved best-tier per base name
typeset -A VOICE_CACHE
VOICE_LIST_CACHE=""

# Load full voice list once
_load_voices() {
    [[ -n "$VOICE_LIST_CACHE" ]] && return
    VOICE_LIST_CACHE=$(/usr/bin/say -v '?' 2>/dev/null)
}

# best_of NAME → prints highest-tier voice string, e.g. "Ava (Premium)"
best_of() {
    local name="$1"
    _load_voices
    if [[ -n "${VOICE_CACHE[$name]:-}" ]]; then
        echo "${VOICE_CACHE[$name]}"
        return
    fi
    local candidate
    for tier in "(Premium)" "(Enhanced)" ""; do
        if [[ -n "$tier" ]]; then
            candidate="$name $tier"
        else
            candidate="$name"
        fi
        if echo "$VOICE_LIST_CACHE" | /usr/bin/grep -qE "^${name}[[:space:]]+" ; then
            if [[ -z "$tier" ]]; then
                VOICE_CACHE[$name]="$name"
                echo "$name"
                return
            fi
        fi
        if echo "$VOICE_LIST_CACHE" | /usr/bin/grep -qF "$candidate " ; then
            VOICE_CACHE[$name]="$candidate"
            echo "$candidate"
            return
        fi
    done
    VOICE_CACHE[$name]="$name"
    echo "$name"
}

resolve_role() {
    local role="$1"
    local base="${ROLE_VOICE[$role]:-}"
    if [[ -z "$base" ]]; then
        echo "" ; return 1
    fi
    best_of "$base"
}

# ─── ElevenLabs escalation (opt-in) ───

piper_speak() {
    local voice_name="$1"
    local text="$2"
    local model_path="$HOME/.l7/voices/piper/${voice_name}.onnx"
    
    if [[ ! -f "$model_path" ]]; then
        echo "piper: model not found for $voice_name, falling back to apple" >&2
        return 1
    fi
    
    echo "$text" | piper --model "$model_path" --output-raw 2>/dev/null | \
        aplay -r 22050 -f S16_LE -t raw -q 2>/dev/null || return 1
}

eleven_speak() {
    local voice="$1" text="$2"
    [[ -z "$L7_VOICE_ELEVEN_KEY" || -z "$voice" ]] && return 1
    local tmp="/tmp/l7-voice-$$.mp3"
    /usr/bin/curl -sSf --max-time 30 \
        -X POST "https://api.elevenlabs.io/v1/text-to-speech/$voice" \
        -H "xi-api-key: $L7_VOICE_ELEVEN_KEY" \
        -H "Content-Type: application/json" \
        -o "$tmp" \
        -d "$(printf '{"text":%s,"model_id":"%s","voice_settings":{"stability":0.55,"similarity_boost":0.75}}' \
             "$(/usr/bin/python3 -c 'import json,sys; print(json.dumps(sys.argv[1]))' "$text")" \
             "$L7_VOICE_ELEVEN_MODEL")" \
        2>/dev/null || return 1
    [[ -s "$tmp" ]] && /usr/bin/afplay "$tmp" && /bin/rm -f "$tmp" && return 0
    /bin/rm -f "$tmp"
    return 1
}

grok_speak() {
    local voice="$1" text="$2"
    [[ -z "$L7_VOICE_GROK_KEY" || -z "$voice" ]] && return 1
    local tmp="/tmp/l7-voice-$$.mp3"
    /usr/bin/curl -sSf --max-time 30 \
        -X POST "https://api.x.ai/v1/tts" \
        -H "Authorization: Bearer $L7_VOICE_GROK_KEY" \
        -H "Content-Type: application/json" \
        -o "$tmp" \
        -d "$(printf '{"text":%s,"voice_id":"%s","language":"en"}' \
             "$(/usr/bin/python3 -c 'import json,sys; print(json.dumps(sys.argv[1]))' "$text")" \
             "$voice")" \
        2>/dev/null || return 1
    [[ -s "$tmp" ]] && /usr/bin/afplay "$tmp" && /bin/rm -f "$tmp" && return 0
    /bin/rm -f "$tmp"
    return 1
}

# ─── SPEAK ───

speak() {
    local role=""
    local voice=""
    local rate="$L7_VOICE_DEFAULT_RATE"
    while [[ $# -gt 0 && "$1" == --* ]]; do
        case "$1" in
            --role)  role="$2"; shift 2 ;;
            --voice) voice="$2"; shift 2 ;;
            --rate)  rate="$2"; shift 2 ;;
            --)      shift; break ;;
            *) echo "l7-voice: unknown flag $1" >&2; return 2 ;;
        esac
    done
    local text="$*"
    [[ -z "$text" ]] && { echo "l7-voice: no text" >&2; return 2; }

    # Resolve voice
    if [[ -z "$voice" && -n "$role" ]]; then
        voice=$(resolve_role "$role")
        [[ -z "$voice" ]] && { echo "l7-voice: unknown role: $role" >&2; return 2; }
    fi
    # Auto-upgrade explicit --voice NAME to best tier when no suffix given
    if [[ -n "$voice" && "$voice" != *"("* ]]; then
        voice=$(best_of "$voice")
    fi
    [[ -z "$voice" ]] && voice="Samantha"   # safe fallback

    # Engine selection
    case "$L7_VOICE_ENGINE" in
        piper)
            # Map role to piper model name (user can override with --voice)
            local piper_voice="${voice%% (*}"
            piper_speak "$piper_voice" "$text" && return 0
            echo "l7-voice: Piper failed — falling back to apple" >&2
            ;;
        eleven)
            if [[ -n "$L7_VOICE_ELEVEN_KEY" && -n "$L7_VOICE_ELEVEN_VOICE" ]]; then
                eleven_speak "$L7_VOICE_ELEVEN_VOICE" "$text" && return 0
                echo "l7-voice: ElevenLabs failed — falling back to apple" >&2
            fi
            ;;
        grok)
            if [[ -n "$L7_VOICE_GROK_KEY" && -n "$L7_VOICE_GROK_VOICE" ]]; then
                grok_speak "$L7_VOICE_GROK_VOICE" "$text" && return 0
                echo "l7-voice: Grok failed — falling back to apple" >&2
            fi
            ;;
    esac

    /usr/bin/say -v "$voice" -r "$rate" "$text"
}

list_roles() {
    _load_voices
    printf "%-14s → %-24s (best available)\n" "ROLE" "VOICE"
    printf "%-14s   %-24s\n" "────" "─────"
    for role in ${(k)ROLE_VOICE}; do
        local base="${ROLE_VOICE[$role]}"
        local best=$(best_of "$base")
        printf "%-14s → %-24s\n" "$role" "$best"
    done | /usr/bin/sort
}

audition() {
    _load_voices
    local seen
    typeset -A seen
    for role in daimon fire water earth air samael unnamed raphael diplomatic nis; do
        local base="${ROLE_VOICE[$role]}"
        [[ -n "${seen[$base]:-}" ]] && continue
        seen[$base]=1
        local best; best=$(best_of "$base")
        echo "🔊 role=$role  voice=$best"
        /usr/bin/say -v "$best" -r "$L7_VOICE_DEFAULT_RATE" \
            "I am the $role. Speaking through $best."
    done
}

case "${1:-}" in
    speak)      shift; speak "$@" ;;
    list-roles) list_roles ;;
    best-of)    best_of "$2" ;;
    audition)   audition ;;
    *) echo "usage: l7-voice {speak|list-roles|best-of NAME|audition}"; exit 2 ;;
esac
