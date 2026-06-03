import Foundation

extension TickerSnapshot {
    nonisolated struct Presentation: Equatable, Sendable {
        let priceText: String
        let priceNumericValue: Double
        let changePercentText: String?
        let isUp24h: Bool?
        let changeNumericValue: Double?
        let snapshotPrice: Decimal?

        static let missing = Presentation(
            priceText: "—",
            priceNumericValue: 0,
            changePercentText: nil,
            isUp24h: nil,
            changeNumericValue: nil,
            snapshotPrice: nil
        )

        var accessibilitySummary: String {
            var parts = [priceText]
            if let changePercentText {
                parts.append("24 hour change \(changePercentText)")
            }
            return parts.joined(separator: ", ")
        }
    }

    nonisolated var presentation: Presentation {
        Presentation(
            priceText: displayPrice,
            priceNumericValue: numericTextValue,
            changePercentText: displayChange24hPercent,
            isUp24h: isPriceUp24h,
            changeNumericValue: change24hNumericTextValue,
            snapshotPrice: price
        )
    }

    nonisolated static func presentation(for snapshot: TickerSnapshot?) -> Presentation {
        snapshot?.presentation ?? .missing
    }
}
