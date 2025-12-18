# Narrative Story Worlds - Testing Documentation

Comprehensive testing documentation for the Narrative Story Worlds visionOS application.

## Table of Contents

1. [Overview](#overview)
2. [Test Structure](#test-structure)
3. [Running Tests](#running-tests)
4. [Test Coverage](#test-coverage)
5. [Test Types](#test-types)
6. [Environment Requirements](#environment-requirements)
7. [CI/CD Integration](#cicd-integration)
8. [Troubleshooting](#troubleshooting)

---

## Overview

This directory contains all test files, strategies, and documentation for ensuring the Narrative Story Worlds application is production-ready. Our testing approach covers:

- **Unit Tests**: Individual component validation
- **Integration Tests**: System interaction verification
- **Performance Tests**: Speed, memory, and efficiency benchmarks
- **UI Tests**: User interface and interaction testing (requires simulator/hardware)
- **Hardware Tests**: visionOS-specific tests requiring Apple Vision Pro

### Test Philosophy

Our testing follows these principles:

1. **Comprehensive Coverage**: 80%+ code coverage for critical systems
2. **Automated Where Possible**: Maximize automation to catch regressions early
3. **Hardware Validation**: Extensive real-device testing before release
4. **Continuous Testing**: Automated tests run on every commit
5. **Performance Baselines**: Track performance metrics against targets

---

## Test Structure

```
Tests/
├── README.md                          # This file
├── TEST_STRATEGY.md                   # Comprehensive test strategy
├── VISIONOS_HARDWARE_TESTS.md        # Hardware-specific test documentation
├── StorySystemTests.swift            # Core story system tests
├── AISystemTests.swift               # AI component unit tests
├── IntegrationTests.swift            # System integration tests
├── PerformanceTests.swift            # Performance benchmarks
└── VisionOSUITests.swift             # UI tests (requires simulator/hardware)
```

### Test File Descriptions

#### StorySystemTests.swift
- Basic story model tests
- Dialogue node creation
- Choice validation
- Scene structure tests

#### AISystemTests.swift
- **StoryDirectorAITests**: Pacing, player archetypes, branch selection
- **CharacterAITests**: Emotional states, memory system, personality behaviors
- **EmotionRecognitionAITests**: Emotion classification, confidence scoring, engagement
- **DialogueGeneratorTests**: Template selection, personality voice, context awareness

#### IntegrationTests.swift
- **StoryFlowIntegrationTests**: End-to-end story progression, save/restore
- **AISystemIntegrationTests**: AI pipeline coordination, emotion→pacing feedback
- **AudioVisualIntegrationTests**: Dialogue+audio sync, emotional haptics

#### PerformanceTests.swift
- AI performance benchmarks
- Memory usage tests
- Frame time simulations
- Algorithm efficiency tests
- Concurrency performance
- Baseline metric validation

#### VISIONOS_HARDWARE_TESTS.md
- ARKit integration tests (room mapping, anchors)
- Spatial audio tests (3D positioning, occlusion)
- Hand tracking tests (gestures, accuracy)
- Eye tracking tests (gaze detection, engagement)
- Face tracking & emotion recognition tests
- Character spatial behavior tests
- Performance & thermal tests on hardware
- User movement & room-scale tests
- Accessibility tests (VoiceOver, reduced motion)
- Multi-session persistence tests

---

## Running Tests

### Prerequisites

**For Unit & Integration Tests** (macOS/Linux):
```bash
# Xcode 15.2+ with visionOS SDK
xcode-select --version

# Swift 6.0+
swift --version
```

**For UI Tests** (visionOS Simulator):
```bash
# Install visionOS simulator
xcodebuild -downloadPlatform visionOS
```

**For Hardware Tests** (Apple Vision Pro):
- Apple Vision Pro device with visionOS 2.0+
- Xcode 15.2+ with device provisioning
- Developer account with visionOS entitlements

### Command Line Testing

#### Run All Unit & Integration Tests

```bash
# From project root
xcodebuild test \
  -scheme NarrativeStoryWorlds \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
```

#### Run Specific Test Suite

```bash
# Run only AI system tests
xcodebuild test \
  -scheme NarrativeStoryWorlds \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -only-testing:NarrativeStoryWorldsTests/AISystemTests
```

#### Run with Code Coverage

```bash
xcodebuild test \
  -scheme NarrativeStoryWorlds \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -enableCodeCoverage YES \
  -resultBundlePath ./TestResults.xcresult
```

#### Generate Coverage Report

```bash
# Convert xcresult to readable format
xcrun xccov view --report ./TestResults.xcresult

# Export to JSON
xcrun xccov view --report --json ./TestResults.xcresult > coverage.json
```

### Xcode Testing

#### Run All Tests (⌘U)

1. Open `NarrativeStoryWorlds.xcodeproj` in Xcode
2. Select the NarrativeStoryWorlds scheme
3. Choose visionOS Simulator destination
4. Press `⌘U` or Product → Test

#### Run Specific Test Class

1. Open test file (e.g., `AISystemTests.swift`)
2. Click diamond icon next to test class
3. Or right-click and select "Run \[TestClass\]"

#### Run Single Test

1. Navigate to specific test method
2. Click diamond icon next to test method
3. Or place cursor in method and press `⌘U`

#### View Test Results

- Test Navigator (⌘6) shows all tests with pass/fail status
- Report Navigator (⌘9) shows detailed test runs
- Coverage tab shows code coverage percentages

### Performance Testing

```bash
# Run performance tests
xcodebuild test \
  -scheme NarrativeStoryWorlds \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -only-testing:NarrativeStoryWorldsTests/PerformanceTests
```

Performance tests use XCTest's `measure` blocks to track:
- Execution time
- Memory usage (XCTMemoryMetric)
- Storage I/O
- Baseline comparisons

### Hardware Testing

Hardware tests **cannot** be automated and require manual execution on Apple Vision Pro. See `VISIONOS_HARDWARE_TESTS.md` for detailed procedures.

**Quick Start**:

1. Build app for device:
   ```bash
   xcodebuild build \
     -scheme NarrativeStoryWorlds \
     -destination 'platform=visionOS,name=My Vision Pro'
   ```

2. Install on Vision Pro via Xcode

3. Execute tests from `VISIONOS_HARDWARE_TESTS.md`:
   - Start with Setup Tests (ARK-001 to ARK-004)
   - Proceed through Interaction Tests (HND-*, EYE-*)
   - Run Performance Tests (PERF-*)
   - Complete with Accessibility Tests (ACC-*)

4. Document results using bug reporting template in hardware tests doc

---

## Test Coverage

### Coverage Goals

| Component | Target | Current |
|-----------|--------|---------|
| AI Systems | 80%+ | 🟡 In Progress |
| Story Models | 85%+ | 🟡 In Progress |
| Core Systems | 75%+ | 🟡 In Progress |
| UI Views | 60%+ | 📋 Planned |
| Overall | 70%+ | 🟡 In Progress |

### Viewing Coverage

**In Xcode**:
1. Run tests with coverage enabled (⌘U)
2. Navigate to Report Navigator (⌘9)
3. Select latest test run
4. Click Coverage tab
5. Expand modules to see file-level coverage

**Command Line**:
```bash
# Generate coverage report
xcrun xccov view --report ./TestResults.xcresult

# Show uncovered lines
xcrun xccov view --report --files-for-target NarrativeStoryWorlds ./TestResults.xcresult
```

### Coverage Gaps (To Be Addressed)

- [ ] UI View rendering tests (requires simulator)
- [ ] Spatial audio engine (requires hardware)
- [ ] Gesture recognition (requires hardware)
- [ ] ARKit integration (requires hardware)
- [ ] CloudKit sync (requires network)

---

## Test Types

### 1. Unit Tests ✅ (Executable Now)

**Purpose**: Validate individual components in isolation

**Environment**: macOS, Linux, or visionOS Simulator

**Files**:
- `AISystemTests.swift`
- `StorySystemTests.swift`
- Parts of `IntegrationTests.swift`

**Coverage**:
- StoryDirectorAI: Pacing, archetypes, branch selection
- CharacterAI: Emotions, memory, personality
- EmotionRecognitionAI: Classification, confidence
- DialogueGenerator: Templates, context awareness
- Story Models: Structures, validation

**Run Time**: ~2-5 seconds

### 2. Integration Tests ✅ (Partially Executable)

**Purpose**: Verify system interactions

**Environment**: visionOS Simulator or macOS (with mocks)

**Files**:
- `IntegrationTests.swift`

**Coverage**:
- Story progression flow
- AI system coordination
- Save/restore functionality
- Achievement unlocking
- Audio-visual integration (mocked)

**Run Time**: ~5-10 seconds

### 3. Performance Tests ✅ (Executable Now)

**Purpose**: Benchmark speed, memory, and efficiency

**Environment**: visionOS Simulator (best on hardware)

**Files**:
- `PerformanceTests.swift`

**Coverage**:
- AI processing speed (<100ms target)
- Memory usage and leaks
- Frame time simulation (90 FPS target)
- Concurrent processing
- Data serialization

**Run Time**: ~30-60 seconds

### 4. UI Tests ⚠️ (Requires Simulator/Hardware)

**Purpose**: Test user interface and interactions

**Environment**: visionOS Simulator or Apple Vision Pro

**Files**:
- `VisionOSUITests.swift` (to be created)

**Coverage**:
- View rendering
- Choice selection
- Dialogue progression
- HUD functionality
- Accessibility labels

**Run Time**: ~10-20 seconds

### 5. Hardware Tests ❌ (Requires Apple Vision Pro)

**Purpose**: Validate visionOS-specific features

**Environment**: Apple Vision Pro only

**Documentation**:
- `VISIONOS_HARDWARE_TESTS.md`

**Coverage**:
- ARKit tracking and anchors
- Spatial audio 3D positioning
- Hand gestures (pinch, point, grab, wave)
- Eye tracking and gaze detection
- Face tracking and emotion recognition
- Character spatial behavior
- Performance (90 FPS, thermal, battery)
- Room-scale movement
- Accessibility (VoiceOver, etc.)
- Multi-session persistence

**Run Time**: 20-30 hours for full suite

---

## Environment Requirements

### Local Development (macOS)

**Minimum**:
- macOS 14.0 (Sonoma) or later
- Xcode 15.2+
- 16 GB RAM
- Apple Silicon (M1/M2/M3) recommended

**Setup**:
```bash
# Clone repository
git clone https://github.com/your-org/visionOS_Gaming_narrative-story-worlds.git
cd visionOS_Gaming_narrative-story-worlds

# Open in Xcode
open NarrativeStoryWorlds.xcodeproj

# Run tests
xcodebuild test -scheme NarrativeStoryWorlds
```

### visionOS Simulator

**Requirements**:
- Xcode 15.2+ with visionOS SDK
- 50+ GB free disk space
- 16+ GB RAM recommended

**Installation**:
```bash
# Download visionOS platform
xcodebuild -downloadPlatform visionOS

# Verify installation
xcrun simctl list runtimes | grep visionOS
```

**Create Simulator**:
```bash
xcrun simctl create "Vision Pro Test" "Apple Vision Pro" visionOS2.0
```

### Apple Vision Pro Hardware

**Requirements**:
- Apple Vision Pro with visionOS 2.0+
- Apple Developer account ($99/year)
- Provisioning profile with visionOS entitlements
- USB-C cable for device connection

**Setup**:
1. Enable Developer Mode on Vision Pro:
   - Settings → Privacy & Security → Developer Mode → Enable
2. Connect to Mac via USB-C
3. Trust computer on Vision Pro
4. Select device in Xcode scheme selector
5. Build and run (⌘R)

### CI/CD Environment (GitHub Actions / Xcode Cloud)

**GitHub Actions Example** (`.github/workflows/tests.yml`):
```yaml
name: Run Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v3

      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode_15.2.app

      - name: Run Unit Tests
        run: |
          xcodebuild test \
            -scheme NarrativeStoryWorlds \
            -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
            -enableCodeCoverage YES \
            -resultBundlePath ./TestResults.xcresult

      - name: Generate Coverage Report
        run: |
          xcrun xccov view --report ./TestResults.xcresult > coverage.txt
          cat coverage.txt

      - name: Upload Coverage
        uses: actions/upload-artifact@v3
        with:
          name: coverage-report
          path: coverage.txt
```

---

## CI/CD Integration

### Continuous Integration Pipeline

Our CI pipeline runs on every commit and pull request:

**Stage 1: Build** (2-3 minutes)
- Swift compilation check
- Dependency resolution
- Asset validation

**Stage 2: Unit & Integration Tests** (3-5 minutes)
- Run all unit tests
- Run integration tests
- Generate code coverage

**Stage 3: Performance Tests** (5-10 minutes)
- Run performance benchmarks
- Compare against baselines
- Alert on >5% regression

**Stage 4: Code Quality** (2-3 minutes)
- SwiftLint static analysis
- Detect code smells
- Enforce style guidelines

**Total**: ~15-20 minutes

### Nightly Builds

Extended testing runs every night at 2 AM UTC:

- Full test suite (including long-running tests)
- Memory leak detection (4-hour stress test)
- Performance profiling with Instruments
- Test coverage report generation
- Dependency security audit

### Pre-Release Checklist

Before submitting to App Store:

- [ ] All unit tests pass (100%)
- [ ] All integration tests pass (100%)
- [ ] Performance tests pass (>95%)
- [ ] Code coverage >70%
- [ ] SwiftLint warnings = 0
- [ ] Manual hardware tests complete (from VISIONOS_HARDWARE_TESTS.md)
- [ ] Beta tester feedback reviewed
- [ ] Known issues documented
- [ ] Privacy manifest updated
- [ ] TestFlight beta deployed and validated

---

## Test Data & Fixtures

### Mock Data Location

Mock data for testing is located in:
- `Tests/Fixtures/` (to be created)
- Inline mock data in test files

### Creating Test Stories

Example of creating a test story:

```swift
func createTestStory() -> Story {
    let character = Character(
        id: UUID(),
        name: "Test Character",
        bio: "A test character",
        personality: Personality(
            openness: 0.7,
            conscientiousness: 0.6,
            extraversion: 0.6,
            agreeableness: 0.7,
            neuroticism: 0.3
        ),
        emotionalState: EmotionalState(),
        voiceProfile: VoiceProfile(),
        spatialProperties: SpatialCharacterProperties(
            preferredDistance: 1.5,
            height: 1.7,
            allowedMovementRadius: 3.0
        ),
        appearanceDescription: "Test appearance"
    )

    let dialogueNode = DialogueNode(
        id: UUID(),
        characterID: character.id,
        text: "Test dialogue",
        emotionalTone: .neutral,
        audioClipName: nil,
        nextNodes: [],
        choices: []
    )

    // ... create scene, chapter, and story
}
```

### Mock ARKit Data

For tests that need ARKit data (without hardware):

```swift
func createMockFaceAnchor() -> [String: Float] {
    return [
        "mouthSmileLeft": 0.7,
        "mouthSmileRight": 0.7,
        "eyeWideLeft": 0.2,
        "eyeWideRight": 0.2
    ]
}
```

---

## Troubleshooting

### Common Issues

#### Issue: Tests Fail to Build

**Error**: `Cannot find 'Story' in scope`

**Solution**:
- Ensure test target has access to app code
- Check Target Membership in File Inspector
- Verify `@testable import NarrativeStoryWorlds` at top of test file

#### Issue: Simulator Not Found

**Error**: `Unable to boot device in current state: Booted`

**Solution**:
```bash
# Reset simulator
xcrun simctl shutdown all
xcrun simctl erase all

# Recreate simulator
xcrun simctl create "Vision Pro Test" "Apple Vision Pro" visionOS2.0
```

#### Issue: Tests Time Out

**Error**: `Test case timed out after 60 seconds`

**Solution**:
- Increase timeout for async tests:
  ```swift
  let expectation = XCTestExpectation(description: "Async operation")
  wait(for: [expectation], timeout: 120.0) // Increase from 60
  ```

#### Issue: Code Coverage Not Generating

**Error**: No coverage data in results

**Solution**:
- Ensure `-enableCodeCoverage YES` flag is set
- Check scheme settings: Edit Scheme → Test → Options → Code Coverage
- Clean build folder (Shift+⌘K) and retry

#### Issue: Hardware Tests Not Connecting

**Error**: `Device not found: My Vision Pro`

**Solution**:
- Verify Developer Mode enabled on Vision Pro
- Re-pair device (unpair in Xcode → Devices, then reconnect)
- Check USB-C cable and port
- Restart Xcode

### Performance Test Failures

If performance tests fail:

1. **Check Baseline**: Performance may vary by machine
   - Run tests 3 times to establish baseline
   - Update baseline in Xcode: Editor → Set Baseline for Test

2. **Reduce Noise**: Close other applications
   - Quit Xcode previews
   - Stop other simulators
   - Disable Time Machine during tests

3. **Warm Up**: First run is often slower
   - Run tests twice, ignore first run
   - Use `setUp()` to warm up caches

### Test Debugging

Enable verbose test output:

```bash
xcodebuild test \
  -scheme NarrativeStoryWorlds \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -verbose
```

Debug specific test in Xcode:
1. Set breakpoint in test method
2. Right-click test diamond → Debug "testMethodName"
3. Step through with debugger (F6, F7)

---

## Performance Baselines

### Target Metrics

| Metric | Target | Notes |
|--------|--------|-------|
| Dialogue Generation | <100ms | AI response time |
| Emotion Classification | <20ms | Per frame |
| Memory Usage | <1.5 GB | Peak during gameplay |
| Frame Rate | 90 FPS | Minimum on Vision Pro |
| Frame Time | <11ms | 90 FPS requirement |
| Cold Launch | <3s | To first frame |
| Story Load | <500ms | Saved state restore |

### Tracking Performance

Performance metrics are tracked in CI and compared against baselines:

```swift
func testDialogueGenerationPerformance() {
    measure(metrics: [XCTClockMetric()]) {
        // Code to measure
    }
}

func testMemoryUsage() {
    measure(metrics: [XCTMemoryMetric()]) {
        // Code to measure
    }
}
```

---

## Contributing Tests

### Test Writing Guidelines

1. **Clear Test Names**: Use descriptive names
   ```swift
   // Good
   func testEmotionalState_PositiveChoice_IncreaseTrust()

   // Bad
   func testEmotion()
   ```

2. **Arrange-Act-Assert Pattern**:
   ```swift
   func testExample() {
       // Arrange: Set up test data
       let character = createTestCharacter()

       // Act: Execute the code being tested
       character.updateTrust(delta: 0.1)

       // Assert: Verify the result
       XCTAssertEqual(character.emotionalState.trust, 0.6)
   }
   ```

3. **Test One Thing**: Each test should verify one behavior

4. **Use setUp/tearDown**:
   ```swift
   override func setUp() async throws {
       // Initialize before each test
   }

   override func tearDown() async throws {
       // Clean up after each test
   }
   ```

5. **Document Complex Tests**:
   ```swift
   /// Tests that the Story Director correctly adjusts pacing when
   /// player engagement drops below 40% during a high-intensity scene.
   /// This ensures the AI prevents player disengagement.
   func testPacingAdjustment_LowEngagement_HighIntensity()
   ```

### Adding New Tests

1. Create test method in appropriate file
2. Run test locally to verify
3. Update coverage goals if needed
4. Submit PR with tests
5. Ensure CI passes

### Test Review Checklist

- [ ] Test name is descriptive
- [ ] Follows Arrange-Act-Assert
- [ ] No hardcoded wait times (use expectations)
- [ ] Cleans up resources in tearDown
- [ ] Passes locally on simulator
- [ ] Documented if complex

---

## Resources

### Documentation

- [TEST_STRATEGY.md](./TEST_STRATEGY.md) - Comprehensive test strategy
- [VISIONOS_HARDWARE_TESTS.md](./VISIONOS_HARDWARE_TESTS.md) - Hardware test procedures
- [XCTest Documentation](https://developer.apple.com/documentation/xctest)
- [visionOS Testing Guide](https://developer.apple.com/documentation/visionos)

### Tools

- **Xcode**: Primary IDE with integrated testing
- **Instruments**: Performance profiling
- **SwiftLint**: Code quality and style
- **GitHub Actions**: CI/CD automation
- **TestFlight**: Beta testing distribution

### Contacts

- **Test Lead**: [Your Name]
- **CI/CD**: [DevOps Contact]
- **Hardware Testing**: [QA Lead]

---

## Changelog

### 2025-11-19
- Created comprehensive test suite
- Added AI system tests (unit)
- Added integration tests
- Added performance tests
- Documented visionOS hardware tests
- Created test strategy document
- This README created

---

**Last Updated**: 2025-11-19
**Next Review**: Before each major release
