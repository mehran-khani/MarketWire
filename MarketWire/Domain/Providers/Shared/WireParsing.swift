import Foundation

nonisolated enum WireParsing {
    static let posix = Locale(identifier: "en_US_POSIX")

    static func decimal(_ string: String?) -> Decimal? {
        guard let string else {
            return nil
        }
        return Decimal(string: string, locale: posix)
    }

    static func millisTimestamp(_ string: String) -> Date? {
        guard let millis = Int64(string) else {
            return nil
        }
        return Date(timeIntervalSince1970: TimeInterval(millis) / 1_000)
    }

    static func iso8601Date(_ string: String) -> Date? {
        if let parsed = try? Date.ISO8601FormatStyle(includingFractionalSeconds: true).parse(string) {
            return parsed
        }
        return try? Date.ISO8601FormatStyle(includingFractionalSeconds: false).parse(string)
    }

    static func tradeID(_ string: String) -> Int {
        if let id = Int(string) {
            return id
        }
        if let id = UInt64(string) {
            return Int(id % UInt64(Int.max))
        }
        return 0
    }
}
