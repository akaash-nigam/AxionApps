# Reality Realms RPG - Test Suite

## 📋 Overview

This directory contains comprehensive tests for Reality Realms RPG, ensuring the game is production-ready for Apple Vision Pro. The test suite is organized into multiple categories to verify different aspects of the application.

## 🗂️ Test Structure

```
Tests/
├── Unit/                           # Unit tests (can run without Vision Pro)
│   ├── GameStateManagerTests.swift
│   ├── EntityComponentTests.swift
│   └── EventBusTests.swift
├── Integration/                    # Integration tests (can run without Vision Pro)
│   └── IntegrationTests.swift
├── Performance/                    # Performance tests (can run without Vision Pro)
│   └── PerformanceTests.swift
├── UI/                            # UI tests (requires visionOS Simulator or device)
│   └── UITests.swift
├── Accessibility/                 # Accessibility test documentation
│   └── AccessibilityTests.md
├── VisionOSSpecific/              # Tests requiring Vision Pro hardware
│   └── SpatialTests.md
└── README.md                      # This file
```

## ✅ Test Categories

### 1. Unit Tests (Can Run in Current Environment)

**Location**: `Tests/Unit/`

These tests verify individual components and systems in isolation.

#### GameStateManagerTests.swift
Tests the game state management system:
- ✅ State initialization
- ✅ State transitions (initialization → room scanning → tutorial → gameplay)
- ✅ Pause/resume functionality
- ✅ Combat state management
- ✅ Loading states
- ✅ Error handling

**Test Count**: 15 tests
**Coverage Target**: 95%

#### EntityComponentTests.swift
Tests the Entity-Component-System architecture:
- ✅ Entity creation and lifecycle
- ✅ Component attachment/detachment
- ✅ Health component (damage, healing, death)
- ✅ Combat component (attack, defense, critical hits)
- ✅ Inventory component (add, remove, equip items)
- ✅ AI component state transitions
- ✅ Player entity with character classes
- ✅ Enemy entity behavior

**Test Count**: 22 tests
**Coverage Target**: 95%

#### EventBusTests.swift
Tests the event system:
- ✅ Event subscription
- ✅ Event publishing
- ✅ Multiple subscribers
- ✅ Event filtering
- ✅ Unsubscription
- ✅ Thread safety

**Test Count**: 12 tests
**Coverage Target**: 100%

### 2. Integration Tests (Can Run in Current Environment)

**Location**: `Tests/Integration/IntegrationTests.swift`

These tests verify that multiple systems work together correctly:
- ✅ Complete game startup flow
- ✅ Combat lifecycle (start → damage → death → loot)
- ✅ Event chain propagation
- ✅ State manager + entity integration
- ✅ Player progression flow
- ✅ Inventory and equipment system

**Test Count**: 10 tests
**Coverage Target**: 85%

### 3. Performance Tests (Can Run in Current Environment)

**Location**: `Tests/Performance/PerformanceTests.swift`

These tests verify performance targets are met:
- ✅ 90 FPS target frame time (11.1ms)
- ✅ Entity creation performance (1000 entities in < 100ms)
- ✅ Event bus throughput (10,000 events/second)
- ✅ State transition performance (< 1ms)
- ✅ Combat calculation performance
- ✅ Memory leak detection
- ✅ Memory footprint (< 4GB)
- ✅ Startup time (< 5 seconds)

**Test Count**: 12 tests
**Performance Budget**:
- Frame time: 11.1ms maximum (90 FPS)
- Memory: 4GB maximum
- Startup: 5 seconds maximum
- State transitions: 1ms maximum

### 4. UI Tests (Requires visionOS Simulator or Device)

**Location**: `Tests/UI/UITests.swift`

These tests verify user interface functionality:
- ⚠️ Requires visionOS Simulator or Vision Pro device
- Main menu navigation
- Settings screen
- HUD visibility
- Inventory UI
- Quest tracking UI

**Test Count**: 15 tests

### 5. Accessibility Tests (Manual Testing Required)

**Location**: `Tests/Accessibility/AccessibilityTests.md`

Comprehensive accessibility testing documentation:
- **Motor Accessibility**: One-handed mode, seated play, gesture sensitivity, auto-aim
- **Visual Accessibility**: Colorblind modes, high contrast, text scaling, motion reduction
- **Cognitive Accessibility**: Difficulty options, quest assistance, simplified UI, auto-combat
- **Hearing Accessibility**: Subtitles, visual indicators, mono audio
- **WCAG 2.1 Compliance**: Level A, AA, and AAA compliance checklist

**Test Count**: 30+ manual tests
**Compliance**: WCAG 2.1 Level AAA

### 6. visionOS-Specific Tests (Requires Vision Pro Hardware)

**Location**: `Tests/VisionOSSpecific/SpatialTests.md`

Tests that require actual Vision Pro hardware:
- ⚠️ Cannot run in current environment
- 🔴 Requires Apple Vision Pro device

**Test Categories**:
1. **Room Mapping & Spatial Understanding**
   - Room scanning accuracy
   - Floor plane detection
   - Wall detection
   - Furniture classification
   - Play area validation

2. **Hand Tracking**
   - Gesture recognition (90%+ accuracy)
   - Combat gestures (sword swing, spell cast)
   - Menu interactions
   - Two-handed gestures
   - Accessibility gestures

3. **Eye Tracking**
   - Gaze target selection
   - UI focus
   - Combat targeting
   - Menu navigation
   - Calibration

4. **Spatial Anchors**
   - Anchor persistence
   - Multi-session persistence
   - World locking accuracy (±2cm)
   - Anchor updates

5. **Performance on Device**
   - 90 FPS in room-scale gameplay
   - Thermal management
   - Battery life
   - Memory usage on device

**Test Count**: 25+ hardware tests

---

## 🚀 Running Tests

### Prerequisites

#### For Unit, Integration, and Performance Tests:
- macOS Sonoma or later
- Xcode 16.0+
- Swift 6.0+

#### For UI Tests:
- visionOS Simulator (included with Xcode)
- OR Apple Vision Pro device

#### For visionOS-Specific Tests:
- 🔴 **Apple Vision Pro device required**
- visionOS 2.0 or later
- Sufficient play space (2m × 2m minimum)

### Running Tests via Xcode

#### 1. Run All Tests (that can run without device)

```bash
# Open project in Xcode
open RealityRealms.xcodeproj

# In Xcode, press ⌘U to run all tests
# Or use the Test Navigator (⌘6) to run specific test suites
```

#### 2. Run Unit Tests Only

```bash
xcodebuild test \
  -scheme RealityRealms \
  -destination 'platform=macOS' \
  -only-testing:RealityRealmsTests/GameStateManagerTests

xcodebuild test \
  -scheme RealityRealms \
  -destination 'platform=macOS' \
  -only-testing:RealityRealmsTests/EntityComponentTests

xcodebuild test \
  -scheme RealityRealms \
  -destination 'platform=macOS' \
  -only-testing:RealityRealmsTests/EventBusTests
```

#### 3. Run Integration Tests

```bash
xcodebuild test \
  -scheme RealityRealms \
  -destination 'platform=macOS' \
  -only-testing:RealityRealmsTests/IntegrationTests
```

#### 4. Run Performance Tests

```bash
xcodebuild test \
  -scheme RealityRealms \
  -destination 'platform=macOS' \
  -only-testing:RealityRealmsTests/PerformanceTests
```

#### 5. Run UI Tests (Requires Simulator or Device)

```bash
# Using visionOS Simulator
xcodebuild test \
  -scheme RealityRealms \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -only-testing:RealityRealmsUITests

# Using actual Vision Pro device
xcodebuild test \
  -scheme RealityRealms \
  -destination 'platform=visionOS,name=Your Vision Pro' \
  -only-testing:RealityRealmsUITests
```

### Running Tests via Command Line

```bash
# Navigate to project directory
cd /path/to/RealityRealms

# Run all tests that can run without Vision Pro
swift test

# Run with verbose output
swift test --verbose

# Run specific test suite
swift test --filter GameStateManagerTests

# Run with code coverage
swift test --enable-code-coverage
```

### Generating Code Coverage Report

```bash
# Run tests with coverage
xcodebuild test \
  -scheme RealityRealms \
  -destination 'platform=macOS' \
  -enableCodeCoverage YES

# Generate coverage report
xcrun xccov view --report \
  ~/Library/Developer/Xcode/DerivedData/RealityRealms-*/Logs/Test/*.xcresult
```

---

## 📊 Test Execution Matrix

| Test Suite | Can Run Locally | Requires Simulator | Requires Vision Pro | Test Count | Status |
|------------|-----------------|-------------------|---------------------|------------|--------|
| **Unit Tests** | ✅ Yes | ❌ No | ❌ No | 49 | ✅ Ready |
| **Integration Tests** | ✅ Yes | ❌ No | ❌ No | 10 | ✅ Ready |
| **Performance Tests** | ✅ Yes | ❌ No | ❌ No | 12 | ✅ Ready |
| **UI Tests** | ❌ No | ✅ Yes | ⚠️ Recommended | 15 | ⚠️ Requires Simulator |
| **Accessibility Tests** | ❌ No | ⚠️ Partial | ✅ Yes | 30+ | 📋 Manual Testing |
| **Spatial Tests** | ❌ No | ❌ No | ✅ Yes | 25+ | 🔴 Requires Device |

**Legend**:
- ✅ Can execute in this environment
- ❌ Cannot execute in this environment
- ⚠️ Partial support or recommended
- 📋 Manual testing required
- 🔴 Hardware required

---

## 🎯 Success Criteria

### Unit Tests
- ✅ All tests must pass
- ✅ Code coverage ≥ 95% for tested components
- ✅ No memory leaks
- ✅ No force unwraps that could crash
- ✅ Thread-safe operations verified

### Integration Tests
- ✅ All critical user flows work end-to-end
- ✅ Events propagate correctly between systems
- ✅ State transitions are valid
- ✅ No race conditions
- ✅ Code coverage ≥ 85%

### Performance Tests
- ✅ Frame time ≤ 11.1ms (90 FPS)
- ✅ Entity creation: 1000 entities in < 100ms
- ✅ Event throughput: ≥ 10,000 events/second
- ✅ Memory usage < 4GB
- ✅ Startup time < 5 seconds
- ✅ No memory leaks detected
- ✅ State transitions < 1ms

### UI Tests
- ✅ All screens accessible
- ✅ Navigation works correctly
- ✅ HUD elements visible
- ✅ Settings persist
- ✅ No UI crashes

### Accessibility Tests
- ✅ WCAG 2.1 Level AAA compliance
- ✅ All colorblind modes functional
- ✅ Text scaling up to 200%
- ✅ Contrast ratio ≥ 7:1 (high contrast mode)
- ✅ One-handed mode fully functional
- ✅ Seated play mode works
- ✅ Subtitles for all audio
- ✅ Visual indicators for all sounds

### Spatial Tests (Vision Pro)
- ✅ Room scanning accuracy ≥ 95%
- ✅ Hand gesture recognition ≥ 90%
- ✅ Eye tracking accuracy ≥ 95%
- ✅ Spatial anchor accuracy ±2cm
- ✅ 90 FPS maintained in room-scale gameplay
- ✅ Furniture detection ≥ 80% accuracy
- ✅ Multi-session anchor persistence

---

## 🐛 Continuous Integration

### Automated Testing Pipeline

```yaml
# Example CI configuration (.github/workflows/tests.yml)
name: Tests

on: [push, pull_request]

jobs:
  unit-tests:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4
      - name: Run Unit Tests
        run: |
          xcodebuild test \
            -scheme RealityRealms \
            -destination 'platform=macOS' \
            -only-testing:RealityRealmsTests/GameStateManagerTests \
            -only-testing:RealityRealmsTests/EntityComponentTests \
            -only-testing:RealityRealmsTests/EventBusTests

  integration-tests:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4
      - name: Run Integration Tests
        run: |
          xcodebuild test \
            -scheme RealityRealms \
            -destination 'platform=macOS' \
            -only-testing:RealityRealmsTests/IntegrationTests

  performance-tests:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4
      - name: Run Performance Tests
        run: |
          xcodebuild test \
            -scheme RealityRealms \
            -destination 'platform=macOS' \
            -only-testing:RealityRealmsTests/PerformanceTests
```

---

## 📝 Test Reporting

### Generating Test Reports

```bash
# Run tests with result bundle
xcodebuild test \
  -scheme RealityRealms \
  -destination 'platform=macOS' \
  -resultBundlePath TestResults.xcresult

# View results
open TestResults.xcresult

# Export to JSON
xcrun xcresulttool get --format json --path TestResults.xcresult
```

### Coverage Reports

```bash
# Generate coverage report
xcrun xccov view --report --json TestResults.xcresult > coverage.json

# View coverage in terminal
xcrun xccov view --report TestResults.xcresult
```

---

## 🔍 Debugging Failed Tests

### Common Issues and Solutions

#### Issue: "No such module 'RealityKit'"
**Solution**: Ensure you're building for visionOS target, not macOS:
```bash
xcodebuild -scheme RealityRealms -destination 'platform=visionOS Simulator'
```

#### Issue: "Hand tracking not available"
**Solution**: Hand tracking requires actual Vision Pro hardware or specific simulator settings.

#### Issue: Performance tests failing
**Solution**:
1. Close other applications
2. Run on release build configuration
3. Check system resources
4. Disable debug overlays

#### Issue: Spatial tests cannot run
**Solution**: These tests require Vision Pro hardware. See `VisionOSSpecific/SpatialTests.md` for manual testing procedures.

---

## 📅 Testing Schedule

### Pre-Commit
- ✅ Run unit tests
- ✅ Run integration tests

### Daily (CI/CD)
- ✅ Run all unit tests
- ✅ Run all integration tests
- ✅ Run performance tests
- ✅ Generate coverage report

### Weekly
- ✅ Run UI tests on simulator
- ✅ Review accessibility compliance
- ✅ Performance profiling

### Before Each Release
- ✅ Run all tests (unit, integration, performance, UI)
- ✅ Manual accessibility testing
- ✅ Spatial tests on Vision Pro hardware
- ✅ User acceptance testing
- ✅ Performance validation on device
- ✅ Memory leak detection
- ✅ Thermal testing

---

## 🎓 Writing New Tests

### Unit Test Template

```swift
import XCTest
@testable import RealityRealms

final class MyComponentTests: XCTestCase {
    var sut: MyComponent!

    override func setUp() {
        super.setUp()
        sut = MyComponent()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testSomething() {
        // Given
        let expected = "expected value"

        // When
        let result = sut.doSomething()

        // Then
        XCTAssertEqual(result, expected)
    }
}
```

### Performance Test Template

```swift
func testPerformance() {
    measure {
        // Code to measure
        for _ in 0..<1000 {
            _ = expensiveOperation()
        }
    }
}

func testPerformanceWithMetrics() {
    let options = XCTMeasureOptions()
    options.iterationCount = 10

    measure(metrics: [XCTClockMetric(), XCTMemoryMetric()], options: options) {
        // Code to measure
    }
}
```

---

## 📚 Additional Resources

- [XCTest Documentation](https://developer.apple.com/documentation/xctest)
- [visionOS Testing Guide](https://developer.apple.com/documentation/visionos/testing-your-app)
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [Swift Testing Best Practices](https://developer.apple.com/swift/blog/)

---

## ✅ Test Execution Checklist

Before considering the app production-ready, ensure:

- [ ] All unit tests pass (49 tests)
- [ ] All integration tests pass (10 tests)
- [ ] All performance tests pass (12 tests)
- [ ] Code coverage ≥ 95% for core systems
- [ ] UI tests pass on visionOS Simulator
- [ ] Manual accessibility testing completed
- [ ] Spatial tests completed on Vision Pro device
- [ ] Performance validated on actual hardware
- [ ] No memory leaks detected
- [ ] Thermal performance acceptable
- [ ] Battery life meets targets (2+ hours)
- [ ] User acceptance testing completed
- [ ] Regression testing passed
- [ ] Security testing completed

---

## 📞 Support

For test-related issues:
1. Check test logs in `DerivedData/Logs/Test/`
2. Review test documentation in respective directories
3. Verify Xcode and visionOS SDK versions
4. Check hardware requirements for device-specific tests

---

**Last Updated**: 2025-11-19
**Test Suite Version**: 1.0.0
**Minimum Requirements**: Xcode 16.0+, visionOS 2.0+, Swift 6.0+
