import AppKit
import SwiftUI

struct UsageView: View {
    @ObservedObject var store: AccountStore
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(AccountProfile.all) { profile in
                        AccountUsageView(profile: profile, state: store.state(for: profile))
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxHeight: 560)
            .fixedSize(horizontal: false, vertical: true)
            Divider()
            HStack(spacing: 6) {
                Button("Refresh", systemImage: "arrow.clockwise") { Task { await store.refreshAll() } }
                    .disabled(!store.canRefresh || store.isRefreshing)
                Button("Accounts…", systemImage: "person.crop.circle") {
                    openWindow(id: "accounts")
                    NSApp.activate(ignoringOtherApps: true)
                }
                Button("Quit", systemImage: "power") { NSApp.terminate(nil) }
            }
            .buttonStyle(MenuActionStyle())
            .padding(12)
        }
        .frame(width: 400)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

struct AccountUsageView: View {
    let profile: AccountProfile
    let state: AccountState

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(profile.name)
                        .font(.system(size: 13, weight: .semibold))
                        .lineLimit(1)
                    Spacer(minLength: 4)
                    if state.isRefreshing {
                        ProgressView().controlSize(.mini)
                    } else if let snapshot = state.snapshot {
                        Text("\(snapshot.updatedAt.formatted(date: .omitted, time: .shortened))\(state.error == nil ? "" : " · stale")")
                            .font(.system(size: 10).monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                }
                Text(state.email ?? "Not connected")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .textSelection(.enabled)
            }
            if let snapshot = state.snapshot {
                ForEach(snapshot.payload.windows) { window in
                    UsageWindowView(window: window)
                }
                if snapshot.payload.windows.isEmpty, let note = snapshot.payload.note {
                    Text(note)
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            } else if state.error == nil && !state.isRefreshing {
                Text("Open Accounts to sign in.")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            if let error = state.error {
                Text(error)
                    .font(.system(size: 10))
                    .foregroundStyle(Color.orange)
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .modifier(HoverSurface(cornerRadius: 10, restingOpacity: 0.03))
    }
}

private struct UsageWindowView: View {
    let window: UsageWindow

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 6) {
                Text(window.name)
                    .font(.system(size: 12))
                    .lineLimit(1)
                    .truncationMode(.tail)
                Spacer(minLength: 4)
                valueText
                resetText
            }
            if let used = window.usedPercent {
                UsageBar(percent: used)
            }
        }
    }

    @ViewBuilder private var valueText: some View {
        if let used = window.usedPercent {
            Text("\(used.formatted(.number.precision(.fractionLength(0))))%")
                .font(.system(size: 12).monospacedDigit())
                .foregroundStyle(used >= 80 ? UsagePalette.color(for: used) : Color.primary)
        } else if let remaining = window.remaining {
            Text("\(remaining) left")
                .font(.system(size: 12).monospacedDigit())
        } else {
            Text(window.status ?? "Usage unavailable")
                .font(.system(size: 10))
                .foregroundStyle(Color.secondary)
                .lineLimit(1)
        }
    }

    @ViewBuilder private var resetText: some View {
        if let reset = window.resetDate {
            TimelineView(.periodic(from: .now, by: 60)) { context in
                Text(Self.shortReset(reset, now: context.date))
                    .font(.system(size: 10).monospacedDigit())
                    .foregroundStyle(Color.secondary)
            }
            .help("Reset: \(reset.formatted(date: .complete, time: .shortened))")
        } else if let status = window.status, window.usedPercent != nil || window.remaining != nil {
            Text(status)
                .font(.system(size: 10))
                .foregroundStyle(Color.orange)
                .lineLimit(1)
        }
    }

    static func shortReset(_ date: Date, now: Date) -> String {
        let seconds = date.timeIntervalSince(now)
        guard seconds > 0 else { return "due" }
        let minutes = max(1, Int(ceil(seconds / 60)))
        let days = minutes / 1440
        let hours = (minutes % 1440) / 60
        let remainder = minutes % 60
        if days > 0 { return "\(days)d \(hours)h" }
        if hours > 0 { return "\(hours)h \(remainder)m" }
        return "\(minutes)m"
    }
}

private struct UsageBar: View {
    let percent: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.primary.opacity(0.12))
                Capsule()
                    .fill(UsagePalette.color(for: percent))
                    .frame(width: geometry.size.width * min(max(percent, 0), 100) / 100)
            }
        }
        .frame(height: 3)
    }
}

enum UsagePalette {
    // The color is the same for every provider.
    // Below 80 percent the color is the accent color.
    // From 80 percent the color is orange. From 90 percent the color is red.
    static func color(for percent: Double) -> Color {
        if percent >= 90 { return .red }
        if percent >= 80 { return .orange }
        return .accentColor
    }
}
