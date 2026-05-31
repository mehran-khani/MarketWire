import ComposableArchitecture
import SwiftUI

struct AppView: View {
    @Bindable var store: StoreOf<AppFeature>

    private var activeSection: AppSection {
        store.selectedSection ?? .markets
    }

    var body: some View {
        NavigationSplitView(
            columnVisibility: $store.columnVisibility,
            preferredCompactColumn: $store.preferredCompactColumn
        ) {
            sidebar
        } content: {
            contentColumn
                .navigationTitle(activeSection.title)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        ConnectionStatusControl(
                            connectionState: store.connectionState,
                            lastError: store.lastError,
                            onReconnect: { store.send(.appStarted) }
                        )
                    }
                }
        } detail: {
            detailColumn
        }
        .task {
            store.send(.appStarted)
        }
        .onChange(of: store.preferredCompactColumn) { oldColumn, newColumn in
            // System back on compact updates the binding only — clear TCA detail when leaving the detail column.
            guard oldColumn == .detail, newColumn == .content, store.detail != nil else { return }
            store.send(.detailNavigationPop)
        }
    }

    private var sidebar: some View {
        List(selection: $store.selectedSection) {
            ForEach(AppSection.allCases) { section in
                NavigationLink(value: section) {
                    Label(section.title, systemImage: section.systemImage)
                }
            }
        }
        .navigationTitle("MarketWire")
    }

    @ViewBuilder
    private var contentColumn: some View {
        switch activeSection {
        case .watchlist:
            WatchlistView(
                store: store.scope(state: \.watchlist, action: \.watchlist)
            )
        case .markets:
            MarketsView(
                store: store.scope(state: \.markets, action: \.markets),
                connectionState: store.connectionState
            )
        case .alerts:
            AlertsView(
                store: store.scope(state: \.alerts, action: \.alerts)
            )
        case .settings:
            SettingsView(
                store: store.scope(state: \.settings, action: \.settings)
            )
        }
    }

    @ViewBuilder
    private var detailColumn: some View {
        if let detailStore = store.scope(state: \.detail, action: \.detail) {
            AssetDetailView(store: detailStore)
        } else {
            SectionPlaceholderView(
                title: "Detail",
                subtitle: "Select a symbol from Markets to open asset detail."
            )
        }
    }
}

private struct ConnectionStatusControl: View {
    let connectionState: ConnectionState
    let lastError: String?
    let onReconnect: () -> Void

    private var canReconnect: Bool {
        switch connectionState {
        case .disconnected, .failed:
            true
        default:
            false
        }
    }

    var body: some View {
        Group {
            if canReconnect {
                Button(action: onReconnect) {
                    statusLabel
                }
                .buttonStyle(.plain)
                .accessibilityHint("Double tap to reconnect")
            } else {
                statusLabel
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("connection-status")
        .accessibilityLabel(accessibilityLabelText)
        .help(lastError ?? "")
    }

    private var statusLabel: some View {
        Label(connectionLabel, systemImage: connectionSymbol)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(connectionColor)
    }

    private var accessibilityLabelText: String {
        if let lastError, !lastError.isEmpty {
            return "\(connectionLabel). \(lastError)"
        }
        return connectionLabel
    }

    private var connectionLabel: String {
        switch connectionState {
        case .idle:
            "Idle"
        case .connecting:
            "Connecting…"
        case .connected:
            "Live"
        case let .disconnected(reason):
            reason.map { "Disconnected: \($0). Tap to reconnect." } ?? "Disconnected. Tap to reconnect."
        case let .failed(message):
            "Failed: \(message). Tap to reconnect."
        }
    }

    private var connectionSymbol: String {
        switch connectionState {
        case .connected:
            "wifi"
        case .connecting:
            "arrow.triangle.2.circlepath"
        case .failed:
            "exclamationmark.triangle"
        case .disconnected:
            "wifi.slash"
        case .idle:
            "circle"
        }
    }

    private var connectionColor: Color {
        switch connectionState {
        case .connected:
            .green
        case .connecting:
            .orange
        case .failed:
            .red
        case .disconnected, .idle:
            .secondary
        }
    }
}

#Preview {
    AppView(
        store: Store(initialState: AppFeature.State()) {
            AppFeature()
        }
    )
}
