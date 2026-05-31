import Foundation

extension AppFeature.State {
    mutating func applyTicker(_ snapshot: TickerSnapshot) {
        markets.tickerBySymbolID[snapshot.symbolID] = snapshot

        guard var detail, detail.symbolID == snapshot.symbolID else {
            return
        }
        detail.ticker = snapshot
        self.detail = detail
    }
}
