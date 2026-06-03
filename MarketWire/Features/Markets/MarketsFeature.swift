import ComposableArchitecture
import Foundation

@Reducer
struct MarketsFeature {
    enum CatalogLoadState: Equatable, Sendable {
        case idle
        case loading
        case loaded
        case failed(String)
    }

    enum QuoteRefreshState: Equatable, Sendable {
        case idle
        case loading
        case loaded
        case failed(String)
    }

    @ObservableState
    struct State: Equatable {
        var instruments: [Symbol] = []
        var filteredInstruments: [Symbol] = []
        var instrumentSearchIndex: [Symbol.ID: SymbolSearchIndexEntry] = [:]
        var marketTickerBySymbolID: [Symbol.ID: MarketTicker] = [:]
        var loadState: CatalogLoadState = .idle
        var quoteRefreshState: QuoteRefreshState = .idle
        var filterQuery: String = ""
        var isQuotePollingActive = false
        var quotesUpdatedAt: Date?

        var isSearchActive: Bool {
            !filterQuery.isEmpty
        }
    }

    enum Action: Equatable {
        case catalogAppeared
        case instrumentsLoaded([Symbol])
        case instrumentsFailed(String)
        case setQuotePollingActive(Bool)
        case quoteRefreshTick
        case marketTickersLoaded([Symbol.ID: MarketTicker])
        case marketTickersFailed(String)
        case symbolTapped(Symbol.ID)
        case favoriteToggled(Symbol.ID)
        case searchFilterCommitted(String)
        case delegate(Delegate)

        enum Delegate: Equatable {
            case assetSelected(symbolID: Symbol.ID)
            case toggleFavorite(symbolID: Symbol.ID)
        }
    }

    @Dependency(\.marketREST) var marketREST
    @Dependency(\.continuousClock) var clock
    @Dependency(\.date) var date

    private nonisolated enum QuotePollID: Hashable, Sendable {
        case poll
        case fetch
    }

    private nonisolated static let quotePollInterval: Duration = .seconds(3)

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .catalogAppeared:
                switch state.loadState {
                case .loading, .loaded:
                    return .none
                case .idle, .failed:
                    break
                }

                state.loadState = .loading
                return .run { [marketREST] send in
                    do {
                        let instruments = try await marketREST.fetchSpotInstruments()
                        await send(.instrumentsLoaded(instruments))
                    } catch {
                        await send(.instrumentsFailed(error.localizedDescription))
                    }
                }

            case let .instrumentsLoaded(instruments):
                state.loadState = .loaded
                state.applyInstruments(instruments)
                return state.isQuotePollingActive ? startQuoteRefresh() : .none

            case let .instrumentsFailed(message):
                state.loadState = .failed(message)
                return .none

            case let .setQuotePollingActive(isActive):
                guard isActive != state.isQuotePollingActive else { return .none }
                state.isQuotePollingActive = isActive

                guard isActive else {
                    state.quoteRefreshState = .idle
                    state.quotesUpdatedAt = nil
                    return .merge(
                        .cancel(id: QuotePollID.poll),
                        .cancel(id: QuotePollID.fetch)
                    )
                }

                guard state.loadState == .loaded else { return .none }
                return startQuoteRefresh()

            case .quoteRefreshTick:
                guard state.isQuotePollingActive, state.loadState == .loaded else { return .none }
                if state.marketTickerBySymbolID.isEmpty {
                    state.quoteRefreshState = .loading
                }
                return fetchMarketTickers()

            case let .marketTickersLoaded(tickers):
                state.marketTickerBySymbolID = tickers
                state.quoteRefreshState = .loaded
                state.quotesUpdatedAt = date.now
                return .none

            case let .marketTickersFailed(message):
                if state.marketTickerBySymbolID.isEmpty {
                    state.quoteRefreshState = .failed(message)
                }
                return .none

            case let .searchFilterCommitted(query):
                state.applyFilterQuery(query)
                return .none

            case let .symbolTapped(symbolID):
                return .send(.delegate(.assetSelected(symbolID: symbolID)))

            case let .favoriteToggled(symbolID):
                return .send(.delegate(.toggleFavorite(symbolID: symbolID)))

            case .delegate:
                return .none
            }
        }
    }

    private func startQuoteRefresh() -> Effect<Action> {
        .run { [clock] send in
            await send(.quoteRefreshTick)
            for await _ in clock.timer(interval: Self.quotePollInterval) {
                await send(.quoteRefreshTick)
            }
        }
        .cancellable(id: QuotePollID.poll, cancelInFlight: true)
    }

    private func fetchMarketTickers() -> Effect<Action> {
        .run { [marketREST] send in
            do {
                let tickers = try await marketREST.fetchSpotMarketTickers()
                await send(.marketTickersLoaded(tickers))
            } catch {
                await send(.marketTickersFailed(error.localizedDescription))
            }
        }
        .cancellable(id: QuotePollID.fetch, cancelInFlight: true)
    }
}
