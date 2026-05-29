@testable import MarketWire
import Testing

@MainActor
struct MarketWireTests {
    @Test func appFeatureStateStartsEmpty() {
        #expect(AppFeature.State() == AppFeature.State())
    }
}
