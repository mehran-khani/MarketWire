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

    @ObservableState
    struct State: Equatable {
        var instruments: [Symbol] = []
        var loadState: CatalogLoadState = .idle
        var searchQuery: String = ""
        var tickerBySymbolID: [Symbol.ID: TickerSnapshot] = [:]

        var filteredInstruments: [Symbol] {
            guard !searchQuery.isEmpty else { return instruments }

            let query = searchQuery.lowercased()
            return instruments.filter { symbol in
                symbol.id.lowercased().contains(query)
                    || symbol.base.lowercased().contains(query)
                    || symbol.quote.lowercased().contains(query)
            }
        }

        var instrumentIDs: Set<Symbol.ID> {
            Set(instruments.map(\.id))
        }
    }

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case catalogAppeared
        case instrumentsLoaded([Symbol])
        case instrumentsFailed(String)
        case symbolTapped(Symbol.ID)
        case delegate(Delegate)

        enum Delegate: Equatable {
            case assetSelected(symbolID: Symbol.ID)
        }
    }

    @Dependency(\.marketREST) var marketREST

    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding:
                return .none

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
                state.instruments = instruments
                state.loadState = .loaded
                return .none

            case let .instrumentsFailed(message):
                state.loadState = .failed(message)
                return .none

            case let .symbolTapped(symbolID):
                return .send(.delegate(.assetSelected(symbolID: symbolID)))

            case .delegate:
                return .none
            }
        }
    }
}
