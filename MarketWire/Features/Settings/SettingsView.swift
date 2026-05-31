import ComposableArchitecture
import SwiftUI

struct SettingsView: View {
    let store: StoreOf<SettingsFeature>

    var body: some View {
        SectionPlaceholderView(
            title: "Settings",
            subtitle: "Preferences and provider options arrive in a later phase."
        )
    }
}
