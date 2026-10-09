enum ChatGPTUsageReader {
    // Website session only. This reader is read-only: it sends GET requests only.
    // It never sends a prompt, a message, or a conversation request.
    // Schemas: openai/codex@50379197779be0e5afcbddb014a34cd1fc08af53 and gpt2agent/usage.py.
    static let script = WebsiteScript.helpers + #"""
    try {
        const session = await request("/api/auth/session");
        const email = session.user?.email;
        if (typeof email !== "string" || !email.trim() || typeof session.accessToken !== "string" || !session.accessToken) {
            throw new Error("sign-in-required");
        }
        async function confirmAccount() {
            const confirmed = await request("/api/auth/session");
            if (confirmed.user?.email !== email || (session.user?.id && confirmed.user?.id !== session.user.id)) {
                throw new Error("account-changed");
            }
        }
        const headers = { Authorization: `Bearer ${session.accessToken}`, "Content-Type": "application/json" };
        const accounts = await request("/backend-api/accounts/check/v4-2023-04-27", headers);
        if (!accounts.accounts || typeof accounts.accounts !== "object") throw new Error("Website account response changed.");
        const unique = new Map();
        for (const value of Object.values(accounts.accounts)) {
            if (typeof value?.account?.account_id === "string") unique.set(value.account.account_id, value);
        }
        const contexts = [...unique.values()].filter(value => value.account.structure === "personal");
        // Route explicitly to one personal account, never the website's selected business workspace.
        if (contexts.length !== 1) {
            await confirmAccount();
            return JSON.stringify({ email, workspaces: [], workspaceID: null, windows: [],
                note: "A unique personal quota context cannot be verified for this session." });
        }
        const accountID = contexts[0].account.account_id;
        headers["ChatGPT-Account-Id"] = accountID;
        const dashboard = await request("/backend-api/wham/usage", headers);
        if ((dashboard.account_id != null && dashboard.account_id !== accountID)
            || (dashboard.user_id != null && session.user?.id && dashboard.user_id !== session.user.id)) {
            throw new Error("account-changed");
        }
        if (!dashboard || typeof dashboard !== "object" || !("rate_limit" in dashboard)
            || (dashboard.additional_rate_limits != null && !Array.isArray(dashboard.additional_rate_limits))) {
            throw new Error("Website usage dashboard response changed.");
        }
        const windows = [];
        function addDashboardWindows(id, name, limit) {
            if (limit == null) return;
            if (typeof limit !== "object") throw new Error("Website usage dashboard response changed.");
            for (const position of ["primary_window", "secondary_window"]) {
                const window = limit[position];
                if (window == null) continue;
                if (typeof window !== "object") throw new Error("Website usage dashboard response changed.");
                const seconds = window.limit_window_seconds;
                const period = seconds === 18000 ? "5-hour" : seconds === 604800 ? "Weekly"
                    : count(seconds) > 0 ? `${seconds}s window` : position === "primary_window" ? "Primary window" : "Secondary window";
                windows.push({ id: `${id}-${position}`, name: `${name} · ${period}`,
                    usedPercent: percentage(window.used_percent), remaining: null, resetAt: resetTime(window.reset_at),
                    status: limit.allowed === false || limit.limit_reached === true ? "Allowance limit reached" : null });
            }
        }
        addDashboardWindows("agentic", "Work & Codex", dashboard.rate_limit);
        for (const [index, value] of (dashboard.additional_rate_limits || []).entries()) {
            const name = typeof value?.limit_name === "string" && value.limit_name.trim() ? value.limit_name
                : typeof value?.metered_feature === "string" && value.metered_feature.trim() ? value.metered_feature : "Additional allowance";
            addDashboardWindows(`agentic-extra-${index}`, `Work & Codex · ${name}`, value?.rate_limit);
        }
        if (windows.length === 0) {
            windows.push({ id: "agentic-unavailable", name: "Work & Codex", usedPercent: null, remaining: null,
                resetAt: null, status: "Usage unavailable" });
        }
        // Read the dashboard allowance only. Do not request conversation data or chat limits.
        await confirmAccount();
        return JSON.stringify({ email, workspaces: [], workspaceID: null, windows,
            note: "Work and Codex share this dashboard allowance. The app reads usage only and never sends a prompt." });
    } catch (error) { return failure(error); }
    """#
}
