import Foundation

struct Heartbeat: Equatable, Sendable {
    let symbolID: Symbol.ID
    let sequence: Int?
    let lastTradeID: Int?
    let time: Date
}
