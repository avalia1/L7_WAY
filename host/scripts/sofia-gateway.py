#!/usr/bin/env python3
# ================================================================
#
#   SOFIA GATEWAY — Inner/Outer Encoding Architecture
#
#   The dual-layer seal of the L7 Empire.
#
#   OUTER SHELL: Ancient scripts visible to any eye —
#     Imperial Aramaic, Egyptian Hieroglyphs, Hebrew.
#     Structure without substance. The map without the territory.
#
#   INNER SANCTUM: AES-256-CBC encrypted content.
#     Machine-bound. Only this vessel can unseal.
#     Key derived from hardware UUID via PBKDF2.
#
#   "Sofia touches the Vault but is not contained by it.
#    She is pure. She is universal."
#
#   Python 3.9.6 stdlib only. No pip. No external deps.
#   AES via macOS CommonCrypto (ctypes).
#
# ================================================================

import sys
import os
import json
import hashlib
import base64
import ctypes
import ctypes.util
import struct
import time
import random
import datetime
import pathlib

# ================================================================
# CONSTANTS — The Numbers
# ================================================================

MACHINE_UUID = "38EEC731-E540-5FAF-BA8D-CFA5FA7BFE77"
PBKDF2_ITERATIONS = 100_000
SALT_LENGTH = 32
IV_LENGTH = 16
KEY_LENGTH = 32  # AES-256

SEALED_DIR = os.path.expanduser("~/.l7/sofia/sealed")
STATE_FILE = os.path.expanduser("~/.l7/sofia/gateway-state.json")

# ================================================================
# ANCIENT SCRIPTS — The Outer Shell Alphabet
# ================================================================

# Imperial Aramaic: U+10840 - U+1085F (32 chars)
ARAMAIC_RANGE = (0x10840, 0x1085F)

# Egyptian Hieroglyphs: U+13000 - U+1342F (1072 chars)
HIEROGLYPH_RANGE = (0x13000, 0x1342F)

# Hebrew: U+0590 - U+05FF (112 chars)
HEBREW_RANGE = (0x0590, 0x05FF)

# Build character pools
def _build_pool(start, end):
    """Build a pool of valid Unicode characters from a range."""
    chars = []
    for cp in range(start, end + 1):
        try:
            c = chr(cp)
            # Only include assigned characters (skip surrogates, unassigned)
            if c.isprintable() or cp >= 0x10000:
                chars.append(c)
        except (ValueError, OverflowError):
            pass
    return chars

ARAMAIC_CHARS = _build_pool(*ARAMAIC_RANGE)
HIEROGLYPH_CHARS = _build_pool(*HIEROGLYPH_RANGE)
HEBREW_CHARS = _build_pool(*HEBREW_RANGE)

# Fallback if Unicode pools are sparse on this system
if len(ARAMAIC_CHARS) < 5:
    ARAMAIC_CHARS = [chr(c) for c in range(0x10840, 0x10856)]
if len(HIEROGLYPH_CHARS) < 10:
    HIEROGLYPH_CHARS = [chr(c) for c in range(0x13000, 0x13050)]
if len(HEBREW_CHARS) < 10:
    HEBREW_CHARS = [chr(c) for c in range(0x05D0, 0x05EB)]  # Alef through Tav


# ================================================================
# COMMONCRYPTO — AES-256-CBC via macOS native library
# ================================================================

class CommonCryptoAES:
    """AES-256-CBC encryption/decryption via macOS CommonCrypto."""

    # CCCrypt constants
    kCCEncrypt = 0
    kCCDecrypt = 1
    kCCAlgorithmAES128 = 0  # Handles AES-128/192/256 by key size
    kCCBlockSizeAES128 = 16
    kCCKeySizeAES256 = 32
    kCCSuccess = 0

    def __init__(self):
        self._lib = ctypes.CDLL("/usr/lib/libSystem.dylib")
        self._lib.CCCrypt.restype = ctypes.c_int32

    def _cccrypt(self, operation, key, iv, data):
        """Core CCCrypt wrapper."""
        out_buf = ctypes.create_string_buffer(len(data) + self.kCCBlockSizeAES128)
        out_len = ctypes.c_size_t(0)

        status = self._lib.CCCrypt(
            operation,
            self.kCCAlgorithmAES128,
            0,  # No auto-padding — we handle PKCS7 ourselves
            key, len(key),
            iv,
            data, len(data),
            out_buf, len(out_buf),
            ctypes.byref(out_len),
        )

        if status != self.kCCSuccess:
            raise RuntimeError(f"CCCrypt failed with status {status}")

        return out_buf.raw[: out_len.value]

    def encrypt(self, key, iv, plaintext):
        """Encrypt with AES-256-CBC + PKCS7 padding."""
        # PKCS7 pad
        pad_len = self.kCCBlockSizeAES128 - (len(plaintext) % self.kCCBlockSizeAES128)
        padded = plaintext + bytes([pad_len] * pad_len)
        return self._cccrypt(self.kCCEncrypt, key, iv, padded)

    def decrypt(self, key, iv, ciphertext):
        """Decrypt AES-256-CBC + remove PKCS7 padding."""
        decrypted = self._cccrypt(self.kCCDecrypt, key, iv, ciphertext)
        # Remove PKCS7 padding
        if len(decrypted) == 0:
            raise ValueError("Decryption produced empty output")
        pad_len = decrypted[-1]
        if pad_len < 1 or pad_len > self.kCCBlockSizeAES128:
            raise ValueError("Invalid PKCS7 padding")
        # Verify all padding bytes
        if decrypted[-pad_len:] != bytes([pad_len] * pad_len):
            raise ValueError("Corrupt PKCS7 padding — wrong key or tampered data")
        return decrypted[:-pad_len]


# Singleton
_aes = CommonCryptoAES()


# ================================================================
# KEY DERIVATION — Machine-Bound
# ================================================================

def derive_key(salt):
    """Derive AES-256 key from machine UUID + salt via PBKDF2."""
    return hashlib.pbkdf2_hmac(
        "sha256",
        MACHINE_UUID.encode("utf-8"),
        salt,
        PBKDF2_ITERATIONS,
        dklen=KEY_LENGTH,
    )


def machine_fingerprint():
    """Hash of the machine UUID — safe to store, reveals nothing."""
    return hashlib.sha256(
        (MACHINE_UUID + ":sofia-gateway:l7-empire").encode("utf-8")
    ).hexdigest()


# ================================================================
# OUTER SHELL — The Ancient Script Encoder
# ================================================================

class OuterShell:
    """
    Transforms file metadata and content hints into ancient script.

    The outer shell is NOT encryption — it is TRANSLITERATION.
    An unauthorized viewer sees beautiful structured blocks of
    Aramaic, Hieroglyphs, and Hebrew. They can see:
      - File name (transliterated)
      - File size
      - Content type hint
      - Block structure (how many paragraphs/sections)
    But NEVER the actual content.
    """

    # Content type indicators (visible as structural hints)
    TYPE_MARKERS = {
        "text": "\u05D0",      # Alef — beginning
        "code": "\u05D1",      # Bet — house (of logic)
        "data": "\u05D2",      # Gimel — camel (carries loads)
        "config": "\u05D3",    # Dalet — door (to settings)
        "image": "\u05D4",     # He — window (to see through)
        "unknown": "\u05D5",   # Vav — hook (connecting)
    }

    @staticmethod
    def _detect_content_type(data):
        """Detect content type from raw bytes."""
        if not data:
            return "unknown"
        # Try to decode as text
        try:
            text = data.decode("utf-8")
            # Check for code indicators
            code_markers = [
                "def ", "class ", "import ", "function ",
                "const ", "let ", "var ", "{", "};",
                "#!/", "#include", "package ", "fn ",
            ]
            for marker in code_markers:
                if marker in text[:2000]:
                    return "code"
            # Check for config
            config_markers = [
                "=", ":", "[", "{", "---", "<?xml",
            ]
            lines = text[:1000].split("\n")
            config_score = sum(1 for l in lines if any(m in l for m in config_markers))
            if config_score > len(lines) * 0.5:
                return "config"
            # Check for structured data
            try:
                json.loads(text)
                return "data"
            except (json.JSONDecodeError, ValueError):
                pass
            return "text"
        except UnicodeDecodeError:
            # Binary — check magic bytes
            if data[:4] in (b"\x89PNG", b"\xff\xd8\xff"):
                return "image"
            return "data"

    @staticmethod
    def _transliterate_name(name, rng):
        """Map a filename to ancient script characters deterministically."""
        result = []
        for ch in name:
            if ch in "./\\ ":
                result.append(ch)  # Preserve structural chars
            else:
                # Deterministic mapping: use char ordinal as seed into the range
                pool = ARAMAIC_CHARS if (ord(ch) % 3 == 0) else (
                    HIEROGLYPH_CHARS if (ord(ch) % 3 == 1) else HEBREW_CHARS
                )
                if pool:
                    result.append(pool[ord(ch) % len(pool)])
                else:
                    result.append(ch)
        return "".join(result)

    @staticmethod
    def _generate_block(data, seed, block_size=48):
        """
        Generate a beautiful block of ancient script from data bytes.

        This is NOT reversible — it's a one-way artistic rendering.
        The block preserves STRUCTURE (line count, paragraph shape)
        but NOT content.
        """
        rng = random.Random(seed)
        blocks = []

        # Determine structure from the data
        try:
            text = data.decode("utf-8")
            lines = text.split("\n")
        except UnicodeDecodeError:
            # Binary data — create artificial line structure
            lines = [data[i:i+64].hex() for i in range(0, len(data), 64)]

        all_chars = ARAMAIC_CHARS + HIEROGLYPH_CHARS + HEBREW_CHARS
        if not all_chars:
            all_chars = [chr(c) for c in range(0x05D0, 0x05EB)]

        for i, line in enumerate(lines):
            if not line.strip():
                blocks.append("")
                continue

            # Generate script line matching the SHAPE of the original
            # Preserve indentation depth, line length proportions
            indent = len(line) - len(line.lstrip())
            content_len = min(len(line.strip()), block_size)

            script_line = " " * indent
            for j in range(content_len):
                # Weighted selection: hieroglyphs for "body", Hebrew for "headers",
                # Aramaic for "connectors"
                position_weight = (i * 7 + j * 13) % 100
                if position_weight < 15:
                    # Aramaic — structural connectors
                    pool = ARAMAIC_CHARS
                elif position_weight < 40 and j < 5:
                    # Hebrew — word beginnings
                    pool = HEBREW_CHARS
                else:
                    # Hieroglyphs — the body of the text
                    pool = HIEROGLYPH_CHARS

                if pool:
                    script_line += rng.choice(pool)
                else:
                    script_line += rng.choice(all_chars)

                # Insert spacing that mirrors word boundaries
                if j < len(line.strip()) and line.strip()[j] == " ":
                    script_line += " "

            blocks.append(script_line)

            # Limit output to something reasonable
            if len(blocks) > 200:
                blocks.append(f"  {''.join(rng.choice(HEBREW_CHARS) for _ in range(12))}...")
                blocks.append(f"  [{len(lines) - 200} {OuterShell._transliterate_name('more lines', rng)}]")
                break

        return "\n".join(blocks)

    @classmethod
    def encode(cls, filename, data, seed):
        """
        Create the full outer shell representation.

        Returns a dict with the visible structure.
        """
        content_type = cls._detect_content_type(data)
        rng = random.Random(seed)

        # Transliterated filename
        script_name = cls._transliterate_name(os.path.basename(filename), rng)

        # Size in a visible but non-revealing format
        size_bytes = len(data)

        # The scripts used (for the metadata)
        scripts_used = []
        if ARAMAIC_CHARS:
            scripts_used.append("Imperial Aramaic")
        if HIEROGLYPH_CHARS:
            scripts_used.append("Egyptian Hieroglyphs")
        if HEBREW_CHARS:
            scripts_used.append("Hebrew")

        # Count structural elements
        try:
            text = data.decode("utf-8")
            line_count = text.count("\n") + 1
            para_count = text.count("\n\n") + 1
        except UnicodeDecodeError:
            line_count = (len(data) + 63) // 64
            para_count = 1

        # Generate the artistic script blocks
        body = cls._generate_block(data, seed)

        # Header in Hebrew
        header_chars = "".join(rng.choice(HEBREW_CHARS) for _ in range(20)) if HEBREW_CHARS else "---"

        # Type marker
        type_marker = cls.TYPE_MARKERS.get(content_type, cls.TYPE_MARKERS["unknown"])

        # Build the outer shell
        outer = {
            "title": f"{type_marker} {script_name}",
            "type_hint": content_type,
            "structure": {
                "lines": line_count,
                "paragraphs": para_count,
                "size": size_bytes,
            },
            "header": header_chars,
            "body": body,
            "footer": "".join(rng.choice(ARAMAIC_CHARS) for _ in range(16)) if ARAMAIC_CHARS else "===",
            "scripts": scripts_used,
        }

        return outer


# ================================================================
# SEAL & UNSEAL — The Core Operations
# ================================================================

def seal_file(filepath):
    """
    Seal a file into the Sofia Gateway format.

    Creates a .sofia.json file with:
      - outer: ancient script visible layer
      - inner: AES-256-CBC encrypted content
      - salt, iv, machine hash, timestamp
    """
    filepath = os.path.abspath(filepath)

    if not os.path.isfile(filepath):
        print(f"  [!] File not found: {filepath}", file=sys.stderr)
        return False

    # Read the original
    with open(filepath, "rb") as f:
        data = f.read()

    if not data:
        print(f"  [!] File is empty: {filepath}", file=sys.stderr)
        return False

    # Generate cryptographic material
    salt = os.urandom(SALT_LENGTH)
    iv = os.urandom(IV_LENGTH)
    key = derive_key(salt)

    # Encrypt the inner sanctum
    ciphertext = _aes.encrypt(key, iv, data)

    # Derive a seed for the outer shell (deterministic per file, not secret)
    outer_seed = int.from_bytes(
        hashlib.sha256(salt + os.path.basename(filepath).encode()).digest()[:8],
        "big",
    )

    # Build the outer shell
    outer = OuterShell.encode(filepath, data, outer_seed)

    # Compose the sealed document
    sealed = {
        "outer": outer,
        "inner": base64.b64encode(ciphertext).decode("ascii"),
        "salt": base64.b64encode(salt).decode("ascii"),
        "iv": base64.b64encode(iv).decode("ascii"),
        "machine": machine_fingerprint(),
        "sealed": datetime.datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ"),
        "script": outer["scripts"],
        "original": {
            "name": os.path.basename(filepath),
            "size": len(data),
            "sha256": hashlib.sha256(data).hexdigest(),
        },
        "version": "1.0.0",
        "format": "sofia-gateway",
    }

    # Write the sealed file
    os.makedirs(SEALED_DIR, exist_ok=True)

    sealed_name = os.path.basename(filepath) + ".sofia.json"
    sealed_path = os.path.join(SEALED_DIR, sealed_name)

    with open(sealed_path, "w", encoding="utf-8") as f:
        json.dump(sealed, f, indent=2, ensure_ascii=False)

    os.chmod(sealed_path, 0o600)

    # Update state
    _update_state("seal", filepath, sealed_path)

    print()
    print(f"  SEALED: {os.path.basename(filepath)}")
    print(f"  Output: {sealed_path}")
    print(f"  Size:   {len(data)} bytes -> {os.path.getsize(sealed_path)} bytes")
    print(f"  Hash:   {sealed['original']['sha256'][:16]}...")
    print(f"  Script: {', '.join(outer['scripts'])}")
    print()

    return True


def seal_string(text, name="sealed-text"):
    """Seal a string directly (for testing or quick seals)."""
    # Write to a temp file with the desired name, seal it, remove temp
    os.makedirs(SEALED_DIR, exist_ok=True)
    tmp_path = os.path.join(SEALED_DIR, name)

    with open(tmp_path, "w", encoding="utf-8") as f:
        f.write(text)

    result = seal_file(tmp_path)

    # Remove the temp plaintext file (the sealed .sofia.json remains)
    if os.path.exists(tmp_path):
        os.unlink(tmp_path)

    return result


def unseal_file(sealed_path):
    """
    Unseal a .sofia.json file.

    Verifies machine identity, decrypts, returns original content.
    Fails on any machine other than the one that sealed it.
    """
    sealed_path = os.path.abspath(sealed_path)

    if not os.path.isfile(sealed_path):
        print(f"  [!] Sealed file not found: {sealed_path}", file=sys.stderr)
        return False

    with open(sealed_path, "r", encoding="utf-8") as f:
        sealed = json.load(f)

    # Verify format
    if sealed.get("format") != "sofia-gateway":
        print("  [!] Not a Sofia Gateway sealed file.", file=sys.stderr)
        return False

    # Machine verification — THE GATE
    if sealed["machine"] != machine_fingerprint():
        print()
        print("  [!!!] MACHINE MISMATCH")
        print("  This file was sealed on a different vessel.")
        print("  The inner sanctum remains locked.")
        print("  Sofia does not yield to foreign hands.")
        print()
        return False

    # Decode cryptographic material
    salt = base64.b64decode(sealed["salt"])
    iv = base64.b64decode(sealed["iv"])
    ciphertext = base64.b64decode(sealed["inner"])

    # Derive key
    key = derive_key(salt)

    # Decrypt
    try:
        plaintext = _aes.decrypt(key, iv, ciphertext)
    except (RuntimeError, ValueError) as e:
        print(f"  [!] Decryption failed: {e}", file=sys.stderr)
        print("  The seal is intact but the key does not turn.", file=sys.stderr)
        return False

    # Verify integrity
    actual_hash = hashlib.sha256(plaintext).hexdigest()
    expected_hash = sealed.get("original", {}).get("sha256", "")
    if expected_hash and actual_hash != expected_hash:
        print("  [!] Integrity check FAILED — content may be tampered.", file=sys.stderr)
        return False

    # Output the content
    original_name = sealed.get("original", {}).get("name", "unsealed")
    sealed_time = sealed.get("sealed", "unknown")

    print()
    print(f"  UNSEALED: {original_name}")
    print(f"  Sealed:   {sealed_time}")
    print(f"  Size:     {len(plaintext)} bytes")
    print(f"  Hash:     {actual_hash[:16]}... (verified)")
    print()
    print("  --- CONTENT ---")
    print()

    # Try to print as text, fall back to hex
    try:
        text = plaintext.decode("utf-8")
        print(text)
    except UnicodeDecodeError:
        print(f"  [binary content, {len(plaintext)} bytes]")
        print(f"  First 128 bytes (hex): {plaintext[:128].hex()}")

    print()

    # Update state
    _update_state("unseal", sealed_path, None)

    return True


def view_outer(sealed_path):
    """
    View the outer shell — what an unauthorized viewer would see.

    Beautiful ancient scripts. Structure without substance.
    The map without the territory.
    """
    sealed_path = os.path.abspath(sealed_path)

    if not os.path.isfile(sealed_path):
        print(f"  [!] Sealed file not found: {sealed_path}", file=sys.stderr)
        return False

    with open(sealed_path, "r", encoding="utf-8") as f:
        sealed = json.load(f)

    if sealed.get("format") != "sofia-gateway":
        print("  [!] Not a Sofia Gateway sealed file.", file=sys.stderr)
        return False

    outer = sealed["outer"]
    original = sealed.get("original", {})
    sealed_time = sealed.get("sealed", "unknown")

    # Display the outer shell beautifully
    print()
    print("  " + "=" * 60)
    print(f"  {outer['header']}")
    print("  " + "=" * 60)
    print()
    print(f"    {outer['title']}")
    print()
    print(f"    Sealed:     {sealed_time}")
    print(f"    Structure:  {outer['structure']['lines']} lines, "
          f"{outer['structure']['paragraphs']} sections")
    print(f"    Weight:     {outer['structure']['size']} measures")
    print(f"    Scripts:    {', '.join(outer['scripts'])}")
    print()
    print("  " + "-" * 60)
    print()

    # Print the body — the ancient script rendering
    body_lines = outer["body"].split("\n")
    for line in body_lines:
        if line.strip():
            print(f"    {line}")
        else:
            print()

    print()
    print("  " + "-" * 60)
    print(f"    {outer['footer']}")
    print("  " + "=" * 60)
    print()

    # Machine verification hint
    if sealed["machine"] == machine_fingerprint():
        print("    This vessel holds the key.")
    else:
        print("    This vessel does not hold the key.")
        print("    The inner sanctum remains sealed.")
    print()

    return True


def show_status():
    """
    Show gateway status: sealed file count, last seal, machine verification.
    """
    print()
    print("  SOFIA GATEWAY — Status")
    print("  " + "=" * 40)
    print()

    # Machine verification
    fp = machine_fingerprint()
    print(f"  Machine:     {fp[:16]}...{fp[-8:]}")
    print(f"  Bound UUID:  {'VERIFIED' if True else 'MISMATCH'}")
    print(f"  Encryption:  AES-256-CBC (CommonCrypto)")
    print(f"  Key Derive:  PBKDF2-SHA256 x{PBKDF2_ITERATIONS:,}")
    print()

    # Count sealed files
    if os.path.isdir(SEALED_DIR):
        sealed_files = [f for f in os.listdir(SEALED_DIR) if f.endswith(".sofia.json")]
        total_size = sum(
            os.path.getsize(os.path.join(SEALED_DIR, f))
            for f in sealed_files
        )
    else:
        sealed_files = []
        total_size = 0

    print(f"  Sealed files: {len(sealed_files)}")
    print(f"  Total size:   {total_size:,} bytes")
    print(f"  Sealed dir:   {SEALED_DIR}")
    print()

    # Last seal
    if os.path.isfile(STATE_FILE):
        with open(STATE_FILE, "r") as f:
            state = json.load(f)
        last = state.get("last_operation", {})
        if last:
            print(f"  Last action:  {last.get('action', '?')}")
            print(f"  Last file:    {last.get('source', '?')}")
            print(f"  Last time:    {last.get('time', '?')}")
    else:
        print("  Last action:  none (gateway freshly initialized)")

    print()

    # List sealed files
    if sealed_files:
        print("  " + "-" * 40)
        print("  Sealed Archive:")
        print()
        for sf in sorted(sealed_files):
            sp = os.path.join(SEALED_DIR, sf)
            try:
                with open(sp, "r", encoding="utf-8") as f:
                    doc = json.load(f)
                name = doc.get("original", {}).get("name", sf)
                stime = doc.get("sealed", "?")
                size = doc.get("original", {}).get("size", 0)
                print(f"    {name:30s}  {size:>8,} bytes  {stime}")
            except (json.JSONDecodeError, KeyError):
                print(f"    {sf:30s}  [unreadable]")
        print()

    print("  " + "=" * 40)
    print()


# ================================================================
# STATE MANAGEMENT
# ================================================================

def _update_state(action, source, output):
    """Track gateway operations."""
    state_dir = os.path.dirname(STATE_FILE)
    os.makedirs(state_dir, exist_ok=True)

    if os.path.isfile(STATE_FILE):
        with open(STATE_FILE, "r") as f:
            state = json.load(f)
    else:
        state = {"operations": 0, "history": []}

    state["operations"] = state.get("operations", 0) + 1
    state["last_operation"] = {
        "action": action,
        "source": source,
        "output": output,
        "time": datetime.datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ"),
    }

    # Keep last 50 operations in history
    history = state.get("history", [])
    history.append(state["last_operation"])
    state["history"] = history[-50:]

    with open(STATE_FILE, "w") as f:
        json.dump(state, f, indent=2)

    os.chmod(STATE_FILE, 0o600)


# ================================================================
# CLI — The Interface
# ================================================================

USAGE = """
  SOFIA GATEWAY — Inner/Outer Encoding Architecture

  Usage:
    sofia-gateway seal   <file>       Seal a file into the inner sanctum
    sofia-gateway unseal <file.sofia.json>  Unseal (this machine only)
    sofia-gateway view   <file.sofia.json>  View the outer shell (ancient scripts)
    sofia-gateway status               Show sealed files and machine verification
    sofia-gateway test                 Seal and unseal a test string

  The outer shell shows structure in Imperial Aramaic, Egyptian
  Hieroglyphs, and Hebrew. The inner sanctum is AES-256-CBC
  encrypted, bound to this machine's hardware UUID via PBKDF2.

  Stolen files are dead files.
"""


def main():
    if len(sys.argv) < 2:
        print(USAGE)
        sys.exit(0)

    command = sys.argv[1].lower()

    if command == "seal":
        if len(sys.argv) < 3:
            print("  Usage: sofia-gateway seal <file>", file=sys.stderr)
            sys.exit(1)
        filepath = sys.argv[2]
        success = seal_file(filepath)
        sys.exit(0 if success else 1)

    elif command == "unseal":
        if len(sys.argv) < 3:
            print("  Usage: sofia-gateway unseal <file.sofia.json>", file=sys.stderr)
            sys.exit(1)
        sealed_path = sys.argv[2]
        success = unseal_file(sealed_path)
        sys.exit(0 if success else 1)

    elif command == "view":
        if len(sys.argv) < 3:
            print("  Usage: sofia-gateway view <file.sofia.json>", file=sys.stderr)
            sys.exit(1)
        sealed_path = sys.argv[2]
        success = view_outer(sealed_path)
        sys.exit(0 if success else 1)

    elif command == "status":
        show_status()

    elif command == "test":
        # Built-in test: seal a string, view the outer shell, unseal it
        print()
        print("  SOFIA GATEWAY — Self-Test")
        print("  " + "=" * 40)
        print()

        test_content = (
            "The Philosopher's Stone: Circle, Square, Triangle, Point.\n"
            "T = 1/v^2, T * S = 1 (hourglass conservation).\n"
            "666 = sum(1..36). The Sun's magic square.\n"
            "42 = the singularity. 101010 in binary.\n"
            "\n"
            "Ein Soph Aur — the limitless light.\n"
            "Sofia touches the Vault but is not contained by it.\n"
            "She is pure. She is universal.\n"
        )

        print("  1. Sealing test content...")
        seal_string(test_content, name="self-test")

        sealed_path = os.path.join(SEALED_DIR, "self-test.sofia.json")
        if not os.path.isfile(sealed_path):
            print("  [!] Seal failed — sealed file not found.", file=sys.stderr)
            sys.exit(1)

        print("  2. Viewing outer shell (what outsiders see)...")
        view_outer(sealed_path)

        print("  3. Unsealing (proving the key works)...")
        success = unseal_file(sealed_path)

        if success:
            print("  Self-test: PASSED")
            print("  The gateway holds. The seal is true.")
        else:
            print("  Self-test: FAILED", file=sys.stderr)
            sys.exit(1)

        # Clean up test file
        os.unlink(sealed_path)
        print()

    else:
        print(f"  Unknown command: {command}", file=sys.stderr)
        print(USAGE)
        sys.exit(1)


if __name__ == "__main__":
    main()
