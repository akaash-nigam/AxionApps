# Rhythm Flow Test Suite

Comprehensive test coverage for the Rhythm Flow visionOS game.

## 📋 Quick Start

### Run Tests NOW (No Xcode Required)
```bash
# Landing page validation tests
python3 Tests/Landing/validate_html.py
```

### Run Tests Later (Requires Xcode + visionOS SDK)
```bash
# All Swift tests
xcodebuild test -project RhythmFlow/RhythmFlow.xcodeproj -scheme RhythmFlow

# Specific test suite
xcodebuild test -only-testing:RhythmFlowTests/ScoreManagerTests
```

---

## 🧪 Test Structure

```
Tests/
├── Unit/                           # Unit tests for isolated components
│   ├── ScoreManagerTests.swift     # Scoring system tests (15+ tests)
│   └── DataModelTests.swift        # Data model tests (20+ tests)
│
├── Integration/                    # Multi-system integration tests
│   └── GameplayIntegrationTests.swift  # End-to-end gameplay (10+ tests)
│
├── UI/                            # User interface tests
│   └── MenuNavigationTests.swift   # UI navigation tests (8+ tests)
│
├── Performance/                    # Performance benchmarks
│   └── PerformanceTests.swift      # FPS, memory, CPU tests (15+ tests)
│
├── Accessibility/                  # Accessibility compliance tests
│   └── AccessibilityTests.swift    # WCAG & Apple guidelines (20+ tests)
│
├── Landing/                        # Landing page validation (RUNNABLE NOW!)
│   └── validate_html.py           # HTML/CSS/JS validation ✅
│
├── TEST_GUIDE.md                  # Comprehensive testing documentation
└── README.md                      # This file
```

---

## 📊 Test Coverage

| Test Type | Files | Test Methods | Status | Runnable Now |
|-----------|-------|--------------|--------|--------------|
| **Unit Tests** | 2 | 35+ | ✅ Ready | ❌ Requires Xcode |
| **Integration Tests** | 1 | 10+ | ✅ Ready | ❌ Requires Xcode |
| **UI Tests** | 1 | 8+ | ✅ Ready | ❌ Requires Xcode |
| **Performance Tests** | 1 | 15+ | ✅ Ready | ❌ Requires Xcode |
| **Accessibility Tests** | 1 | 20+ | ✅ Ready | ❌ Requires Xcode |
| **Landing Page Tests** | 1 | 30+ | ✅ Ready | ✅ **YES** |
| **TOTAL** | **7** | **118+** | ✅ **Ready** | 1/7 runnable |

---

## 🎯 What Each Test Suite Covers

### Unit Tests
**ScoreManagerTests.swift**
- Hit quality scoring (Perfect/Great/Good/Okay/Miss)
- Combo multipliers (10x, 25x, 50x, 100x, 200x)
- Accuracy calculations
- Grade determination (S/A/B/C/D/F)
- Statistics tracking
- Reset functionality

**DataModelTests.swift**
- Song, BeatMap, NoteEvent models
- PlayerProfile progression
- GameSession tracking
- Codable conformance
- Data validation

### Integration Tests
**GameplayIntegrationTests.swift**
- Complete song playthrough
- Pause/resume functionality
- Multi-system coordination (Game + Audio + Input)
- Profile updates after gameplay
- State transitions
- Data persistence

### UI Tests
**MenuNavigationTests.swift**
- Main menu navigation
- Song library browsing
- Settings access
- Profile viewing
- Accessibility labels

### Performance Tests
**PerformanceTests.swift**
- Frame rate (90 FPS target)
- Memory usage (< 2GB limit)
- CPU performance
- Object pooling efficiency
- Sustained gameplay stress tests
- Audio sync performance

### Accessibility Tests
**AccessibilityTests.swift**
- VoiceOver support
- High contrast mode (WCAG AAA 7:1)
- Color blind modes
- Dynamic Type support
- Reduce motion
- Alternative controls
- Haptic feedback
- WCAG 2.1 Level AA compliance

### Landing Page Tests
**validate_html.py** ✅ **Runnable Now!**
- HTML5 validation
- CSS validation
- JavaScript validation
- SEO optimization
- Accessibility features
- Responsive design

---

## 🚀 Running Tests

### Landing Page Tests (Python) ✅

**Run immediately without Xcode:**
```bash
cd visionOS_Gaming_rhythm-flow
python3 Tests/Landing/validate_html.py
```

**Latest Results:**
```
HTML:       17 passes, 4 warnings (81.0% success)
CSS:        4 passes, 0 warnings (100% success)
JavaScript: 5 passes, 0 warnings (100% success)
```

### Swift Tests (Xcode Required) ❌

**Prerequisites:**
- macOS 14.0+ (Sonoma)
- Xcode 16.0+
- visionOS SDK 2.0+
- Apple Vision Pro Simulator or device

**Run all tests:**
```bash
xcodebuild test \
  -project RhythmFlow/RhythmFlow.xcodeproj \
  -scheme RhythmFlow \
  -sdk xros \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
```

**Run specific test suite:**
```bash
# Unit tests only
xcodebuild test -only-testing:RhythmFlowTests/ScoreManagerTests

# Integration tests only
xcodebuild test -only-testing:RhythmFlowTests/GameplayIntegrationTests

# Performance tests only
xcodebuild test -only-testing:RhythmFlowTests/PerformanceTests
```

**In Xcode GUI:**
1. Open `RhythmFlow.xcodeproj`
2. Press ⌘U to run all tests
3. Or click diamond icon next to specific test

---

## 📈 Performance Benchmarks

### Target Metrics

| Metric | Target | Measured |
|--------|--------|----------|
| **Frame Rate** | 90 FPS (11.1ms) | TBD |
| **Memory Peak** | < 2GB | TBD |
| **Memory Growth** | < 200MB / 10min | TBD |
| **Input Latency** | < 20ms | TBD |
| **Audio Sync** | ±2ms | TBD |

### Coverage Goals

| Category | Target | Critical Paths |
|----------|--------|----------------|
| **Unit Tests** | 80% | 100% |
| **Integration** | 70% | 100% |
| **UI Tests** | 60% | 100% |

---

## ♿ Accessibility Compliance

Tests validate compliance with:
- ✅ **WCAG 2.1 Level AA** - Web Content Accessibility Guidelines
- ✅ **Apple Accessibility Guidelines** - visionOS specific requirements
- ✅ **Section 508** - US Federal accessibility standards

**Key Features Tested:**
- VoiceOver support throughout app
- High contrast mode (7:1 ratio)
- Color blind friendly palettes
- Dynamic Type (text scaling)
- Reduce motion mode
- Alternative controls (controller, head tracking)
- Haptic feedback
- Adjustable difficulty and timing

---

## 🔧 Setting Up Tests in Xcode

### 1. Create Test Targets

```bash
# Open project
open RhythmFlow/RhythmFlow.xcodeproj
```

In Xcode:
1. **File → New → Target**
2. Select **visionOS → Test → Unit Testing Bundle**
3. Name: `RhythmFlowTests`
4. Repeat for **UI Testing Bundle**: `RhythmFlowUITests`

### 2. Add Test Files

Drag test files from `Tests/` directory into Xcode:
- `Unit/*.swift` → Add to `RhythmFlowTests` target
- `Integration/*.swift` → Add to `RhythmFlowTests` target
- `Performance/*.swift` → Add to `RhythmFlowTests` target
- `Accessibility/*.swift` → Add to `RhythmFlowTests` target
- `UI/*.swift` → Add to `RhythmFlowUITests` target

### 3. Configure Dependencies

For `RhythmFlowTests` target:
1. Go to **Build Phases → Link Binary With Libraries**
2. Add `RhythmFlow.framework`
3. Ensure `@testable import RhythmFlow` works

### 4. Enable Code Coverage

1. **Product → Scheme → Edit Scheme**
2. Go to **Test** tab
3. Check **Code Coverage**
4. Select **RhythmFlow** under coverage targets

---

## 📝 Test Documentation

For detailed information, see **[TEST_GUIDE.md](TEST_GUIDE.md)**:
- Complete test descriptions
- Step-by-step running instructions
- Troubleshooting guide
- CI/CD integration
- Test maintenance guidelines

---

## 🎯 Test Philosophy

### Principles

1. **Fast**: Unit tests run in < 5 seconds
2. **Isolated**: Tests don't depend on each other
3. **Repeatable**: Same input = same output
4. **Self-checking**: Pass/fail is automatic
5. **Timely**: Written alongside features

### Test Naming Convention

```swift
func test[Feature][Scenario]() {
    // Arrange
    // Act
    // Assert
}
```

**Examples:**
- `testPerfectHitScoring()` - Tests perfect hit gives correct score
- `testComboMultiplierAt50()` - Tests 50-combo gives 1.5x multiplier
- `testGradeCalculationForAGrade()` - Tests A grade threshold

### Test Structure (AAA Pattern)

```swift
func testScoreCalculation() {
    // Arrange - Set up test data
    let scoreManager = ScoreManager()

    // Act - Perform action
    scoreManager.registerHit(.perfect, noteValue: 100)

    // Assert - Verify result
    XCTAssertEqual(scoreManager.currentScore, 115)
}
```

---

## 🐛 Troubleshooting

### Common Issues

**"Could not find test target"**
- Ensure test files are added to correct target
- Check target membership in File Inspector (⌥⌘1)

**"No such module 'RhythmFlow'"**
- Add RhythmFlow.framework to test target dependencies
- Clean build folder (⇧⌘K) and rebuild

**"Hand tracking not available in simulator"**
- Hand tracking tests require physical device
- Use `#if targetEnvironment(simulator)` to skip

**Performance tests failing intermittently**
- Run on physical device for consistency
- Increase baseline tolerance to 15-20%
- Close other apps during testing

---

## 📅 Test Maintenance

### When to Update Tests

- ✅ **After adding new features** - Write tests for new code
- ✅ **After bug fixes** - Add regression tests
- ✅ **When APIs change** - Update affected tests
- ✅ **When tests fail** - Fix or update assertions

### Before Committing

- [ ] All tests pass locally
- [ ] New features have tests
- [ ] Code coverage meets targets (80%)
- [ ] Performance benchmarks pass
- [ ] Accessibility tests updated

---

## 🚀 CI/CD Integration

### GitHub Actions

Tests automatically run on:
- Every push to `main`, `develop`, `claude/*` branches
- Every pull request
- Nightly (performance tests)
- Weekly (full accessibility audit)

See **[.github/workflows/test.yml](../.github/workflows/test.yml)** for configuration.

---

## 📞 Support

- **Documentation**: [TEST_GUIDE.md](TEST_GUIDE.md)
- **Apple Docs**: [XCTest Framework](https://developer.apple.com/documentation/xctest)
- **Project Issues**: [GitHub Issues](https://github.com/akaash-nigam/visionOS_Gaming_rhythm-flow/issues)

---

## ✅ Test Checklist

### Before Release

- [ ] Unit tests: 80%+ coverage
- [ ] Integration tests: All critical paths pass
- [ ] UI tests: All major flows work
- [ ] Performance: 90 FPS sustained
- [ ] Memory: < 2GB peak usage
- [ ] Accessibility: WCAG 2.1 AA compliant
- [ ] Landing page: All validations pass

### Test Status

| Category | Status | Notes |
|----------|--------|-------|
| Unit Tests | ✅ Written | Ready for Xcode |
| Integration Tests | ✅ Written | Ready for Xcode |
| UI Tests | ✅ Written | Ready for Xcode |
| Performance Tests | ✅ Written | Ready for Xcode |
| Accessibility Tests | ✅ Written | Ready for Xcode |
| Landing Page Tests | ✅ **PASSING** | 81% HTML, 100% CSS, 100% JS |

---

**Last Updated**: 2024
**Test Files**: 7
**Test Methods**: 118+
**Code Coverage Goal**: 80%
**Performance Target**: 90 FPS
