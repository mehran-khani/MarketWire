import Foundation

nonisolated enum OKXConfiguration {
    private static let publicRESTURLString = "https://www.okx.com"
    private static let publicWebSocketURLString = "wss://ws.okx.com:8443/ws/v5/public"

    static let publicRESTURL: URL = {
        guard let url = URL(string: publicRESTURLString) else {
            preconditionFailure("Invalid OKX public REST URL: \(publicRESTURLString)")
        }
        return url
    }()

    static let publicWebSocketURL: URL = {
        guard let url = URL(string: publicWebSocketURLString) else {
            preconditionFailure("Invalid OKX public WebSocket URL: \(publicWebSocketURLString)")
        }
        return url
    }()

    static let defaultWatchlistSymbolIDs: [Symbol.ID] = ["BTC-USDT", "ETH-USDT", "SOL-USDT"]

    static let defaultMarketSymbolIDs: [Symbol.ID] = ["BTC-USDT"]

    static var trackedSymbolIDs: [Symbol.ID] {
        var seen = Set<Symbol.ID>()
        return (defaultWatchlistSymbolIDs + defaultMarketSymbolIDs).filter { seen.insert($0).inserted }
    }

    static let defaultSubscribeArgs: [OkxSubscribeArg] = trackedSymbolIDs.map {
        OkxSubscribeArg(channel: "tickers", instId: $0)
    }

    static let connectTimeoutNanoseconds: UInt64 = 15_000_000_000
    static let pingIntervalNanoseconds: UInt64 = 20_000_000_000
}
