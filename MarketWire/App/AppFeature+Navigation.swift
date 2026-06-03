import SwiftUI

extension AppFeature.State {
    mutating func openAssetDetail(symbolID: Symbol.ID) {
        let ticker = cachedTicker(for: symbolID)
            ?? markets.marketTickerBySymbolID[symbolID]?.tickerSnapshot
        detail = AssetDetailFeature.State(
            symbolID: symbolID,
            ticker: ticker
        )
        preferredCompactColumn = .detail
    }
}
