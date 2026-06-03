import ComposableArchitecture
@testable import MarketWire
import SwiftUI
import Testing

@MainActor
struct AppFeatureNavigationTests {
    @Test func selectingSectionUpdatesState() async {
        let store = TestStore(initialState: AppFeature.State()) {
            AppFeature()
        }

        await store.send(\.binding.selectedSection, .markets) {
            $0.selectedSection = .markets
        }

        await store.send(\.binding.selectedSection, .settings) {
            $0.selectedSection = .settings
        }
    }

    @Test func marketsAssetSelectionOpensDetailAndPrefersDetailColumn() async {
        let store = navigationTestStore()

        await store.send(.markets(.symbolTapped("BTC-USDT")))

        await store.receive(\.markets.delegate) {
            $0.detail = AssetDetailFeature.State(symbolID: "BTC-USDT", ticker: nil)
            $0.preferredCompactColumn = .detail
        }

        await store.finish()
    }

    @Test func marketsAssetSelectionUsesCachedTicker() async throws {
        let tickerEvent = try tickerFixtureEventForTests()
        guard case let .ticker(snapshot) = tickerEvent else {
            Issue.record("expected ticker fixture")
            return
        }

        let store = navigationTestStore(
            initialState: AppFeature.State(
                watchlist: WatchlistFeature.State(
                    tickerBySymbolID: [snapshot.symbolID: snapshot]
                )
            )
        )

        await store.send(.markets(.symbolTapped(snapshot.symbolID)))

        await store.receive(\.markets.delegate) {
            $0.detail = AssetDetailFeature.State(symbolID: snapshot.symbolID, ticker: snapshot)
            $0.preferredCompactColumn = .detail
        }

        await store.finish()
    }

    @Test func assetDetailCloseClearsDetail() async {
        let store = navigationTestStore(
            initialState: AppFeature.State(
                preferredCompactColumn: .detail,
                detail: AssetDetailFeature.State(symbolID: "BTC-USDT", ticker: nil)
            )
        )

        await store.send(.detail(.closeTapped))

        await store.receive(\.detail.delegate) {
            $0.detail = nil
            $0.preferredCompactColumn = .content
        }

        await store.finish()
    }

    @Test func detailNavigationPopClearsDetail() async {
        let store = navigationTestStore(
            initialState: AppFeature.State(
                preferredCompactColumn: .detail,
                detail: AssetDetailFeature.State(symbolID: "BTC-USDT", ticker: nil)
            )
        )

        await store.send(.detailNavigationPop) {
            $0.detail = nil
            $0.preferredCompactColumn = .content
        }

        await store.finish()
    }

    @Test func detailNavigationPopIsNoOpWithoutDetail() async {
        let store = TestStore(initialState: AppFeature.State()) {
            AppFeature()
        }

        await store.send(.detailNavigationPop)
    }

    @Test func compactColumnBindingFromDetailToContentDoesNotClearWithoutPopAction() async {
        let store = TestStore(
            initialState: AppFeature.State(
                preferredCompactColumn: .detail,
                detail: AssetDetailFeature.State(symbolID: "BTC-USDT", ticker: nil)
            )
        ) {
            AppFeature()
        }

        await store.send(\.binding.preferredCompactColumn, .content) {
            $0.preferredCompactColumn = .content
        }
    }

    @Test func tickerUpdatesOpenDetail() async throws {
        let tickerEvent = try tickerFixtureEventForTests()
        guard case let .ticker(snapshot) = tickerEvent else {
            Issue.record("expected ticker fixture")
            return
        }

        let store = TestStore(
            initialState: AppFeature.State(
                detail: AssetDetailFeature.State(symbolID: snapshot.symbolID, ticker: nil),
                markets: MarketsFeature.State(
                    instruments: [Symbol(id: snapshot.symbolID, base: "BTC", quote: "USDT")],
                    loadState: .loaded
                )
            )
        ) {
            AppFeature()
        }

        await store.send(AppFeature.Action.marketEvent(tickerEvent)) {
            $0.watchlist.tickerBySymbolID = [snapshot.symbolID: snapshot]
            $0.detail = AssetDetailFeature.State(symbolID: snapshot.symbolID, ticker: snapshot)
        }
    }

    @Test func watchlistAssetSelectionOpensDetail() async {
        let store = navigationTestStore()

        await store.send(.watchlist(.symbolTapped("ETH-USDT")))

        await store.receive(\.watchlist.delegate) {
            $0.detail = AssetDetailFeature.State(symbolID: "ETH-USDT", ticker: nil)
            $0.preferredCompactColumn = .detail
        }

        await store.finish()
    }

    @Test func watchlistAssetSelectionUsesCachedTicker() async throws {
        let tickerEvent = try tickerFixtureEventForTests()
        guard case let .ticker(snapshot) = tickerEvent else {
            Issue.record("expected ticker fixture")
            return
        }

        let store = navigationTestStore(
            initialState: AppFeature.State(
                watchlist: WatchlistFeature.State(
                    tickerBySymbolID: [snapshot.symbolID: snapshot]
                )
            )
        )

        await store.send(.watchlist(.symbolTapped(snapshot.symbolID)))

        await store.receive(\.watchlist.delegate) {
            $0.detail = AssetDetailFeature.State(symbolID: snapshot.symbolID, ticker: snapshot)
            $0.preferredCompactColumn = .detail
        }

        await store.finish()
    }

    @Test func tickerDoesNotUpdateDetailForDifferentSymbol() async throws {
        let tickerEvent = try tickerFixtureEventForTests()
        guard case let .ticker(snapshot) = tickerEvent else {
            Issue.record("expected ticker fixture")
            return
        }

        let store = TestStore(
            initialState: AppFeature.State(
                detail: AssetDetailFeature.State(symbolID: "ETH-USDT", ticker: nil),
                markets: MarketsFeature.State(
                    instruments: [Symbol(id: snapshot.symbolID, base: "BTC", quote: "USDT")],
                    loadState: .loaded
                )
            )
        ) {
            AppFeature()
        }

        await store.send(AppFeature.Action.marketEvent(tickerEvent)) {
            $0.watchlist.tickerBySymbolID = [snapshot.symbolID: snapshot]
        }
    }

    @Test func columnVisibilityBindingUpdatesState() async {
        let store = TestStore(initialState: AppFeature.State()) {
            AppFeature()
        }

        await store.send(\.binding.columnVisibility, .all) {
            $0.columnVisibility = .all
        }
    }

    @Test func marketsFavoriteToggleUpdatesWatchlist() async {
        let store = navigationTestStore()

        await store.send(.markets(.favoriteToggled("DOGE-USDT")))

        await store.receive(\.markets.delegate) {
            $0.watchlist.favoriteSymbolIDs = OKXConfiguration.defaultWatchlistSymbolIDs + ["DOGE-USDT"]
        }

        await store.send(.markets(.favoriteToggled("DOGE-USDT")))

        await store.receive(\.markets.delegate) {
            $0.watchlist.favoriteSymbolIDs = OKXConfiguration.defaultWatchlistSymbolIDs
        }

        await store.finish()
    }

    @Test func watchlistFavoriteToggleUpdatesFavorites() async {
        let store = navigationTestStore()

        await store.send(.watchlist(.favoriteToggled("BTC-USDT"))) {
            $0.watchlist.favoriteSymbolIDs = ["ETH-USDT", "SOL-USDT"]
        }

        await store.finish()
    }
}

@MainActor
private func navigationTestStore(
    initialState: AppFeature.State = AppFeature.State()
) -> TestStore<AppFeature.State, AppFeature.Action> {
    let store = TestStore(initialState: initialState) {
        AppFeature()
    } withDependencies: {
        $0.marketData.stream = AppFeatureTestSupport.finishingMarketStream
    }
    store.exhaustivity = .off
    return store
}

private func tickerFixtureEventForTests() throws -> MarketEvent {
    let data = try Fixture.data("okx_ticker", provider: .okx)
    guard let event = try OkxMessageCodec.marketEvent(from: data) else {
        throw Fixture.FixtureError.notFound("okx_ticker event")
    }
    return event
}
