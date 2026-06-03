import Foundation

nonisolated struct TickerSnapshot: Equatable, Sendable {
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
}

extension TickerSnapshot {
    nonisolated var displayPrice: String {
        PriceFormatting.displayPrice(price)
    }

    nonisolated var numericTextValue: Double {
        (price as NSDecimalNumber).doubleValue
    }
}
