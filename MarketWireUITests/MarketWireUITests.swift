import XCTest

final class MarketWireUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunchesIntoMarketsContent() throws {
        let app = XCUIApplication()
        app.launch()
        openMarketsIfNeeded(app)

        XCTAssertTrue(app.navigationBars.staticTexts["Markets"].waitForExistence(timeout: 10))
    }

    @MainActor
    func testMarketsSymbolOpensAndClosesDetail() throws {
        let app = XCUIApplication()
        app.launch()
        openMarketsIfNeeded(app)

        let row = app.buttons["market-row-BTC-USDT"]
        XCTAssertTrue(row.waitForExistence(timeout: 10))
        row.tap()

        XCTAssertTrue(app.staticTexts["BTC-USDT"].waitForExistence(timeout: 10))

        app.navigationBars.buttons.element(boundBy: 0).tap()

        XCTAssertTrue(row.waitForExistence(timeout: 10))
    }

    /// Compact split view may show the sidebar first — tap Markets once to reach content.
    @MainActor
    private func openMarketsIfNeeded(_ app: XCUIApplication) {
        if app.buttons["market-row-BTC-USDT"].waitForExistence(timeout: 2) {
            return
        }
        app.staticTexts["Markets"].tap()
    }
}
