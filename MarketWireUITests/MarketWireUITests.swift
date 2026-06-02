import XCTest

final class MarketWireUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunchesIntoWatchlistContent() throws {
        let app = XCUIApplication()
        app.launch()
        openSectionIfNeeded(app, title: "Watchlist", rowID: "watchlist-card-BTC-USDT")

        XCTAssertTrue(app.navigationBars.staticTexts["Watchlist"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["watchlist-card-BTC-USDT"].waitForExistence(timeout: 10))
    }

    @MainActor
    func testWatchlistSymbolOpensAndClosesDetail() throws {
        let app = XCUIApplication()
        app.launch()
        openSectionIfNeeded(app, title: "Watchlist", rowID: "watchlist-card-BTC-USDT")

        let card = app.buttons["watchlist-card-BTC-USDT"]
        XCTAssertTrue(card.waitForExistence(timeout: 10))
        card.tap()

        XCTAssertTrue(app.staticTexts["BTC-USDT"].waitForExistence(timeout: 10))

        app.navigationBars.buttons.element(boundBy: 0).tap()

        XCTAssertTrue(card.waitForExistence(timeout: 10))
    }

    @MainActor
    private func openSectionIfNeeded(_ app: XCUIApplication, title: String, rowID: String) {
        if app.buttons[rowID].waitForExistence(timeout: 2) {
            return
        }
        app.staticTexts[title].tap()
    }
}
