# Testing Strategy Document

## Overview

Comprehensive testing strategy for Physical-Digital Twins covering unit tests, integration tests, UI tests, and AR testing.

## Testing Pyramid

```
          /\
         /UI\         10% - UI & Integration Tests
        /Tests\
       /--------\
      /  Unit   \     90% - Unit Tests
     /   Tests   \
    /_____________\
```

## Unit Testing

### Core Data Tests

```swift
class CoreDataTests: XCTestCase {
    var context: NSManagedObjectContext!
    var controller: PersistenceController!

    override func setUp() {
        super.setUp()
        controller = PersistenceController(inMemory: true)
        context = controller.container.viewContext
    }

    func testCreateBookTwin() throws {
        let book = BookTwin(title: "Test Book", author: "Test Author")
        let repo = CoreDataDigitalTwinRepository(context: context)

        try repo.save(book)

        let fetched = try repo.fetch(id: book.id) as? BookTwin
        XCTAssertEqual(fetched?.title, "Test Book")
    }

    func testExpirationQuery() throws {
        // Create food items with various expiration dates
        let today = Date()
        let expiringSoon = FoodTwin(productName: "Milk")
        expiringSoon.expirationDate = today.addingTimeInterval(2 * 86400) // 2 days

        let notExpiring = FoodTwin(productName: "Canned Beans")
        notExpiring.expirationDate = today.addingTimeInterval(30 * 86400) // 30 days

        let repo = CoreDataDigitalTwinRepository(context: context)
        try repo.save(expiringSoon)
        try repo.save(notExpiring)

        // Query expiring items
        let expiring = try repo.fetchExpiring(within: 3)
        XCTAssertEqual(expiring.count, 1)
        XCTAssertEqual(expiring.first?.productName, "Milk")
    }
}
```

### Vision & ML Tests

```swift
class VisionServiceTests: XCTestCase {
    var visionService: VisionService!

    override func setUp() {
        super.setUp()
        visionService = VisionServiceImpl()
    }

    func testBarcodeScanning() async throws {
        let testImage = CIImage(named: "test_barcode")!
        let result = try await visionService.scanBarcode(from: testImage)

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.value, "012345678905")
        XCTAssertGreaterThan(result!.confidence, 0.9)
    }

    func testObjectRecognition() async throws {
        let testImage = CIImage(named: "test_book_cover")!
        let result = try await visionService.recognizeObject(from: testImage)

        XCTAssertEqual(result.category, .book)
        XCTAssertGreaterThan(result.confidence, 0.7)
    }

    func testOCRDateExtraction() async throws {
        let testImage = CIImage(named: "test_expiration_label")!
        let date = try await visionService.extractExpirationDate(from: testImage)

        XCTAssertNotNil(date)
        let expectedDate = DateComponents(year: 2024, month: 12, day: 31)
        XCTAssertEqual(Calendar.current.dateComponents([.year, .month, .day], from: date!), expectedDate)
    }
}
```

### API Integration Tests

```swift
class APIIntegrationTests: XCTestCase {
    func testAmazonAPIFallback() async throws {
        let mockAmazon = MockAmazonAPI()
        mockAmazon.shouldFail = true

        let mockUPC = MockUPCDatabase()
        mockUPC.mockProduct = UPCProduct(title: "Test Product", brand: "Test")

        let aggregator = ProductAPIAggregator(
            amazonAPI: mockAmazon,
            upcDatabase: mockUPC
        )

        let result = try await aggregator.fetchProductInfo(barcode: "123456")
        XCTAssertEqual(result.title, "Test Product")
    }

    func testRateLimiting() async throws {
        let rateLimiter = RateLimiter()

        // First call should succeed immediately
        let start = Date()
        try await rateLimiter.checkLimit(api: "amazon")
        let firstCallTime = Date().timeIntervalSince(start)
        XCTAssertLessThan(firstCallTime, 0.1)

        // Second call should wait ~1 second (rate limit)
        let secondStart = Date()
        try await rateLimiter.checkLimit(api: "amazon")
        let secondCallTime = Date().timeIntervalSince(secondStart)
        XCTAssertGreaterThan(secondCallTime, 0.9)
    }
}
```

## Integration Testing

### End-to-End Recognition Flow

```swift
class RecognitionFlowTests: XCTestCase {
    var appState: AppState!

    override func setUp() {
        super.setUp()
        let dependencies = MockDependencies()
        appState = AppState(dependencies: dependencies)
    }

    func testCompleteRecognitionFlow() async throws {
        // 1. Scan barcode
        let testImage = CIImage(named: "test_product_barcode")!
        let recognitionResult = try await appState.recognitionRouter.recognize(image: testImage)

        XCTAssertEqual(recognitionResult.method, .barcode)

        // 2. Fetch product info
        let productInfo = try await appState.apiAggregator.fetchProductInfo(barcode: recognitionResult.identifier!)

        XCTAssertNotNil(productInfo.title)

        // 3. Create digital twin
        let twin = try await appState.twinManager.createTwin(from: productInfo)

        XCTAssertNotNil(twin.id)

        // 4. Save to inventory
        try await appState.inventory.addItem(twin)

        XCTAssertEqual(appState.inventory.items.count, 1)
    }
}
```

## UI Testing

### SwiftUI View Tests

```swift
class HomeViewTests: XCTestCase {
    func testStatsCardDisplay() throws {
        let appState = AppState.mock
        appState.inventory.items = [
            InventoryItem(digitalTwin: BookTwin(title: "Test", author: "Author"))
        ]

        let view = HomeView()
            .environment(appState)

        let host = UIHostingController(rootView: view)

        XCTAssertNotNil(host.view)
        // Verify stats are displayed correctly
    }
}
```

### Snapshot Tests

```swift
class SnapshotTests: XCTestCase {
    func testDigitalTwinCardSnapshot() {
        let book = BookTwin(title: "Atomic Habits", author: "James Clear")
        book.averageRating = 4.8

        let card = DigitalTwinCardView(twin: book, onTap: {})
        assertSnapshot(matching: card, as: .image)
    }

    func testExpirationBadgeSnapshot() {
        let badge = ExpirationBadge(
            expirationDate: Date().addingTimeInterval(2 * 86400),
            status: .useSoon
        )

        assertSnapshot(matching: badge, as: .image)
    }
}
```

## AR Testing

### RealityKit Tests

```swift
class ARSceneTests: XCTestCase {
    func testDigitalTwinEntityCreation() {
        let twin = BookTwin(title: "Test", author: "Author")
        let entity = DigitalTwinEntity(
            twin: twin,
            anchor: AnchoringComponent(.world(transform: .identity))
        )

        XCTAssertNotNil(entity.infoCard)
        XCTAssertEqual(entity.twinID, twin.id)
        XCTAssertNotNil(entity.anchoring)
    }

    func testAssemblyInstructionRendering() {
        let renderer = AssemblyInstructionRenderer()
        let step = AssemblyStep(
            stepNumber: 1,
            title: "Attach panel",
            description: "Attach side panel to base",
            instructions: [
                Instruction(
                    type: .highlight(area: CGRect(x: 0, y: 0, width: 0.3, height: 0.5)),
                    targetPosition: [0, 0, 0]
                )
            ],
            estimatedTime: 300
        )

        let object = Entity()
        renderer.showStep(step, on: object)

        XCTAssertFalse(renderer.instructionEntities.isEmpty)
    }
}
```

### Manual Device Testing

**AR features require device testing**:
- Hand tracking accuracy
- Eye gaze precision
- Spatial anchor persistence
- Multi-object performance
- Real-world lighting conditions

## Performance Testing

```swift
class PerformanceTests: XCTestCase {
    func testRecognitionLatency() throws {
        let image = CIImage(named: "test_object")!
        let recognitionRouter = RecognitionRouter()

        measure {
            _ = try? recognitionRouter.recognize(image: image)
        }

        // Assert < 500ms average
    }

    func testLargeInventoryPerformance() throws {
        let context = PersistenceController(inMemory: true).container.viewContext
        let repo = CoreDataDigitalTwinRepository(context: context)

        // Create 10,000 items
        for i in 0..<10000 {
            let book = BookTwin(title: "Book \(i)", author: "Author")
            try repo.save(book)
        }

        measure {
            _ = try? repo.fetchAll(category: nil)
        }

        // Assert < 100ms for fetch
    }
}
```

## Test Coverage Goals

| Layer | Target Coverage |
|-------|----------------|
| Data Layer | 90% |
| Service Layer | 85% |
| ViewModels | 80% |
| Views | 60% |
| Overall | 75% |

## CI/CD Testing

### Xcode Cloud Configuration

```yaml
# .xcode-cloud.yml
version: 1.0

workflows:
  - name: Main Branch
    trigger:
      branch: main
    actions:
      - name: Test
        scheme: PhysicalDigitalTwins
        platform: visionOS
        destination: "Apple Vision Pro"
        test-plan: AllTests
      - name: Build
        scheme: PhysicalDigitalTwins
        archive: true
```

## Beta Testing

### TestFlight Strategy

**Phase 1: Internal (Weeks 1-2)**
- Dev team only
- Test core functionality
- Fix critical bugs

**Phase 2: Closed Beta (Weeks 3-6)**
- 100 invited users
- Test real-world usage
- Gather feedback

**Phase 3: Public Beta (Weeks 7-10)**
- 1,000 users
- Finalize for launch
- Monitor crash rates

### Metrics to Track

- Crash-free rate: > 99.5%
- Average session duration
- Recognition success rate
- API error rate
- User retention

## Summary

Comprehensive testing ensures:
- **Quality**: Catch bugs before users do
- **Confidence**: Deploy with certainty
- **Performance**: Meet latency targets
- **Reliability**: High crash-free rate

Tests are not optional—they're essential for shipping quality software.
