import ComposableArchitecture
import Foundation

@Reducer
struct AssetDetailFeature {
    @ObservableState
    struct State: Equatable {
        var symbolID: Symbol.ID
        var ticker: TickerSnapshot?
    }

    enum Action: Equatable {
        case closeTapped
        case delegate(Delegate)

        enum Delegate: Equatable {
            case closeRequested
        }
    }

    var body: some Reducer<State, Action> {
        Reduce { _, action in
            switch action {
            case .closeTapped:
                return .send(.delegate(.closeRequested))

            case .delegate:
                return .none
            }
        }
    }
}
