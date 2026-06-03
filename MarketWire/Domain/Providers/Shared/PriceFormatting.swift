import Foundation

nonisolated enum PriceFormatting {
    static func displayPrice(_ price: Decimal) -> String {
        let absolute = abs(price)
        guard absolute != 0 else { return "0.00" }

        return price.formatted(
            .number
                .precision(.fractionLength(fractionLengthRange(for: absolute)))
                .grouping(.automatic)
        )
    }

    private static func fractionLengthRange(for absolutePrice: Decimal) -> ClosedRange<Int> {
        if absolutePrice >= 1_000 {
            return 0 ... 2
        }
        if absolutePrice >= 1 {
            return 2 ... 2
        }
        if absolutePrice >= 0.01 {
            return 2 ... 4
        }
        if absolutePrice >= 0.0001 {
            return 4 ... 6
        }
        return 2 ... 8
    }

    private static func abs(_ value: Decimal) -> Decimal {
        value < 0 ? -value : value
    }
}
