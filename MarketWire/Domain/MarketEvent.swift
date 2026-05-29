enum MarketEvent: Equatable, Sendable {
    case subscribed(channels: [String])
    case ticker(TickerSnapshot)
    case trade(Trade)
    case heartbeat(Heartbeat)
    case orderBook(OrderBook)
    case providerError(message: String)
}
