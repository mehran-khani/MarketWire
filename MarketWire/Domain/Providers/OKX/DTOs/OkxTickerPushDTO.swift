nonisolated struct OkxTickerPushDTO: Decodable, Equatable, Sendable {
    let arg: OkxChannelArgDTO
    let data: [OkxTickerDTO]

    enum CodingKeys: String, CodingKey {
        case arg
        case data
    }
}
