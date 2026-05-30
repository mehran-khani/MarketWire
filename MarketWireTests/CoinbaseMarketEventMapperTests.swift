import Foundation
@testable import MarketWire
import Testing

struct CoinbaseMarketEventMapperTests {
    private let decoder = JSONDecoder()
    private let posix = Locale(identifier: "en_US_POSIX")

    @Test func mapsTicker() throws {
        guard case let .ticker(snapshot)? = try event("coinbase_ticker") else {
            Issue.record("expected ticker event")
            return
        }
        #expect(snapshot.symbolID == "ETH-USD")
        #expect(snapshot.price == Decimal(string: "1285.22", locale: posix))
        #expect(snapshot.volume24h == Decimal(string: "245532.79269678", locale: posix))
        #expect(snapshot.bestBid == Decimal(string: "1285.04", locale: posix))
        #expect(snapshot.side == .buy)

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: snapshot.time)
        #expect(components.year == 2022)
        #expect(components.month == 10)
        #expect(components.day == 19)
        #expect(components.hour == 23)
        #expect(components.minute == 28)
        #expect(components.second == 22)
    }

    @Test func mapsMatchToTrade() throws {
        guard case let .trade(trade)? = try event("coinbase_match") else {
            Issue.record("expected trade event")
            return
        }
        #expect(trade.id == 10)
        #expect(trade.symbolID == "BTC-USD")
        #expect(trade.price == Decimal(string: "400.23", locale: posix))
        #expect(trade.size == Decimal(string: "5.23512", locale: posix))
        #expect(trade.side == .sell)
    }

    @Test func mapsHeartbeat() throws {
        guard case let .heartbeat(beat)? = try event("coinbase_heartbeat") else {
            Issue.record("expected heartbeat event")
            return
        }
        #expect(beat.symbolID == "BTC-USD")
        #expect(beat.sequence == 90)
        #expect(beat.lastTradeID == 20)
    }

    @Test func mapsSubscriptions() throws {
        guard case let .subscribed(channels)? = try event("coinbase_subscriptions") else {
            Issue.record("expected subscribed event")
            return
        }
        #expect(channels == ["ticker", "heartbeat"])
    }

    @Test func mapsProviderError() throws {
        guard case let .providerError(message)? = try event("coinbase_error") else {
            Issue.record("expected providerError event")
            return
        }
        #expect(message == "Failed to subscribe")
    }

    @Test func unsupportedMapsToNil() throws {
        #expect(try event("coinbase_unsupported") == nil)
    }

    private func event(_ name: String) throws -> MarketEvent? {
        let data = try Fixture.data(name, provider: .coinbase)
        let message = try decoder.decode(CoinbaseInboundMessage.self, from: data)
        return CoinbaseMarketEventMapper.event(from: message)
    }
}
