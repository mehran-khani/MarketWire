import ComposableArchitecture
import SwiftUI

struct AlertsView: View {
    let store: StoreOf<AlertsFeature>

    var body: some View {
        SectionPlaceholderView(
            title: "Alerts",
            subtitle: "Local price alerts arrive in a later phase."
        )
    }
}
