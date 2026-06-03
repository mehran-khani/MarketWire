import SwiftUI

struct ConnectionStatusControl: View {
    let connectionState: ConnectionState
    let lastError: String?
    let onReconnect: () -> Void

    private var canReconnect: Bool {
        switch connectionState {
        case .disconnected, .failed:
            true
        default:
            false
        }
    }

    var body: some View {
        Group {
            if canReconnect {
                Button(action: onReconnect) {
                    statusLabel
                }
                .buttonStyle(.plain)
                .accessibilityHint("Double tap to reconnect")
            } else {
                statusLabel
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("connection-status")
        .accessibilityLabel(accessibilityLabelText)
        .help(lastError ?? "")
    }

    private var statusLabel: some View {
        Label(connectionLabel, systemImage: connectionSymbol)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(connectionColor)
    }

    private var accessibilityLabelText: String {
        if let lastError, !lastError.isEmpty {
            return "\(connectionLabel). \(lastError)"
        }
        return connectionLabel
    }

    private var connectionLabel: String {
        switch connectionState {
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

    private var connectionSymbol: String {
        switch connectionState {
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

    private var connectionColor: Color {
        switch connectionState {
        case .connected:
            .green
        case .connecting:
            .orange
        case .failed:
            .red
        case .disconnected, .idle:
            .secondary
        }
    }
}
