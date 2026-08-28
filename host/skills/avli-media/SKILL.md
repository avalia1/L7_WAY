# avli-media

Media generation skill for Avli Cloud (music, video, image, speech, transcription).

## Overview
Wraps the media generation endpoints from the NCLS projects API into a clean L7 skill interface.

## Tools

### generate_music
Generate music from a text prompt.

**Arguments:**
- `prompt` (string, required): Description of the music
- `duration` (number, optional): Duration in seconds (default: 30)

### generate_video
Generate video from a text prompt.

**Arguments:**
- `prompt` (string, required): Description of the video
- `duration` (number, optional): Duration in seconds
- `model` (string, optional): Model to use (`ltx-video`, `wan-2.1`)

### generate_image
Generate an image from a text prompt.

**Arguments:**
- `prompt` (string, required): Description of the image
- `style` (string, optional): Image style
- `size` (string, optional): Image size (e.g. `1024x1024`)

### generate_speech
Generate speech audio from text.

**Arguments:**
- `text` (string, required): Text to synthesize
- `voice` (string, optional): Voice identifier
- `language` (string, optional): Language code

### transcribe_audio
Transcribe audio to text.

**Arguments:**
- `audio_url` (string, required): URL or path to audio file
- `language` (string, optional): Language code

## Implementation Notes
- Backend: Calls `https://ai-api.avli.ts.net` endpoints
- This skill is designed to be used by L7 agents and the OpenClaw gateway
- Future versions should support local model fallbacks and credit tracking

## Status
Initial extraction from ncls-comprehensive MCP server (2026-08-15)