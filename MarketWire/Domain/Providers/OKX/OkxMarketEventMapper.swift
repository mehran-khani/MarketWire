nonisolated enum OkxMarketEventMapper {
    static func events(from message: OkxInboundMessage) -> [MarketEvent] {
        switch message {
        case let .subscribed(dto):
            return [.subscribed(channels: subscribedChannels(from: dto))]

        case .unsubscribed:
            return []

        case let .error(dto):
            return [.providerError(message: providerErrorMessage(from: dto))]

        case let .notice(dto):
            return [.providerError(message: providerErrorMessage(from: dto))]

        case let .tickers(dto):
            return dto.data.compactMap { tickerEvent(from: $0) }

        case let .trades(dto):
            return dto.data.compactMap { tradeEvent(from: $0) }

        case .unsupported:
            return []
        }
    }

    static func event(from message: OkxInboundMessage) -> MarketEvent? {
        events(from: message).first
    }

    private static func subscribedChannels(from dto: OkxEventMessageDTO) -> [String] {
        guard let arg = dto.arg else {
            return []
        }
        if let instId = arg.instId {
            return ["\(arg.channel):\(instId)"]
        }
        return [arg.channel]
    }

    private static func providerErrorMessage(from dto: OkxEventMessageDTO) -> String {
        if let msg = dto.msg, !msg.isEmpty {
            if let code = dto.code, !code.isEmpty {
                return "\(code): \(msg)"
            }
            return msg
        }
        return dto.code ?? "Unknown OKX error"
    }

    private static func tickerEvent(from dto: OkxTickerDTO) -> MarketEvent? {
        guard let price = WireParsing.decimal(dto.last),
              let time = WireParsing.millisTimestamp(dto.ts)
        else {
            return nil
        }

        return .ticker(
            TickerSnapshot(
                symbolID: dto.instId,
                price: price,
                open24h: WireParsing.decimal(dto.open24h),
                high24h: WireParsing.decimal(dto.high24h),
                low24h: WireParsing.decimal(dto.low24h),
                volume24h: WireParsing.decimal(dto.vol24h),
                bestBid: WireParsing.decimal(dto.bidPx),
                bestAsk: WireParsing.decimal(dto.askPx),
                lastSize: WireParsing.decimal(dto.lastSz),
                side: nil,
                time: time
            )
        )
    }

    private static func tradeEvent(from dto: OkxTradeDTO) -> MarketEvent? {
        guard let price = WireParsing.decimal(dto.px),
              let size = WireParsing.decimal(dto.sz),
              let side = TradeSide(rawValue: dto.side.lowercased()),
              let time = WireParsing.millisTimestamp(dto.ts)
        else {
            return nil
        }

        return .trade(
            Trade(
                id: WireParsing.tradeID(dto.tradeId),
                symbolID: dto.instId,
                price: price,
                size: size,
                side: side,
                time: time
            )
        )
    }
}
