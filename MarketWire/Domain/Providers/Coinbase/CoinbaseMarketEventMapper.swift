import Foundation

nonisolated enum CoinbaseMarketEventMapper {
    static func event(from message: CoinbaseInboundMessage) -> MarketEvent? {
        switch message {
        case let .subscriptions(dto):
            return .subscribed(channels: dto.channels.map(\.name))

        case let .ticker(dto):
            guard let price = WireParsing.decimal(dto.price),
                  let time = WireParsing.iso8601Date(dto.time)
            else {
                return nil
            }
            return .ticker(
                TickerSnapshot(
                    symbolID: dto.productID,
                    price: price,
                    open24h: WireParsing.decimal(dto.open24h),
                    high24h: WireParsing.decimal(dto.high24h),
                    low24h: WireParsing.decimal(dto.low24h),
                    volume24h: WireParsing.decimal(dto.volume24h),
                    bestBid: WireParsing.decimal(dto.bestBid),
                    bestAsk: WireParsing.decimal(dto.bestAsk),
                    lastSize: WireParsing.decimal(dto.lastSize),
                    side: dto.side.flatMap(TradeSide.init(rawValue:)),
                    time: time
                )
            )

        case let .match(dto):
            guard let price = WireParsing.decimal(dto.price),
                  let size = WireParsing.decimal(dto.size),
                  let side = TradeSide(rawValue: dto.side),
                  let time = WireParsing.iso8601Date(dto.time)
            else {
                return nil
            }
            // Coinbase reports the maker order side: sell is an up-tick, buy is a down-tick.
            return .trade(
                Trade(id: dto.tradeID, symbolID: dto.productID, price: price, size: size, side: side, time: time)
            )

        case let .heartbeat(dto):
            guard let time = WireParsing.iso8601Date(dto.time) else {
                return nil
            }
            return .heartbeat(
                Heartbeat(symbolID: dto.productID, sequence: dto.sequence, lastTradeID: dto.lastTradeID, time: time)
            )

        case let .error(dto):
            return .providerError(message: dto.message)

        case .unsupported:
            return nil
        }
    }
}
