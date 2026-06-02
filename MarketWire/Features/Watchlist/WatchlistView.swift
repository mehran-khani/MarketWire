import ComposableArchitecture
import SwiftUI

struct WatchlistView: View {
    let store: StoreOf<WatchlistFeature>
    let connectionState: ConnectionState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if store.favoriteSymbolIDs.isEmpty {
                    emptyState
                } else {
                    favoritesGrid
                }
            }
            .padding()
        }
    }

    private var emptyState: some View {
        SectionPlaceholderView(
            title: "No symbols yet",
            subtitle: "Add favorites from Markets in a later step."
        )
    }

    private var favoritesGrid: some View {
        VStack(spacing: 12) {
            ForEach(store.favoriteSymbolIDs, id: \.self) { symbolID in
                Button {
                    store.send(.symbolTapped(symbolID))
                } label: {
                    TickerCard(
                        symbolID: symbolID,
                        ticker: store.tickerBySymbolID[symbolID],
                        connectionState: connectionState
                    )
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("watchlist-card-\(symbolID)")
            }
        }
    }
}
