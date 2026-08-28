"""Append-only audit log for skill runtime executions."""

from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict

L7_DIR = Path.home() / ".l7"
AUDIT_PATH = L7_DIR / "state" / "skill-runtime" / "audit.jsonl"


def log_execution(action: str, params: Dict[str, Any], envelope: Dict[str, Any]) -> None:
    AUDIT_PATH.parent.mkdir(parents=True, exist_ok=True)
    record = {
        "who": "skill-runtime",
        "what": {
            "action": action,
            "params": params,
            "success": envelope.get("success"),
            "tool": (envelope.get("meta") or {}).get("tool"),
            "entity_id": (envelope.get("meta") or {}).get("entity_id"),
            "error": envelope.get("error") or None,
        },
        "when": datetime.now(timezone.utc).isoformat(),
    }
    with open(AUDIT_PATH, "a", encoding="utf-8") as f:
        f.write(json.dumps(record, default=str) + "\n")
    # also mirror to main L7 audit.log as one-line JSON
    main_audit = L7_DIR / "audit.log"
    try:
        with open(main_audit, "a", encoding="utf-8") as f:
            f.write(json.dumps({"source": "skill-runtime", **record}, default=str) + "\n")
    except Exception:
        pass
