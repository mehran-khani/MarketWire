import Foundation

struct SymbolSearchIndexEntry: Equatable, Sendable {
    let haystack: String
    let compactHaystack: String
}

extension MarketsFeature.State {
    mutating func applyInstruments(_ instruments: [Symbol]) {
        self.instruments = instruments
        instrumentSearchIndex = MarketsCatalogSearch.buildIndex(for: instruments)
        rebuildFilteredInstruments()
    }

    mutating func applyFilterQuery(_ query: String) {
        filterQuery = query
        rebuildFilteredInstruments()
    }

    mutating func rebuildFilteredInstruments() {
        guard !filterQuery.isEmpty else {
            filteredInstruments = instruments
            return
        }

        filteredInstruments = MarketsCatalogSearch.filter(
            instruments: instruments,
            index: instrumentSearchIndex,
            query: filterQuery
        )
    }
}

enum MarketsCatalogSearch {
    static func buildIndex(for instruments: [Symbol]) -> [Symbol.ID: SymbolSearchIndexEntry] {
        Dictionary(uniqueKeysWithValues: instruments.map { symbol in
            let haystack = normalizedSearchText("\(symbol.id) \(symbol.base) \(symbol.quote)")
            let compactHaystack = compactSearchText(haystack)
            return (
                symbol.id,
                SymbolSearchIndexEntry(haystack: haystack, compactHaystack: compactHaystack)
            )
        })
    }

    static func filter(
        instruments: [Symbol],
        index: [Symbol.ID: SymbolSearchIndexEntry],
        query: String
    ) -> [Symbol] {
        guard !query.isEmpty else { return instruments }

        let queryTokens = searchTokens(from: query)
        guard !queryTokens.isEmpty else { return instruments }

        let compactQuery = compactSearchText(query)
        let compactQueryTokens = queryTokens.map { compactSearchText($0) }

        return instruments.filter { symbol in
            guard let entry = index[symbol.id] else { return false }
            return matches(
                entry: entry,
                queryTokens: queryTokens,
                compactQuery: compactQuery,
                compactQueryTokens: compactQueryTokens
            )
        }
    }

    private static func matches(
        entry: SymbolSearchIndexEntry,
        queryTokens: [String],
        compactQuery: String,
        compactQueryTokens: [String]
    ) -> Bool {
        if !compactQuery.isEmpty, entry.compactHaystack.contains(compactQuery) {
            return true
        }

        return zip(queryTokens, compactQueryTokens).allSatisfy { token, compactToken in
            entry.haystack.contains(token)
                || (!compactToken.isEmpty && entry.compactHaystack.contains(compactToken))
        }
    }

    private static func searchTokens(from rawQuery: String) -> [String] {
        normalizedSearchText(rawQuery)
            .split(separator: " ")
            .map(String.init)
    }

    private static func normalizedSearchText(_ text: String) -> String {
        text
            .lowercased()
            .replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: "/", with: " ")
            .replacingOccurrences(of: "_", with: " ")
            .split(whereSeparator: \.isWhitespace)
            .joined(separator: " ")
    }

    private static func compactSearchText(_ text: String) -> String {
        normalizedSearchText(text).replacingOccurrences(of: " ", with: "")
    }
}
