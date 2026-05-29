import Foundation
@testable import MarketWire
import Testing

@MainActor
struct CoinbaseDecodingTests {
    private let decoder = JSONDecoder()

    @Test func decodesTicker() throws {
        let message = try decode("coinbase_ticker")
        guard case let .ticker(dto) = message else {
            Issue.record("expected ticker, got \(message)")
            return
        }
        #expect(dto.productID == "ETH-USD")
        #expect(dto.price == "1285.22")
        #expect(dto.tradeID == 370843401)
        #expect(dto.side == "buy")
        #expect(dto.time == "2022-10-19T23:28:22.061769Z")
    }

    @Test func decodesMatch() throws {
        let message = try decode("coinbase_match")
        guard case let .match(dto) = message else {
            Issue.record("expected match, got \(message)")
            return
        }
        #expect(dto.tradeID == 10)
        #expect(dto.productID == "BTC-USD")
        #expect(dto.price == "400.23")
        #expect(dto.size == "5.23512")
        #expect(dto.side == "sell")
    }

    @Test func decodesHeartbeat() throws {
        let message = try decode("coinbase_heartbeat")
        guard case let .heartbeat(dto) = message else {
            Issue.record("expected heartbeat, got \(message)")
            return
        }
        #expect(dto.productID == "BTC-USD")
        #expect(dto.sequence == 90)
        #expect(dto.lastTradeID == 20)
    }

    @Test func decodesSubscriptions() throws {
        let message = try decode("coinbase_subscriptions")
        guard case let .subscriptions(dto) = message else {
            Issue.record("expected subscriptions, got \(message)")
            return
        }
        #expect(dto.channels.map(\.name) == ["ticker", "heartbeat"])
        #expect(dto.channels.first?.productIDs == ["BTC-USD", "ETH-USD"])
    }

    @Test func decodesError() throws {
        let message = try decode("coinbase_error")
        guard case let .error(dto) = message else {
            Issue.record("expected error, got \(message)")
            return
        }
        #expect(dto.message == "Failed to subscribe")
        #expect(dto.reason == "ticker is not a valid channel")
    }

    @Test func decodesUnknownTypeAsUnsupported() throws {
        let message = try decode("coinbase_unsupported")
        guard case let .unsupported(type) = message else {
            Issue.record("expected unsupported, got \(message)")
            return
        }
        #expect(type == "status")
    }

    @Test func malformedMessageThrows() throws {
        let data = try Fixture.data("coinbase_malformed")
        #expect(throws: (any Error).self) {
            try decoder.decode(CoinbaseInboundMessage.self, from: data)
        }
    }

    private func decode(_ name: String) throws -> CoinbaseInboundMessage {
        let data = try Fixture.data(name)
        return try decoder.decode(CoinbaseInboundMessage.self, from: data)
    }
}
