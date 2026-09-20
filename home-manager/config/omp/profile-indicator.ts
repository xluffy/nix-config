import type { HookAPI } from "@oh-my-pi/pi-coding-agent";

export default function (pi: HookAPI) {
  pi.on("session_start", (_event, ctx) => {
    const profile = process.env.OMP_PROFILE ?? "default";
    const color = profile === "work" ? "warning" : "success";
    const label = ctx.ui.theme.bold(ctx.ui.theme.fg(color, `● profile:${profile}`));

    ctx.ui.setStatus("account-profile", label);
    ctx.ui.setTitle(`OMP ${profile}`);
  });
}
