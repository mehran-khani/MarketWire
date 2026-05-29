struct CoinbaseMatchDTO: Decodable {
    let tradeID: Int
    let sequence: Int?
    let productID: String
    let size: String
    let price: String
    let side: String
    let time: String

    enum CodingKeys: String, CodingKey {
        case tradeID = "trade_id"
        case sequence
        case productID = "product_id"
        case size
        case price
        case side
        case time
    }
}
