nonisolated enum CoinbaseInboundMessage: Decodable, Equatable, Sendable {
    case subscriptions(CoinbaseSubscriptionsDTO)
    case ticker(CoinbaseTickerDTO)
    case match(CoinbaseMatchDTO)
    case heartbeat(CoinbaseHeartbeatDTO)
    case error(CoinbaseErrorDTO)
    case unsupported(type: String)

    private enum CodingKeys: String, CodingKey {
        case type
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "subscriptions":
            self = .subscriptions(try CoinbaseSubscriptionsDTO(from: decoder))
        case "ticker":
            self = .ticker(try CoinbaseTickerDTO(from: decoder))
        case "match", "last_match":
            self = .match(try CoinbaseMatchDTO(from: decoder))
        case "heartbeat":
            self = .heartbeat(try CoinbaseHeartbeatDTO(from: decoder))
        case "error":
            self = .error(try CoinbaseErrorDTO(from: decoder))
        default:
            self = .unsupported(type: type)
        }
    }
}
