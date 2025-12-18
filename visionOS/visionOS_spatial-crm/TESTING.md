# Spatial CRM - Testing Guide

## Overview

This document describes the testing strategy and available tests for the Spatial CRM application.

## Testing Environment

Since this is a visionOS application, testing requires:
- **Xcode 16+** with visionOS SDK
- **visionOS Simulator** or **Apple Vision Pro** device
- **Swift Testing Framework** (built into Xcode 16+)

## Test Coverage

### Current Test Suites

#### 1. Account Model Tests (`AccountTests.swift`)
**File**: `SpatialCRM/Tests/UnitTests/AccountTests.swift`
**Tests**: 7 test cases

- ✅ Account initialization with valid data
- ✅ Account position property computed correctly
- ✅ Total opportunity value calculation
- ✅ Primary contact identification
- ✅ Sample data validation
- ✅ Risk level enumeration

**Coverage**: Core Account model functionality

#### 2. Opportunity Tests (`OpportunityTests.swift`)
**File**: `SpatialCRM/Tests/UnitTests/OpportunityTests.swift`
**Tests**: 12 test cases

- ✅ Opportunity initialization
- ✅ Stage progression logic
- ✅ Close won functionality
- ✅ Close lost functionality
- ✅ Days to close calculation
- ✅ Overdue detection (active)
- ✅ Not overdue when closed
- ✅ Stage display names
- ✅ Stage probability mappings
- ✅ Pipeline position properties
- ✅ Sample data validation

**Coverage**: Complete Opportunity lifecycle and business logic

#### 3. Contact Tests (`ContactTests.swift`)
**File**: `SpatialCRM/Tests/UnitTests/ContactTests.swift`
**Tests**: 6 test cases

- ✅ Contact initialization
- ✅ Full name computation
- ✅ Initials computation
- ✅ Contact role enumeration
- ✅ Orbital properties (for 3D visualization)
- ✅ Sample data validation

**Coverage**: Contact model and spatial properties

#### 4. Activity Tests (`ActivityTests.swift`)
**File**: `SpatialCRM/Tests/UnitTests/ActivityTests.swift`
**Tests**: 11 test cases

- ✅ Activity initialization
- ✅ Activity completion flow
- ✅ Overdue detection
- ✅ Not overdue when completed
- ✅ Activity type icons
- ✅ Sentiment scores
- ✅ Sentiment emojis
- ✅ Duration formatting (minutes)
- ✅ Duration formatting (hours)
- ✅ Activity outcome enumeration
- ✅ Sample data validation

**Coverage**: Activity tracking and sentiment analysis

#### 5. AI Service Tests (`AIServiceTests.swift`)
**File**: `SpatialCRM/Tests/UnitTests/AIServiceTests.swift`
**Tests**: 12 test cases

- ✅ Opportunity scoring returns valid range
- ✅ High value deals get higher scores
- ✅ Advanced stage deals score higher
- ✅ Churn prediction valid range
- ✅ Low health score increases churn risk
- ✅ Stage-appropriate action suggestions
- ✅ Urgent actions for closing deals
- ✅ Cross-sell opportunity identification
- ✅ Stakeholder network analysis
- ✅ Decision maker identification
- ✅ Influence score calculation
- ✅ Natural language query processing

**Coverage**: AI business logic and algorithms

## Test Statistics

```
Total Test Suites: 5
Total Test Cases: 48
Test Code Lines: ~1,200
Coverage Target: 80%
```

## Running Tests

### In Xcode

1. **Run All Tests**:
   ```
   ⌘ + U
   ```

2. **Run Specific Test Suite**:
   - Open Test Navigator (⌘ + 6)
   - Click ▶️ next to desired test suite

3. **Run Single Test**:
   - Click ▶️ next to individual test method

### Via Command Line (macOS only)

```bash
# Note: Requires Xcode project setup first
xcodebuild test \
  -scheme SpatialCRM \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
```

## Test Results Interpretation

### Success
```
✓ All tests passed
Test execution time: X seconds
```

### Failure
```
✗ Test failed: testName
Expected: value1
Actual: value2
```

## What Can Be Tested in Linux Environment

❌ **Cannot Test** (requires Xcode/visionOS):
- Actual Swift compilation
- SwiftData persistence
- RealityKit 3D rendering
- Hand/eye tracking
- Spatial audio
- UI rendering

✅ **Can Validate**:
- File structure and organization
- Code architecture patterns
- Documentation completeness
- Configuration file syntax (XML)
- Git repository state

## Testing Best Practices

### 1. Unit Test Structure

```swift
@Test("Clear test description")
func testFeature() async throws {
    // Arrange
    let object = Object(...)

    // Act
    let result = object.performAction()

    // Assert
    #expect(result == expectedValue)
}
```

### 2. Async Testing

```swift
@Test("Async operation")
func testAsyncFeature() async throws {
    let service = AIService()
    let result = try await service.scoreOpportunity(opp)
    #expect(result.value > 0)
}
```

### 3. Error Testing

```swift
@Test("Error handling")
func testErrorCase() async throws {
    await #expect(throws: CRMError.accountNotFound) {
        try await service.fetchAccount(id: invalidID)
    }
}
```

## Integration Testing

### SwiftData Integration

To test SwiftData persistence:

```swift
@MainActor
@Test("SwiftData CRUD")
func testAccountPersistence() throws {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try ModelContainer(
        for: Account.self,
        configurations: config
    )
    let context = container.mainContext

    let account = Account(name: "Test")
    context.insert(account)
    try context.save()

    let fetched = try context.fetch(FetchDescriptor<Account>())
    #expect(fetched.count == 1)
}
```

### UI Testing

For spatial views:

```swift
@MainActor
@Test("Dashboard displays metrics")
func testDashboardUI() throws {
    let app = XCUIApplication()
    app.launch()

    let metricsGrid = app.otherElements["MetricsGrid"]
    #expect(metricsGrid.exists)
}
```

## Performance Testing

### Benchmark Tests

```swift
@Test("Performance: 1000 accounts")
func testLargeDataset() throws {
    measure {
        let accounts = (0..<1000).map { Account(name: "Account \($0)") }
        let positions = spatialService.calculateCustomerPositions(accounts: accounts)
        #expect(positions.count == 1000)
    }
}
```

### Performance Targets

| Operation | Target | Limit |
|-----------|--------|-------|
| Account fetch (100) | < 50ms | < 100ms |
| AI scoring | < 200ms | < 500ms |
| 3D layout calculation | < 100ms | < 200ms |
| Search query | < 100ms | < 200ms |

## Accessibility Testing

```swift
@Test("VoiceOver labels")
@MainActor
func testAccessibilityLabels() throws {
    let account = Account.sample
    let card = AccountCard(account: account)

    #expect(card.accessibilityLabel != nil)
    #expect(card.accessibilityHint != nil)
}
```

## Test Data

### Sample Data Generator

Use `SampleDataGenerator` for consistent test data:

```swift
let generator = SampleDataGenerator(modelContext: context)
generator.generateCompleteDataset()
```

Generates:
- 6 Sales Reps
- 5 Territories
- 10 Accounts
- 30-60 Contacts
- 20-40 Opportunities
- 60-320 Activities

## Continuous Testing

### Pre-commit Hooks

Add to `.git/hooks/pre-commit`:

```bash
#!/bin/bash
# Run tests before commit
xcodebuild test -scheme SpatialCRM -destination 'platform=visionOS Simulator,name=Apple Vision Pro' || exit 1
```

### CI/CD Integration

GitHub Actions example:

```yaml
- name: Run Tests
  run: |
    xcodebuild test \
      -scheme SpatialCRM \
      -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
      -resultBundlePath TestResults
```

## Known Limitations

1. **visionOS Simulator Required**: Cannot run tests on Linux/Windows
2. **SwiftData**: In-memory testing only in unit tests
3. **RealityKit**: Some 3D features require actual device
4. **Hand Tracking**: Cannot test gesture recognition without hardware

## Future Test Additions

- [ ] Territory model tests
- [ ] SalesRep model tests
- [ ] CollaborationSession tests
- [ ] CRMService integration tests
- [ ] SpatialService layout tests
- [ ] UI snapshot tests
- [ ] Performance benchmarks
- [ ] Accessibility audit tests
- [ ] End-to-end workflow tests

## Debugging Failed Tests

### Enable Detailed Logging

```swift
#if DEBUG
print("Debug info: \(value)")
#endif
```

### Breakpoints in Tests

1. Click line number to set breakpoint
2. Run test in debug mode
3. Inspect variables when stopped

### Test Execution Timeline

View in:
- Test Navigator (⌘ + 6)
- Report Navigator (⌘ + 9)

## Resources

- [Swift Testing Documentation](https://developer.apple.com/documentation/testing)
- [XCTest Guide](https://developer.apple.com/documentation/xctest)
- [visionOS Testing Best Practices](https://developer.apple.com/visionos/testing/)

## Contributing Tests

When adding new features:

1. Write tests first (TDD)
2. Ensure tests pass
3. Maintain >80% code coverage
4. Document test purpose
5. Include in PR description

---

**Last Updated**: 2025-11-17
**Test Framework**: Swift Testing (Xcode 16+)
**Platform**: visionOS 2.0+
