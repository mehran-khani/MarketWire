import ComposableArchitecture
import Foundation
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

    @Test func favoriteToggledAddsAndRemovesSymbol() async {
        let store = TestStore(initialState: WatchlistFeature.State()) {
            WatchlistFeature()
        }

        await store.send(.favoriteToggled("DOGE-USDT")) {
            $0.favoriteSymbolIDs.append("DOGE-USDT")
        }

        await store.send(.favoriteToggled("DOGE-USDT")) {
            $0.favoriteSymbolIDs = OKXConfiguration.defaultWatchlistSymbolIDs
            $0.tickerBySymbolID = [:]
        }
    }

    @Test func favoriteToggledRemovesCachedTicker() async {
        let snapshot = TickerSnapshot(
            symbolID: "BTC-USDT",
            price: 1,
            open24h: nil,
            high24h: nil,
            low24h: nil,
            volume24h: nil,
            bestBid: nil,
            bestAsk: nil,
            lastSize: nil,
            side: nil,
            time: Date(timeIntervalSince1970: 0)
        )
        var initialState = WatchlistFeature.State()
        initialState.tickerBySymbolID = ["BTC-USDT": snapshot]

        let store = TestStore(initialState: initialState) {
            WatchlistFeature()
        }

        await store.send(.favoriteToggled("BTC-USDT")) {
            $0.favoriteSymbolIDs.removeAll { $0 == "BTC-USDT" }
            $0.tickerBySymbolID = [:]
        }
    }
}
