import Foundation
import SwiftUI

@MainActor
final class AccountStore: ObservableObject {
    @Published private(set) var states: [UUID: AccountState] = [:]
    private var sessions: [UUID: WebsiteSession] = [:]
    private var connected: Set<UUID> = []
    private var generations: [UUID: Int] = [:]
    private var polling: Task<Void, Never>?
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        for profile in AccountProfile.all {
            var state = AccountState()
            state.workspaceID = defaults.string(forKey: "workspace.\(profile.id)")
            states[profile.id] = state
            if defaults.bool(forKey: "connected.\(profile.id)") { connected.insert(profile.id) }
        }
    }

    var canRefresh: Bool { !connected.isEmpty }
    var isRefreshing: Bool { states.values.contains { $0.isRefreshing } }

    func isConnected(_ profile: AccountProfile) -> Bool {
        connected.contains(profile.id)
    }

    func state(for profile: AccountProfile) -> AccountState {
        states[profile.id] ?? AccountState()
    }

    func session(for profile: AccountProfile) -> WebsiteSession {
        if let session = sessions[profile.id] { return session }
        let session = WebsiteSession(profile: profile)
        sessions[profile.id] = session
        return session
    }

    /// The interval between automatic refreshes. Manual refresh always runs at once.
    /// Low Power Mode and a serious thermal state make the interval longer to save energy.
    private static var pollingInterval: Duration {
        let info = ProcessInfo.processInfo
        let constrained = info.isLowPowerModeEnabled || info.thermalState == .serious || info.thermalState == .critical
        return .seconds(constrained ? 900 : 300)
    }

    func startPolling() {
        guard polling == nil else { return }
        polling = Task { [weak self] in
            while !Task.isCancelled {
                await self?.refreshAll()
                let interval = AccountStore.pollingInterval
                // The tolerance lets macOS group this wake-up with other timers.
                do { try await Task.sleep(for: interval, tolerance: interval / 5) } catch { return }
            }
        }
    }

    func refreshAll() async {
        // Each account has its own WebKit profile. A failure cannot replace another account's reading.
        // The accounts refresh at the same time, so a slow account does not delay the others.
        await withTaskGroup(of: Void.self) { group in
            for profile in AccountProfile.all where connected.contains(profile.id) {
                group.addTask { await self.refresh(profile) }
            }
        }
    }

    func refresh(_ profile: AccountProfile) async {
        guard !state(for: profile).isRefreshing else { return }
        let generation = generations[profile.id, default: 0]
        states[profile.id]?.isRefreshing = true
        defer {
            if generations[profile.id, default: 0] == generation {
                states[profile.id]?.isRefreshing = false
            }
        }
        do {
            let payload = try await session(for: profile).readUsage(workspaceID: state(for: profile).workspaceID)
            guard generations[profile.id, default: 0] == generation else { return }
            guard !payload.email.isEmpty else {
                throw WebsiteError.unavailable("Website did not provide an account email.")
            }
            if state(for: profile).email != nil && state(for: profile).email != payload.email {
                states[profile.id]?.snapshot = nil
            }
            states[profile.id]?.email = payload.email
            states[profile.id]?.workspaces = payload.workspaces
            states[profile.id]?.workspaceID = payload.workspaceID
            states[profile.id]?.snapshot = UsageSnapshot(payload: payload, updatedAt: Date())
            states[profile.id]?.error = nil
            connected.insert(profile.id)
            defaults.set(true, forKey: "connected.\(profile.id)")
            defaults.set(payload.workspaceID, forKey: "workspace.\(profile.id)")
        } catch {
            guard generations[profile.id, default: 0] == generation else { return }
            if let websiteError = error as? WebsiteError,
               case .signInRequired = websiteError {
                states[profile.id]?.snapshot = nil
                states[profile.id]?.email = nil
                states[profile.id]?.workspaces = []
                connected.remove(profile.id)
                defaults.removeObject(forKey: "connected.\(profile.id)")
            }
            if let websiteError = error as? WebsiteError, case .accountChanged = websiteError {
                states[profile.id]?.snapshot = nil
                states[profile.id]?.email = nil
                states[profile.id]?.workspaces = []
            }
            // Preserve the original timestamp when an existing reading becomes stale.
            states[profile.id]?.error = (error as? WebsiteError)?.localizedDescription
                ?? "Cannot read website usage. Open the account website and try Refresh."
        }
    }

    func selectWorkspace(_ id: String?, for profile: AccountProfile) {
        guard !state(for: profile).isRefreshing else { return }
        states[profile.id]?.workspaceID = id
        states[profile.id]?.snapshot = nil
        defaults.set(id, forKey: "workspace.\(profile.id)")
        Task { await refresh(profile) }
    }

    func disconnect(_ profile: AccountProfile) async {
        generations[profile.id, default: 0] += 1
        connected.remove(profile.id)
        defaults.removeObject(forKey: "connected.\(profile.id)")
        defaults.removeObject(forKey: "workspace.\(profile.id)")
        states[profile.id] = AccountState(isRefreshing: true)
        do {
            try await session(for: profile).disconnect()
            states[profile.id] = AccountState()
        } catch {
            states[profile.id] = AccountState(error: error.localizedDescription)
        }
    }

    func importSession(_ header: String, for profile: AccountProfile) async throws {
        let cookies = try SessionImport.cookies(from: header, for: profile)
        generations[profile.id, default: 0] += 1
        connected.remove(profile.id)
        defaults.removeObject(forKey: "connected.\(profile.id)")
        defaults.removeObject(forKey: "workspace.\(profile.id)")
        states[profile.id] = AccountState(isRefreshing: true)
        do {
            try await session(for: profile).disconnect()
            try await session(for: profile).importSession(cookies)
            states[profile.id] = AccountState()
            await refresh(profile)
        } catch {
            states[profile.id] = AccountState(error: error.localizedDescription)
            throw error
        }
    }
}
