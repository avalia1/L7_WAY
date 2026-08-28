"""Load ~/.l7/state/skill-runtime/corpus.json profile roots."""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any, Dict, List, Optional

L7_DIR = Path.home() / ".l7"
DEFAULT_CORPUS_CONFIG = L7_DIR / "state" / "skill-runtime" / "corpus.json"


def load_corpus_config(path: Optional[Path] = None) -> Dict[str, Any]:
    p = Path(path) if path else DEFAULT_CORPUS_CONFIG
    if not p.exists():
        return {"version": 1, "profiles": {}}
    return json.loads(p.read_text(encoding="utf-8"))


def resolve_profile_roots(
    profile: str,
    extra_roots: Optional[List[str]] = None,
    config_path: Optional[Path] = None,
) -> Dict[str, Any]:
    """
    Returns {
      profile, roots: [Path], use_builtin: bool, builtin: str|None, description
    }
    """
    cfg = load_corpus_config(config_path)
    profiles = cfg.get("profiles") or {}
    entry = profiles.get(profile) or {}
    roots = [Path(r).expanduser() for r in (entry.get("roots") or [])]
    for r in extra_roots or []:
        roots.append(Path(r).expanduser())
    # drop empty / missing (warn via missing list)
    existing = []
    missing = []
    for r in roots:
        if r.exists():
            existing.append(r)
        else:
            missing.append(str(r))
    return {
        "profile": profile,
        "description": entry.get("description", ""),
        "roots": existing,
        "missing_roots": missing,
        "use_builtin": bool(entry.get("use_builtin", profile in ("default", "real-corpus"))),
        "builtin": entry.get("builtin") or (profile if profile in ("default", "real-corpus") else None),
        "config_path": str(config_path or DEFAULT_CORPUS_CONFIG),
    }
