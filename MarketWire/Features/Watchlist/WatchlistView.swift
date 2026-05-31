import ComposableArchitecture
import SwiftUI

struct WatchlistView: View {
    let store: StoreOf<WatchlistFeature>

    var body: some View {
        SectionPlaceholderView(
            title: "Watchlist",
            subtitle: "Favorite symbols and live tickers arrive in a later phase."
        )
    }
}
