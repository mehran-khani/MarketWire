import Foundation

nonisolated enum OKXConfiguration {
    private static let publicWebSocketURLString = "wss://ws.okx.com:8443/ws/v5/public"

    static let publicWebSocketURL: URL = {
        guard let url = URL(string: publicWebSocketURLString) else {
            preconditionFailure("Invalid OKX public WebSocket URL: \(publicWebSocketURLString)")
        }
        return url
    }()

    static let defaultSubscribeArgs: [OkxSubscribeArg] = [
        OkxSubscribeArg(channel: "tickers", instId: "BTC-USDT"),
        OkxSubscribeArg(channel: "trades", instId: "BTC-USDT")
    ]

    static let connectTimeoutNanoseconds: UInt64 = 15_000_000_000
    static let pingIntervalNanoseconds: UInt64 = 20_000_000_000
}
