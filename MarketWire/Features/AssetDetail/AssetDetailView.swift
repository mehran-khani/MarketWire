import ComposableArchitecture
import SwiftUI

struct AssetDetailView: View {
    let store: StoreOf<AssetDetailFeature>

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var presentation: TickerSnapshot.Presentation {
        TickerSnapshot.presentation(for: store.ticker)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(store.symbolID)
                    .font(.largeTitle.weight(.semibold))
                    .fontDesign(.serif)
                    .accessibilityIdentifier("asset-detail-title")

                VStack(alignment: .leading, spacing: 8) {
                    Text("Last price")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(presentation.priceText)
                        .font(.system(.title, design: .rounded, weight: .semibold))
                        .monospacedDigit()
                        .contentTransition(.numericText(value: presentation.priceNumericValue))
                        .animation(reduceMotion ? nil : .bouncy, value: presentation.snapshotPrice)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(.regularMaterial, in: .rect(cornerRadius: 12))

                Text("Live charts, trades, and order book ship in a later phase.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
    }
}
