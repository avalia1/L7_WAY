"""Discover and load L7 skills, tools, and citizens."""

from __future__ import annotations

import json
import re
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Dict, List, Optional

try:
    import yaml
except ImportError:  # pragma: no cover
    yaml = None


L7_DIR = Path.home() / ".l7"
DEFAULT_SKILL_ROOTS = [
    L7_DIR / "skills",
    L7_DIR / "work" / "dev" / "skills",
]
TOOLS_DIR = L7_DIR / "tools"
CITIZENS_DIR = L7_DIR / "citizens"
PLAYGROUND = Path.home() / "Documents" / "Obsidian Vault" / "00 AI Playground"


@dataclass
class Skill:
    name: str
    path: Path
    description: str
    body: str
    frontmatter: Dict[str, Any] = field(default_factory=dict)
    references: List[Path] = field(default_factory=list)
    suite: str = ""
    does: str = ""
    emoji: str = ""
    entity_id: str = ""

    @property
    def location(self) -> str:
        return str(self.path)


def _parse_frontmatter(text: str) -> tuple[Dict[str, Any], str]:
    if not text.startswith("---"):
        return {}, text
    parts = text.split("---", 2)
    if len(parts) < 3:
        return {}, text
    raw_fm, body = parts[1], parts[2].lstrip("\n")
    data: Dict[str, Any] = {}
    if yaml is not None:
        try:
            data = yaml.safe_load(raw_fm) or {}
        except Exception:
            data = _simple_fm(raw_fm)
    else:
        data = _simple_fm(raw_fm)
    return data, body


def _simple_fm(raw: str) -> Dict[str, Any]:
    out: Dict[str, Any] = {}
    for line in raw.splitlines():
        if ":" not in line or line.strip().startswith("#"):
            continue
        if line.startswith(" ") or line.startswith("\t"):
            continue
        key, val = line.split(":", 1)
        key = key.strip()
        val = val.strip().strip('"').strip("'")
        if key in ("name", "description"):
            out[key] = val
    return out


def discover_skill_paths(roots: Optional[List[Path]] = None) -> List[Path]:
    roots = roots or DEFAULT_SKILL_ROOTS
    found: Dict[str, Path] = {}
    for root in roots:
        if not root.exists():
            continue
        for skill_md in root.rglob("SKILL.md"):
            # skip nested packages that aren't skill roots deeper than 6
            rel = skill_md.relative_to(root)
            if len(rel.parts) > 6:
                continue
            name = skill_md.parent.name
            # first root wins (main skills before dev)
            if name not in found:
                found[name] = skill_md
    return sorted(found.values(), key=lambda p: p.parent.name)


def load_skill(skill_md: Path) -> Skill:
    text = skill_md.read_text(encoding="utf-8", errors="replace")
    fm, body = _parse_frontmatter(text)
    name = fm.get("name") or skill_md.parent.name
    description = fm.get("description") or ""
    meta = fm.get("metadata") or {}
    if isinstance(meta, str):
        try:
            meta = json.loads(meta)
        except Exception:
            meta = {}
    openclaw = (meta.get("openclaw") if isinstance(meta, dict) else {}) or {}
    l7 = (meta.get("l7") if isinstance(meta, dict) else {}) or {}
    refs_dir = skill_md.parent / "references"
    refs = sorted(refs_dir.glob("**/*")) if refs_dir.exists() else []
    refs = [p for p in refs if p.is_file()]
    return Skill(
        name=name,
        path=skill_md,
        description=description,
        body=body,
        frontmatter=fm,
        references=refs,
        suite=str(l7.get("suite", "")),
        does=str(l7.get("does", "")),
        emoji=str(openclaw.get("emoji", "")),
        entity_id=str(l7.get("entity_id", f"skill.{name}")),
    )


def load_all_skills(roots: Optional[List[Path]] = None) -> List[Skill]:
    return [load_skill(p) for p in discover_skill_paths(roots)]


def parse_tool_file(path: Path) -> Dict[str, Any]:
    text = path.read_text(encoding="utf-8", errors="replace")
    if yaml is not None:
        try:
            data = yaml.safe_load(text)
            if isinstance(data, dict):
                return data
        except Exception:
            pass
    # minimal line parser
    out: Dict[str, Any] = {}
    section = None
    for line in text.splitlines():
        if not line.strip() or line.strip().startswith("#"):
            continue
        if re.match(r"^[a-zA-Z_][a-zA-Z0-9_]*:\s*$", line.strip()):
            section = line.strip()[:-1]
            out[section] = {}
            continue
        m = re.match(r"^([a-zA-Z_][a-zA-Z0-9_]*)\s*:\s*(.*)$", line.strip())
        if not m:
            continue
        key, val = m.group(1), m.group(2).strip().strip('"')
        if val.lower() in ("true", "false"):
            parsed: Any = val.lower() == "true"
        else:
            parsed = val
        if section and line.startswith("  "):
            if not isinstance(out.get(section), dict):
                out[section] = {}
            out[section][key] = parsed
        else:
            section = None
            out[key] = parsed
    return out


def load_all_tools() -> List[Dict[str, Any]]:
    if not TOOLS_DIR.exists():
        return []
    tools = []
    for p in sorted(TOOLS_DIR.glob("*.tool")):
        data = parse_tool_file(p)
        data["_path"] = str(p)
        data.setdefault("name", p.stem)
        tools.append(data)
    return tools


def load_all_citizens() -> List[Dict[str, Any]]:
    if not CITIZENS_DIR.exists():
        return []
    out = []
    for p in sorted(CITIZENS_DIR.glob("*.citizen")):
        try:
            out.append(json.loads(p.read_text()))
        except Exception as exc:
            out.append({"name": p.stem, "error": str(exc)})
    return out


def route_task(query: str, skills: Optional[List[Skill]] = None) -> List[Dict[str, Any]]:
    """Score skills against a natural-language task."""
    skills = skills or load_all_skills()
    q = query.lower()
    tokens = set(re.findall(r"[a-z0-9]+", q))
    ranked = []
    keyword_boosts = {
        "rag": ["rag-pipeline", "llamaindex-rag", "vector-chroma", "vector-qdrant"],
        "vector": ["vector-chroma", "vector-qdrant", "rag-pipeline"],
        "chroma": ["vector-chroma"],
        "qdrant": ["vector-qdrant"],
        "langchain": ["langchain-agents"],
        "llama": ["llamaindex-rag"],
        "autogen": ["multiagent-autogen"],
        "multiagent": ["multiagent-autogen", "agent-workflows"],
        "agent": ["agent-workflows", "autonomous-agents", "multiagent-autogen"],
        "prompt": ["prompt-engineering"],
        "openai": ["openai-patterns"],
        "gemini": ["gemini-vertex"],
        "vertex": ["gemini-vertex"],
        "financial": ["financial-analysis", "financial-ratios", "dcf-valuation"],
        "ratio": ["financial-ratios", "financial-analysis"],
        "dcf": ["dcf-valuation", "financial-analysis"],
        "brand": ["brand-guidelines"],
        "skill": ["claude-skills-dev", "ai-playground-index"],
        "tool": ["tool-use-patterns"],
        "playground": ["ai-playground-index"],
        "index": ["ai-playground-index"],
    }
    for skill in skills:
        hay = f"{skill.name} {skill.description} {skill.body[:2000]}".lower()
        score = 0.0
        for tok in tokens:
            if tok in hay:
                score += 1.0
            if tok in skill.name:
                score += 2.0
        for key, names in keyword_boosts.items():
            if key in q and skill.name in names:
                score += 5.0
        if skill.name == "ai-playground-index":
            score += 0.5  # soft baseline router
        if score > 0:
            ranked.append(
                {
                    "name": skill.name,
                    "score": round(score, 2),
                    "description": skill.description,
                    "path": skill.location,
                    "does": skill.does,
                    "suite": skill.suite,
                    "emoji": skill.emoji,
                }
            )
    ranked.sort(key=lambda x: (-x["score"], x["name"]))
    return ranked
