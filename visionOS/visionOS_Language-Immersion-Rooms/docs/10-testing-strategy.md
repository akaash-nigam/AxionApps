# Testing Strategy

## Testing Pyramid

```
       /\
      /  \  E2E Tests (5%)
     /────\
    /      \ Integration Tests (15%)
   /────────\
  /          \ Unit Tests (80%)
 /────────────\
```

## Unit Testing

### Test Coverage Goals
- **Target**: 80% code coverage
- **Critical paths**: 100% coverage (auth, payments, data persistence)
- **UI code**: 60% coverage (SwiftUI previews + snapshot tests)

### XCTest Setup

```swift
import XCTest
@testable import LanguageImmersionRooms

class VocabularyServiceTests: XCTestCase {
    var sut: VocabularyService!
    var mockLanguageService: MockLanguageService!

    override func setUp() {
        super.setUp()
        mockLanguageService = MockLanguageService()
        sut = VocabularyService(languageService: mockLanguageService)
    }

    override func tearDown() {
        sut = nil
        mockLanguageService = nil
        super.tearDown()
    }

    func testTranslation_ValidWord_ReturnsTranslation() async throws {
        // Given
        let word = "table"
        let expected = "mesa"
        mockLanguageService.stubbedTranslation = expected

        // When
        let result = try await sut.translate(word, from: .english, to: .spanish)

        // Then
        XCTAssertEqual(result, expected)
        XCTAssertTrue(mockLanguageService.translateCalled)
    }

    func testTranslation_InvalidWord_ThrowsError() async {
        // Given
        mockLanguageService.shouldThrowError = true

        // When/Then
        await XCTAssertThrowsError(
            try await sut.translate("", from: .english, to: .spanish)
        )
    }
}
```

### Mock Objects

```swift
class MockAIService: AIServiceProtocol {
    var generateResponseCalled = false
    var stubbedResponse: String = "Hola, ¿cómo estás?"
    var shouldThrowError = false

    func generateResponse(
        to message: String,
        context: [ConversationMessage]
    ) async throws -> String {
        generateResponseCalled = true

        if shouldThrowError {
            throw AIError.apiError
        }

        return stubbedResponse
    }
}

class MockSpeechService: SpeechServiceProtocol {
    var recognizeCalled = false
    var stubbedTranscription: String = "Hola"

    func recognize(audioURL: URL, language: String) async throws -> String {
        recognizeCalled = true
        return stubbedTranscription
    }
}
```

## Integration Testing

### Service Integration Tests

```swift
class AIServiceIntegrationTests: XCTestCase {
    var aiService: OpenAIService!

    override func setUp() {
        super.setUp()
        // Use test API key
        let config = AIServiceConfig(apiKey: TestConfig.openAITestKey)
        aiService = OpenAIService(config: config)
    }

    func testRealAPICall_GeneratesValidResponse() async throws {
        // Given
        let message = "Hello"
        let context: [ConversationMessage] = []

        // When
        let response = try await aiService.generateResponse(to: message, context: context)

        // Then
        XCTAssertFalse(response.isEmpty)
        XCTAssertTrue(response.count > 10) // Reasonable response length
    }
}
```

### Database Integration Tests

```swift
class CoreDataIntegrationTests: XCTestCase {
    var container: NSPersistentContainer!

    override func setUp() {
        super.setUp()
        container = NSPersistentContainer(name: "LanguageImmersionRooms")
        container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        container.loadPersistentStores { _, error in
            XCTAssertNil(error)
        }
    }

    func testSaveAndFetch_VocabularyWord() throws {
        let context = container.viewContext

        // Given
        let word = VocabularyWordEntity(context: context)
        word.id = UUID()
        word.word = "mesa"
        word.translation = "table"

        // When
        try context.save()

        let fetchRequest: NSFetchRequest<VocabularyWordEntity> = VocabularyWordEntity.fetchRequest()
        let results = try context.fetch(fetchRequest)

        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.word, "mesa")
    }
}
```

## UI Testing

### XCUITest

```swift
class MainMenuUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]
        app.launch()
    }

    func testStartLearningSession() {
        // Given: User is on main menu
        XCTAssertTrue(app.buttons["Start Session"].exists)

        // When: User taps start
        app.buttons["Start Session"].tap()

        // Then: Immersive space launches
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "exists == true"),
            object: app.otherElements["ImmersiveSpace"]
        )
        wait(for: [expectation], timeout: 5)
    }

    func testNavigateToSettings() {
        // When
        app.buttons["Settings"].tap()

        // Then
        XCTAssertTrue(app.navigationBars["Settings"].exists)
        XCTAssertTrue(app.switches["High Contrast"].exists)
    }
}
```

### Snapshot Testing

```swift
import SnapshotTesting

class ViewSnapshotTests: XCTestCase {
    func testMainMenuView_LightMode() {
        let view = MainMenuView()
            .environmentObject(AppState.preview)

        assertSnapshot(matching: view, as: .image(layout: .device(config: .visionPro)))
    }

    func testGrammarCard_ErrorState() {
        let card = GrammarCardView(card: .mockError)

        assertSnapshot(matching: card, as: .image(precision: 0.98))
    }
}
```

## RealityKit Testing

### Entity Testing

```swift
class ObjectLabelEntityTests: XCTestCase {
    func testLabelEntity_Creation() {
        // Given
        let word = VocabularyWord.mock
        let anchor = AnchorEntity()

        // When
        let label = ObjectLabelEntity(word: word, anchor: anchor)

        // Then
        XCTAssertNotNil(label.labelComponent)
        XCTAssertEqual(label.labelComponent.text, word.word)
    }

    func testLabelEntity_ShowAnimation() {
        // Given
        let label = ObjectLabelEntity.mock
        label.transform.scale = [0, 0, 0]

        // When
        label.showWithAnimation()

        // Then (check after animation completes)
        let expectation = XCTestExpectation(description: "Animation completes")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertEqual(label.transform.scale, [1, 1, 1])
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
}
```

## Performance Testing

### Measure Performance

```swift
class PerformanceTests: XCTestCase {
    func testObjectDetection_Performance() {
        let detector = ObjectDetector()
        let image = TestImages.kitchenScene

        measure {
            _ = try? detector.detectObjects(in: image)
        }
        // Baseline: 50ms
    }

    func testSceneLoading_Performance() {
        let manager = SceneManager.test

        measure {
            _ = try? manager.loadEnvironment(.parisianCafe)
        }
        // Baseline: 3 seconds
    }
}
```

### Memory Testing

```swift
class MemoryTests: XCTestCase {
    func testConversation_MemoryLeak() {
        weak var weakConversation: ConversationState?

        autoreleasepool {
            let conversation = ConversationState()
            weakConversation = conversation
            // Simulate conversation
        }

        XCTAssertNil(weakConversation, "Conversation should be deallocated")
    }
}
```

## Accessibility Testing

```swift
class AccessibilityTests: XCTestCase {
    func testVoiceOver_Labels() {
        let view = MainMenuView()

        // All interactive elements should have labels
        XCTAssertNotNil(view.button("Start Session").accessibilityLabel)
        XCTAssertNotNil(view.button("Settings").accessibilityLabel)
    }

    func testColorContrast() {
        let label = ObjectLabelView(text: "mesa")

        // Test color contrast ratio
        let ratio = calculateContrastRatio(
            foreground: label.textColor,
            background: label.backgroundColor
        )

        XCTAssertGreaterThan(ratio, 4.5) // WCAG AA standard
    }
}
```

## Test Data Fixtures

```swift
extension UserProfile {
    static var mock: UserProfile {
        UserProfile(
            id: UUID(),
            username: "testuser",
            email: "test@example.com",
            nativeLanguage: .english,
            targetLanguages: [
                LanguageProgress.mockSpanish
            ],
            proficiencyLevel: .intermediate,
            preferences: .default,
            subscriptionTier: .premium,
            totalStudyTime: 3600,
            currentStreak: 7,
            longestStreak: 14,
            lastActiveDate: Date(),
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}

extension VocabularyWord {
    static var mock: VocabularyWord {
        VocabularyWord(
            id: UUID(),
            word: "mesa",
            language: .spanish,
            translation: "table",
            partOfSpeech: .noun,
            exampleSentences: ["La mesa es roja."],
            ipa: "/ˈme.sa/",
            frequency: .veryCommon,
            difficulty: .beginner,
            category: [.home],
            learningState: .learning,
            addedDate: Date(),
            reviewCount: 3,
            correctCount: 2,
            incorrectCount: 1,
            easinessFactor: 2.5,
            interval: 1
        )
    }
}
```

## Continuous Integration

### GitHub Actions Workflow

```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v3

      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode_16.0.app

      - name: Build
        run: xcodebuild build -scheme LanguageImmersionRooms -destination 'platform=visionOS Simulator,name=Apple Vision Pro'

      - name: Run tests
        run: xcodebuild test -scheme LanguageImmersionRooms -destination 'platform=visionOS Simulator,name=Apple Vision Pro' -resultBundlePath TestResults

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./TestResults/Coverage.xcresult
```

## Test Coverage Report

```bash
# Generate coverage report
xcodebuild test \
  -scheme LanguageImmersionRooms \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -enableCodeCoverage YES \
  -resultBundlePath ./TestResults

# Convert to HTML
xcrun xccov view --report --only-targets ./TestResults.xcresult > coverage.txt
```

## Testing Checklist

- [ ] All public methods have unit tests
- [ ] All ViewModels have unit tests
- [ ] Critical user flows have UI tests
- [ ] All API integrations have integration tests
- [ ] Performance benchmarks established
- [ ] Memory leaks checked
- [ ] Accessibility tested
- [ ] Edge cases covered
- [ ] Error handling tested
- [ ] Localization tested for all languages
