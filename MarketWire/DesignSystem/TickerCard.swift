import SwiftUI

struct TickerCard: View {
    let symbolID: Symbol.ID
    let ticker: TickerSnapshot?
    let connectionState: ConnectionState

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var presentation: TickerSnapshot.Presentation {
        TickerSnapshot.presentation(for: ticker)
    }

    private var symbolLabels: (base: String, quote: String) {
        Symbol.cardLabels(for: symbolID)
    }

    private var isWaitingForPrice: Bool {
        ticker == nil && connectionState == .connecting
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
                Text("Connecting…")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityLabel("Waiting for live price")
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
           let changeValue = presentation.changeNumericValue {
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

    private var accessibilitySummary: String {
        var parts = [symbolID]
        if isWaitingForPrice {
            parts.append("waiting for live price")
        } else {
            parts.append(presentation.accessibilitySummary)
        }
        return parts.joined(separator: ", ")
    }
}
