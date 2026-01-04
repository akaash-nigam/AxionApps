import axios from "axios";
import { saveFile, generateFilename, bufferToBase64 } from "../utils.js";

interface FluxOptions {
  width?: number;
  height?: number;
}

interface FluxResult {
  path: string;
  base64: string;
}

export async function generateImageFlux(
  prompt: string,
  options: FluxOptions = {}
): Promise<FluxResult> {
  if (!process.env.BFL_API_KEY) {
    throw new Error("BFL_API_KEY not set in environment variables");
  }

  const { width = 1024, height = 1024 } = options;

  console.error(`Generating image with Flux Pro: "${prompt}"`);

  // Request image generation
  const response = await axios.post(
    "https://api.bfl.ml/v1/flux-pro",
    {
      prompt,
      width,
      height,
    },
    {
      headers: {
        "Content-Type": "application/json",
        "X-Key": process.env.BFL_API_KEY,
      },
    }
  );

  const taskId = response.data.id;
  console.error(`Task ID: ${taskId}, waiting for completion...`);

  // Poll for result
  let imageUrl: string | null = null;
  let attempts = 0;
  const maxAttempts = 60; // 5 minutes max

  while (!imageUrl && attempts < maxAttempts) {
    await new Promise((resolve) => setTimeout(resolve, 5000)); // Wait 5 seconds

    const resultResponse = await axios.get(
      `https://api.bfl.ml/v1/get_result?id=${taskId}`,
      {
        headers: {
          "X-Key": process.env.BFL_API_KEY,
        },
      }
    );

    if (resultResponse.data.status === "Ready") {
      imageUrl = resultResponse.data.result.sample;
    } else if (resultResponse.data.status === "Error") {
      throw new Error(`Flux generation failed: ${resultResponse.data.error}`);
    }

    attempts++;
  }

  if (!imageUrl) {
    throw new Error("Flux image generation timed out");
  }

  // Download the image
  const imageResponse = await axios.get(imageUrl, {
    responseType: "arraybuffer",
  });
  const imageBuffer = Buffer.from(imageResponse.data);

  // Save to file
  const filename = generateFilename("flux", "png");
  const filepath = await saveFile(imageBuffer, filename);

  console.error(`Image saved to: ${filepath}`);

  return {
    path: filepath,
    base64: bufferToBase64(imageBuffer),
  };
}
