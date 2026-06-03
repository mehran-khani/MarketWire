import Foundation

extension MarketTicker {
    nonisolated var displayPrice: String {
        PriceFormatting.displayPrice(lastPrice)
    }

    nonisolated var numericTextValue: Double {
        (lastPrice as NSDecimalNumber).doubleValue
    }

    nonisolated var change24hFraction: Decimal? {
        guard let open24h, open24h != 0 else { return nil }
        return (lastPrice - open24h) / open24h
    }

    nonisolated var isPriceUp24h: Bool? {
        guard change24hFraction != nil else { return nil }
        return lastPrice >= open24h ?? lastPrice
    }

    nonisolated var displayChange24hPercent: String? {
        guard let change24hFraction else { return nil }
        let percent = change24hFraction * 100
        let formatted = percent.formatted(
            .number
                .precision(.fractionLength(2))
                .sign(strategy: .always(includingZero: false))
        )
        return "\(formatted)%"
    }

    nonisolated var change24hNumericTextValue: Double? {
        guard let change24hFraction else { return nil }
        return (change24hFraction as NSDecimalNumber).doubleValue
    }

    nonisolated var presentation: TickerSnapshot.Presentation {
        TickerSnapshot.Presentation(
            priceText: displayPrice,
            priceNumericValue: numericTextValue,
            changePercentText: displayChange24hPercent,
            isUp24h: isPriceUp24h,
            changeNumericValue: change24hNumericTextValue,
            snapshotPrice: lastPrice
        )
    }

    nonisolated static func presentation(for ticker: MarketTicker?) -> TickerSnapshot.Presentation {
        ticker?.presentation ?? .missing
    }
}
