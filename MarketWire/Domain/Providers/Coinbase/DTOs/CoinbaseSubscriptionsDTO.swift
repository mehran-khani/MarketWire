nonisolated struct CoinbaseSubscriptionsDTO: Decodable, Equatable, Sendable {
    nonisolated struct Channel: Decodable, Equatable, Sendable {
        let name: String
        let productIDs: [String]

        enum CodingKeys: String, CodingKey {
            case name
            case productIDs = "product_ids"
        }
    }

    let channels: [Channel]
}
