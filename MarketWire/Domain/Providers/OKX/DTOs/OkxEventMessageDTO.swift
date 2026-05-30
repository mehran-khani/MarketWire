nonisolated struct OkxEventMessageDTO: Decodable, Equatable, Sendable {
    let id: String?
    let event: String
    let arg: OkxChannelArgDTO?
    let code: String?
    let msg: String?
    let connId: String?

    enum CodingKeys: String, CodingKey {
        case id
        case event
        case arg
        case code
        case msg
        case connId
    }
}
