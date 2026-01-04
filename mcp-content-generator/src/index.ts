#!/usr/bin/env node

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import dotenv from "dotenv";
import { generateImageDallE } from "./providers/dalle.js";
import { generateImageFlux } from "./providers/flux.js";
import { generateImageStableDiffusion } from "./providers/stability.js";
import { generateVideoRunway } from "./providers/runway.js";
import { generateVideoVeo } from "./providers/veo.js";
import { ensureOutputDir } from "./utils.js";

// Load environment variables
dotenv.config();

// Ensure output directory exists
await ensureOutputDir();

// Create MCP server
const server = new Server(
  {
    name: "mcp-content-generator",
    version: "1.0.0",
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// List available tools
server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: "generate_image_dalle",
        description:
          "Generate an image using DALL-E 3. Creates high-quality images with excellent prompt accuracy and text rendering.",
        inputSchema: {
          type: "object",
          properties: {
            prompt: {
              type: "string",
              description: "The text prompt describing the image to generate",
            },
            size: {
              type: "string",
              enum: ["1024x1024", "1792x1024", "1024x1792"],
              description: "Image size (default: 1024x1024)",
              default: "1024x1024",
            },
            quality: {
              type: "string",
              enum: ["standard", "hd"],
              description: "Image quality (default: standard)",
              default: "standard",
            },
            style: {
              type: "string",
              enum: ["natural", "vivid"],
              description: "Image style (default: vivid)",
              default: "vivid",
            },
          },
          required: ["prompt"],
        },
      },
      {
        name: "generate_image_flux",
        description:
          "Generate a photorealistic image using Flux Pro. Best for highly realistic photos with exceptional detail and lighting.",
        inputSchema: {
          type: "object",
          properties: {
            prompt: {
              type: "string",
              description: "The text prompt describing the image to generate",
            },
            width: {
              type: "number",
              description: "Image width in pixels (default: 1024)",
              default: 1024,
            },
            height: {
              type: "number",
              description: "Image height in pixels (default: 1024)",
              default: 1024,
            },
          },
          required: ["prompt"],
        },
      },
      {
        name: "generate_image_sd",
        description:
          "Generate an image using Stable Diffusion 3.5. Highly customizable with good quality and cost-effective pricing.",
        inputSchema: {
          type: "object",
          properties: {
            prompt: {
              type: "string",
              description: "The text prompt describing the image to generate",
            },
            negative_prompt: {
              type: "string",
              description: "What to avoid in the generated image (optional)",
            },
            aspect_ratio: {
              type: "string",
              enum: ["1:1", "16:9", "21:9", "9:16", "9:21"],
              description: "Image aspect ratio (default: 1:1)",
              default: "1:1",
            },
            model: {
              type: "string",
              enum: ["sd3.5-large", "sd3.5-large-turbo", "sd3.5-medium"],
              description: "Stable Diffusion model to use (default: sd3.5-large)",
              default: "sd3.5-large",
            },
          },
          required: ["prompt"],
        },
      },
      {
        name: "generate_video_runway",
        description:
          "Generate a video using Runway Gen-3. Professional-quality video generation with advanced physics and motion.",
        inputSchema: {
          type: "object",
          properties: {
            prompt: {
              type: "string",
              description: "The text prompt describing the video to generate",
            },
            duration: {
              type: "number",
              description: "Video duration in seconds (5 or 10, default: 5)",
              enum: [5, 10],
              default: 5,
            },
          },
          required: ["prompt"],
        },
      },
      {
        name: "generate_video_veo",
        description:
          "Generate a video using Google Veo 3.1. High-quality 8-second 720p/1080p videos with stunning realism and native audio. Ranked #2 in quality benchmarks.",
        inputSchema: {
          type: "object",
          properties: {
            prompt: {
              type: "string",
              description: "The text prompt describing the video to generate",
            },
            duration: {
              type: "number",
              description: "Video duration in seconds (5-15, default: 8)",
              minimum: 5,
              maximum: 15,
              default: 8,
            },
            aspectRatio: {
              type: "string",
              enum: ["9:16", "16:9", "1:1"],
              description: "Video aspect ratio (default: 16:9)",
              default: "16:9",
            },
          },
          required: ["prompt"],
        },
      },
    ],
  };
});

// Handle tool calls
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  if (!args) {
    return {
      content: [{ type: "text", text: "Error: No arguments provided" }],
      isError: true,
    };
  }

  try {
    switch (name) {
      case "generate_image_dalle": {
        const result = await generateImageDallE(
          args.prompt as string,
          {
            size: args.size as any,
            quality: args.quality as any,
            style: args.style as any,
          }
        );
        return {
          content: [
            {
              type: "text",
              text: `Image generated successfully with DALL-E 3!\n\nPrompt: ${args.prompt}\n\nSaved to: ${result.path}\n\nRevised prompt: ${result.revisedPrompt}`,
            },
            {
              type: "image",
              data: result.base64,
              mimeType: "image/png",
            },
          ],
        };
      }

      case "generate_image_flux": {
        const result = await generateImageFlux(
          args.prompt as string,
          {
            width: args.width as number,
            height: args.height as number,
          }
        );
        return {
          content: [
            {
              type: "text",
              text: `Image generated successfully with Flux Pro!\n\nPrompt: ${args.prompt}\n\nSaved to: ${result.path}`,
            },
            {
              type: "image",
              data: result.base64,
              mimeType: "image/png",
            },
          ],
        };
      }

      case "generate_image_sd": {
        const result = await generateImageStableDiffusion(
          args.prompt as string,
          {
            negative_prompt: args.negative_prompt as string,
            aspect_ratio: args.aspect_ratio as any,
            model: args.model as any,
          }
        );
        return {
          content: [
            {
              type: "text",
              text: `Image generated successfully with Stable Diffusion 3.5!\n\nPrompt: ${args.prompt}\nModel: ${args.model || 'sd3.5-large'}\n\nSaved to: ${result.path}`,
            },
            {
              type: "image",
              data: result.base64,
              mimeType: "image/png",
            },
          ],
        };
      }

      case "generate_video_runway": {
        const result = await generateVideoRunway(
          args.prompt as string,
          {
            duration: (args.duration === 10 ? 10 : 5) as 5 | 10,
          }
        );
        return {
          content: [
            {
              type: "text",
              text: `Video generated successfully with Runway Gen-3!\n\nPrompt: ${args.prompt}\nDuration: ${args.duration || 5} seconds\n\nSaved to: ${result.path}\n\nNote: Video generation can take several minutes. The video has been saved to your output directory.`,
            },
          ],
        };
      }

      case "generate_video_veo": {
        const result = await generateVideoVeo(
          args.prompt as string,
          {
            duration: args.duration as number,
            aspectRatio: args.aspectRatio as any,
          }
        );
        return {
          content: [
            {
              type: "text",
              text: `Video generated successfully with Google Veo 3.1!\n\nPrompt: ${args.prompt}\nDuration: ${args.duration || 8} seconds\nAspect Ratio: ${args.aspectRatio || '16:9'}\n\nSaved to: ${result.path}\n\nNote: Veo 3 generates high-quality videos with native audio. The video has been saved to your output directory.`,
            },
          ],
        };
      }

      default:
        throw new Error(`Unknown tool: ${name}`);
    }
  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : String(error);
    return {
      content: [
        {
          type: "text",
          text: `Error: ${errorMessage}`,
        },
      ],
      isError: true,
    };
  }
});

// Start the server
async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error("MCP Content Generator server running on stdio");
}

main().catch((error) => {
  console.error("Fatal error:", error);
  process.exit(1);
});
