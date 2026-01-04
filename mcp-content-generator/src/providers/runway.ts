import axios from "axios";
import { saveFile, generateFilename } from "../utils.js";

interface RunwayOptions {
  duration?: 5 | 10;
}

interface RunwayResult {
  path: string;
}

export async function generateVideoRunway(
  prompt: string,
  options: RunwayOptions = {}
): Promise<RunwayResult> {
  if (!process.env.RUNWAY_API_KEY) {
    throw new Error("RUNWAY_API_KEY not set in environment variables");
  }

  const { duration = 5 } = options;

  console.error(`Generating video with Runway Gen-3: "${prompt}"`);

  // Note: This is a placeholder implementation as Runway's API documentation
  // may vary. You'll need to adjust this based on the actual API endpoints.

  // Request video generation
  const response = await axios.post(
    "https://api.runwayml.com/v1/gen3/text-to-video",
    {
      prompt,
      duration,
      model: "gen3a_turbo",
    },
    {
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${process.env.RUNWAY_API_KEY}`,
      },
    }
  );

  const taskId = response.data.id;
  console.error(`Task ID: ${taskId}, waiting for completion...`);

  // Poll for result
  let videoUrl: string | null = null;
  let attempts = 0;
  const maxAttempts = 120; // 10 minutes max

  while (!videoUrl && attempts < maxAttempts) {
    await new Promise((resolve) => setTimeout(resolve, 5000)); // Wait 5 seconds

    const resultResponse = await axios.get(
      `https://api.runwayml.com/v1/tasks/${taskId}`,
      {
        headers: {
          Authorization: `Bearer ${process.env.RUNWAY_API_KEY}`,
        },
      }
    );

    if (resultResponse.data.status === "SUCCEEDED") {
      videoUrl = resultResponse.data.output[0];
    } else if (resultResponse.data.status === "FAILED") {
      throw new Error(`Runway generation failed: ${resultResponse.data.error}`);
    }

    attempts++;
    console.error(`Status: ${resultResponse.data.status} (attempt ${attempts}/${maxAttempts})`);
  }

  if (!videoUrl) {
    throw new Error("Runway video generation timed out");
  }

  // Download the video
  const videoResponse = await axios.get(videoUrl, {
    responseType: "arraybuffer",
  });
  const videoBuffer = Buffer.from(videoResponse.data);

  // Save to file
  const filename = generateFilename("runway", "mp4");
  const filepath = await saveFile(videoBuffer, filename);

  console.error(`Video saved to: ${filepath}`);

  return {
    path: filepath,
  };
}
