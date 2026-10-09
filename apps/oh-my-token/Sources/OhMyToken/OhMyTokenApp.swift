import SwiftUI

@main
@MainActor
struct OhMyTokenApp: App {
    @StateObject private var store: AccountStore

    init() {
        let accountStore = AccountStore()
        accountStore.startPolling()
        _store = StateObject(wrappedValue: accountStore)
    }

    var body: some Scene {
        MenuBarExtra {
            UsageView(store: store)
        } label: {
            Image(nsImage: MenuBarIcon.image)
                .accessibilityLabel("oh-my-token")
        }
        .menuBarExtraStyle(.window)

        Window("oh-my-token · Accounts", id: "accounts") {
            AccountManagerView(store: store)
        }
        .defaultSize(width: 500, height: 640)
    }
}
