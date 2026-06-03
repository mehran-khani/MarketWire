import Foundation
@testable import MarketWire
import Testing

struct QuoteFreshnessTests {
    private let now = Date(timeIntervalSince1970: 1_000)

    @Test func relativeAgeJustNow() {
        let updatedAt = now.addingTimeInterval(-2)
        #expect(QuoteFreshness.relativeAgeDescription(since: updatedAt, now: now) == "just now")
    }

    @Test func relativeAgeSeconds() {
        let updatedAt = now.addingTimeInterval(-12)
        #expect(QuoteFreshness.relativeAgeDescription(since: updatedAt, now: now) == "12 seconds ago")
    }

    @Test func catalogStaleAfterThreshold() {
        let updatedAt = now.addingTimeInterval(-11)
        #expect(QuoteFreshness.isCatalogStale(since: updatedAt, now: now))
    }

    @Test func catalogFreshWithinThreshold() {
        let updatedAt = now.addingTimeInterval(-9)
        #expect(!QuoteFreshness.isCatalogStale(since: updatedAt, now: now))
    }

    @Test func catalogAttentionOnlyWhenStale() {
        let fresh = now.addingTimeInterval(-5)
        #expect(QuoteFreshness.catalogAttentionMessage(since: fresh, now: now) == nil)

        let stale = now.addingTimeInterval(-15)
        let text = QuoteFreshness.catalogAttentionMessage(since: stale, now: now)
        #expect(text?.contains("outdated") == true)
    }
}
