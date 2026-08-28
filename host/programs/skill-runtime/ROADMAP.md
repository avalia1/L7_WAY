# L7 Skill Runtime — Development Roadmap

**Status:** baseline green (2026-07-22) · **M1 DONE · M2 Forge live DONE (2026-07-22)**  
**Owner:** founder  
**Scope:** `~/.l7/programs/skill-runtime`, `~/.l7/skills`, real-corpus RAG, OpenClaw/L7 integration  

This plan assumes you keep what works and do **not** restart from playground skill sprawl.

### M1 checklist (completed)
- [x] `RUNBOOK.md` + skill links  
- [x] Real finance JSON (`--data`) + schemas + fixtures  
- [x] Incomplete data fails loud  
- [x] Demo mode labeled (`mode`, `data_quality`, `assumptions`)  
- [x] `corpus.json` + `l7 skills corpus` + profile roots  
- [x] Unit tests 12/12 including real/incomplete finance  

### M2 checklist (completed)
- [x] `forge/skill_bridge.py` — tool map → `l7skills.py`  
- [x] `forge/forge_server.py` — GET `/tools`, POST `/execute` on **:7378**  
- [x] `gateway.js` prefers skill-runtime forge before MCP  
- [x] empire `POST /api/execute` accepts `{tool, params}`  
- [x] `l7 forge` CLI (serve / exec / tools)  
- [x] Contract tests 8/8 + HTTP smoke

---

## 0. Current baseline (do not regress)

### What is done
| Layer | State |
|-------|--------|
| Skills pack | 20 skills (playground map + executables + l7-empire) |
| Runtime CLI | `l7 skills` → doctor, list, route, show, validate, ratios, dcf, brand, rag-*, e2e |
| Contracts | `.tool` + `.citizen` + Seven Seals |
| RAG | heading-aware chunks, strict/top1 eval, L7 lexicon expanders, founder roots |
| Quality gates | unit tests 9/9, e2e 16/16, rag strict 16/16, top1 ~11/16 |
| Freeze | no more global TF-IDF hacks; no embeddings until real failure; no new framework guide skills |

### How to re-verify anytime
```bash
l7 skills doctor
l7 skills validate
python3 ~/.l7/programs/skill-runtime/tests/test_runtime.py
l7 skills rag-eval --profile real-corpus
bash ~/.l7/programs/skill-runtime/scripts/e2e_offline.sh
```

### Success metrics to keep
- Unit + e2e always green before merge-like changes  
- RAG **strict@k ≥ 0.9** on golden set  
- Law XV, dual-auth, gateway top1 stay true  
- Doctor validation_errors == 0  

---

## Phase A — Productize daily use (1–2 weeks)

**Goal:** the runtime becomes a habit, not a museum piece.

### A1. Operator runbook (0.5 day)
**Deliverable:** one-page “when to run what.”

| Need | Command |
|------|---------|
| Health | `l7 skills doctor` |
| Find skill | `l7 skills route "…"` |
| Doctrine Q&A | `l7 skills rag-query "…" --profile real-corpus` |
| Finance sample | `l7 skills ratios` / `dcf` |
| Regression | `l7 skills e2e` |

**Steps**
1. Write `~/.l7/programs/skill-runtime/RUNBOOK.md` (link from `l7-empire` skill).  
2. Add 5 “founder prompts” you actually ask.  
3. Put `l7 skills doctor` on weekly heartbeat / calendar.

**Exit criteria:** you can operate without reading ROADMAP.

### A2. Real financial path (1–2 days)
**Deliverable:** input file → ratios/DCF without sample proxies pretending to be truth.

**Steps**
1. Define JSON schema `statements.v1.json` (income, balance, cash, market).  
2. CLI:  
   `l7 skills ratios --data path.json --industry technology`  
   `l7 skills dcf --data path.json --company Name`  
3. Remove silent CSV proxies when `--data` is used; fail loud on missing fields.  
4. Print `assumptions` + `data_quality` block in every result.  
5. One real company fixture (anonymized) + unit test.

**Exit criteria:** sample mode labeled demo; real mode refuses incomplete books.

### A3. Personal / domain corpus slot (1 day)
**Deliverable:** named profile for *your* content when a folder actually has files.

**Steps**
1. Config file `~/.l7/state/skill-runtime/corpus.json`:  
   ```json
   {
     "profiles": {
       "real-corpus": { "roots": ["..."] },
       "founder-notes": { "roots": ["/path/to/notes"] }
     }
   }
   ```
2. CLI: `--profile founder-notes` reads config roots.  
3. Golden eval file per profile (even 5 questions).  
4. Do **not** index empty vault folders.

**Exit criteria:** one non-empty personal/domain profile with eval ≥ 0.8 strict.

### A4. Answer composer (optional, 1 day)
**Deliverable:** not just chunks — a short answer with citations.

```bash
l7 skills rag-answer "What is Law XV?" --profile real-corpus
```

**Steps**
1. Retrieve top-k with headings.  
2. Extractive summary (no LLM required first): quote top heading + 2–3 sentences + source paths.  
3. Later optional: pipe to local model via `l7 dev` / foundation.

**Exit criteria:** answers always include source path + heading.

---

## Phase B — Empire integration (1–2 weeks)

**Goal:** tools/citizens execute through the forge, not only CLI.

### B1. Gateway execute adapter (2–3 days)
**Deliverable:** empire/MCP path calls skill-runtime.

**Steps**
1. Map tool names → CLI:  
   - `financial_ratios` → `ratios`  
   - `dcf_valuation` → `dcf`  
   - `rag_pipeline` + action query → `rag-query`  
2. Implement handler in empire server or thin Node/Python bridge:  
   `POST /execute { tool, params }` → `subprocess` `l7skills.py` → JSON envelope.  
3. Audit already exists; append `who=gateway`.  
4. Contract tests: execute ratios via HTTP returns same envelope as CLI.

**Exit criteria:** one dashboard or `curl` path runs ratios without shelling by hand.

### B2. OpenClaw skill that forces runtime (0.5–1 day)
**Deliverable:** when agent is in L7 workspace, financial/RAG questions call `l7 skills`, not free invention.

**Steps**
1. Update `l7-empire` / `rag-pipeline` / `financial-ratios` bodies: “MUST run CLI for facts.”  
2. Ensure `l7dev` allowlist still has these skills.  
3. Consider tool profile: if coding + skills, expand beyond minimal when needed.  
4. Smoke: ask l7dev “Law XV?” and confirm exec/read of runtime.

**Exit criteria:** agent cites CLI output or skill path, not hallucinated law text.

### B3. Flow wiring (1 day)
**Deliverable:** `.flow` files that chain real steps.

Examples:
- `doctrine_qa.flow` → rag-query → optional answer compose  
- `finance_review.flow` → ratios → dcf → brand (report shell)  
- approval=true on any external side effects later  

**Exit criteria:** `node executor` or empire flow runner completes one flow offline.

### B4. Citizen status hygiene (0.5 day)
**Deliverable:** status reflects reality.

- `serving` only if execute path works  
- `formed` if declared but CLI-only  
- Deprecate stale playground tools without skills  

---

## Phase C — Retrieval quality (only if real work fails)

**Goal:** improve recall/precision without eval theater.

### C1. Top-1 cleanup (1–2 days)
**Targets:** cases that are strict@k but not top1  
(`skill-runtime-cli`, `rag-pipeline-skill`, `apprentice`, `tool-contract`, `citizenship`)

**Steps**
1. For each fail: dump top-5 headings.  
2. Prefer heading-query overlap re-rank (cheap) over embeddings.  
3. Fix chunk boundaries (preamble pollution on SKILL.md).  
4. Re-run eval; require top1 ≥ 0.8 without weakening cases.

### C2. Profile-specific lexicon (0.5 day)
**Steps**
1. Move expanders to `lexicon/real-corpus.json`.  
2. Domain profile gets its own lexicon (AVLI/DIAL terms later).  
3. Unit-test: query Q expands to expected tokens.

### C3. Embeddings upgrade (3–5 days) — **gate**
**Only if:** a real notes corpus has strict@k < 0.7 on 20 founder questions.

**Steps**
1. Local embeddings (e.g. sentence-transformers or Ollama embed) offline.  
2. Store vectors in Chroma under `~/.l7/state/skill-runtime/chroma/`.  
3. Hybrid: TF-IDF candidate gen + embed re-rank.  
4. Keep heading metadata.  
5. Dual eval: lexical vs hybrid.

**Exit criteria:** hybrid beats lexical on the 20-question set by ≥10 points strict@k.

### C4. Dedup & corpus governance (1 day)
**Steps**
1. Manifest of indexed sources with mtime hash.  
2. Incremental reindex (changed files only).  
3. Exclude salt/eval JSON pollution from retrieval (meta docs optional profile).  
4. Size budget: warn if chunks > 5k or index > 50MB.

---

## Phase D — Domain products (AVLI / DIAL / NCLS)

**Goal:** playground map becomes a substrate; domain skills do the real work.

### D1. Domain skill template (0.5 day)
Each domain skill must have:
- SKILL.md + Seven Seals  
- `.tool` + `.citizen`  
- `references/sources.md` with **real paths**  
- Optional `scripts/` or runtime actions  
- Eval cases (min 5)  

### D2. `avli-rag` or `dial-knowledge` (2–4 days)
**Steps**
1. Inventory allowed corpora (docs, Notion export, local markdown).  
2. Profile + roots in corpus.json.  
3. Secrets policy: never index `.env`, tokens, vault.  
4. Eval against real operator questions.  
5. Route from `ai-playground-index` → domain skill when keywords match.

### D3. Operational skills (as needed)
Examples (only when a weekly task exists):
- deploy checklist against Coolify/Traefik notes  
- incident runbook  
- mail/onboarding templates  

**Rule:** no skill without a recurring task owner.

---

## Phase E — Hardening & ops (ongoing)

### E1. CI-like local gate
```bash
# pre-commit or weekly cron
l7 skills e2e && l7 skills rag-eval --profile real-corpus
```
Fail on strict regression > 1 case or unit fail.

### E2. Versioning
- `runtime/__init__.py` version bump on breaking CLI  
- Index version already in JSON; migrate on mismatch  
- Changelog in `QUALITY_REPORT.md` or `CHANGELOG.md`

### E3. Security
- Audit every executable  
- approval=true for anything that writes outside `~/.l7/state`  
- Never log full financial PII in audit (hash or redact)  
- Corpus roots must not include `.vault` / credentials  

### E4. Performance
- Cache loaded index in memory for CLI process (optional)  
- Parallel file walk if roots grow  
- Keep pure-Python path as fallback when ML stack missing  

---

## Suggested calendar

| Week | Focus | Outcome |
|------|--------|---------|
| **1** | A1 runbook + A2 real finance schema | Daily usable finance path |
| **2** | A3 domain/personal profile + A4 answers | Real corpus Q&A with citations |
| **3** | B1 gateway execute + B2 OpenClaw discipline | Tools actually fire |
| **4** | B3 flows + E1 weekly gate | Repeatable ops |
| **5+** | D domain skills OR C3 embeddings if eval fails | Product surface |

If time is scarce: **Week 1 only (A1+A2)** still compounds.

---

## Decision gates (do / don’t)

| Idea | Do when | Don’t when |
|------|---------|------------|
| More playground skills | Used twice in a week | “Might be nice” |
| Embeddings | Personal corpus strict < 0.7 | Doctrine already works |
| Gateway hook | You run CLI daily | No one invokes tools |
| Multi-agent Autogen skill depth | Real multi-agent job | Single-agent tool loop enough |
| Public ClawHub publish | Sanitized, no founder paths | Contains home paths / audit |

---

## Work breakdown (first implementable slice)

### Milestone M1 — “Founder daily” (recommended next implementation)
1. `RUNBOOK.md`  
2. `ratios --data` / `dcf --data` with schema + tests  
3. `corpus.json` + one personal profile if folder non-empty  
4. Document freezes in DECISIONS.md (already exists)  

### Milestone M2 — “Forge live”
1. `/execute` → subprocess skill-runtime  
2. Contract tests  
3. Update citizen status  

### Milestone M3 — “Domain”
1. `avli-rag` or `dial-knowledge`  
2. Eval set of 10 real questions  
3. Router updates in `ai-playground-index`  

---

## Risks & mitigations

| Risk | Mitigation |
|------|------------|
| Eval theater | Keep strict + top1; never loosen cases to pass |
| Path drift | Validator path checks; corpus manifest |
| Secret leakage | Root denylist; audit redaction |
| Scope creep | One milestone at a time; freeze list |
| l7dev too weak | Separate “explore” vs “execute” agent profiles |

---

## Definition of “done” for the overall system

The skill system is “developed enough” when:

1. You resolve ≥3 real questions/week via `rag-query` or domain profile.  
2. At least one non-demo financial run is trusted enough to keep.  
3. Gateway or OpenClaw can invoke executables without manual CLI.  
4. Weekly e2e + rag-eval stay green.  
5. New skills only appear with task + eval + owner.

Until then, prefer **use and M1** over new architecture.

---

## Appendix — Key paths

```
~/.l7/programs/skill-runtime/          # runtime
~/.l7/programs/skill-runtime/ROADMAP.md
~/.l7/skills/                          # agent skills
~/.l7/tools/  ~/.l7/citizens/          # contracts
~/.l7/state/skill-runtime/rag/         # indexes + eval reports
~/.l7/state/skill-runtime/DECISIONS.md # historical choices
~/.l7/state/skill-runtime/rag/STEP_PROGRESS.md
```

## Appendix — Command cheat sheet

```bash
l7 skills doctor
l7 skills route "build multi-agent research"
l7 skills rag-query "What is Law XV?" --profile real-corpus -k 5
l7 skills rag-eval --profile real-corpus
l7 skills ratios --period Q4_2024
l7 skills dcf --company Acme
l7 skills e2e
```

## Done 2026-07-22 — Alchemy + forge on reorganized home
- Skills alchemy-* + project_index forge tools
- Transmuted ~/Projects, ~/L7_WAY, openclaw, skill-runtime
- Seals in state/skill-runtime/alchemy/
- Commit b9edece
