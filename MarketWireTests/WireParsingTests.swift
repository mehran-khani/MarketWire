import Foundation
@testable import MarketWire
import Testing

struct WireParsingTests {
    private let posix = Locale(identifier: "en_US_POSIX")

    @Test func parsesDecimalString() {
        #expect(WireParsing.decimal("73692.1") == Decimal(string: "73692.1", locale: posix))
        #expect(WireParsing.decimal(nil) == nil)
    }

    @Test func parsesMillisTimestamp() {
        let date = WireParsing.millisTimestamp("1780106768765")
        #expect(date != nil)
        #expect(WireParsing.millisTimestamp("not-a-timestamp") == nil)
    }

    @Test func parsesISO8601Date() {
        let date = WireParsing.iso8601Date("2022-10-19T23:28:22.061769Z")
        #expect(date != nil)
        #expect(WireParsing.iso8601Date("not-a-date") == nil)
    }

    @Test func parsesTradeID() {
        #expect(WireParsing.tradeID("1010874567") == 1_010_874_567)
    }
}
