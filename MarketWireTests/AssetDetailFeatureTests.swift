import ComposableArchitecture
@testable import MarketWire
import Testing

@MainActor
struct AssetDetailFeatureTests {
    @Test func closeTappedEmitsDelegate() async {
        let store = TestStore(
            initialState: AssetDetailFeature.State(symbolID: "BTC-USDT", ticker: nil)
        ) {
            AssetDetailFeature()
        }

        await store.send(.closeTapped)
        await store.receive(.delegate(.closeRequested))
    }
}
