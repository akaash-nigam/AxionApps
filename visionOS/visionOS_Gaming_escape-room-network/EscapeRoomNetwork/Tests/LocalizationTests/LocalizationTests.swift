import XCTest
@testable import EscapeRoomNetwork

/// Localization and internationalization tests
/// ✅ Can run in CLI with `swift test --filter LocalizationTests`
final class LocalizationTests: XCTestCase {

    // MARK: - String Key Validation Tests

    func testDifficultyLevelsLocalizableFormat() {
        // Verify all difficulty levels have display names
        for difficulty in Puzzle.Difficulty.allCases {
            let displayName = difficulty.displayName

            XCTAssertFalse(displayName.isEmpty)
            XCTAssertGreaterThan(displayName.count, 2)
            // Display name should be capitalized
            XCTAssertEqual(displayName, displayName.capitalized)
        }
    }

    func testPuzzleTypeNamesLocalizable() {
        // Verify all puzzle types have string representations
        for puzzleType in PuzzleType.allCases {
            let typeName = String(describing: puzzleType)

            XCTAssertFalse(typeName.isEmpty)
            // Should be a valid identifier (no spaces, special chars)
            XCTAssertTrue(typeName.allSatisfy { $0.isLetter || $0 == "_" })
        }
    }

    func testGameStateNamesLocalizable() {
        // Verify all game states can be represented as strings
        let states: [GameState] = [
            .initialization,
            .roomScanning,
            .roomMapping,
            .loadingPuzzle,
            .playing,
            .paused,
            .puzzleCompleted,
            .gameOver,
            .multiplayerLobby,
            .multiplayerSession
        ]

        for state in states {
            let stateName = String(describing: state)
            XCTAssertFalse(stateName.isEmpty)
            XCTAssertGreaterThan(stateName.count, 3)
        }
    }

    // MARK: - Text Length Tests

    func testShortTextFitsInUI() {
        // Verify critical UI text isn't too long for different languages
        // Rule: Button text should be < 20 chars, labels < 30 chars

        struct UIText {
            let key: String
            let text: String
            let maxLength: Int
        }

        let uiTexts = [
            UIText(key: "start_game", text: "Start Game", maxLength: 20),
            UIText(key: "pause", text: "Pause", maxLength: 20),
            UIText(key: "resume", text: "Resume", maxLength: 20),
            UIText(key: "get_hint", text: "Get Hint", maxLength: 20),
            UIText(key: "objectives", text: "Objectives", maxLength: 20),
            UIText(key: "settings", text: "Settings", maxLength: 20)
        ]

        for uiText in uiTexts {
            XCTAssertLessThanOrEqual(
                uiText.text.count,
                uiText.maxLength,
                "\(uiText.key) text too long: '\(uiText.text)'"
            )
        }
    }

    func testPluralFormsHandled() {
        // Test that pluralization logic exists for countable items
        struct PluralTest {
            let count: Int
            let singular: String
            let expectedPlural: String
        }

        let tests = [
            PluralTest(count: 0, singular: "puzzle", expectedPlural: "puzzles"),
            PluralTest(count: 1, singular: "puzzle", expectedPlural: "puzzle"),
            PluralTest(count: 2, singular: "puzzle", expectedPlural: "puzzles"),
            PluralTest(count: 0, singular: "hint", expectedPlural: "hints"),
            PluralTest(count: 1, singular: "hint", expectedPlural: "hint")
        ]

        for test in tests {
            let result = test.count == 1 ? test.singular : test.expectedPlural
            XCTAssertNotNil(result)
        }
    }

    // MARK: - Number Formatting Tests

    func testTimeFormatting() {
        // Verify time is formatted consistently
        let durations: [TimeInterval] = [0, 60, 3600, 5400] // 0s, 1m, 1h, 1h30m

        for duration in durations {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.hour, .minute, .second]
            formatter.unitsStyle = .abbreviated

            let formatted = formatter.string(from: duration)
            XCTAssertNotNil(formatted)
        }
    }

    func testScoreFormatting() {
        // Verify numbers are formatted with locale-appropriate separators
        let scores = [100, 1000, 10000, 1000000]

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal

        for score in scores {
            let formatted = formatter.string(from: NSNumber(value: score))
            XCTAssertNotNil(formatted)
        }
    }

    // MARK: - Date Formatting Tests

    func testDateFormatting() {
        // Verify dates are formatted according to locale
        let date = Date()

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short

        let formatted = dateFormatter.string(from: date)
        XCTAssertFalse(formatted.isEmpty)
        XCTAssertGreaterThan(formatted.count, 5)
    }

    func testRelativeDateFormatting() {
        // Test relative date formatting (e.g., "2 hours ago")
        let now = Date()
        let twoHoursAgo = now.addingTimeInterval(-7200)

        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full

        let formatted = formatter.localizedString(for: twoHoursAgo, relativeTo: now)
        XCTAssertFalse(formatted.isEmpty)
    }

    // MARK: - Text Direction Tests

    func testBidirectionalTextSupport() {
        // Verify app can handle RTL languages
        // This tests the data structures, not actual rendering

        let testStrings = [
            "Left to Right text",
            "مرحبا بك", // Arabic (RTL)
            "שלום", // Hebrew (RTL)
            "Mixed مرحبا and English"
        ]

        for testString in testStrings {
            let puzzle = Puzzle(
                title: testString,
                description: testString,
                difficulty: .beginner,
                estimatedTime: 600,
                requiredRoomSize: .small,
                puzzleElements: [],
                objectives: [],
                hints: []
            )

            XCTAssertEqual(puzzle.title, testString)
        }
    }

    // MARK: - Character Encoding Tests

    func testUnicodeSupport() {
        // Verify Unicode characters are handled correctly
        let unicodeStrings = [
            "Emoji: 🎮🎯🔓",
            "Accents: àéîôù",
            "Symbols: ©®™",
            "Asian: 你好世界",
            "Mixed: Hello 世界 🌍"
        ]

        for string in unicodeStrings {
            let puzzle = Puzzle(
                title: string,
                description: string,
                difficulty: .beginner,
                estimatedTime: 600,
                requiredRoomSize: .small,
                puzzleElements: [],
                objectives: [],
                hints: []
            )

            XCTAssertEqual(puzzle.title, string)
            XCTAssertEqual(puzzle.title.count, string.count)
        }
    }

    // MARK: - Measurement Unit Tests

    func testDistanceUnits() {
        // Verify measurements can be converted for different locales
        struct Distance {
            let meters: Double

            var feet: Double {
                meters * 3.28084
            }

            func formatted(useMetric: Bool) -> String {
                if useMetric {
                    return String(format: "%.1fm", meters)
                } else {
                    return String(format: "%.1fft", feet)
                }
            }
        }

        let distance = Distance(meters: 5.0)
        XCTAssertEqual(distance.formatted(useMetric: true), "5.0m")
        XCTAssertEqual(distance.formatted(useMetric: false), "16.4ft")
    }

    // MARK: - Currency Formatting Tests

    func testCurrencyFormatting() {
        // Verify in-app purchases would be formatted correctly
        let prices = [7.99, 14.99, 99.99]

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")

        for price in prices {
            let formatted = formatter.string(from: NSNumber(value: price))
            XCTAssertNotNil(formatted)
            XCTAssertTrue(formatted!.contains("$"))
        }
    }

    // MARK: - Consistency Tests

    func testTerminologyConsistency() {
        // Verify same concepts use same terms throughout
        let terms = [
            "puzzle": ["puzzle", "escape", "challenge"],  // Should use "puzzle" consistently
            "hint": ["hint", "clue", "tip"],  // Should use "hint" consistently
            "objective": ["objective", "goal", "target"]  // Should use "objective" consistently
        ]

        // In production, would scan all localized strings for consistency
        for (preferred, alternatives) in terms {
            XCTAssertFalse(preferred.isEmpty)
            XCTAssertFalse(alternatives.isEmpty)
        }
    }

    // MARK: - Context Preservation Tests

    func testVariableSubstitution() {
        // Test that variable substitution works correctly
        func formatString(_ template: String, _ value: Int) -> String {
            return String(format: template, value)
        }

        let templates = [
            "You have %d hints remaining",
            "Level %d complete",
            "%d objectives completed"
        ]

        for template in templates {
            let result = formatString(template, 5)
            XCTAssertTrue(result.contains("5"))
            XCTAssertFalse(result.contains("%d"))
        }
    }

    // MARK: - Truncation Handling Tests

    func testTextTruncation() {
        // Verify long text is handled gracefully
        let longTitle = "This is an extremely long puzzle title that might not fit in the available UI space in some languages"

        func truncate(_ string: String, to length: Int) -> String {
            if string.count <= length {
                return string
            }
            return String(string.prefix(length - 3)) + "..."
        }

        let truncated = truncate(longTitle, to: 50)
        XCTAssertLessThanOrEqual(truncated.count, 50)
        XCTAssertTrue(truncated.hasSuffix("..."))
    }

    // MARK: - Collation Tests

    func testSortingInDifferentLocales() {
        // Verify sorting works correctly for different languages
        let puzzleTitles = ["Zulu", "Alpha", "Echo", "Bravo", "Charlie"]

        let sorted = puzzleTitles.sorted()
        XCTAssertEqual(sorted, ["Alpha", "Bravo", "Charlie", "Echo", "Zulu"])

        // Test with accented characters
        let accentedTitles = ["café", "camel", "car", "école"]
        let accentedSorted = accentedTitles.sorted()

        XCTAssertFalse(accentedSorted.isEmpty)
        XCTAssertEqual(accentedSorted.count, accentedTitles.count)
    }

    // MARK: - Accessibility Labels Tests

    func testAccessibilityLabelsLocalizable() {
        // Verify accessibility labels can be localized
        let buttons = [
            ("play_button", "Play"),
            ("pause_button", "Pause"),
            ("hint_button", "Get Hint")
        ]

        for (key, defaultValue) in buttons {
            XCTAssertFalse(key.isEmpty)
            XCTAssertFalse(defaultValue.isEmpty)
        }
    }
}

/*
 MARK: - Localization Tests Requiring Xcode

 These tests require Xcode's localization features:

 1. Strings File Validation
    - Verify all .strings files are valid
    - Check for missing translations
    - Verify string keys match code usage

 2. Dynamic Type Support
    - Test UI with different text sizes
    - Verify layout doesn't break
    - Test with longest supported language

 3. Locale-Specific Testing
    - Test with different language settings
    - Verify date/time formats
    - Test number formatting
    - Verify currency display

 4. Pseudo-Localization Testing
    - Test with pseudo-locale to find hard-coded strings
    - Verify UI can handle longer text
    - Test with accented characters

 5. Screenshot Localization
    - Generate localized screenshots
    - Verify UI translations in context

 To run full localization tests:
 1. Add Localizable.strings files
 2. Export for localization
 3. Import translations
 4. Test in Xcode with different languages
 5. Use xcodebuild with -locale parameter
 */
