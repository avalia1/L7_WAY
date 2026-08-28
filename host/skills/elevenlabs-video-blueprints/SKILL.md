---
name: "elevenlabs-video-blueprints"
description: "Build/download ElevenLabs character sheets and storyboards while enforcing paid-generation approval and visual QA."
---

# ElevenLabs Video Blueprints

Produce production-ready visual blueprints in ElevenLabs while preserving budget boundaries, original asset quality, and character continuity.

## Safety boundary

- Treat account credits, plan upgrades, purchases, and paid video generation as separate actions.
- Require explicit user approval for the exact spend before upgrading a plan, purchasing credits, or starting paid video generation.
- If the user approves free-tier fallback assets, do not reinterpret that approval as permission to spend.
- Record the visible credit balance before and after Studio Agent analysis. Agent analysis itself may consume credits.
- Never expose cookies, credentials, private account metadata, or expiring download links in logs or responses.

## Prepare the production target

1. Resolve the project root and create or reuse:
   - `references/` for the canonical character sheet
   - `storyboards/` for scene boards
   - `logs/` for the capability and QA record
2. Inspect existing character references before generating. Prefer a reliable canonical reference if ElevenLabs permits upload.
3. If no reliable upload path exists, generate the character sheet before the storyboard.
4. Define:
   - native aspect ratio and target resolution
   - exact scene duration and motion
   - character identity, attire, tools, materials, and exclusions
   - environment, lighting, camera grammar, and cultural constraints
   - prohibited audio, text, symbols, watermarks, and anatomical defects

Read [references/prompt-templates.md](references/prompt-templates.md) before composing requests.

## Probe the current capability once

1. Use the authenticated user browser/profile when login state matters.
2. Reuse an existing ElevenLabs tab when possible.
3. Open ElevenLabs Image & Video or Studio and inspect the visible plan and credit state.
4. Submit one complete video request that states duration, aspect ratio, real subject/environment motion, camera movement, output quality, and exclusions.
5. Read the capability message before acting again.
6. Classify the result:
   - **Video available without new spend:** proceed only when the request authorizes generation and the visible credit cost is acceptable.
   - **Paid feature or upgrade required:** stop paid execution and offer free-tier blueprints.
   - **Unknown cost or ambiguous confirmation:** stop and ask for explicit approval.

Avoid repeated probes. Studio Agent analysis can consume credits even when video generation is unavailable.

## Generate free-tier blueprints

When free-tier fallback is approved:

1. Start with: “Proceed with the free-tier storyboard and character sheet only. Do not upgrade, purchase, or invoke paid video generation.”
2. Request the canonical character sheet first.
3. Request the storyboard only after the character definition is fixed.
4. Ask for the native target aspect ratio and highest available practical resolution.
5. Preserve a generation in reserve when iteration limits are visible.
6. Wait for a completed state. Do not infer completion from a preview alone.

## Download originals

1. Prefer ElevenLabs' visible Download control for every completed asset.
2. Take a fresh browser snapshot before each click and use the current control reference.
3. Wait for the browser download to complete; do not save a screenshot or low-resolution preview as the deliverable.
4. If the download control is missing or exposes only a preview:
   - inspect the visible UI for an overflow menu, asset detail view, or export control;
   - retry once after a fresh snapshot;
   - use only a documented ElevenLabs API with user-authorized credentials when available;
   - otherwise stop and request a manual download instead of extracting browser credentials or calling undocumented private endpoints.
5. Move or copy the completed original into a stable project filename:
   - `references/<character>_elevenlabs_character_sheet_<aspect>.png`
   - `storyboards/<character>_elevenlabs_storyboard_sceneNN_<aspect>.png`

## Verify each deliverable

Run file-level checks:

```bash
file "<asset>"
sips -g pixelWidth -g pixelHeight -g format "<asset>"
```

On non-macOS systems, use `identify` or another trusted image inspector.

Visually inspect each original at high detail and classify it:

- **Canonical reference:** face, hair, body, attire, tools, colors, and materials are internally consistent.
- **Storyboard-ready:** framing and beats are useful, and the subject matches the canonical reference.
- **Mood/composition only:** framing is useful but face, hair, body, clothing, or tools drift.
- **Reject/regenerate:** text, watermark, malformed anatomy, severe blur, duplicated elements, or culturally inappropriate invention appears.

Do not claim identity lock merely because the prompt says “same character.” Compare the actual pixels against the character sheet.

## Log the run

Write one dated Markdown record under `logs/` containing:

- account plan and visible credits before/after
- exact capability result and quoted paid/free boundary
- what was requested and what was actually generated
- output paths, formats, dimensions, and byte sizes
- visual QA classification and continuity issues
- whether any purchase, upgrade, or paid generation occurred
- the precise next action and whether it requires owner approval

Lead the handoff with the actual outcome: downloaded assets, dimensions, QA status, paid blocker if any, and confirmation that no unauthorized spend occurred.

## L7 Declaration (Seven Seals)

- Capability: ElevenLabs character sheets and storyboard blueprints with paid-generation gates
- Data: project `references/`, `storyboards/`, and `logs/` plus visible plan/credit state
- Policy: explicit approval for spend; never log cookies, credentials, or expiring download links
- Presentation: downloaded original assets and a dated Markdown run record
- Orchestration: probe once → free-tier blueprints or stop → download originals → visual QA → log
- Time: v1 (2026-08-15)
- Identity: Founder/operator browser session; audit every paid-boundary decision

## Workflow

1. Prepare the production target directories.
2. Probe ElevenLabs capability once and classify spend.
3. Generate only approved free-tier or paid assets.
4. Download originals and verify dimensions.
5. Write the dated log and hand off.
