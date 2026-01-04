import OpenAI from "openai";
import axios from "axios";
import { saveFile, generateFilename, bufferToBase64 } from "../utils.js";

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

interface DalleOptions {
  size?: "1024x1024" | "1792x1024" | "1024x1792";
  quality?: "standard" | "hd";
  style?: "natural" | "vivid";
}

interface DalleResult {
  path: string;
  base64: string;
  revisedPrompt: string;
}

export async function generateImageDallE(
  prompt: string,
  options: DalleOptions = {}
): Promise<DalleResult> {
  if (!process.env.OPENAI_API_KEY) {
    throw new Error("OPENAI_API_KEY not set in environment variables");
  }

  const {
    size = "1024x1024",
    quality = "standard",
    style = "vivid",
  } = options;

  console.error(`Generating image with DALL-E 3: "${prompt}"`);

  const response = await openai.images.generate({
    model: "dall-e-3",
    prompt,
    n: 1,
    size,
    quality,
    style,
    response_format: "url",
  });

  if (!response.data || !response.data[0]) {
    throw new Error("No image data returned from DALL-E");
  }

  const imageUrl = response.data[0].url;
  const revisedPrompt = response.data[0].revised_prompt || prompt;

  if (!imageUrl) {
    throw new Error("No image URL returned from DALL-E");
  }

  // Download the image
  const imageResponse = await axios.get(imageUrl, {
    responseType: "arraybuffer",
  });
  const imageBuffer = Buffer.from(imageResponse.data);

  // Save to file
  const filename = generateFilename("dalle", "png");
  const filepath = await saveFile(imageBuffer, filename);

  console.error(`Image saved to: ${filepath}`);

  return {
    path: filepath,
    base64: bufferToBase64(imageBuffer),
    revisedPrompt,
  };
}
