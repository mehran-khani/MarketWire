import ComposableArchitecture
import SwiftUI

@main
struct MarketWireApp: App {
    private let store = Store(initialState: AppFeature.State()) {
        AppFeature()
    }

    init() {
        MarketNavigationTitleTypography.configure()
    }

    var body: some Scene {
        WindowGroup {
            AppView(store: store)
        }
    }
}
