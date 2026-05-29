import Foundation

struct TickerSnapshot: Equatable, Sendable {
    let symbolID: Symbol.ID
    let price: Decimal
    let open24h: Decimal?
    let high24h: Decimal?
    let low24h: Decimal?
    let volume24h: Decimal?
    let bestBid: Decimal?
    let bestAsk: Decimal?
    let lastSize: Decimal?
    let side: TradeSide?
    let time: Date

    init(
        symbolID: Symbol.ID,
        price: Decimal,
        open24h: Decimal? = nil,
        high24h: Decimal? = nil,
        low24h: Decimal? = nil,
        volume24h: Decimal? = nil,
        bestBid: Decimal? = nil,
        bestAsk: Decimal? = nil,
        lastSize: Decimal? = nil,
        side: TradeSide? = nil,
        time: Date
    ) {
        self.symbolID = symbolID
        self.price = price
        self.open24h = open24h
        self.high24h = high24h
        self.low24h = low24h
        self.volume24h = volume24h
        self.bestBid = bestBid
        self.bestAsk = bestAsk
        self.lastSize = lastSize
        self.side = side
        self.time = time
    }
}
