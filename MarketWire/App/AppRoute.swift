import Foundation

nonisolated enum AppSection: String, CaseIterable, Hashable, Sendable, Identifiable {
    case watchlist
    case markets
    case alerts
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .watchlist: "Watchlist"
        case .markets: "Markets"
        case .alerts: "Alerts"
        case .settings: "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .watchlist: "star"
        case .markets: "chart.line.uptrend.xyaxis"
        case .alerts: "bell"
        case .settings: "gearshape"
        }
    }
}
