import SwiftUI

struct MarketElevatedSurface: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var cornerRadius: CGFloat = MarketMetrics.cardCornerRadius

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
    }

    func body(content: Content) -> some View {
        content
            .background {
                shape
                    .fill(MarketCardSurfaceStyle.fill)
                    .marketCardShadow(
                        colorScheme: colorScheme,
                        reduceTransparency: reduceTransparency
                    )
            }
            .overlay {
                shape.strokeBorder(
                    MarketCardSurfaceStyle.borderColor(for: colorScheme),
                    lineWidth: MarketMetrics.cardBorderLineWidth
                )
            }
    }
}

extension View {
    func marketElevatedSurface(cornerRadius: CGFloat = MarketMetrics.cardCornerRadius) -> some View {
        modifier(MarketElevatedSurface(cornerRadius: cornerRadius))
    }
}

// MARK: - Shadow stack

private extension View {
    func marketCardShadow(colorScheme: ColorScheme, reduceTransparency: Bool) -> some View {
        modifier(
            MarketCardShadowModifier(
                colorScheme: colorScheme,
                reduceTransparency: reduceTransparency
            )
        )
    }
}

/// Layered, low-contrast shadows sized to stay visually contained by the list gutter.
private struct MarketCardShadowModifier: ViewModifier {
    let colorScheme: ColorScheme
    let reduceTransparency: Bool

    func body(content: Content) -> some View {
        if reduceTransparency {
            content
                .shadow(
                    color: MarketCardSurfaceStyle.shadowColor(for: colorScheme, layer: .key),
                    radius: MarketMetrics.cardShadowKeyBlur * 0.65,
                    x: 0,
                    y: MarketMetrics.cardShadowKeyYOffset * 0.75
                )
        } else {
            content
                .shadow(
                    color: MarketCardSurfaceStyle.shadowColor(for: colorScheme, layer: .contact),
                    radius: MarketMetrics.cardShadowContactBlur,
                    x: 0,
                    y: MarketMetrics.cardShadowContactYOffset
                )
                .shadow(
                    color: MarketCardSurfaceStyle.shadowColor(for: colorScheme, layer: .key),
                    radius: MarketMetrics.cardShadowKeyBlur,
                    x: 0,
                    y: MarketMetrics.cardShadowKeyYOffset
                )
                .shadow(
                    color: MarketCardSurfaceStyle.shadowColor(for: colorScheme, layer: .ambient),
                    radius: MarketMetrics.cardShadowAmbientBlur,
                    x: 0,
                    y: MarketMetrics.cardShadowAmbientYOffset
                )
        }
    }
}

// MARK: - Tokens

private enum MarketCardSurfaceStyle {
    enum ShadowLayer {
        case contact
        case key
        case ambient
    }

    static var fill: Color {
        Color(.secondarySystemGroupedBackground)
    }

    static func borderColor(for colorScheme: ColorScheme) -> Color {
        switch colorScheme {
        case .dark:
            Color.white.opacity(0.09)
        default:
            Color.black.opacity(0.05)
        }
    }

    static func shadowColor(for colorScheme: ColorScheme, layer: ShadowLayer) -> Color {
        let opacity: CGFloat
        switch (colorScheme, layer) {
        case (.dark, .contact):
            opacity = 0.24
        case (.dark, .key):
            opacity = 0.18
        case (.dark, .ambient):
            opacity = 0.10
        case (_, .contact):
            opacity = 0.045
        case (_, .key):
            opacity = 0.055
        case (_, .ambient):
            opacity = 0.028
        }
        return Color.black.opacity(opacity)
    }
}
