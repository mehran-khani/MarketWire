nonisolated struct CoinbaseHeartbeatDTO: Decodable, Equatable, Sendable {
    let sequence: Int?
    let lastTradeID: Int?
    let productID: String
    let time: String

    enum CodingKeys: String, CodingKey {
        case sequence
        case lastTradeID = "last_trade_id"
        case productID = "product_id"
        case time
    }
}
