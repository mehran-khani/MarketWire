import Foundation

nonisolated enum CoinbaseMessageCodec {
    static func decode(_ data: Data) throws -> CoinbaseInboundMessage {
        try JSONDecoder().decode(CoinbaseInboundMessage.self, from: data)
    }

    static func marketEvent(from data: Data) throws -> MarketEvent? {
        try CoinbaseMarketEventMapper.event(from: decode(data))
    }
}
