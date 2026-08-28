# Live verification

Verified against https://n8n.avli.cloud on 2026-08-11.

Expected create result:
- ok: true
- duration: 1800
- soundtrack: Suno
- lyrics author: Suno
- creative mood includes beautiful, spiritual, vibrant, celestial, visionary, majestic

Expected policy tests:
- motion_generation/running without approval -> paid_generation_requires_human_approval
- reject identity_drift -> candidate with preservation guard
- reject fake_still_zoom_or_pan -> rejected
