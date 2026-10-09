import type { ExtensionAPI, ExtensionContext } from "@oh-my-pi/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  let timer: NodeJS.Timeout | undefined;
  let currentStatus: string | undefined;

  const updateStatus = (_event: unknown, ctx: ExtensionContext) => {
    const profile = process.env.OMP_PROFILE ?? "default";
    const color = profile === "work" ? "warning" : "success";
    const provider = ctx.model?.provider;
    const model = ctx.model;
    const thinkingLevel = pi.getThinkingLevel();
    currentStatus = `${provider}/${model?.id}/${thinkingLevel}`;
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

    const modelLabel = model ? ` · ${model.name}${thinkingLevel ? ` (${thinkingLevel})` : ""}` : "";
    const label = ctx.ui.theme.bold(ctx.ui.theme.fg(color, `● profile:${profile}${account ? ` · ${account}` : ""}${modelLabel}`));
    ctx.ui.setStatus("account-profile", label);
    ctx.ui.setTitle(`OMP ${profile}`);
  };

  const startWatcher = (event: unknown, ctx: ExtensionContext) => {
    updateStatus(event, ctx);
    clearInterval(timer);
    if (ctx.mode === "tui" && ctx.agent.kind === "main") {
      timer = setInterval(() => {
        const status = `${ctx.model?.provider}/${ctx.model?.id}/${pi.getThinkingLevel()}`;
        if (status !== currentStatus) updateStatus(undefined, ctx);
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
