import SwiftUI

extension MarketMetrics {
    static var cardPreviewShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
    }
}

extension View {
    /// Clips the context-menu lift animation to the card shape instead of the full list row.
    func tickerCardContextMenuShape() -> some View {
        contentShape(.contextMenuPreview, MarketMetrics.cardPreviewShape)
            .contentShape(.interaction, MarketMetrics.cardPreviewShape)
    }

    func favoriteSwipeAction(isFavorite: Bool, onToggle: @escaping () -> Void) -> some View {
        swipeActions(edge: .trailing, allowsFullSwipe: isFavorite) {
            if isFavorite {
                Button(role: .destructive, action: onToggle) {
                    Label("Remove Favorite", systemImage: "star.slash")
                        .labelStyle(.iconOnly)
                }
                .accessibilityLabel("Remove Favorite")
            } else {
                Button(action: onToggle) {
                    Label("Add Favorite", systemImage: "star.fill")
                        .labelStyle(.iconOnly)
                }
                .tint(.yellow)
                .accessibilityLabel("Add Favorite")
            }
        }
    }

    /// List-row chrome for a `TickerCard`: context menu, swipe favorite, tap, and plain list styling.
    func tickerCardFavoriteListRow(
        isFavorite: Bool,
        accessibilityIdentifier: String,
        onSelect: @escaping () -> Void,
        onFavoriteToggle: @escaping () -> Void
    ) -> some View {
        tickerCardContextMenuShape()
            .contextMenu {
                Button(action: onFavoriteToggle) {
                    if isFavorite {
                        Label("Remove Favorite", systemImage: "star.slash")
                    } else {
                        Label("Add Favorite", systemImage: "star")
                    }
                }
                .accessibilityLabel(isFavorite ? "Remove from Watchlist" : "Add to Watchlist")
                Button(action: onSelect) {
                    Label("View Details", systemImage: "chart.line.uptrend.xyaxis")
                }
            }
            .onTapGesture(perform: onSelect)
            .accessibilityAddTraits(.isButton)
            .accessibilityIdentifier(accessibilityIdentifier)
            .favoriteSwipeAction(isFavorite: isFavorite, onToggle: onFavoriteToggle)
            .listRowInsets(
                EdgeInsets(
                    top: MarketMetrics.cardListRowVerticalInset,
                    leading: 16,
                    bottom: MarketMetrics.cardListRowVerticalInset,
                    trailing: 16
                )
            )
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
    }
}
