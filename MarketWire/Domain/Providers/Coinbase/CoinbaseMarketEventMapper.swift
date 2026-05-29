import Foundation

enum CoinbaseMarketEventMapper {
    static func event(from message: CoinbaseInboundMessage) -> MarketEvent? {
        switch message {
        case let .subscriptions(dto):
            return .subscribed(channels: dto.channels.map(\.name))

        case let .ticker(dto):
            guard let price = decimal(dto.price), let time = date(dto.time) else {
                return nil
            }
            return .ticker(
                TickerSnapshot(
                    symbolID: dto.productID,
                    price: price,
                    open24h: decimal(dto.open24h),
                    high24h: decimal(dto.high24h),
                    low24h: decimal(dto.low24h),
                    volume24h: decimal(dto.volume24h),
                    bestBid: decimal(dto.bestBid),
                    bestAsk: decimal(dto.bestAsk),
                    lastSize: decimal(dto.lastSize),
                    side: dto.side.flatMap(TradeSide.init(rawValue:)),
                    time: time
                )
            )

        case let .match(dto):
            guard let price = decimal(dto.price),
                  let size = decimal(dto.size),
                  let side = TradeSide(rawValue: dto.side),
                  let time = date(dto.time)
            else {
                return nil
            }
            // Coinbase reports the maker order side: sell is an up-tick, buy is a down-tick.
            return .trade(
                Trade(id: dto.tradeID, symbolID: dto.productID, price: price, size: size, side: side, time: time)
            )

        case let .heartbeat(dto):
            guard let time = date(dto.time) else {
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

    private static let posix = Locale(identifier: "en_US_POSIX")

    private static func decimal(_ string: String?) -> Decimal? {
        guard let string else {
            return nil
        }
        return Decimal(string: string, locale: posix)
    }

    // Coinbase timestamps carry microsecond fractional seconds (e.g. 2022-10-19T23:28:22.061769Z).
    private static let fractionalSeconds = Date.ISO8601FormatStyle(includingFractionalSeconds: true)
    private static let wholeSeconds = Date.ISO8601FormatStyle(includingFractionalSeconds: false)

    private static func date(_ string: String) -> Date? {
        if let parsed = try? fractionalSeconds.parse(string) {
            return parsed
        }
        return try? wholeSeconds.parse(string)
    }
}
