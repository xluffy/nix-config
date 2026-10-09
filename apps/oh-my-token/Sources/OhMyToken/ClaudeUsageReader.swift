enum ClaudeUsageReader {
    // Website schema reference: CodexBar ClaudeWebAPIFetcher and ClaudeWebUsageExtraWindowTests.
    static let script = WebsiteScript.helpers + #"""
    try {
        const account = await request("/api/account", { Accept: "application/json" });
        const email = account.email_address;
        if (typeof email !== "string" || !email.trim()) throw new Error("sign-in-required");
        async function confirmAccount() {
            const confirmed = await request("/api/account", { Accept: "application/json" });
            if (confirmed.email_address !== email || (account.uuid && account.uuid !== confirmed.uuid)) {
                throw new Error("account-changed");
            }
        }
        const organizations = await request("/api/organizations", { Accept: "application/json" });
        if (!Array.isArray(organizations)) throw new Error("Website organization response changed.");
        const workspaces = organizations.filter(org =>
            typeof org.uuid === "string" && Array.isArray(org.capabilities) && org.capabilities.includes("chat")
        ).map(org => ({ id: org.uuid, name: typeof org.name === "string" && org.name ? org.name : org.uuid }));
        // A saved workspace that is no longer available is not a selection. The single-workspace rule applies again.
        // With more than one workspace, the reader returns no selection so that the Accounts picker asks the user.
        let selected = workspaces.find(org => org.id === workspaceID) || null;
        if (!selected && workspaces.length === 1) selected = workspaces[0];
        if (!selected) {
            await confirmAccount();
            const note = !workspaces.length ? "This account has no chat workspace."
                : workspaceID ? "The saved workspace is no longer available. Select the intended workspace in Accounts."
                : "Select the intended workspace in Accounts.";
            return JSON.stringify({ email, workspaces, workspaceID: null, windows: [], note });
        }
        const usage = await request(`/api/organizations/${encodeURIComponent(selected.id)}/usage`, { Accept: "application/json" });
        if (!usage || typeof usage !== "object" || Array.isArray(usage)) throw new Error("Website usage response changed.");
        const names = {
            five_hour: "Session", seven_day: "Weekly", seven_day_sonnet: "Sonnet · Weekly",
            seven_day_opus: "Opus · Weekly", seven_day_cowork: "Daily Routines", seven_day_routines: "Daily Routines"
        };
        const windows = [];
        for (const [id, value] of Object.entries(usage)) {
            if (id !== "five_hour" && !id.startsWith("seven_day")) continue;
            if (!value || typeof value !== "object") continue;
            const usedPercent = percentage(value.utilization);
            const resetAt = resetTime(value.resets_at);
            if (usedPercent === null && resetAt === null) continue;
            windows.push({ id, name: names[id] || id, usedPercent, remaining: null, limit: null, resetAt });
        }
        if (Array.isArray(usage.limits)) {
            for (const [index, value] of usage.limits.entries()) {
                if (!value || value.kind !== "weekly_scoped") continue;
                const model = value.scope?.model?.display_name;
                if (typeof model !== "string" || !model) continue;
                const usedPercent = percentage(value.percent);
                const resetAt = resetTime(value.resets_at);
                if (usedPercent === null && resetAt === null) continue;
                windows.push({ id: `weekly-scoped-${index}`, name: `${model} · Weekly`,
                    usedPercent, remaining: null, limit: null, resetAt });
            }
        }
        await confirmAccount();
        return JSON.stringify({ email, workspaces, workspaceID: selected.id, windows,
            note: windows.length ? null : "This workspace did not report usage limits." });
    } catch (error) { return failure(error); }
    """#
}
