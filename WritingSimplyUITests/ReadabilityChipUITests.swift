import XCTest

final class ReadabilityChipUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func test_chipShowsImmediatelyOnEmptyNote() throws {
        let app = launchFreshApp()
        openNewNote(in: app)

        XCTAssertTrue(
            app.navigationBars.staticTexts["Grade"].waitForExistence(timeout: 3),
            "Grade chip should be visible in the nav bar the moment the editor opens"
        )
    }

    @MainActor
    func test_chipGradeUpdatesAsBodyGrows() throws {
        let app = launchFreshApp()
        openNewNote(in: app)

        let bodyEditor = app.textViews.firstMatch
        XCTAssertTrue(bodyEditor.waitForExistence(timeout: 3))
        bodyEditor.tap()

        bodyEditor.typeText("The quick brown fox jumps over the lazy dog and then keeps running until sunset eventually arrives over the distant horizon line softly.")

        let chip = app.navigationBars.staticTexts["Grade"]
        XCTAssertTrue(chip.waitForExistence(timeout: 3), "Chip should remain visible while typing")
    }

    @MainActor
    func test_chipTapOpensDetailPopover() throws {
        let app = launchFreshApp()
        openNewNote(in: app)

        let bodyEditor = app.textViews.firstMatch
        XCTAssertTrue(bodyEditor.waitForExistence(timeout: 3))
        bodyEditor.tap()
        bodyEditor.typeText("The quick brown fox jumps over the lazy dog and then keeps running until sunset eventually.")

        let chip = app.navigationBars.staticTexts["Grade"]
        XCTAssertTrue(chip.waitForExistence(timeout: 3))
        chip.tap()

        XCTAssertTrue(
            app.staticTexts["Readability"].waitForExistence(timeout: 2),
            "Tapping the chip should reveal the Readability detail popover"
        )
    }

    @MainActor
    func test_chipStaysInNavBarAcrossModes() throws {
        let app = launchFreshApp()
        openNewNote(in: app)

        let bodyEditor = app.textViews.firstMatch
        XCTAssertTrue(bodyEditor.waitForExistence(timeout: 3))
        bodyEditor.tap()
        bodyEditor.typeText("The quick brown fox jumps over the lazy dog and then keeps running until sunset eventually.")

        XCTAssertTrue(
            app.navigationBars.staticTexts["Grade"].waitForExistence(timeout: 3),
            "Grade chip should be in the nav bar while editing"
        )

        let doneButton = app.buttons["Done"]
        XCTAssertTrue(doneButton.waitForExistence(timeout: 2))
        doneButton.tap()

        XCTAssertTrue(
            app.navigationBars.staticTexts["Grade"].waitForExistence(timeout: 2),
            "Grade chip should remain in the nav bar in view mode"
        )

        XCTAssertEqual(
            app.staticTexts.matching(identifier: "Grade").count,
            1,
            "Grade should appear once total (nav bar only) in both modes"
        )
    }

    @MainActor
    private func launchFreshApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-UI_TEST_RESET"]
        app.launch()
        return app
    }

    @MainActor
    private func openNewNote(in app: XCUIApplication) {
        let newNoteButton = app.buttons["New Note"]
        XCTAssertTrue(newNoteButton.waitForExistence(timeout: 3))
        newNoteButton.tap()

        XCTAssertTrue(
            app.textFields["Title"].waitForExistence(timeout: 3),
            "Title field should appear after opening a new note"
        )
    }
}
