import ComposableArchitecture
import SwiftUI

struct AssetDetailView: View {
    let store: StoreOf<AssetDetailFeature>

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
                    Text(store.ticker.displayPriceOrPlaceholder)
                        .font(.system(.title, design: .rounded, weight: .semibold))
                        .monospacedDigit()
                        .contentTransition(.numericText(value: store.ticker.numericTextValue))
                        .animation(.bouncy, value: store.ticker?.price)
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
