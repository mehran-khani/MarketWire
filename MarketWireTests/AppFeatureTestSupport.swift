import ComposableArchitecture
@testable import MarketWire

enum AppFeatureTestSupport {
    static var finishingMarketStream: @Sendable ([OkxSubscribeArg]) async -> AsyncStream<MarketEvent> {
        { _ in
            AsyncStream { continuation in
                continuation.finish()
            }
        }
    }
}
