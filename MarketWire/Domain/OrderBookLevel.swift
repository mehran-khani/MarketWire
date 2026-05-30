import Foundation

nonisolated struct OrderBookLevel: Equatable, Sendable {
    let price: Decimal
    let size: Decimal
}
