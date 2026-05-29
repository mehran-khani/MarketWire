import Foundation

struct OrderBookLevel: Equatable, Sendable {
    let price: Decimal
    let size: Decimal
}
