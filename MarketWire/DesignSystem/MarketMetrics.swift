import CoreGraphics

enum MarketMetrics {
    static let cardCornerRadius: CGFloat = 14
    static let cardPadding: CGFloat = 16

    /// Vertical gap between adjacent ticker cards in plain lists.
    static let cardSpacing: CGFloat = 16

    /// Matches `cardSpacing / 2` — use for `listRowInsets` top and bottom.
    static let cardListRowVerticalInset: CGFloat = cardSpacing / 2

    /// Hairline stroke on elevated cards (scales cleanly at @2x/@3x).
    static let cardBorderLineWidth: CGFloat = 0.5

    // Resting cards stay low: a crisp contact layer plus two soft, low-alpha clouds.
    static let cardShadowContactYOffset: CGFloat = 0.5
    static let cardShadowContactBlur: CGFloat = 1
    static let cardShadowKeyYOffset: CGFloat = 2.5
    static let cardShadowKeyBlur: CGFloat = 7
    static let cardShadowAmbientYOffset: CGFloat = 3
    static let cardShadowAmbientBlur: CGFloat = 11
}
