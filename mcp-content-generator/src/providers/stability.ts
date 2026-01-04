import axios from "axios";
import { saveFile, generateFilename, bufferToBase64 } from "../utils.js";

interface StabilityOptions {
  negative_prompt?: string;
  aspect_ratio?: "1:1" | "16:9" | "21:9" | "9:16" | "9:21";
  model?: "sd3.5-large" | "sd3.5-large-turbo" | "sd3.5-medium";
}

interface StabilityResult {
  path: string;
  base64: string;
}

export async function generateImageStableDiffusion(
  prompt: string,
  options: StabilityOptions = {}
): Promise<StabilityResult> {
  if (!process.env.STABILITY_API_KEY) {
    throw new Error("STABILITY_API_KEY not set in environment variables");
  }

  const {
    negative_prompt,
    aspect_ratio = "1:1",
    model = "sd3.5-large",
  } = options;

  console.error(`Generating image with Stable Diffusion ${model}: "${prompt}"`);

  // Prepare form data
  const formData = new FormData();
  formData.append("prompt", prompt);
  if (negative_prompt) {
    formData.append("negative_prompt", negative_prompt);
  }
  formData.append("aspect_ratio", aspect_ratio);
  formData.append("model", model);
  formData.append("output_format", "png");

  const response = await axios.post(
    "https://api.stability.ai/v2beta/stable-image/generate/sd3",
    formData,
    {
      headers: {
        Authorization: `Bearer ${process.env.STABILITY_API_KEY}`,
        Accept: "image/*",
      },
      responseType: "arraybuffer",
    }
  );

  const imageBuffer = Buffer.from(response.data);

  // Save to file
  const filename = generateFilename("sd35", "png");
  const filepath = await saveFile(imageBuffer, filename);

  console.error(`Image saved to: ${filepath}`);

  return {
    path: filepath,
    base64: bufferToBase64(imageBuffer),
  };
}
