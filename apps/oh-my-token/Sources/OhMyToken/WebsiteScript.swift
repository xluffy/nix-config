enum WebsiteScript {
    static let helpers = #"""
    // Read-only helper. The app must never send a prompt or a conversation request.
    // Therefore this helper sends GET requests only and accepts no request body.
    // A reader can send the website session token as authentication for these GET requests.
    async function request(path, headers = {}) {
        const controller = new AbortController();
        const timeout = setTimeout(() => controller.abort(), 15000);
        try {
            const response = await fetch(path, {
                credentials: "include", headers, signal: controller.signal,
                method: "GET"
            });
            if (response.status === 401) throw new Error("sign-in-required");
            if (response.status === 403) {
                const challenge = response.headers.get("cf-mitigated")?.trim().toLowerCase() === "challenge"
                    || (await response.text()).slice(0, 65536).toLowerCase().includes("just a moment");
                throw new Error(challenge ? "challenge" : "sign-in-required");
            }
            if (response.status === 429) throw new Error("Website rate limit reached. Try Refresh later.");
            if (!response.ok) throw new Error(`Usage request failed (HTTP ${response.status}).`);
            try { return await response.json(); }
            catch { throw new Error("Website returned an unreadable usage response."); }
        } catch (error) {
            if (error.name === "AbortError") throw new Error("timeout");
            throw error;
        } finally { clearTimeout(timeout); }
    }
    function percentage(value) {
        return typeof value === "number" && Number.isFinite(value) && value >= 0 ? value : null;
    }
    function count(value) {
        return typeof value === "number" && Number.isSafeInteger(value) && value >= 0 ? value : null;
    }
    function resetTime(value) {
        if (typeof value !== "string" && typeof value !== "number") return null;
        const date = new Date(typeof value === "number" ? value * 1000 : Date.parse(value));
        // A finite number can still be outside the Date range. An invalid optional reset must not discard the reading.
        return Number.isNaN(date.getTime()) ? null : date.toISOString();
    }
    function failure(error) {
        const known = error.message;
        const safe = known === "sign-in-required" || known === "account-changed"
            || known === "timeout" || known === "challenge"
            || known.startsWith("Usage request failed") || known.startsWith("Website ");
        return JSON.stringify({ error: safe ? known : "Website usage could not be read. Open the account website and try Refresh." });
    }
    """#
}
