import Foundation

enum ConnectionState: Equatable, Sendable {
    case idle
    case connecting
    case connected(since: Date)
    case reconnecting(attempt: Int, nextRetry: Date)
    case stale(lastMessageAt: Date)
    case disconnected(reason: String?)
    case failed(message: String)
}
