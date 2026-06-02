import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
struct AppFeature {
    @ObservableState
    struct State: Equatable {
        var selectedSection: AppSection? = .watchlist
        var columnVisibility: NavigationSplitViewVisibility = .automatic
        var preferredCompactColumn: NavigationSplitViewColumn = .content
        var detail: AssetDetailFeature.State?

        var connectionState: ConnectionState = .idle
        var lastError: String?

        var watchlist = WatchlistFeature.State()
        var markets = MarketsFeature.State()
        var alerts = AlertsFeature.State()
        var settings = SettingsFeature.State()
    }

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case appStarted
        case detailNavigationPop
        case marketEvent(MarketEvent)
        case streamFinished
        case watchlist(WatchlistFeature.Action)
        case markets(MarketsFeature.Action)
        case alerts(AlertsFeature.Action)
        case settings(SettingsFeature.Action)
        case detail(AssetDetailFeature.Action)
    }

    private nonisolated enum CancelID: Hashable, Sendable {
        case marketStream
    }

    @Dependency(\.date) var date

    var body: some Reducer<State, Action> {
        BindingReducer()

        Scope(state: \.watchlist, action: \.watchlist) {
            WatchlistFeature()
        }

        Scope(state: \.markets, action: \.markets) {
            MarketsFeature()
        }

        Scope(state: \.alerts, action: \.alerts) {
            AlertsFeature()
        }

        Scope(state: \.settings, action: \.settings) {
            SettingsFeature()
        }

        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .detailNavigationPop:
                guard state.detail != nil else { return .none }
                state.detail = nil
                state.preferredCompactColumn = .content
                return .none

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
                    if case .connecting = state.connectionState {
                        state.connectionState = .connected(since: date.now)
                    }
                    state.applyTicker(snapshot)

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

            case let .markets(.delegate(.assetSelected(symbolID))),
                 let .watchlist(.delegate(.assetSelected(symbolID))):
                state.openAssetDetail(symbolID: symbolID)
                return .none

            case .markets, .watchlist:
                return .none

            case .detail(.delegate(.closeRequested)):
                state.detail = nil
                state.preferredCompactColumn = .content
                return .none

            case .detail:
                return .none

            case .alerts, .settings:
                return .none
            }
        }
        .ifLet(\.detail, action: \.detail) {
            AssetDetailFeature()
        }
    }
}
