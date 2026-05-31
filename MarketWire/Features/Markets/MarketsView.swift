import ComposableArchitecture
import SwiftUI

struct MarketsView: View {
    let store: StoreOf<MarketsFeature>
    let connectionState: ConnectionState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Live prices from the OKX stream. Tap a pair for detail.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                ForEach(store.symbols, id: \.self) { symbolID in
                    Button {
                        store.send(.symbolTapped(symbolID))
                    } label: {
                        MarketSymbolRow(
                            symbolID: symbolID,
                            ticker: store.tickerBySymbolID[symbolID],
                            connectionState: connectionState
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("market-row-\(symbolID)")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
    }
}

private struct MarketSymbolRow: View {
    let symbolID: Symbol.ID
    let ticker: TickerSnapshot?
    let connectionState: ConnectionState

    private var isWaitingForPrice: Bool {
        ticker == nil && connectionState == .connecting
    }

    var body: some View {
        HStack {
            Text(symbolID)
                .font(.headline)
            Spacer()
            if isWaitingForPrice {
                ProgressView()
                    .controlSize(.small)
                    .accessibilityLabel("Waiting for live price")
            } else {
                Text(ticker.displayPriceOrPlaceholder)
                    .font(.headline.monospacedDigit())
                    .foregroundStyle(.primary)
                    .contentTransition(.numericText(value: ticker.numericTextValue))
                    .animation(.bouncy, value: ticker?.price)
            }
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background(.regularMaterial, in: .rect(cornerRadius: 12))
    }
}
