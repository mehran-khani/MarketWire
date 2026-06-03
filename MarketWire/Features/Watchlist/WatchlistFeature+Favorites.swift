import Foundation

extension WatchlistFeature.State {
    mutating func toggleFavorite(symbolID: Symbol.ID) {
        if let index = favoriteSymbolIDs.firstIndex(of: symbolID) {
            favoriteSymbolIDs.remove(at: index)
            tickerBySymbolID.removeValue(forKey: symbolID)
        } else {
            favoriteSymbolIDs.append(symbolID)
        }
    }

    func isFavorite(symbolID: Symbol.ID) -> Bool {
        favoriteSymbolIDs.contains(symbolID)
    }
}
