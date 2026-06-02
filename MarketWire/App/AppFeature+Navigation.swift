import SwiftUI

extension AppFeature.State {
    mutating func openAssetDetail(symbolID: Symbol.ID) {
        detail = AssetDetailFeature.State(
            symbolID: symbolID,
            ticker: cachedTicker(for: symbolID)
        )
        preferredCompactColumn = .detail
    }
}
