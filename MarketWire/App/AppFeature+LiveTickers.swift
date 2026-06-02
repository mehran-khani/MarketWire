import Foundation

extension AppFeature.State {
    mutating func applyTicker(_ snapshot: TickerSnapshot) {
        if watchlist.favoriteSymbolIDs.contains(snapshot.symbolID) {
            watchlist.tickerBySymbolID[snapshot.symbolID] = snapshot
        }

        if markets.symbols.contains(snapshot.symbolID) {
            markets.tickerBySymbolID[snapshot.symbolID] = snapshot
        }

        guard var detail, detail.symbolID == snapshot.symbolID else {
            return
        }
        detail.ticker = snapshot
        self.detail = detail
    }

    func cachedTicker(for symbolID: Symbol.ID) -> TickerSnapshot? {
        watchlist.tickerBySymbolID[symbolID] ?? markets.tickerBySymbolID[symbolID]
    }
}
