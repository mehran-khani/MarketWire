import Foundation

extension ConnectionState {
    nonisolated var statusSymbolName: String {
        switch self {
        case .connected:
            "wifi"
        case .connecting:
            "arrow.triangle.2.circlepath"
        case .failed:
            "exclamationmark.triangle"
        case .disconnected:
            "wifi.slash"
        case .idle:
            "circle"
        }
    }

    nonisolated var canReconnect: Bool {
        switch self {
        case .disconnected, .failed:
            true
        case .idle, .connecting, .connected:
            false
        }
    }

    nonisolated var toolbarStatusLabel: String {
        switch self {
        case .idle:
            "Idle"
        case .connecting:
            "Connecting…"
        case .connected:
            "Live"
        case let .disconnected(reason):
            reason.map { "Disconnected: \($0). Tap to reconnect." } ?? "Disconnected. Tap to reconnect."
        case let .failed(message):
            "Failed: \(message). Tap to reconnect."
        }
    }

    nonisolated func toolbarAccessibilityLabel(lastError: String?) -> String {
        if let lastError, !lastError.isEmpty {
            return "\(toolbarStatusLabel). \(lastError)"
        }
        return toolbarStatusLabel
    }

    nonisolated var livePriceStatusLabel: String {
        switch self {
        case .idle:
            "Starting"
        case .connecting:
            "Connecting"
        case .connected:
            "Live"
        case .disconnected:
            "Offline"
        case .failed:
            "Failed"
        }
    }

    nonisolated var livePriceLoadingLabel: String {
        switch self {
        case .idle:
            "Starting…"
        case .connecting:
            "Connecting…"
        case .connected:
            "Waiting for live price…"
        case let .disconnected(reason):
            reason.map { "Offline: \($0)" } ?? "Offline"
        case let .failed(message):
            "Connection failed: \(message)"
        }
    }

    nonisolated var livePriceAccessibilityHint: String {
        switch self {
        case .idle, .connecting, .connected:
            "waiting for live price"
        case .disconnected:
            "offline"
        case .failed:
            "connection failed"
        }
    }
}
