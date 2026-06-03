import SwiftUI

extension ConnectionState {
    var statusColor: Color {
        switch self {
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
