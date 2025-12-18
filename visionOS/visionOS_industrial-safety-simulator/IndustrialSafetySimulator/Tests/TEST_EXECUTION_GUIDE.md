# Test Execution Guide

## 🎯 Purpose

This guide provides step-by-step instructions for executing tests in different environments and scenarios.

## 📋 Table of Contents

1. [Environment Setup](#environment-setup)
2. [Running Tests Locally](#running-tests-locally)
3. [Running Tests in CI/CD](#running-tests-in-cicd)
4. [Test Filtering and Selection](#test-filtering-and-selection)
5. [Troubleshooting](#troubleshooting)

## 🛠️ Environment Setup

### Prerequisites

**Required**:
- macOS 14.0+ (Sonoma)
- Xcode 15.2+
- Swift 6.0+
- Command Line Tools: `xcode-select --install`

**Optional** (for advanced testing):
- visionOS Simulator (for UI tests)
- Apple Vision Pro (for hardware tests)
- Fastlane: `brew install fastlane`
- xcparse: `brew install chargepoint/xcparse/xcparse`

### Initial Setup

```bash
# 1. Clone repository
git clone https://github.com/yourorg/visionOS_industrial-safety-simulator.git
cd visionOS_industrial-safety-simulator/IndustrialSafetySimulator

# 2. Verify Swift version
swift --version
# Should show: Swift version 6.0 or later

# 3. Build project
swift build

# 4. Verify tests can run
swift test --list-tests
```

## 🚀 Running Tests Locally

### Method 1: Xcode GUI (Recommended for Development)

#### Run All Tests
1. Open `IndustrialSafetySimulator.xcodeproj` in Xcode
2. Press `⌘ + U` (Command + U)
3. View results in Test Navigator (`⌘ + 6`)

#### Run Specific Test Suite
1. Open Test Navigator (`⌘ + 6`)
2. Find test suite (e.g., `SafetyUserTests`)
3. Click diamond icon next to suite name
4. Or: Right-click → Run

#### Run Single Test
1. Open test file
2. Click diamond icon next to specific test
3. Or: Place cursor in test function and press `⌘ + U`

#### View Test Results
- **Test Navigator**: `⌘ + 6` → See pass/fail status
- **Report Navigator**: `⌘ + 9` → Detailed test logs
- **Issue Navigator**: `⌘ + 5` → Failed test details

### Method 2: Command Line (Recommended for CI/CD)

#### Run All Tests
```bash
swift test
```

#### Run with Release Configuration
```bash
swift test -c release
```

#### Run with Verbose Output
```bash
swift test --verbose
```

#### Run with Code Coverage
```bash
swift test --enable-code-coverage
```

#### Run Tests in Parallel (Faster)
```bash
swift test --parallel
```

### Method 3: Xcode Command Line

#### Run All Tests
```bash
xcodebuild test \
  -scheme IndustrialSafetySimulator \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
```

#### Run Only Unit Tests
```bash
xcodebuild test \
  -scheme IndustrialSafetySimulator \
  -only-testing:UnitTests
```

#### Run Specific Test Class
```bash
xcodebuild test \
  -scheme IndustrialSafetySimulator \
  -only-testing:UnitTests/SafetyUserTests
```

## 🎯 Test Filtering and Selection

### Filter by Test Name

```bash
# Run tests matching pattern
swift test --filter SafetyUser

# Run specific test
swift test --filter testUserInitialization

# Run multiple patterns
swift test --filter "Safety|Training"
```

### Filter by Tags

```swift
// In code, define tags:
extension Tag {
    @Tag static var unit: Self
    @Tag static var smoke: Self
    @Tag static var critical: Self
}

// Tag tests:
@Test("Critical feature", .tags(.critical, .smoke))
func testCriticalFeature() { }
```

```bash
# Run tests with specific tag (when supported)
swift test --tag smoke
```

### Skip Specific Tests

```bash
# Skip specific test suite
swift test --skip SafetyUserTests

# Skip specific test
swift test --skip testUserInitialization
```

## 🎭 Running Different Test Categories

### Unit Tests Only (✅ Can Run Now)

```bash
# All unit tests
swift test --filter UnitTests

# Specific unit test file
swift test --filter SafetyUserTests
swift test --filter SafetyScenarioTests
swift test --filter PerformanceMetricsTests
```

**Expected Duration**: 5-10 seconds for ~100 tests

### Integration Tests Only (✅ Can Run Now)

```bash
# All integration tests
swift test --filter IntegrationTests

# Specific integration suite
swift test --filter TrainingFlowIntegrationTests
```

**Expected Duration**: 10-15 seconds for ~15 tests

### Performance Tests (✅ Logic Tests Can Run Now)

```bash
# All performance tests
swift test --filter PerformanceTests

# Specific benchmarks
swift test --filter PerformanceBenchmarkTests
```

**Expected Duration**: 30-60 seconds for ~15 benchmarks

**Note**: Rendering performance tests require hardware.

### Accessibility Tests (✅ Can Run Now)

```bash
# All accessibility tests
swift test --filter AccessibilityTests

# Specific accessibility suite
swift test --filter AccessibilityComplianceTests
```

**Expected Duration**: 5-8 seconds for ~25 tests

### UI Tests (⚠️ Requires Simulator)

```bash
# Requires visionOS Simulator
xcodebuild test \
  -scheme IndustrialSafetySimulator \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -only-testing:UITests
```

**Expected Duration**: 2-5 minutes for UI tests

**Note**: Cannot run without simulator/hardware.

## 📊 Test Coverage Measurement

### Enable Coverage in Xcode

1. Edit Scheme (`⌘ + <`)
2. Select Test tab
3. Go to Options
4. Check "Gather coverage for some targets"
5. Select `IndustrialSafetySimulator` target
6. Run tests (`⌘ + U`)
7. View coverage:
   - Report Navigator (`⌘ + 9`)
   - Click latest test report
   - Select Coverage tab

### Generate Coverage via Command Line

```bash
# 1. Run tests with coverage
swift test --enable-code-coverage

# 2. Export coverage data
xcrun llvm-cov export \
  .build/debug/IndustrialSafetySimulatorPackageTests.xctest/Contents/MacOS/IndustrialSafetySimulatorPackageTests \
  -instr-profile=.build/debug/codecov/default.profdata \
  -format=lcov > coverage.lcov

# 3. Generate HTML report
xcrun llvm-cov show \
  .build/debug/IndustrialSafetySimulatorPackageTests.xctest/Contents/MacOS/IndustrialSafetySimulatorPackageTests \
  -instr-profile=.build/debug/codecov/default.profdata \
  -format=html \
  -output-dir=coverage-html

# 4. View report
open coverage-html/index.html
```

### Coverage Targets

| Component | Target | Command to Check |
|-----------|--------|------------------|
| Data Models | 90% | `swift test --filter "SafetyUser\|SafetyScenario\|TrainingSession"` |
| ViewModels | 85% | `swift test --filter "ViewModel"` |
| Services | 80% | `swift test --filter "Service"` |
| Overall | 85% | `swift test --enable-code-coverage` |

## 🤖 Running Tests in CI/CD

### GitHub Actions

Create `.github/workflows/tests.yml`:

```yaml
name: Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  unit-and-integration:
    name: Unit & Integration Tests
    runs-on: macos-14

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Select Xcode version
        run: sudo xcode-select -s /Applications/Xcode_15.2.app

      - name: Cache Swift packages
        uses: actions/cache@v3
        with:
          path: .build
          key: ${{ runner.os }}-swift-${{ hashFiles('**/Package.resolved') }}

      - name: Run Unit Tests
        run: |
          cd IndustrialSafetySimulator
          swift test --filter UnitTests --enable-code-coverage

      - name: Run Integration Tests
        run: |
          cd IndustrialSafetySimulator
          swift test --filter IntegrationTests

      - name: Run Accessibility Tests
        run: |
          cd IndustrialSafetySimulator
          swift test --filter AccessibilityTests

      - name: Run Performance Tests
        run: |
          cd IndustrialSafetySimulator
          swift test --filter PerformanceTests

      - name: Generate Coverage Report
        run: |
          xcrun llvm-cov export \
            .build/debug/IndustrialSafetySimulatorPackageTests.xctest/Contents/MacOS/IndustrialSafetySimulatorPackageTests \
            -instr-profile=.build/debug/codecov/default.profdata \
            -format=lcov > coverage.lcov

      - name: Upload Coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage.lcov
          fail_ci_if_error: true

  ui-tests:
    name: UI Tests
    runs-on: macos-14

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Select Xcode version
        run: sudo xcode-select -s /Applications/Xcode_15.2.app

      - name: Run UI Tests on Simulator
        run: |
          xcodebuild test \
            -scheme IndustrialSafetySimulator \
            -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
            -only-testing:UITests \
            -resultBundlePath TestResults

      - name: Upload Test Results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: test-results
          path: TestResults.xcresult
```

### Expected CI/CD Execution Times

| Job | Duration | Can Run Now |
|-----|----------|-------------|
| Unit Tests | 10-20s | ✅ Yes |
| Integration Tests | 15-25s | ✅ Yes |
| Accessibility Tests | 8-12s | ✅ Yes |
| Performance Tests | 45-90s | ✅ Yes (logic only) |
| UI Tests | 3-7m | ⚠️ Needs simulator |
| **Total (without UI)** | **~2 minutes** | **✅ Yes** |
| **Total (with UI)** | **~5-8 minutes** | **⚠️ Needs simulator** |

## 🔍 Test Results and Reporting

### Viewing Results in Xcode

1. **Test Navigator** (`⌘ + 6`):
   - Green checkmark: Test passed
   - Red X: Test failed
   - Gray: Test not run

2. **Report Navigator** (`⌘ + 9`):
   - Click test report
   - View detailed logs
   - See code coverage

3. **Issue Navigator** (`⌘ + 5`):
   - All test failures
   - Stack traces
   - Quick jump to failure

### Command Line Results

```bash
# Standard output shows:
Test Suite 'All tests' started at 2024-01-15 10:30:00.000
Test Suite 'SafetyUserTests' started at 2024-01-15 10:30:00.100
Test Case 'testUserInitialization' passed (0.005 seconds)
Test Case 'testCertificationValidation' passed (0.003 seconds)
...
Test Suite 'SafetyUserTests' passed at 2024-01-15 10:30:01.000
  Executed 18 tests, with 0 failures (0 unexpected) in 0.9 seconds

Test Suite 'All tests' passed at 2024-01-15 10:30:10.000
  Executed 155 tests, with 0 failures (0 unexpected) in 10.0 seconds
```

### JUnit XML Report

```bash
# Generate JUnit XML for CI systems
swift test --xunit-output test-results.xml
```

### HTML Test Reports

```bash
# Using xcparse
brew install chargepoint/xcparse/xcparse

# Convert xcresult to HTML
xcparse --output-format html \
  TestResults.xcresult \
  test-report.html

open test-report.html
```

## 🐛 Troubleshooting

### Common Issues

#### Issue: "No tests found"

**Symptoms**: `swift test` finds 0 tests

**Solutions**:
```bash
# 1. Verify test files exist
ls Tests/UnitTests/*.swift

# 2. Check test file structure
# Tests must use @Test macro or XCTest class

# 3. Rebuild
swift build --clean
swift build
swift test
```

#### Issue: Tests timeout

**Symptoms**: Tests hang or exceed time limit

**Solutions**:
```swift
// Increase timeout in code
@Test("Long operation", .timeLimit(.minutes(5)))
func testLongRunning() async { }

// Or run with extended timeout
swift test --timeout 300  // 5 minutes
```

#### Issue: "Unable to find simulator"

**Symptoms**: UI tests fail with simulator error

**Solutions**:
```bash
# 1. List available simulators
xcrun simctl list devices

# 2. Ensure visionOS simulator is installed
# Xcode → Settings → Platforms → visionOS

# 3. Specify explicit destination
xcodebuild test \
  -scheme IndustrialSafetySimulator \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro,OS=2.0'
```

#### Issue: Code coverage not generating

**Symptoms**: No coverage data after tests

**Solutions**:
```bash
# 1. Ensure flag is set
swift test --enable-code-coverage

# 2. Check build directory exists
ls .build/debug/codecov/

# 3. Verify profile data
ls .build/debug/codecov/default.profdata

# 4. Try clean build
rm -rf .build
swift test --enable-code-coverage
```

#### Issue: "Ambiguous use of test"

**Symptoms**: Build errors in test files

**Solutions**:
```swift
// Ensure proper imports
import Testing  // For @Test macro
@testable import IndustrialSafetySimulator

// Or use XCTest
import XCTest
class MyTests: XCTestCase { }
```

#### Issue: Flaky tests

**Symptoms**: Tests pass/fail intermittently

**Solutions**:
```swift
// ❌ Bad: Using sleep/delays
func testAsync() {
    performAsync()
    sleep(2)  // Flaky!
    #expect(completed)
}

// ✅ Good: Use async/await
func testAsync() async {
    await performAsync()
    #expect(completed)
}
```

### Getting Help

1. **Check test output**: Read error messages carefully
2. **Review test logs**: Report Navigator in Xcode
3. **Search documentation**: [Swift Testing Docs](https://developer.apple.com/documentation/testing)
4. **Check CI logs**: GitHub Actions → View workflow run
5. **Team support**: Post in #testing channel

## 📝 Quick Reference

### Essential Commands

```bash
# Run all tests
swift test

# Run with coverage
swift test --enable-code-coverage

# Run specific suite
swift test --filter SafetyUserTests

# Run in parallel
swift test --parallel

# Verbose output
swift test --verbose

# List all tests
swift test --list-tests

# Generate JUnit report
swift test --xunit-output results.xml
```

### Xcode Shortcuts

| Action | Shortcut |
|--------|----------|
| Run Tests | ⌘ + U |
| Test Navigator | ⌘ + 6 |
| Report Navigator | ⌘ + 9 |
| Issue Navigator | ⌘ + 5 |
| Edit Scheme | ⌘ + < |
| Stop Testing | ⌘ + . |

## 🎯 Best Practices

1. **Run tests before committing**: `swift test`
2. **Check coverage regularly**: Aim for 85%+
3. **Fix failing tests immediately**: Don't let them accumulate
4. **Keep tests fast**: Unit tests should run in seconds
5. **Use tags**: Organize tests for different scenarios
6. **Monitor CI**: Fix broken builds quickly

---

**Next Steps**:
- Read [README.md](README.md) for testing overview
- Review [TESTING_STRATEGY.md](TESTING_STRATEGY.md) for approach
- Check [VISIONOS_TESTING_GUIDE.md](VisionOSTests/VISIONOS_TESTING_GUIDE.md) for hardware tests
