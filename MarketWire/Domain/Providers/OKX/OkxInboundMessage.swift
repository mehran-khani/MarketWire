nonisolated enum OkxInboundMessage: Decodable, Equatable, Sendable {
    case subscribed(OkxEventMessageDTO)
    case unsubscribed(OkxEventMessageDTO)
    case error(OkxEventMessageDTO)
    case notice(OkxEventMessageDTO)
    case tickers(OkxTickerPushDTO)
    case trades(OkxTradePushDTO)
    case unsupported

    private enum CodingKeys: String, CodingKey {
        case event
        case data
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.contains(.event) {
            let eventMessage = try OkxEventMessageDTO(from: decoder)
            switch eventMessage.event {
            case "subscribe":
                self = .subscribed(eventMessage)
            case "unsubscribe":
                self = .unsubscribed(eventMessage)
            case "error":
                self = .error(eventMessage)
            case "notice":
                self = .notice(eventMessage)
            default:
                self = .unsupported
            }
            return
        }

        if container.contains(.data) {
            let argContainer = try decoder.container(keyedBy: ArgCodingKeys.self)
            let arg = try argContainer.decode(OkxChannelArgDTO.self, forKey: .arg)
            switch arg.channel {
            case "tickers":
                self = try .tickers(OkxTickerPushDTO(from: decoder))
            case "trades":
                self = try .trades(OkxTradePushDTO(from: decoder))
            default:
                self = .unsupported
            }
            return
        }

        self = .unsupported
    }

    private enum ArgCodingKeys: String, CodingKey {
        case arg
    }
}
