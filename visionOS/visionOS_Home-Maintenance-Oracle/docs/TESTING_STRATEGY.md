# Testing Strategy Document
## Home Maintenance Oracle

**Version**: 1.0
**Last Updated**: 2025-11-24
**Status**: Draft

---

## Testing Pyramid

```
         /\
        /  \      E2E Tests (10%)
       /────\     - Critical user flows
      /      \    - visionOS UI tests
     /────────\
    /          \  Integration Tests (30%)
   /────────────\ - API integrations
  /              \- Service layer
 /────────────────\
/                  \ Unit Tests (60%)
────────────────────- Business logic
                     - View models
                     - Utilities
```

---

## Unit Testing

### Target: 80% code coverage

**Framework**: XCTest

**Example Tests**:

```swift
@testable import HomeMaintenanceOracle
import XCTest

class ApplianceClassifierTests: XCTestCase {
    var classifier: ApplianceClassificationService!

    override func setUp() {
        super.setUp()
        classifier = ApplianceClassificationService()
    }

    func testClassifyRefrigerator() async throws {
        // Given
        let image = loadTestImage(named: "refrigerator_test")

        // When
        let result = try await classifier.classify(image: image)

        // Then
        XCTAssertEqual(result.category, "refrigerator")
        XCTAssertGreaterThan(result.confidence, 0.9)
    }

    func testLowConfidenceReturnsAlternatives() async throws {
        let image = loadTestImage(named: "ambiguous_appliance")
        let result = try await classifier.classify(image: image)

        XCTAssertFalse(result.alternatives.isEmpty)
        XCTAssertEqual(result.alternatives.count, 3)
    }
}

class MaintenanceServiceTests: XCTestCase {
    var service: MaintenanceService!
    var mockRepository: MockMaintenanceRepository!

    override func setUp() {
        mockRepository = MockMaintenanceRepository()
        service = MaintenanceService(repository: mockRepository)
    }

    func testGenerateScheduleForHVAC() {
        // Given
        let hvac = Appliance(category: .hvac, installDate: Date())

        // When
        let schedule = service.generateSchedule(for: [hvac])

        // Then
        XCTAssertEqual(schedule.count, 4) // Quarterly filter changes
        XCTAssertTrue(schedule.allSatisfy { $0.isRecurring })
    }
}
```

### Mock Objects

```swift
class MockRecognitionService: RecognitionServiceProtocol {
    var mockResult: RecognizedAppliance?
    var shouldThrowError = false
    var callCount = 0

    func recognizeAppliance(from image: CGImage) async throws -> RecognizedAppliance {
        callCount += 1

        if shouldThrowError {
            throw RecognitionError.noApplianceDetected
        }

        return mockResult ?? RecognizedAppliance(
            category: "refrigerator",
            brand: "GE",
            model: "TEST123",
            confidence: 0.95
        )
    }
}
```

---

## Integration Testing

### API Integration Tests

```swift
class AmazonAPIIntegrationTests: XCTestCase {
    var client: AmazonAPIClient!

    override func setUp() {
        let config = AmazonAPIConfig.test
        client = AmazonAPIClientImpl(config: config)
    }

    func testSearchPartsReturnsResults() async throws {
        // Given
        let query = "GE refrigerator water filter"

        // When
        let parts = try await client.searchParts(query: query)

        // Then
        XCTAssertFalse(parts.isEmpty)
        XCTAssertTrue(parts.allSatisfy { $0.price != nil })
        XCTAssertTrue(parts.allSatisfy { !$0.name.isEmpty })
    }

    func testRateLimitingWorks() async throws {
        let start = Date()

        // Make 3 requests
        _ = try await client.searchParts(query: "filter 1")
        _ = try await client.searchParts(query: "filter 2")
        _ = try await client.searchParts(query: "filter 3")

        let elapsed = Date().timeIntervalSince(start)

        // Should take at least 2 seconds (1 req/sec limit)
        XCTAssertGreaterThanOrEqual(elapsed, 2.0)
    }
}
```

### Core Data Integration Tests

```swift
class CoreDataIntegrationTests: XCTestCase {
    var context: NSManagedObjectContext!

    override func setUp() {
        let container = NSPersistentContainer(name: "Test")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores { _, error in
            XCTAssertNil(error)
        }

        context = container.viewContext
    }

    func testSaveAndFetchAppliance() throws {
        // Create
        let appliance = ApplianceEntity(context: context)
        appliance.id = UUID()
        appliance.brand = "GE"
        appliance.model = "GDT695SSJ2SS"
        appliance.category = "dishwasher"

        try context.save()

        // Fetch
        let request: NSFetchRequest<ApplianceEntity> = ApplianceEntity.fetchRequest()
        let results = try context.fetch(request)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.brand, "GE")
    }
}
```

---

## UI Testing

### visionOS UI Tests

```swift
class HomeMaintenanceOracleUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testRecognitionFlow() throws {
        // Start recognition
        app.buttons["Scan Appliance"].tap()

        // Wait for recognition
        let recognitionCard = app.windows["Recognition Card"]
        XCTAssertTrue(recognitionCard.waitForExistence(timeout: 5))

        // Verify content
        XCTAssertTrue(app.staticTexts["Brand:"].exists)
        XCTAssertTrue(app.staticTexts["Model:"].exists)

        // Open manual
        app.buttons["View Manual"].tap()

        let manualWindow = app.windows["Manual Viewer"]
        XCTAssertTrue(manualWindow.waitForExistence(timeout: 3))
    }

    func testMaintenanceSchedule() throws {
        app.buttons["Maintenance"].tap()

        let scheduleView = app.windows["Maintenance Schedule"]
        XCTAssertTrue(scheduleView.exists)

        // Verify tasks listed
        let taskCells = app.cells.matching(identifier: "MaintenanceTaskCell")
        XCTAssertGreaterThan(taskCells.count, 0)

        // Mark task complete
        taskCells.element(boundBy: 0).buttons["Complete"].tap()

        // Verify checkmark appears
        XCTAssertTrue(taskCells.element(boundBy: 0).images["checkmark"].exists)
    }
}
```

### Spatial UI Testing

```swift
class SpatialUITests: XCTestCase {
    func testWindowPositioning() throws {
        app.launch()

        let mainWindow = app.windows["Main"]
        let manualWindow = app.windows["Manual"]

        // Verify windows don't overlap
        let mainFrame = mainWindow.frame
        let manualFrame = manualWindow.frame

        XCTAssertFalse(mainFrame.intersects(manualFrame))
    }

    func testVolumeInteraction() throws {
        // Open 3D tutorial
        app.buttons["Start Tutorial"].tap()

        let volume = app.volumes["Tutorial Volume"]
        XCTAssertTrue(volume.waitForExistence(timeout: 3))

        // Test pinch gesture
        volume.pinch(scale: 1.5)

        // Verify volume scaled
        let newBounds = volume.frame
        XCTAssertGreaterThan(newBounds.width, 0.8)
    }
}
```

---

## ML Model Testing

### Model Accuracy Tests

```python
import unittest
import torch
from models import ApplianceClassifier

class ApplianceClassifierTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.model = ApplianceClassifier.load('trained_model.pth')
        cls.test_dataset = load_test_dataset()

    def test_accuracy_above_threshold(self):
        correct = 0
        total = 0

        for image, label in self.test_dataset:
            prediction = self.model.predict(image)
            if prediction == label:
                correct += 1
            total += 1

        accuracy = correct / total
        self.assertGreater(accuracy, 0.95)  # 95% minimum

    def test_confidence_calibration(self):
        predictions = []

        for image, label in self.test_dataset:
            pred, confidence = self.model.predict_with_confidence(image)
            correct = (pred == label)
            predictions.append((confidence, correct))

        # High confidence should correlate with correctness
        high_conf = [p[1] for p in predictions if p[0] > 0.9]
        high_conf_accuracy = sum(high_conf) / len(high_conf)

        self.assertGreater(high_conf_accuracy, 0.98)

    def test_inference_time(self):
        import time

        image = self.test_dataset[0][0]

        start = time.time()
        _ = self.model.predict(image)
        elapsed = time.time() - start

        self.assertLess(elapsed, 0.5)  # < 500ms
```

---

## Performance Testing

### Load Testing

```swift
class PerformanceTests: XCTestCase {
    func testRecognitionPerformance() throws {
        let image = loadTestImage(named: "refrigerator")

        measure {
            let _ = try? classifier.classify(image: image)
        }
    }

    func testDatabaseQueryPerformance() throws {
        // Insert 1000 appliances
        for i in 0..<1000 {
            createTestAppliance(id: i)
        }

        measure {
            let request: NSFetchRequest<ApplianceEntity> = ApplianceEntity.fetchRequest()
            let _ = try? context.fetch(request)
        }
    }

    func testMemoryUsage() throws {
        measureMetrics([XCTMemoryMetric()], automaticallyStartMeasuring: false) {
            startMeasuring()

            // Load 100 manuals
            for i in 0..<100 {
                let manual = loadManual(id: i)
                // Process manual
            }

            stopMeasuring()
        }
    }
}
```

### Stress Testing

```python
import concurrent.futures
import requests

def stress_test_api(endpoint, num_requests=1000, concurrency=50):
    def make_request():
        response = requests.get(endpoint)
        return response.status_code == 200

    with concurrent.futures.ThreadPoolExecutor(max_workers=concurrency) as executor:
        futures = [executor.submit(make_request) for _ in range(num_requests)]
        results = [f.result() for f in concurrent.futures.as_completed(futures)]

    success_rate = sum(results) / len(results)
    print(f"Success rate: {success_rate * 100}%")
    assert success_rate > 0.99  # 99% success rate
```

---

## Automated Testing Pipeline

### CI/CD with GitHub Actions

```yaml
# .github/workflows/test.yml
name: Test Suite

on: [push, pull_request]

jobs:
  unit-tests:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v3

      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode_15.2.app

      - name: Run Unit Tests
        run: xcodebuild test -scheme HomeMaintenanceOracle -destination 'platform=visionOS Simulator,name=Apple Vision Pro'

      - name: Upload Coverage
        uses: codecov/codecov-action@v3

  integration-tests:
    runs-on: macos-14
    needs: unit-tests
    steps:
      - name: Run Integration Tests
        run: xcodebuild test -scheme HomeMaintenanceOracle-Integration

  ui-tests:
    runs-on: macos-14
    needs: integration-tests
    steps:
      - name: Run UI Tests
        run: xcodebuild test -scheme HomeMaintenanceOracle-UITests
```

---

## Manual Testing

### Beta Testing Plan

**Phase 1: Internal (2 weeks)**
- 10 team members
- All features
- Daily feedback

**Phase 2: Closed Beta (4 weeks)**
- 100 users (TestFlight)
- Core features
- Weekly surveys

**Phase 3: Public Beta (8 weeks)**
- 1,000 users
- Full app
- In-app feedback

### Test Scenarios

```markdown
## Scenario 1: First-Time User

1. Download and open app
2. Complete onboarding
3. Scan first appliance
4. View manual
5. Set maintenance reminder

Expected: Smooth flow, clear instructions

## Scenario 2: Maintenance Task

1. Receive notification
2. Open app from notification
3. Navigate to task
4. Complete task
5. Take photo
6. Mark complete

Expected: <2 minutes, intuitive

## Scenario 3: Part Ordering

1. Identify broken part
2. Search parts
3. Compare prices
4. Order through affiliate link
5. Return to app

Expected: Seamless handoff, accurate part
```

---

## Bug Tracking

### Priority Levels

| Priority | Description | Response Time | Examples |
|----------|-------------|---------------|----------|
| P0 - Critical | App crashes, data loss | < 4 hours | Crash on launch |
| P1 - High | Core feature broken | < 24 hours | Recognition not working |
| P2 - Medium | Feature partially broken | < 1 week | Manual won't download |
| P3 - Low | Minor issue, workaround exists | < 1 month | UI glitch |
| P4 - Enhancement | Nice to have | Backlog | Feature request |

### Bug Template

```markdown
## Bug Report

**Title**: [Brief description]

**Priority**: P0 / P1 / P2 / P3 / P4

**Environment**:
- visionOS version:
- App version:
- Device: Apple Vision Pro

**Steps to Reproduce**:
1. Step one
2. Step two
3. ...

**Expected Behavior**:
[What should happen]

**Actual Behavior**:
[What actually happens]

**Screenshots/Logs**:
[Attach if available]

**Additional Context**:
[Any other relevant information]
```

---

## Quality Gates

### Release Criteria

**Must Pass**:
- ✅ All unit tests (100%)
- ✅ All integration tests (100%)
- ✅ Critical path UI tests (100%)
- ✅ Code coverage > 80%
- ✅ No P0 or P1 bugs
- ✅ Performance benchmarks met
- ✅ Security audit passed
- ✅ Privacy review approved

**Should Pass**:
- No P2 bugs (or documented)
- User acceptance testing positive
- App Store guidelines compliance
- Accessibility audit passed

---

**Document Status**: Ready for Review
**Next Steps**: Set up test infrastructure, write initial test suite, configure CI/CD
