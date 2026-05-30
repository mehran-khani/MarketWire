import Foundation
@testable import MarketWire
import Testing

struct OkxMarketEventMapperTests {
    private let posix = Locale(identifier: "en_US_POSIX")

    @Test func mapsSubscribeConfirmation() throws {
        guard case let .subscribed(channels)? = try event("okx_subscribe") else {
            Issue.record("expected subscribed event")
            return
        }
        #expect(channels == ["tickers:BTC-USDT"])
    }

    @Test func mapsTickerPush() throws {
        guard case let .ticker(snapshot)? = try event("okx_ticker") else {
            Issue.record("expected ticker event")
            return
        }
        #expect(snapshot.symbolID == "BTC-USDT")
        #expect(snapshot.price == Decimal(string: "73692.1", locale: posix))
        #expect(snapshot.bestBid == Decimal(string: "73692.1", locale: posix))
        #expect(snapshot.bestAsk == Decimal(string: "73692.2", locale: posix))
        #expect(snapshot.volume24h == Decimal(string: "5745.90193243", locale: posix))
        #expect(snapshot.time == WireParsing.millisTimestamp("1780106768765"))
    }

    @Test func mapsTradePush() throws {
        guard case let .trade(trade)? = try event("okx_trade") else {
            Issue.record("expected trade event")
            return
        }
        #expect(trade.id == 1_010_874_567)
        #expect(trade.symbolID == "BTC-USDT")
        #expect(trade.price == Decimal(string: "73692.2", locale: posix))
        #expect(trade.size == Decimal(string: "0.0000407", locale: posix))
        #expect(trade.side == .buy)
    }

    @Test func mapsProviderError() throws {
        guard case let .providerError(message)? = try event("okx_error") else {
            Issue.record("expected providerError event")
            return
        }
        #expect(message.hasPrefix("60012:"))
    }

    @Test func mapsNoticeToProviderError() throws {
        guard case let .providerError(message)? = try event("okx_notice") else {
            Issue.record("expected providerError event")
            return
        }
        #expect(message.contains("64008"))
    }

    @Test func unsupportedMapsToNil() throws {
        #expect(try event("okx_unsupported") == nil)
    }

    private func event(_ name: String) throws -> MarketEvent? {
        let data = try Fixture.data(name, provider: .okx)
        return try OkxMessageCodec.marketEvent(from: data)
    }
}
