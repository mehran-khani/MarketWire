import Foundation

nonisolated struct Trade: Identifiable, Equatable, Sendable {
    let id: Int
    let symbolID: Symbol.ID
    let price: Decimal
    let size: Decimal
    let side: TradeSide
    let time: Date
}
