import ComposableArchitecture
import Foundation
@testable import MarketWire
import Testing

@MainActor
struct AppFeatureStreamTests {
    private let testDate = Date(timeIntervalSince1970: 1_000)

    @Test func appStartedStartsConnectingAndMapsStreamEvents() async throws {
        let subscribeEvent = try subscribedFixtureEvent()
        let tickerEvent = try tickerFixtureEvent()

        let store = TestStore(initialState: AppFeature.State()) {
            AppFeature()
        } withDependencies: {
            $0.marketData.stream = { _ in fixtureStream() }
            $0.date.now = testDate
        }

        await store.send(AppFeature.Action.appStarted) {
            $0.connectionState = .connecting
            $0.subscribedStreamSymbolIDs = Set(OKXConfiguration.defaultWatchlistSymbolIDs)
        }

        await store.receive(AppFeature.Action.marketEvent(subscribeEvent)) {
            $0.connectionState = .connected(since: testDate)
        }

        await store.receive(AppFeature.Action.marketEvent(tickerEvent)) {
            $0.connectionState = .connected(since: testDate)
            if case let .ticker(snapshot) = tickerEvent {
                $0.watchlist.tickerBySymbolID = [snapshot.symbolID: snapshot]
            }
        }

        await store.receive(AppFeature.Action.streamFinished) {
            $0.connectionState = .disconnected(reason: nil)
        }
    }

    @Test func appStartedIsIdempotentWhileConnecting() async {
        let store = TestStore(
            initialState: AppFeature.State(connectionState: .connecting)
        ) {
            AppFeature()
        }

        await store.send(AppFeature.Action.appStarted)
    }

    @Test func appStartedIsIdempotentWhileConnected() async {
        let store = TestStore(
            initialState: AppFeature.State(connectionState: .connected(since: testDate))
        ) {
            AppFeature()
        }

        await store.send(AppFeature.Action.appStarted)
    }

    @Test func appStartedRestartsStreamFromDisconnected() async {
        let store = TestStore(
            initialState: AppFeature.State(connectionState: .disconnected(reason: "Stream ended"))
        ) {
            AppFeature()
        } withDependencies: {
            $0.marketData.stream = { _ in AsyncStream { $0.finish() } }
        }

        await store.send(AppFeature.Action.appStarted) {
            $0.connectionState = .connecting
            $0.lastError = nil
            $0.subscribedStreamSymbolIDs = Set(OKXConfiguration.defaultWatchlistSymbolIDs)
        }

        await store.receive(AppFeature.Action.streamFinished) {
            $0.connectionState = .disconnected(reason: "Stream ended")
        }
    }

    @Test func streamFinishedWhileConnectingMarksDisconnected() async {
        let store = TestStore(initialState: AppFeature.State(connectionState: .connecting)) {
            AppFeature()
        }

        await store.send(AppFeature.Action.streamFinished) {
            $0.connectionState = .disconnected(reason: "Stream ended")
        }
    }

    @Test func providerErrorMarksConnectionFailed() async {
        let store = TestStore(initialState: AppFeature.State(connectionState: .connecting)) {
            AppFeature()
        } withDependencies: {
            $0.date.now = testDate
        }

        await store.send(AppFeature.Action.marketEvent(.providerError(message: "rate limit"))) {
            $0.connectionState = .failed(message: "rate limit")
            $0.lastError = "rate limit"
        }
    }

    @Test func providerErrorWhileConnectedMarksFailed() async {
        let store = TestStore(
            initialState: AppFeature.State(connectionState: .connected(since: testDate))
        ) {
            AppFeature()
        }

        await store.send(AppFeature.Action.marketEvent(.providerError(message: "socket closed"))) {
            $0.connectionState = .failed(message: "socket closed")
            $0.lastError = "socket closed"
        }
    }
}

private func fixtureStream() -> AsyncStream<MarketEvent> {
    AsyncStream { continuation in
        Task {
            do {
                continuation.yield(try subscribedFixtureEvent())
                continuation.yield(try tickerFixtureEvent())
            } catch {
                Issue.record("fixture stream failed: \(error)")
            }
            continuation.finish()
        }
    }
}

private func subscribedFixtureEvent() throws -> MarketEvent {
    let data = try Fixture.data("okx_subscribe", provider: .okx)
    guard let event = try OkxMessageCodec.marketEvent(from: data) else {
        throw Fixture.FixtureError.notFound("okx_subscribe event")
    }
    return event
}

private func tickerFixtureEvent() throws -> MarketEvent {
    let data = try Fixture.data("okx_ticker", provider: .okx)
    guard let event = try OkxMessageCodec.marketEvent(from: data) else {
        throw Fixture.FixtureError.notFound("okx_ticker event")
    }
    return event
}
