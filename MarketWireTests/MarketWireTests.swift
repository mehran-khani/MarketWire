@testable import MarketWire
import Testing

@MainActor
struct MarketWireTests {
    @Test func defaultSubscribeArgsTrackConfiguredSymbols() {
        let subscribedIDs = Set(OKXConfiguration.defaultSubscribeArgs.map(\.instId))
        #expect(subscribedIDs == Set(OKXConfiguration.trackedSymbolIDs))
    }

    @Test func defaultSubscribeArgsUseTickersChannelOnly() {
        #expect(OKXConfiguration.defaultSubscribeArgs.allSatisfy { $0.channel == "tickers" })
    }

    @Test func trackedSymbolIDsIncludeWatchlistAndMarkets() {
        #expect(OKXConfiguration.trackedSymbolIDs.contains("BTC-USDT"))
        #expect(OKXConfiguration.trackedSymbolIDs.contains("ETH-USDT"))
        #expect(OKXConfiguration.trackedSymbolIDs.contains("SOL-USDT"))
    }

    @Test func missingTickerPresentationUsesPlaceholder() {
        #expect(TickerSnapshot.presentation(for: nil) == .missing)
    }

    @Test func symbolCardLabelsParsePair() {
        #expect(Symbol.cardLabels(for: "BTC-USDT") == ("BTC", "USDT"))
    }
}
