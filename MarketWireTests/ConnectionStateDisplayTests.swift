@testable import MarketWire
import Foundation
import Testing

struct ConnectionStateDisplayTests {
    @Test func disconnectedShowsOfflineLiveLabel() {
        #expect(ConnectionState.disconnected(reason: nil).livePriceStatusLabel == "Offline")
    }

    @Test func disconnectedShowsReconnectInToolbarLabel() {
        let label = ConnectionState.disconnected(reason: nil).toolbarStatusLabel
        #expect(label.contains("reconnect"))
    }

    @Test func connectingShowsConnectingLoadingLabel() {
        #expect(ConnectionState.connecting.livePriceLoadingLabel == "Connecting…")
    }

    @Test func failedStateCanReconnect() {
        #expect(ConnectionState.failed(message: "timeout").canReconnect)
        #expect(!ConnectionState.connected(since: .distantPast).canReconnect)
    }

    @Test func statusSymbolNameForConnected() {
        #expect(ConnectionState.connected(since: .distantPast).statusSymbolName == "wifi")
    }
}
