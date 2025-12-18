# Testing Strategy
## Reality Annotation Platform

**Version**: 1.0
**Date**: November 2024
**Status**: Draft

---

## 1. Overview

This document defines the testing strategy for the Reality Annotation Platform, covering unit tests, integration tests, UI tests, and manual testing procedures.

---

## 2. Testing Pyramid

```
        /\
       /  \
      / UI \         10% - End-to-end UI tests
     /______\
    /        \
   /Integration\    30% - Integration tests
  /____________\
 /              \
/   Unit Tests   \  60% - Unit tests
/__________________\
```

---

## 3. Unit Testing

### 3.1 Test Coverage Goals

- **Services**: 90% coverage
- **ViewModels**: 85% coverage
- **Repositories**: 80% coverage
- **Utilities**: 95% coverage
- **Overall**: 80% minimum

### 3.2 Unit Test Examples

```swift
import XCTest
@testable import RealityAnnotation

class AnnotationServiceTests: XCTestCase {
    var sut: DefaultAnnotationService!
    var mockRepository: MockAnnotationRepository!
    var mockPermissionService: MockPermissionService!

    override func setUp() {
        super.setUp()
        mockRepository = MockAnnotationRepository()
        mockPermissionService = MockPermissionService()
        sut = DefaultAnnotationService(
            repository: mockRepository,
            permissionService: mockPermissionService,
            anchorManager: MockAnchorManager(),
            syncCoordinator: MockSyncCoordinator()
        )
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        mockPermissionService = nil
        super.tearDown()
    }

    func testCreateAnnotation_Success() async throws {
        // Given
        let content = AnnotationContent(text: "Test annotation")
        let position = SIMD3<Float>(0, 1, -2)
        let layerID = UUID()

        mockPermissionService.canCreateResult = true

        // When
        let annotation = try await sut.createAnnotation(
            content: content,
            type: .text,
            position: position,
            layerID: layerID
        )

        // Then
        XCTAssertEqual(annotation.content.text, "Test annotation")
        XCTAssertEqual(annotation.position, position)
        XCTAssertEqual(mockRepository.savedAnnotations.count, 1)
    }

    func testCreateAnnotation_EmptyContent_ThrowsError() async {
        // Given
        let content = AnnotationContent(text: "")

        // When/Then
        await XCTAssertThrowsError(
            try await sut.createAnnotation(
                content: content,
                type: .text,
                position: SIMD3(0, 0, 0),
                layerID: UUID()
            )
        ) { error in
            XCTAssertEqual(error as? AnnotationError, .emptyContent)
        }
    }

    func testFetchAnnotations_FiltersDeleted() async throws {
        // Given
        let activeAnnotation = Annotation(id: UUID(), isDeleted: false)
        let deletedAnnotation = Annotation(id: UUID(), isDeleted: true)
        mockRepository.annotations = [activeAnnotation, deletedAnnotation]

        // When
        let annotations = try await sut.fetchAnnotations(in: UUID())

        // Then
        XCTAssertEqual(annotations.count, 1)
        XCTAssertEqual(annotations.first?.id, activeAnnotation.id)
    }
}

// MARK: - Mock Objects

class MockAnnotationRepository: AnnotationRepository {
    var annotations: [Annotation] = []
    var savedAnnotations: [Annotation] = []

    func fetch(_ id: UUID) async throws -> Annotation? {
        return annotations.first { $0.id == id }
    }

    func fetchAll() async throws -> [Annotation] {
        return annotations
    }

    func save(_ annotation: Annotation) async throws {
        savedAnnotations.append(annotation)
        annotations.append(annotation)
    }

    func delete(_ id: UUID) async throws {
        annotations.removeAll { $0.id == id }
    }
}

class MockPermissionService: PermissionService {
    var canCreateResult = true

    func canView(_ annotation: Annotation) -> Bool {
        return true
    }

    func checkCanCreate(in layerID: UUID) async throws {
        if !canCreateResult {
            throw PermissionError.cannotCreate
        }
    }
}
```

### 3.3 ViewModel Testing

```swift
@MainActor
class AnnotationListViewModelTests: XCTestCase {
    var sut: AnnotationListViewModel!
    var mockService: MockAnnotationService!

    override func setUp() {
        super.setUp()
        mockService = MockAnnotationService()
        sut = AnnotationListViewModel(annotationService: mockService)
    }

    func testLoadAnnotations_Success() async {
        // Given
        let testAnnotations = [
            Annotation(id: UUID(), content: AnnotationContent(text: "Test 1")),
            Annotation(id: UUID(), content: AnnotationContent(text: "Test 2"))
        ]
        mockService.annotations = testAnnotations

        // When
        await sut.loadAnnotations()

        // Then
        XCTAssertEqual(sut.annotations.count, 2)
        XCTAssertEqual(sut.loadingState, .loaded)
    }

    func testLoadAnnotations_Error() async {
        // Given
        mockService.shouldThrowError = true

        // When
        await sut.loadAnnotations()

        // Then
        XCTAssertEqual(sut.annotations.count, 0)
        XCTAssertEqual(sut.loadingState, .error)
    }
}
```

---

## 4. Integration Testing

### 4.1 Repository Integration Tests

```swift
class AnnotationRepositoryIntegrationTests: XCTestCase {
    var sut: DefaultAnnotationRepository!
    var modelContext: ModelContext!

    override func setUp() {
        super.setUp()

        // Create in-memory SwiftData container for testing
        let schema = Schema([Annotation.self, Layer.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])

        modelContext = ModelContext(container)

        let localDataSource = SwiftDataSource(modelContext: modelContext)
        let remoteDataSource = MockCloudKitDataSource()

        sut = DefaultAnnotationRepository(
            localDataSource: localDataSource,
            remoteDataSource: remoteDataSource,
            syncCoordinator: MockSyncCoordinator()
        )
    }

    func testSaveAndFetch() async throws {
        // Given
        let annotation = Annotation(
            type: .text,
            content: AnnotationContent(text: "Test"),
            position: SIMD3(0, 1, -2),
            layerID: UUID(),
            ownerID: "test-user"
        )

        // When
        try await sut.save(annotation)
        let fetched = try await sut.fetch(annotation.id)

        // Then
        XCTAssertNotNil(fetched)
        XCTAssertEqual(fetched?.id, annotation.id)
        XCTAssertEqual(fetched?.content.text, "Test")
    }

    func testFetchByLayer() async throws {
        // Given
        let layerID = UUID()
        let annotation1 = Annotation(layerID: layerID)
        let annotation2 = Annotation(layerID: layerID)
        let annotation3 = Annotation(layerID: UUID()) // Different layer

        try await sut.save(annotation1)
        try await sut.save(annotation2)
        try await sut.save(annotation3)

        // When
        let annotations = try await sut.fetchByLayer(layerID)

        // Then
        XCTAssertEqual(annotations.count, 2)
        XCTAssertTrue(annotations.contains { $0.id == annotation1.id })
        XCTAssertTrue(annotations.contains { $0.id == annotation2.id })
    }
}
```

### 4.2 CloudKit Integration Tests

```swift
class CloudKitSyncIntegrationTests: XCTestCase {
    var cloudKitService: DefaultCloudKitService!

    override func setUp() {
        super.setUp()
        // Use CloudKit development environment
        cloudKitService = DefaultCloudKitService(scope: .private)
    }

    func testUploadAnnotation() async throws {
        // Given
        let annotation = Annotation(
            type: .text,
            content: AnnotationContent(text: "CloudKit Test"),
            position: SIMD3(0, 1, -2),
            layerID: UUID(),
            ownerID: "test-user"
        )

        // When
        try await cloudKitService.upload(annotation)

        // Then
        let record = try await cloudKitService.fetch(
            CKRecord.ID(recordName: annotation.id.uuidString)
        )
        XCTAssertEqual(record["content"] as? String, "CloudKit Test")
    }

    func testFetchChanges() async throws {
        // Given
        let annotation1 = Annotation(...)
        let annotation2 = Annotation(...)

        try await cloudKitService.upload(annotation1)
        try await cloudKitService.upload(annotation2)

        // When
        let changes = try await cloudKitService.fetchChanges(since: nil)

        // Then
        XCTAssertGreaterThanOrEqual(changes.count, 2)
    }
}
```

---

## 5. UI Testing

### 5.1 UI Test Setup

```swift
class AnnotationUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false

        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()
    }

    func testCreateAnnotation() throws {
        // Enter AR mode
        app.buttons["Enter AR Mode"].tap()

        // Wait for AR to load
        let arView = app.otherElements["ar-space"]
        XCTAssertTrue(arView.waitForExistence(timeout: 3))

        // Open create panel
        app.buttons["Create"].tap()

        // Fill in annotation details
        let textField = app.textViews["annotation-text"]
        textField.tap()
        textField.typeText("UI Test Annotation")

        // Select layer
        app.buttons["Layer"].tap()
        app.buttons["Family Messages"].tap()

        // Create
        app.buttons["Create"].tap()

        // Verify annotation appears
        XCTAssertTrue(app.staticTexts["UI Test Annotation"].waitForExistence(timeout: 2))
    }

    func testSearchAnnotations() throws {
        // Navigate to search
        app.tabBars.buttons["Search"].tap()

        // Enter search query
        let searchField = app.searchFields["Search annotations"]
        searchField.tap()
        searchField.typeText("meeting")

        // Verify results
        let resultsTable = app.tables["search-results"]
        XCTAssertTrue(resultsTable.waitForExistence(timeout: 2))
        XCTAssertGreaterThan(resultsTable.cells.count, 0)
    }

    func testLayerVisibilityToggle() throws {
        // Open layers menu
        app.buttons["Layers"].tap()

        // Toggle layer visibility
        let familyLayer = app.buttons["Family Messages"]
        let isVisible = familyLayer.value as? String == "visible"

        familyLayer.tap()

        // Verify toggle
        let newValue = familyLayer.value as? String
        XCTAssertNotEqual(isVisible ? "visible" : "hidden", newValue)
    }
}
```

---

## 6. Manual Testing

### 6.1 AR Testing Checklist

**Annotation Creation**:
- [ ] Can create text annotation by tapping in space
- [ ] Can create photo annotation with camera
- [ ] Can create voice memo
- [ ] Can create drawing annotation
- [ ] Annotation appears at correct position
- [ ] Annotation persists after app restart

**Spatial Tracking**:
- [ ] Annotations stay in correct position when moving
- [ ] Annotations relocalize correctly in same space
- [ ] World map saves successfully
- [ ] Can switch between different spaces
- [ ] Annotations visible at appropriate distances

**Interaction**:
- [ ] Can select annotation by tapping
- [ ] Can move annotation by dragging
- [ ] Can delete annotation
- [ ] Context menu works correctly
- [ ] Detail view shows correct information

**Performance**:
- [ ] App runs at 60+ FPS with 50 annotations
- [ ] App runs at 60+ FPS with 100 annotations
- [ ] No noticeable lag when creating annotation
- [ ] LOD transitions are smooth
- [ ] Memory usage stays under 500 MB

**Multi-User**:
- [ ] Can share annotation with another user
- [ ] Shared annotations sync correctly
- [ ] Permissions enforced correctly
- [ ] Can comment on shared annotations
- [ ] Can see other users' reactions

### 6.2 Edge Case Testing

```
Test Scenarios:
1. Network Loss
   - Create annotation while offline
   - Toggle airplane mode during sync
   - Verify annotation appears after reconnection

2. Low Memory
   - Load 500+ annotations
   - Verify app doesn't crash
   - Verify memory cleanup works

3. Low Battery
   - Verify frame rate reduces appropriately
   - Verify sync frequency reduces

4. Permissions
   - Attempt to edit others' annotations
   - Attempt to delete others' annotations
   - Verify permission errors shown

5. CloudKit Issues
   - Account not signed in
   - CloudKit quota exceeded
   - Network timeout during sync
```

---

## 7. Performance Testing

### 7.1 Load Testing

```swift
class LoadTests: XCTestCase {
    func testLoad100Annotations() throws {
        measure {
            let annotations = createTestAnnotations(count: 100)
            _ = renderer.render(annotations)
        }

        // Should complete in < 100ms
    }

    func testLoad500Annotations() throws {
        measure {
            let annotations = createTestAnnotations(count: 500)
            _ = renderer.render(annotations)
        }

        // Should complete in < 500ms
    }
}
```

### 7.2 Memory Testing

```swift
class MemoryTests: XCTestCase {
    func testMemoryUsageUnder500MB() throws {
        measureMetrics([XCTMemoryMetric()]) {
            // Load 1000 annotations
            _ = loadAnnotations(count: 1000)
        }
    }

    func testNoMemoryLeaks() {
        addTeardownBlock { [weak sut] in
            XCTAssertNil(sut, "Memory leak detected")
        }

        // Perform operations
        for _ in 0..<100 {
            _ = sut.createAnnotation(...)
        }
    }
}
```

---

## 8. Continuous Integration

### 8.1 GitHub Actions Workflow

```yaml
# .github/workflows/test.yml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v3

      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode_15.0.app

      - name: Run Tests
        run: |
          xcodebuild test \
            -scheme RealityAnnotation \
            -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
            -enableCodeCoverage YES

      - name: Upload Coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage.xml

      - name: Check Coverage
        run: |
          COVERAGE=$(xccov view --report coverage.xcresult | grep "Total" | awk '{print $NF}')
          if (( $(echo "$COVERAGE < 80.0" | bc -l) )); then
            echo "Coverage $COVERAGE% is below 80%"
            exit 1
          fi
```

---

## 9. Test Data Management

### 9.1 Test Fixtures

```swift
struct TestFixtures {
    static func createAnnotation(
        id: UUID = UUID(),
        text: String = "Test Annotation",
        position: SIMD3<Float> = SIMD3(0, 1, -2),
        layerID: UUID = UUID()
    ) -> Annotation {
        return Annotation(
            id: id,
            type: .text,
            content: AnnotationContent(text: text),
            position: position,
            layerID: layerID,
            ownerID: "test-user"
        )
    }

    static func createLayer(
        id: UUID = UUID(),
        name: String = "Test Layer"
    ) -> Layer {
        return Layer(
            id: id,
            name: name,
            icon: "tag.fill",
            color: .blue,
            ownerID: "test-user"
        )
    }

    static func createUser(
        id: String = "test-user"
    ) -> User {
        return User(id: id)
    }
}
```

---

## 10. Bug Reporting Template

```markdown
## Bug Report

**Environment**:
- Device: Apple Vision Pro
- visionOS Version: 1.0
- App Version: 1.0.0

**Description**:
[Clear description of the bug]

**Steps to Reproduce**:
1. Step 1
2. Step 2
3. Step 3

**Expected Behavior**:
[What should happen]

**Actual Behavior**:
[What actually happens]

**Screenshots/Videos**:
[Attach if relevant]

**Console Logs**:
```
[Paste relevant logs]
```

**Frequency**:
- [ ] Always
- [ ] Sometimes
- [ ] Rarely

**Severity**:
- [ ] Critical (app crashes)
- [ ] High (major feature broken)
- [ ] Medium (workaround exists)
- [ ] Low (minor issue)
```

---

## 11. Testing Schedule

| Phase | Duration | Coverage Target |
|-------|----------|-----------------|
| Unit Tests | Ongoing | 80%+ |
| Integration Tests | Weekly | All critical paths |
| UI Tests | Before release | All user flows |
| Manual Testing | Before release | Full checklist |
| Performance Testing | Weekly | Meet targets |
| Load Testing | Before release | 100-500 annotations |

---

**Document Status**: ✅ Ready for Implementation
**Dependencies**: All architecture documents
**Next Steps**: Create Implementation Roadmap document
