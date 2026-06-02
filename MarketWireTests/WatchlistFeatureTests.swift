import ComposableArchitecture
@testable import MarketWire
import Testing

@MainActor
struct WatchlistFeatureTests {
    @Test func defaultFavoritesMatchOKXConfiguration() {
        #expect(WatchlistFeature.State().favoriteSymbolIDs == OKXConfiguration.defaultWatchlistSymbolIDs)
    }

    @Test func symbolTappedEmitsDelegate() async {
        let store = TestStore(initialState: WatchlistFeature.State()) {
            WatchlistFeature()
        }

        await store.send(.symbolTapped("ETH-USDT"))
        await store.receive(.delegate(.assetSelected(symbolID: "ETH-USDT")))
    }
}
