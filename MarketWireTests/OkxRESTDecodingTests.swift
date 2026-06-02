import Foundation
@testable import MarketWire
import Testing

struct OkxRESTDecodingTests {
    private let decoder = JSONDecoder()

    @Test func decodesSpotInstrumentsEnvelope() throws {
        let response = try decodeInstruments("okx_rest_instruments")
        #expect(response.isSuccess)
        #expect(response.data.count == 3)
        #expect(response.data[0].instId == "BTC-USDT")
        #expect(response.data[0].baseCcy == "BTC")
        #expect(response.data[0].quoteCcy == "USDT")
        #expect(response.data[0].state == "live")
    }

    @Test func decodesSpotMarketTickersEnvelope() throws {
        let response = try decodeTickers("okx_rest_tickers")
        #expect(response.isSuccess)
        #expect(response.data.count == 2)
        #expect(response.data[0].instId == "BTC-USDT")
        #expect(response.data[0].last == "73692.1")
        #expect(response.data[1].instId == "ETH-USDT")
    }

    @Test func mapsLiveInstrumentsToSymbols() throws {
        let response = try decodeInstruments("okx_rest_instruments")
        let symbols = OkxRESTMapper.symbols(from: response.data)

        #expect(symbols.count == 2)
        #expect(symbols.map(\.id) == ["BTC-USDT", "ETH-USDT"])
        #expect(symbols[0].base == "BTC")
        #expect(symbols[0].quote == "USDT")
    }

    @Test func mapsMarketTickersFromRESTPayload() throws {
        let response = try decodeTickers("okx_rest_tickers")
        let tickers = OkxRESTMapper.marketTickers(from: response.data)

        #expect(tickers.count == 2)
        let btc = try #require(tickers["BTC-USDT"])
        #expect(btc.lastPrice == Decimal(string: "73692.1", locale: WireParsing.posix))
        #expect(btc.open24h == Decimal(string: "73600.1", locale: WireParsing.posix))
        #expect(btc.high24h == Decimal(string: "74335", locale: WireParsing.posix))
        #expect(btc.low24h == Decimal(string: "72508", locale: WireParsing.posix))
    }

    private func decodeInstruments(_ name: String) throws -> OkxRESTResponseDTO<[OkxInstrumentDTO]> {
        let data = try Fixture.data(name, provider: .okx)
        return try decoder.decode(OkxRESTResponseDTO<[OkxInstrumentDTO]>.self, from: data)
    }

    private func decodeTickers(_ name: String) throws -> OkxRESTResponseDTO<[OkxTickerDTO]> {
        let data = try Fixture.data(name, provider: .okx)
        return try decoder.decode(OkxRESTResponseDTO<[OkxTickerDTO]>.self, from: data)
    }
}
