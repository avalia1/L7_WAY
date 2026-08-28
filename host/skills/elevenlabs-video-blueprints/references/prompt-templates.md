# Prompt Templates

Replace bracketed fields with project-specific facts. Keep culturally sensitive claims grounded in user-provided references; do not invent private ceremonies, symbols, or regalia.

## Capability probe

```text
Create one [DURATION]-second native [ASPECT] cinematic video clip at the highest available practical resolution. No narration, captions, or music.

SUBJECT: [IDENTITY, ROLE, PHYSICAL DESCRIPTION, DIGNIFIED CHARACTERIZATION].
ACTION: [CLEAR EMBODIED ACTION WITH TEMPORAL PROGRESSION].
ENVIRONMENTAL MOTION: [LEAVES/CLOTH/HAIR/WATER/MIST/ANIMALS] move naturally and independently.
CAMERA: [TRACK/DOLLY/ARC/PAN] with real parallax and changing perspective.
LOOK: [PHOTOREALISM, LIGHTING, PALETTE, ATMOSPHERE, CULTURAL CONTEXT].

No slideshow, stock montage, still-image push-in, bouncing photograph, zoom-only motion, fantasy costume, invented sacred symbols, text, watermark, malformed hands, or malformed face.
```

## Free-tier boundary and handoff

```text
Proceed with the free-tier storyboard and character sheet only. Do not upgrade, purchase, or invoke paid video generation.

Character and tools: [FACE, HAIR, BODY, ATTIRE, COLORS, MATERIALS, TOOLS]. Keep them functional, dignified, and consistent rather than theatrical.

Environment: [LOCATION, TIME, WEATHER, LIGHT, MATERIAL DETAIL, CULTURAL LIMITS].

If no reliable image upload is available, first generate a clean canonical character sheet that locks face, body, attire, tools, colors, and materials. Then generate one native [ASPECT] cinematic storyboard for the exact scene. No text inside the images, no watermark, no malformed anatomy, and no excessive glow. Preserve one image generation in reserve if possible.
```

## Canonical character sheet

```text
Create a canonical character reference sheet for [CHARACTER]. Native [ASPECT], [RESOLUTION], sharp [STYLE], simple neutral background, no labels or text.

IDENTITY LOCK:
- Face: [FEATURES, AGE RANGE, EXPRESSION]
- Hair: [STYLE, LENGTH, TEXTURE]
- Body: [BUILD, HEIGHT IMPRESSION, SKIN TONE]
- Attire: [GARMENTS, COLORS, MATERIALS, FIT]
- Tools/props: [ITEMS, CONSTRUCTION, CARRY POSITION]
- Cultural constraints: [REQUIRED AND PROHIBITED ELEMENTS]

Show a consistent [GRID] containing front full body, three-quarter full body, side profile, back view, action pose, face close-up, hand/tool interaction, tool detail, and material detail. Use the identical face, hair, build, clothing, and tools in every view.

No text, labels, watermark, malformed hands or face, duplicated limbs, generic fantasy armor, invented symbols, or costume drift.
```

## Scene storyboard

```text
Create a cinematic storyboard for [TITLE]. Native [ASPECT], [RESOLUTION], [GRID] frames, [STYLE], no labels or text.

CANONICAL CHARACTER:
[PASTE THE LOCKED FACE, HAIR, BODY, ATTIRE, COLORS, MATERIALS, AND TOOLS FROM THE APPROVED CHARACTER SHEET.]

SETTING:
[LOCATION, TIME, WEATHER, LIGHT, PALETTE, CONTINUITY DETAILS.]

FRAMES:
1. [SHOT SIZE + ACTION + CAMERA]
2. [SHOT SIZE + ACTION + CAMERA]
3. [SHOT SIZE + ACTION + CAMERA]
4. [SHOT SIZE + ACTION + CAMERA]

Use the identical face, hair, build, attire, and tools in every frame. Preserve the same environment and lighting logic across the sequence.

No text, labels, watermark, malformed anatomy, duplicated limbs, fantasy drift, or invented sacred symbols.
```

## QA rubric

Check and record:

- File: original downloaded, valid MIME/format, expected dimensions, nonzero size
- Character: face, hair, build, skin tone, attire, tools
- Scene: beat order, shot grammar, environment, lighting continuity
- Defects: hands, face, duplicated anatomy, text, watermark, blur
- Cultural integrity: no invented or theatricalized sacred material
- Final class: canonical / storyboard-ready / mood-only / reject