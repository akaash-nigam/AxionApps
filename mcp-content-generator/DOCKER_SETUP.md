# Docker Setup Guide for MCP Content Generator

This guide explains how to run the MCP Content Generator server in a Docker container and connect it to Claude Code.

## Prerequisites

1. **Docker Desktop** must be installed and running
   - Download from: https://www.docker.com/products/docker-desktop
   - After installation, launch Docker Desktop from your Applications folder
   - Wait for the Docker icon in your menu bar to show "Docker Desktop is running"

2. **API Keys** - You need at least one of these:
   - OpenAI API Key (for DALL-E 3)
   - Stability AI API Key (for Stable Diffusion 3.5)
   - Black Forest Labs API Key (for Flux Pro)
   - Runway API Key (for Gen-3 videos)
   - Google AI API Key (for Veo 3.1 videos)

## Quick Start

### Step 1: Start Docker Desktop

**On macOS:**
1. Open "Docker Desktop" from Applications folder
2. Wait for the status to show "Docker Desktop is running" (green icon in menu bar)

**Verify Docker is running:**
```bash
docker --version
```

You should see output like: `Docker version 24.x.x, build...`

### Step 2: Configure API Keys

Create a `.env` file in the `mcp-content-generator` directory:

```bash
cd /Users/aakashnigam/Axion/AxionApps/mcp-content-generator
cp .env.example .env
```

Edit `.env` and add your actual API keys:
```bash
# Replace these with your actual API keys
OPENAI_API_KEY=sk-proj-...
STABILITY_API_KEY=sk-...
BFL_API_KEY=...
RUNWAY_API_KEY=...
GOOGLE_API_KEY=...
```

### Step 3: Build the Docker Image

```bash
docker build -t mcp-content-generator:latest .
```

**Expected output:**
- `[builder 1/6]` - Building TypeScript stage
- `[stage-1 1/4]` - Production stage
- `Successfully tagged mcp-content-generator:latest`

**Build time:** ~2-5 minutes (depending on internet speed)

### Step 4: Test the Container

Run the container locally to verify it works:

```bash
docker run --rm \
  --env-file .env \
  -v $(pwd)/generated:/app/generated \
  mcp-content-generator:latest
```

You should see: `MCP Content Generator running on stdio`

Press `Ctrl+C` to stop the test.

## Using with Docker Compose (Recommended)

Docker Compose simplifies container management.

### Start the Server

```bash
docker-compose up -d
```

**Flags:**
- `-d` = Run in background (detached mode)

### Check Status

```bash
docker-compose ps
```

Should show:
```
NAME                    STATUS
mcp-content-generator   Up X seconds
```

### View Logs

```bash
docker-compose logs -f
```

Press `Ctrl+C` to exit logs.

### Stop the Server

```bash
docker-compose down
```

## Configure Claude Code to Use Docker Container

You have **two options** for connecting Claude Code to the MCP server:

### Option 1: Direct Node.js (Current Setup)

Edit `~/.claude/mcp_settings.json`:

```json
{
  "mcpServers": {
    "content-generator": {
      "command": "node",
      "args": [
        "/Users/aakashnigam/Axion/AxionApps/mcp-content-generator/dist/index.js"
      ],
      "env": {
        "OPENAI_API_KEY": "your-actual-key-here",
        "STABILITY_API_KEY": "your-actual-key-here",
        "BFL_API_KEY": "your-actual-key-here",
        "RUNWAY_API_KEY": "your-actual-key-here",
        "GOOGLE_API_KEY": "your-actual-key-here",
        "OUTPUT_DIR": "/Users/aakashnigam/Axion/AxionApps/mcp-content-generator/generated"
      }
    }
  }
}
```

**Pros:**
- Faster startup
- Easier debugging
- No Docker overhead

**Cons:**
- Requires Node.js installed
- Must rebuild with `npm run build` after code changes

### Option 2: Docker Container (Production)

Edit `~/.claude/mcp_settings.json`:

```json
{
  "mcpServers": {
    "content-generator": {
      "command": "docker",
      "args": [
        "run",
        "--rm",
        "-i",
        "--env-file",
        "/Users/aakashnigam/Axion/AxionApps/mcp-content-generator/.env",
        "-v",
        "/Users/aakashnigam/Axion/AxionApps/mcp-content-generator/generated:/app/generated",
        "mcp-content-generator:latest"
      ]
    }
  }
}
```

**Pros:**
- Isolated environment
- Consistent across machines
- Easy to deploy and share

**Cons:**
- Slightly slower startup (~1-2 seconds)
- Requires Docker Desktop running
- Harder to debug

## After Configuration

1. **Restart Claude Code** completely (quit and relaunch)
2. **Verify MCP server is loaded:**
   - Look for "MCP Content Generator running on stdio" in logs
   - Available tools should appear in Claude Code's MCP tools list

## Testing Your Setup

Once Claude Code is restarted, test with a simple command:

```
Generate a small 256x256 image of a sunset using DALL-E
```

**Expected result:**
- Claude Code calls the `generate_image_dalle` tool
- Image is generated and saved to `generated/` folder
- Image is displayed in the conversation

## Troubleshooting

### Docker daemon not running

**Error:** `Cannot connect to the Docker daemon`

**Fix:**
1. Launch Docker Desktop from Applications
2. Wait for green status icon
3. Retry build command

### Docker build fails with npm errors

**Error:** `npm install failed` or `package not found`

**Fix:**
```bash
# Clear Docker build cache
docker builder prune -a

# Rebuild without cache
docker build --no-cache -t mcp-content-generator:latest .
```

### Container starts but Claude Code can't connect

**Symptoms:**
- Container runs successfully with `docker run`
- But Claude Code shows "MCP server failed to start"

**Fix:**

1. **Check file paths** - Ensure paths in `mcp_settings.json` are absolute
2. **Check .env file exists** - Must be at `/Users/aakashnigam/Axion/AxionApps/mcp-content-generator/.env`
3. **Verify Docker image** - Run `docker images | grep mcp-content-generator`
4. **Check API keys** - Ensure `.env` has valid keys (no quotes around values)

### Generated files not appearing

**Symptoms:**
- Tool executes successfully
- But files not in `generated/` folder

**Check volume mount:**
```bash
docker run --rm \
  --env-file .env \
  -v $(pwd)/generated:/app/generated \
  mcp-content-generator:latest \
  ls -la /app/generated
```

Should show files being created.

### API key errors

**Error:** `OPENAI_API_KEY not set` or `Invalid API key`

**Fix:**

1. **Verify .env file:**
   ```bash
   cat .env | grep OPENAI_API_KEY
   ```

2. **No quotes or spaces:**
   ```bash
   # CORRECT
   OPENAI_API_KEY=sk-proj-abc123...

   # WRONG
   OPENAI_API_KEY="sk-proj-abc123..."
   OPENAI_API_KEY = sk-proj-abc123...
   ```

3. **Test API key manually:**
   ```bash
   curl https://api.openai.com/v1/models \
     -H "Authorization: Bearer YOUR_KEY_HERE"
   ```

### Port conflicts

**Error:** `port is already allocated`

**Fix:**
```bash
# Stop all containers
docker-compose down

# Or stop specific container
docker stop mcp-content-generator
```

## Updating the Server

### After Code Changes

**Using Docker:**
```bash
# Rebuild image
docker-compose down
docker-compose build
docker-compose up -d
```

**Using Node.js directly:**
```bash
npm run build
# Restart Claude Code
```

### Pulling Latest from Git

```bash
cd /Users/aakashnigam/Axion/AxionApps/mcp-content-generator
git pull origin main

# If using Docker
docker-compose down
docker-compose build
docker-compose up -d

# If using Node.js
npm install
npm run build
# Restart Claude Code
```

## Performance Optimization

### Reduce Image Size

Current image size: ~150-200 MB

To reduce further:
```dockerfile
# Add to Dockerfile before final CMD
RUN npm prune --production
```

### Faster Rebuilds

Use Docker BuildKit:
```bash
DOCKER_BUILDKIT=1 docker build -t mcp-content-generator:latest .
```

### Persistent Volumes

To persist generated files across container restarts:
```yaml
# In docker-compose.yml
volumes:
  - ./generated:/app/generated
  - generated-cache:/app/.cache
volumes:
  generated-cache:
```

## Security Best Practices

1. **Never commit .env to Git** - Already in `.gitignore`
2. **Use environment variables** - Don't hardcode API keys
3. **Limit container permissions** - Run as non-root user (future enhancement)
4. **Regular updates** - Keep base images updated

## Advanced Configuration

### Custom Output Directory

```bash
# In .env
OUTPUT_DIR=/custom/path/to/generated

# Update volume mount in docker-compose.yml
volumes:
  - /custom/path/to/generated:/app/generated
```

### Multiple Instances

To run multiple instances on different ports:
```yaml
# docker-compose-dev.yml
services:
  mcp-content-generator-dev:
    container_name: mcp-content-generator-dev
    # ... rest of config
```

Run with:
```bash
docker-compose -f docker-compose-dev.yml up -d
```

## Monitoring and Logs

### Real-time logs

```bash
docker-compose logs -f
```

### Container stats

```bash
docker stats mcp-content-generator
```

### Disk usage

```bash
docker system df
```

### Clean up old images

```bash
docker image prune -a
```

## Support and Resources

- **MCP Documentation:** https://modelcontextprotocol.io
- **Docker Documentation:** https://docs.docker.com
- **GitHub Repository:** https://github.com/akaash-nigam/AxionApps
- **Issues:** Report at GitHub Issues

## Next Steps

1. Get your API keys from the providers
2. Add them to `.env` file
3. Build and test the Docker container
4. Configure Claude Code
5. Start generating amazing content!

Happy creating! 🎨🎬
