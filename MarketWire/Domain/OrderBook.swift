import Foundation

struct OrderBook: Equatable, Sendable {
    let symbolID: Symbol.ID
    let bids: [OrderBookLevel]
    let asks: [OrderBookLevel]
    let time: Date?

    init(symbolID: Symbol.ID, bids: [OrderBookLevel], asks: [OrderBookLevel], time: Date? = nil) {
        self.symbolID = symbolID
        self.bids = bids
        self.asks = asks
        self.time = time
    }
}
