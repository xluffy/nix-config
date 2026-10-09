import Foundation

/// The actual origin of a page in the sign-in browser, as the app shows it to the user.
struct WebsiteOrigin: Equatable {
    enum Kind {
        case provider
        case identityProvider
        case external
        case blank
    }

    /// Sign-in services that the providers use for single sign-on.
    /// Pages on these hosts get a "Sign-in provider" label, not an external-site warning.
    static let identityDomains = [
        "accounts.google.com",
        "appleid.apple.com",
        "login.microsoftonline.com",
        "login.live.com"
    ]

    let label: String
    let kind: Kind
    let isSecure: Bool

    init(url: URL?, provider: AccountProfile.Provider) {
        guard let url, let scheme = url.scheme?.lowercased() else {
            self.init(label: "No page", kind: .blank, isSecure: true)
            return
        }
        if scheme == "about" {
            self.init(label: url.absoluteString, kind: .blank, isSecure: true)
            return
        }
        // Show the scheme and the host only. A data or file URL can be long and can imitate a host name.
        guard let host = url.host?.lowercased(), !host.isEmpty else {
            self.init(label: "\(scheme):", kind: .external, isSecure: false)
            return
        }
        let label = url.port.map { "\(scheme)://\(host):\($0)" } ?? "\(scheme)://\(host)"
        let isSecure = scheme == "https"
        let kind: Kind
        if isSecure && Self.host(host, isIn: provider.siteDomains) {
            kind = .provider
        } else if isSecure && Self.host(host, isIn: Self.identityDomains) {
            kind = .identityProvider
        } else {
            kind = .external
        }
        self.init(label: label, kind: kind, isSecure: isSecure)
    }

    private init(label: String, kind: Kind, isSecure: Bool) {
        self.label = label
        self.kind = kind
        self.isSecure = isSecure
    }

    /// A short trust note for the origin. The provider's own site needs no note.
    var note: String? {
        switch kind {
        case .provider, .blank: return nil
        case .identityProvider: return "Sign-in provider"
        case .external: return "External site"
        }
    }

    private static func host(_ host: String, isIn domains: [String]) -> Bool {
        domains.contains { host == $0 || host.hasSuffix(".\($0)") }
    }
}
