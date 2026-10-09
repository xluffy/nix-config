import Foundation
import Security
import WebKit

@MainActor
enum SessionImport {
    private static let service = "com.quang.oh-my-token.imported-session"

    static func cookies(from header: String, for profile: AccountProfile) throws -> [HTTPCookie] {
        var text = header.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.lowercased().hasPrefix("cookie:") { text = String(text.dropFirst(7)).trimmingCharacters(in: .whitespaces) }
        guard !text.isEmpty, text.utf8.count <= 32768, !text.contains("\n"), !text.contains("\r") else {
            throw WebsiteError.unavailable("Paste only the Cookie header from this account's website request.")
        }
        var names = Set<String>()
        let cookies = try text.split(separator: ";").map { component -> HTTPCookie in
            let pair = component.trimmingCharacters(in: .whitespaces).split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
            guard pair.count == 2, !pair[0].isEmpty, names.insert(String(pair[0])).inserted,
                  pair[0].unicodeScalars.allSatisfy({ $0.isASCII && !$0.properties.isWhitespace && !"()<>@,;:\\\"/[]?={}".unicodeScalars.contains($0) }),
                  pair[1].unicodeScalars.allSatisfy({ $0.value >= 0x20 && $0.value != 0x7F }),
                  let cookie = HTTPCookie.cookies(
                    withResponseHeaderFields: ["Set-Cookie": "\(pair[0])=\(pair[1]); Path=/; Secure; HttpOnly"],
                    for: profile.provider.websiteURL
                  ).first else {
                throw WebsiteError.unavailable("Cookie header is invalid or contains duplicate names.")
            }
            return cookie
        }
        guard cookies.contains(where: { isAuthenticationCookie($0, for: profile) }) else {
            throw WebsiteError.unavailable("Cookie header does not contain this website's session cookie.")
        }
        return cookies
    }

    static func save(_ cookies: [HTTPCookie], for profile: AccountProfile) throws {
        let values = Dictionary(uniqueKeysWithValues: cookies.map { ($0.name, $0.value) })
        let data = try JSONSerialization.data(withJSONObject: values)
        var query = keychainQuery(profile)
        let status = SecItemUpdate(query as CFDictionary, [kSecValueData as String: data] as CFDictionary)
        if status == errSecItemNotFound {
            query[kSecValueData as String] = data
            query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
            guard SecItemAdd(query as CFDictionary, nil) == errSecSuccess else {
                throw WebsiteError.unavailable("Cannot save this session in Keychain.")
            }
        } else if status != errSecSuccess {
            throw WebsiteError.unavailable("Cannot update this session in Keychain.")
        }
    }

    static func restore(for profile: AccountProfile, into store: WKHTTPCookieStore) async throws {
        let current = await store.allCookies()
        // A newer website login owns its cookies. Never overwrite it with an imported session.
        if current.contains(where: { isAuthenticationCookie($0, for: profile) }) { return }
        var query = keychainQuery(profile)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecItemNotFound { return }
        guard status == errSecSuccess, let data = result as? Data,
              let values = try JSONSerialization.jsonObject(with: data) as? [String: String] else {
            throw WebsiteError.unavailable("Cannot restore this account's imported session from Keychain.")
        }
        let header = values.map { "\($0.key)=\($0.value)" }.joined(separator: "; ")
        for cookie in try cookies(from: header, for: profile) { await store.setCookie(cookie) }
    }

    static func remove(for profile: AccountProfile) throws {
        let status = SecItemDelete(keychainQuery(profile) as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw WebsiteError.unavailable("Cannot remove this account's imported session from Keychain.")
        }
    }

    private static func isAuthenticationCookie(_ cookie: HTTPCookie, for profile: AccountProfile) -> Bool {
        let domain = cookie.domain.trimmingCharacters(in: CharacterSet(charactersIn: "."))
        guard domain == profile.provider.host else { return false }
        switch profile.provider {
        case .claude: return cookie.name == "sessionKey"
        case .chatGPT: return cookie.name.contains("session-token")
        }
    }

    private static func keychainQuery(_ profile: AccountProfile) -> [String: Any] {
        [kSecClass as String: kSecClassGenericPassword,
         kSecAttrService as String: service,
         kSecAttrAccount as String: profile.id.uuidString]
    }
}
