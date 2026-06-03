import SwiftUI

extension View {
    @ViewBuilder
    func marketNavigationBarScrollEffects() -> some View {
        if #available(iOS 26.0, *) {
            toolbarBackground(.automatic, for: .navigationBar)
        } else {
            toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            toolbarBackground(.visible, for: .navigationBar)
        }
    }

    @ViewBuilder
    func marketContentScrollEdgeEffects() -> some View {
        if #available(iOS 26.0, *) {
            scrollEdgeEffectStyle(.soft, for: .vertical)
        } else {
            self
        }
    }
}
