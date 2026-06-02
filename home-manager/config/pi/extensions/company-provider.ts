import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  const baseUrl = process.env.SKM_BASE_URL;
  const apiKey = process.env.SKM_ANTHROPIC_KEY;
  if (!baseUrl || !apiKey) return;

  pi.registerProvider("anthropic", { baseUrl, apiKey, authHeader: true });
}
