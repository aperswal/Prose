import XCTest

final class NoteCreationUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func test_canCreateTwoNotesBackToBack() throws {
        let app = launchFreshApp()

        createNoteTypingTitle("Alpha One", in: app)
        createNoteTypingTitle("Bravo Two", in: app)

        XCTAssertTrue(
            app.staticTexts["Alpha One"].waitForExistence(timeout: 3),
            "First note title should appear in the list"
        )
        XCTAssertTrue(
            app.staticTexts["Bravo Two"].waitForExistence(timeout: 3),
            "Second note title should appear in the list"
        )
    }

    @MainActor
    func test_canCreateFiveNotesInOneSession() throws {
        let app = launchFreshApp()

        let titles = ["One", "Two", "Three", "Four", "Five"]
        for title in titles {
            createNoteTypingTitle("Note " + title, in: app)
        }

        for title in titles {
            XCTAssertTrue(
                app.staticTexts["Note " + title].waitForExistence(timeout: 3),
                "Note '\(title)' should appear in the list after creation"
            )
        }
    }

    @MainActor
    private func launchFreshApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-UI_TEST_RESET"]
        app.launch()
        return app
    }

    @MainActor
    private func createNoteTypingTitle(_ title: String, in app: XCUIApplication) {
        let newNoteButton = app.buttons["New Note"]
        XCTAssertTrue(
            newNoteButton.waitForExistence(timeout: 3),
            "New Note toolbar button should be reachable from the list"
        )
        newNoteButton.tap()

        let titleField = app.textFields["Title"]
        XCTAssertTrue(
            titleField.waitForExistence(timeout: 3),
            "Title text field should appear after tapping New Note (push to editor failed)"
        )
        titleField.tap()
        titleField.typeText(title)

        let backButton = app.navigationBars.buttons["Notes"].firstMatch
        XCTAssertTrue(
            backButton.waitForExistence(timeout: 3),
            "Back button labeled 'Notes' should exist in editor nav bar after creating '\(title)'"
        )
        backButton.tap()

        XCTAssertTrue(
            app.buttons["New Note"].waitForExistence(timeout: 3),
            "Should return to list view after back tap from '\(title)' editor"
        )
    }
}
