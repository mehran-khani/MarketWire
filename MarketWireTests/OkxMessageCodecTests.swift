import Foundation
@testable import MarketWire
import Testing

struct OkxMessageCodecTests {
    private let posix = Locale(identifier: "en_US_POSIX")

    @Test func decodesInboundMessage() throws {
        let data = try Fixture.data("okx_subscribe", provider: .okx)
        let message = try OkxMessageCodec.decode(data)
        guard case .subscribed = message else {
            Issue.record("expected subscribed message")
            return
        }
    }

    @Test func mapsMarketEventsFromData() throws {
        let data = try Fixture.data("okx_ticker", provider: .okx)
        let events = try OkxMessageCodec.marketEvents(from: data)
        #expect(events.count == 1)
        guard case let .ticker(snapshot) = events[0] else {
            Issue.record("expected ticker event")
            return
        }
        #expect(snapshot.symbolID == "BTC-USDT")
        #expect(snapshot.price == Decimal(string: "73692.1", locale: posix))
    }

    @Test func encodesSubscribePayload() throws {
        let text = try OkxMessageCodec.encodeSubscribe(
            to: [
                OkxSubscribeArg(channel: "tickers", instId: "BTC-USDT"),
                OkxSubscribeArg(channel: "trades", instId: "BTC-USDT")
            ],
            id: "1512"
        )
        #expect(text.contains("\"op\":\"subscribe\""))
        #expect(text.contains("\"channel\":\"tickers\""))
        #expect(text.contains("\"instId\":\"BTC-USDT\""))
    }
}
