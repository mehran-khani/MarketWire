import ComposableArchitecture
import SwiftUI

struct AppView: View {
    let store: StoreOf<AppFeature>

    var body: some View {
        NavigationSplitView {
            List {
                Label("Watchlist", systemImage: "star")
                Label("Markets", systemImage: "chart.line.uptrend.xyaxis")
                Label("Alerts", systemImage: "bell")
            }
            .navigationTitle("MarketWire")
        } detail: {
            VStack(spacing: 12) {
                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 44, weight: .medium))
                    .foregroundStyle(.tint)

                Text("MarketWire")
                    .font(.largeTitle.weight(.semibold))
                    .fontDesign(.serif)

                Text("Realtime markets")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .task {
            await store.send(.appStarted).finish()
        }
    }
}

#Preview {
    AppView(
        store: Store(initialState: AppFeature.State()) {
            AppFeature()
        }
    )
}
