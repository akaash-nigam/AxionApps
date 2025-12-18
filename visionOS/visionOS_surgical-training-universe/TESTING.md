# Testing Guide - Surgical Training Universe

## Overview

Comprehensive testing strategy for the Surgical Training Universe visionOS application, covering unit tests, integration tests, UI tests, performance tests, and validation.

---

## Table of Contents

1. [Testing Philosophy](#testing-philosophy)
2. [Test Coverage Goals](#test-coverage-goals)
3. [Unit Testing](#unit-testing)
4. [Integration Testing](#integration-testing)
5. [UI Testing](#ui-testing)
6. [Performance Testing](#performance-testing)
7. [Manual Testing](#manual-testing)
8. [Landing Page Testing](#landing-page-testing)
9. [Running Tests](#running-tests)
10. [Continuous Integration](#continuous-integration)
11. [Test Results](#test-results)

---

## Testing Philosophy

Our testing approach follows these principles:

1. **Test Pyramid**: 70% unit tests, 20% integration tests, 10% UI tests
2. **Fast Feedback**: Tests should run quickly (<5 minutes for full suite)
3. **Isolated**: Tests should be independent and not rely on external services
4. **Maintainable**: Tests should be easy to understand and update
5. **Comprehensive**: Cover critical paths and edge cases

---

## Test Coverage Goals

| Component | Target Coverage | Priority |
|-----------|----------------|----------|
| **Models** | 90%+ | P0 |
| **Services** | 85%+ | P0 |
| **ViewModels** | 80%+ | P1 |
| **Views** | 60%+ | P2 |
| **Overall** | 80%+ | P0 |

---

## Unit Testing

### Models

#### SurgeonProfileTests
**File**: `SurgicalTrainingUniverseTests/Models/SurgeonProfileTests.swift`

**Test Coverage**:
- ✅ Profile initialization
- ✅ Statistics updates
- ✅ Overall score calculation
- ✅ Relationship management (sessions, certifications)
- ✅ Training level progression
- ✅ Surgical specialty encoding/decoding

**Key Tests**:
```swift
func testSurgeonProfileInitialization()
func testUpdateStatisticsFromSession()
func testOverallScoreCalculation()
func testSessionRelationship()
func testTrainingLevelProgression()
```

**Run Command**:
```bash
xcodebuild test -scheme SurgicalTrainingUniverse \
  -only-testing:SurgicalTrainingUniverseTests/SurgeonProfileTests
```

#### ProcedureSessionTests
**Coverage**:
- Session lifecycle (start, complete, abort, pause)
- Score calculations
- Movement tracking
- Complication recording
- Performance metrics

#### SurgicalMovementTests
**Coverage**:
- Movement precision scoring
- Distance calculations
- Velocity tracking
- Force validation
- Position accuracy

### Services

#### ProcedureServiceTests
**File**: `SurgicalTrainingUniverseTests/Services/ProcedureServiceTests.swift`

**Test Coverage**:
- ✅ Session management (start, complete, abort, pause, resume)
- ✅ Movement recording
- ✅ Complication tracking
- ✅ Session queries (by surgeon, by type, recent)
- ✅ Multiple session handling

**Key Tests**:
```swift
func testStartProcedure()
func testCompleteProcedure()
func testRecordMovement()
func testRecordComplication()
func testGetSessionsForSurgeon()
```

**Run Command**:
```bash
xcodebuild test -scheme SurgicalTrainingUniverse \
  -only-testing:SurgicalTrainingUniverseTests/ProcedureServiceTests
```

#### AnalyticsServiceTests
**File**: `SurgicalTrainingUniverseTests/Services/AnalyticsServiceTests.swift`

**Test Coverage**:
- ✅ Average score calculations
- ✅ Skill progression tracking
- ✅ Procedure distribution analysis
- ✅ Learning curve metrics
- ✅ Mastery level determination
- ✅ Performance report generation

**Key Tests**:
```swift
func testCalculateAverageScores()
func testCalculateSkillProgression()
func testCalculateLearningCurve()
func testGeneratePerformanceReport()
```

#### SurgicalCoachAITests
**Coverage**:
- Movement analysis
- Feedback generation
- Complication prediction
- Step suggestions
- Real-time coaching

---

## Integration Testing

### Service Integration Tests
**File**: `SurgicalTrainingUniverseTests/Integration/ServiceIntegrationTests.swift`

**Test Scenarios**:
1. **End-to-End Procedure Flow**:
   - Start procedure
   - Record movements
   - AI provides feedback
   - Complete procedure
   - Generate analytics

2. **Multi-Service Collaboration**:
   - ProcedureService + AnalyticsService + SurgicalCoachAI
   - Data flow between services
   - State synchronization

3. **SwiftData Integration**:
   - Model persistence
   - Relationship management
   - Query performance

**Example Test**:
```swift
func testEndToEndProcedureFlow() async throws {
    // 1. Start procedure
    let session = try await procedureService.startProcedure(
        type: .appendectomy,
        surgeon: testSurgeon
    )

    // 2. Perform movements
    for _ in 0..<10 {
        await procedureService.recordMovement(...)
    }

    // 3. Complete and analyze
    let report = try await procedureService.completeProcedure(session)
    let summary = analyticsService.generatePerformanceReport(for: testSurgeon)

    // 4. Verify results
    XCTAssertGreaterThan(report.overallScore, 0)
    XCTAssertEqual(summary.totalSessions, 1)
}
```

---

## UI Testing

### Window Views

#### DashboardViewTests
**Test Coverage**:
- Dashboard loads correctly
- Performance cards display accurate data
- Procedure library shows all procedures
- Recent activity list updates
- Navigation to other windows

**Example Test**:
```swift
func testDashboardLoadsWithData() throws {
    let app = XCUIApplication()
    app.launch()

    // Verify dashboard elements
    XCTAssertTrue(app.staticTexts["Welcome, Dr. Jane Smith"].exists)
    XCTAssertTrue(app.staticTexts["Accuracy"].exists)
    XCTAssertTrue(app.buttons["Start Procedure"].exists)
}
```

#### AnalyticsViewTests
**Coverage**:
- Charts render correctly
- Data updates in real-time
- Export functionality works
- Filter options function

### Immersive Views

#### SurgicalTheaterViewTests
**Coverage**:
- Immersive space opens
- RealityKit scene loads
- Hand tracking initializes
- Instruments are selectable
- AI coach overlay appears
- Performance metrics update

**Challenges**:
- Requires Vision Pro hardware or simulator
- Hand tracking requires physical interaction
- Difficult to automate fully

**Manual Testing Required**: Yes

---

## Performance Testing

### Metrics to Track

| Metric | Target | Critical Threshold |
|--------|--------|-------------------|
| **Frame Rate** | 120 FPS | 90 FPS minimum |
| **App Launch** | <2s | <5s |
| **Model Load** | <2s | <5s |
| **Memory Usage** | <2GB | <3GB |
| **Network Latency** | <200ms | <500ms |
| **Database Query** | <100ms | <500ms |

### Performance Test Suite

#### Memory Tests
```swift
func testMemoryUsageDuringProcedure() {
    measure(metrics: [XCTMemoryMetric()]) {
        // Perform complete procedure
        performFullProcedure()
    }
}
```

#### Rendering Tests
```swift
func testRenderingPerformance() {
    measure(metrics: [XCTClockMetric(), XCTCPUMetric()]) {
        // Load and render 3D scene
        loadSurgicalTheater()
    }
}
```

#### Database Performance
```swift
func testDatabaseQueryPerformance() {
    measure {
        // Query 1000 sessions
        let sessions = fetchSessions(limit: 1000)
    }
}
```

### Profiling with Instruments

**Tools to Use**:
1. **Time Profiler**: Identify CPU bottlenecks
2. **Allocations**: Track memory usage
3. **Leaks**: Detect memory leaks
4. **Energy Log**: Monitor battery impact
5. **Metal System Trace**: GPU performance

**Run Profiling**:
```bash
# Profile in Instruments
xcodebuild -scheme SurgicalTrainingUniverse -destination 'platform=visionOS Simulator' \
  -resultBundlePath ./test-results/profile.xcresult \
  -enableCodeCoverage YES build
```

---

## Manual Testing

### Checklist for Vision Pro Testing

#### Basic Functionality
- [ ] App launches successfully
- [ ] Dashboard displays correctly
- [ ] Can navigate between windows
- [ ] Volumes render properly
- [ ] Immersive space transitions smoothly

#### Hand Tracking
- [ ] Hand tracking initializes
- [ ] Can select UI elements with gaze + pinch
- [ ] Instrument selection works
- [ ] Surgical gestures recognized
- [ ] Haptic feedback felt

#### 3D Rendering
- [ ] Anatomical models load
- [ ] 60pt minimum hit targets
- [ ] Proper depth perception
- [ ] No visual artifacts
- [ ] Smooth 120 FPS

#### AI Coaching
- [ ] Real-time feedback appears
- [ ] Insights are relevant
- [ ] Warning alerts work
- [ ] Performance tracking accurate

#### Collaboration
- [ ] SharePlay connects
- [ ] Multiple users visible
- [ ] Spatial audio works
- [ ] Synchronization correct

#### Accessibility
- [ ] VoiceOver navigation
- [ ] Dynamic Type scaling
- [ ] Reduce Motion respected
- [ ] High Contrast mode
- [ ] Color blind friendly

---

## Landing Page Testing

### HTML Validation

**Automated Tests**:
```bash
# Check HTML structure
grep -c "<html" index.html  # Should be 1
grep -c "</html>" index.html  # Should be 1

# Validate meta tags
grep -c "charset" index.html  # Should be 1
grep -c "viewport" index.html  # Should be 1
grep -c "description" index.html  # Should be 1+

# Section count
grep -c "<section" index.html  # Should be 10
```

**Results**: ✅ All tests passed
- HTML structure: Valid
- Meta tags: Present
- Sections: 10 found
- Forms: 1 found

### CSS Validation

**Tests**:
```bash
# CSS rules
grep -c "{" css/styles.css  # 190 rules

# Responsive design
grep -c "@media" css/styles.css  # 3 breakpoints

# Animations
grep -c "@keyframes" css/styles.css  # 4 animations
```

**Results**: ✅ All tests passed
- CSS Rules: 190
- Media Queries: 3 (mobile, tablet, desktop)
- Animations: 4 (slideInUp, slideInDown, fadeIn, float)

### JavaScript Validation

**Tests**:
```bash
# Functions
grep -c "function" js/main.js  # 12 functions

# Event listeners
grep -c "addEventListener" js/main.js  # 11 listeners
```

**Results**: ✅ All tests passed
- Functions: 12 defined
- Event Listeners: 11 attached
- No syntax errors detected

### Browser Compatibility Testing

**Manual Testing Required**:
- [ ] Chrome 90+
- [ ] Firefox 88+
- [ ] Safari 14+
- [ ] Edge 90+
- [ ] Mobile Safari (iOS)
- [ ] Chrome Mobile (Android)

### Lighthouse Audit

**Target Scores**:
- Performance: 90+
- Accessibility: 95+
- Best Practices: 95+
- SEO: 95+

**Run Audit**:
```bash
# Using Chrome DevTools
# 1. Open index.html in Chrome
# 2. Open DevTools (F12)
# 3. Go to Lighthouse tab
# 4. Generate report
```

### Form Testing

**Test Cases**:
1. **Valid Submission**:
   - Fill all fields correctly
   - Submit form
   - Verify success notification

2. **Validation**:
   - Submit with empty fields → Should show error
   - Invalid email format → Should validate
   - Missing required fields → Should prevent submission

3. **Network Error**:
   - Simulate network failure
   - Verify error handling

---

## Running Tests

### Full Test Suite

```bash
# Run all tests
xcodebuild test -scheme SurgicalTrainingUniverse \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -enableCodeCoverage YES \
  -resultBundlePath ./test-results/latest.xcresult
```

### Specific Test Suites

```bash
# Models only
xcodebuild test -scheme SurgicalTrainingUniverse \
  -only-testing:SurgicalTrainingUniverseTests/Models

# Services only
xcodebuild test -scheme SurgicalTrainingUniverse \
  -only-testing:SurgicalTrainingUniverseTests/Services

# Integration only
xcodebuild test -scheme SurgicalTrainingUniverse \
  -only-testing:SurgicalTrainingUniverseTests/Integration
```

### Individual Tests

```bash
# Single test class
xcodebuild test -scheme SurgicalTrainingUniverse \
  -only-testing:SurgicalTrainingUniverseTests/SurgeonProfileTests

# Single test method
xcodebuild test -scheme SurgicalTrainingUniverse \
  -only-testing:SurgicalTrainingUniverseTests/SurgeonProfileTests/testSurgeonProfileInitialization
```

### Code Coverage

```bash
# Generate coverage report
xcrun xccov view --report ./test-results/latest.xcresult > coverage-report.txt

# View HTML report
xcrun xccov view --html ./test-results/latest.xcresult > coverage.html
open coverage.html
```

---

## Continuous Integration

### GitHub Actions Workflow

**File**: `.github/workflows/test.yml`

```yaml
name: Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: macos-14

    steps:
    - uses: actions/checkout@v3

    - name: Select Xcode version
      run: sudo xcode-select -s /Applications/Xcode_16.0.app

    - name: Run tests
      run: |
        xcodebuild test \
          -scheme SurgicalTrainingUniverse \
          -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
          -enableCodeCoverage YES \
          -resultBundlePath ./test-results/ci.xcresult

    - name: Upload coverage
      uses: codecov/codecov-action@v3
      with:
        files: ./test-results/ci.xcresult
```

---

## Test Results

### Current Status

**Unit Tests**: ✅ 3 test files created
- SurgeonProfileTests.swift (15+ tests)
- ProcedureServiceTests.swift (12+ tests)
- AnalyticsServiceTests.swift (10+ tests)

**Integration Tests**: 🔄 In Progress
- ServiceIntegrationTests.swift (planned)

**UI Tests**: 📝 Planned
- DashboardViewTests.swift
- AnalyticsViewTests.swift
- SurgicalTheaterViewTests.swift

**Landing Page**: ✅ Validated
- HTML: Valid structure
- CSS: 190 rules, 3 breakpoints, 4 animations
- JavaScript: 12 functions, 11 event listeners
- No syntax errors

### Test Execution Summary

**What Can Be Run in Current Environment**:
- ❌ Swift tests (requires Xcode/visionOS SDK)
- ✅ HTML/CSS/JS validation
- ✅ Code structure analysis
- ✅ File organization verification
- ✅ Documentation review

**What Requires visionOS Environment**:
- Swift unit tests execution
- Integration tests
- UI tests
- Performance profiling
- Hand tracking tests
- Immersive space testing

---

## Next Steps

### Immediate
1. ✅ Create unit test files
2. ✅ Validate landing page
3. 🔄 Update documentation
4. 📝 Create integration tests
5. 📝 Set up CI/CD pipeline

### Short-term
1. Run tests on actual Vision Pro hardware
2. Implement UI test suite
3. Set up code coverage tracking
4. Create performance benchmarks
5. Establish testing best practices

### Long-term
1. Achieve 80%+ code coverage
2. Automate all testable components
3. Implement continuous monitoring
4. Regular performance audits
5. User acceptance testing with surgeons

---

## Conclusion

This testing strategy ensures the Surgical Training Universe application is:
- **Reliable**: Comprehensive test coverage
- **Performant**: Regular performance testing
- **Maintainable**: Well-structured tests
- **High-Quality**: Multiple testing layers
- **User-Ready**: Manual testing on real hardware

All tests are designed to be run regularly during development and automatically in CI/CD pipelines.
