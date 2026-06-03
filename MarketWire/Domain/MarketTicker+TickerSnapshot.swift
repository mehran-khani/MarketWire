import Foundation

extension MarketTicker {
    nonisolated var tickerSnapshot: TickerSnapshot {
        TickerSnapshot(
            symbolID: symbolID,
            price: lastPrice,
            open24h: open24h,
            high24h: high24h,
            low24h: low24h,
            volume24h: nil,
            bestBid: nil,
            bestAsk: nil,
            lastSize: nil,
            side: nil,
            time: updatedAt
        )
    }
}
