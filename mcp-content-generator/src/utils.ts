import fs from "fs/promises";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export const OUTPUT_DIR =
  process.env.OUTPUT_DIR || path.join(process.cwd(), "generated");

export async function ensureOutputDir(): Promise<void> {
  try {
    await fs.access(OUTPUT_DIR);
  } catch {
    await fs.mkdir(OUTPUT_DIR, { recursive: true });
  }
}

export async function saveFile(
  data: Buffer | string,
  filename: string
): Promise<string> {
  await ensureOutputDir();
  const filepath = path.join(OUTPUT_DIR, filename);
  await fs.writeFile(filepath, data);
  return filepath;
}

export function generateFilename(prefix: string, extension: string): string {
  const timestamp = new Date().toISOString().replace(/[:.]/g, "-");
  return `${prefix}_${timestamp}.${extension}`;
}

export function base64ToBuffer(base64: string): Buffer {
  return Buffer.from(base64, "base64");
}

export function bufferToBase64(buffer: Buffer): string {
  return buffer.toString("base64");
}
