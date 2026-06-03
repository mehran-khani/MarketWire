import ComposableArchitecture
import SwiftUI

struct AssetDetailView: View {
    let store: StoreOf<AssetDetailFeature>
    let connectionState: ConnectionState

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var presentation: TickerSnapshot.Presentation {
        TickerSnapshot.presentation(for: store.ticker)
    }

    private var isWaitingForLivePrice: Bool {
        store.ticker == nil
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(store.symbolID)
                    .font(.largeTitle.weight(.semibold))
                    .fontDesign(.serif)
                    .accessibilityIdentifier("asset-detail-title")

                connectionStatusRow

                priceCard

                Text("Live charts, trades, and order book ship in a later phase.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .accessibilityElement(children: .contain)
    }

    private var connectionStatusRow: some View {
        ConnectionStatusLabel(
            text: connectionState.livePriceStatusLabel,
            connectionState: connectionState
        )
        .accessibilityIdentifier("asset-detail-connection-status")
    }

    private var priceCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Last price")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if isWaitingForLivePrice {
                HStack(spacing: 8) {
                    ProgressView()
                        .controlSize(.small)
                    Text(connectionState.livePriceLoadingLabel)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .accessibilityLabel(detailPriceAccessibilityLabel)
            } else {
                Text(presentation.priceText)
                    .font(.system(.title, design: .rounded, weight: .semibold))
                    .monospacedDigit()
                    .contentTransition(.numericText(value: presentation.priceNumericValue))
                    .animation(reduceMotion ? nil : .bouncy, value: presentation.snapshotPrice)
                    .accessibilityLabel(detailPriceAccessibilityLabel)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.regularMaterial, in: .rect(cornerRadius: 12))
        .accessibilityIdentifier("asset-detail-price-card")
    }

    private var detailPriceAccessibilityLabel: String {
        if isWaitingForLivePrice {
            return "\(store.symbolID), \(connectionState.livePriceAccessibilityHint)"
        }
        return "\(store.symbolID), \(presentation.accessibilitySummary)"
    }
}
