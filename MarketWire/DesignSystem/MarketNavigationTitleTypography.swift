import UIKit

enum MarketNavigationTitleTypography {
    static func configure() {
        UINavigationBar.appearance().largeTitleTextAttributes = [
            .font: navigationTitleFont(for: .largeTitle, weight: .bold)
        ]
        UINavigationBar.appearance().titleTextAttributes = [
            .font: navigationTitleFont(for: .headline, weight: .semibold)
        ]
    }

    private static func navigationTitleFont(for textStyle: UIFont.TextStyle, weight: UIFont.Weight) -> UIFont {
        let preferredFont = UIFont.preferredFont(forTextStyle: textStyle)
        let serifDescriptor = preferredFont.fontDescriptor.withDesign(.serif) ?? preferredFont.fontDescriptor
        let weightedDescriptor = serifDescriptor.addingAttributes([
            .traits: [UIFontDescriptor.TraitKey.weight: weight]
        ])

        return UIFontMetrics(forTextStyle: textStyle).scaledFont(
            for: UIFont(descriptor: weightedDescriptor, size: preferredFont.pointSize)
        )
    }
}
