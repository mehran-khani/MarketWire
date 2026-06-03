import ComposableArchitecture
import SwiftUI

struct AppView: View {
    @Bindable var store: StoreOf<AppFeature>
    @Environment(\.scenePhase) private var scenePhase

    private var activeSection: AppSection {
        store.selectedSection ?? .watchlist
    }

    private var isMarketsQuotePollingActive: Bool {
        activeSection == .markets && scenePhase == .active
    }

    private var favoriteSymbolIDs: Set<Symbol.ID> {
        Set(store.watchlist.favoriteSymbolIDs)
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
                store: store.scope(state: \.watchlist, action: \.watchlist),
                connectionState: store.connectionState
            )
        case .markets:
            MarketsView(
                store: store.scope(state: \.markets, action: \.markets),
                favoriteSymbolIDs: favoriteSymbolIDs,
                isQuotePollingActive: isMarketsQuotePollingActive
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

#Preview {
    AppView(
        store: Store(initialState: AppFeature.State()) {
            AppFeature()
        }
    )
}
