import ComposableArchitecture
import Foundation

extension AppFeature.State {
    var trackedSymbolIDs: [Symbol.ID] {
        var ids = Set(watchlist.favoriteSymbolIDs)
        if let detailSymbolID = detail?.symbolID {
            ids.insert(detailSymbolID)
        }
        return ids.sorted()
    }

    var marketStreamSubscribeArgs: [OkxSubscribeArg] {
        OKXConfiguration.tickerSubscribeArgs(for: trackedSymbolIDs)
    }
}

extension AppFeature {
    func refreshMarketStream(state: inout State) -> Effect<Action> {
        let targetIDs = Set(state.trackedSymbolIDs)

        if targetIDs.isEmpty {
            state.subscribedStreamSymbolIDs = []
            state.connectionState = .idle
            state.lastError = nil
            return .cancel(id: CancelID.marketStream)
        }

        let subscriptionChanged = targetIDs != state.subscribedStreamSymbolIDs
        let shouldReconnect: Bool = switch state.connectionState {
        case .idle, .disconnected, .failed:
            true
        case .connecting, .connected:
            subscriptionChanged
        }

        guard shouldReconnect else { return .none }

        return startMarketStream(state: &state)
    }

    func startMarketStream(state: inout State) -> Effect<Action> {
        let args = state.marketStreamSubscribeArgs
        state.subscribedStreamSymbolIDs = Set(args.map(\.instId))
        state.connectionState = .connecting
        state.lastError = nil

        return .run { send in
            @Dependency(\.marketData) var marketData
            let stream = await marketData.stream(args)
            for await event in stream {
                await send(.marketEvent(event))
            }
            await send(.streamFinished)
        }
        .cancellable(id: CancelID.marketStream, cancelInFlight: true)
    }
}
