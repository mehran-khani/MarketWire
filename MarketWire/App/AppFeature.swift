import ComposableArchitecture
import Foundation

@Reducer
struct AppFeature {
    @ObservableState
    struct State: Equatable {
        static let debugSymbolID = "BTC-USDT"

        var connectionState: ConnectionState = .idle
        var debugTicker: TickerSnapshot?
        var lastError: String?
    }

    enum Action: Equatable {
        case appStarted
        case marketEvent(MarketEvent)
        case streamFinished
        case streamFailed(String)
    }

    private nonisolated enum CancelID: Hashable, Sendable {
        case marketStream
    }

    @Dependency(\.date) var date

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .appStarted:
                switch state.connectionState {
                case .connecting, .connected:
                    return .none
                default:
                    break
                }

                state.connectionState = .connecting
                state.lastError = nil

                return .run { send in
                    @Dependency(\.marketData) var marketData
                    let stream = await marketData.stream(OKXConfiguration.defaultSubscribeArgs)
                    for await event in stream {
                        await send(.marketEvent(event))
                    }
                    await send(.streamFinished)
                }
                .cancellable(id: CancelID.marketStream, cancelInFlight: true)

            case let .marketEvent(event):
                switch event {
                case .subscribed:
                    state.connectionState = .connected(since: date.now)
                    state.lastError = nil

                case let .ticker(snapshot):
                    if snapshot.symbolID == State.debugSymbolID {
                        state.debugTicker = snapshot
                    }
                    if case .connecting = state.connectionState {
                        state.connectionState = .connected(since: date.now)
                    }

                case let .providerError(message):
                    state.connectionState = .failed(message: message)
                    state.lastError = message

                case .trade, .heartbeat, .orderBook:
                    break
                }

                return .none

            case .streamFinished:
                switch state.connectionState {
                case .connected:
                    state.connectionState = .disconnected(reason: nil)
                case .connecting:
                    state.connectionState = .disconnected(reason: "Stream ended")
                default:
                    break
                }
                return .none

            case let .streamFailed(message):
                state.connectionState = .failed(message: message)
                state.lastError = message
                return .none
            }
        }
    }
}
