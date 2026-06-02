import Foundation

enum OKXRESTError: Error, Sendable, LocalizedError {
    case invalidURL
    case httpStatus(Int)
    case apiError(code: String, message: String?)
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid OKX REST URL."
        case let .httpStatus(status):
            return "OKX REST request failed with status \(status)."
        case let .apiError(code, message):
            if let message, !message.isEmpty {
                return "OKX API error \(code): \(message)"
            }
            return "OKX API error \(code)."
        case .decodingFailed:
            return "Failed to decode OKX REST response."
        }
    }
}

nonisolated struct OKXRESTClient: Sendable {
    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder

    init(
        baseURL: URL = OKXConfiguration.publicRESTURL,
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.session = session
        decoder = JSONDecoder()
    }

    func fetchSpotInstruments() async throws -> [Symbol] {
        let response: OkxRESTResponseDTO<[OkxInstrumentDTO]> = try await get(
            path: "/api/v5/public/instruments",
            queryItems: [URLQueryItem(name: "instType", value: "SPOT")]
        )
        return OkxRESTMapper.symbols(from: response.data)
    }

    func fetchSpotMarketTickers() async throws -> [Symbol.ID: MarketTicker] {
        let response: OkxRESTResponseDTO<[OkxTickerDTO]> = try await get(
            path: "/api/v5/market/tickers",
            queryItems: [URLQueryItem(name: "instType", value: "SPOT")]
        )
        return OkxRESTMapper.marketTickers(from: response.data)
    }

    private func get<Response: Decodable & Sendable>(
        path: String,
        queryItems: [URLQueryItem]
    ) async throws -> OkxRESTResponseDTO<Response> {
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            throw OKXRESTError.invalidURL
        }
        components.path = path
        components.queryItems = queryItems

        guard let url = components.url else {
            throw OKXRESTError.invalidURL
        }

        let (data, response) = try await session.data(from: url)
        if let http = response as? HTTPURLResponse, !(200 ... 299).contains(http.statusCode) {
            throw OKXRESTError.httpStatus(http.statusCode)
        }

        let envelope: OkxRESTResponseDTO<Response>
        do {
            envelope = try decoder.decode(OkxRESTResponseDTO<Response>.self, from: data)
        } catch {
            throw OKXRESTError.decodingFailed
        }

        guard envelope.isSuccess else {
            throw OKXRESTError.apiError(code: envelope.code, message: envelope.msg)
        }

        return envelope
    }
}
