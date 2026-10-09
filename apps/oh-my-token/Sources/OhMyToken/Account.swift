import Foundation

struct AccountProfile: Identifiable, Equatable {
    enum Provider {
        case claude
        case chatGPT

        var host: String {
            switch self {
            case .claude: return "claude.ai"
            case .chatGPT: return "chatgpt.com"
            }
        }

        /// Domains that belong to the provider. Sign-in pages on these domains are not external.
        var siteDomains: [String] {
            switch self {
            case .claude: return ["claude.ai", "claude.com", "anthropic.com"]
            case .chatGPT: return ["chatgpt.com", "openai.com"]
            }
        }

        var websiteURL: URL {
            switch self {
            case .claude: return URL(string: "https://claude.ai/settings/usage")!
            case .chatGPT: return URL(string: "https://chatgpt.com/settings/usage?tab=overview")!
            }
        }

        /// A small static file on the provider origin. The usage reader runs in this document.
        var readerURL: URL { URL(string: "https://\(host)/robots.txt")! }
    }

    let id: UUID
    let name: String
    let provider: Provider

    static let all: [AccountProfile] = [
        .init(id: UUID(uuidString: "C3640423-AB53-460B-A746-B8BC1D304722")!, name: "Claude · Personal", provider: .claude),
        .init(id: UUID(uuidString: "6A6CC28A-DA74-4F89-B436-796356DE7A11")!, name: "Claude · Work", provider: .claude),
        .init(id: UUID(uuidString: "DC116FAD-8BC2-4E22-966D-A0C4504D1F34")!, name: "ChatGPT Plus · Personal", provider: .chatGPT)
    ]
    .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
}

struct Workspace: Decodable, Identifiable {
    let id: String
    let name: String
}

struct UsageWindow: Decodable, Identifiable {
    let id: String
    let name: String
    let usedPercent: Double?
    let remaining: Int?
    let status: String?
    let resetAt: String?

    var resetDate: Date? {
        guard let resetAt else { return nil }
        return Self.fractionalFormatter.date(from: resetAt) ?? Self.standardFormatter.date(from: resetAt)
    }

    private static let standardFormatter = ISO8601DateFormatter()
    private static let fractionalFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
}

struct UsagePayload: Decodable {
    let email: String
    let workspaces: [Workspace]
    let workspaceID: String?
    let windows: [UsageWindow]
    let note: String?
}

struct UsageSnapshot {
    let payload: UsagePayload
    let updatedAt: Date
}

struct AccountState {
    var email: String?
    var workspaces: [Workspace] = []
    var workspaceID: String?
    var snapshot: UsageSnapshot?
    var error: String?
    var isRefreshing = false
}

enum WebsiteError: LocalizedError {
    case signInRequired
    case accountChanged
    case timeout
    case unavailable(String)

    var errorDescription: String? {
        switch self {
        case .signInRequired: return "Sign in to this account."
        case .accountChanged: return "Account changed during refresh. Try Refresh."
        case .timeout: return "Website did not respond."
        case .unavailable(let message): return message
        }
    }
}
