import ComposableArchitecture
import Foundation

struct MarketRESTClient: Sendable {
    var fetchSpotInstruments: @Sendable () async throws -> [Symbol]
    var fetchSpotMarketTickers: @Sendable () async throws -> [Symbol.ID: MarketTicker]
}

extension MarketRESTClient: DependencyKey {
    nonisolated static let liveValue = MarketRESTClient(
        fetchSpotInstruments: {
            try await OKXRESTClient().fetchSpotInstruments()
        },
        fetchSpotMarketTickers: {
            try await OKXRESTClient().fetchSpotMarketTickers()
        }
    )

    nonisolated static let testValue = MarketRESTClient(
        fetchSpotInstruments: { [] },
        fetchSpotMarketTickers: { [:] }
    )
}

extension DependencyValues {
    nonisolated var marketREST: MarketRESTClient {
        get { self[MarketRESTClient.self] }
        set { self[MarketRESTClient.self] = newValue }
    }
}
