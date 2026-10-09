import AppKit
import SwiftUI
import WebKit

struct AccountManagerView: View {
    @ObservedObject var store: AccountStore
    @State private var loginProfile: AccountProfile?
    @State private var importProfile: AccountProfile?
    @State private var disconnectProfile: AccountProfile?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(AccountProfile.all) { profile in
                    AccountRow(
                        profile: profile,
                        state: store.state(for: profile),
                        isConnected: store.isConnected(profile),
                        onSignIn: { loginProfile = profile },
                        onImport: { importProfile = profile },
                        onRefresh: { Task { await store.refresh(profile) } },
                        onDisconnect: { disconnectProfile = profile },
                        onWorkspace: { store.selectWorkspace($0, for: profile) }
                    )
                    if profile != AccountProfile.all.last { Divider() }
                }
                Text("Each account uses a separate website session. Usage stays in the menu bar. It refreshes every five minutes, or every 15 minutes in Low Power Mode or when the Mac is hot.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            .padding(20)
        }
        .frame(minWidth: 460, minHeight: 440)
        .background(Color(nsColor: .windowBackgroundColor))
        .sheet(item: $loginProfile) { profile in
            AccountWebsiteView(profile: profile, store: store)
        }
        .sheet(item: $importProfile) { profile in
            AccountSessionImportView(profile: profile, store: store)
        }
        .alert(item: $disconnectProfile) { profile in
            Alert(
                title: Text("Disconnect \(profile.name)?"),
                message: Text("This removes only this account's local website session and usage reading."),
                primaryButton: .destructive(Text("Disconnect")) { Task { await store.disconnect(profile) } },
                secondaryButton: .cancel()
            )
        }
    }
}

private struct AccountRow: View {
    let profile: AccountProfile
    let state: AccountState
    let isConnected: Bool
    let onSignIn: () -> Void
    let onImport: () -> Void
    let onRefresh: () -> Void
    let onDisconnect: () -> Void
    let onWorkspace: (String?) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: isConnected ? "checkmark.circle.fill" : "circle.dashed")
                    .font(.title3)
                    .foregroundStyle(isConnected ? Color.green : Color.secondary)
                    .accessibilityLabel(isConnected ? "Connected" : "Not connected")
                VStack(alignment: .leading, spacing: 1) {
                    Text(profile.name).font(.headline)
                    Text(state.email ?? "Not signed in")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .textSelection(.enabled)
                }
                Spacer()
                if state.isRefreshing { ProgressView().controlSize(.small) }
            }
            if state.workspaces.count > 1 {
                Picker("Workspace", selection: Binding(
                    get: { state.workspaceID ?? "" },
                    set: { onWorkspace($0.isEmpty ? nil : $0) }
                )) {
                    Text("Select a workspace").tag("")
                    ForEach(state.workspaces) { workspace in
                        Text(workspace.name).tag(workspace.id)
                    }
                }
                .disabled(state.isRefreshing)
                .help("This account belongs to more than one workspace. Choose the workspace for the usage reading.")
            }
            if let error = state.error {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(Color.orange)
                    .lineLimit(2)
            }
            HStack {
                Button("Sign in…", action: onSignIn)
                Button("Import session…", action: onImport)
                Button("Refresh", action: onRefresh)
                    .disabled(!isConnected)
                Spacer()
                // Removing local data does not depend on a successful account check.
                Button("Disconnect", role: .destructive, action: onDisconnect)
                    .tint(.red)
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            .disabled(state.isRefreshing)
        }
    }
}

private struct AccountWebsiteView: View {
    let profile: AccountProfile
    @ObservedObject var store: AccountStore
    @Environment(\.dismiss) private var dismiss
    @State private var browser: WKWebView?
    @State private var pageURL: URL?

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(profile.name).font(.headline)
                Spacer()
                OriginLabel(origin: WebsiteOrigin(url: pageURL, provider: profile.provider))
            }
            .padding(12)
            Divider()
            if let browser {
                WebsiteView(webView: browser)
                    .onReceive(browser.publisher(for: \.url)) { pageURL = $0 }
            } else {
                Color.clear
            }
            Divider()
            HStack {
                VStack(alignment: .leading) {
                    if let email = store.state(for: profile).email {
                        Text(email).font(.caption).textSelection(.enabled)
                    }
                    Text(store.state(for: profile).error ?? "Sign in, then click Check account.")
                        .font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                if store.state(for: profile).isRefreshing { ProgressView().controlSize(.small) }
                Button("Check account") { Task { await store.refresh(profile) } }
                    .buttonStyle(.borderedProminent)
                    .disabled(store.state(for: profile).isRefreshing)
                Button("Close") { dismiss() }
            }
            .padding(12)
        }
        .frame(width: 960, height: 720)
        .onAppear { browser = store.session(for: profile).openWebsite() }
        // A full website uses much memory. Usage reads do not need it, so release it with this window.
        .onDisappear { store.session(for: profile).closeWebsite() }
    }
}

/// Shows the actual origin of the current page, not the provider that the account expects.
private struct OriginLabel: View {
    let origin: WebsiteOrigin

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: origin.isSecure ? "lock.fill" : "lock.open.fill")
                .accessibilityLabel(origin.isSecure ? "Secure connection" : "Not secure")
            Text(origin.label)
                .lineLimit(1)
                .truncationMode(.middle)
                .textSelection(.enabled)
            if let note = origin.note {
                Text("· \(note)").fontWeight(.semibold)
            }
        }
        .foregroundStyle(origin.kind == .external || !origin.isSecure ? Color.orange : Color.secondary)
        .help("The address of the page in this window.")
    }
}

private struct WebsiteView: NSViewRepresentable {
    let webView: WKWebView

    func makeNSView(context: Context) -> WKWebView { webView }
    func updateNSView(_ nsView: WKWebView, context: Context) {}
}
