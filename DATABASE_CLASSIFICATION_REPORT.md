# SQLite Database Classification Report
**Generated:** 2026-02-28
**Total Databases Analyzed:** 511
**Total Storage:** ~2.40 GB

---

## Executive Summary

The 511 SQLite databases on your system have been classified into four categories:

| Category | Count | Total Size | % of Total |
|----------|-------|-----------|-----------|
| **SYSTEM** | 185 | 1.56 GB | 64.98% |
| **APP DATA** | 203 | 184.2 MB | 7.55% |
| **OTHER** | 126 | 107.3 MB | 4.40% |
| **AVLI/L7 ORIGINAL** | 19 | **405.4 MB** | **16.64%** |

---

## Category Breakdown

### 1. AVLI/L7 ORIGINAL (19 databases, 405.4 MB)

**These are YOUR databases** — created by your own software projects (NCLS Scripts, AVLI Cloud, LLM Scrapper, Intelligence Extraction).

#### Complete Listing (sorted by size):

1. **chroma.sqlite3** (264.9 MB)
   Path: `/Users/rnir_hrc_avd/Backup/NCLS_SCRIPTS/SCRIPTS/knowledge_graph/chroma_db/chroma.sqlite3`
   Modified: 2026-02-01T01:10:02
   Purpose: Vector database for knowledge graph embeddings

2. **true_graph.db** (62.2 MB)
   Path: `/Users/rnir_hrc_avd/Backup/Scripts/llm_assisted_scrapper/true_graph.db`
   Modified: 2026-02-04T01:26:03
   Purpose: Graph database from scrapper results

3. **NC_LIFE_STUDY_TIMELINE.db** (33.3 MB)
   Path: `/Users/rnir_hrc_avd/Backup/Downloads/NC_LIFE_STUDY_TIMELINE.db`
   Modified: 2025-12-11T17:30:58
   Purpose: NCLS research data

4. **comprehensive_graph.db** (24.2 MB)
   Path: `/Users/rnir_hrc_avd/Backup/Scripts/llm_assisted_scrapper/comprehensive_graph.db`
   Modified: 2026-02-04T01:26:04
   Purpose: Comprehensive relationship graph

5. **IntelligencePlatform.Entity.sqlite3** (9.5 MB)
   Path: `/Users/rnir_hrc_avd/Backup/00_PYTHON_PROJECTS/avli_cloud.2.0/databases/IntelligencePlatform.Entity/IntelligencePlatform.Entity.sqlite3`
   Modified: 2026-02-01T01:24:50
   Purpose: AVLI Cloud entity database

6. **chroma.sqlite3** (9.2 MB)
   Path: `/Users/rnir_hrc_avd/Backup/NCLS_SCRIPTS/SCRIPTS/intelligence_extraction/intelligence_extraction_db/chroma.sqlite3`
   Modified: 2026-02-02T10:17:07
   Purpose: Intelligence extraction vector store

7. **chroma.sqlite3** (1.3 MB)
   Path: `/Users/rnir_hrc_avd/Backup/Documents/Obsidian Vault/00 AI Playground/llama_index/llama-index-packs/llama-index-packs-raptor/examples/raptor/chroma.sqlite3`
   Modified: 2025-12-03T02:09:51
   Purpose: Raptor example vector database

8. **IntelligencePlatform.Entity-fullRebuild.sqlite3** (271 KB)
   Path: `/Users/rnir_hrc_avd/Backup/00_PYTHON_PROJECTS/avli_cloud.2.0/databases/IntelligencePlatform.Entity/IntelligencePlatform.Entity-fullRebuild.sqlite3`
   Modified: 2026-01-30T11:23:26
   Purpose: AVLI Cloud rebuild state

9. **chroma.sqlite3** (160 KB)
   Path: `/Users/rnir_hrc_avd/Backup/gen_questions/data/open-webui/vector_db/chroma.sqlite3`
   Modified: 2026-01-02T03:49:31
   Purpose: Open WebUI vector store

10. **Games.RecentlyPlayed.sqlite3** (72 KB)
    Path: `/Users/rnir_hrc_avd/Backup/00_PYTHON_PROJECTS/avli_cloud.2.0/databases/Games.RecentlyPlayed/Games.RecentlyPlayed.sqlite3`
    Modified: 2026-02-01T01:26:21
    Purpose: AVLI Cloud games data

*Plus 9 additional smaller AVLI/L7 databases (under 50 KB each)*

---

### 2. SYSTEM (185 databases, 1.56 GB)

**macOS system infrastructure databases** — required by the OS and system frameworks. These can be safely ignored unless investigating system behavior.

#### Top 5 Largest:

1. **index.sql** (1.32 GB)
   Path: `/System/Library/AssetsV2/com_apple_MobileAsset_AppleDeveloperDocumentation/.../index.sql`
   Modified: 2026-02-17T15:13:38
   Purpose: Apple Developer Documentation asset cache

2. **world.geokit** (50.4 MB)
   Path: `/System/Library/PrivateFrameworks/GeoKit.framework/Versions/A/Resources/world.geokit`
   Modified: 2026-02-05T05:13:23
   Purpose: Geolocation database (read-only)

3. **CurrentPowerlog.PLSQL** (14.3 MB)
   Path: `/private/var/db/powerlog/Library/BatteryLife/CurrentPowerlog.PLSQL`
   Modified: 2026-02-28T17:14:25
   Purpose: Battery and power management logs

4. **valid.sqlite3** (13.6 MB) — Trust database
   Path: `/private/var/protected/trustd/valid.sqlite3`
   Modified: 2026-02-27T21:54:50
   Purpose: Certificate trust store

5. **valid.sqlite3** (12.7 MB) — Certificates bundle
   Path: `/System/Library/Security/Certificates.bundle/Contents/Resources/valid.sqlite3`
   Modified: 2026-02-05T05:13:23
   Purpose: System certificate store

**Composition:** Certificates, geolocation, power logs, framework resources, font registries, personality models, and system policies.

---

### 3. APP DATA (203 databases, 184.2 MB)

**Third-party and Apple application databases** — including Xcode, iOS Simulator, Maps, Photos, and Safari.

#### Top 5 Largest:

1. **globalKnowledge.db** (50.8 MB)
   Path: `/Users/rnir_hrc_avd/Library/Developer/CoreSimulator/Devices/.../Library/IntelligencePlatform/globalKnowledge.db`
   Modified: 2026-02-28T01:17:52
   Purpose: iOS Simulator Intelligence Platform

2. **cache.db** (34.9 MB)
   Path: `/Applications/Xcode.app/Contents/SharedFrameworks/DNTDocumentationSupport.framework/.../cache.db`
   Modified: 2026-01-09T18:49:11
   Purpose: Xcode documentation cache

3. **valid.sqlite3** (13.6 MB)
   Path: `/Users/rnir_hrc_avd/Library/Developer/CoreSimulator/Devices/.../private/var/protected/trustd/valid.sqlite3`
   Modified: 2026-02-28T01:18:31
   Purpose: iOS Simulator trust store

4. **valid.sqlite3** (13.5 MB)
   Path: `/Library/Developer/CoreSimulator/Volumes/iOS_23C54/.../Certificates.bundle/valid.sqlite3`
   Modified: 2025-12-06T03:10:46
   Purpose: iOS runtime certificate store

5. **CloudAutoFillCorrections.db** (11.8 MB)
   Path: `/Users/rnir_hrc_avd/Library/Developer/CoreSimulator/Devices/.../Safari/CloudAutoFillCorrections.db`
   Modified: 2026-02-28T01:20:39
   Purpose: Safari autofill data in simulator

**Composition:** Mostly iOS Simulator data, Xcode support files, Maps cache, and Safari data.

---

### 4. OTHER (126 databases, 107.3 MB)

**Miscellaneous databases** — mostly Go test data, backups, and other development artifacts.

#### Top 5 Largest:

1. **fuzzdata2.db** (16.2 MB)
   Path: `/Users/rnir_hrc_avd/Backup/go/pkg/mod/modernc.org/sqlite@v1.38.2/testdata/tcl/fuzzdata2.db`
   Modified: 2026-02-01T20:09:50
   Purpose: Go SQLite fuzzing test data

2. **fuzzdata7.db** (16.0 MB)
   Path: `/Users/rnir_hrc_avd/Backup/go/pkg/mod/modernc.org/sqlite@v1.38.2/testdata/tcl/fuzzdata7.db`
   Modified: 2026-02-01T20:09:50
   Purpose: Go SQLite fuzzing test data

3. **valid.sqlite3** (14.4 MB)
   Path: `/Volumes/SYSTEM2/System/Library/Security/Certificates.bundle/Contents/Resources/valid.sqlite3`
   Modified: 2025-10-25T02:22:19
   Purpose: External drive system copy (BACKUP)

4. **fuzzdata3.db** (11.3 MB)
   Path: `/Users/rnir_hrc_avd/Backup/go/pkg/mod/modernc.org/sqlite@v1.38.2/testdata/tcl/fuzzdata3.db`
   Modified: 2026-02-01T20:09:50
   Purpose: Go SQLite fuzzing test data

5. **fuzzdata5.db** (6.9 MB)
   Path: `/Users/rnir_hrc_avd/Backup/go/pkg/mod/modernc.org/sqlite@v1.38.2/testdata/tcl/fuzzdata5.db`
   Modified: 2026-02-01T20:09:50
   Purpose: Go SQLite fuzzing test data

**Composition:**
- Go SQLite test data (~60 MB, mostly fuzzing data)
- Keychains (5.5 MB)
- Backup/duplicate database copies (14.4 MB from SYSTEM2)
- Photos Library backups (5.3 MB)

---

## Key Findings

### "YOURS" (AVLI/L7) vs "FOREIGN"

| Type | Count | Size | Status |
|------|-------|------|--------|
| Your Projects | 19 | 405.4 MB | **Active** |
| Third-Party | 326 | 1.78 GB | **System/App** |
| Unclassified | 126 | 107.3 MB | **Test/Backup** |

### Storage Distribution

```
AVLI/L7 ORIGINAL:    405.4 MB (16.6%)  ← YOUR CRITICAL DATA
APP DATA:            184.2 MB  (7.6%)
OTHER:               107.3 MB  (4.4%)
SYSTEM:            1,563.7 MB (64.2%)  ← READ-ONLY (OS)
────────────────────────────────────────
TOTAL:             2,433.6 MB (2.37 GB)
```

### Largest Single Database

**Apple Developer Documentation** (`index.sql`)
Size: 1.32 GB
Path: `/System/Library/AssetsV2/com_apple_MobileAsset_AppleDeveloperDocumentation/...`
Category: SYSTEM (safe to ignore)

---

## Recommendations

### 1. Core Data to Preserve
Your **19 AVLI/L7 ORIGINAL databases** (405.4 MB total) should be:
- Regularly backed up
- Version controlled (if not already)
- Never deleted without explicit intent
- Indexed for quick discovery

### 2. Safe to Clean
The **126 OTHER databases** (107.3 MB) are mostly:
- Go module test data (can be regenerated: `go clean -modcache`)
- Backup copies from external drives
- Development artifacts

Deleting would recover ~100 MB with minimal impact.

### 3. System Databases
The **185 SYSTEM databases** (1.56 GB) are:
- macOS infrastructure (read-only on most)
- Regenerated automatically
- Safe to ignore for storage management
- Critical for system functionality — do NOT delete

### 4. Application Caches
The **203 APP DATA databases** (184.2 MB) are:
- iOS Simulator state (can be reset: `xcrun simctl erase all`)
- Xcode caches (can be cleared: `~/Library/Caches/com.apple.dt.Xcode`)
- App-managed data

Clearing would recover ~50-100 MB and improve system performance.

---

## Quick Commands

### Clean Go Module Test Data
```bash
cd ~/Backup/go/pkg/mod && du -sh modernc.org/sqlite@v1.38.2/testdata
go clean -modcache
```

### Reset iOS Simulator (Frees 50-100 MB)
```bash
xcrun simctl erase all
```

### Clear Xcode Caches
```bash
rm -rf ~/Library/Caches/com.apple.dt.Xcode/BuildProductsCache
```

### List Your Databases by Size
```bash
find ~/Backup/NCLS_SCRIPTS ~/Backup/Scripts/llm_assisted_scrapper ~/Backup/00_PYTHON_PROJECTS/avli_cloud* -name "*.db" -o -name "*.sqlite3" | xargs -I {} sh -c 'du -h "{}" | awk "{print \$1, \"{}\"}"' | sort -rh
```

---

## Conclusion

**Your AVLI/L7 ecosystem comprises 19 databases totaling 405.4 MB** — a lean, purposeful collection:
- Knowledge graphs (chroma vector DBs): 274 MB
- Research timelines & intelligence extraction: 34 MB
- AVLI Cloud platform: ~10 MB

All other databases are either **system infrastructure** (untouchable) or **third-party app data** (app-managed).

The most valuable asset here is your **knowledge_graph/chroma_db** — a 265 MB vector embedding database that represents accumulated intelligence and structured knowledge.
