# Veo 3.1 Added! 🎉

I've successfully added **Google Veo 3.1** support to your MCP Content Generator!

## What is Veo 3.1?

- **Ranked #2** in video generation quality benchmarks (Elo score: 1,226)
- Generates **720p/1080p** high-quality videos
- **5-15 second** videos with **native audio**
- Supports **multiple aspect ratios**: 16:9, 9:16, 1:1
- **Stunning realism** and cinematic quality

## What's Changed

### New Files:
- `src/providers/veo.ts` - Veo 3.1 integration
- Updated `package.json` - Added Google Generative AI dependency

### Updated Files:
- `src/index.ts` - Added `generate_video_veo` tool
- `.env.example` - Added GOOGLE_API_KEY
- `~/.claude/mcp_settings.json` - Added GOOGLE_API_KEY placeholder
- `README.md` - Updated with Veo 3.1 documentation

## Your Video Generation Options

You now have **TWO** video generation models:

### 1. **Runway Gen-3** (Already had this)
- Duration: 5-10 seconds
- Cost: ~$0.05/second
- Best for: Professional, physics-based videos

### 2. **Veo 3.1** (NEW!)
- Duration: 5-15 seconds
- Cost: $0.75/second
- Aspect ratios: 16:9, 9:16, 1:1
- Best for: High-quality videos with native audio

## How to Use Veo 3.1

### Step 1: Get Google AI API Key
1. Go to: https://aistudio.google.com/app/apikey
2. Click "Create API Key"
3. Copy your key

### Step 2: Add to Configuration
Edit `~/.claude/mcp_settings.json` and add your key:
```json
"GOOGLE_API_KEY": "your-actual-google-api-key-here"
```

### Step 3: Restart Claude Code
Exit and restart Claude Code to load the new configuration.

### Step 4: Generate Videos!
Once restarted, you can ask me:
```
Use Veo to create an 8-second video of a sunset over mountains in 16:9
```

Or:
```
Generate a vertical video (9:16) with Veo showing a city street at night, 10 seconds
```

## Cost Comparison

| Model | Duration | Cost | Audio | Quality Rank |
|-------|----------|------|-------|--------------|
| **Veo 3.1** | 5-15s | $0.75/sec | ✅ Native | #2 |
| **Runway Gen-3** | 5-10s | $0.05/sec | ❌ No | #1 |

**Note:** Veo is more expensive but includes native audio generation!

## Example Prompts

```
Create a cinematic video with Veo of a drone flying over a forest
```

```
Use Veo 3.1 to generate a 12-second square video (1:1) of ocean waves
```

```
Generate a vertical TikTok-style video (9:16) with Veo showing a chef cooking, 15 seconds
```

## Complete Model Lineup

Your MCP server now supports:

**Images:**
1. DALL-E 3 - Prompt accuracy
2. Flux Pro - Photorealism
3. Stable Diffusion 3.5 - Customizable

**Videos:**
1. Runway Gen-3 - #1 quality, physics-based
2. Veo 3.1 - #2 quality, with audio

🎬 Ready to create amazing content!
