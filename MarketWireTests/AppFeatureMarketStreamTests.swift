import ComposableArchitecture
import Foundation
@testable import MarketWire
import Testing

@MainActor
struct AppFeatureMarketStreamTests {
    @Test func trackedSymbolIDsIncludeFavoritesAndOpenDetail() {
        var state = AppFeature.State()
        state.watchlist.favoriteSymbolIDs = ["ETH-USDT", "BTC-USDT"]
        state.detail = AssetDetailFeature.State(symbolID: "DOGE-USDT", ticker: nil)

        #expect(state.trackedSymbolIDs == ["BTC-USDT", "DOGE-USDT", "ETH-USDT"])
    }

    @Test func marketStreamSubscribeArgsUseTickersChannel() {
        var state = AppFeature.State()
        state.watchlist.favoriteSymbolIDs = ["SOL-USDT"]

        #expect(
            state.marketStreamSubscribeArgs == [
                OkxSubscribeArg(channel: "tickers", instId: "SOL-USDT"),
            ]
        )
    }

    @Test func favoriteToggleRestartsStreamWithNewSymbol() async {
        let subscribeBox = SubscribeArgsBox()

        let store = TestStore(initialState: AppFeature.State()) {
            AppFeature()
        } withDependencies: {
            $0.marketData.stream = { args in
                subscribeBox.record(args)
                return AsyncStream { $0.finish() }
            }
        }
        store.exhaustivity = .off

        await store.send(.appStarted)
        await store.finish()

        subscribeBox.reset()

        await store.send(.markets(.favoriteToggled("DOGE-USDT")))
        await store.receive(\.markets.delegate)
        await store.finish()

        let subscribedIDs = Set(subscribeBox.lastArgs.map(\.instId))
        #expect(subscribedIDs.contains("DOGE-USDT"))
        #expect(subscribedIDs.contains("BTC-USDT"))
    }

    @Test func openingDetailAddsSymbolToStreamTargets() async {
        let subscribeBox = SubscribeArgsBox()

        var initialState = AppFeature.State()
        initialState.watchlist.favoriteSymbolIDs = ["BTC-USDT"]

        let store = TestStore(initialState: initialState) {
            AppFeature()
        } withDependencies: {
            $0.marketData.stream = { args in
                subscribeBox.record(args)
                return AsyncStream { $0.finish() }
            }
        }
        store.exhaustivity = .off

        await store.send(.appStarted)
        await store.finish()
        subscribeBox.reset()

        await store.send(.markets(.symbolTapped("DOGE-USDT")))
        await store.receive(\.markets.delegate)
        await store.finish()

        #expect(Set(subscribeBox.lastArgs.map(\.instId)).contains("DOGE-USDT"))
    }

    @Test func openAssetDetailSeedsTickerFromMarketREST() {
        let now = Date(timeIntervalSince1970: 2_000)
        var state = AppFeature.State()
        state.markets.marketTickerBySymbolID = [
            "DOGE-USDT": MarketTicker(
                symbolID: "DOGE-USDT",
                lastPrice: 0.12,
                open24h: 0.11,
                high24h: 0.13,
                low24h: 0.10,
                updatedAt: now
            ),
        ]

        state.openAssetDetail(symbolID: "DOGE-USDT")

        #expect(state.detail?.ticker?.price == 0.12)
        #expect(state.detail?.ticker?.symbolID == "DOGE-USDT")
    }
}

private final class SubscribeArgsBox: @unchecked Sendable {
    private(set) var lastArgs: [OkxSubscribeArg] = []

    func record(_ args: [OkxSubscribeArg]) {
        lastArgs = args
    }

    func reset() {
        lastArgs = []
    }
}
