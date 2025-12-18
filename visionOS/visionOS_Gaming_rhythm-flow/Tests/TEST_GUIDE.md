# Rhythm Flow - Comprehensive Test Guide

This document provides detailed instructions for running all tests in the Rhythm Flow project, including tests that require specific environments.

---

## Table of Contents

1. [Test Overview](#test-overview)
2. [Test Types](#test-types)
3. [Running Tests in Current Environment](#running-tests-in-current-environment)
4. [Running Tests in Xcode Environment](#running-tests-in-xcode-environment)
5. [Test Coverage Goals](#test-coverage-goals)
6. [CI/CD Integration](#cicd-integration)
7. [Test Results Interpretation](#test-results-interpretation)
8. [Troubleshooting](#troubleshooting)

---

## Test Overview

The Rhythm Flow test suite includes comprehensive coverage across multiple categories:

| Test Type | Location | Count | Runnable Now | Environment Needed |
|-----------|----------|-------|--------------|-------------------|
| **Unit Tests** | `Tests/Unit/` | 2 files | ❌ No | Xcode + visionOS SDK |
| **Integration Tests** | `Tests/Integration/` | 1 file | ❌ No | Xcode + visionOS SDK |
| **UI Tests** | `Tests/UI/` | 1 file | ❌ No | Xcode + visionOS SDK/Simulator |
| **Performance Tests** | `Tests/Performance/` | 1 file | ❌ No | Xcode + visionOS SDK |
| **Accessibility Tests** | `Tests/Accessibility/` | 1 file | ❌ No | Xcode + visionOS SDK |
| **Landing Page Tests** | `Tests/Landing/` | 1 file | ✅ **Yes** | Python 3 |

**Total Test Files**: 7 files covering all major aspects of the application

---

## Test Types

### 1. Unit Tests

**Location**: `Tests/Unit/`

#### ScoreManagerTests.swift
Tests the scoring system in isolation:
- ✅ Hit quality scoring (Perfect, Great, Good, Okay, Miss)
- ✅ Combo multipliers (10x, 25x, 50x, 100x, 200x)
- ✅ Streak tracking
- ✅ Accuracy calculation
- ✅ Grade determination (S, A, B, C, D, F)
- ✅ Statistics export
- ✅ Reset functionality
- ✅ Performance benchmarks

**Test Count**: 15+ test methods

#### DataModelTests.swift
Tests all data models:
- ✅ Song model (initialization, Codable)
- ✅ BeatMap model (AI generation, difficulty scaling)
- ✅ NoteEvent model (validation, timing)
- ✅ PlayerProfile model (level progression, statistics)
- ✅ GameSession model (tracking, grade calculation)
- ✅ Persistence (encode/decode)

**Test Count**: 20+ test methods

---

### 2. Integration Tests

**Location**: `Tests/Integration/`

#### GameplayIntegrationTests.swift
Tests multi-system interactions:
- ✅ Complete song playthrough
- ✅ Pause and resume functionality
- ✅ Game engine + Audio engine + Input system integration
- ✅ Score calculation across systems
- ✅ Profile updates after gameplay
- ✅ State transitions
- ✅ Data persistence after gameplay

**Test Count**: 10+ test methods

**Critical Flows Tested**:
1. Main Menu → Song Selection → Gameplay → Results → Profile Update
2. Gameplay → Pause → Settings → Resume → Complete
3. Multiple songs in succession with state cleanup

---

### 3. UI Tests

**Location**: `Tests/UI/`

#### MenuNavigationTests.swift
Tests user interface navigation:
- ✅ Main menu appearance and elements
- ✅ Song library navigation
- ✅ Song selection flow
- ✅ Settings access and changes
- ✅ Profile view navigation
- ✅ Accessibility labels and hints
- ✅ Button interactions

**Test Count**: 8+ test methods

**UI Elements Tested**:
- Navigation bars
- Buttons and interactive elements
- Lists and grids
- Text fields
- Accessibility features

---

### 4. Performance Tests

**Location**: `Tests/Performance/`

#### PerformanceTests.swift
Tests performance and optimization:

**Frame Rate Tests**:
- ✅ 90 FPS maintenance with minimal load
- ✅ 90 FPS under heavy load (Expert+)
- ✅ Audio sync performance
- ✅ Note spawning performance

**Memory Tests**:
- ✅ Memory usage during gameplay (< 2GB)
- ✅ Object pool efficiency
- ✅ Memory cleanup after songs

**CPU Tests**:
- ✅ Hit detection algorithm performance
- ✅ Combo calculation performance
- ✅ Beat map parsing performance

**Graphics Tests**:
- ✅ RealityKit rendering with many entities
- ✅ Particle effects performance

**Stress Tests**:
- ✅ Sustained 10-minute gameplay
- ✅ Rapid mode transitions
- ✅ Profile save/load performance

**Test Count**: 15+ performance benchmarks

**Performance Targets**:
- **Frame Rate**: 90 FPS average (11.1ms per frame)
- **Memory**: < 2GB peak, < 200MB growth over 10 minutes
- **CPU**: < 8ms game loop, < 1ms hit detection
- **Latency**: < 20ms input-to-action, ±2ms audio-visual sync

---

### 5. Accessibility Tests

**Location**: `Tests/Accessibility/`

#### AccessibilityTests.swift
Tests accessibility compliance:

**VoiceOver Support**:
- ✅ Accessibility labels for all interactive elements
- ✅ Gameplay state announcements
- ✅ Note descriptions

**Visual Accessibility**:
- ✅ High contrast mode (7:1 ratio, WCAG AAA)
- ✅ Color blind modes
- ✅ Text size scaling (Dynamic Type)
- ✅ Reduce motion support

**Audio Accessibility**:
- ✅ Visual cues for audio events
- ✅ Haptic feedback alternatives
- ✅ Closed captions support

**Motor Accessibility**:
- ✅ Alternative control schemes
- ✅ Adjustable timing windows
- ✅ Note speed reduction
- ✅ Auto-hit assistance

**Cognitive Accessibility**:
- ✅ Simplified UI mode
- ✅ Tutorial clarity
- ✅ Pause/resume functionality

**Spatial Accessibility**:
- ✅ Adjustable play area
- ✅ Seated play mode
- ✅ Head-only mode

**Compliance Tests**:
- ✅ WCAG 2.1 Level AA compliance
- ✅ Apple accessibility guidelines

**Test Count**: 20+ accessibility tests

---

### 6. Landing Page Tests

**Location**: `Tests/Landing/`

#### validate_html.py
Validates landing page quality:

**HTML Validation**:
- ✅ HTML5 DOCTYPE
- ✅ Meta tags (charset, viewport, description, Open Graph)
- ✅ Semantic HTML5 elements
- ✅ Link integrity
- ✅ Image alt attributes
- ✅ Accessibility features (ARIA labels, lang attribute)
- ✅ SEO optimization (title length, meta description)
- ✅ Structure (closing tags, section count)

**CSS Validation**:
- ✅ CSS custom properties (variables)
- ✅ Media queries (responsive design)
- ✅ CSS animations
- ✅ Syntax validity (balanced braces)

**JavaScript Validation**:
- ✅ Syntax validity (balanced parentheses and braces)
- ✅ Event listeners
- ✅ Function definitions
- ✅ Code documentation

**Test Count**: 30+ validation checks

---

## Running Tests in Current Environment

### ✅ Landing Page Validation (Python)

**These tests CAN be run right now without Xcode!**

#### Prerequisites
```bash
# Python 3.x (already available)
python3 --version
```

#### Run All Landing Page Tests
```bash
cd visionOS_Gaming_rhythm-flow
python3 Tests/Landing/validate_html.py
```

#### Expected Output
```
============================================================
🎵 RHYTHM FLOW - LANDING PAGE VALIDATION TESTS
============================================================

🔍 Validating HTML: website/index.html
✅ PASSED (17):
  ✓ HTML5 DOCTYPE present
  ✓ UTF-8 charset present
  ✓ Viewport meta tag present
  ...

⚠️  WARNINGS (4):
  ⚠ No <header> element found
  ⚠ No <article> element found
  ...

Success Rate: 81.0% (17/21)

🎨 Validating CSS: website/css/styles.css
✅ PASSED (4):
  ✓ CSS variables defined (119 variables)
  ✓ Responsive design (2 media queries)
  ...

⚡ Validating JavaScript: website/js/script.js
✅ PASSED (5):
  ✓ Balanced parentheses
  ✓ Event listeners attached (15 listeners)
  ...

============================================================
📊 FINAL SUMMARY
============================================================
  HTML            ✅ PASS
  CSS             ✅ PASS
  JavaScript      ✅ PASS
============================================================
```

#### Latest Test Results (2024)
```
HTML:       17 passes, 4 warnings (81% success rate)
CSS:        4 passes, 0 warnings (100% success rate)
JavaScript: 5 passes, 0 warnings (100% success rate)
```

---

## Running Tests in Xcode Environment

### ❌ Swift Tests (Requires Xcode + visionOS SDK)

**These tests CANNOT be run in the current environment. They require:**
- macOS 14.0 (Sonoma) or later
- Xcode 16.0 or later
- visionOS SDK 2.0 or later
- Apple Vision Pro Simulator or physical device

#### Setup Instructions

1. **Open Project in Xcode**
   ```bash
   cd visionOS_Gaming_rhythm-flow
   open RhythmFlow/RhythmFlow.xcodeproj
   ```

2. **Add Test Targets**
   - In Xcode, go to **File → New → Target**
   - Select **visionOS → Test → Unit Testing Bundle**
   - Name it `RhythmFlowTests`
   - Repeat for UI Testing Bundle: `RhythmFlowUITests`

3. **Add Test Files to Targets**
   - Drag test files from `Tests/` directory into Xcode project
   - Ensure they're added to appropriate test targets:
     - `Unit/*.swift` → RhythmFlowTests
     - `Integration/*.swift` → RhythmFlowTests
     - `Performance/*.swift` → RhythmFlowTests
     - `Accessibility/*.swift` → RhythmFlowTests
     - `UI/*.swift` → RhythmFlowUITests

4. **Configure Test Scheme**
   - Select **Product → Scheme → Edit Scheme**
   - Go to **Test** section
   - Enable all test classes

---

### Running Unit Tests

#### Command Line (All Tests)
```bash
xcodebuild test \
  -project RhythmFlow/RhythmFlow.xcodeproj \
  -scheme RhythmFlow \
  -sdk xros \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
```

#### Command Line (Specific Test)
```bash
xcodebuild test \
  -project RhythmFlow/RhythmFlow.xcodeproj \
  -scheme RhythmFlow \
  -only-testing:RhythmFlowTests/ScoreManagerTests/testPerfectHitScoring
```

#### Xcode GUI
1. Open project in Xcode
2. Select **Product → Test** (⌘U)
3. Or click the diamond icon next to any test method

#### Run Specific Test Suite
```bash
# Unit tests only
xcodebuild test -only-testing:RhythmFlowTests/ScoreManagerTests

# Integration tests only
xcodebuild test -only-testing:RhythmFlowTests/GameplayIntegrationTests

# Performance tests only
xcodebuild test -only-testing:RhythmFlowTests/PerformanceTests

# Accessibility tests only
xcodebuild test -only-testing:RhythmFlowTests/AccessibilityTests
```

---

### Running UI Tests

#### Command Line
```bash
xcodebuild test \
  -project RhythmFlow/RhythmFlow.xcodeproj \
  -scheme RhythmFlow \
  -sdk xros \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -only-testing:RhythmFlowUITests
```

#### Xcode GUI
1. Open **Test Navigator** (⌘6)
2. Right-click on **RhythmFlowUITests**
3. Select **Run "RhythmFlowUITests"**

---

### Running Performance Tests

Performance tests use `measure { }` blocks to benchmark code.

#### Command Line
```bash
xcodebuild test \
  -only-testing:RhythmFlowTests/PerformanceTests \
  -resultBundlePath TestResults.xcresult
```

#### View Performance Results
```bash
open TestResults.xcresult
```

In Xcode:
1. Run performance tests
2. Go to **Report Navigator** (⌘9)
3. Click on test run
4. View performance metrics and baselines

#### Setting Performance Baselines
1. Run performance test
2. Click **Set Baseline** in test results
3. Future runs will compare against baseline
4. Fail test if performance degrades > 10%

---

### Running Tests on Physical Device

#### Prerequisites
- Apple Vision Pro device
- USB-C cable connection
- Device registered in Apple Developer account
- Development certificate installed

#### Steps
1. Connect Vision Pro via USB-C
2. In Xcode, select your device from device menu
3. Run tests: **Product → Test** (⌘U)
4. Authorize on device when prompted

**Note**: Some tests (especially performance and hand tracking) require physical hardware for accurate results.

---

## Test Coverage Goals

### Overall Coverage Targets

| Category | Target | Critical Paths |
|----------|--------|----------------|
| **Unit Tests** | 80% | 100% |
| **Integration** | 70% | 100% |
| **UI Tests** | 60% | 100% |
| **Performance** | 90 FPS | Sustained |

### Measuring Code Coverage

#### Enable Code Coverage
1. In Xcode: **Product → Scheme → Edit Scheme**
2. Go to **Test** tab
3. Enable **Code Coverage**
4. Check **Gather coverage for: RhythmFlow**

#### View Coverage Report
1. Run tests with coverage enabled
2. Go to **Report Navigator** (⌘9)
3. Select test run
4. Click **Coverage** tab

#### Command Line Coverage
```bash
xcodebuild test \
  -enableCodeCoverage YES \
  -resultBundlePath TestResults.xcresult

xcrun xccov view --report TestResults.xcresult
```

### Critical Paths (Must be 100% Covered)

- ✅ Score calculation (ScoreManager)
- ✅ Hit detection (GameEngine)
- ✅ Combo multiplier logic
- ✅ Grade determination
- ✅ Profile data persistence
- ✅ Audio synchronization
- ✅ Input processing

---

## CI/CD Integration

### GitHub Actions Workflow

Create `.github/workflows/test.yml`:

```yaml
name: Test Suite

on:
  push:
    branches: [ main, develop, claude/* ]
  pull_request:
    branches: [ main ]

jobs:
  test-landing-page:
    name: Landing Page Tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.x'
      - name: Run Landing Page Tests
        run: python3 Tests/Landing/validate_html.py

  test-swift:
    name: Swift Tests
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v3
      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode_16.0.app
      - name: Run Unit Tests
        run: |
          xcodebuild test \
            -project RhythmFlow/RhythmFlow.xcodeproj \
            -scheme RhythmFlow \
            -sdk xros \
            -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
      - name: Upload Test Results
        uses: actions/upload-artifact@v3
        with:
          name: test-results
          path: TestResults.xcresult
```

### Automated Testing Schedule

- **On every push**: Landing page tests (fast, always available)
- **On every PR**: Full Swift test suite
- **Nightly**: Performance tests and stress tests
- **Weekly**: Full accessibility audit

---

## Test Results Interpretation

### Unit Test Results

**✅ Success Criteria**:
- All test methods pass
- No warnings or errors
- Execution time < 5 seconds

**Example Output**:
```
Test Suite 'ScoreManagerTests' passed at 2024-XX-XX
Executed 15 tests, with 0 failures (0 unexpected)
```

### Performance Test Results

**✅ Success Criteria**:
- Average frame time < 11.1ms (90 FPS)
- 99th percentile < 13ms
- Memory growth < 200MB over 10 minutes
- No memory leaks

**Example Output**:
```
testFrameRateWithMaximumNotes: average 10.8ms (baseline: 11.1ms) ✅
testMemoryUsageDuringGameplay: 156MB growth ✅
```

### Accessibility Test Results

**✅ Success Criteria**:
- All accessibility features present
- WCAG 2.1 Level AA compliance
- VoiceOver support complete
- Contrast ratios meet standards (7:1)

**Example Output**:
```
testWCAGCompliance: PASSED ✅
testAccessibilityLabelsPresent: PASSED ✅
testHighContrastMode: Contrast ratio 8.2:1 ✅
```

---

## Troubleshooting

### Common Issues

#### Issue: "Could not find target 'RhythmFlow' in project"
**Solution**:
```bash
# Ensure you're in the correct directory
cd RhythmFlow
open RhythmFlow.xcodeproj  # NOT .xcworkspace
```

#### Issue: "No such module 'RhythmFlow'"
**Solution**:
1. Ensure test target has proper dependencies
2. Go to test target → Build Phases → Link Binary With Libraries
3. Add RhythmFlow.framework

#### Issue: "Hand tracking not available in simulator"
**Solution**:
- Hand tracking tests require physical device
- Use mock InputManager for simulator testing
- Or skip hand tracking tests in simulator:
```swift
#if targetEnvironment(simulator)
    throw XCTSkip("Hand tracking requires physical device")
#endif
```

#### Issue: Performance tests failing intermittently
**Solution**:
- Run on physical device (more consistent than simulator)
- Close other apps to reduce system load
- Increase baseline tolerance to 15-20%
- Run multiple times and take average

#### Issue: UI tests timing out
**Solution**:
- Increase timeout values:
```swift
let app = XCUIApplication()
app.launch()
_ = app.buttons["Play"].waitForExistence(timeout: 10)  // Increase from 5 to 10
```

### Getting Help

- **Test Documentation**: This file
- **Test Examples**: See existing test files for patterns
- **Xcode Help**: **Help → Xcode Help** → Search "Unit Testing"
- **Apple Docs**: [XCTest Framework Reference](https://developer.apple.com/documentation/xctest)

---

## Test Maintenance

### Adding New Tests

1. **Create Test File**
   ```swift
   import XCTest
   @testable import RhythmFlow

   @MainActor
   final class MyNewTests: XCTestCase {
       func testNewFeature() {
           // Test code
       }
   }
   ```

2. **Add to Xcode Project**
   - Drag file into appropriate test target
   - Ensure target membership is set

3. **Run New Tests**
   ```bash
   xcodebuild test -only-testing:RhythmFlowTests/MyNewTests
   ```

### Updating Tests After Code Changes

When you modify game code:
1. Run affected tests
2. Update test assertions if behavior changed intentionally
3. Add new tests for new features
4. Remove tests for removed features

### Test Review Checklist

Before committing tests:
- [ ] All tests pass locally
- [ ] Tests follow naming conventions (`test[Feature][Scenario]`)
- [ ] Tests are independent (can run in any order)
- [ ] Tests clean up after themselves
- [ ] Performance tests have reasonable baselines
- [ ] Accessibility tests cover new UI elements
- [ ] Documentation updated

---

## Summary

### Tests Ready to Run NOW ✅
- **Landing Page Tests** (Python): `python3 Tests/Landing/validate_html.py`

### Tests Requiring Xcode Environment ❌
- **Unit Tests** (5 files, 50+ methods)
- **Integration Tests** (1 file, 10+ methods)
- **UI Tests** (1 file, 8+ methods)
- **Performance Tests** (1 file, 15+ benchmarks)
- **Accessibility Tests** (1 file, 20+ checks)

### Next Steps

1. **Now**: Run landing page tests to verify website quality
2. **When Xcode is available**:
   - Set up test targets
   - Run full Swift test suite
   - Configure CI/CD pipeline
3. **Before release**:
   - Achieve 80% code coverage
   - Pass all performance benchmarks
   - Complete accessibility audit

---

**Last Updated**: 2024
**Test Suite Version**: 1.0
**Maintained by**: Rhythm Flow Development Team
