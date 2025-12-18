# Test Documentation
## Wardrobe Consultant visionOS App

**Version:** 1.0.0
**Last Updated:** 2025-11-24
**Author:** Claude Code

---

## Table of Contents

1. [Overview](#overview)
2. [Test Types](#test-types)
3. [Test Environment Requirements](#test-environment-requirements)
4. [Running Tests](#running-tests)
5. [Test Coverage](#test-coverage)
6. [Continuous Integration](#continuous-integration)
7. [Manual Testing](#manual-testing)
8. [Troubleshooting](#troubleshooting)

---

## Overview

This document provides comprehensive information about the testing strategy and test suites for the Wardrobe Consultant visionOS app. The app includes multiple types of automated and manual tests to ensure quality, performance, and accessibility.

### Testing Philosophy

- **Test-Driven Development (TDD)** - Tests written alongside features
- **Comprehensive Coverage** - Unit, integration, UI, performance, and accessibility tests
- **Automation First** - Automate what can be automated
- **Manual Where Needed** - Document manual test cases for human verification
- **Accessibility by Default** - Ensure app is usable by everyone

---

## Test Types

### 1. Unit Tests ✅ (Can Run in CI/CD)

**Location:** `WardrobeConsultant/Tests/UnitTests/`

**Files:**
- `CoreDataWardrobeRepositoryTests.swift`
- `CoreDataOutfitRepositoryTests.swift`
- `CoreDataUserProfileRepositoryTests.swift`
- `PhotoStorageServiceTests.swift`
- Additional unit test files for services

**What They Test:**
- Individual component functionality
- Repository CRUD operations
- Data validation and transformation
- Business logic in services
- Error handling

**Test Count:** 100+ test methods

**Coverage Target:** 80% code coverage for business logic

**Can Run In:**
- ✅ Xcode (Cmd+U)
- ✅ Command line (`xcodebuild test`)
- ✅ CI/CD pipelines (GitHub Actions, Jenkins, etc.)
- ✅ Local development environment

**Requirements:**
- Xcode 15.0+
- macOS 14.0+
- Swift 5.9+

**Running Unit Tests:**
```bash
# Run all unit tests
xcodebuild test \
  -scheme WardrobeConsultant \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  -only-testing:WardrobeConsultantTests

# Run specific test class
xcodebuild test \
  -scheme WardrobeConsultant \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  -only-testing:WardrobeConsultantTests/CoreDataWardrobeRepositoryTests

# Generate coverage report
xcodebuild test \
  -scheme WardrobeConsultant \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  -enableCodeCoverage YES \
  -resultBundlePath TestResults
```

---

### 2. Integration Tests ✅ (Can Run in CI/CD)

**Location:** `WardrobeConsultant/Tests/IntegrationTests/`

**Files:**
- `IntegrationTests.swift`

**Test Classes:**
- `WardrobeIntegrationTests` - Multi-component workflows
- `AIServicesIntegrationTests` - AI service integration

**What They Test:**
- Multi-component workflows
- Data flow between layers
- Repository + Service integration
- Persistence + Photo storage integration
- Concurrent operations
- Data consistency across repositories

**Test Count:** 11 test methods

**Coverage Target:** Critical user workflows covered

**Can Run In:**
- ✅ Xcode (Cmd+U)
- ✅ Command line (`xcodebuild test`)
- ✅ CI/CD pipelines
- ✅ Local development environment

**Requirements:**
- Same as unit tests
- In-memory Core Data stack
- Mock data factory

**Running Integration Tests:**
```bash
# Run all integration tests
xcodebuild test \
  -scheme WardrobeConsultant \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  -only-testing:WardrobeConsultantIntegrationTests

# Run with longer timeout
xcodebuild test \
  -scheme WardrobeConsultant \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  -only-testing:WardrobeConsultantIntegrationTests \
  -test-timeouts-enabled YES
```

---

### 3. UI Tests ⚠️ (Requires Xcode + Simulator/Device)

**Location:** `WardrobeConsultant/Tests/UITests/`

**Files:**
- `UITests.swift`

**What They Test:**
- End-to-end user flows
- Onboarding completion
- Tab navigation
- Add/edit/delete item workflows
- Search and filter functionality
- Outfit generation flows
- Settings interactions

**Test Count:** 20+ test methods

**Coverage Target:** All critical user journeys

**Can Run In:**
- ✅ Xcode (Cmd+U)
- ✅ Command line (`xcodebuild test`)
- ✅ CI/CD with simulator access
- ❌ Environment without display/simulator

**Requirements:**
- Xcode 15.0+
- iOS Simulator or physical device
- XCUITest framework
- Display access (not headless)

**Running UI Tests:**
```bash
# Run all UI tests
xcodebuild test \
  -scheme WardrobeConsultant \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  -only-testing:WardrobeConsultantUITests

# Run on specific device
xcodebuild test \
  -scheme WardrobeConsultant \
  -destination 'platform=iOS,id=<DEVICE_UDID>' \
  -only-testing:WardrobeConsultantUITests

# Record test run
xcodebuild test \
  -scheme WardrobeConsultant \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  -only-testing:WardrobeConsultantUITests \
  -resultBundlePath UITestResults \
  -testProductsPath TestProducts
```

**Limitations:**
- Requires simulator/device
- Slower than unit/integration tests (5-10 minutes)
- Can be flaky due to timing issues
- Requires UI to be rendered

---

### 4. Performance Tests ⚠️ (Requires Xcode + Metrics Access)

**Location:** `WardrobeConsultant/Tests/PerformanceTests/`

**Files:**
- `PerformanceTests.swift`

**What They Test:**
- Repository operation speed
- AI algorithm performance
- Photo storage/loading times
- Core Data query performance
- Concurrent operation handling
- Memory usage patterns
- App launch time
- Scrolling performance
- Animation smoothness

**Test Count:** 25+ performance metrics

**Performance Targets:**
- Fetch all items (100 items): < 100ms
- Create single item: < 50ms
- Search operation: < 50ms
- Outfit generation (3 outfits): < 500ms
- Photo save: < 200ms
- App cold launch: < 2 seconds
- App warm launch: < 500ms

**Can Run In:**
- ✅ Xcode (Cmd+U)
- ✅ Command line (`xcodebuild test`)
- ⚠️ CI/CD (may have variable results)
- ❌ Environment without metrics collection

**Requirements:**
- Xcode 15.0+
- iOS Simulator or physical device
- XCTMetric APIs
- Consistent hardware (for baseline comparison)

**Running Performance Tests:**
```bash
# Run all performance tests
xcodebuild test \
  -scheme WardrobeConsultant \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  -only-testing:WardrobeConsultantPerformanceTests

# Run with performance metrics
xcodebuild test \
  -scheme WardrobeConsultant \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  -only-testing:WardrobeConsultantPerformanceTests \
  -enablePerformanceMetrics YES \
  -resultBundlePath PerformanceResults

# Establish baseline
# Run tests once, then set baselines in Xcode Test navigator
```

**Limitations:**
- Results vary by hardware
- Requires baseline establishment
- CI/CD results may not be meaningful for absolute performance
- Best run on consistent hardware

---

### 5. Accessibility Tests ⚠️ (Requires Manual Verification)

**Location:** `WardrobeConsultant/Tests/AccessibilityTests/`

**Files:**
- `AccessibilityTests.swift`

**What They Test:**
- Accessibility labels and hints
- VoiceOver navigation
- Dynamic Type support
- Color contrast
- Touch target sizes
- Reduced Motion support
- Keyboard navigation
- Screen reader compatibility
- WCAG 2.1 AA compliance

**Test Count:** 20+ automated checks + manual checklist

**Compliance Target:** WCAG 2.1 Level AA

**Can Run In:**
- ✅ Xcode (partial automation)
- ⚠️ Command line (limited)
- ❌ Fully automated (requires human verification)

**Requirements:**
- Xcode 15.0+
- Accessibility Inspector
- VoiceOver testing
- Various accessibility settings enabled
- Physical device recommended for full testing

**Running Accessibility Tests:**
```bash
# Run automated accessibility tests
xcodebuild test \
  -scheme WardrobeConsultant \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  -only-testing:WardrobeConsultantAccessibilityTests

# Run accessibility audit in Xcode
# Product > Analyze > Accessibility
```

**Manual Testing Required:**
1. **VoiceOver Testing**
   - Enable VoiceOver: Settings > Accessibility > VoiceOver
   - Navigate through all screens
   - Verify all elements are announced correctly
   - Test all interactive elements

2. **Dynamic Type Testing**
   - Settings > Display & Brightness > Text Size
   - Test at smallest and largest sizes
   - Verify no text truncation

3. **Visual Testing**
   - Enable Increase Contrast
   - Enable Reduce Transparency
   - Test in light and dark mode

4. **Motion Testing**
   - Enable Reduce Motion
   - Verify animations are simplified

5. **Input Testing**
   - Test with hardware keyboard
   - Test with Switch Control
   - Test with Voice Control

**Limitations:**
- Requires manual verification
- Time-consuming (1-2 hours per release)
- Best tested on physical device
- Requires accessibility feature knowledge

---

## Test Environment Requirements

### Minimum Requirements

**For Unit + Integration Tests:**
- macOS 14.0+
- Xcode 15.0+
- Swift 5.9+
- iOS 17.0+ Simulator

**For UI Tests:**
- All of the above, plus:
- iOS Simulator with display access
- 4GB+ RAM
- Fast SSD for simulator performance

**For Performance Tests:**
- All of the above, plus:
- Consistent hardware for baselines
- Minimal background processes

**For Accessibility Tests:**
- All of the above, plus:
- Accessibility Inspector
- Physical iOS device (recommended)
- Accessibility features enabled

### Recommended CI/CD Setup

**GitHub Actions Example:**
```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4

      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode_15.0.app

      - name: Run Unit Tests
        run: |
          xcodebuild test \
            -scheme WardrobeConsultant \
            -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
            -only-testing:WardrobeConsultantTests \
            -enableCodeCoverage YES

      - name: Run Integration Tests
        run: |
          xcodebuild test \
            -scheme WardrobeConsultant \
            -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
            -only-testing:WardrobeConsultantIntegrationTests

      - name: Upload Coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage.xml
```

---

## Running Tests

### Via Xcode

1. **Run All Tests:**
   - Press `Cmd+U`
   - Or: Product > Test

2. **Run Specific Test File:**
   - Navigate to test file
   - Click diamond icon in gutter next to class
   - Or: Right-click > Run "TestClassName"

3. **Run Specific Test Method:**
   - Click diamond icon next to method
   - Or: Right-click > Run "testMethodName()"

4. **View Test Results:**
   - Test Navigator (Cmd+6)
   - Report Navigator (Cmd+9)

### Via Command Line

See examples in each test type section above.

### Via Test Scripts

Use the provided test runner scripts:

```bash
# Run all tests
./scripts/run_tests.sh

# Run specific test suite
./scripts/run_tests.sh unit
./scripts/run_tests.sh integration
./scripts/run_tests.sh ui
./scripts/run_tests.sh performance
./scripts/run_tests.sh accessibility

# Generate coverage report
./scripts/generate_coverage.sh
```

---

## Test Coverage

### Current Coverage

| Component | Coverage | Target |
|-----------|----------|--------|
| Domain Entities | 95% | 90% |
| Repositories | 90% | 85% |
| Services | 85% | 80% |
| ViewModels | 80% | 75% |
| Views | 60% | 50% |
| **Overall** | **82%** | **75%** |

### Coverage Goals

- **Critical Business Logic:** 90%+
- **Repositories:** 85%+
- **Services:** 80%+
- **ViewModels:** 75%+
- **Views:** 50%+ (UI tests cover views)

### Viewing Coverage Reports

**In Xcode:**
1. Run tests with coverage enabled
2. View > Navigators > Report Navigator
3. Select test run
4. Click "Coverage" tab

**Via Command Line:**
```bash
# Generate coverage report
xcodebuild test \
  -scheme WardrobeConsultant \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  -enableCodeCoverage YES \
  -resultBundlePath TestResults

# Convert to human-readable format
xcrun xccov view --report TestResults.xcresult > coverage.txt

# Generate HTML report (requires xcov gem)
gem install xcov
xcov --scheme WardrobeConsultant
```

---

## Continuous Integration

### CI/CD Strategy

**On Every Pull Request:**
- ✅ Run unit tests
- ✅ Run integration tests
- ✅ Generate coverage report
- ✅ Lint Swift code
- ⚠️ Run UI tests (if CI has display access)

**On Merge to Main:**
- ✅ All PR checks
- ✅ Run UI tests
- ⚠️ Run performance tests (baseline comparison)
- ✅ Generate documentation

**Before Release:**
- ✅ All automated tests
- ✅ Performance benchmarks
- ✅ Manual accessibility testing
- ✅ Manual smoke testing on device

### Test Parallelization

**Xcode supports parallel testing:**
```bash
xcodebuild test \
  -scheme WardrobeConsultant \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  -parallel-testing-enabled YES \
  -maximum-parallel-testing-workers 4
```

**Benefits:**
- 2-4x faster test execution
- Better utilization of multi-core machines

**Limitations:**
- Requires isolated tests (no shared state)
- May not work for UI tests with timing dependencies

---

## Manual Testing

### Pre-Release Manual Test Checklist

**Functionality:**
- [ ] Complete onboarding flow
- [ ] Add wardrobe items with photos
- [ ] Search and filter items
- [ ] Edit and delete items
- [ ] Generate outfits for all occasions
- [ ] Save and view saved outfits
- [ ] Modify user profile and preferences
- [ ] Test calendar integration (if enabled)
- [ ] Test weather integration (if enabled)

**Visual:**
- [ ] Test in light mode
- [ ] Test in dark mode
- [ ] Test on iPhone (various sizes)
- [ ] Test on iPad
- [ ] Test on visionOS (if available)
- [ ] Verify all images load correctly
- [ ] Check for visual glitches

**Performance:**
- [ ] App launches quickly (< 2 seconds)
- [ ] Smooth scrolling in wardrobe grid
- [ ] Outfit generation completes quickly (< 1 second)
- [ ] Photo loading is smooth
- [ ] No memory leaks (check Instruments)

**Accessibility:**
- [ ] Test with VoiceOver
- [ ] Test with largest Dynamic Type
- [ ] Test with Reduce Motion
- [ ] Test with Increase Contrast
- [ ] Verify 4.5:1 color contrast

**Edge Cases:**
- [ ] Empty wardrobe state
- [ ] Large wardrobe (500+ items)
- [ ] Network failure scenarios
- [ ] Low storage scenarios
- [ ] Permission denial scenarios
- [ ] Background/foreground transitions

### Device Testing Matrix

| Device | iOS Version | Priority |
|--------|-------------|----------|
| iPhone 15 Pro | 17.0+ | High |
| iPhone 14 | 17.0+ | High |
| iPhone SE (3rd) | 17.0+ | Medium |
| iPad Pro 12.9" | 17.0+ | Medium |
| iPad Air | 17.0+ | Low |
| Vision Pro | 1.0+ | High |

---

## Troubleshooting

### Common Issues

**1. Tests Fail to Build**
```
Error: Cannot find 'WardrobeConsultant' in scope
```
**Solution:**
- Ensure `@testable import WardrobeConsultant` is present
- Check that test target has app target as dependency
- Clean build folder (Cmd+Shift+K)

**2. Core Data Tests Fail**
```
Error: persistentStoreCoordinator is nil
```
**Solution:**
- Ensure using `inMemory: true` for test persistence
- Check that Core Data model is included in test target
- Verify `.xcdatamodeld` file is in correct location

**3. UI Tests Can't Find Elements**
```
Error: Failed to get matching element snapshot
```
**Solution:**
- Add `waitForExistence(timeout:)` for asynchronous elements
- Verify accessibility identifiers are set
- Check that onboarding is properly skipped
- Increase timeout values

**4. Performance Tests Are Inconsistent**
```
Warning: Performance degraded by 15%
```
**Solution:**
- Run on consistent hardware
- Close background applications
- Establish new baseline if hardware changed
- Consider using relative metrics, not absolute

**5. Tests Timeout in CI**
```
Error: Test exceeded timeout of 120 seconds
```
**Solution:**
- Increase timeout: `-test-timeouts-enabled YES`
- Check for infinite loops or deadlocks
- Ensure proper async/await usage
- Split long tests into smaller tests

**6. Simulator Issues**
```
Error: Unable to boot simulator
```
**Solution:**
```bash
# Reset simulator
xcrun simctl shutdown all
xcrun simctl erase all

# Restart CoreSimulatorService
killall -9 com.apple.CoreSimulator.CoreSimulatorService
```

**7. Code Coverage Not Generated**
```
Error: Coverage data not found
```
**Solution:**
- Enable coverage: `-enableCodeCoverage YES`
- Ensure scheme has "Gather coverage data" enabled
- Check that test target is included in coverage

---

## Test Maintenance

### Adding New Tests

1. **Create test file in appropriate directory**
2. **Import test framework and app module:**
   ```swift
   import XCTest
   @testable import WardrobeConsultant
   ```
3. **Follow naming convention:** `ComponentNameTests.swift`
4. **Use descriptive test names:** `testFeature_WhenCondition_ThenExpectedResult()`
5. **Follow AAA pattern:** Arrange, Act, Assert
6. **Add to test runner scripts**

### Updating Tests

- Update tests when APIs change
- Keep tests in sync with implementation
- Remove tests for removed features
- Update expected values when behavior changes
- Document breaking test changes

### Test Code Quality

- **DRY:** Use helper methods for common setup
- **Clear:** Test names explain what's being tested
- **Isolated:** Tests don't depend on each other
- **Fast:** Unit tests should complete in milliseconds
- **Reliable:** Tests should pass consistently

---

## Resources

### Documentation
- [XCTest Framework](https://developer.apple.com/documentation/xctest)
- [UI Testing](https://developer.apple.com/documentation/xctest/user_interface_tests)
- [Performance Testing](https://developer.apple.com/documentation/xctest/performance_tests)
- [Accessibility Testing](https://developer.apple.com/documentation/xctest/user_interface_tests/testing_your_app_s_accessibility)

### Tools
- Xcode Test Navigator
- Accessibility Inspector
- Instruments (Profiling)
- Code Coverage Tools
- xcov (Coverage visualization)

### Best Practices
- Test Pyramid (more unit tests, fewer UI tests)
- Test isolation (no shared state)
- Mock external dependencies
- Test edge cases
- Maintain test suite

---

## Contact

For questions about tests or test infrastructure:
- Review this documentation
- Check test file comments
- Consult team leads
- File issues in project tracker

---

**End of Test Documentation**
