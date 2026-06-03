import Foundation

nonisolated enum QuoteFreshness {
    static let catalogStaleThreshold: TimeInterval = 10

    static func isCatalogStale(since updatedAt: Date, now: Date) -> Bool {
        now.timeIntervalSince(updatedAt) > catalogStaleThreshold
    }

    /// Shown only when the catalog bulk quote poll is stale — not when prices are current.
    static func catalogAttentionMessage(since updatedAt: Date, now: Date) -> String? {
        guard isCatalogStale(since: updatedAt, now: now) else { return nil }
        return "Prices may be outdated · \(relativeAgeDescription(since: updatedAt, now: now))"
    }

    static func rowAccessibilityFragment(updatedAt: Date, now: Date) -> String {
        if isCatalogStale(since: updatedAt, now: now) {
            return "price may be stale, \(relativeAgeDescription(since: updatedAt, now: now))"
        }
        return "updated \(relativeAgeDescription(since: updatedAt, now: now))"
    }

    static func relativeAgeDescription(since updatedAt: Date, now: Date) -> String {
        let seconds = max(0, Int(now.timeIntervalSince(updatedAt).rounded()))
        if seconds < 5 {
            return "just now"
        }
        if seconds < 60 {
            return "\(seconds) seconds ago"
        }
        let minutes = seconds / 60
        if minutes == 1 {
            return "1 minute ago"
        }
        if minutes < 60 {
            return "\(minutes) minutes ago"
        }
        return "over an hour ago"
    }
}
