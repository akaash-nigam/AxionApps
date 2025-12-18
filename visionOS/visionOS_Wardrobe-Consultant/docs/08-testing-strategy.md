# Testing Strategy & QA Plan

## Document Overview

**Version**: 1.0
**Last Updated**: 2025-11-24
**Status**: Draft

## 1. Executive Summary

This document defines the comprehensive testing strategy for Wardrobe Consultant, covering unit tests, integration tests, UI tests, AR/3D rendering validation, performance testing, and quality assurance processes. Given the complexity of AR body tracking and ML inference, thorough testing is critical for delivering a reliable user experience.

## 2. Testing Pyramid

```
                    /\
                   /  \
                  /Manual\          10% - Exploratory testing
                 /--------\
                /  E2E/UI  \        20% - End-to-end scenarios
               /------------\
              / Integration  \      30% - Component integration
             /----------------\
            /   Unit Tests     \    40% - Individual components
           /--------------------\
```

## 3. Unit Testing Strategy

### 3.1 Coverage Goals

**Target Coverage**: 80% overall
- **Critical Paths**: 95% (data models, business logic)
- **UI Code**: 60% (ViewModels, coordinators)
- **Utilities**: 90% (helpers, extensions)

### 3.2 Unit Test Structure

```swift
import XCTest
@testable import WardrobeConsultant

class WardrobeItemTests: XCTestCase {
    var sut: WardrobeItem! // System Under Test
    var mockRepository: MockWardrobeRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockWardrobeRepository()
        sut = WardrobeItem(context: mockContext)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - Test Cases
    func testWardrobeItemInitialization() {
        // Given
        let name = "Blue Shirt"
        let category = ClothingCategory.shirt

        // When
        sut.name = name
        sut.category = category.rawValue

        // Then
        XCTAssertEqual(sut.name, name)
        XCTAssertEqual(sut.category, category.rawValue)
        XCTAssertNotNil(sut.id)
        XCTAssertNotNil(sut.createdAt)
    }

    func testTimesWornIncrement() {
        // Given
        sut.timesWorn = 5

        // When
        sut.timesWorn += 1

        // Then
        XCTAssertEqual(sut.timesWorn, 6)
    }

    func testInvalidColorHex() {
        // Given
        let invalidHex = "not-a-color"

        // When/Then
        XCTAssertThrowsError(try sut.setPrimaryColor(invalidHex)) { error in
            XCTAssertTrue(error is ValidationError)
        }
    }
}
```

### 3.3 Critical Components to Unit Test

**Data Models**:
- WardrobeItem validation
- Outfit validation
- UserProfile validation
- Relationship integrity

**Business Logic**:
- Style recommendation algorithm
- Color harmony rules
- Weather appropriateness logic
- Dress code classification
- Size recommendation

**Services**:
- Weather service (with mocks)
- Calendar service (with mocks)
- ML inference service (with mocks)

**Repositories**:
- Core Data CRUD operations
- CloudKit sync logic
- Query performance

**ViewModels**:
- State management
- User action handling
- Data transformation

### 3.4 Mock Objects

```swift
// MARK: - Mock Repository
class MockWardrobeRepository: WardrobeRepository {
    var items: [WardrobeItem] = []
    var shouldThrowError = false

    func fetchAll() async throws -> [WardrobeItem] {
        if shouldThrowError {
            throw RepositoryError.fetchFailed
        }
        return items
    }

    func create(_ item: WardrobeItem) async throws -> WardrobeItem {
        if shouldThrowError {
            throw RepositoryError.createFailed
        }
        items.append(item)
        return item
    }

    func delete(id: UUID) async throws {
        items.removeAll { $0.id == id }
    }
}

// MARK: - Mock Weather Service
class MockWeatherService: WeatherService {
    var mockWeather: CurrentWeather?
    var shouldFail = false

    func getCurrentWeather(for location: CLLocation) async throws -> CurrentWeather {
        if shouldFail {
            throw WeatherServiceError.weatherDataUnavailable
        }
        return mockWeather ?? defaultWeather()
    }

    private func defaultWeather() -> CurrentWeather {
        CurrentWeather(
            temperature: Measurement(value: 72, unit: .fahrenheit),
            feelsLike: Measurement(value: 70, unit: .fahrenheit),
            condition: .clear,
            humidity: 0.5,
            windSpeed: Measurement(value: 5, unit: .milesPerHour),
            precipitationProbability: 0.1,
            uvIndex: 6,
            timestamp: Date()
        )
    }
}
```

## 4. Integration Testing

### 4.1 Integration Test Scenarios

**Data Layer Integration**:
- Core Data ↔ CloudKit sync
- Repository ↔ Core Data stack
- File system ↔ Photo storage

**Service Integration**:
- WeatherKit API integration
- EventKit API integration
- ML model inference pipeline

**Feature Integration**:
- Add wardrobe item: Photo → ML classification → Core Data → UI
- Outfit suggestion: Weather + Calendar + Wardrobe → Recommendations
- Virtual try-on: Body tracking → 3D rendering → User interaction

### 4.2 Integration Test Example

```swift
class OutfitGenerationIntegrationTests: XCTestCase {
    var repository: WardrobeRepository!
    var weatherService: WeatherService!
    var calendarService: CalendarService!
    var styleEngine: StyleRecommendationService!
    var useCase: GenerateOutfitSuggestionsUseCase!

    override func setUp() {
        super.setUp()

        // Setup real implementations (or test doubles)
        repository = CoreDataWardrobeRepository(context: testContext)
        weatherService = MockWeatherService()
        calendarService = MockCalendarService()
        styleEngine = RuleBasedStyleEngine()

        useCase = GenerateOutfitSuggestionsUseCase(
            wardrobeRepository: repository,
            weatherService: weatherService,
            calendarService: calendarService,
            styleEngine: styleEngine
        )
    }

    func testEndToEndOutfitGeneration() async throws {
        // Given: Wardrobe with items
        let shirt = createTestItem(category: .shirt, color: "#4169E1")
        let pants = createTestItem(category: .pants, color: "#000000")
        try await repository.create(shirt)
        try await repository.create(pants)

        // And: Weather context
        let mockWeather = (weatherService as! MockWeatherService)
        mockWeather.mockWeather = createTestWeather(temp: 72)

        // And: Calendar context
        let mockCalendar = (calendarService as! MockCalendarService)
        mockCalendar.mockEvents = [createTestEvent(title: "Work Meeting")]

        // When: Generate outfits
        let outfits = try await useCase.execute()

        // Then: Outfits are generated
        XCTAssertFalse(outfits.isEmpty)
        XCTAssertTrue(outfits.count <= 10)

        // And: Outfits contain appropriate items
        let firstOutfit = outfits[0]
        XCTAssertTrue(firstOutfit.items.contains(shirt))
        XCTAssertTrue(firstOutfit.items.contains(pants))

        // And: Outfit is appropriate for context
        XCTAssertEqual(firstOutfit.occasionType, OccasionType.work.rawValue)
    }
}
```

## 5. UI Testing

### 5.1 UI Test Strategy

**Focus Areas**:
- Critical user flows
- Navigation paths
- Error states
- Accessibility

**Tools**:
- XCTest UI Testing
- Snapshot testing for visual regression

### 5.2 UI Test Example

```swift
class OnboardingUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting", "--reset-data"]
        app.launch()
    }

    func testCompleteOnboardingFlow() {
        // Welcome screen
        XCTAssertTrue(app.staticTexts["Welcome to Wardrobe Consultant"].exists)
        app.buttons["Get Started"].tap()

        // Body measurement setup
        XCTAssertTrue(app.staticTexts["Body Measurements"].exists)
        app.textFields["Height"].tap()
        app.textFields["Height"].typeText("70")
        app.buttons["Next"].tap()

        // Style quiz
        XCTAssertTrue(app.staticTexts["What's Your Style?"].exists)
        app.buttons["Minimalist"].tap()
        app.buttons["Next"].tap()

        // Permission requests
        // (Mocked in UI tests)
        app.buttons["Enable Camera"].tap()
        app.buttons["Enable Calendar"].tap()

        // Complete
        XCTAssertTrue(app.staticTexts["You're All Set!"].exists)
        app.buttons["Start Styling"].tap()

        // Should reach home screen
        XCTAssertTrue(app.tabBars.buttons["Home"].exists)
    }

    func testAddWardrobeItem() {
        navigateToWardrobeTab()

        // Tap add button
        app.buttons["Add Item"].tap()

        // Choose photo (mocked)
        app.buttons["Choose Photo"].tap()
        // Select photo from test library

        // Verify classification UI appears
        XCTAssertTrue(app.staticTexts["Classifying..."].exists)

        // Wait for classification
        let classifiedLabel = app.staticTexts["Blue Shirt"]
        XCTAssertTrue(classifiedLabel.waitForExistence(timeout: 5))

        // Save item
        app.buttons["Save"].tap()

        // Verify item appears in wardrobe
        XCTAssertTrue(app.collectionViews.cells.staticTexts["Blue Shirt"].exists)
    }

    func testVirtualTryOn() {
        navigateToHomeTab()

        // Select an outfit suggestion
        app.collectionViews.cells.element(boundBy: 0).tap()

        // Tap try on
        app.buttons["Try On"].tap()

        // Should enter immersive space
        // (Difficult to test AR in UI tests, verify UI elements)
        XCTAssertTrue(app.buttons["Close"].exists)
        XCTAssertTrue(app.staticTexts["Current Outfit"].exists)

        // Exit virtual try-on
        app.buttons["Close"].tap()

        // Should return to previous screen
        XCTAssertTrue(app.tabBars.buttons["Home"].exists)
    }

    private func navigateToWardrobeTab() {
        app.tabBars.buttons["Wardrobe"].tap()
        XCTAssertTrue(app.navigationBars["Wardrobe"].exists)
    }

    private func navigateToHomeTab() {
        app.tabBars.buttons["Home"].tap()
        XCTAssertTrue(app.navigationBars["Home"].exists)
    }
}
```

### 5.3 Accessibility Testing

```swift
class AccessibilityTests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launch()
    }

    func testVoiceOverLabels() {
        // Test critical elements have accessibility labels
        let addButton = app.buttons["Add Item"]
        XCTAssertTrue(addButton.exists)
        XCTAssertNotNil(addButton.label)

        let favoriteButton = app.buttons["Favorite"]
        XCTAssertTrue(favoriteButton.isAccessibilityElement)
        XCTAssertEqual(favoriteButton.accessibilityTraits, .button)
    }

    func testDynamicTypeSupport() {
        // Test UI adapts to different text sizes
        // (Requires manual testing or snapshot tests)
    }

    func testColorContrastRatio() {
        // Use snapshot testing with contrast analysis
    }
}
```

## 6. AR/3D Rendering Testing

### 6.1 AR Testing Challenges

**Challenges**:
- Requires physical device
- Needs real-world environment
- Difficult to automate
- Lighting conditions vary

**Approach**:
- Unit tests for AR logic
- Manual testing for AR experience
- Synthetic data for body tracking tests

### 6.2 Body Tracking Tests

```swift
class BodyTrackingTests: XCTestCase {
    var trackingManager: ARBodyTrackingManager!

    override func setUp() {
        super.setUp()
        trackingManager = ARBodyTrackingManager()
    }

    func testBodyMeasurementExtraction() {
        // Given: Synthetic body anchor
        let mockBodyAnchor = createMockBodyAnchor()

        // When: Extract measurements
        let extractor = BodyMeasurementExtractor()
        let measurements = extractor.extractMeasurements(from: mockBodyAnchor)

        // Then: Measurements are reasonable
        XCTAssertNotNil(measurements)
        XCTAssertGreaterThan(measurements!.height.value, 1.0) // > 1 meter
        XCTAssertLessThan(measurements!.height.value, 2.5) // < 2.5 meters
        XCTAssertGreaterThan(measurements!.confidence, 0.5)
    }

    func testClothingAttachment() {
        // Given: Body anchor and clothing model
        let bodyAnchor = createMockBodyAnchor()
        let clothingModel = createTestClothingModel()
        let item = createTestWardrobeItem()

        // When: Attach clothing to body
        let attachmentSystem = ClothingAttachmentSystem()
        attachmentSystem.attachClothingToBody(clothingModel, bodyAnchor: bodyAnchor, item: item)

        // Then: Clothing is positioned correctly
        XCTAssertNotNil(clothingModel.transform)
        // Verify position is near body center
    }

    func testRenderingFrameRate() {
        // Measure rendering performance
        measure(metrics: [XCTClockMetric()]) {
            // Simulate frame updates
            for _ in 0..<60 {
                trackingManager.updateFrame()
            }
        }
        // Assert average frame time < 16.67ms (60fps)
    }
}
```

### 6.3 3D Model Loading Tests

```swift
class ClothingModelLoaderTests: XCTestCase {
    var loader: ClothingModelLoader!

    override func setUp() {
        super.setUp()
        loader = ClothingModelLoader()
    }

    func testModelLoadingPerformance() async throws {
        // Given: Test wardrobe item
        let item = createTestWardrobeItem()

        // When: Load model
        let start = Date()
        let model = try await loader.loadModel(for: item)
        let elapsed = Date().timeIntervalSince(start)

        // Then: Load time is acceptable
        XCTAssertNotNil(model)
        XCTAssertLessThan(elapsed, 2.0) // < 2 seconds
    }

    func testModelCaching() async throws {
        // Given: Same item loaded twice
        let item = createTestWardrobeItem()

        // When: Load model first time
        _ = try await loader.loadModel(for: item)

        // And: Load model second time
        let start = Date()
        let model = try await loader.loadModel(for: item)
        let elapsed = Date().timeIntervalSince(start)

        // Then: Second load is faster (cached)
        XCTAssertLessThan(elapsed, 0.1) // < 100ms
        XCTAssertNotNil(model)
    }
}
```

## 7. Machine Learning Testing

### 7.1 ML Model Accuracy Tests

```swift
class ClothingClassificationTests: XCTestCase {
    var service: ClothingClassificationService!

    override func setUp() {
        super.setUp()
        service = ClothingClassificationService()
    }

    func testShirtClassification() async throws {
        // Given: Test images with known labels
        let testCases = [
            ("blue_shirt.jpg", ClothingCategory.shirt, "#4169E1"),
            ("red_dress.jpg", ClothingCategory.dress, "#FF0000"),
            ("black_pants.jpg", ClothingCategory.pants, "#000000")
        ]

        for (imageName, expectedCategory, expectedColor) in testCases {
            // When: Classify image
            let image = UIImage(named: imageName, in: testBundle, with: nil)!
            let result = try await service.classifyClothing(image: image)

            // Then: Classification is correct
            XCTAssertEqual(result.category, expectedCategory)
            XCTAssertTrue(result.colors.contains(expectedColor))
            XCTAssertGreaterThan(result.confidence, 0.7)
        }
    }

    func testInferenceSpeed() async throws {
        // Given: Test image
        let image = UIImage(named: "test_shirt")!

        // When: Measure inference time
        let start = Date()
        _ = try await service.classifyClothing(image: image)
        let elapsed = Date().timeIntervalSince(start)

        // Then: Inference is fast enough
        XCTAssertLessThan(elapsed, 0.2) // < 200ms
    }

    func testBatchAccuracy() async throws {
        // Test on larger dataset
        let testDataset = loadTestDataset() // 100+ images

        var correctPredictions = 0
        for (image, groundTruth) in testDataset {
            let result = try await service.classifyClothing(image: image)
            if result.category == groundTruth.category {
                correctPredictions += 1
            }
        }

        let accuracy = Float(correctPredictions) / Float(testDataset.count)
        XCTAssertGreaterThan(accuracy, 0.85) // 85% accuracy target
    }
}
```

### 7.2 Recommendation Quality Tests

```swift
class StyleRecommendationTests: XCTestCase {
    var engine: StyleRecommendationService!

    func testRecommendationsAreWeatherAppropriate() async throws {
        // Given: Wardrobe and cold weather
        let wardrobe = createWinterWardrobe()
        let coldWeather = CurrentWeather(temperature: Measurement(value: 32, unit: .fahrenheit), ...)

        // When: Generate recommendations
        let outfits = try await engine.generateOutfits(
            wardrobe: wardrobe,
            weather: coldWeather,
            events: [],
            profile: defaultProfile()
        )

        // Then: Recommended outfits include warm items
        for outfit in outfits {
            let hasWarmLayer = outfit.items.contains { item in
                [ClothingCategory.coat, .sweater, .jacket].contains(ClothingCategory(rawValue: item.category))
            }
            XCTAssertTrue(hasWarmLayer, "Cold weather outfit should include warm layer")
        }
    }

    func testColorHarmony() {
        // Test color harmony rules
        let harmony = ColorHarmonyEngine()

        // Complementary colors should be harmonious
        XCTAssertTrue(harmony.areColorsHarmonious("#FF0000", "#00FF00"))

        // Analogous colors should be harmonious
        XCTAssertTrue(harmony.areColorsHarmonious("#FF0000", "#FF8800"))

        // Clashing colors should not be harmonious
        XCTAssertFalse(harmony.areColorsHarmonious("#FF0000", "#FF00FF"))
    }
}
```

## 8. Performance Testing

### 8.1 Performance Benchmarks

```swift
class PerformanceTests: XCTestCase {
    func testAppLaunchTime() {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            let app = XCUIApplication()
            app.launch()
        }
        // Target: < 2 seconds
    }

    func testWardrobeLoadingPerformance() async throws {
        // Given: Large wardrobe (500 items)
        let repository = createRepositoryWithItems(count: 500)

        // When: Fetch all items
        measure {
            _ = try? await repository.fetchAll()
        }
        // Target: < 1 second
    }

    func testOutfitGenerationPerformance() async throws {
        // Given: Context for outfit generation
        let wardrobe = createLargeWardrobe(itemCount: 200)

        // When: Generate outfits
        measure {
            _ = try? await styleEngine.generateOutfits(
                wardrobe: wardrobe,
                weather: mockWeather,
                events: [],
                profile: mockProfile
            )
        }
        // Target: < 3 seconds
    }

    func testMemoryUsage() {
        measure(metrics: [XCTMemoryMetric()]) {
            // Load typical app state
            let wardrobe = createTypicalWardrobe()
            let outfits = generateTypicalOutfits()
            // ... use data
        }
        // Target: < 200MB for typical usage
    }
}
```

### 8.2 Stress Testing

```swift
class StressTests: XCTestCase {
    func testLargeWardrobeHandling() async throws {
        // Test with maximum wardrobe size (2000 items)
        let repository = WardrobeRepository()

        // Create 2000 items
        for i in 0..<2000 {
            let item = createTestItem(id: i)
            try await repository.create(item)
        }

        // Test operations still performant
        let start = Date()
        let items = try await repository.fetchAll()
        let elapsed = Date().timeIntervalSince(start)

        XCTAssertEqual(items.count, 2000)
        XCTAssertLessThan(elapsed, 2.0) // Should still be fast
    }

    func testConcurrentRequests() async throws {
        // Test concurrent API calls
        await withThrowingTaskGroup(of: Void.self) { group in
            for _ in 0..<10 {
                group.addTask {
                    _ = try await weatherService.getCurrentWeather(for: testLocation)
                }
            }
        }
        // Should not crash or deadlock
    }
}
```

## 9. Manual Testing Checklist

### 9.1 Visual QA

- [ ] UI matches design specifications
- [ ] All text is readable (contrast, size)
- [ ] Images load correctly
- [ ] Animations are smooth
- [ ] No visual glitches or artifacts
- [ ] Dark mode support (if applicable)

### 9.2 Functional Testing

- [ ] Add wardrobe item flow
- [ ] Outfit generation
- [ ] Virtual try-on (AR)
- [ ] Shopping assistant
- [ ] Settings and preferences
- [ ] Data export/delete

### 9.3 Compatibility Testing

- [ ] Vision Pro (various OSversions)
- [ ] Different lighting conditions (AR)
- [ ] Various body types (AR)
- [ ] Multiple languages (if supported)

### 9.4 Edge Cases

- [ ] Empty wardrobe
- [ ] No internet connection
- [ ] Permission denied scenarios
- [ ] Low storage space
- [ ] Poor AR tracking conditions

## 10. Beta Testing Plan

### 10.1 TestFlight Beta

**Beta Phases**:
1. **Internal Beta** (Week 1-2): Dev team + close friends
2. **Closed Beta** (Week 3-4): 100 fashion enthusiasts
3. **Public Beta** (Week 5-6): 1,000 users

**Feedback Collection**:
- In-app feedback form
- Crash reports (automatically collected)
- Survey after 1 week of use
- User interviews (10-15 users)

### 10.2 Beta Test Metrics

| Metric | Target |
|--------|--------|
| Crash-free sessions | > 99% |
| Average session length | > 5 minutes |
| Outfit suggestions used | > 40% |
| Virtual try-on completion | > 70% |
| Net Promoter Score | > 50 |

### 10.3 Beta Feedback Form

```swift
struct BetaFeedbackView: View {
    @State private var rating: Int = 5
    @State private var feedback: String = ""
    @State private var feature: BetaFeature = .virtualTryOn

    var body: some View {
        Form {
            Section("Overall Rating") {
                Picker("Rating", selection: $rating) {
                    ForEach(1...5, id: \.self) { star in
                        Text("\(star) stars")
                    }
                }
            }

            Section("Feature Feedback") {
                Picker("Feature", selection: $feature) {
                    ForEach(BetaFeature.allCases) { feature in
                        Text(feature.rawValue)
                    }
                }
            }

            Section("Comments") {
                TextEditor(text: $feedback)
                    .frame(height: 150)
            }

            Button("Submit Feedback") {
                submitFeedback()
            }
        }
    }
}
```

## 11. Continuous Integration

### 11.1 CI/CD Pipeline

```yaml
# .github/workflows/test.yml
name: Test

on: [push, pull_request]

jobs:
  test:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v3

      - name: Setup Xcode
        uses: maxim-lobanov/setup-xcode@v1
        with:
          xcode-version: '15.2'

      - name: Install Dependencies
        run: |
          # No external dependencies for MVP

      - name: Run Unit Tests
        run: |
          xcodebuild test \
            -scheme WardrobeConsultant \
            -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
            -enableCodeCoverage YES

      - name: Upload Coverage
        uses: codecov/codecov-action@v3
        with:
          token: ${{ secrets.CODECOV_TOKEN }}

      - name: Run SwiftLint
        run: swiftlint lint --reporter github-actions-logging
```

### 11.2 Pre-commit Hooks

```bash
#!/bin/bash
# .git/hooks/pre-commit

# Run SwiftLint
if which swiftlint >/dev/null; then
  swiftlint
else
  echo "warning: SwiftLint not installed"
fi

# Run unit tests
xcodebuild test -scheme WardrobeConsultant -destination 'platform=visionOS Simulator' | xcpretty

# Check exit code
if [ $? -ne 0 ]; then
  echo "Tests failed. Commit aborted."
  exit 1
fi
```

## 12. Test Data Management

### 12.1 Test Fixtures

```swift
class TestDataFactory {
    static func createTestWardrobeItem(
        category: ClothingCategory = .shirt,
        color: String = "#4169E1",
        name: String = "Test Item"
    ) -> WardrobeItem {
        let item = WardrobeItem(context: testContext)
        item.id = UUID()
        item.name = name
        item.category = category.rawValue
        item.primaryColor = color
        item.createdAt = Date()
        item.updatedAt = Date()
        item.timesWorn = 0
        item.condition = ItemCondition.good.rawValue
        return item
    }

    static func createTestOutfit(items: [WardrobeItem]) -> Outfit {
        let outfit = Outfit(context: testContext)
        outfit.id = UUID()
        outfit.items = Set(items)
        outfit.createdAt = Date()
        outfit.occasionType = OccasionType.casual.rawValue
        return outfit
    }
}
```

### 12.2 Test Database

```swift
class TestCoreDataStack {
    static let shared = TestCoreDataStack()

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "WardrobeConsultant")

        // Use in-memory store for testing
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Test Core Data stack failed: \(error)")
            }
        }

        return container
    }()

    var testContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func reset() {
        let entities = persistentContainer.managedObjectModel.entities
        for entity in entities {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.name!)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            try? testContext.execute(deleteRequest)
        }
        try? testContext.save()
    }
}
```

## 13. Quality Metrics

### 13.1 Release Criteria

| Metric | Minimum | Target |
|--------|---------|--------|
| Unit test coverage | 75% | 80% |
| Crash-free rate | 99% | 99.5% |
| Critical bugs | 0 | 0 |
| High priority bugs | < 3 | 0 |
| Performance (app launch) | < 3s | < 2s |
| Performance (AR rendering) | 50fps | 60fps |
| User satisfaction (NPS) | > 40 | > 60 |

### 13.2 Bug Severity Classification

| Severity | Definition | Example | Response Time |
|----------|------------|---------|---------------|
| Critical | App crashes, data loss | App crashes on launch | < 4 hours |
| High | Major feature broken | Virtual try-on doesn't work | < 1 day |
| Medium | Feature partially broken | Some outfits not suggested | < 3 days |
| Low | Minor UI issue | Text slightly misaligned | < 1 week |

## 14. Next Steps

- ✅ Testing strategy defined
- ⬜ Implement unit tests (target 80% coverage)
- ⬜ Implement integration tests
- ⬜ Setup CI/CD pipeline
- ⬜ Conduct manual testing
- ⬜ Launch beta program
- ⬜ Collect feedback and iterate

---

**Document Status**: Draft - Ready for Review
**Next Document**: Performance Budget & Optimization Plan
