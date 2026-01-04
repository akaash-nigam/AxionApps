# MCP Content Generator

A custom Model Context Protocol (MCP) server for AI-powered image and video generation. This server enables Claude Code to generate images using DALL-E 3, Flux Pro, and Stable Diffusion 3.5, as well as videos using Runway Gen-3.

## Features

### Image Generation
- **DALL-E 3** - OpenAI's image generation with excellent prompt accuracy
- **Flux Pro** - Black Forest Labs' photorealistic image generation
- **Stable Diffusion 3.5** - Customizable, cost-effective image generation

### Video Generation
- **Runway Gen-3** - Professional video generation with advanced physics
- **Google Veo 3.1** - High-quality 720p/1080p videos with native audio (Ranked #2)

## Prerequisites

- Node.js 18+
- npm or yarn
- API keys for the services you want to use:
  - [OpenAI API Key](https://platform.openai.com/api-keys) for DALL-E 3
  - [Stability AI API Key](https://platform.stability.ai/account/keys) for Stable Diffusion
  - [Black Forest Labs API Key](https://api.bfl.ml/) for Flux Pro
  - [Runway API Key](https://runwayml.com/) for Runway video generation
  - [Google AI API Key](https://aistudio.google.com/app/apikey) for Veo 3.1 video generation

## Installation

1. **Install dependencies:**
```bash
cd mcp-content-generator
npm install
```

2. **Configure API keys:**

Create a `.env` file in the project root:
```bash
cp .env.example .env
```

Edit `.env` and add your API keys:
```env
OPENAI_API_KEY=sk-...
STABILITY_API_KEY=sk-...
BFL_API_KEY=...
RUNWAY_API_KEY=...
GOOGLE_API_KEY=...
OUTPUT_DIR=./generated
```

3. **Build the server:**
```bash
npm run build
```

## Configuration in Claude Code

Add the MCP server to your Claude Code configuration file at `~/.claude/mcp_settings.json`:

```json
{
  "mcpServers": {
    "content-generator": {
      "command": "node",
      "args": [
        "/Users/aakashnigam/Axion/AxionApps/mcp-content-generator/dist/index.js"
      ],
      "env": {
        "OPENAI_API_KEY": "sk-your-openai-key",
        "STABILITY_API_KEY": "sk-your-stability-key",
        "BFL_API_KEY": "your-bfl-key",
        "RUNWAY_API_KEY": "your-runway-key",
        "GOOGLE_API_KEY": "your-google-api-key",
        "OUTPUT_DIR": "/Users/aakashnigam/Axion/AxionApps/mcp-content-generator/generated"
      }
    }
  }
}
```

**Note:** Replace the API keys and paths with your actual values.

## Available Tools

Once configured, you can use these tools in Claude Code:

### `generate_image_dalle`
Generate images using DALL-E 3.

**Parameters:**
- `prompt` (required): Text description of the image
- `size`: "1024x1024", "1792x1024", or "1024x1792" (default: "1024x1024")
- `quality`: "standard" or "hd" (default: "standard")
- `style`: "natural" or "vivid" (default: "vivid")

**Example:**
```
Generate an image using DALL-E of a futuristic city at sunset with flying cars
```

### `generate_image_flux`
Generate photorealistic images using Flux Pro.

**Parameters:**
- `prompt` (required): Text description of the image
- `width`: Image width in pixels (default: 1024)
- `height`: Image height in pixels (default: 1024)

**Example:**
```
Use Flux to create a photorealistic portrait of a person in natural lighting
```

### `generate_image_sd`
Generate images using Stable Diffusion 3.5.

**Parameters:**
- `prompt` (required): Text description of the image
- `negative_prompt`: What to avoid in the image
- `aspect_ratio`: "1:1", "16:9", "21:9", "9:16", or "9:21" (default: "1:1")
- `model`: "sd3.5-large", "sd3.5-large-turbo", or "sd3.5-medium" (default: "sd3.5-large")

**Example:**
```
Generate an image with Stable Diffusion of a serene mountain landscape
```

### `generate_video_runway`
Generate videos using Runway Gen-3.

**Parameters:**
- `prompt` (required): Text description of the video
- `duration`: 5 or 10 seconds (default: 5)

**Example:**
```
Create a 10-second video of ocean waves crashing on a beach at sunset
```

### `generate_video_veo`
Generate videos using Google Veo 3.1.

**Parameters:**
- `prompt` (required): Text description of the video
- `duration`: 5-15 seconds (default: 8)
- `aspectRatio`: "9:16" (vertical), "16:9" (horizontal), or "1:1" (square) (default: "16:9")

**Example:**
```
Use Veo to create an 8-second video of a drone flying over a forest in 16:9 aspect ratio
```

## Output

All generated files are saved to the `generated/` directory (or the path specified in `OUTPUT_DIR`). Files are named with timestamps for easy organization:

- DALL-E images: `dalle_YYYY-MM-DDTHH-MM-SS.png`
- Flux images: `flux_YYYY-MM-DDTHH-MM-SS.png`
- Stable Diffusion images: `sd35_YYYY-MM-DDTHH-MM-SS.png`
- Runway videos: `runway_YYYY-MM-DDTHH-MM-SS.mp4`
- Veo videos: `veo3_YYYY-MM-DDTHH-MM-SS.mp4`

## Costs

Approximate costs per generation:

- **DALL-E 3**: $0.04 (standard) to $0.12 (HD) per image
- **Flux Pro**: ~$0.05 per image
- **Stable Diffusion 3.5**: $0.01 to $0.25 per image
- **Runway Gen-3**: ~$0.05 per second of video
- **Veo 3.1**: $0.75 per second of video (includes audio)

## Troubleshooting

### API Key Errors
Make sure your `.env` file has the correct API keys and that they're properly set in the Claude Code MCP configuration.

### Build Errors
```bash
npm run build
```
Check for TypeScript errors in the output.

### Module Not Found
Make sure you've run `npm install` and `npm run build`.

### Images/Videos Not Generating
Check the console output in Claude Code for error messages. Some providers may have rate limits or require account verification.

## Development

To watch for changes during development:
```bash
npm run watch
```

## License

MIT

## Author

Aakash Nigam
