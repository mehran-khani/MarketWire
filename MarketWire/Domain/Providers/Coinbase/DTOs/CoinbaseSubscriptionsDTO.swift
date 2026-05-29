struct CoinbaseSubscriptionsDTO: Decodable {
    struct Channel: Decodable {
        let name: String
        let productIDs: [String]

        enum CodingKeys: String, CodingKey {
            case name
            case productIDs = "product_ids"
        }
    }

    let channels: [Channel]
}
