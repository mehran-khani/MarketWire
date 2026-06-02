import ComposableArchitecture
import Foundation

@Reducer
struct WatchlistFeature {
    @ObservableState
    struct State: Equatable {
        var favoriteSymbolIDs: [Symbol.ID] = OKXConfiguration.defaultWatchlistSymbolIDs
        var tickerBySymbolID: [Symbol.ID: TickerSnapshot] = [:]
    }

    enum Action: Equatable {
        case symbolTapped(Symbol.ID)
        case delegate(Delegate)

        enum Delegate: Equatable {
            case assetSelected(symbolID: Symbol.ID)
        }
    }

    var body: some Reducer<State, Action> {
        Reduce { _, action in
            switch action {
            case let .symbolTapped(symbolID):
                return .send(.delegate(.assetSelected(symbolID: symbolID)))

            case .delegate:
                return .none
            }
        }
    }
}
