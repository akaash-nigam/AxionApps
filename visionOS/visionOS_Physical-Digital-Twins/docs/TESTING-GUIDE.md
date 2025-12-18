# Testing Guide - Physical-Digital Twins MVP

## Overview

This comprehensive testing guide covers all testing strategies for the Physical-Digital Twins visionOS app. It includes tests that can be run in this environment and tests that must be executed in Xcode.

## Test Categories

### ✅ Unit Tests (Implemented)
Location: `PhysicalDigitalTwinsTests/`

**Status**: Tests written, ready to run in Xcode

**Coverage**:
- ✅ `InventoryItemTests.swift` - Model tests
- ✅ `BookTwinTests.swift` - Digital twin tests
- ✅ `PhotoServiceTests.swift` - Photo service tests

**To Run**:
```bash
# In Xcode
cmd + U (Run All Tests)

# Or via command line
xcodebuild test -scheme PhysicalDigitalTwins -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
```

### 📋 UI Tests (To Be Implemented in Xcode)

**Status**: Documented below, needs implementation in Xcode

**Location**: Create `PhysicalDigitalTwinsUITests/` target

---

## 🧪 Unit Tests Details

### InventoryItemTests

**Test Coverage**: 15 tests

1. **Initialization Tests**
   - `testInventoryItemInitialization()` - Default values
   - `testInventoryItemWithCustomID()` - Custom UUID

2. **Mutability Tests**
   - `testInventoryItemMutability()` - Property modifications
   - `testPhotoPathsModification()` - Photo array updates

3. **Lending Tests**
   - `testLendingFunctionality()` - Lending workflow

4. **Condition Tests**
   - `testItemConditionEnum()` - All condition states

5. **Codable Tests**
   - `testInventoryItemCodable()` - JSON encoding/decoding

6. **Type Erasure Tests**
   - `testAnyDigitalTwinTypeErasure()` - Type casting
   - `testAnyDigitalTwinProperties()` - Property access

7. **Edge Cases**
   - `testEmptyValues()` - Empty strings/arrays
   - `testNilValues()` - Optional properties

### BookTwinTests

**Test Coverage**: 18 tests

1. **Initialization Tests**
   - `testBookTwinInitialization()` - Basic creation
   - `testBookTwinWithAllFields()` - Complete data

2. **Display Tests**
   - `testDisplayName()` - Title display

3. **Reading Status Tests**
   - `testReadingStatusEnum()` - Status values
   - `testReadingStatusUpdate()` - Status changes

4. **Recognition Method Tests**
   - `testRecognitionMethodEnum()` - Method types

5. **Category Tests**
   - `testObjectCategory()` - Object type

6. **Codable Tests**
   - `testBookTwinCodable()` - Serialization

7. **Identifier Tests**
   - `testUniqueIdentifiers()` - UUID uniqueness

8. **Timestamp Tests**
   - `testCreatedAtTimestamp()` - Creation time

9. **Edge Cases**
   - `testMinimalBookTwin()` - Minimal data
   - `testEmptyCategoriesArray()` - Empty categories

10. **Rating Tests**
    - `testValidRatings()` - Rating data
    - `testNoRatings()` - No ratings

### PhotoServiceTests

**Test Coverage**: 15 tests

1. **Save Photo Tests**
   - `testSavePhoto()` - Basic save
   - `testSavePhotoGeneratesUniquePaths()` - Path uniqueness
   - `testSavePhotoForDifferentItems()` - Multi-item support

2. **Load Photo Tests**
   - `testLoadPhotoAfterSave()` - Save and load cycle
   - `testLoadPhotoThrowsForInvalidPath()` - Error handling

3. **Delete Photo Tests**
   - `testDeletePhoto()` - Single deletion
   - `testDeleteNonexistentPhotoDoesNotThrow()` - Graceful failure

4. **Delete All Tests**
   - `testDeleteAllPhotos()` - Batch deletion
   - `testDeleteAllPhotosWithEmptyArray()` - Empty array handling

5. **Error Tests**
   - `testPhotoErrorDescriptions()` - Error messages

6. **Quality Tests**
   - `testPhotoCompressionQuality()` - JPEG compression

7. **Concurrency Tests**
   - `testConcurrentSaves()` - Thread safety

8. **Performance Tests**
   - `testSavePhotoPerformance()` - Speed measurement

---

## 🎨 UI Tests (To Implement in Xcode)

Create a new UI Testing target in Xcode and implement these test cases:

### Test File: `InventoryFlowUITests.swift`

```swift
import XCTest

final class InventoryFlowUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    // MARK: - Manual Entry Flow

    func testManualEntryFlow() throws {
        // 1. Tap "Add Manually" from home
        app.buttons["Add Manually"].tap()

        // 2. Fill in form
        let titleField = app.textFields["Title"]
        titleField.tap()
        titleField.typeText("Test Book")

        let authorField = app.textFields["Author"]
        authorField.tap()
        authorField.typeText("Test Author")

        // 3. Save
        app.buttons["Save"].tap()

        // 4. Verify item appears in inventory
        XCTAssertTrue(app.staticTexts["Test Book"].exists)
    }

    // MARK: - Barcode Scanning Flow

    func testScanningFlow() throws {
        // Note: This requires simulator camera mocking or device testing
        // 1. Tap "Scan Barcode"
        app.buttons["Scan Barcode"].tap()

        // 2. Verify camera view appears
        XCTAssertTrue(app.otherElements["CameraPreview"].exists)

        // 3. Simulate barcode detection (requires mocking)
        // This would be done via test data injection

        // 4. Verify success state
        XCTAssertTrue(app.buttons["Done"].exists)
    }

    // MARK: - Item Detail Flow

    func testViewItemDetail() throws {
        // Setup: Add a test item first
        addTestItem()

        // 1. Tap on item in list
        app.cells.firstMatch.tap()

        // 2. Verify detail view
        XCTAssertTrue(app.navigationBars["Test Book"].exists)
        XCTAssertTrue(app.staticTexts["Test Author"].exists)
    }

    // MARK: - Edit Item Flow

    func testEditItem() throws {
        // Setup
        addTestItem()
        app.cells.firstMatch.tap()

        // 1. Tap edit
        app.buttons["Edit Item"].tap()

        // 2. Modify title
        let titleField = app.textFields["Title"]
        titleField.tap()
        titleField.clearText()
        titleField.typeText("Modified Book")

        // 3. Save
        app.buttons["Save Changes"].tap()

        // 4. Verify changes
        XCTAssertTrue(app.staticTexts["Modified Book"].exists)
    }

    // MARK: - Delete Item Flow

    func testDeleteItem() throws {
        // Setup
        addTestItem()
        app.cells.firstMatch.tap()

        // 1. Tap delete
        app.buttons["Delete Item"].tap()

        // 2. Confirm
        app.alerts.buttons["Delete"].tap()

        // 3. Verify item removed
        XCTAssertFalse(app.staticTexts["Test Book"].exists)
    }

    // MARK: - Photo Flow

    func testAddPhoto() throws {
        // Setup
        addTestItem()
        app.cells.firstMatch.tap()

        // 1. Tap "Add Photos"
        app.buttons["Add Photos"].tap()

        // 2. Select photo from picker (requires mock photos)
        // PhotoPicker interaction

        // 3. Verify photo added
        XCTAssertTrue(app.buttons["View Gallery"].exists)
    }

    func testViewPhotoGallery() throws {
        // Setup: Add item with photos
        addTestItemWithPhotos()

        // 1. Open item detail
        app.cells.firstMatch.tap()

        // 2. Open gallery
        app.buttons["View Gallery"].tap()

        // 3. Verify gallery view
        XCTAssertTrue(app.navigationBars["Photos"].exists)
        XCTAssertTrue(app.buttons["Add Photos"].exists)
    }

    // MARK: - Search Flow

    func testSearchInventory() throws {
        // Setup: Add multiple items
        addTestItem()

        // 1. Tap search
        let searchField = app.searchFields.firstMatch
        searchField.tap()

        // 2. Type search query
        searchField.typeText("Test")

        // 3. Verify filtered results
        XCTAssertTrue(app.cells.count >= 1)
    }

    // MARK: - Pull to Refresh

    func testPullToRefresh() throws {
        // 1. Navigate to inventory
        app.tabBars.buttons["Inventory"].tap()

        // 2. Pull down
        let firstCell = app.cells.firstMatch
        firstCell.swipeDown()

        // 3. Verify refresh indicator appears
        // Note: Hard to test reliably, may need visual verification
    }

    // MARK: - Helpers

    private func addTestItem() {
        app.buttons["Add Manually"].tap()
        app.textFields["Title"].tap()
        app.textFields["Title"].typeText("Test Book")
        app.textFields["Author"].tap()
        app.textFields["Author"].typeText("Test Author")
        app.buttons["Save"].tap()
    }

    private func addTestItemWithPhotos() {
        // Implementation would involve adding item and photos
    }
}

extension XCUIElement {
    func clearText() {
        guard let stringValue = self.value as? String else {
            return
        }

        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        typeText(deleteString)
    }
}
```

---

## ⚡ Performance Tests (To Implement in Xcode)

### Test File: `PerformanceTests.swift`

```swift
import XCTest
@testable import PhysicalDigitalTwins

final class PerformanceTests: XCTestCase {

    // MARK: - Inventory Loading Performance

    func testInventoryLoadPerformance() throws {
        // Given: Database with 1000 items
        let persistence = PersistenceController.preview
        let storage = CoreDataStorageService(persistenceController: persistence)

        // Populate with test data
        Task {
            for i in 0..<1000 {
                let book = BookTwin(
                    title: "Book \(i)",
                    author: "Author \(i)",
                    isbn: nil,
                    recognitionMethod: .manual
                )
                let item = InventoryItem(digitalTwin: book)
                try? await storage.saveItem(item)
            }
        }

        // When: Measure fetch performance
        measure {
            Task {
                _ = try? await storage.fetchAllItems()
            }
        }

        // Then: Should complete in < 500ms
        // XCTest will report the time
    }

    // MARK: - Search Performance

    func testSearchPerformance() throws {
        let persistence = PersistenceController.preview
        let storage = CoreDataStorageService(persistenceController: persistence)

        // Populate test data...

        measure {
            Task {
                _ = try? await storage.searchItems(query: "Book")
            }
        }
    }

    // MARK: - Photo Load Performance

    func testPhotoLoadPerformance() throws {
        let photoService = FileSystemPhotoService()
        let testImage = createTestImage()
        let itemID = UUID()

        var savedPath: String!

        // Setup
        Task {
            savedPath = try await photoService.savePhoto(testImage, itemId: itemID)
        }

        // Measure
        measure {
            Task {
                _ = try? await photoService.loadPhoto(path: savedPath)
            }
        }

        // Target: < 100ms per photo
    }

    // MARK: - Barcode Detection Performance

    func testBarcodeDetectionPerformance() {
        // This requires actual camera frames or test images
        // Measure time from frame to detection

        // Target: < 500ms detection time
    }

    // MARK: - UI Rendering Performance

    func testListScrollPerformance() {
        // This requires UI testing framework
        // Measure scroll FPS with large list

        // Target: Maintain 60 FPS
    }

    // MARK: - Animation Performance

    func testListAnimationPerformance() {
        // Measure animation frame rate during transitions
        // Target: 60 FPS during animations
    }

    // MARK: - Memory Tests

    func testMemoryUsageWithManyPhotos() {
        // Monitor memory while loading 100+ photos
        // Target: < 500MB memory usage
    }

    // MARK: - Helpers

    private func createTestImage() -> UIImage {
        let size = CGSize(width: 100, height: 100)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor.red.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}
```

---

## 🔗 Integration Tests (To Implement in Xcode)

### Test File: `IntegrationTests.swift`

```swift
import XCTest
@testable import PhysicalDigitalTwins

final class IntegrationTests: XCTestCase {

    // MARK: - End-to-End Flows

    func testCompleteAddItemFlow() async throws {
        // Given: AppState and dependencies
        let dependencies = AppDependencies()
        let appState = AppState(dependencies: dependencies)

        // When: Add item through AppState
        let book = BookTwin(
            title: "Integration Test",
            author: "Test Author",
            isbn: "9781234567890",
            recognitionMethod: .manual
        )
        let item = InventoryItem(digitalTwin: book)

        await appState.addItem(item)

        // Then: Item should be in inventory
        XCTAssertEqual(appState.inventory.items.count, 1)
        XCTAssertEqual(appState.inventory.items.first?.digitalTwin.displayName, "Integration Test")
    }

    func testEditAndSaveFlow() async throws {
        // Given: Item in storage
        let dependencies = AppDependencies()
        let appState = AppState(dependencies: dependencies)

        let book = BookTwin(
            title: "Original Title",
            author: "Author",
            isbn: nil,
            recognitionMethod: .manual
        )
        let item = InventoryItem(digitalTwin: book)
        await appState.addItem(item)

        // When: Edit and update
        var editedBook = book
        editedBook.title = "Modified Title"

        var editedItem = item
        editedItem.digitalTwin = AnyDigitalTwin(editedBook)

        await appState.updateItem(editedItem)

        // Then: Changes should persist
        let reloadedItems = try await dependencies.storageService.fetchAllItems()
        XCTAssertEqual(reloadedItems.first?.digitalTwin.displayName, "Modified Title")
    }

    func testPhotoWorkflow() async throws {
        // Given: Item with photos
        let dependencies = AppDependencies()
        let appState = AppState(dependencies: dependencies)

        let book = BookTwin(title: "Test", author: "Author", isbn: nil, recognitionMethod: .manual)
        var item = InventoryItem(digitalTwin: book)

        // When: Add photos
        let testImage = createTestImage()
        let path1 = try await dependencies.photoService.savePhoto(testImage, itemId: item.id)
        let path2 = try await dependencies.photoService.savePhoto(testImage, itemId: item.id)

        item.photosPaths = [path1, path2]
        await appState.addItem(item)

        // Then: Photos should be loadable
        let loadedImage1 = try await dependencies.photoService.loadPhoto(path: path1)
        let loadedImage2 = try await dependencies.photoService.loadPhoto(path: path2)

        XCTAssertNotNil(loadedImage1)
        XCTAssertNotNil(loadedImage2)

        // When: Delete item
        await appState.deleteItem(item)

        // Then: Photos should be deleted
        do {
            _ = try await dependencies.photoService.loadPhoto(path: path1)
            XCTFail("Photo should be deleted")
        } catch {
            // Expected
        }
    }

    // MARK: - Service Integration

    func testStorageAndPhotoServiceIntegration() async throws {
        let dependencies = AppDependencies()

        // Create item with photos
        let book = BookTwin(title: "Test", author: "Author", isbn: nil, recognitionMethod: .manual)
        let item = InventoryItem(digitalTwin: book)

        let testImage = createTestImage()
        let photoPath = try await dependencies.photoService.savePhoto(testImage, itemId: item.id)

        var itemWithPhoto = item
        itemWithPhoto.photosPaths = [photoPath]

        // Save to storage
        try await dependencies.storageService.saveItem(itemWithPhoto)

        // Fetch from storage
        let fetched = try await dependencies.storageService.fetchItem(id: item.id)

        XCTAssertEqual(fetched?.photosPaths.count, 1)
        XCTAssertEqual(fetched?.photosPaths.first, photoPath)

        // Load photo
        let loadedImage = try await dependencies.photoService.loadPhoto(path: photoPath)
        XCTAssertNotNil(loadedImage)
    }

    // MARK: - Helpers

    private func createTestImage() -> UIImage {
        let size = CGSize(width: 100, height: 100)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor.blue.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}
```

---

## 📱 Manual Testing Checklist

### Pre-Launch Testing (Run on Physical Device)

#### 1. Barcode Scanning
- [ ] Camera permission prompt appears
- [ ] Camera preview displays correctly
- [ ] Scan ISBN barcode (test with 9780735211292 - Atomic Habits)
- [ ] Barcode detection happens within 2 seconds
- [ ] Haptic feedback on successful scan
- [ ] Item appears in inventory after scan
- [ ] Error handling for invalid barcodes
- [ ] Works in different lighting conditions

#### 2. Manual Entry
- [ ] Form validation works (title and author required)
- [ ] All fields save correctly
- [ ] Cancel button works
- [ ] Keyboard dismisses properly
- [ ] ISBN field accepts numbers only

#### 3. Item Management
- [ ] View item details
- [ ] Edit item successfully
- [ ] Delete item with confirmation
- [ ] All fields editable
- [ ] Changes persist after app restart

#### 4. Photo Management
- [ ] Add photos from library
- [ ] Multiple photo selection (up to 5)
- [ ] Photos display in gallery
- [ ] Fullscreen photo view works
- [ ] Delete individual photos
- [ ] Photos deleted when item deleted
- [ ] Photo count badge accurate

#### 5. UI/UX
- [ ] Pull-to-refresh works
- [ ] List animations smooth
- [ ] Empty state displays correctly
- [ ] Search works correctly
- [ ] Filter by category works
- [ ] Navigation smooth
- [ ] No visual glitches

#### 6. Haptic Feedback
- [ ] Add item → success haptic
- [ ] Delete item → medium haptic
- [ ] Scan barcode → success haptic
- [ ] Add photo → light haptic
- [ ] Delete photo → medium haptic
- [ ] Error operations → error haptic

#### 7. Performance
- [ ] App launches in < 2 seconds
- [ ] List scrolls at 60 FPS
- [ ] Animations smooth (no jank)
- [ ] Photos load quickly (< 500ms)
- [ ] No memory warnings
- [ ] No crashes

#### 8. Data Persistence
- [ ] Items persist after app restart
- [ ] Photos persist after app restart
- [ ] Edits persist
- [ ] No data loss

#### 9. Edge Cases
- [ ] Works with 0 items (empty state)
- [ ] Works with 100+ items (performance)
- [ ] Works with 10+ photos per item
- [ ] Works offline
- [ ] Handles app backgrounding
- [ ] Handles low memory

#### 10. Accessibility
- [ ] VoiceOver works
- [ ] Dynamic Type supported
- [ ] Sufficient color contrast
- [ ] Touch targets large enough (44x44pt)

---

## 🚀 Test Execution Instructions

### Running Unit Tests

1. **Open Xcode Project**
   ```bash
   open PhysicalDigitalTwins.xcodeproj
   ```

2. **Run All Tests**
   - Press `Cmd + U`
   - Or: Product → Test

3. **Run Specific Test Suite**
   - Click test diamond next to test class
   - Or: Right-click test → Run

4. **View Test Results**
   - View → Navigators → Show Test Navigator
   - Green checkmark = passed
   - Red X = failed

### Running UI Tests

1. **Create UI Test Target** (if not exists)
   - File → New → Target
   - Select "UI Testing Bundle"
   - Name: PhysicalDigitalTwinsUITests

2. **Add UI Test Files**
   - Copy test code from this guide
   - Add to UI test target

3. **Run UI Tests**
   - Select target device/simulator
   - Press `Cmd + U`
   - Watch automated UI interactions

### Running Performance Tests

1. **Use XCTest Metrics**
   ```swift
   measure(metrics: [XCTClockMetric()]) {
       // Code to measure
   }
   ```

2. **View Baseline**
   - Test results shows performance metrics
   - Set baseline for future comparisons

3. **Monitor Memory**
   - Instruments → Allocations
   - Instruments → Leaks

### Continuous Integration

**GitHub Actions** (recommended):

```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run tests
        run: |
          xcodebuild test \
            -scheme PhysicalDigitalTwins \
            -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
```

---

## 📊 Test Coverage Goals

### Coverage Targets

- **Overall**: 80%+
- **Models**: 95%+
- **Services**: 85%+
- **ViewModels**: 80%+
- **Views**: 50%+ (UI tests)

### Measuring Coverage

1. **Enable Code Coverage**
   - Edit Scheme → Test → Options
   - Check "Gather coverage for: PhysicalDigitalTwins"

2. **View Coverage Report**
   - Report Navigator → Coverage tab
   - Green = covered, red = uncovered

3. **Generate Coverage Report**
   ```bash
   xcodebuild test \
     -scheme PhysicalDigitalTwins \
     -enableCodeCoverage YES \
     -derivedDataPath ./DerivedData
   ```

---

## 🐛 Bug Tracking

### Severity Levels

1. **Critical** - App crash, data loss
2. **High** - Feature broken, cannot proceed
3. **Medium** - Feature impaired, workaround exists
4. **Low** - Cosmetic issue, minor inconvenience

### Bug Report Template

```markdown
**Title**: Brief description

**Severity**: Critical/High/Medium/Low

**Steps to Reproduce**:
1. ...
2. ...
3. ...

**Expected Result**: ...

**Actual Result**: ...

**Environment**:
- Device: Apple Vision Pro / Simulator
- iOS Version: ...
- App Version: ...

**Screenshots**: (if applicable)

**Logs**: (if applicable)
```

---

## ✅ Pre-Launch Checklist

- [ ] All unit tests passing
- [ ] All UI tests passing
- [ ] Manual testing complete
- [ ] Performance benchmarks met
- [ ] No memory leaks
- [ ] No crashes in testing
- [ ] Accessibility verified
- [ ] Privacy policy in place
- [ ] App Store screenshots ready
- [ ] TestFlight beta complete
- [ ] User feedback addressed
- [ ] Final build tested on device

---

## 📝 Notes

1. **Simulator Limitations**:
   - Camera doesn't work in simulator
   - Haptics don't work in simulator
   - Performance may differ from device

2. **Device Testing**:
   - Always test on physical Apple Vision Pro
   - Test in different lighting for camera
   - Test with different network conditions

3. **Test Data**:
   - Use test ISBNs: 9780735211292 (Atomic Habits)
   - Create variety of test items
   - Test with realistic data volumes

4. **Continuous Testing**:
   - Run tests before every commit
   - Run full suite before release
   - Monitor crash reports in production

---

**Last Updated**: Epic 7 - Testing & Launch Prep
**Target**: 80%+ code coverage, 0 critical bugs
