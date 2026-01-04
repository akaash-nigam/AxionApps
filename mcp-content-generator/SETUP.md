# Quick Setup Guide

## Step 1: Get Your API Keys

You'll need API keys for the services you want to use:

1. **OpenAI (for DALL-E 3)**
   - Go to: https://platform.openai.com/api-keys
   - Create a new API key
   - Copy it (starts with `sk-...`)

2. **Stability AI (for Stable Diffusion 3.5)**
   - Go to: https://platform.stability.ai/account/keys
   - Create a new API key
   - Copy it (starts with `sk-...`)

3. **Black Forest Labs (for Flux Pro)**
   - Go to: https://api.bfl.ml/
   - Sign up and get your API key

4. **Runway (for video generation)**
   - Go to: https://runwayml.com/
   - Sign up for API access
   - Get your API key

## Step 2: Configure the MCP Server in Claude Code

1. **Create or edit** `~/.claude/mcp_settings.json`:

```bash
mkdir -p ~/.claude
nano ~/.claude/mcp_settings.json
```

2. **Add this configuration** (replace with your actual API keys and path):

```json
{
  "mcpServers": {
    "content-generator": {
      "command": "node",
      "args": [
        "/Users/aakashnigam/Axion/AxionApps/mcp-content-generator/dist/index.js"
      ],
      "env": {
        "OPENAI_API_KEY": "sk-proj-YOUR-OPENAI-KEY-HERE",
        "STABILITY_API_KEY": "sk-YOUR-STABILITY-KEY-HERE",
        "BFL_API_KEY": "YOUR-BFL-KEY-HERE",
        "RUNWAY_API_KEY": "YOUR-RUNWAY-KEY-HERE",
        "OUTPUT_DIR": "/Users/aakashnigam/Axion/AxionApps/mcp-content-generator/generated"
      }
    }
  }
}
```

3. **Save and close** the file (Ctrl+X, then Y, then Enter in nano)

## Step 3: Restart Claude Code

For the changes to take effect, restart Claude Code completely:

```bash
# Exit Claude Code (Ctrl+D or type 'exit')
# Then start it again:
claude
```

## Step 4: Test the MCP Server

Once Claude Code restarts, you can test the tools:

```
Generate a test image with DALL-E of a sunset over mountains
```

Or:

```
Use Stable Diffusion to create an image of a futuristic cityscape
```

## Checking if it Works

When you start Claude Code, you should see the MCP server load in the startup messages. If you see errors, check:

1. **Path is correct** - The path to `dist/index.js` matches where you installed it
2. **API keys are valid** - No typos, and they're active
3. **Node.js version** - You need Node.js 18 or higher: `node --version`

## Generated Files

All images and videos are saved to:
```
/Users/aakashnigam/Axion/AxionApps/mcp-content-generator/generated/
```

Files are named with timestamps:
- `dalle_2025-01-04T12-30-45.png`
- `flux_2025-01-04T12-31-20.png`
- `sd35_2025-01-04T12-32-10.png`
- `runway_2025-01-04T12-35-00.mp4`

## Troubleshooting

### "Command not found" or "Cannot find module"
- Make sure you ran `npm install` and `npm run build`
- Check the path in `mcp_settings.json` is absolute and correct

### "API key not set"
- Double-check your `.env` file or `mcp_settings.json` has the keys
- Make sure there are no extra spaces or quotes around the keys

### "Permission denied"
- Make sure the `generated/` directory is writable
- Try: `mkdir -p /Users/aakashnigam/Axion/AxionApps/mcp-content-generator/generated`

### Images/videos aren't generating
- Check the console output for specific error messages
- Some providers may have rate limits or require billing setup
- Verify your API keys are active and have credits

## Next Steps

Once it's working, you can:

- Generate images for your iOS/Android app landing pages
- Create video content for app demos
- Test different AI models to see which produces the best results
- Batch generate content by asking Claude to create multiple variations

Enjoy!
