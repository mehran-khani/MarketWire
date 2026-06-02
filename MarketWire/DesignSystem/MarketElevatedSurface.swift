import SwiftUI

struct MarketElevatedSurface: ViewModifier {
    var cornerRadius: CGFloat = MarketMetrics.cardCornerRadius

    func body(content: Content) -> some View {
        content
            .background(.regularMaterial, in: .rect(cornerRadius: cornerRadius))
            .shadow(color: .black.opacity(0.08), radius: 10, y: 4)
    }
}

extension View {
    func marketElevatedSurface(cornerRadius: CGFloat = MarketMetrics.cardCornerRadius) -> some View {
        modifier(MarketElevatedSurface(cornerRadius: cornerRadius))
    }
}
