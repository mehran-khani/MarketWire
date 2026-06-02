import Foundation

nonisolated struct OkxInstrumentDTO: Decodable, Equatable, Sendable {
    let instId: String
    let baseCcy: String
    let quoteCcy: String
    let state: String
    let instType: String?

    enum CodingKeys: String, CodingKey {
        case instId
        case baseCcy
        case quoteCcy
        case state
        case instType
    }
}
