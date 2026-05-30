nonisolated struct CoinbaseErrorDTO: Decodable, Equatable, Sendable {
    let message: String
    let reason: String?
}
