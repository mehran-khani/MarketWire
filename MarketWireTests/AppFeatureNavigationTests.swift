import ComposableArchitecture
@testable import MarketWire
import SwiftUI
import Testing

@MainActor
struct AppFeatureNavigationTests {
    @Test func selectingSectionUpdatesState() async {
        let store = TestStore(initialState: AppFeature.State()) {
            AppFeature()
        }

        await store.send(\.binding.selectedSection, .watchlist) {
            $0.selectedSection = .watchlist
        }

        await store.send(\.binding.selectedSection, .settings) {
            $0.selectedSection = .settings
        }
    }

    @Test func marketsAssetSelectionOpensDetailAndPrefersDetailColumn() async {
        let store = TestStore(initialState: AppFeature.State()) {
            AppFeature()
        }

        await store.send(.markets(.symbolTapped("BTC-USDT")))

        await store.receive(\.markets.delegate) {
            $0.detail = AssetDetailFeature.State(symbolID: "BTC-USDT", ticker: nil)
            $0.preferredCompactColumn = .detail
        }
    }

    @Test func marketsAssetSelectionUsesCachedTicker() async throws {
        let tickerEvent = try tickerFixtureEventForTests()
        guard case let .ticker(snapshot) = tickerEvent else {
            Issue.record("expected ticker fixture")
            return
        }

        let store = TestStore(
            initialState: AppFeature.State(
                markets: MarketsFeature.State(
                    tickerBySymbolID: [snapshot.symbolID: snapshot]
                )
            )
        ) {
            AppFeature()
        }

        await store.send(.markets(.symbolTapped(snapshot.symbolID)))

        await store.receive(\.markets.delegate) {
            $0.detail = AssetDetailFeature.State(symbolID: snapshot.symbolID, ticker: snapshot)
            $0.preferredCompactColumn = .detail
        }
    }

    @Test func assetDetailCloseClearsDetail() async {
        let store = TestStore(
            initialState: AppFeature.State(
                preferredCompactColumn: .detail,
                detail: AssetDetailFeature.State(symbolID: "BTC-USDT", ticker: nil)
            )
        ) {
            AppFeature()
        }

        await store.send(.detail(.closeTapped))

        await store.receive(\.detail.delegate) {
            $0.detail = nil
            $0.preferredCompactColumn = .content
        }
    }

    @Test func detailNavigationPopClearsDetail() async {
        let store = TestStore(
            initialState: AppFeature.State(
                preferredCompactColumn: .detail,
                detail: AssetDetailFeature.State(symbolID: "BTC-USDT", ticker: nil)
            )
        ) {
            AppFeature()
        }

        await store.send(.detailNavigationPop) {
            $0.detail = nil
            $0.preferredCompactColumn = .content
        }
    }

    @Test func detailNavigationPopIsNoOpWithoutDetail() async {
        let store = TestStore(initialState: AppFeature.State()) {
            AppFeature()
        }

        await store.send(.detailNavigationPop)
    }

    @Test func compactColumnBindingFromDetailToContentDoesNotClearWithoutPopAction() async {
        let store = TestStore(
            initialState: AppFeature.State(
                preferredCompactColumn: .detail,
                detail: AssetDetailFeature.State(symbolID: "BTC-USDT", ticker: nil)
            )
        ) {
            AppFeature()
        }

        await store.send(\.binding.preferredCompactColumn, .content) {
            $0.preferredCompactColumn = .content
        }
    }

    @Test func tickerUpdatesOpenDetail() async throws {
        let tickerEvent = try tickerFixtureEventForTests()
        guard case let .ticker(snapshot) = tickerEvent else {
            Issue.record("expected ticker fixture")
            return
        }

        let store = TestStore(
            initialState: AppFeature.State(
                detail: AssetDetailFeature.State(symbolID: snapshot.symbolID, ticker: nil)
            )
        ) {
            AppFeature()
        }

        await store.send(.marketEvent(tickerEvent)) {
            $0.markets.tickerBySymbolID = [snapshot.symbolID: snapshot]
            $0.detail = AssetDetailFeature.State(symbolID: snapshot.symbolID, ticker: snapshot)
        }
    }

    @Test func tickerDoesNotUpdateDetailForDifferentSymbol() async throws {
        let tickerEvent = try tickerFixtureEventForTests()
        guard case let .ticker(snapshot) = tickerEvent else {
            Issue.record("expected ticker fixture")
            return
        }

        let store = TestStore(
            initialState: AppFeature.State(
                detail: AssetDetailFeature.State(symbolID: "ETH-USDT", ticker: nil)
            )
        ) {
            AppFeature()
        }

        await store.send(.marketEvent(tickerEvent)) {
            $0.markets.tickerBySymbolID = [snapshot.symbolID: snapshot]
        }
    }

    @Test func columnVisibilityBindingUpdatesState() async {
        let store = TestStore(initialState: AppFeature.State()) {
            AppFeature()
        }

        await store.send(\.binding.columnVisibility, .all) {
            $0.columnVisibility = .all
        }
    }
}

private func tickerFixtureEventForTests() throws -> MarketEvent {
    let data = try Fixture.data("okx_ticker", provider: .okx)
    guard let event = try OkxMessageCodec.marketEvent(from: data) else {
        throw Fixture.FixtureError.notFound("okx_ticker event")
    }
    return event
}
