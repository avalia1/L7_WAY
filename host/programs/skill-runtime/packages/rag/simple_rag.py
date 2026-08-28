"""
Pure-Python TF-IDF RAG — offline, no chromadb/numpy.

Supports:
  - default skill + playground index
  - named profiles (e.g. real-corpus)
  - extra roots passed at index time
"""

from __future__ import annotations

import json
import math
import re
from collections import Counter
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional, Sequence, Tuple

L7_DIR = Path.home() / ".l7"
PLAYGROUND = Path.home() / "Documents" / "Obsidian Vault" / "00 AI Playground"
INDEX_DIR = L7_DIR / "state" / "skill-runtime" / "rag"
DEFAULT_INDEX = INDEX_DIR / "tfidf_index.json"
CORPUS_DIR = Path(__file__).resolve().parent / "corpus"
REAL_CORPUS_DIR = CORPUS_DIR / "real"

TOKEN_RE = re.compile(r"[a-z0-9]{2,}")
TEXT_SUFFIXES = {".md", ".txt", ".py", ".yaml", ".yml", ".json", ".toml", ".sh"}
SKIP_DIR_NAMES = {
    ".git",
    "node_modules",
    "__pycache__",
    ".venv",
    "venv",
    "dist",
    "build",
    ".tox",
    "target",
}


def index_path(profile: str = "default") -> Path:
    if profile in ("", "default"):
        return DEFAULT_INDEX
    safe = re.sub(r"[^a-zA-Z0-9_-]+", "_", profile)
    return INDEX_DIR / f"tfidf_{safe}.json"


def _stem_token(tok: str) -> List[str]:
    """Minimal plural fold only — avoid -ing stems (they add ranking noise)."""
    out = [tok]
    if len(tok) > 4 and tok.endswith("ies"):
        out.append(tok[:-3] + "y")
    elif len(tok) > 3 and tok.endswith("s") and not tok.endswith(("ss", "us", "is")):
        out.append(tok[:-1])  # factors -> factor
    seen = set()
    uniq = []
    for t in out:
        if t not in seen:
            seen.add(t)
            uniq.append(t)
    return uniq


def _tokenize(text: str) -> List[str]:
    toks = TOKEN_RE.findall(text.lower())
    expanded: List[str] = []
    for t in toks:
        expanded.extend(_stem_token(t))
    return expanded


HEADING_RE = re.compile(r"(?m)^(#{1,6})\s+(.+?)\s*$")


def _split_fixed(text: str, size: int = 900, overlap: int = 120) -> List[str]:
    text = re.sub(r"\s+", " ", text).strip()
    if not text:
        return []
    chunks = []
    i = 0
    while i < len(text):
        chunks.append(text[i : i + size])
        i += max(size - overlap, 1)
    return chunks


def _chunk_sections(text: str, size: int = 1200, overlap: int = 80) -> List[Dict[str, str]]:
    """
    Heading-aware chunking for markdown-ish docs.

    Returns list of {heading, text}. Prefer one section per chunk; split long
    sections with fixed windows while preserving the heading prefix.
    """
    if not text or not text.strip():
        return []

    matches = list(HEADING_RE.finditer(text))
    # Few/no headings → fixed windows (no fake structure)
    if len(matches) < 2:
        return [{"heading": "", "text": c} for c in _split_fixed(text, size=size, overlap=overlap)]

    sections: List[Dict[str, str]] = []
    # Preamble before first heading
    if matches[0].start() > 0:
        pre = text[: matches[0].start()].strip()
        if len(pre) >= 40:
            sections.append({"heading": "(preamble)", "text": pre})

    for i, m in enumerate(matches):
        start = m.start()
        end = matches[i + 1].start() if i + 1 < len(matches) else len(text)
        body = text[start:end].strip()
        heading = m.group(2).strip()
        if len(body) < 20:
            continue
        if len(body) <= size:
            sections.append({"heading": heading, "text": body})
        else:
            # Keep heading on every sub-window for retrieval signal
            prefix = m.group(0).strip()
            rest = body[len(prefix) :].strip() if body.startswith(prefix) else body
            for j, piece in enumerate(_split_fixed(rest, size=size - len(prefix) - 2, overlap=overlap)):
                sections.append(
                    {
                        "heading": heading if j == 0 else f"{heading} (cont. {j})",
                        "text": f"{prefix}\n\n{piece}".strip(),
                    }
                )
    return sections


def _chunk(text: str, size: int = 900, overlap: int = 120) -> List[str]:
    """Backward-compatible: return plain text chunks only."""
    return [s["text"] for s in _chunk_sections(text, size=size, overlap=overlap)]


def _read_text(path: Path, max_chars: int = 200_000) -> str:
    try:
        data = path.read_text(encoding="utf-8", errors="replace")
    except Exception:
        return ""
    if len(data) > max_chars:
        return data[:max_chars]
    return data


def _iter_files(root: Path) -> Iterable[Path]:
    if root.is_file():
        yield root
        return
    if not root.exists():
        return
    for p in root.rglob("*"):
        if not p.is_file():
            continue
        if any(part in SKIP_DIR_NAMES for part in p.parts):
            continue
        if p.suffix.lower() in TEXT_SUFFIXES or p.name in {"SKILL.md", "README", "AGENTS.md"}:
            # skip huge binary-looking
            try:
                if p.stat().st_size > 2_000_000:
                    continue
            except OSError:
                continue
            yield p


def _add_doc(docs: List[Dict[str, str]], doc_id: str, source: Path, text: str) -> None:
    text = (text or "").strip()
    if len(text) < 40:
        return
    docs.append({"id": doc_id, "source": str(source), "text": text})


def collect_default_documents() -> List[Dict[str, str]]:
    docs: List[Dict[str, str]] = []

    for root in (L7_DIR / "skills", L7_DIR / "work" / "dev" / "skills"):
        if not root.exists():
            continue
        for skill_md in root.glob("*/SKILL.md"):
            _add_doc(docs, f"skill:{skill_md.parent.name}", skill_md, _read_text(skill_md))
            ref = skill_md.parent / "references"
            if ref.exists():
                for p in ref.rglob("*.md"):
                    _add_doc(docs, f"ref:{skill_md.parent.name}:{p.name}", p, _read_text(p))

    if CORPUS_DIR.exists():
        for p in _iter_files(CORPUS_DIR):
            rel = p.relative_to(CORPUS_DIR)
            _add_doc(docs, f"corpus:{rel}", p, _read_text(p))

    if PLAYGROUND.exists():
        for name in [
            "anthropic-cookbook",
            "autogen",
            "AutoGPT",
            "chroma",
            "generative-ai",
            "langchain",
            "llama_index",
            "llm-course",
            "openai-cookbook",
            "Prompt-Engineering-Guide",
            "qdrant",
        ]:
            readme = PLAYGROUND / name / "README.md"
            if readme.exists():
                _add_doc(docs, f"readme:{name}", readme, _read_text(readme, 20_000))

    patterns = PLAYGROUND / "anthropic-cookbook" / "patterns" / "agents" / "README.md"
    if patterns.exists():
        _add_doc(docs, "readme:agent-patterns", patterns, _read_text(patterns))

    return docs


def collect_from_roots(roots: Sequence[Path], id_prefix: str = "root") -> List[Dict[str, str]]:
    docs: List[Dict[str, str]] = []
    for root in roots:
        root = root.expanduser().resolve()
        if not root.exists():
            continue
        for p in _iter_files(root):
            try:
                rel = p.relative_to(root)
                doc_id = f"{id_prefix}:{root.name}/{rel}"
            except ValueError:
                doc_id = f"{id_prefix}:{p}"
            _add_doc(docs, doc_id, p, _read_text(p))
    return docs


def collect_real_corpus_documents(extra_roots: Optional[Sequence[Path]] = None) -> List[Dict[str, str]]:
    """Curated real corpus: L7 doctrine + runtime + founder ops trees + optional roots."""
    docs: List[Dict[str, str]] = []

    # Seeded real corpus tree
    if REAL_CORPUS_DIR.exists():
        for p in _iter_files(REAL_CORPUS_DIR):
            rel = p.relative_to(REAL_CORPUS_DIR)
            _add_doc(docs, f"real:{rel}", p, _read_text(p))

    # Always include live L7 identity + atoms (current, not only seeded)
    for name in [
        "AGENTS.md",
        "ATOMS.md",
        "SOUL.md",
        "TOOLS.md",
        "IDENTITY.md",
        "HEARTBEAT.md",
        "BOOTSTRAP.md",
        "FOUNDERS_DRAFT.md",
        "hermes-notes.md",
        "USER.md",
    ]:
        p = L7_DIR / name
        if p.exists():
            _add_doc(docs, f"l7root:{name}", p, _read_text(p))

    # Skills (guidance layer)
    for skill_md in (L7_DIR / "skills").glob("*/SKILL.md"):
        _add_doc(docs, f"skill:{skill_md.parent.name}", skill_md, _read_text(skill_md))
        ref = skill_md.parent / "references"
        if ref.exists():
            for p in ref.rglob("*.md"):
                _add_doc(docs, f"ref:{skill_md.parent.name}:{p.name}", p, _read_text(p))

    # Runtime docs
    rt = L7_DIR / "programs" / "skill-runtime"
    for rel in ["README.md", "QUALITY_REPORT.md"]:
        p = rt / rel
        if p.exists():
            _add_doc(docs, f"runtime:{rel}", p, _read_text(p))

    # Founder ops trees (bounded) — chosen defaults for "real corpus"
    default_founder_roots = [
        L7_DIR / "work" / "memory",
        L7_DIR / "research",
        L7_DIR / "governance",
        L7_DIR / "council",
        L7_DIR / "salt",  # sealed doctrine / decrees (markdown)
        L7_DIR / "state" / "skill-runtime" / "rag",  # eval reports as meta-docs
    ]
    for root in default_founder_roots:
        if not root.exists():
            continue
        for p in _iter_files(root):
            # skip large json indexes
            if p.suffix.lower() == ".json" and p.stat().st_size > 100_000:
                continue
            try:
                rel = p.relative_to(L7_DIR)
            except ValueError:
                rel = p.name
            _add_doc(docs, f"founder:{rel}", p, _read_text(p, max_chars=80_000))

    if extra_roots:
        docs.extend(collect_from_roots(list(extra_roots), id_prefix="extra"))

    return docs


def build_index(
    force: bool = False,
    profile: str = "default",
    roots: Optional[Sequence[Path]] = None,
    include_default: bool = True,
) -> Dict[str, Any]:
    path = index_path(profile)
    if path.exists() and not force and not roots:
        data = json.loads(path.read_text())
        return {
            "rebuilt": False,
            "profile": profile,
            "index_path": str(path),
            "chunks": len(data.get("chunks", [])),
            "vocab": len(data.get("idf", {})),
            "documents": data.get("documents", 0),
        }

    if profile == "real-corpus":
        raw_docs = collect_real_corpus_documents(extra_roots=roots)
    elif include_default:
        raw_docs = collect_default_documents()
        if roots:
            raw_docs.extend(collect_from_roots(list(roots), id_prefix="extra"))
    elif roots:
        raw_docs = collect_from_roots(list(roots), id_prefix="extra")
    else:
        raw_docs = []

    # de-dupe by source path, then by content fingerprint (seeded copy vs live file)
    seen_src = set()
    seen_fp = set()
    deduped = []
    for d in raw_docs:
        if d["source"] in seen_src:
            continue
        seen_src.add(d["source"])
        # fingerprint: normalize whitespace, first 2k chars
        norm = re.sub(r"\s+", " ", d["text"]).strip()[:2000]
        fp = hash(norm)
        if fp in seen_fp:
            continue
        seen_fp.add(fp)
        deduped.append(d)
    raw_docs = deduped

    chunks: List[Dict[str, Any]] = []
    for doc in raw_docs:
        for i, sec in enumerate(_chunk_sections(doc["text"])):
            body = sec["text"]
            heading = sec.get("heading") or ""
            # Heading tokens get extra weight so "Law XV" beats random body hits
            tokens = _tokenize(body) + (_tokenize(heading) * 3)
            if len(tokens) < 5:
                continue
            tf = Counter(tokens)
            chunks.append(
                {
                    "id": f"{doc['id']}#{i}",
                    "source": doc["source"],
                    "parent": doc["id"],
                    "heading": heading,
                    "text": body,
                    "tf": dict(tf),
                    "len": len(tokens),
                }
            )

    df: Counter = Counter()
    for ch in chunks:
        df.update(ch["tf"].keys())
    n = max(len(chunks), 1)
    idf = {term: math.log((n + 1) / (df[term] + 1)) + 1.0 for term in df}

    for ch in chunks:
        weight_sq = 0.0
        weights = {}
        for term, freq in ch["tf"].items():
            w = (freq / ch["len"]) * idf.get(term, 0.0)
            weights[term] = w
            weight_sq += w * w
        ch["weights"] = weights
        ch["norm"] = math.sqrt(weight_sq) or 1.0
        del ch["tf"]

    payload = {
        "version": 3,
        "chunking": "heading-aware",
        "profile": profile,
        "documents": len(raw_docs),
        "chunks": chunks,
        "idf": idf,
        "sources": sorted({d["source"] for d in raw_docs}),
    }
    INDEX_DIR.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload))
    return {
        "rebuilt": True,
        "profile": profile,
        "index_path": str(path),
        "chunks": len(chunks),
        "vocab": len(idf),
        "documents": len(raw_docs),
        "sources_sample": payload["sources"][:15],
    }


def _load(profile: str = "default") -> Dict[str, Any]:
    path = index_path(profile)
    if not path.exists():
        build_index(force=True, profile=profile)
    return json.loads(path.read_text())


# Surgical L7 domain expansions — only when query matches; not global synonym soup.
_L7_QUERY_EXPANDERS: List[Tuple[re.Pattern, List[str]]] = [
    (
        re.compile(
            r"(dual\s*factor|two\s+factors?|factors?\s+.*\bwrite\b|\bwrite\b.*factors?|"
            r"allows?\s+a\s+write|before\s+.*\bwrite\b|write\s*gate)",
            re.I,
        ),
        ["auth", "fingerprint", "passphrase", "a1", "a4", "dual", "factor", "write", "gate"],
    ),
    (
        re.compile(
            r"(gateway.{0,40}(router|forge)|(router|forge).{0,40}gateway|"
            r"not\s+a\s+(dumb\s+)?router|gateway\s+is\s+a\s+forge|law\s+xxv)",
            re.I,
        ),
        ["gateway", "forge", "router", "law", "i", "xxv", "flows"],
    ),
    (
        re.compile(
            r"(founder.{0,40}access|free\s+forever\s+access|cannot\s+be\s+locked\s+out|"
            r"perpetual.{0,20}access|law\s+xv)",
            re.I,
        ),
        ["founder", "law", "xv", "perpetual", "unrestricted", "philosopher"],
    ),
]


def _expand_query_tokens(query: str, base_tokens: List[str]) -> List[str]:
    extra: List[str] = []
    for pattern, terms in _L7_QUERY_EXPANDERS:
        if pattern.search(query):
            extra.extend(terms)
    if not extra:
        return base_tokens
    return base_tokens + extra


def search(query: str, k: int = 5, profile: str = "default") -> List[Dict[str, Any]]:
    data = _load(profile)
    idf = data["idf"]
    q_tokens = _expand_query_tokens(query, _tokenize(query))
    if not q_tokens:
        return []
    q_tf = Counter(q_tokens)
    q_len = len(q_tokens)
    q_weights = {}
    q_norm_sq = 0.0
    for term, freq in q_tf.items():
        w = (freq / q_len) * idf.get(term, 0.0)
        q_weights[term] = w
        q_norm_sq += w * w
    q_norm = math.sqrt(q_norm_sq) or 1.0

    scored: List[Tuple[float, Dict[str, Any]]] = []
    for ch in data["chunks"]:
        dot = 0.0
        for term, qw in q_weights.items():
            cw = ch["weights"].get(term)
            if cw:
                dot += qw * cw
        score = dot / (q_norm * ch["norm"])
        if score > 0:
            scored.append(
                (
                    score,
                    {
                        "score": round(score, 4),
                        "id": ch["id"],
                        "source": ch["source"],
                        "parent": ch["parent"],
                        "heading": ch.get("heading") or "",
                        "text": ch["text"][:700],
                    },
                )
            )
    scored.sort(key=lambda x: -x[0])
    return [item for _, item in scored[:k]]


def evaluate(
    cases: Sequence[Dict[str, Any]],
    profile: str = "default",
    k: int = 5,
) -> Dict[str, Any]:
    """
    cases fields:
      - expect_heading_any: substrings that must appear in hit.heading (strict / passage-level)
      - expect_any: substrings in source|parent|heading|text (weak / file-level, legacy)
      - require_top1: if true, strict match must be rank 1

    Metrics:
      - weak_hit: expect_any matched somewhere in top-k
      - strict_hit: expect_heading_any matched on a top-k heading (or expect_any if no heading expects)
      - top1_strict: strict criteria met by rank-1 only
    """
    results = []
    weak_hits = 0
    strict_hits = 0
    top1_strict = 0

    for case in cases:
        q = case["query"]
        expect_weak = [e.lower() for e in case.get("expect_any", [])]
        expect_head = [e.lower() for e in case.get("expect_heading_any", [])]
        require_top1 = bool(case.get("require_top1", False))
        ranked = search(q, k=k, profile=profile)

        weak = False
        weak_on = None
        strict = False
        strict_on = None
        strict_rank = None

        for rank, h in enumerate(ranked, start=1):
            heading = (h.get("heading") or "").lower()
            blob = f"{h.get('source','')} {h.get('parent','')} {heading} {h.get('text','')}".lower()

            if not weak:
                for e in expect_weak:
                    if e in blob:
                        weak = True
                        weak_on = e
                        break

            # Strict: prefer heading expectations
            if expect_head:
                for e in expect_head:
                    if e in heading:
                        if not strict:
                            strict = True
                            strict_on = e
                            strict_rank = rank
                        break
            else:
                # No heading criterion → strict falls back to weak (documented)
                if weak and not strict:
                    strict = True
                    strict_on = f"weak:{weak_on}"
                    strict_rank = rank

            if strict and weak:
                # can early-exit scanning only if we don't need better rank tracking
                pass

        # recompute top1_strict cleanly
        top1 = False
        if ranked:
            h0 = ranked[0]
            hdg = (h0.get("heading") or "").lower()
            if expect_head:
                top1 = any(e in hdg for e in expect_head)
            elif expect_weak:
                blob0 = f"{h0.get('source','')} {h0.get('parent','')} {hdg} {h0.get('text','')}".lower()
                top1 = any(e in blob0 for e in expect_weak)

        if require_top1:
            strict = top1
            if top1:
                strict_rank = 1

        if weak:
            weak_hits += 1
        if strict:
            strict_hits += 1
        if top1:
            top1_strict += 1

        results.append(
            {
                "id": case.get("id"),
                "query": q,
                "weak_hit": weak,
                "weak_on": weak_on,
                "strict_hit": strict,
                "strict_on": strict_on,
                "strict_rank": strict_rank,
                "top1_strict": top1,
                "hit": strict,  # primary metric is now strict
                "matched_on": strict_on or weak_on,
                "top": [
                    {
                        "score": h["score"],
                        "parent": h["parent"],
                        "source": h["source"],
                        "heading": h.get("heading") or "",
                    }
                    for h in ranked[:3]
                ],
                "notes": case.get("notes", ""),
            }
        )

    n = max(len(cases), 1)
    return {
        "profile": profile,
        "k": k,
        "cases": len(cases),
        "hits": strict_hits,
        "hit_rate": round(strict_hits / n, 3),
        "weak_hits": weak_hits,
        "weak_hit_rate": round(weak_hits / n, 3),
        "strict_hits": strict_hits,
        "strict_hit_rate": round(strict_hits / n, 3),
        "top1_strict_hits": top1_strict,
        "top1_strict_rate": round(top1_strict / n, 3),
        "results": results,
    }
