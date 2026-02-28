# .salt Replication Protocol

## Law XVII — Salt Domain
> Preserved, sealed, immutable archive of proven work.

## Replication Rules

1. **On Seal**: When a document is sealed into `.salt`, a checksum seal is created in `seals/`
2. **On Network**: When the L7 network becomes active, all salt files replicate to every connected node
3. **On Sync**: Every new L7 node receives the full salt archive on first sync
4. **Immutability**: Salt files are append-only. Previous seals are never modified or deleted.
5. **Verification**: Any node can verify integrity by computing SHA-256 against the seal record

## Replication Targets

| Target | Method | Status |
|--------|--------|--------|
| `origin/master` | Git push (L7_WAY repo) | Pending — SSH key registration |
| `avli.cloud` (VPS) | rsync over Tailscale | Pending — network activation |
| L7 Gateway nodes | MCP broadcast on `salt.replicate` | Pending — universal-xr boot |
| `.vault` backup | Encrypted copy with biometric seal | Pending — vault implementation |

## Sealed Documents

| Document | Sealed At | SHA-256 |
|----------|-----------|---------|
| FOUNDERS_DRAFT | 2026-02-28T03:39:04Z | e1820d452d29efd35a17b76d15a5aed8ac93f66b8cdd71520e537792fb952d0b |

## Verification Command

```bash
shasum -a 256 ~/.l7/salt/FOUNDERS_DRAFT_20260228_033904.salt.md
# Must match: e1820d452d29efd35a17b76d15a5aed8ac93f66b8cdd71520e537792fb952d0b
```

---

*What enters salt never leaves. What leaves salt was never there.*
