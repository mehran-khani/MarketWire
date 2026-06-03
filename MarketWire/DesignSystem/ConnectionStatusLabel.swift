import SwiftUI

struct ConnectionStatusLabel: View {
    let text: String
    let connectionState: ConnectionState

    var body: some View {
        Label(text, systemImage: connectionState.statusSymbolName)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(connectionState.statusColor)
    }
}
