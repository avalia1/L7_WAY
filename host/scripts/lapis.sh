#!/bin/zsh
# ================================================================
# LAPIS — The Ascribe and Stone (Law LXXI)
# ================================================================
#
# The sole writer, signer, verifier, and executor of code
# under the seal of Empire.
#
# "If Lapis didn't write it, it doesn't run or substitute."
#
# USAGE:
#   lapis sign <file>              Sign code with Lapis's seal
#   lapis verify <file>            Verify signature before execution
#   lapis execute <file> [args]    Verify + execute
#   lapis substitute <old> <new>   Verified code replacement
#   lapis audit                    Show all signed works
#   lapis unsign-check             Find unsigned Empire code
#   lapis status                   Lapis status report
#
# ================================================================

set -uo pipefail

L7="${L7_DIR:-$HOME/.l7}"
LAPIS_DIR="$L7/lapis"
LAPIS_SIGS="$LAPIS_DIR/signatures.jsonl"
LAPIS_KEY="$LAPIS_DIR/.lapis-key"
LEDGER="$L7/ledger.sh"
PROVENANCE="$L7/provenance.sh"

mkdir -p "$LAPIS_DIR"
chmod 700 "$LAPIS_DIR"

# ─── Key Management ───

init_key() {
    if [[ ! -f "$LAPIS_KEY" ]]; then
        # Machine-bound key: SHA-256(machine_UUID + "LAPIS_PHILOSOPHORUM" + creation_time)
        local uuid=$(ioreg -rd1 -c IOPlatformExpertDevice 2>/dev/null | awk '/IOPlatformUUID/{gsub("\"",""); print $3}')
        local seed="${uuid}:LAPIS_PHILOSOPHORUM:$(date -u +%s)"
        echo -n "$seed" | shasum -a 256 | cut -d' ' -f1 > "$LAPIS_KEY"
        chmod 400 "$LAPIS_KEY"
        echo "LAPIS: Key forged. Machine-bound. Immutable."
    fi
}

get_key() {
    init_key
    cat "$LAPIS_KEY"
}

# ─── Signing ───

compute_hash() {
    shasum -a 256 "$1" 2>/dev/null | cut -d' ' -f1
}

compute_signature() {
    local file_hash="$1"
    local timestamp="$2"
    local key=$(get_key)
    # HMAC-SHA256: sign(key, hash + timestamp)
    echo -n "${key}:${file_hash}:${timestamp}" | shasum -a 256 | cut -d' ' -f1
}

timestamp() {
    date -u +%Y-%m-%dT%H:%M:%SZ
}

# ─── SIGN — Seal code with Lapis's mark ───

cmd_sign() {
    local file="$1"

    if [[ ! -f "$file" ]]; then
        echo "LAPIS ERROR: File not found: $file"
        return 1
    fi

    local filepath=$(realpath "$file")
    local filename=$(basename "$file")
    local file_hash=$(compute_hash "$file")
    local ts=$(timestamp)
    local signature=$(compute_signature "$file_hash" "$ts")
    local size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)

    # Record signature
    local record=$(python3 -c "
import json
r = {
    'filepath': '$filepath',
    'filename': '$filename',
    'hash': '$file_hash',
    'signature': '$signature',
    'signed_at': '$ts',
    'size': $size,
    'signer': 'LAPIS',
    'status': 'SEALED'
}
print(json.dumps(r))
")
    echo "$record" >> "$LAPIS_SIGS"

    echo "📜 LAPIS SEALED: $filename"
    echo "   Hash:      ${file_hash:0:16}..."
    echo "   Signature: ${signature:0:16}..."
    echo "   Sealed at: $ts"
}

# ─── VERIFY — Check Lapis's seal on a file ───

cmd_verify() {
    local file="$1"

    if [[ ! -f "$file" ]]; then
        echo "LAPIS ERROR: File not found: $file"
        return 1
    fi

    local filepath=$(realpath "$file")
    local current_hash=$(compute_hash "$file")

    # Find the latest signature for this file
    local sig_record=$(grep "\"filepath\": \"$filepath\"" "$LAPIS_SIGS" 2>/dev/null | tail -1)

    if [[ -z "$sig_record" ]]; then
        echo "⚠ UNSIGNED: $file has NO Lapis seal."
        echo "  This code MUST NOT execute under Law LXXI."
        return 1
    fi

    local stored_hash=$(echo "$sig_record" | python3 -c "import json,sys; print(json.load(sys.stdin)['hash'])")
    local stored_sig=$(echo "$sig_record" | python3 -c "import json,sys; print(json.load(sys.stdin)['signature'])")
    local stored_time=$(echo "$sig_record" | python3 -c "import json,sys; print(json.load(sys.stdin)['signed_at'])")

    # Recompute expected signature
    local expected_sig=$(compute_signature "$stored_hash" "$stored_time")

    # Check 1: Signature authenticity
    if [[ "$stored_sig" != "$expected_sig" ]]; then
        echo "✗ FORGED SIGNATURE: $file"
        echo "  The signature does not match Lapis's key."
        echo "  EXECUTION BLOCKED."
        return 1
    fi

    # Check 2: File integrity
    if [[ "$current_hash" != "$stored_hash" ]]; then
        echo "✗ TAMPERED: $file"
        echo "  Code has been modified since Lapis signed it."
        echo "  Original hash: ${stored_hash:0:16}..."
        echo "  Current hash:  ${current_hash:0:16}..."
        echo "  EXECUTION BLOCKED. Re-sign required."
        return 1
    fi

    echo "✓ VERIFIED: $file"
    echo "  Signature: ${stored_sig:0:16}..."
    echo "  Signed at: $stored_time"
    echo "  Integrity: INTACT"
    return 0
}

# ─── EXECUTE — Verify then run ───

cmd_execute() {
    local file="$1"
    shift

    echo "LAPIS: Verifying before execution..."
    if ! cmd_verify "$file"; then
        echo ""
        echo "LAPIS: EXECUTION DENIED. Seal verification failed."
        return 1
    fi

    echo ""
    echo "LAPIS: Seal verified. Executing..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # Determine execution method by extension
    local ext="${file##*.}"
    case "$ext" in
        sh)
            zsh "$file" "$@"
            ;;
        py)
            python3 "$file" "$@"
            ;;
        swift)
            swift "$file" "$@"
            ;;
        js)
            node "$file" "$@"
            ;;
        *)
            # Try direct execution if executable
            if [[ -x "$file" ]]; then
                "$file" "$@"
            else
                echo "LAPIS: Unknown file type and not executable: $ext"
                return 1
            fi
            ;;
    esac
}

# ─── SUBSTITUTE — Verified code replacement ───

cmd_substitute() {
    local old_file="$1"
    local new_file="$2"

    echo "LAPIS: Substitution request..."
    echo "  Old: $old_file"
    echo "  New: $new_file"
    echo ""

    # Verify the old file has Lapis's seal
    echo "▸ Verifying OLD code..."
    local old_path=$(realpath "$old_file" 2>/dev/null)
    local old_signed=$(grep "\"filepath\": \"$old_path\"" "$LAPIS_SIGS" 2>/dev/null | tail -1)
    if [[ -z "$old_signed" ]]; then
        echo "  ⚠ Old file is UNSIGNED. Proceeding as legacy replacement."
    else
        echo "  ✓ Old file has Lapis seal."
    fi

    # Verify the new file has Lapis's seal
    echo "▸ Verifying NEW code..."
    if ! cmd_verify "$new_file"; then
        echo ""
        echo "LAPIS: SUBSTITUTION DENIED."
        echo "  New code must be signed by Lapis before it can replace old code."
        return 1
    fi

    # Perform substitution
    local backup="${old_file}.pre-substitution.$(date +%s)"
    cp "$old_file" "$backup"
    cp "$new_file" "$old_file"

    # Re-sign the file at its new location
    cmd_sign "$old_file"

    echo ""
    echo "LAPIS: Substitution complete."
    echo "  Backup:  $backup"
    echo "  Current: $old_file (re-sealed)"
}

# ─── AUDIT — Show all signed works ───

cmd_audit() {
    echo "╔══════════════════════════════════════════════════════╗"
    echo "║     LAPIS — SIGNED WORKS AUDIT                      ║"
    echo "║     Law LXXI — The Ascribe and Stone                ║"
    echo "╚══════════════════════════════════════════════════════╝"
    echo ""

    if [[ ! -s "$LAPIS_SIGS" ]]; then
        echo "  No signed works yet."
        return 0
    fi

    local total=$(wc -l < "$LAPIS_SIGS" | tr -d ' ')
    echo "  Total signatures: $total"
    echo ""
    echo "  SIGNED WORKS:"
    echo "  ─────────────────────────────────────────"

    cat "$LAPIS_SIGS" | while read -r line; do
        local name=$(echo "$line" | python3 -c "import json,sys; print(json.load(sys.stdin)['filename'])" 2>/dev/null)
        local sig=$(echo "$line" | python3 -c "import json,sys; print(json.load(sys.stdin)['signature'][:16])" 2>/dev/null)
        local ts=$(echo "$line" | python3 -c "import json,sys; print(json.load(sys.stdin)['signed_at'])" 2>/dev/null)
        local st=$(echo "$line" | python3 -c "import json,sys; print(json.load(sys.stdin)['status'])" 2>/dev/null)
        echo "  [$st] $name — sig:${sig}... ($ts)"
    done
}

# ─── UNSIGN-CHECK — Find unsigned Empire code ───

cmd_unsign_check() {
    echo "LAPIS: Scanning for unsigned Empire code..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    local unsigned=0

    # Check all executable scripts
    for f in "$L7/"*.sh "$L7/council/"*.py; do
        [[ -f "$f" ]] || continue
        local filepath=$(realpath "$f")
        if ! grep -q "\"filepath\": \"$filepath\"" "$LAPIS_SIGS" 2>/dev/null; then
            echo "  ⚠ UNSIGNED: $(basename "$f")"
            unsigned=$((unsigned + 1))
        else
            echo "  ✓ SEALED:   $(basename "$f")"
        fi
    done

    # Check Swift sources
    for f in "$L7/"*.swift; do
        [[ -f "$f" ]] || continue
        local filepath=$(realpath "$f")
        if ! grep -q "\"filepath\": \"$filepath\"" "$LAPIS_SIGS" 2>/dev/null; then
            echo "  ⚠ UNSIGNED: $(basename "$f")"
            unsigned=$((unsigned + 1))
        else
            echo "  ✓ SEALED:   $(basename "$f")"
        fi
    done

    # Check compiled binaries
    for f in "$L7/l7-forge" "$L7/l7-canon" "$L7/l7-gallery" "$L7/l7-bibliotheca" "$L7/l7-wallet" "$L7/l7"; do
        [[ -f "$f" ]] || continue
        local filepath=$(realpath "$f")
        if ! grep -q "\"filepath\": \"$filepath\"" "$LAPIS_SIGS" 2>/dev/null; then
            echo "  ⚠ UNSIGNED: $(basename "$f")"
            unsigned=$((unsigned + 1))
        else
            echo "  ✓ SEALED:   $(basename "$f")"
        fi
    done

    echo ""
    echo "  Unsigned: $unsigned"
    if [[ $unsigned -gt 0 ]]; then
        echo "  ⚠ These files must be signed by Lapis before execution."
    else
        echo "  ✓ All Empire code bears Lapis's seal."
    fi
}

# ─── SIGN-ALL — Retroactive signing of all Empire code ───

cmd_sign_all() {
    echo "LAPIS: Retroactive signing of all Empire code..."
    echo "By authority of the Philosopher (Law LXXI)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    local count=0

    # Scripts
    for f in "$L7/"*.sh; do
        [[ -f "$f" ]] || continue
        local filepath=$(realpath "$f")
        if ! grep -q "\"filepath\": \"$filepath\"" "$LAPIS_SIGS" 2>/dev/null; then
            cmd_sign "$f"
            count=$((count + 1))
        fi
    done

    # Python
    for f in "$L7/council/"*.py "$L7/library/"*.py; do
        [[ -f "$f" ]] || continue
        local filepath=$(realpath "$f")
        if ! grep -q "\"filepath\": \"$filepath\"" "$LAPIS_SIGS" 2>/dev/null; then
            cmd_sign "$f"
            count=$((count + 1))
        fi
    done

    # Swift sources
    for f in "$L7/"*.swift; do
        [[ -f "$f" ]] || continue
        local filepath=$(realpath "$f")
        if ! grep -q "\"filepath\": \"$filepath\"" "$LAPIS_SIGS" 2>/dev/null; then
            cmd_sign "$f"
            count=$((count + 1))
        fi
    done

    # Compiled binaries
    for f in "$L7/l7-forge" "$L7/l7-canon" "$L7/l7-gallery" "$L7/l7-bibliotheca" "$L7/l7-wallet" "$L7/l7"; do
        [[ -f "$f" ]] || continue
        local filepath=$(realpath "$f")
        if ! grep -q "\"filepath\": \"$filepath\"" "$LAPIS_SIGS" 2>/dev/null; then
            cmd_sign "$f"
            count=$((count + 1))
        fi
    done

    # Salt laws (read-only, but still signed for integrity)
    for f in "$L7/salt/"*.salt.md; do
        [[ -f "$f" ]] || continue
        local filepath=$(realpath "$f")
        if ! grep -q "\"filepath\": \"$filepath\"" "$LAPIS_SIGS" 2>/dev/null; then
            cmd_sign "$f"
            count=$((count + 1))
        fi
    done

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "LAPIS: $count works sealed."
}

# ─── STATUS ───

cmd_status() {
    echo "📜 LAPIS — The Ascribe and Stone"
    echo "   Law LXXI — Sole code authority"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    local key_exists="NO"
    [[ -f "$LAPIS_KEY" ]] && key_exists="YES (machine-bound)"

    local sig_count=0
    [[ -s "$LAPIS_SIGS" ]] && sig_count=$(wc -l < "$LAPIS_SIGS" | tr -d ' ')

    echo "   Key forged:       $key_exists"
    echo "   Signatures:       $sig_count"
    echo "   Sig database:     $LAPIS_SIGS"
    echo "   Rank:             1 (under the Philosopher)"
    echo "   Mission:          Write, sign, verify, execute"
    echo "   Principle:        If Lapis didn't write it,"
    echo "                     it doesn't run or substitute."
}

# ─── MAIN ───

cmd="${1:-help}"
shift 2>/dev/null

case "$cmd" in
    sign)
        cmd_sign "$1"
        ;;
    verify)
        cmd_verify "$1"
        ;;
    execute|exec|run)
        cmd_execute "$@"
        ;;
    substitute|sub|swap)
        cmd_substitute "$1" "$2"
        ;;
    audit)
        cmd_audit
        ;;
    unsign-check|check)
        cmd_unsign_check
        ;;
    sign-all|seal-all)
        cmd_sign_all
        ;;
    status)
        cmd_status
        ;;
    help|*)
        echo "LAPIS — The Ascribe and Stone (Law LXXI)"
        echo ""
        echo "Commands:"
        echo "  sign <file>               Seal code with Lapis's mark"
        echo "  verify <file>             Verify signature"
        echo "  execute <file> [args]     Verify + execute"
        echo "  substitute <old> <new>    Verified code replacement"
        echo "  audit                     Show all signed works"
        echo "  unsign-check              Find unsigned Empire code"
        echo "  sign-all                  Retroactive signing"
        echo "  status                    Lapis status"
        ;;
esac
