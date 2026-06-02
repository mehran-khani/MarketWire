import ComposableArchitecture
@testable import MarketWire
import Testing

@MainActor
struct MarketsFeatureTests {
    @Test func defaultSymbolsMatchOKXConfiguration() {
        #expect(MarketsFeature.State().symbols == OKXConfiguration.defaultMarketSymbolIDs)
    }

    @Test func symbolTappedEmitsDelegate() async {
        let store = TestStore(initialState: MarketsFeature.State()) {
            MarketsFeature()
        }

        await store.send(.symbolTapped("BTC-USDT"))
        await store.receive(.delegate(.assetSelected(symbolID: "BTC-USDT")))
    }
}
