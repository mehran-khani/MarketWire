// swiftlint:disable identifier_name
nonisolated struct OkxTickerDTO: Decodable, Equatable, Sendable {
    let instType: String?
    let instId: String
    let last: String
    let lastSz: String?
    let askPx: String?
    let askSz: String?
    let bidPx: String?
    let bidSz: String?
    let open24h: String?
    let high24h: String?
    let low24h: String?
    let volCcy24h: String?
    let vol24h: String?
    let ts: String

    enum CodingKeys: String, CodingKey {
        case instType
        case instId
        case last
        case lastSz
        case askPx
        case askSz
        case bidPx
        case bidSz
        case open24h
        case high24h
        case low24h
        case volCcy24h
        case vol24h
        case ts
    }
}
// swiftlint:enable identifier_name
