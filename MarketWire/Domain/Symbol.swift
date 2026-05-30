import Foundation

nonisolated struct Symbol: Identifiable, Hashable, Sendable {
    let id: String
    let base: String
    let quote: String
    let displayName: String

    init(id: String, base: String, quote: String, displayName: String? = nil) {
        self.id = id
        self.base = base
        self.quote = quote
        self.displayName = displayName ?? id
    }
}
