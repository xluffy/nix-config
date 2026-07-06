/**
 * Colorful footer
 *
 * Left:  ~/project git:branch± | provider/model (thinking) | ↑1.2k ↓340 R5.1k W2.0k | $0.03
 * Right: [####.........] 40% (128K)
 */

import type { AssistantMessage } from "@earendil-works/pi-ai";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

type Rgb = { r: number; g: number; b: number };

const PROVIDER_COLORS: Record<string, Rgb> = {
  anthropic: { r: 191, g: 90, b: 242 },
  openai: { r: 52, g: 199, b: 89 },
  google: { r: 66, g: 133, b: 244 },
  openrouter: { r: 255, g: 159, b: 10 },
};

const CTX_STOPS: Rgb[] = [
  { r: 52, g: 199, b: 89 },
  { r: 255, g: 214, b: 10 },
  { r: 255, g: 159, b: 10 },
  { r: 255, g: 69, b: 58 },
];

const rgb = (t: string, { r, g, b }: Rgb) => `\x1b[38;2;${r};${g};${b}m${t}\x1b[39m`;

function lerp(pct: number, stops: Rgb[]): Rgb {
  const p = Math.max(0, Math.min(1, pct)) * (stops.length - 1);
  const i = Math.floor(p);
  const j = Math.min(stops.length - 1, i + 1);
  const t = p - i;
  return {
    r: Math.round(stops[i].r + (stops[j].r - stops[i].r) * t),
    g: Math.round(stops[i].g + (stops[j].g - stops[i].g) * t),
    b: Math.round(stops[i].b + (stops[j].b - stops[i].b) * t),
  };
}

function fmtCtx(n: number | undefined): string {
  if (!n) return "";
  if (n >= 1e6) return `${(n / 1e6).toFixed(n % 1e6 === 0 ? 0 : 1)}M`;
  if (n >= 1e3) return `${(n / 1e3).toFixed(n % 1e3 === 0 ? 0 : 1)}K`;
  return `${n}`;
}

function shortenCwd(cwd: string): string {
  const home = process.env.HOME;
  let p = home && cwd.startsWith(home) ? "~" + cwd.slice(home.length) : cwd;
  if (visibleWidth(p) > 40) {
    const parts = p.split("/").filter(Boolean);
    p = (p.startsWith("~/") ? "~/" : "/") + parts[0] + "/.../" + parts[parts.length - 1];
  }
  return p;
}

export default function (pi: ExtensionAPI) {
  let thinking = "off";
  let dirty = false;

  pi.on("thinking_level_select", async (e) => { thinking = e.level; });

  pi.on("turn_end", async () => {
    const r = await pi.exec("git", ["status", "--porcelain"], { cwd: pi.cwd }).catch(() => null);
    dirty = (r?.stdout.trim().length ?? 0) > 0;
  });

  pi.on("session_start", async (_e, ctx) => {
    thinking = pi.getThinkingLevel();
    const r = await pi.exec("git", ["status", "--porcelain"], { cwd: pi.cwd }).catch(() => null);
    dirty = (r?.stdout.trim().length ?? 0) > 0;

    ctx.ui.setFooter((tui, theme, footerData) => {
      const unsub = footerData.onBranchChange(() => tui.requestRender());

      return {
        dispose: unsub,
        invalidate() {},
        render(width: number): string[] {
          const sep = theme.fg("dim", " | ");

          // -- Left: path + git + model + tokens + cost --
          const cwd = shortenCwd(ctx.cwd);
          const slash = cwd.lastIndexOf("/");
          const pathStr = slash >= 0
            ? theme.fg("dim", cwd.slice(0, slash + 1)) + theme.fg("accent", theme.bold(cwd.slice(slash + 1)))
            : theme.fg("accent", theme.bold(cwd));

          const branch = footerData.getGitBranch();
          const branchStr = branch
            ? theme.fg(dirty ? "warning" : "success", `git:${branch}${dirty ? "±" : ""}`)
            : "";

          const model = ctx.model;
          const provider = (model as any)?.provider ?? "";
          const provColor = PROVIDER_COLORS[provider.toLowerCase()];
          const modelStr = provider && !model?.id?.includes("/")
            ? (provColor ? rgb(provider, provColor) : theme.fg("muted", provider))
              + theme.fg("dim", "/") + theme.fg("accent", model?.id ?? "")
            : theme.fg("accent", model?.id ?? "none");
          const thinkStr = thinking !== "off" ? theme.fg("muted", ` (${thinking})`) : "";

          // -- Token stats --
          const fmt = (n: number) => (n < 1000 ? `${n}` : `${(n / 1000).toFixed(1)}k`);
          let tokIn = 0, tokOut = 0, cacheR = 0, cacheW = 0, cost = 0;
          for (const e of ctx.sessionManager.getBranch()) {
            if (e.type === "message" && e.message.role === "assistant") {
              const m = e.message as AssistantMessage;
              tokIn += m.usage.input;
              tokOut += m.usage.output;
              cacheR += m.usage.cacheRead ?? 0;
              cacheW += m.usage.cacheWrite ?? 0;
              cost += m.usage.cost.total;
            }
          }
          const tokParts = [
            theme.fg("syntaxKeyword", `\u2191${fmt(tokIn)}`),
            theme.fg("syntaxFunction", `\u2193${fmt(tokOut)}`),
          ];
          if (cacheR > 0) tokParts.push(theme.fg("syntaxVariable", `R${fmt(cacheR)}`));
          if (cacheW > 0) tokParts.push(theme.fg("syntaxType", `W${fmt(cacheW)}`));
          const tokStr = tokParts.join(" ");

          const costStr = theme.fg("warning", cost < 0.01 ? `$${cost.toFixed(4)}` : `$${cost.toFixed(2)}`);

          const left = [pathStr, branchStr, modelStr + thinkStr, tokStr, costStr].filter(Boolean).join(sep);

          // -- Right: context bar --
          const usage = ctx.getContextUsage();
          const pct = usage?.percent ?? 0;
          const color = lerp(pct / 100, CTX_STOPS);
          const BARS = 10;
          const filled = Math.round((pct / 100) * BARS);
          const bar = rgb("[", color)
            + rgb("#".repeat(filled), color)
            + theme.fg("dim", ".".repeat(BARS - filled))
            + rgb("] ", color)
            + rgb(`${Math.round(pct)}%`, color);
          const ctxWin = model?.contextWindow ? theme.fg("dim", ` (${fmtCtx(model.contextWindow)})`) : "";
          const right = bar + ctxWin;

          // -- Layout --
          const lw = visibleWidth(left);
          const rw = visibleWidth(right);
          if (lw + rw <= width) {
            return [truncateToWidth(left + " ".repeat(width - lw - rw) + right, width)];
          }
          return [truncateToWidth(left, width), truncateToWidth(right, width)];
        },
      };
    });
  });
}
