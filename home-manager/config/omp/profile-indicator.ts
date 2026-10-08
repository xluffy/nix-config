import type { ExtensionAPI, ExtensionContext } from "@oh-my-pi/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  let timer: NodeJS.Timeout | undefined;
  let currentProvider: string | undefined;

  const updateStatus = (_event: unknown, ctx: ExtensionContext) => {
    const profile = process.env.OMP_PROFILE ?? "default";
    const color = profile === "work" ? "warning" : "success";
    const provider = ctx.model?.provider;
    currentProvider = provider;
    const auth = ctx.modelRegistry.authStorage;
    let account: string | undefined;

    if (provider) {
      const source = auth.keys.source(provider);
      if (source?.kind === "oauth") {
        const accounts = auth.oauth.accounts(provider, ctx.sessionManager.getSessionId());
        account = (accounts.find((entry) => entry.active) ?? (accounts.length === 1 ? accounts[0] : undefined))?.email;
      } else if (source) {
        account = "API token";
      }
    }

    const label = ctx.ui.theme.bold(ctx.ui.theme.fg(color, `● profile:${profile}${account ? ` · ${account}` : ""}`));
    ctx.ui.setStatus("account-profile", label);
    ctx.ui.setTitle(`OMP ${profile}`);
  };

  const startWatcher = (event: unknown, ctx: ExtensionContext) => {
    updateStatus(event, ctx);
    clearInterval(timer);
    if (ctx.mode === "tui" && ctx.agent.kind === "main") {
      timer = setInterval(() => {
        if (ctx.model?.provider !== currentProvider) updateStatus(undefined, ctx);
      }, 500);
    }
  };
  pi.on("session_start", startWatcher);
  pi.on("turn_start", updateStatus);
  pi.on("turn_end", updateStatus);
  pi.on("session_switch", startWatcher);
  pi.on("session_shutdown", () => {
    clearInterval(timer);
    timer = undefined;
  });
}
