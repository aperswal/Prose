import XCTest

/// Drives the seeded app to the screens we want for the App Store and saves each
/// as a test attachment. Run via screenshots/capture-auto.sh, which then pulls the
/// attachments out of the .xcresult into screenshots/raw/.
final class ScreenshotCaptureUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func test_captureHighlights() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-SEED_SCREENSHOTS"]
        app.launch()

        let danaTitle = "Note to Dana \u{2014} pricing page"
        let dana = app.staticTexts[danaTitle]
        XCTAssertTrue(dana.waitForExistence(timeout: 8), "Seeded list should show the demo note")

        save(named: "01-list")

        dana.tap()

        let eye = app.buttons["Show highlights"]
        XCTAssertTrue(eye.waitForExistence(timeout: 5), "Editor should show the eye toggle")
        save(named: "02-note-plain")

        eye.tap()
        XCTAssertTrue(
            app.buttons["Hide highlights"].waitForExistence(timeout: 3),
            "Eye should flip to the on state once highlights are showing"
        )
        save(named: "03-highlights")

        let chip = app.buttons
            .matching(NSPredicate(format: "label BEGINSWITH %@", "Readability"))
            .firstMatch
        XCTAssertTrue(chip.waitForExistence(timeout: 3), "Grade chip should be in the nav bar")
        chip.tap()
        XCTAssertTrue(
            app.staticTexts["Readability"].waitForExistence(timeout: 3),
            "Tapping the chip with highlights on should show the legend popover"
        )
        save(named: "04-legend")
    }

    @MainActor
    private func save(named name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
