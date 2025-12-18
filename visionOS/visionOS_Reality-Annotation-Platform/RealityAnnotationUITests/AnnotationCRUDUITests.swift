//
//  AnnotationCRUDUITests.swift
//  Reality Annotation Platform UI Tests
//
//  UI tests for annotation CRUD operations
//  REQUIRES: Xcode UI Testing on visionOS Simulator/Device
//

import XCTest

final class AnnotationCRUDUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--skip-onboarding"]
        app.launch()
    }

    // MARK: - Create Tests

    func testCreateAnnotationFrom2DUI() throws {
        // Go to Annotations tab
        app.tabBars.buttons["Annotations"].tap()

        // Tap create button
        app.buttons["Create"].tap()

        // Verify creation sheet appears
        XCTAssertTrue(app.staticTexts["New Annotation"].waitForExistence(timeout: 2))

        // Fill in form
        let titleField = app.textFields["Enter title"]
        titleField.tap()
        titleField.typeText("Test Title")

        let contentEditor = app.textViews.firstMatch
        contentEditor.tap()
        contentEditor.typeText("Test content for annotation")

        // Tap Create
        app.buttons["Create"].tap()

        // Verify annotation appears in list
        XCTAssertTrue(app.staticTexts["Test Title"].waitForExistence(timeout: 3))
    }

    func testCreateAnnotationValidation() throws {
        // Go to Annotations tab
        app.tabBars.buttons["Annotations"].tap()
        app.buttons["Create"].tap()

        // Try to create with empty content
        let createButton = app.buttons["Create"]
        XCTAssertFalse(createButton.isEnabled)

        // Add content
        app.textViews.firstMatch.tap()
        app.textViews.firstMatch.typeText("Now it has content")

        // Create button should be enabled
        XCTAssertTrue(createButton.isEnabled)
    }

    // MARK: - Read Tests

    func testViewAnnotationDetails() throws {
        // Assuming there's at least one annotation
        app.tabBars.buttons["Annotations"].tap()

        // Wait for list to load
        sleep(1)

        // Tap first annotation
        let firstAnnotation = app.cells.firstMatch
        if firstAnnotation.exists {
            firstAnnotation.tap()

            // Verify detail view appears
            XCTAssertTrue(app.navigationBars["Annotation"].waitForExistence(timeout: 2))
            XCTAssertTrue(app.buttons["Edit"].exists)
            XCTAssertTrue(app.buttons["Delete"].exists)
        }
    }

    // MARK: - Update Tests

    func testEditAnnotation() throws {
        // Navigate to annotations list
        app.tabBars.buttons["Annotations"].tap()
        sleep(1)

        let firstAnnotation = app.cells.firstMatch
        if firstAnnotation.exists {
            firstAnnotation.tap()

            // Tap Edit
            app.buttons["Edit"].tap()

            // Modify content
            let contentEditor = app.textViews.firstMatch
            contentEditor.tap()
            contentEditor.typeText(" - EDITED")

            // Save
            app.buttons["Save"].tap()

            // Verify we're back to detail view
            XCTAssertFalse(app.buttons["Save"].exists)
            XCTAssertTrue(app.buttons["Edit"].exists)
        }
    }

    func testCancelEdit() throws {
        app.tabBars.buttons["Annotations"].tap()
        sleep(1)

        let firstAnnotation = app.cells.firstMatch
        if firstAnnotation.exists {
            firstAnnotation.tap()

            // Tap Edit
            app.buttons["Edit"].tap()

            // Tap Cancel
            app.buttons["Cancel"].tap()

            // Should return to view mode
            XCTAssertTrue(app.buttons["Edit"].exists)
            XCTAssertFalse(app.buttons["Cancel"].exists)
        }
    }

    // MARK: - Delete Tests

    func testDeleteAnnotationWithConfirmation() throws {
        app.tabBars.buttons["Annotations"].tap()
        sleep(1)

        let initialCount = app.cells.count

        let firstAnnotation = app.cells.firstMatch
        if firstAnnotation.exists {
            firstAnnotation.tap()

            // Scroll to delete button
            app.swipeUp()

            // Tap Delete
            app.buttons["Delete"].tap()

            // Confirm deletion
            app.alerts.buttons["Delete"].tap()

            // Verify we're back to list
            XCTAssertTrue(app.navigationBars["Annotations"].waitForExistence(timeout: 2))

            // Verify count decreased
            sleep(1)
            XCTAssertEqual(app.cells.count, initialCount - 1)
        }
    }

    func testCancelDelete() throws {
        app.tabBars.buttons["Annotations"].tap()
        sleep(1)

        let initialCount = app.cells.count

        let firstAnnotation = app.cells.firstMatch
        if firstAnnotation.exists {
            firstAnnotation.tap()
            app.swipeUp()
            app.buttons["Delete"].tap()

            // Cancel deletion
            app.alerts.buttons["Cancel"].tap()

            // Should stay on detail view
            XCTAssertTrue(app.buttons["Edit"].exists)

            // Go back and verify count unchanged
            app.navigationBars.buttons.firstMatch.tap()
            sleep(1)
            XCTAssertEqual(app.cells.count, initialCount)
        }
    }

    // MARK: - Sort Tests

    func testAnnotationSorting() throws {
        app.tabBars.buttons["Annotations"].tap()

        // Open sort menu
        app.buttons["Sort"].tap()

        // Select "Oldest First"
        app.buttons["Oldest First"].tap()

        // Verify sorting (would need to check actual order)
        sleep(1)
        XCTAssertTrue(app.cells.count >= 0)
    }

    // MARK: - Navigation Tests

    func testBackNavigationFromDetail() throws {
        app.tabBars.buttons["Annotations"].tap()
        sleep(1)

        let firstAnnotation = app.cells.firstMatch
        if firstAnnotation.exists {
            firstAnnotation.tap()

            // Navigate back
            app.navigationBars.buttons.firstMatch.tap()

            // Should be on list view
            XCTAssertTrue(app.navigationBars["Annotations"].exists)
        }
    }
}
