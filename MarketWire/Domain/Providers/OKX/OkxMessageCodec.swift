import Foundation

nonisolated enum OkxMessageCodec {
    static func decode(_ data: Data) throws -> OkxInboundMessage {
        try JSONDecoder().decode(OkxInboundMessage.self, from: data)
    }

    static func marketEvents(from data: Data) throws -> [MarketEvent] {
        try OkxMarketEventMapper.events(from: decode(data))
    }

    static func marketEvent(from data: Data) throws -> MarketEvent? {
        try OkxMarketEventMapper.event(from: decode(data))
    }

    static func encodeSubscribe(to args: [OkxSubscribeArg], id: String? = nil) throws -> String {
        let request = OkxSubscribeRequest(id: id, op: "subscribe", args: args)
        let data = try JSONEncoder().encode(request)
        guard let text = String(data: data, encoding: .utf8) else {
            throw OkxMessageCodecError.encodingFailed
        }
        return text
    }
}

enum OkxMessageCodecError: Error, Sendable {
    case encodingFailed
}
