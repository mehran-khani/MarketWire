import Foundation
@testable import MarketWire
import Testing

@Suite(.serialized)
struct OKXRESTClientTests {
    @Test func fetchSpotInstrumentsUsesMockSession() async throws {
        let session = makeMockSession { request in
            guard request.url?.path == "/api/v5/public/instruments" else {
                throw URLError(.unsupportedURL)
            }
            let data = try Fixture.data("okx_rest_instruments", provider: .okx)
            return try mockResponse(for: request, data: data)
        }

        let client = OKXRESTClient(session: session)
        let symbols = try await client.fetchSpotInstruments()

        #expect(symbols.count == 2)
        #expect(symbols[0].id == "BTC-USDT")
    }

    @Test func fetchSpotMarketTickersUsesMockSession() async throws {
        let session = makeMockSession { request in
            guard request.url?.path == "/api/v5/market/tickers" else {
                throw URLError(.unsupportedURL)
            }
            let data = try Fixture.data("okx_rest_tickers", provider: .okx)
            return try mockResponse(for: request, data: data)
        }

        let client = OKXRESTClient(session: session)
        let tickers = try await client.fetchSpotMarketTickers()

        #expect(tickers.count == 2)
        #expect(tickers["BTC-USDT"] != nil)
    }

    private func makeMockSession(
        handler: @escaping @Sendable (URLRequest) throws -> (HTTPURLResponse, Data)
    ) -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        MockURLProtocol.requestHandler = handler
        return URLSession(configuration: configuration)
    }

    private func mockResponse(for request: URLRequest, data: Data) throws -> (HTTPURLResponse, Data) {
        let url = try #require(request.url)
        let response = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        return (response, data)
    }
}

private final class MockURLProtocol: URLProtocol, @unchecked Sendable {
    nonisolated(unsafe) static var requestHandler: (@Sendable (URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = Self.requestHandler else {
            client?.urlProtocol(self, didFailWithError: URLError(.unsupportedURL))
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
