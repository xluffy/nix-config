import SwiftUI

struct AccountSessionImportView: View {
    let profile: AccountProfile
    @ObservedObject var store: AccountStore
    @Environment(\.dismiss) private var dismiss
    @State private var header = ""
    @State private var error: String?
    @State private var isImporting = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Import session · \(profile.name)").font(.headline)
            Text("Use this when Google sign-in or company SSO cannot run in the app's browser.")
            Text("In your signed-in browser, open Developer Tools → Network and reload \(profile.provider.host).")
            Text("Copy the Cookie request header from a request to \(profile.provider.host). Paste only that header below.")
            SecureField("Cookie header", text: $header)
                .textFieldStyle(.roundedBorder)
                .privacySensitive()
            Text("Session cookies grant account access. Import only your own account. Follow your work security policy.")
                .font(.caption).foregroundStyle(.secondary)
            Text("Import replaces this account slot's session. The app stores imported cookies in your local Keychain.")
                .font(.caption).foregroundStyle(.secondary)
            if let error { Text(error).font(.caption).foregroundStyle(.orange) }
            HStack {
                Spacer()
                if isImporting { ProgressView().controlSize(.small) }
                Button("Cancel") { header = ""; dismiss() }.disabled(isImporting)
                Button("Import") {
                    isImporting = true
                    let input = header
                    header = ""
                    Task {
                        do {
                            try await store.importSession(input, for: profile)
                            if store.state(for: profile).email != nil {
                                dismiss()
                            } else {
                                error = store.state(for: profile).error ?? "Account identity could not be confirmed."
                            }
                        } catch {
                            self.error = error.localizedDescription
                        }
                        isImporting = false
                    }
                }
                .disabled(header.isEmpty || isImporting)
            }
        }
        .padding(20)
        .frame(width: 520)
    }
}
