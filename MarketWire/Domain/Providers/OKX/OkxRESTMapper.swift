import Foundation

nonisolated enum OkxRESTMapper {
    static func symbols(from instruments: [OkxInstrumentDTO]) -> [Symbol] {
        instruments
            .filter { $0.state == "live" }
            .map { instrument in
                Symbol(
                    id: instrument.instId,
                    base: instrument.baseCcy,
                    quote: instrument.quoteCcy
                )
            }
            .sorted { $0.id.localizedCaseInsensitiveCompare($1.id) == .orderedAscending }
    }

    static func marketTickers(from tickers: [OkxTickerDTO]) -> [Symbol.ID: MarketTicker] {
        var result: [Symbol.ID: MarketTicker] = [:]
        result.reserveCapacity(tickers.count)

        for ticker in tickers {
            guard let marketTicker = marketTicker(from: ticker) else { continue }
            result[marketTicker.symbolID] = marketTicker
        }

        return result
    }

    private static func marketTicker(from dto: OkxTickerDTO) -> MarketTicker? {
        guard let lastPrice = WireParsing.decimal(dto.last),
              let updatedAt = WireParsing.millisTimestamp(dto.ts)
        else {
            return nil
        }

        return MarketTicker(
            symbolID: dto.instId,
            lastPrice: lastPrice,
            open24h: WireParsing.decimal(dto.open24h),
            high24h: WireParsing.decimal(dto.high24h),
            low24h: WireParsing.decimal(dto.low24h),
            updatedAt: updatedAt
        )
    }
}
