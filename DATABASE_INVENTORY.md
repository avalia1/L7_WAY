# L7 WAY Database Inventory & Asset Map
**Generated:** 2026-02-28
**System:** macOS Darwin 25.3.0 (arm64), rnir_hrc_avd user

---

## Quick Overview

### Your Databases at a Glance

You own and control **19 SQLite databases** across three major projects:

| Project | Count | Size | Purpose |
|---------|-------|------|---------|
| **Knowledge Graph (NCLS)** | 3 | 282.9 MB | Vector embeddings, intelligence extraction |
| **LLM Scrapper** | 4 | 115.4 MB | Relationship graphs, data synthesis |
| **AVLI Cloud 2.0** | 10 | ~10 MB | Entity tracking, games, telemetry indexes |
| **Research & Tools** | 2 | 34.2 MB | NC Life Study, Raptor experiments |

**Total: 405.4 MB across 19 databases**

---

## Tier 1: CRITICAL KNOWLEDGE (High Value)

These databases contain synthesized intelligence and structured knowledge.

### 1. Knowledge Graph Chroma DB
**Size:** 264.9 MB
**Type:** Vector database (Chroma)
**Location:** `/Users/rnir_hrc_avd/Backup/NCLS_SCRIPTS/SCRIPTS/knowledge_graph/chroma_db/chroma.sqlite3`
**Modified:** 2026-02-01T01:10:02
**Purpose:** Embeddings, semantic search, knowledge representation
**Status:** ACTIVE - Core asset

This is your largest database. It contains:
- Vector embeddings of processed documents
- Semantic relationships between concepts
- Search indices for knowledge retrieval

**Preservation:** CRITICAL - This represents accumulated learning and synthesis.

---

### 2. True Graph Database
**Size:** 62.2 MB
**Type:** Relationship graph
**Location:** `/Users/rnir_hrc_avd/Backup/Scripts/llm_assisted_scrapper/true_graph.db`
**Modified:** 2026-02-04T01:26:03
**Purpose:** Fact extraction, entity relationships, ground truth synthesis
**Status:** ACTIVE - Primary output

Generated from LLM-assisted scraping of research sources.

**Preservation:** CRITICAL - Foundation of knowledge synthesis.

---

### 3. NC Life Study Timeline
**Size:** 33.3 MB
**Type:** Research database
**Location:** `/Users/rnir_hrc_avd/Backup/Downloads/NC_LIFE_STUDY_TIMELINE.db`
**Modified:** 2025-12-11T17:30:58
**Purpose:** Temporal data, biographical research, NC LIFE project
**Status:** ACTIVE - Research archive

Historical and longitudinal research data.

**Preservation:** HIGH - Irreplaceable research corpus.

---

### 4. Comprehensive Graph Database
**Size:** 24.2 MB
**Type:** Relationship graph
**Location:** `/Users/rnir_hrc_avd/Backup/Scripts/llm_assisted_scrapper/comprehensive_graph.db`
**Modified:** 2026-02-04T01:26:04
**Purpose:** Unified relationship map, cross-referencing
**Status:** ACTIVE - Synthesis layer

Aggregated relationships across all scraped sources.

**Preservation:** CRITICAL - High-order synthesis.

---

## Tier 2: INTELLIGENCE EXTRACTION (Medium Value)

### 5. Intelligence Extraction Chroma DB
**Size:** 9.2 MB
**Type:** Vector database
**Location:** `/Users/rnir_hrc_avd/Backup/NCLS_SCRIPTS/SCRIPTS/intelligence_extraction/intelligence_extraction_db/chroma.sqlite3`
**Modified:** 2026-02-02T10:17:07
**Purpose:** Extracted insights, summary embeddings
**Status:** ACTIVE - Processing pipeline

Derived from knowledge graph via extraction pipeline.

---

### 6. AVLI Cloud Entity Platform
**Size:** 9.5 MB
**Type:** Entity database
**Location:** `/Users/rnir_hrc_avd/Backup/00_PYTHON_PROJECTS/avli_cloud.2.0/databases/IntelligencePlatform.Entity/IntelligencePlatform.Entity.sqlite3`
**Modified:** 2026-02-01T01:24:50
**Purpose:** Entity catalog, relationships, metadata
**Status:** ACTIVE - Platform core

Central entity registry for AVLI Cloud system.

---

## Tier 3: DEVELOPMENT & EXPERIMENTS (Low Volume)

### 7-19: Small Databases (<2 MB each)

| Name | Size | Purpose | Location |
|------|------|---------|----------|
| Raptor Chroma | 1.3 MB | Experiment - RAG vectorization | `.../Obsidian Vault/.../raptor/` |
| Entity Rebuild | 271 KB | Backup - Full rebuild state | `...avli_cloud.2.0/.../Entity/` |
| Open WebUI Chroma | 160 KB | Tool integration test | `...open-webui/vector_db/` |
| Games.RecentlyPlayed | 73 KB | Platform test data | `...avli_cloud.2.0/.../Games/` |
| Immutable Truth Backup | 73 KB | Archive - 2025-12-07 backup | `.../llm_assisted_scrapper/` |
| LexisNexis Graph | 60 KB | Research data stub | `.../llm_assisted_scrapper/` |
| First Party Sets | 49 KB | Browser research metadata | `.../NCLS_SCRIPTS/.playwright/` |
| Flow Transcript Indexes | 40 KB | System metadata | `...avli_cloud.2.0/.../Indexes/` |
| Siri Engagement Indexes | 28 KB | System metadata | `...avli_cloud.2.0/.../Indexes/` |
| Yearbooks | 20 KB | VPS recovery archive | `.../VPS RECOVERY/avli_cloud/` |
| Flow Telemetry Indexes | 12 KB | System metadata | `...avli_cloud.2.0/.../Indexes/` |
| Games Rebuild 1 & 2 | 12 KB each | Backup copies | `...avli_cloud.2.0/.../Games/` |

---

## Project Architecture Map

```
YOUR DATABASES (405.4 MB)
│
├─ NCLS_SCRIPTS (293.1 MB)
│  ├─ knowledge_graph/
│  │  └─ chroma_db/chroma.sqlite3 (264.9 MB)  [TIER 1: Core Knowledge]
│  │
│  └─ intelligence_extraction/
│     └─ intelligence_extraction_db/chroma.sqlite3 (9.2 MB)  [TIER 2: Processing]
│
├─ Scripts/llm_assisted_scrapper/ (101.8 MB)
│  ├─ true_graph.db (62.2 MB)  [TIER 1: Truth Synthesis]
│  ├─ comprehensive_graph.db (24.2 MB)  [TIER 1: Unified Relationships]
│  ├─ immutable_truth.db.backup_20251207_081632 (73 KB)
│  └─ lexisnexis_graph.db (60 KB)
│
├─ 00_PYTHON_PROJECTS/avli_cloud.2.0/ (9.9 MB)
│  ├─ IntelligencePlatform.Entity/ (9.8 MB)  [TIER 2: Entity Registry]
│  ├─ Games.RecentlyPlayed/ (97 KB)  [TIER 3: Test Data]
│  ├─ IntelligenceFlow.Transcript/ (40 KB)  [TIER 3: Metadata]
│  ├─ Siri.PostSiriEngagement/ (28 KB)  [TIER 3: Metadata]
│  └─ IntelligenceFlow.Telemetry/ (12 KB)  [TIER 3: Metadata]
│
├─ Downloads/ (33.3 MB)
│  └─ NC_LIFE_STUDY_TIMELINE.db (33.3 MB)  [TIER 1: Research Archive]
│
├─ VPS RECOVERY/avli_cloud/ (20 KB)
│  └─ yearbooks.sqlite (20 KB)  [TIER 3: Archive]
│
└─ Documents/Obsidian Vault/ (1.3 MB)
   └─ llama_index/.../raptor/ (1.3 MB)  [TIER 3: Experiment]
```

---

## Integration Points

### Knowledge Graph Flow
```
NCLS_SCRIPTS/
  └─ SCRIPTS/
     ├─ knowledge_graph/chroma_db/ (INPUT: raw knowledge embeddings)
     │  └─ chroma.sqlite3 (264.9 MB)
     │
     └─ intelligence_extraction/ (PROCESSING)
        └─ chroma.sqlite3 (9.2 MB, derived from knowledge_graph)
```

### LLM Scrapper Pipeline
```
Scripts/llm_assisted_scrapper/ (PROCESSING LAYER)
├─ true_graph.db (62.2 MB, source-specific relationships)
├─ comprehensive_graph.db (24.2 MB, unified synthesis)
└─ immutable_truth.db.backup (archive)
```

### AVLI Cloud Platform
```
00_PYTHON_PROJECTS/avli_cloud.2.0/databases/
├─ IntelligencePlatform.Entity/ (entity catalog)
├─ Games.RecentlyPlayed/ (feature modules)
├─ IntelligenceFlow.* (system indexes)
└─ Siri.* (integration hooks)
```

---

## Storage & Redundancy Analysis

### Size Distribution
```
264.9 MB |████████████████████████████████████████ Chroma Knowledge Graph
 62.2 MB |██████████                              True Graph
 33.3 MB |█████                                   NC Life Study
 24.2 MB |███                                     Comprehensive Graph
  9.5 MB |█                                       AVLI Entity Platform
  9.2 MB |█                                       Intelligence Extraction
  1.3 MB |                                        Raptor Experiment
  0.8 MB |                                        Other (< 1 MB each)
──────────────────────────────────────────────────────────────────
405.4 MB TOTAL YOUR DATABASES
```

### Backup Status

**External Backups Detected:**
- `/Volumes/SYSTEM2/` - External system copy (14.4 MB certificate bundle)
- `Backup/VPS RECOVERY/avli_cloud/` - Remote VPS archive
- Multiple `-fullRebuild` and `-backup` files

**Tier 1 Databases Appear in Multiple Locations:**
- Knowledge Graph: Primary location only (single copy, 264.9 MB)
- True Graph: Primary location only (single copy, 62.2 MB)

**Recommendation:** Implement automated daily backups to encrypted vault for Tier 1 assets.

---

## Maintenance Checklist

### CRITICAL (Tier 1) - Review Monthly
- [ ] Chroma Knowledge Graph (264.9 MB)
- [ ] True Graph Database (62.2 MB)
- [ ] NC Life Study Timeline (33.3 MB)
- [ ] Comprehensive Graph (24.2 MB)

**Action:** Verify integrity, confirm backups exist, check modification dates.

### IMPORTANT (Tier 2) - Review Quarterly
- [ ] Intelligence Extraction Chroma (9.2 MB)
- [ ] AVLI Cloud Entity Platform (9.5 MB)

**Action:** Archive if inactive for 6+ months.

### OPTIONAL (Tier 3) - Review Annually
- [ ] Experiment databases (<2 MB each)
- [ ] Backup/rebuild copies

**Action:** Clean up outdated backups, consolidate redundant copies.

---

## Quick Access Paths

### View All Your Databases
```bash
find ~/Backup/NCLS_SCRIPTS ~/Backup/Scripts/llm_assisted_scrapper ~/Backup/00_PYTHON_PROJECTS/avli_cloud* ~/Backup/Downloads -name "*.db" -o -name "*.sqlite3" | sort
```

### Get Total Size
```bash
du -sh ~/Backup/NCLS_SCRIPTS ~/Backup/Scripts/llm_assisted_scrapper ~/Backup/00_PYTHON_PROJECTS/avli_cloud*
```

### Monitor Changes (Last 7 Days)
```bash
find ~/Backup/NCLS_SCRIPTS ~/Backup/Scripts -type f \( -name "*.db" -o -name "*.sqlite3" \) -mtime -7
```

### Inspect Database Schema (Chroma)
```bash
sqlite3 ~/Backup/NCLS_SCRIPTS/SCRIPTS/knowledge_graph/chroma_db/chroma.sqlite3 ".schema"
```

---

## Summary

**You control 19 SQLite databases totaling 405.4 MB:**

- **65% (264.9 MB):** Knowledge Graph (Chroma) — your largest single asset
- **26% (101.8 MB):** Graph synthesis from LLM scraping
- **8% (33.3 MB):** Research data archives
- **<1% (< 5 MB):** Platform infrastructure, experiments, and metadata

**The crown jewel: Knowledge Graph Chroma DB (264.9 MB)** — represents vectorized, semantically indexed knowledge synthesized from research and learning. This is irreplaceable without the original source documents.

**Backup Priority:**
1. Chroma Knowledge Graph
2. True Graph + Comprehensive Graph
3. NC Life Study Timeline
4. Everything else (lower value)

All data is currently in `/Users/rnir_hrc_avd/Backup/` (local storage). No cloud sync detected. Consider implementing automated encrypted backups to external storage or vault.
