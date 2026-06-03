import SwiftUI

struct TickerCard: View {
    let symbolID: Symbol.ID
    let ticker: TickerSnapshot?
    let marketTicker: MarketTicker?
    let connectionState: ConnectionState
    let isLoadingPrice: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(
        symbolID: Symbol.ID,
        ticker: TickerSnapshot?,
        connectionState: ConnectionState,
        marketTicker: MarketTicker? = nil,
        isLoadingPrice: Bool = false
    ) {
        self.symbolID = symbolID
        self.ticker = ticker
        self.marketTicker = marketTicker
        self.connectionState = connectionState
        self.isLoadingPrice = isLoadingPrice
    }

    private var presentation: TickerSnapshot.Presentation {
        if let marketTicker {
            MarketTicker.presentation(for: marketTicker)
        } else {
            TickerSnapshot.presentation(for: ticker)
        }
    }

    private var symbolLabels: (base: String, quote: String) {
        Symbol.cardLabels(for: symbolID)
    }

    private var isWaitingForPrice: Bool {
        if isLoadingPrice {
            return true
        }
        if marketTicker != nil {
            return false
        }
        guard ticker == nil else { return false }
        switch connectionState {
        case .idle:
            return false
        case .connecting, .connected, .disconnected, .failed:
            return true
        }
    }

    private var usesLivePrice: Bool {
        marketTicker == nil
    }

    private var reservesFreshnessLine: Bool {
        marketTicker != nil || isLoadingPrice
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerRow
                .padding(.bottom, 14)

            priceSection
        }
        .padding(MarketMetrics.cardPadding)
        .marketElevatedSurface(cornerRadius: MarketMetrics.cardCornerRadius)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilitySummary)
    }

    private var headerRow: some View {
        HStack(alignment: .center, spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(symbolLabels.base)
                        .font(.headline.weight(.semibold))
                        .fontDesign(.rounded)

                    if !symbolLabels.quote.isEmpty {
                        Text("/\(symbolLabels.quote)")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)
                    }
                }

                Text(symbolID)
                    .font(.caption2.weight(.medium))
                    .fontDesign(.monospaced)
                    .foregroundStyle(.tertiary)

                if reservesFreshnessLine {
                    freshnessCaptionLine
                }
            }

            Spacer(minLength: 8)

            change24hBadge

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.quaternary)
                .accessibilityHidden(true)
        }
    }

    @ViewBuilder
    private var priceSection: some View {
        if isWaitingForPrice {
            HStack(spacing: 8) {
                ProgressView()
                    .controlSize(.small)
                Text(loadingPriceLabel)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityLabel(loadingPriceAccessibilityLabel)
        } else {
            Text(presentation.priceText)
                .font(.system(.title, design: .rounded, weight: .semibold))
                .monospacedDigit()
                .contentTransition(.numericText(value: presentation.priceNumericValue))
                .animation(reduceMotion ? nil : .bouncy, value: presentation.snapshotPrice)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private var change24hBadge: some View {
        if let changeText = presentation.changePercentText,
           let isUp = presentation.isUp24h,
           let changeValue = presentation.changeNumericValue
        {
            HStack(spacing: 4) {
                Image(systemName: isUp ? "arrow.up.right" : "arrow.down.right")
                    .font(.caption2.weight(.bold))
                Text(changeText)
                    .font(.caption.weight(.semibold))
                    .monospacedDigit()
            }
            .foregroundStyle(isUp ? .green : .red)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(
                (isUp ? Color.green : Color.red).opacity(0.12),
                in: Capsule()
            )
            .contentTransition(.numericText(value: changeValue))
            .animation(reduceMotion ? nil : .smooth, value: presentation.snapshotPrice)
        } else if !isWaitingForPrice {
            Text("—")
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(Color.secondary.opacity(0.08), in: Capsule())
        }
    }

    private var freshnessCaptionLine: some View {
        Text(freshnessCaption ?? " ")
            .font(.caption2)
            .foregroundStyle(freshnessCaptionStyle)
            .opacity(freshnessCaption == nil ? 0 : 1)
            .accessibilityHidden(freshnessCaption == nil)
            .animation(reduceMotion ? nil : .smooth, value: freshnessCaption)
    }

    private var loadingPriceLabel: String {
        if isLoadingPrice {
            return "Loading price…"
        }
        return connectionState.livePriceLoadingLabel
    }

    private var loadingPriceAccessibilityLabel: String {
        if isLoadingPrice {
            return "Loading price"
        }
        return connectionState.livePriceAccessibilityHint
    }

    private var freshnessCaption: String? {
        guard let marketTicker else { return nil }
        let now = Date()
        guard QuoteFreshness.isCatalogStale(since: marketTicker.updatedAt, now: now) else { return nil }
        return "Stale · \(QuoteFreshness.relativeAgeDescription(since: marketTicker.updatedAt, now: now))"
    }

    private var freshnessCaptionStyle: Color {
        guard let marketTicker else { return .secondary }
        return QuoteFreshness.isCatalogStale(since: marketTicker.updatedAt, now: Date())
            ? .orange
            : .secondary
    }

    private var accessibilitySummary: String {
        var parts = [symbolID]
        if isWaitingForPrice {
            parts.append(loadingPriceAccessibilityLabel)
            if usesLivePrice {
                parts.append(connectionState.livePriceStatusLabel.lowercased())
            }
        } else {
            parts.append(presentation.accessibilitySummary)
            if let marketTicker {
                parts.append(
                    QuoteFreshness.rowAccessibilityFragment(
                        updatedAt: marketTicker.updatedAt,
                        now: Date()
                    )
                )
            }
        }
        return parts.joined(separator: ", ")
    }
}
