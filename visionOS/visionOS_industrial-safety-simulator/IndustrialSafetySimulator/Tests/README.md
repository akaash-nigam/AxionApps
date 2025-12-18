# Industrial Safety Simulator - Testing Guide

## 📋 Overview

This document provides comprehensive instructions for running tests, understanding test coverage, and contributing to the test suite for the Industrial Safety Simulator visionOS application.

## 🎯 Testing Philosophy

Our testing strategy follows the **testing pyramid** approach:

```
        /\
       /UI\          10% - UI/E2E Tests
      /----\
     / Intg \        20% - Integration Tests
    /--------\
   /   Unit   \      70% - Unit Tests
  /------------\
```

**Coverage Targets**:
- **Unit Tests**: 85% code coverage minimum
- **Integration Tests**: 75% coverage of critical flows
- **UI Tests**: 100% coverage of user-facing features
- **Accessibility**: 100% WCAG 2.1 Level AA compliance

## 📊 Test Environment Matrix

| Test Type | Current Environment | visionOS Simulator | Vision Pro Hardware |
|-----------|-------------------|-------------------|-------------------|
| Unit Tests | ✅ **Can Run** | ✅ Can Run | ✅ Can Run |
| Integration Tests | ✅ **Can Run** | ✅ Can Run | ✅ Can Run |
| UI Tests (Basic) | ❌ Cannot Run | ⚠️ **Required** | ✅ Can Run |
| Performance Tests (Logic) | ✅ **Can Run** | ✅ Can Run | ✅ Can Run |
| Performance Tests (Rendering) | ❌ Cannot Run | ⚠️ Simulated | 🔴 **Required** |
| Accessibility Tests (Code) | ✅ **Can Run** | ✅ Can Run | ✅ Can Run |
| Accessibility Tests (VoiceOver) | ❌ Cannot Run | ⚠️ **Required** | ✅ Can Run |
| Hand Tracking Tests | ❌ Cannot Run | ❌ Cannot Run | 🔴 **Required** |
| Eye Tracking Tests | ❌ Cannot Run | ❌ Cannot Run | 🔴 **Required** |
| Spatial Audio Tests | ❌ Cannot Run | ⚠️ Simulated | 🔴 **Required** |

### Legend

- ✅ **Can Run**: Executable in this environment now
- ⚠️ **Required**: Needs visionOS Simulator (not currently available)
- 🔴 **Required**: Needs actual Vision Pro hardware
- ❌ **Cannot Run**: Not possible in this environment

## 🚀 Quick Start

### Running Tests in Xcode

1. **Open Project**:
   ```bash
   cd IndustrialSafetySimulator
   open IndustrialSafetySimulator.xcodeproj
   ```

2. **Run All Tests**:
   - Press `⌘ + U` (Command + U)
   - Or: Product → Test

3. **Run Specific Test Suite**:
   - Click the diamond icon next to test suite name
   - Or use Test Navigator (`⌘ + 6`)

4. **Run Single Test**:
   - Click diamond icon next to specific test
   - Or place cursor in test and press `⌘ + U`

### Running Tests from Command Line

```bash
# Run all tests
swift test

# Run with specific configuration
swift test -c release

# Run specific test suite
swift test --filter SafetyUserTests

# Run tests with coverage
swift test --enable-code-coverage

# Generate coverage report
xcrun llvm-cov report .build/debug/IndustrialSafetySimulatorPackageTests.xctest/Contents/MacOS/IndustrialSafetySimulatorPackageTests \
  -instr-profile=.build/debug/codecov/default.profdata \
  -use-color
```

### Running Tests in CI/CD

See [CI/CD Integration Guide](#cicd-integration) below.

## 📁 Test Organization

```
Tests/
├── UnitTests/                          ✅ Can run now
│   ├── SafetyUserTests.swift          # User model tests
│   ├── SafetyScenarioTests.swift      # Scenario & hazard tests
│   ├── TrainingSessionTests.swift     # Session logic tests
│   ├── PerformanceMetricsTests.swift  # Analytics tests
│   ├── DashboardViewModelTests.swift  # Dashboard VM tests
│   └── AnalyticsViewModelTests.swift  # Analytics VM tests
│
├── IntegrationTests/                   ✅ Can run now
│   └── TrainingFlowIntegrationTests.swift  # End-to-end flows
│
├── UITests/                            ⚠️ Requires simulator
│   └── DashboardUITests.swift         # UI interaction tests
│
├── PerformanceTests/                   ✅ Logic tests can run now
│   └── PerformanceBenchmarkTests.swift # Performance benchmarks
│
├── AccessibilityTests/                 ✅ Can run now
│   └── AccessibilityComplianceTests.swift  # WCAG compliance
│
├── VisionOSTests/                      🔴 Requires hardware
│   └── VISIONOS_TESTING_GUIDE.md      # Hardware test documentation
│
├── TESTING_STRATEGY.md                 # Overall strategy document
└── README.md                           # This file
```

## ✅ Tests You Can Run Right Now

The following tests can be executed **in the current environment** without visionOS Simulator or Vision Pro hardware:

### 1. Unit Tests (✅ All Runnable)

**SafetyUserTests.swift** - 18 tests
- User model initialization and validation
- Certification tracking and expiration
- Role-based permission testing
- Edge cases and error handling

**SafetyScenarioTests.swift** - 21 tests
- Scenario creation and configuration
- Hazard detection and proximity testing
- Environment type validation
- Passing score calculations

**TrainingSessionTests.swift** - 19 tests
- Session lifecycle management
- Score calculation and tracking
- Session status transitions
- Result aggregation

**PerformanceMetricsTests.swift** - 20 tests
- Metrics initialization and updates
- Pass rate calculations
- Skill level progression
- Risk score calculations
- Trend data analysis

**DashboardViewModelTests.swift** - Tests in progress
- Dashboard state management
- Module filtering and search
- Quick actions functionality
- Progress tracking

**AnalyticsViewModelTests.swift** - 18 tests
- Analytics data loading
- Time period filtering
- Chart data generation
- Export functionality
- Comparison calculations

**Total: ~100+ unit tests** ✅

### 2. Integration Tests (✅ All Runnable)

**TrainingFlowIntegrationTests.swift** - 12 tests
- Complete training workflow
- Multi-scenario completion
- Metrics integration
- Certification awarding
- Data persistence
- Error handling

**AppStateIntegrationTests.swift** - 3 tests
- Authentication flow
- Session lifecycle
- Progress tracking

**Total: 15+ integration tests** ✅

### 3. Accessibility Tests (✅ All Runnable)

**AccessibilityComplianceTests.swift** - 25 tests
- Color contrast compliance (WCAG AA)
- Dynamic Type support
- Touch target sizing
- VoiceOver labels and hints
- Gesture alternatives
- Reduced motion support
- Audio alternatives
- Localization support
- Cognitive accessibility
- Focus management

**Total: 25+ accessibility tests** ✅

### 4. Performance Tests (✅ Logic Tests Runnable)

**PerformanceBenchmarkTests.swift** - 15 tests
- Data model creation benchmarks
- Hazard detection performance
- Search and filter performance
- Score calculation performance
- Concurrent operations
- Memory usage validation

**Total: 15+ performance benchmarks** ✅

### **GRAND TOTAL: 155+ Tests Runnable Now** ✅

## ⚠️ Tests Requiring visionOS Simulator

These tests require Xcode with visionOS Simulator (not currently available):

### UI Tests
- Dashboard navigation testing
- Module selection flows
- Settings interaction
- Window management
- Search and filter UI
- Accessibility navigation

**How to Run (when simulator available)**:
```bash
# In Xcode
1. Select visionOS Simulator as destination
2. Press ⌘ + U to run all tests
3. Or run UITests scheme specifically

# Command line
xcodebuild test \
  -scheme IndustrialSafetySimulator \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -only-testing:IndustrialSafetySimulatorUITests
```

## 🔴 Tests Requiring Vision Pro Hardware

These tests **require actual Apple Vision Pro** device and cannot be run in simulator:

- **Hand Tracking Tests**: Pinch gestures, hand pose, equipment manipulation
- **Eye Tracking Tests**: Gaze accuracy, attention tracking, hazard fixation
- **Spatial Audio Tests**: 3D audio positioning, directional accuracy
- **Performance Tests**: Frame rate (90 FPS), memory usage, battery, thermal
- **Comfort Tests**: Extended session ergonomics, motion sickness
- **Multi-User Tests**: SharePlay synchronization, spatial voice chat

📖 **See**: [`VISIONOS_TESTING_GUIDE.md`](VisionOSTests/VISIONOS_TESTING_GUIDE.md) for complete hardware testing procedures.

## 📊 Test Coverage

### Current Coverage Targets

| Component | Target | Status |
|-----------|--------|--------|
| Data Models | 90% | ✅ On track |
| ViewModels | 85% | ✅ On track |
| Views | 70% | ⚠️ Needs UI tests |
| Services | 80% | ✅ On track |
| Utilities | 95% | ✅ On track |
| Overall | 85% | 🎯 Target |

### Measuring Coverage

**In Xcode**:
1. Edit Scheme (⌘ + <)
2. Test tab → Options
3. Enable "Gather coverage for some targets"
4. Select IndustrialSafetySimulator target
5. Run tests (⌘ + U)
6. View coverage in Report Navigator (⌘ + 9)

**Command Line**:
```bash
# Enable coverage
swift test --enable-code-coverage

# Generate HTML report
xcrun llvm-cov show \
  .build/debug/IndustrialSafetySimulatorPackageTests.xctest/Contents/MacOS/IndustrialSafetySimulatorPackageTests \
  -instr-profile=.build/debug/codecov/default.profdata \
  -format=html \
  -output-dir=coverage-report

# View report
open coverage-report/index.html
```

## 🏗️ Writing New Tests

### Test Structure (AAA Pattern)

```swift
import Testing
@testable import IndustrialSafetySimulator

@Suite("Feature Name Tests")
struct FeatureTests {

    @Test("Descriptive test name")
    func testFeatureBehavior() {
        // Arrange - Set up test data
        let input = createTestData()

        // Act - Execute the behavior being tested
        let result = performOperation(input)

        // Assert - Verify the outcome
        #expect(result == expectedValue)
    }
}
```

### Test Naming Convention

Use descriptive names that explain **what** is being tested and **what** should happen:

✅ **Good**:
- `testUserInitializationSetsCorrectDefaultValues()`
- `testHazardDetectionIdentifiesNearbyThreats()`
- `testSessionCompletionUpdatesUserMetrics()`

❌ **Bad**:
- `testUser()`
- `test1()`
- `testHazard()`

### Test Documentation

Mark tests with environment requirements:

```swift
@Test("✅ Test that can run in any environment")
func testBasicLogic() { }

@Test("⚠️ Test requiring visionOS Simulator")
func testWarningSimulator_UIInteraction() { }

@Test("🔴 Test requiring Vision Pro hardware")
func testHardware_HandTracking() { }
```

### Parameterized Tests

Use `arguments:` for testing multiple scenarios:

```swift
@Test("Pass rate calculates correctly", arguments: [
    (10, 8, 80.0),   // completed, passed, expected rate
    (5, 5, 100.0),
    (10, 0, 0.0),
])
func testPassRateCalculation(completed: Int, passed: Int, expected: Double) {
    // Test implementation
}
```

### Async Tests

```swift
@Test("Async operation completes successfully")
func testAsyncOperation() async {
    // Act
    let result = await performAsyncTask()

    // Assert
    #expect(result.isSuccess)
}
```

### Test Tags

Organize tests with tags:

```swift
extension Tag {
    @Tag static var unit: Self
    @Tag static var integration: Self
    @Tag static var smoke: Self
    @Tag static var critical: Self
}

@Test("Important test", .tags(.critical, .smoke))
func testCriticalFeature() { }
```

## 🔄 CI/CD Integration

### GitHub Actions Example

Create `.github/workflows/tests.yml`:

```yaml
name: Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  unit-tests:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4

      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode_15.2.app

      - name: Run Unit Tests
        run: |
          cd IndustrialSafetySimulator
          swift test --enable-code-coverage

      - name: Generate Coverage Report
        run: |
          xcrun llvm-cov export \
            .build/debug/IndustrialSafetySimulatorPackageTests.xctest/Contents/MacOS/IndustrialSafetySimulatorPackageTests \
            -instr-profile=.build/debug/codecov/default.profdata \
            -format=lcov > coverage.lcov

      - name: Upload Coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage.lcov

  ui-tests:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4

      - name: Run UI Tests on Simulator
        run: |
          xcodebuild test \
            -scheme IndustrialSafetySimulator \
            -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
            -only-testing:IndustrialSafetySimulatorUITests
```

### Fastlane Configuration

Create `fastlane/Fastfile`:

```ruby
lane :test do
  scan(
    scheme: "IndustrialSafetySimulator",
    devices: ["Apple Vision Pro"],
    code_coverage: true,
    output_directory: "./test-reports"
  )
end

lane :test_unit do
  scan(
    scheme: "IndustrialSafetySimulator",
    only_testing: ["UnitTests"],
    code_coverage: true
  )
end
```

## 🐛 Debugging Tests

### Viewing Test Failures

```swift
// Add detailed failure messages
#expect(result == expected,
        "Expected \(expected), but got \(result)")

// Use custom expectation
#expect(user.isValid,
        "User should be valid: \(user.validationErrors)")
```

### Test Execution Options

```bash
# Run tests in parallel (faster)
swift test --parallel

# Run specific test
swift test --filter testUserInitialization

# Verbose output
swift test --verbose

# Debug mode
swift test -c debug
```

### Common Issues

**Issue**: Tests timeout
```swift
// Solution: Increase timeout
@Test("Long-running operation", .timeLimit(.minutes(5)))
func testLongOperation() async { }
```

**Issue**: Flaky tests due to timing
```swift
// Solution: Use async/await properly
@Test("Async operation")
func testAsync() async {
    await performOperation()  // Don't use sleep()
    #expect(result.isComplete)
}
```

**Issue**: Tests fail on CI but pass locally
```swift
// Solution: Avoid hardcoded paths
let testBundle = Bundle.module  // ✅ Good
let path = "/Users/me/test.json"  // ❌ Bad
```

## 📈 Test Metrics & Reporting

### Key Metrics to Track

1. **Test Count**: Total number of tests
2. **Pass Rate**: Percentage of passing tests
3. **Code Coverage**: Percentage of code tested
4. **Test Execution Time**: How long tests take
5. **Flaky Tests**: Tests that intermittently fail

### Generating Reports

**XCResult to HTML**:
```bash
# Install xcresult tool
brew install chargepoint/xcparse/xcparse

# Convert results
xcparse --output-format html \
  DerivedData/Logs/Test/*.xcresult \
  test-results.html
```

**Slather for Coverage**:
```bash
# Install
gem install slather

# Generate HTML report
slather coverage \
  --html \
  --output-directory ./coverage \
  --scheme IndustrialSafetySimulator \
  IndustrialSafetySimulator.xcodeproj
```

## 🎯 Test Execution Checklist

### Before Committing Code

- [ ] All unit tests pass locally (`swift test`)
- [ ] Code coverage meets target (85%+)
- [ ] New features have corresponding tests
- [ ] No test warnings or deprecations
- [ ] Tests are deterministic (no random failures)

### Before Pull Request

- [ ] All tests pass on CI
- [ ] Integration tests verify feature works end-to-end
- [ ] Accessibility tests pass for new UI
- [ ] Performance tests show no regression
- [ ] Test documentation is updated

### Before Release

- [ ] All UI tests pass on visionOS Simulator
- [ ] Critical paths have smoke tests
- [ ] Performance benchmarks meet targets
- [ ] Hardware-specific tests documented
- [ ] Test coverage report generated

## 📚 Additional Resources

### Documentation
- [TESTING_STRATEGY.md](TESTING_STRATEGY.md) - Overall testing approach
- [VISIONOS_TESTING_GUIDE.md](VisionOSTests/VISIONOS_TESTING_GUIDE.md) - Hardware testing procedures
- [Swift Testing Documentation](https://developer.apple.com/documentation/testing)
- [XCTest Documentation](https://developer.apple.com/documentation/xctest)

### Tools
- **Xcode Test Navigator**: ⌘ + 6
- **Code Coverage Viewer**: Report Navigator → Coverage
- **Test Plans**: Organize and configure test suites
- **Accessibility Inspector**: Xcode → Developer Tools

### Best Practices
- Write tests before fixing bugs (TDD)
- Keep tests independent and isolated
- Use descriptive test names
- Mock external dependencies
- Test edge cases and error conditions
- Maintain fast test execution

## 🤝 Contributing

When adding new tests:

1. **Choose the Right Location**:
   - Unit tests → `Tests/UnitTests/`
   - Integration tests → `Tests/IntegrationTests/`
   - UI tests → `Tests/UITests/`
   - Performance → `Tests/PerformanceTests/`
   - Accessibility → `Tests/AccessibilityTests/`

2. **Follow Naming Conventions**:
   - Test files: `[Feature]Tests.swift`
   - Test suites: `@Suite("[Feature] Tests")`
   - Test functions: `test[Feature][Scenario]()`

3. **Add Environment Markers**:
   - ✅ for tests runnable anywhere
   - ⚠️ for simulator-required tests
   - 🔴 for hardware-required tests

4. **Update Documentation**:
   - Add test to appropriate section in this README
   - Update coverage targets if applicable
   - Document any new test utilities

## 📞 Support

For questions or issues with tests:

1. Check this README and TESTING_STRATEGY.md
2. Review existing test examples
3. Check CI/CD logs for failures
4. Consult the team's testing channel

---

**Last Updated**: 2024
**Test Framework**: Swift Testing + XCTest
**Total Tests**: 155+ (and growing)
**Coverage Target**: 85%
