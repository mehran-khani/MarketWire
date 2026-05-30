import Foundation

nonisolated struct PriceAlert: Identifiable, Equatable, Sendable {
    nonisolated enum Condition: String, Sendable, Equatable {
        case above
        case below
    }

    let id: UUID
    let symbolID: Symbol.ID
    let condition: Condition
    let targetPrice: Decimal
    var isEnabled: Bool

    init(
        id: UUID = UUID(),
        symbolID: Symbol.ID,
        condition: Condition,
        targetPrice: Decimal,
        isEnabled: Bool = true
    ) {
        self.id = id
        self.symbolID = symbolID
        self.condition = condition
        self.targetPrice = targetPrice
        self.isEnabled = isEnabled
    }
}
