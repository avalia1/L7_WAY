---
name: "orisha-youtube-documentary-n8n"
description: "Build and operate epic 16:9 Orisha documentaries with n8n, Suno songs, genuine-motion loops, review gates, and YouTube packaging."
---

# Orisha YouTube Documentary via n8n

## Purpose

Use this skill to plan and operate a high-quality horizontal Orisha film for YouTube, typically about 30 minutes long. The working creative pattern is an epic, majestic, music-led cinematic documentary with narration, demonstrated stories, recurring genuine-motion sequences, and original Suno songs.

## Standing creative reference

Use Aghapy's long-form YouTube work as a pacing and packaging reference, especially:

- Channel: Aghapy
- Reference: "REVELATION: The Final Vision of John | Full 4K Cinematic Bible Movie"
- URL: https://www.youtube.com/watch?v=TXwXXOVtXH4

Borrow the long-form chapter flow, horizontal cinematic imagery, recurring visual motifs, narration, music-led pacing, and ambitious title/thumbnail discipline. Never copy Christian theology or iconography into an Orisha film.

## Non-negotiable owner preferences

1. Preserve every generated clip as a candidate.
2. Only reject a clip automatically when it is essentially a still image with artificial zoom/pan instead of genuine motion.
3. Identity drift, framing problems, vertical format, or imperfect composition do not justify deletion. Record notes and retain the candidate.
4. Generate dramatic footage natively in 16:9 whenever possible.
5. High quality is more important than speed: 1920x1080 minimum delivery and a 3840x2160 master when the sources support it.
6. Use Suno for the soundtrack. Prefer a brief simple-mode description and let Suno create the lyrics.
7. Narrate and demonstrate the Orisha stories. The desired mood is epic, majestic, spiritual, vibrant, celestial, visionary, and culturally respectful.
8. A million views is an ambition, not a promise. Optimize the first 30 seconds, title, thumbnail, retention, audio quality, and honest cultural depth.

## Live n8n deployment

- Public instance: https://n8n.avli.cloud
- Workflow ID: `IMtnFDZeT4ybzhBDvkd-2`
- Workflow name: `Orisha Realm - 30 Minute Documentary Pipeline`
- Production webhook: `POST https://n8n.avli.cloud/webhook/v1/orisha/documentary/jobs`
- Authentication header name: `X-Orisha-Pipeline-Key`
- Local credential file: `/Users/rnir_hrc_avd/.l7/secrets/orisha_documentary_n8n.env`
- Source workflow: `/Users/rnir_hrc_avd/avli_cloud/workflows/orchestrator/orisha-documentary-30m.json`

Never print or commit the header value. The local `secrets/` directory is gitignored and the file must remain mode 600.

The deployed n8n version is 2.3.6. It reliably registers the first Webhook trigger from the imported workflow. For compatibility, all API operations use the single production webhook with an `action` field.

## API actions

### Create a production manifest

Send:

```json
{
  "action": "create",
  "job_id": "ochosi-youtube-30m-v1",
  "orisha": "Ochosi",
  "duration_seconds": 1800,
  "dry_run": true,
  "paid_generation_approved": false,
  "youtube_publish_approved": false
}
```

The response must contain:

- exactly 1800 chapter seconds for a 30-minute job
- 16:9 format
- Aghapy creative-reference fields
- high-quality master and audio specifications
- Suno as soundtrack provider
- Suno-written lyrics mode
- recurring genuine-motion loop architecture
- clip preservation policy
- human approval gates
- title, description, and thumbnail art direction

Treat the returned manifest as the authoritative job record. Workflow static data was not durable across webhook executions on the current task-runner setup.

### Record a stage event

Send `action: "event"` with `stage` and `status`.

Motion generation cannot enter `running` or `completed` without `paid_generation_approved: true`. Publishing cannot enter those states without `youtube_publish_approved: true`.

### Review a clip

Send `action: "review_clip"` with `clip_id`, `label`, `reason`, and `genuine_motion`.

If a rejection reason is not one of:

- `fake_still_zoom_or_pan`
- `fake_still_zoom`
- `ken_burns_only`

the workflow must relabel the clip as `candidate` and set `preservation_guard_applied: true`.

## Production sequence

1. Inventory all existing research, character references, music, storyboards, clips, and previous masters.
2. Create the dry-run n8n manifest and save the JSON response in the project metadata directory.
3. Research the Orisha with named sources. Note lineage, region, and contested or differing accounts.
4. Create a seven-chapter treatment totaling the target duration.
5. Draft majestic narration with a deep, warm, authoritative voice. Leave musical and visual breathing room; avoid wall-to-wall speech.
6. Complete fact and cultural review before paid generation.
7. Create at least six distinct 2-to-5-minute visual movements. Each movement should use at least eight genuine-motion shots.
8. Recur the strongest movements like a chorus throughout the 30-minute master. Repetition is intentional; fake motion from a still is not.
9. Generate three related Suno song candidates using a concise brief and Suno-written lyrics.
10. Preserve all Suno outputs. Review pronunciation, cultural fit, accidental religious mixing, memorable hooks, clean loop points, and narration compatibility.
11. Generate or source the remaining 16:9 motion clips only after any required spend approval.
12. Assemble in chapters with music beneath narration, rises between chapters, chapter cards, maps, symbolic motifs, and seamless audio/visual loop transitions.
13. Create the YouTube package: one primary title, three alternates, strong description, chapters, citations, thumbnail text, and cover art.
14. Watch the final master end-to-end.
15. Obtain explicit approval before uploading or publishing.

## Default Suno brief

Use Suno simple mode. Do not supply custom lyrics unless the owner requests it.

> Cinematic devotional song for Ochosi, spirit of the forest, precision, justice, and the sacred hunt; Yoruba-inspired percussion, deep warm lead vocal, call-and-response choir, mystical and reverent, spacious and emotionally powerful.

## Default YouTube package

Primary title:

> OCHOSI: The Divine Hunter Who Never Misses | Epic Orisha Story

Thumbnail copy:

> OCHOSI
>
> THE ARROW NEVER MISSES

Thumbnail art direction:

Ochosi on the right third with his bow and a celestial arrow; visionary sacred forest, constellations, intense readable eyes, rich emerald-cobalt-gold-violet palette, and uncluttered dark space on the left for large deterministic title text.

## Quality checks

- Native 16:9.
- 1920x1080 minimum delivery.
- 3840x2160 master only when source quality supports it.
- 48 kHz audio.
- Approximately -14 LUFS integrated for YouTube.
- -1 dBTP true-peak ceiling.
- No visible loop seam.
- No morphing at edit boundaries.
- Ochosi remains recognizable.
- No clipped highlights or crushed shadows.
- Music does not mask narration.
- Titles and citations read clearly on television and phone screens.
- Rights and licensing review completed.
- Final master watched end-to-end.

## Safe deployment procedure

1. Back up all n8n workflows on the VPS before import.
2. Import the header-auth credential into n8n's encrypted credential store; never place the secret in workflow JSON.
3. Import the workflow with the existing workflow ID and personal project ID.
4. Publish the workflow.
5. Restart n8n because CLI publishing on n8n 2.3.6 does not hot-reload a running instance.
6. Wait for `/healthz` to return 200.
7. Run live tests for create, paid-generation gate, preserved identity-drift candidate, and allowed fake-zoom rejection.
8. Keep the dated backup path in the handoff.

The verified pre-deployment backup is:

`/opt/avli-backups/n8n/20260811T152004Z`

## L7 Declaration (Seven Seals)

- Capability: Orisha documentary pipeline operations through n8n (create, stage, review, package)
- Data: job manifests, clip candidates, Suno tracks, and local credential file under `~/.l7/secrets/`
- Policy: paid generation and YouTube publish require explicit approval; never print the pipeline key
- Presentation: 16:9 masters, chapter manifests, titles, thumbnails, and review notes
- Orchestration: create manifest → stage events → human gates → package → optional publish
- Time: v1 (2026-08-15)
- Identity: Founder-operated n8n service identity; audit all webhook actions

## Workflow

1. Load the local secret file without echoing it.
2. Create a dry-run manifest for the Orisha job.
3. Record stage events and preserve every generated clip candidate.
4. Stop at paid-generation and YouTube-publish gates until approved.
5. Package the 16:9 master and hand off the review record.
