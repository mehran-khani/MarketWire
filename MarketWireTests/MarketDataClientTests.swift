import ComposableArchitecture
@testable import MarketWire
import Testing

struct MarketDataClientTests {
    @Test func testValueStreamFinishesWithoutEvents() async {
        let stream = await MarketDataClient.testValue.stream([])

        var eventCount = 0
        for await _ in stream {
            eventCount += 1
        }

        #expect(eventCount == 0)
    }
}
