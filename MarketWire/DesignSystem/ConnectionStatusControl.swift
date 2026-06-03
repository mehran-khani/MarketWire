import SwiftUI

struct ConnectionStatusControl: View {
    let connectionState: ConnectionState
    let lastError: String?
    let onReconnect: () -> Void

    var body: some View {
        Group {
            if connectionState.canReconnect {
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
        .accessibilityLabel(connectionState.toolbarAccessibilityLabel(lastError: lastError))
        .help(lastError ?? "")
    }

    private var statusLabel: some View {
        ConnectionStatusLabel(
            text: connectionState.toolbarStatusLabel,
            connectionState: connectionState
        )
    }
}
