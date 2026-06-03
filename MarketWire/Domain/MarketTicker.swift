import Foundation

/// Price snapshot for the Markets browse list, from OKX REST bulk tickers
///
/// Use `MarketTicker` for the all-pairs Markets screen refreshed via HTTP poll.
nonisolated struct MarketTicker: Equatable, Sendable {
    let symbolID: Symbol.ID
    let lastPrice: Decimal
    let open24h: Decimal?
    let high24h: Decimal?
    let low24h: Decimal?
    let updatedAt: Date
}
