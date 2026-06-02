import ComposableArchitecture
import SwiftUI

struct MarketsView: View {
    let store: StoreOf<MarketsFeature>
    let connectionState: ConnectionState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Live prices from the OKX stream. Tap a pair for detail.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                VStack(spacing: 12) {
                    ForEach(store.symbols, id: \.self) { symbolID in
                        Button {
                            store.send(.symbolTapped(symbolID))
                        } label: {
                            TickerCard(
                                symbolID: symbolID,
                                ticker: store.tickerBySymbolID[symbolID],
                                connectionState: connectionState
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("market-row-\(symbolID)")
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
    }
}
