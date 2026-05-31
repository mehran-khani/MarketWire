import Foundation

nonisolated enum ConnectionState: Equatable, Sendable {
    case idle
    case connecting
    case connected(since: Date)
    case disconnected(reason: String?)
    case failed(message: String)
}
