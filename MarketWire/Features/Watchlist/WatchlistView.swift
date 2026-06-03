import ComposableArchitecture
import SwiftUI

struct WatchlistView: View {
    let store: StoreOf<WatchlistFeature>
    let connectionState: ConnectionState

    var body: some View {
        Group {
            if store.favoriteSymbolIDs.isEmpty {
                emptyState
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
            } else {
                favoritesList
            }
        }
    }

    private var emptyState: some View {
        SectionPlaceholderView(
            title: "No symbols yet",
            subtitle: "Open Markets, then swipe or long-press a pair to add it here."
        )
    }

    private var favoritesList: some View {
        List {
            ForEach(store.favoriteSymbolIDs, id: \.self) { symbolID in
                TickerCard(
                    symbolID: symbolID,
                    ticker: store.tickerBySymbolID[symbolID],
                    connectionState: connectionState
                )
                .tickerCardFavoriteListRow(
                    isFavorite: true,
                    accessibilityIdentifier: "watchlist-card-\(symbolID)",
                    onSelect: { store.send(.symbolTapped(symbolID)) },
                    onFavoriteToggle: { store.send(.favoriteToggled(symbolID)) }
                )
            }
        }
        .listStyle(.plain)
        .marketContentScrollEdgeEffects()
        .accessibilityIdentifier("watchlist-favorites-list")
    }
}
