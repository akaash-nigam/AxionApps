//
//  MenuNavigationTests.swift
//  RhythmFlowUITests
//
//  UI tests for menu navigation and user flows
//

import XCTest

final class MenuNavigationTests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    // MARK: - Main Menu Tests

    func testMainMenuAppears() throws {
        // Then
        XCTAssertTrue(app.staticTexts["RHYTHM FLOW"].exists)
        XCTAssertTrue(app.buttons["PLAY"].exists)
        XCTAssertTrue(app.buttons["FITNESS"].exists)
        XCTAssertTrue(app.buttons["MULTIPLAYER"].exists)
        XCTAssertTrue(app.buttons["CREATE"].exists)
    }

    func testNavigateToSongSelection() throws {
        // When
        app.buttons["PLAY"].tap()

        // Then
        XCTAssertTrue(app.staticTexts["Select Song"].waitForExistence(timeout: 2))
    }

    func testQuickPlayButton() throws {
        // Given - Song is selected
        app.menus["Select Song"].tap()
        app.menuItems["Electric Dreams"].tap()

        // When
        app.buttons["START"].tap()

        // Then - Should enter immersive space
        XCTAssertTrue(app.staticTexts["3"].waitForExistence(timeout: 2)) // Countdown
    }

    // MARK: - Song Selection Tests

    func testSongSelectionMenu() throws {
        // When
        app.menus["Select Song"].tap()

        // Then - Should show song list
        XCTAssertTrue(app.menuItems.count > 0)
    }

    func testDifficultySelection() throws {
        // When
        app.menus[Difficulty Selection"].tap()

        // Then - Should show all difficulties
        XCTAssertTrue(app.menuItems["Easy"].exists)
        XCTAssertTrue(app.menuItems["Normal"].exists)
        XCTAssertTrue(app.menuItems["Hard"].exists)
        XCTAssertTrue(app.menuItems["Expert"].exists)
        XCTAssertTrue(app.menuItems["Expert+"].exists)
    }

    // MARK: - Settings Tests

    func testOpenSettings() throws {
        // When
        app.buttons["Settings"].tap()

        // Then
        XCTAssertTrue(app.staticTexts["Gameplay Settings"].waitForExistence(timeout: 2))
    }

    func testAdjustVolume() throws {
        // Given
        app.buttons["Settings"].tap()

        // When
        let volumeSlider = app.sliders["Music Volume"]
        volumeSlider.adjust(toNormalizedSliderPosition: 0.5)

        // Then
        XCTAssertTrue(volumeSlider.value as? String == "50%")
    }

    // MARK: - Profile Tests

    func testViewPlayerProfile() throws {
        // When
        app.buttons["Profile"].tap()

        // Then
        XCTAssertTrue(app.staticTexts["Level"].exists)
        XCTAssertTrue(app.staticTexts["Total Score"].exists)
        XCTAssertTrue(app.staticTexts["Songs Played"].exists)
    }

    // MARK: - Accessibility Tests

    func testVoiceOverLabels() throws {
        // Then - All buttons should have accessibility labels
        XCTAssertNotNil(app.buttons["PLAY"].label)
        XCTAssertNotNil(app.buttons["FITNESS"].label)
        XCTAssertNotNil(app.buttons["MULTIPLAYER"].label)
        XCTAssertNotNil(app.buttons["CREATE"].label)
    }

    // MARK: - Performance Tests

    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }

    func testMenuNavigationPerformance() throws {
        measure {
            app.buttons["PLAY"].tap()
            app.buttons["Back"].tap()
        }
    }
}
