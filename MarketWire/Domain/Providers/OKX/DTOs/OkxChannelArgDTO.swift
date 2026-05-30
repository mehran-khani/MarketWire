nonisolated struct OkxChannelArgDTO: Decodable, Equatable, Sendable {
    let channel: String
    let instId: String?

    enum CodingKeys: String, CodingKey {
        case channel
        case instId
    }
}
