// swiftlint:disable identifier_name
nonisolated struct OkxTradeDTO: Decodable, Equatable, Sendable {
    let instId: String
    let tradeId: String
    let px: String
    let sz: String
    let side: String
    let ts: String
    let count: String?
    let source: String?
    let seqId: Int?

    enum CodingKeys: String, CodingKey {
        case instId
        case tradeId
        case px
        case sz
        case side
        case ts
        case count
        case source
        case seqId
    }
}
// swiftlint:enable identifier_name
