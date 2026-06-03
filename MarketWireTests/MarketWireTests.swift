@testable import MarketWire
import Testing

@MainActor
struct MarketWireTests {
    @Test func defaultSubscribeArgsTrackDefaultWatchlist() {
        let subscribedIDs = Set(OKXConfiguration.defaultSubscribeArgs.map(\.instId))
        #expect(subscribedIDs == Set(OKXConfiguration.defaultWatchlistSymbolIDs))
    }

    @Test func defaultSubscribeArgsUseTickersChannelOnly() {
        #expect(OKXConfiguration.defaultSubscribeArgs.allSatisfy { $0.channel == "tickers" })
    }

    @Test func tickerSubscribeArgsMapsSymbolIDs() {
        let args = OKXConfiguration.tickerSubscribeArgs(for: ["ETH-USDT", "BTC-USDT"])
        #expect(args.map(\.instId) == ["ETH-USDT", "BTC-USDT"])
        #expect(args.allSatisfy { $0.channel == "tickers" })
    }

    @Test func missingTickerPresentationUsesPlaceholder() {
        #expect(TickerSnapshot.presentation(for: nil) == .missing)
    }

    @Test func symbolCardLabelsParsePair() {
        #expect(Symbol.cardLabels(for: "BTC-USDT") == ("BTC", "USDT"))
    }
}
