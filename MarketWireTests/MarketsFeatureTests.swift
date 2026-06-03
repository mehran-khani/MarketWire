import ComposableArchitecture
import Foundation
@testable import MarketWire
import Testing

@MainActor
struct MarketsFeatureTests {
    private let sampleInstruments: [Symbol] = [
        Symbol(id: "BTC-USDT", base: "BTC", quote: "USDT"),
        Symbol(id: "ETH-USDT", base: "ETH", quote: "USDT"),
        Symbol(id: "SOL-USDT", base: "SOL", quote: "USDT"),
    ]

    @Test func catalogAppearedLoadsInstruments() async {
        let store = TestStore(initialState: MarketsFeature.State()) {
            MarketsFeature()
        } withDependencies: {
            $0.marketREST.fetchSpotInstruments = { self.sampleInstruments }
        }

        await store.send(.catalogAppeared) {
            $0.loadState = .loading
        }

        await store.receive(\.instrumentsLoaded) {
            $0.loadState = .loaded
            $0.instruments = sampleInstruments
            $0.filteredInstruments = sampleInstruments
            $0.instrumentSearchIndex = MarketsCatalogSearch.buildIndex(for: sampleInstruments)
        }
    }

    @Test func catalogAppearedDoesNotReloadWhileLoaded() async {
        var initialState = MarketsFeature.State(loadState: .loaded)
        initialState.applyInstruments(sampleInstruments)

        let store = TestStore(initialState: initialState) {
            MarketsFeature()
        } withDependencies: {
            $0.marketREST.fetchSpotInstruments = {
                Issue.record("catalog should not refetch while loaded")
                return []
            }
        }

        await store.send(.catalogAppeared)
    }

    @Test func catalogAppearedRetriesAfterFailure() async {
        let attempts = CatalogAttemptBox()
        let store = TestStore(
            initialState: MarketsFeature.State(
                loadState: MarketsFeature.CatalogLoadState.failed("offline")
            )
        ) {
            MarketsFeature()
        } withDependencies: {
            $0.marketREST.fetchSpotInstruments = {
                attempts.count += 1
                if attempts.count == 1 {
                    throw CatalogTestError.offline
                }
                return self.sampleInstruments
            }
        }

        await store.send(.catalogAppeared) {
            $0.loadState = .loading
        }

        await store.receive(\.instrumentsFailed) {
            $0.loadState = MarketsFeature.CatalogLoadState.failed("offline")
        }

        await store.send(.catalogAppeared) {
            $0.loadState = .loading
        }

        await store.receive(\.instrumentsLoaded) {
            $0.loadState = .loaded
            $0.instruments = sampleInstruments
            $0.filteredInstruments = sampleInstruments
            $0.instrumentSearchIndex = MarketsCatalogSearch.buildIndex(for: sampleInstruments)
        }
    }

    @Test func instrumentsFailedSetsFailedState() async {
        let store = TestStore(initialState: MarketsFeature.State()) {
            MarketsFeature()
        } withDependencies: {
            $0.marketREST.fetchSpotInstruments = {
                throw CatalogTestError.offline
            }
        }

        await store.send(.catalogAppeared) {
            $0.loadState = .loading
        }

        await store.receive(\.instrumentsFailed) {
            $0.loadState = MarketsFeature.CatalogLoadState.failed("offline")
        }
    }

    @Test func searchFilterCommittedFiltersInstruments() async {
        var initialState = MarketsFeature.State(loadState: .loaded)
        initialState.applyInstruments(sampleInstruments)

        let store = TestStore(initialState: initialState) {
            MarketsFeature()
        }

        await store.send(.searchFilterCommitted("eth")) {
            $0.filterQuery = "eth"
            $0.filteredInstruments = [Symbol(id: "ETH-USDT", base: "ETH", quote: "USDT")]
        }
    }

    @Test func searchFilterMatchesSlashAndWhitespaceFormats() async {
        var initialState = MarketsFeature.State(loadState: .loaded)
        initialState.applyInstruments(sampleInstruments)

        let store = TestStore(initialState: initialState) {
            MarketsFeature()
        }

        await store.send(.searchFilterCommitted("btc/usd")) {
            $0.filterQuery = "btc/usd"
            $0.filteredInstruments = [Symbol(id: "BTC-USDT", base: "BTC", quote: "USDT")]
        }

        await store.send(.searchFilterCommitted("btc usd")) {
            $0.filterQuery = "btc usd"
            $0.filteredInstruments = [Symbol(id: "BTC-USDT", base: "BTC", quote: "USDT")]
        }

        await store.send(.searchFilterCommitted("btc / usd")) {
            $0.filterQuery = "btc / usd"
            $0.filteredInstruments = [Symbol(id: "BTC-USDT", base: "BTC", quote: "USDT")]
        }

        await store.send(.searchFilterCommitted("btcusd")) {
            $0.filterQuery = "btcusd"
            $0.filteredInstruments = [Symbol(id: "BTC-USDT", base: "BTC", quote: "USDT")]
        }
    }

    @Test func clearingSearchFilterRestoresFullCatalog() async {
        var initialState = MarketsFeature.State(loadState: .loaded)
        initialState.applyInstruments(sampleInstruments)
        initialState.applyFilterQuery("eth")

        let store = TestStore(initialState: initialState) {
            MarketsFeature()
        }

        await store.send(.searchFilterCommitted("")) {
            $0.filterQuery = ""
            $0.filteredInstruments = sampleInstruments
        }
    }

    @Test func symbolTappedEmitsDelegate() async {
        let store = TestStore(initialState: MarketsFeature.State()) {
            MarketsFeature()
        }

        await store.send(.symbolTapped("BTC-USDT"))
        await store.receive(.delegate(.assetSelected(symbolID: "BTC-USDT")))
    }

    @Test func favoriteToggledEmitsDelegate() async {
        let store = TestStore(initialState: MarketsFeature.State()) {
            MarketsFeature()
        }

        await store.send(.favoriteToggled("DOGE-USDT"))
        await store.receive(.delegate(.toggleFavorite(symbolID: "DOGE-USDT")))
    }

    @Test func quoteRefreshTickLoadsMarketTickers() async {
        let tickers = sampleMarketTickersForTests()
        var initialState = MarketsFeature.State(loadState: .loaded, isQuotePollingActive: true)
        initialState.applyInstruments(sampleInstruments)

        let store = TestStore(initialState: initialState) {
            MarketsFeature()
        } withDependencies: {
            $0.marketREST.fetchSpotMarketTickers = { tickers }
        }

        await store.send(.quoteRefreshTick) {
            $0.quoteRefreshState = .loading
        }

        await store.receive(\.marketTickersLoaded) {
            $0.marketTickerBySymbolID = tickers
            $0.quoteRefreshState = .loaded
        }
    }

    @Test func quotePollingStartsAndStopsRefreshLoop() async {
        let clock = TestClock()
        var initialState = MarketsFeature.State(loadState: .loaded)
        initialState.applyInstruments(sampleInstruments)

        let store = TestStore(initialState: initialState) {
            MarketsFeature()
        } withDependencies: {
            $0.continuousClock = clock
            $0.marketREST.fetchSpotMarketTickers = { sampleMarketTickersForTests() }
        }
        store.exhaustivity = .off

        await store.send(.setQuotePollingActive(true))
        await store.receive(\.quoteRefreshTick)
        await store.receive(\.marketTickersLoaded)

        await clock.advance(by: .seconds(3))
        await store.receive(\.quoteRefreshTick)
        await store.receive(\.marketTickersLoaded)

        await store.send(.setQuotePollingActive(false)) {
            $0.isQuotePollingActive = false
            $0.quoteRefreshState = .idle
        }
    }

}

private func sampleMarketTickersForTests() -> [Symbol.ID: MarketTicker] {
    let now = Date(timeIntervalSince1970: 1_000)
    return [
        "BTC-USDT": MarketTicker(
            symbolID: "BTC-USDT",
            lastPrice: 70_000,
            open24h: 69_000,
            high24h: 71_000,
            low24h: 68_000,
            updatedAt: now
        ),
        "ETH-USDT": MarketTicker(
            symbolID: "ETH-USDT",
            lastPrice: 3_500,
            open24h: 3_400,
            high24h: 3_600,
            low24h: 3_300,
            updatedAt: now
        ),
        "SOL-USDT": MarketTicker(
            symbolID: "SOL-USDT",
            lastPrice: 150,
            open24h: 145,
            high24h: 155,
            low24h: 140,
            updatedAt: now
        ),
    ]
}

private enum CatalogTestError: LocalizedError {
    case offline

    var errorDescription: String? { "offline" }
}

private final class CatalogAttemptBox: @unchecked Sendable {
    var count = 0
}
