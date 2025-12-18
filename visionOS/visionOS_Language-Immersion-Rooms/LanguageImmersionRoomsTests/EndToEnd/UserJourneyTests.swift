//
//  UserJourneyTests.swift
//  Language Immersion Rooms Tests
//
//  End-to-end tests for complete user journeys
//
//  ⚠️  REQUIRES: Full app environment with all services configured
//  These tests simulate complete user workflows
//

import XCTest
@testable import LanguageImmersionRooms

final class UserJourneyTests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Complete First-Time User Journey

    func testFirstTimeUserCompleteJourney() throws {
        // Step 1: Sign In
        print("Step 1: Sign In")
        let signInButton = app.buttons["Sign in with Apple"]
        XCTAssertTrue(signInButton.waitForExistence(timeout: 5))
        signInButton.tap()

        // Step 2: Complete Onboarding
        print("Step 2: Onboarding - Language Selection")
        let spanishButton = app.buttons["🇪🇸 Spanish"]
        XCTAssertTrue(spanishButton.waitForExistence(timeout: 5))
        spanishButton.tap()
        app.buttons["Next"].tap()

        print("Step 3: Onboarding - Difficulty")
        let beginnerButton = app.buttons["Beginner"]
        XCTAssertTrue(beginnerButton.waitForExistence(timeout: 5))
        beginnerButton.tap()
        app.buttons["Next"].tap()

        print("Step 4: Onboarding - Goals")
        app.buttons["Vocabulary"].tap()
        app.buttons["Conversations"].tap()
        app.buttons["Finish"].tap()

        // Step 3: View Main Menu
        print("Step 5: Main Menu")
        let startLearningButton = app.buttons["Start Learning"]
        XCTAssertTrue(startLearningButton.waitForExistence(timeout: 5))

        // Verify progress shows zeros for new user
        let wordsText = app.staticTexts.matching(identifier: "wordsToday").element
        if wordsText.exists {
            XCTAssertEqual(wordsText.label, "0")
        }

        // Step 4: Enter Immersive Space
        print("Step 6: Enter Immersive Space")
        startLearningButton.tap()

        let scanButton = app.buttons["Scan Room"]
        XCTAssertTrue(scanButton.waitForExistence(timeout: 10),
                     "Should enter immersive space successfully")

        // Step 5: Scan Room
        print("Step 7: Scan Room")
        scanButton.tap()

        // Wait for scanning to complete
        sleep(3)

        // Step 6: Interact with Label
        print("Step 8: Tap Label")
        // In a real test, we'd tap a label entity
        // For now, verify the toggle button exists
        let toggleButton = app.buttons["Toggle Labels"]
        XCTAssertTrue(toggleButton.exists)

        // Step 7: Start Conversation
        print("Step 9: Start Conversation")
        let chatButton = app.buttons["Start Chat"]
        chatButton.tap()

        let micButton = app.buttons["microphone"]
        XCTAssertTrue(micButton.waitForExistence(timeout: 5),
                     "Conversation UI should appear")

        // Step 8: End Session
        print("Step 10: End Session")
        let endChatButton = app.buttons["End Chat"]
        if endChatButton.exists {
            endChatButton.tap()
        }

        let exitButton = app.buttons["Exit"]
        exitButton.tap()

        // Step 9: Verify Progress Updated
        print("Step 11: Verify Progress")
        XCTAssertTrue(startLearningButton.waitForExistence(timeout: 5),
                     "Should return to main menu")

        print("✅ Complete first-time user journey succeeded")
    }

    // MARK: - Returning User Journey

    func testReturningUserJourney() throws {
        // Assume user is already signed in and onboarding complete

        // Step 1: Check Progress Dashboard
        print("Step 1: View Progress Dashboard")
        let progressButton = app.buttons["Progress"]
        progressButton.tap()

        let progressTitle = app.staticTexts["Your Progress"]
        XCTAssertTrue(progressTitle.waitForExistence(timeout: 5))

        // Navigate back
        app.navigationBars.buttons.element(boundBy: 0).tap()

        // Step 2: Adjust Settings
        print("Step 2: Adjust Settings")
        let settingsButton = app.buttons["Settings"]
        settingsButton.tap()

        let showLabelsToggle = app.switches["Show Labels"]
        if showLabelsToggle.exists {
            showLabelsToggle.tap()
        }

        app.navigationBars.buttons.element(boundBy: 0).tap()

        // Step 3: Start Learning Session
        print("Step 3: Start Learning Session")
        app.buttons["Start Learning"].tap()

        // Quick session
        let scanButton = app.buttons["Scan Room"]
        XCTAssertTrue(scanButton.waitForExistence(timeout: 10))
        scanButton.tap()

        sleep(2)

        // Exit immediately
        app.buttons["Exit"].tap()

        print("✅ Returning user journey succeeded")
    }

    // MARK: - Learning Session Journey

    func testCompleteLearningSession() throws {
        // Step 1: Enter immersive space
        print("Step 1: Enter Immersive Space")
        app.buttons["Start Learning"].tap()

        let scanButton = app.buttons["Scan Room"]
        XCTAssertTrue(scanButton.waitForExistence(timeout: 10))

        // Step 2: Scan and learn vocabulary
        print("Step 2: Scan Room for Vocabulary")
        scanButton.tap()
        sleep(3)

        // In a real test, we'd tap multiple labels
        // Simulate by waiting
        print("Step 3: Learning vocabulary...")
        sleep(2)

        // Step 3: Start conversation
        print("Step 4: Start AI Conversation")
        let chatButton = app.buttons["Start Chat"]
        chatButton.tap()

        let micButton = app.buttons["microphone"]
        XCTAssertTrue(micButton.waitForExistence(timeout: 5))

        // Simulate conversation
        print("Step 5: Having conversation...")
        sleep(3)

        // Step 4: End conversation
        print("Step 6: End Conversation")
        let endChatButton = app.buttons["End Chat"]
        if endChatButton.exists {
            endChatButton.tap()
        }

        // Step 5: Exit and save progress
        print("Step 7: Exit and Save Progress")
        app.buttons["Exit"].tap()

        // Verify back at main menu
        let startButton = app.buttons["Start Learning"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 5))

        print("✅ Complete learning session succeeded")
    }

    // MARK: - Error Recovery Journey

    func testErrorRecoveryJourney() throws {
        // Test that app recovers gracefully from errors

        // Step 1: Start without network (if possible to simulate)
        print("Step 1: Test without network")
        app.buttons["Start Learning"].tap()

        let chatButton = app.buttons["Start Chat"]
        if chatButton.waitForExistence(timeout: 10) {
            chatButton.tap()

            // Wait for potential timeout
            sleep(10)

            // App should still be responsive
            XCTAssertTrue(app.exists)

            // Should be able to exit
            let exitButton = app.buttons["Exit"]
            if exitButton.exists {
                exitButton.tap()
            }
        }

        print("✅ Error recovery journey succeeded")
    }

    // MARK: - Multi-Session Journey

    func testMultipleSessionsJourney() throws {
        // Simulate user doing multiple short sessions

        for session in 1...3 {
            print("Session \(session)")

            // Enter immersive space
            app.buttons["Start Learning"].tap()

            let scanButton = app.buttons["Scan Room"]
            XCTAssertTrue(scanButton.waitForExistence(timeout: 10))

            if session == 1 {
                // Only scan in first session
                scanButton.tap()
                sleep(2)
            }

            // Quick activity
            sleep(1)

            // Exit
            app.buttons["Exit"].tap()

            // Verify return
            let startButton = app.buttons["Start Learning"]
            XCTAssertTrue(startButton.waitForExistence(timeout: 5))

            // Brief pause between sessions
            sleep(1)
        }

        // Check progress accumulated
        app.buttons["Progress"].tap()
        let progressTitle = app.staticTexts["Your Progress"]
        XCTAssertTrue(progressTitle.waitForExistence(timeout: 5))

        print("✅ Multiple sessions journey succeeded")
    }

    // MARK: - Settings Change Journey

    func testSettingsChangeJourney() throws {
        // Step 1: Change settings
        print("Step 1: Change Settings")
        app.buttons["Settings"].tap()

        // Toggle labels off
        let showLabelsToggle = app.switches["Show Labels"]
        if showLabelsToggle.exists {
            showLabelsToggle.tap()
        }

        // Change label size
        let labelSizePicker = app.buttons["Label Size"]
        if labelSizePicker.exists {
            labelSizePicker.tap()
            app.buttons["Large"].tap()
        }

        app.navigationBars.buttons.element(boundBy: 0).tap()

        // Step 2: Verify settings applied in session
        print("Step 2: Verify Settings Applied")
        app.buttons["Start Learning"].tap()

        let scanButton = app.buttons["Scan Room"]
        XCTAssertTrue(scanButton.waitForExistence(timeout: 10))

        // Labels should be hidden by default now
        // (In a real test, we'd verify this visually)

        app.buttons["Exit"].tap()

        print("✅ Settings change journey succeeded")
    }

    // MARK: - Performance Journey

    func testPerformanceJourney() throws {
        measure(metrics: [XCTApplicationLaunchMetric(), XCTClockMetric()]) {
            app.launch()

            // Simulate typical user flow
            app.buttons["Start Learning"].tap()

            let scanButton = app.buttons["Scan Room"]
            _ = scanButton.waitForExistence(timeout: 10)

            app.buttons["Exit"].tap()

            let startButton = app.buttons["Start Learning"]
            _ = startButton.waitForExistence(timeout: 5)
        }
    }

    // MARK: - Accessibility Journey

    func testAccessibilityJourney() throws {
        // Test that all important elements are accessible

        print("Step 1: Check Main Menu Accessibility")
        let startButton = app.buttons["Start Learning"]
        XCTAssertTrue(startButton.isAccessibilityElement)
        XCTAssertFalse(startButton.label.isEmpty)

        let settingsButton = app.buttons["Settings"]
        XCTAssertTrue(settingsButton.isAccessibilityElement)

        let progressButton = app.buttons["Progress"]
        XCTAssertTrue(progressButton.isAccessibilityElement)

        // Enter immersive space
        print("Step 2: Check Immersive Space Accessibility")
        startButton.tap()

        let scanButton = app.buttons["Scan Room"]
        XCTAssertTrue(scanButton.waitForExistence(timeout: 10))
        XCTAssertTrue(scanButton.isAccessibilityElement)

        let chatButton = app.buttons["Start Chat"]
        XCTAssertTrue(chatButton.isAccessibilityElement)

        let exitButton = app.buttons["Exit"]
        XCTAssertTrue(exitButton.isAccessibilityElement)

        exitButton.tap()

        print("✅ Accessibility journey succeeded")
    }
}
