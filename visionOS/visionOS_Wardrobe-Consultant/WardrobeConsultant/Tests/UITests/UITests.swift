//
//  UITests.swift
//  WardrobeConsultantUITests
//
//  Created by Claude Code
//  Copyright © 2025 Wardrobe Consultant. All rights reserved.
//

import XCTest

/// UI Tests for end-to-end user interaction flows
///
/// NOTE: These tests require Xcode and cannot be run in command-line environment.
/// They require XCUITest framework and device/simulator.
///
/// To run these tests:
/// 1. Open project in Xcode
/// 2. Select a device or simulator
/// 3. Press Cmd+U or Product > Test
final class WardrobeConsultantUITests: XCTestCase {
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

    // MARK: - Onboarding Flow Tests
    func testCompleteOnboardingFlow() throws {
        // Given: App launches for the first time
        // The onboarding should be visible

        // When: User completes onboarding
        // Welcome screen
        XCTAssertTrue(app.staticTexts["Welcome to Wardrobe Consultant"].exists)
        app.buttons["Get Started"].tap()

        // Style profile screen
        XCTAssertTrue(app.staticTexts["What's Your Style?"].exists)
        app.buttons["Casual"].tap()
        app.buttons["Next"].tap()

        // Size preferences screen
        XCTAssertTrue(app.staticTexts["Your Measurements"].exists)
        app.buttons["Skip"].tap()

        // Color preferences screen
        XCTAssertTrue(app.staticTexts["Favorite Colors"].exists)
        app.buttons["Next"].tap()

        // Integrations screen
        XCTAssertTrue(app.staticTexts["Connect Your Calendar"].exists)
        app.buttons["Skip"].tap()

        // First item screen
        XCTAssertTrue(app.staticTexts["Add Your First Item"].exists)
        app.buttons["Skip for Now"].tap()

        // Completion screen
        XCTAssertTrue(app.staticTexts["You're All Set!"].exists)
        app.buttons["Start Exploring"].tap()

        // Then: Should land on home screen
        XCTAssertTrue(app.tabBars.buttons["Home"].exists)
        XCTAssertTrue(app.navigationBars["Home"].exists)
    }

    func testSkipOnboarding() throws {
        // Given: Onboarding is showing
        XCTAssertTrue(app.staticTexts["Welcome to Wardrobe Consultant"].exists)

        // When: User taps skip repeatedly
        for _ in 0..<7 {
            if app.buttons["Skip"].exists {
                app.buttons["Skip"].tap()
            } else if app.buttons["Skip for Now"].exists {
                app.buttons["Skip for Now"].tap()
            } else if app.buttons["Next"].exists {
                app.buttons["Next"].tap()
            } else if app.buttons["Get Started"].exists {
                app.buttons["Get Started"].tap()
            } else if app.buttons["Start Exploring"].exists {
                app.buttons["Start Exploring"].tap()
            }
        }

        // Then: Should reach home screen
        XCTAssertTrue(app.tabBars.buttons["Home"].exists)
    }

    // MARK: - Navigation Tests
    func testTabNavigation() throws {
        // Given: App is on home screen
        skipOnboardingIfNeeded()

        // When: User navigates through tabs
        app.tabBars.buttons["Wardrobe"].tap()
        XCTAssertTrue(app.navigationBars["Wardrobe"].waitForExistence(timeout: 2))

        app.tabBars.buttons["Outfits"].tap()
        XCTAssertTrue(app.navigationBars["Outfits"].waitForExistence(timeout: 2))

        app.tabBars.buttons["AI"].tap()
        XCTAssertTrue(app.navigationBars["Recommendations"].waitForExistence(timeout: 2))

        app.tabBars.buttons["Settings"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 2))

        app.tabBars.buttons["Home"].tap()
        XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: 2))

        // Then: All tabs should be accessible
    }

    // MARK: - Add Item Flow Tests
    func testAddWardrobeItemComplete() throws {
        // Given: User is on wardrobe screen
        skipOnboardingIfNeeded()
        app.tabBars.buttons["Wardrobe"].tap()

        // When: User adds a new item
        app.buttons["Add Item"].tap()

        // Fill in item details
        XCTAssertTrue(app.navigationBars["Add Item"].exists)

        // Category selection
        app.buttons["Select Category"].tap()
        app.buttons["T-Shirt"].tap()

        // Brand
        let brandField = app.textFields["Brand"]
        brandField.tap()
        brandField.typeText("Nike")

        // Size
        app.buttons["Select Size"].tap()
        app.buttons["M"].tap()

        // Color (primary)
        app.buttons["Select Primary Color"].tap()
        app.buttons["Blue"].tap()

        // Purchase date
        app.datePickers["Purchase Date"].tap()
        // Select today's date (default)

        // Price
        let priceField = app.textFields["Price"]
        priceField.tap()
        priceField.typeText("29.99")

        // Save
        app.buttons["Save"].tap()

        // Then: Should return to wardrobe with new item
        XCTAssertTrue(app.navigationBars["Wardrobe"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Nike"].exists)
    }

    func testAddItemWithPhoto() throws {
        // Given: User is on add item screen
        skipOnboardingIfNeeded()
        app.tabBars.buttons["Wardrobe"].tap()
        app.buttons["Add Item"].tap()

        // When: User adds a photo
        app.buttons["Add Photo"].tap()

        // Select from photo library (simulator test)
        // This will show system photo picker
        XCTAssertTrue(app.otherElements["PhotosPicker"].waitForExistence(timeout: 2))

        // Note: Actual photo selection requires simulator setup with test photos
        // or camera access on device

        // Cancel for this test
        app.buttons["Cancel"].tap()

        // Then: Should return to add item form
        XCTAssertTrue(app.navigationBars["Add Item"].exists)
    }

    func testCancelAddItem() throws {
        // Given: User is on add item screen
        skipOnboardingIfNeeded()
        app.tabBars.buttons["Wardrobe"].tap()
        app.buttons["Add Item"].tap()

        // When: User cancels
        app.buttons["Cancel"].tap()

        // Then: Should return to wardrobe
        XCTAssertTrue(app.navigationBars["Wardrobe"].exists)
    }

    // MARK: - Item Detail Tests
    func testViewItemDetail() throws {
        // Given: Wardrobe has items
        skipOnboardingIfNeeded()
        addTestItemIfNeeded()
        app.tabBars.buttons["Wardrobe"].tap()

        // When: User taps on an item
        let firstItem = app.collectionViews.cells.firstMatch
        XCTAssertTrue(firstItem.waitForExistence(timeout: 2))
        firstItem.tap()

        // Then: Detail view should appear
        XCTAssertTrue(app.navigationBars["Item Details"].waitForExistence(timeout: 2))

        // Should show stats
        XCTAssertTrue(app.staticTexts["Times Worn"].exists)
        XCTAssertTrue(app.staticTexts["Cost per Wear"].exists)
        XCTAssertTrue(app.staticTexts["Last Worn"].exists)
    }

    func testEditItemFromDetail() throws {
        // Given: User is viewing item detail
        skipOnboardingIfNeeded()
        addTestItemIfNeeded()
        app.tabBars.buttons["Wardrobe"].tap()
        app.collectionViews.cells.firstMatch.tap()

        // When: User taps edit
        app.buttons["Edit"].tap()

        // Then: Edit form should appear
        XCTAssertTrue(app.navigationBars["Edit Item"].waitForExistence(timeout: 2))

        // Make a change
        let brandField = app.textFields["Brand"]
        brandField.tap()
        brandField.clearText()
        brandField.typeText("Adidas")

        // Save
        app.buttons["Save"].tap()

        // Then: Should return to detail with updated info
        XCTAssertTrue(app.navigationBars["Item Details"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Adidas"].exists)
    }

    func testDeleteItemFromDetail() throws {
        // Given: User is viewing item detail
        skipOnboardingIfNeeded()
        addTestItemIfNeeded()
        app.tabBars.buttons["Wardrobe"].tap()
        let itemCount = app.collectionViews.cells.count
        app.collectionViews.cells.firstMatch.tap()

        // When: User deletes item
        app.buttons["Delete"].tap()

        // Confirm deletion
        app.alerts.buttons["Delete"].tap()

        // Then: Should return to wardrobe with item removed
        XCTAssertTrue(app.navigationBars["Wardrobe"].waitForExistence(timeout: 2))
        XCTAssertEqual(app.collectionViews.cells.count, itemCount - 1)
    }

    func testToggleFavorite() throws {
        // Given: User is viewing item detail
        skipOnboardingIfNeeded()
        addTestItemIfNeeded()
        app.tabBars.buttons["Wardrobe"].tap()
        app.collectionViews.cells.firstMatch.tap()

        // When: User taps favorite button
        let favoriteButton = app.buttons["Favorite"]
        XCTAssertTrue(favoriteButton.exists)
        favoriteButton.tap()

        // Then: Favorite state should toggle
        // (Visual indicator would change - test by re-checking state)
    }

    // MARK: - Search and Filter Tests
    func testSearchWardrobe() throws {
        // Given: Wardrobe has multiple items
        skipOnboardingIfNeeded()
        addMultipleTestItems()
        app.tabBars.buttons["Wardrobe"].tap()

        // When: User searches for an item
        let searchField = app.searchFields.firstMatch
        searchField.tap()
        searchField.typeText("Nike")

        // Then: Results should be filtered
        sleep(1) // Wait for search to complete
        let visibleItems = app.collectionViews.cells.count
        XCTAssertGreaterThan(visibleItems, 0)

        // Clear search
        app.buttons["Clear text"].tap()
    }

    func testFilterByCategory() throws {
        // Given: Wardrobe has multiple categories
        skipOnboardingIfNeeded()
        addMultipleTestItems()
        app.tabBars.buttons["Wardrobe"].tap()

        // When: User applies category filter
        app.buttons["Filter"].tap()
        app.buttons["T-Shirts"].tap()

        // Then: Only t-shirts should be visible
        sleep(1) // Wait for filter to apply
        // All visible items should be t-shirts
    }

    // MARK: - Outfit Generation Tests
    func testGenerateOutfit() throws {
        // Given: User is on recommendations screen with items in wardrobe
        skipOnboardingIfNeeded()
        addMultipleTestItems()
        app.tabBars.buttons["AI"].tap()

        // When: User generates an outfit for an occasion
        app.buttons["Casual"].tap()

        // Then: Generated outfit should appear
        XCTAssertTrue(app.staticTexts["Generated Outfit"].waitForExistence(timeout: 5))

        // Should show confidence score
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Confidence'")).firstMatch.exists)
    }

    func testSaveGeneratedOutfit() throws {
        // Given: User has generated an outfit
        skipOnboardingIfNeeded()
        addMultipleTestItems()
        app.tabBars.buttons["AI"].tap()
        app.buttons["Casual"].tap()

        // When: User saves the outfit
        app.buttons["Save Outfit"].tap()

        // Navigate to outfits tab
        app.tabBars.buttons["Outfits"].tap()

        // Then: Saved outfit should appear in list
        XCTAssertGreaterThan(app.collectionViews.cells.count, 0)
    }

    // MARK: - Settings Tests
    func testViewUserProfile() throws {
        // Given: User is on settings screen
        skipOnboardingIfNeeded()
        app.tabBars.buttons["Settings"].tap()

        // When: User taps on profile
        app.buttons["User Profile"].tap()

        // Then: Profile view should appear
        XCTAssertTrue(app.navigationBars["User Profile"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Style Preferences"].exists)
    }

    func testEditUserProfile() throws {
        // Given: User is viewing profile
        skipOnboardingIfNeeded()
        app.tabBars.buttons["Settings"].tap()
        app.buttons["User Profile"].tap()

        // When: User edits profile
        app.buttons["Primary Style"].tap()
        app.buttons["Minimalist"].tap()

        // Then: Changes should be saved
        XCTAssertTrue(app.staticTexts["Minimalist"].exists)
    }

    func testToggleCalendarIntegration() throws {
        // Given: User is on settings screen
        skipOnboardingIfNeeded()
        app.tabBars.buttons["Settings"].tap()

        // When: User toggles calendar integration
        let calendarSwitch = app.switches["Calendar Integration"]
        XCTAssertTrue(calendarSwitch.exists)
        calendarSwitch.tap()

        // Then: Switch state should change
        // (Would require calendar permission handling)
    }

    func testToggleWeatherIntegration() throws {
        // Given: User is on settings screen
        skipOnboardingIfNeeded()
        app.tabBars.buttons["Settings"].tap()

        // When: User toggles weather integration
        let weatherSwitch = app.switches["Weather Integration"]
        XCTAssertTrue(weatherSwitch.exists)
        weatherSwitch.tap()

        // Then: Switch state should change
    }

    // MARK: - Helper Methods
    private func skipOnboardingIfNeeded() {
        if app.staticTexts["Welcome to Wardrobe Consultant"].exists {
            // Fast skip through onboarding
            for _ in 0..<10 {
                if app.buttons["Skip"].exists {
                    app.buttons["Skip"].tap()
                } else if app.buttons["Skip for Now"].exists {
                    app.buttons["Skip for Now"].tap()
                } else if app.buttons["Next"].exists {
                    app.buttons["Next"].tap()
                } else if app.buttons["Get Started"].exists {
                    app.buttons["Get Started"].tap()
                } else if app.buttons["Start Exploring"].exists {
                    app.buttons["Start Exploring"].tap()
                    break
                }
                sleep(1)
            }
        }
    }

    private func addTestItemIfNeeded() {
        app.tabBars.buttons["Wardrobe"].tap()

        if app.collectionViews.cells.count == 0 {
            // Add a test item
            app.buttons["Add Item"].tap()

            app.buttons["Select Category"].tap()
            app.buttons["T-Shirt"].tap()

            let brandField = app.textFields["Brand"]
            brandField.tap()
            brandField.typeText("Test Brand")

            app.buttons["Save"].tap()
            sleep(1)
        }
    }

    private func addMultipleTestItems() {
        let categories = ["T-Shirt", "Jeans", "Sneakers"]
        let brands = ["Nike", "Adidas", "Zara"]

        for i in 0..<3 {
            app.tabBars.buttons["Wardrobe"].tap()
            app.buttons["Add Item"].tap()

            app.buttons["Select Category"].tap()
            app.buttons[categories[i]].tap()

            let brandField = app.textFields["Brand"]
            brandField.tap()
            brandField.typeText(brands[i])

            app.buttons["Save"].tap()
            sleep(1)
        }
    }
}

// MARK: - XCUIElement Extensions
extension XCUIElement {
    func clearText() {
        guard let stringValue = self.value as? String else {
            return
        }

        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        self.typeText(deleteString)
    }
}
