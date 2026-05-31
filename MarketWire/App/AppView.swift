import ComposableArchitecture
import SwiftUI

private enum SidebarSection: String, CaseIterable, Hashable, Identifiable {
    case watchlist
    case markets
    case alerts

    var id: String { rawValue }

    var title: String {
        switch self {
        case .watchlist: "Watchlist"
        case .markets: "Markets"
        case .alerts: "Alerts"
        }
    }

    var systemImage: String {
        switch self {
        case .watchlist: "star"
        case .markets: "chart.line.uptrend.xyaxis"
        case .alerts: "bell"
        }
    }
}

struct AppView: View {
    @Bindable var store: StoreOf<AppFeature>
    @State private var selectedSection: SidebarSection? = .markets

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedSection) {
                ForEach(SidebarSection.allCases) { section in
                    NavigationLink(value: section) {
                        Label(section.title, systemImage: section.systemImage)
                    }
                }
            }
            .navigationTitle("MarketWire")
        } detail: {
            Group {
                switch selectedSection {
                case .markets:
                    marketsDebugDetail
                case .watchlist:
                    sectionPlaceholder(
                        title: "Watchlist",
                        subtitle: "Favorites will appear here in a later phase."
                    )
                case .alerts:
                    sectionPlaceholder(
                        title: "Alerts",
                        subtitle: "Price alerts will appear here in a later phase."
                    )
                case .none:
                    sectionPlaceholder(
                        title: "MarketWire",
                        subtitle: "Select a section from the sidebar."
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var marketsDebugDetail: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Markets")
                    .font(.largeTitle.weight(.semibold))
                    .fontDesign(.serif)

                Text("Live stream debug (BTC-USDT)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 12) {
                    Label(connectionLabel, systemImage: connectionSymbol)
                        .font(.headline)
                        .foregroundStyle(connectionColor)

                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text("BTC-USDT")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(debugPriceText)
                            .font(.title.monospacedDigit().weight(.semibold))
                            .contentTransition(.numericText(value: Double(debugPriceText) ?? Double(1)))
                            .animation(.bouncy, value: debugPriceText)
                    }

                    if let lastError = store.lastError {
                        Text(lastError)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(.regularMaterial, in: .rect(cornerRadius: 12))
            }
            .padding()
        }
        .onAppear {
            store.send(.appStarted)
        }
    }

    private func sectionPlaceholder(title: String, subtitle: String) -> some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.largeTitle.weight(.semibold))
                .fontDesign(.serif)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    private var connectionLabel: String {
        switch store.connectionState {
        case .idle:
            "Idle"
        case .connecting:
            "Connecting…"
        case .connected:
            "Live"
        case let .reconnecting(attempt, _):
            "Reconnecting (\(attempt))…"
        case .stale:
            "Stale"
        case let .disconnected(reason):
            reason.map { "Disconnected: \($0)" } ?? "Disconnected"
        case let .failed(message):
            "Failed: \(message)"
        }
    }

    private var connectionSymbol: String {
        switch store.connectionState {
        case .connected:
//            "dot.radiowaves.left.and.right"
            "wifi"
        case .connecting, .reconnecting:
            "arrow.triangle.2.circlepath"
        case .failed:
            "exclamationmark.triangle"
        case .stale, .disconnected:
            "wifi.slash"
        case .idle:
            "circle"
        }
    }

    private var connectionColor: Color {
        switch store.connectionState {
        case .connected:
            .green
        case .connecting, .reconnecting:
            .orange
        case .failed:
            .red
        case .stale, .disconnected, .idle:
            .secondary
        }
    }

    private var debugPriceText: String {
        guard let price = store.debugTicker?.price else {
            return "—"
        }
        return price.formatted(
            .number
                .precision(.fractionLength(2))
                .grouping(.automatic)
        )
    }
}

#Preview {
    AppView(
        store: Store(initialState: AppFeature.State()) {
            AppFeature()
        }
    )
}
