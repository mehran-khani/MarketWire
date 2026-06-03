import ComposableArchitecture
import SwiftUI

struct MarketsView: View {
    @Bindable var store: StoreOf<MarketsFeature>
    let favoriteSymbolIDs: Set<Symbol.ID>
    let isQuotePollingActive: Bool

    @State private var searchText = ""
    @State private var searchDebounceTask: Task<Void, Never>?

    @Environment(\.dismissSearch) private var dismissSearch

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
        .onAppear {
            searchText = store.filterQuery
        }
        .onChange(of: store.filterQuery) { _, filterQuery in
            if searchText != filterQuery {
                searchText = filterQuery
            }
        }
        .onDisappear {
            searchDebounceTask?.cancel()
        }
        .task(id: isQuotePollingActive) {
            store.send(.setQuotePollingActive(isQuotePollingActive))
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

    private var catalogBody: some View {
        List {
            if store.instruments.isEmpty {
                EmptyView()
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            } else if !store.filteredInstruments.isEmpty {
                Section {
                    ForEach(store.filteredInstruments) { symbol in
                        TickerCard(
                            symbolID: symbol.id,
                            ticker: nil,
                            connectionState: .idle,
                            marketTicker: store.marketTickerBySymbolID[symbol.id],
                            isLoadingPrice: isRowLoadingPrice(for: symbol.id)
                        )
                        .tickerCardFavoriteListRow(
                            isFavorite: favoriteSymbolIDs.contains(symbol.id),
                            accessibilityIdentifier: "market-row-\(symbol.id)",
                            onSelect: { openSymbol(symbol.id) },
                            onFavoriteToggle: { store.send(.favoriteToggled(symbol.id)) }
                        )
                    }
                }
            }
        }
        .listStyle(.plain)
        .marketContentScrollEdgeEffects()
        .safeAreaInset(edge: .top, spacing: 0) {
            catalogAttentionBanner
        }
        .searchable(text: $searchText, prompt: "Search symbol or currency")
        .onChange(of: searchText) { _, newValue in
            scheduleSearchFilterCommit(for: newValue)
        }
        .overlay {
            if store.instruments.isEmpty {
                ContentUnavailableView(
                    "No spot markets",
                    systemImage: "chart.line.uptrend.xyaxis",
                    description: Text("OKX returned an empty instrument list.")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .allowsHitTesting(false)
            } else if store.isSearchActive, store.filteredInstruments.isEmpty {
                ContentUnavailableView.search(text: searchText)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .accessibilityIdentifier("markets-search-empty")
                    .allowsHitTesting(false)
            }
        }
        .accessibilityIdentifier("markets-catalog-list")
    }

    private func scheduleSearchFilterCommit(for query: String) {
        searchDebounceTask?.cancel()

        if query.isEmpty {
            store.send(.searchFilterCommitted(""))
            return
        }

        searchDebounceTask = Task {
            try? await Task.sleep(for: .milliseconds(200))
            guard !Task.isCancelled else { return }
            store.send(.searchFilterCommitted(query))
        }
    }

    private func openSymbol(_ symbolID: Symbol.ID) {
        commitSearchImmediately(searchText)
        dismissSearch()
        store.send(.symbolTapped(symbolID))
    }

    private func commitSearchImmediately(_ query: String) {
        searchDebounceTask?.cancel()
        if store.filterQuery != query {
            store.send(.searchFilterCommitted(query))
        }
    }

    private func isRowLoadingPrice(for symbolID: Symbol.ID) -> Bool {
        store.marketTickerBySymbolID[symbolID] == nil && store.quoteRefreshState == .loading
    }

    @ViewBuilder
    private var catalogAttentionBanner: some View {
        if case let .failed(message) = store.quoteRefreshState {
            catalogAttentionLabel("Couldn't refresh prices · \(message)")
        } else if let quotesUpdatedAt = store.quotesUpdatedAt {
            TimelineView(.periodic(from: .now, by: 1)) { context in
                if let message = QuoteFreshness.catalogAttentionMessage(
                    since: quotesUpdatedAt,
                    now: context.date
                ) {
                    catalogAttentionLabel(message)
                }
            }
        }
    }

    private func catalogAttentionLabel(_ message: String) -> some View {
        Text(message)
            .font(.caption.weight(.medium))
            .foregroundStyle(.orange)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(.regularMaterial)
            .accessibilityIdentifier("markets-quote-attention")
    }
}
