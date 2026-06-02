import ComposableArchitecture
import Foundation
@testable import MarketWire
import Testing

@MainActor
struct MarketsFeatureTests {
    private let sampleInstruments: [Symbol] = [
        Symbol(id: "BTC-USDT", base: "BTC", quote: "USDT"),
        Symbol(id: "ETH-USDT", base: "ETH", quote: "USDT"),
        Symbol(id: "SOL-USDT", base: "SOL", quote: "USDT"),
    ]

    @Test func catalogAppearedLoadsInstruments() async {
        let store = TestStore(initialState: MarketsFeature.State()) {
            MarketsFeature()
        } withDependencies: {
            $0.marketREST.fetchSpotInstruments = { self.sampleInstruments }
        }

        await store.send(.catalogAppeared) {
            $0.loadState = .loading
        }

        await store.receive(\.instrumentsLoaded) {
            $0.loadState = .loaded
            $0.instruments = sampleInstruments
        }
    }

    @Test func catalogAppearedDoesNotReloadWhileLoaded() async {
        let store = TestStore(
            initialState: MarketsFeature.State(
                instruments: sampleInstruments,
                loadState: .loaded
            )
        ) {
            MarketsFeature()
        } withDependencies: {
            $0.marketREST.fetchSpotInstruments = {
                Issue.record("catalog should not refetch while loaded")
                return []
            }
        }

        await store.send(.catalogAppeared)
    }

    @Test func catalogAppearedRetriesAfterFailure() async {
        let attempts = CatalogAttemptBox()
        let store = TestStore(
            initialState: MarketsFeature.State(
                loadState: MarketsFeature.CatalogLoadState.failed("offline")
            )
        ) {
            MarketsFeature()
        } withDependencies: {
            $0.marketREST.fetchSpotInstruments = {
                attempts.count += 1
                if attempts.count == 1 {
                    throw CatalogTestError.offline
                }
                return self.sampleInstruments
            }
        }

        await store.send(.catalogAppeared) {
            $0.loadState = .loading
        }

        await store.receive(\.instrumentsFailed) {
            $0.loadState = MarketsFeature.CatalogLoadState.failed("offline")
        }

        await store.send(.catalogAppeared) {
            $0.loadState = .loading
        }

        await store.receive(\.instrumentsLoaded) {
            $0.loadState = .loaded
            $0.instruments = sampleInstruments
        }
    }

    @Test func instrumentsFailedSetsFailedState() async {
        let store = TestStore(initialState: MarketsFeature.State()) {
            MarketsFeature()
        } withDependencies: {
            $0.marketREST.fetchSpotInstruments = {
                throw CatalogTestError.offline
            }
        }

        await store.send(.catalogAppeared) {
            $0.loadState = .loading
        }

        await store.receive(\.instrumentsFailed) {
            $0.loadState = MarketsFeature.CatalogLoadState.failed("offline")
        }
    }

    @Test func searchQueryFiltersInstruments() async {
        var state = MarketsFeature.State(instruments: sampleInstruments, loadState: .loaded)
        state.searchQuery = "eth"
        #expect(state.filteredInstruments.map(\.id) == ["ETH-USDT"])
    }

    @Test func symbolTappedEmitsDelegate() async {
        let store = TestStore(initialState: MarketsFeature.State()) {
            MarketsFeature()
        }

        await store.send(.symbolTapped("BTC-USDT"))
        await store.receive(.delegate(.assetSelected(symbolID: "BTC-USDT")))
    }
}

private enum CatalogTestError: LocalizedError {
    case offline

    var errorDescription: String? { "offline" }
}

private final class CatalogAttemptBox: @unchecked Sendable {
    var count = 0
}
