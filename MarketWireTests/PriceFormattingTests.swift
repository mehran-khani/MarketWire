@testable import MarketWire
import Foundation
import Testing

struct PriceFormattingTests {
    @Test func formatsLargePricesWithCents() {
        let formatted = PriceFormatting.displayPrice(70_000.12)
        #expect(formatted.contains("12"))
        #expect(!formatted.hasSuffix("00.00"))
    }

    @Test func formatsSubDollarPricesWithMorePrecision() {
        let formatted = PriceFormatting.displayPrice(0.0123)
        #expect(formatted != "0.00")
        #expect(formatted.contains("123") || formatted.contains("0123"))
    }

    @Test func formatsVerySmallPricesWithoutRoundingToZero() {
        let formatted = PriceFormatting.displayPrice(0.00004567)
        #expect(formatted != "0.00")
        #expect(formatted.contains("4") || formatted.contains("5"))
    }

    @Test func zeroFormatsAsZeroPointZeroZero() {
        #expect(PriceFormatting.displayPrice(0) == "0.00")
    }
}
