import AppKit
import WebKit

@MainActor
final class WebsiteSession: NSObject, WKNavigationDelegate, WKUIDelegate, NSWindowDelegate {
    let profile: AccountProfile
    private let dataStore: WKWebsiteDataStore
    /// The interactive website. It exists only while the sign-in window is open.
    private var browser: WKWebView?
    /// The page of the usage read in progress. Each read loads a new page and releases it at the end.
    private var reader: WKWebView?
    private var navigation: CheckedContinuation<Void, Error>?
    private var navigationTimeout: Task<Void, Never>?
    private var popupWindows: [NSWindow] = []
    private var popupOrigins: [ObjectIdentifier: NSKeyValueObservation] = [:]
    private var restoredImport = false

    init(profile: AccountProfile) {
        self.profile = profile
        dataStore = WKWebsiteDataStore(forIdentifier: profile.id)
        super.init()
    }

    /// Loads the provider website for sign-in. Call `closeWebsite()` when the sign-in window closes.
    func openWebsite() -> WKWebView {
        if let browser { return browser }
        let browser = makeWebView()
        browser.uiDelegate = self
        browser.load(URLRequest(url: profile.provider.websiteURL))
        self.browser = browser
        return browser
    }

    /// Releases the website and its popups. The cookies stay in the account data store.
    func closeWebsite() {
        browser?.stopLoading()
        browser = nil
        for window in popupWindows { window.close() }
        popupWindows.removeAll()
    }

    func readUsage(workspaceID: String?) async throws -> UsagePayload {
        if !restoredImport {
            try await SessionImport.restore(for: profile, into: dataStore.httpCookieStore)
            restoredImport = true
        }
        // The reader needs only the provider origin and the account cookies, not the full website.
        // Releasing the page after the read lets its WebContent process exit until the next read.
        let reader = makeWebView()
        self.reader = reader
        defer { if self.reader === reader { self.reader = nil } }
        try await navigate(reader, to: profile.provider.readerURL)
        guard reader.url?.host == profile.provider.host else { throw WebsiteError.signInRequired }
        let script: String
        switch profile.provider {
        case .claude: script = ClaudeUsageReader.script
        case .chatGPT: script = ChatGPTUsageReader.script
        }
        let value = try await reader.callAsyncJavaScript(
            script,
            arguments: ["workspaceID": workspaceID as Any? ?? NSNull()],
            in: nil,
            contentWorld: .page
        )
        guard let text = value as? String, let data = text.data(using: .utf8) else {
            throw WebsiteError.unavailable("Website returned an unreadable usage response.")
        }
        if let result = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let error = result["error"] as? String {
            switch error {
            case "sign-in-required": throw WebsiteError.signInRequired
            case "account-changed": throw WebsiteError.accountChanged
            case "timeout": throw WebsiteError.timeout
            case "challenge": throw WebsiteError.unavailable("Website blocked this request. Open the account website to check it.")
            default: throw WebsiteError.unavailable(error)
            }
        }
        return try JSONDecoder().decode(UsagePayload.self, from: data)
    }

    func disconnect() async throws {
        try SessionImport.remove(for: profile)
        finishNavigation(.failure(WebsiteError.signInRequired))
        // Unload a read in progress, so that its requests cannot store cookies again after the removal.
        reader?.load(URLRequest(url: URL(string: "about:blank")!))
        closeWebsite()
        await withCheckedContinuation { continuation in
            dataStore.removeData(
                ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
                modifiedSince: .distantPast
            ) { continuation.resume() }
        }
        restoredImport = false
    }

    func importSession(_ cookies: [HTTPCookie]) async throws {
        try SessionImport.save(cookies, for: profile)
        for cookie in cookies {
            await dataStore.httpCookieStore.setCookie(cookie)
        }
        restoredImport = true
    }

    private func makeWebView() -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = dataStore
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = self
        return webView
    }

    private func navigate(_ webView: WKWebView, to url: URL) async throws {
        try await withCheckedThrowingContinuation { continuation in
            navigation = continuation
            navigationTimeout = Task { [weak self, weak webView] in
                do { try await Task.sleep(for: .seconds(30)) } catch { return }
                webView?.stopLoading()
                self?.finishNavigation(.failure(WebsiteError.timeout))
            }
            webView.load(URLRequest(url: url))
        }
    }

    private func finishNavigation(_ result: Result<Void, Error>) {
        navigationTimeout?.cancel()
        navigationTimeout = nil
        let pending = navigation
        navigation = nil
        pending?.resume(with: result)
    }

    // WebKit invokes these callbacks on the main thread. SDK 14 does not annotate their actor isolation.
    // Only the reader page completes a navigation wait. The website and the popups never do.
    nonisolated func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        MainActor.assumeIsolated {
            guard webView === reader else { return }
            finishNavigation(.success(()))
        }
    }

    nonisolated func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        MainActor.assumeIsolated {
            guard webView === reader else { return }
            finishNavigation(.failure(error))
        }
    }

    nonisolated func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        MainActor.assumeIsolated {
            guard webView === reader else { return }
            finishNavigation(.failure(error))
        }
    }

    nonisolated func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        MainActor.assumeIsolated {
            decisionHandler(policy(for: navigationAction))
        }
    }

    /// One policy for the website, the reader page, and every popup.
    /// HTTPS pages stay in the app so that provider and company SSO redirects work. The origin label marks external pages.
    /// A link that the user clicks to an external site opens in the system browser.
    private func policy(for action: WKNavigationAction) -> WKNavigationActionPolicy {
        // Subframes keep WebKit's same-origin rules. The origin label describes only the top-level page.
        // A nil target frame is a request for a new window.
        if let frame = action.targetFrame, !frame.isMainFrame { return .allow }
        guard let url = action.request.url, let scheme = url.scheme?.lowercased() else { return .cancel }
        let origin = WebsiteOrigin(url: url, provider: profile.provider)
        if origin.kind == .external, action.navigationType == .linkActivated,
           ["https", "http", "mailto"].contains(scheme) {
            NSWorkspace.shared.open(url)
            return .cancel
        }
        return scheme == "https" || scheme == "about" ? .allow : .cancel
    }

    nonisolated func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
                            for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        MainActor.assumeIsolated {
            guard navigationAction.targetFrame == nil else { return nil }
            let popup = WKWebView(frame: .zero, configuration: configuration)
            popup.navigationDelegate = self
            popup.uiDelegate = self
            let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 800, height: 700),
                                  styleMask: [.titled, .closable, .resizable], backing: .buffered, defer: false)
            window.contentView = popup
            window.isReleasedWhenClosed = false
            window.delegate = self
            // The title shows the actual page origin, and it changes with every navigation.
            let provider = profile.provider
            let account = "oh-my-token · \(profile.name)"
            popupOrigins[ObjectIdentifier(window)] = popup.observe(\.url, options: [.initial]) { [weak window] popup, _ in
                MainActor.assumeIsolated {
                    let origin = WebsiteOrigin(url: popup.url ?? navigationAction.request.url, provider: provider)
                    window?.title = origin.label
                    window?.subtitle = [account, origin.note].compactMap { $0 }.joined(separator: " · ")
                }
            }
            popupWindows.append(window)
            window.center()
            window.makeKeyAndOrderFront(nil)
            return popup
        }
    }

    nonisolated func webViewDidClose(_ webView: WKWebView) {
        MainActor.assumeIsolated {
            popupWindows.first { $0.contentView === webView }?.close()
        }
    }

    func windowWillClose(_ notification: Notification) {
        guard let window = notification.object as? NSWindow else { return }
        popupOrigins.removeValue(forKey: ObjectIdentifier(window))?.invalidate()
        popupWindows.removeAll { $0 === window }
    }
}
