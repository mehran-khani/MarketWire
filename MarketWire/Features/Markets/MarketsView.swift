import ComposableArchitecture
import SwiftUI

struct MarketsView: View {
    @Bindable var store: StoreOf<MarketsFeature>
    let connectionState: ConnectionState

    var body: some View {
        Group {
            switch store.loadState {
            case .idle, .loading:
                loadingBody

            case let .failed(message):
                failedBody(message: message)

            case .loaded:
                catalogBody
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task {
            store.send(.catalogAppeared)
        }
    }

    private var loadingBody: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Loading spot markets…")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityIdentifier("markets-loading")
    }

    private func failedBody(message: String) -> some View {
        VStack(spacing: 16) {
            Text("Couldn’t load markets")
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Try again") {
                store.send(.catalogAppeared)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .accessibilityIdentifier("markets-load-failed")
    }

    @ViewBuilder
    private var catalogBody: some View {
        if store.instruments.isEmpty {
            ContentUnavailableView(
                "No spot markets",
                systemImage: "chart.line.uptrend.xyaxis",
                description: Text("OKX returned an empty instrument list.")
            )
        } else if store.filteredInstruments.isEmpty {
            ContentUnavailableView.search(text: store.searchQuery)
        } else {
            List {
                Section {
                    Text("Tap a pair for detail. Live stream prices appear when subscribed.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .listRowBackground(Color.clear)
                }

                Section {
                    ForEach(store.filteredInstruments) { symbol in
                        Button {
                            store.send(.symbolTapped(symbol.id))
                        } label: {
                            TickerCard(
                                symbolID: symbol.id,
                                ticker: store.tickerBySymbolID[symbol.id],
                                connectionState: connectionState
                            )
                        }
                        .buttonStyle(.plain)
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .accessibilityIdentifier("market-row-\(symbol.id)")
                    }
                }
            }
            .listStyle(.plain)
            .searchable(text: $store.searchQuery, prompt: "Search symbol or currency")
            .accessibilityIdentifier("markets-catalog-list")
        }
    }
}
