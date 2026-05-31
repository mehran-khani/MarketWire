@testable import MarketWire
import Testing

@MainActor
struct MarketWireTests {
    @Test func defaultSubscribeArgsTrackConfiguredSymbols() {
        let subscribedIDs = Set(OKXConfiguration.defaultSubscribeArgs.map(\.instId))
        #expect(subscribedIDs == Set(OKXConfiguration.defaultSymbolIDs))
    }

    @Test func defaultSubscribeArgsUseTickersChannelOnly() {
        #expect(OKXConfiguration.defaultSubscribeArgs.allSatisfy { $0.channel == "tickers" })
    }
}
