nonisolated struct OkxTradePushDTO: Decodable, Equatable, Sendable {
    let arg: OkxChannelArgDTO
    let data: [OkxTradeDTO]

    enum CodingKeys: String, CodingKey {
        case arg
        case data
    }
}
