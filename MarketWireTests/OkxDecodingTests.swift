import Foundation
@testable import MarketWire
import Testing

struct OkxDecodingTests {
    private let decoder = JSONDecoder()

    @Test func decodesSubscribeEvent() throws {
        let message = try decode("okx_subscribe")
        guard case let .subscribed(dto) = message else {
            Issue.record("expected subscribed, got \(message)")
            return
        }
        #expect(dto.event == "subscribe")
        #expect(dto.arg?.channel == "tickers")
        #expect(dto.arg?.instId == "BTC-USDT")
        #expect(dto.connId == "cf6b6fc7")
    }

    @Test func decodesTickerPush() throws {
        let message = try decode("okx_ticker")
        guard case let .tickers(dto) = message else {
            Issue.record("expected tickers push, got \(message)")
            return
        }
        #expect(dto.arg.channel == "tickers")
        #expect(dto.data.count == 1)
        #expect(dto.data[0].instId == "BTC-USDT")
        #expect(dto.data[0].last == "73692.1")
        #expect(dto.data[0].ts == "1780106768765")
    }

    @Test func decodesTradePush() throws {
        let message = try decode("okx_trade")
        guard case let .trades(dto) = message else {
            Issue.record("expected trades push, got \(message)")
            return
        }
        #expect(dto.arg.channel == "trades")
        #expect(dto.data[0].tradeId == "1010874567")
        #expect(dto.data[0].side == "buy")
    }

    @Test func decodesErrorEvent() throws {
        let message = try decode("okx_error")
        guard case let .error(dto) = message else {
            Issue.record("expected error, got \(message)")
            return
        }
        #expect(dto.code == "60012")
        #expect(dto.msg?.contains("Invalid request") == true)
    }

    @Test func decodesNoticeEvent() throws {
        let message = try decode("okx_notice")
        guard case let .notice(dto) = message else {
            Issue.record("expected notice, got \(message)")
            return
        }
        #expect(dto.code == "64008")
    }

    @Test func decodesUnknownEventAsUnsupported() throws {
        let message = try decode("okx_unsupported")
        #expect(message == .unsupported)
    }

    private func decode(_ name: String) throws -> OkxInboundMessage {
        let data = try Fixture.data(name, provider: .okx)
        return try decoder.decode(OkxInboundMessage.self, from: data)
    }
}
