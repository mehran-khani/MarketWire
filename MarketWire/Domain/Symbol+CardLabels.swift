import Foundation

extension Symbol {
    static func cardLabels(for id: ID) -> (base: String, quote: String) {
        let parts = id.split(separator: "-", maxSplits: 1, omittingEmptySubsequences: false)
        let base = parts.first.map(String.init) ?? id
        let quote = parts.count > 1 ? String(parts[1]) : ""
        return (base, quote)
    }
}
