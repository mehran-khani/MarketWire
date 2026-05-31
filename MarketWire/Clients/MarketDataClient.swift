import ComposableArchitecture
import Foundation

struct MarketDataClient: Sendable {
    var stream: @Sendable ([OkxSubscribeArg]) async -> AsyncStream<MarketEvent>
}

extension MarketDataClient: DependencyKey {
    nonisolated static let liveValue = MarketDataClient(stream: liveStream)
    nonisolated static let testValue = MarketDataClient(stream: testStream)

    private nonisolated static func liveStream(args: [OkxSubscribeArg]) -> AsyncStream<MarketEvent> {
        AsyncStream { continuation in
            let task = Task {
                let client = OKXWebSocketClient()
                defer {
                    Task { await client.disconnect() }
                }
                do {
                    try await client.connect()
                    try await client.subscribe(args: args)
                    let eventStream = await client.marketEvents()
                    for await event in eventStream {
                        if Task.isCancelled {
                            break
                        }
                        continuation.yield(event)
                    }
                    continuation.finish()
                } catch {
                    if !Task.isCancelled {
                        continuation.yield(.providerError(message: error.localizedDescription))
                    }
                    continuation.finish()
                }
            }

            continuation.onTermination = { @Sendable _ in
                task.cancel()
            }
        }
    }

    private nonisolated static func testStream(args: [OkxSubscribeArg]) -> AsyncStream<MarketEvent> {
        _ = args
        return AsyncStream { continuation in
            continuation.finish()
        }
    }
}

extension DependencyValues {
    nonisolated var marketData: MarketDataClient {
        get { self[MarketDataClient.self] }
        set { self[MarketDataClient.self] = newValue }
    }
}
