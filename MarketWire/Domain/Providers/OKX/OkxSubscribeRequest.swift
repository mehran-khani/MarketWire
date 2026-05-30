import Foundation

nonisolated struct OkxSubscribeRequest: Encodable, Equatable, Sendable {
    let id: String?
    let op: String // swiftlint:disable:this identifier_name
    let args: [OkxSubscribeArg]
}

nonisolated struct OkxSubscribeArg: Encodable, Equatable, Sendable {
    let channel: String
    let instId: String

    enum CodingKeys: String, CodingKey {
        case channel
        case instId
    }
}
