struct CoinbaseTickerDTO: Decodable {
    let sequence: Int?
    let productID: String
    let price: String
    let open24h: String?
    let volume24h: String?
    let low24h: String?
    let high24h: String?
    let bestBid: String?
    let bestAsk: String?
    let side: String?
    let time: String
    let tradeID: Int?
    let lastSize: String?

    enum CodingKeys: String, CodingKey {
        case sequence
        case productID = "product_id"
        case price
        case open24h = "open_24h"
        case volume24h = "volume_24h"
        case low24h = "low_24h"
        case high24h = "high_24h"
        case bestBid = "best_bid"
        case bestAsk = "best_ask"
        case side
        case time
        case tradeID = "trade_id"
        case lastSize = "last_size"
    }
}
