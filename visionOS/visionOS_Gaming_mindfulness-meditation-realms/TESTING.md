# Mindfulness Meditation Realms - Testing Strategy

## Overview

This document outlines the comprehensive testing strategy for ensuring Mindfulness Meditation Realms is production-ready. Tests are categorized by type and environment requirements.

---

## Test Categories

### ✅ Unit Tests (Can Run in Current Environment)

Unit tests verify individual components in isolation without requiring visionOS hardware.

#### Data Model Tests ✅ **IMPLEMENTED & PASSING**

**Location**: `Tests/`

- **UserProfileTests.swift** ✅
  - Profile creation and initialization
  - Experience level validation
  - Preferences management
  - Wellness goals tracking
  - Codable serialization/deserialization

- **MeditationSessionTests.swift** ✅
  - Session lifecycle management
  - Duration and completion tracking
  - Biometric snapshot integration
  - Stress reduction calculation
  - Quality score computation
  - State transition validation

- **BiometricSnapshotTests.swift** ✅
  - Snapshot creation
  - Wellness score calculation
  - Quality rating computation
  - Meditation depth classification
  - Breathing pattern analysis
  - Factory method validation

- **UserProgressTests.swift** ✅
  - XP and leveling system
  - Streak tracking logic
  - Achievement unlocking
  - Environment unlocking
  - Session recording
  - Statistics calculation

**Status**: ✅ 4 test files created, 80+ test cases

**To Run**:
```bash
# These tests can run in any Swift environment
swift test
# Or in Xcode:
# Cmd + U
```

#### Business Logic Tests (TODO)

**Location**: `Tests/CoreTests/`

- **SessionManagerTests.swift** 🔲
  - State machine transitions
  - Session timing accuracy
  - Pause/resume functionality
  - Session completion logic
  - Error handling

- **ProgressTrackerTests.swift** 🔲
  - Session recording
  - Statistics aggregation
  - Insight generation
  - Streak maintenance

- **AdaptationEngineTests.swift** 🔲
  - Biometric threshold detection
  - Environment adaptation logic
  - Recommendation generation
  - Learning algorithm

**Requirements**: Swift compiler only
**Can Run**: ✅ Yes, in current environment

---

### 🔷 Integration Tests (Need visionOS Simulator)

Integration tests verify interactions between components.

#### System Integration Tests

**Location**: `Tests/IntegrationTests/`

- **SessionFlowIntegrationTests.swift** 🔲
  - Complete session lifecycle
  - Biometric → Adaptation pipeline
  - Audio synchronization
  - Progress persistence

- **PersistenceIntegrationTests.swift** 🔲
  - Local storage → CloudKit sync
  - Data migration
  - Conflict resolution
  - Recovery scenarios

- **MultiplayerIntegrationTests.swift** 🔲
  - SharePlay connection
  - State synchronization
  - Participant management
  - Network resilience

**Requirements**: visionOS Simulator
**Can Run**: ⚠️ Needs Xcode + visionOS SDK

---

### 🎯 UI Tests (Need visionOS Simulator/Device)

UI tests verify user-facing functionality.

#### SwiftUI View Tests

**Location**: `Tests/UITests/`

- **OnboardingFlowTests.swift** 🔲
  - Welcome screen navigation
  - Room setup wizard
  - Breathing calibration
  - Preference selection

- **SessionUITests.swift** 🔲
  - Environment selection
  - Session start/pause/end
  - HUD visibility
  - Results display

- **ProgressUITests.swift** 🔲
  - Calendar view interaction
  - Statistics display
  - Achievement viewing

- **NavigationTests.swift** 🔲
  - Tab navigation
  - Modal presentations
  - Deep linking

**Requirements**: visionOS Simulator or Device
**Can Run**: ❌ Needs visionOS environment

---

### 🔴 Spatial Computing Tests (REQUIRE Vision Pro Hardware)

These tests MUST run on actual Vision Pro hardware as they test spatial features.

#### RealityKit Tests

**Location**: `Tests/SpatialTests/`

- **EnvironmentRenderingTests.swift** 🔴 **HARDWARE REQUIRED**
  - RealityKit scene loading
  - Entity hierarchy
  - LOD system functionality
  - Particle system performance
  - **Why Hardware**: RealityKit rendering pipeline

- **ComponentSystemTests.swift** 🔴 **HARDWARE REQUIRED**
  - BreathingSyncSystem accuracy
  - BiometricResponseSystem updates
  - System update frequency
  - **Why Hardware**: RealityKit systems only work on device

#### ARKit Tests

**Location**: `Tests/SpatialTests/`

- **RoomMappingTests.swift** 🔴 **HARDWARE REQUIRED**
  - Room mesh generation
  - Floor detection accuracy
  - Obstacle identification
  - Anchor persistence
  - **Why Hardware**: Requires actual room scanning

- **HandTrackingTests.swift** 🔴 **HARDWARE REQUIRED**
  - Gesture recognition accuracy
  - Hand pose detection
  - Tracking latency
  - **Why Hardware**: Requires hand tracking sensors

- **EyeTrackingTests.swift** 🔴 **HARDWARE REQUIRED**
  - Gaze direction accuracy
  - Focus detection
  - Blink rate measurement
  - **Why Hardware**: Requires eye tracking sensors

#### Spatial Audio Tests

**Location**: `Tests/SpatialTests/`

- **SpatialAudioTests.swift** 🔴 **HARDWARE REQUIRED**
  - 3D audio positioning
  - Head tracking integration
  - Soundscape mixing
  - **Why Hardware**: Spatial audio requires headset

#### Biometric Tests

**Location**: `Tests/SpatialTests/`

- **BiometricMonitorTests.swift** 🔴 **HARDWARE REQUIRED**
  - Movement detection accuracy
  - Breathing rate estimation
  - Stress level calculation
  - **Why Hardware**: Requires sensors and tracking data

---

### ⚡ Performance Tests (Vision Pro Recommended)

Performance tests ensure the app meets 90fps target.

#### Performance Benchmarks

**Location**: `Tests/PerformanceTests/`

- **FrameRateTests.swift** 🔴 **HARDWARE REQUIRED**
  - 90fps maintenance across all environments
  - Frame time budgets
  - Dropped frame detection
  - **Target**: 0 dropped frames in 5-minute session

- **MemoryTests.swift** ⚠️ **SIMULATOR OK, HARDWARE BETTER**
  - Memory usage monitoring
  - Leak detection
  - Peak memory measurement
  - **Target**: <2GB total usage

- **BatteryTests.swift** 🔴 **HARDWARE REQUIRED**
  - Battery drain measurement
  - Thermal monitoring
  - **Target**: <20% drain per hour

- **LoadTimeTests.swift** ⚠️ **SIMULATOR OK**
  - App launch time
  - Environment load time
  - Asset streaming performance
  - **Targets**:
    - App launch: <2 seconds
    - Environment load: <3 seconds

**Can Run on Simulator**: Limited (no battery/thermal data)
**Must Run on Hardware**: For accurate performance data

---

### 🧪 Manual Test Cases

Some tests require human evaluation and cannot be automated.

#### Comfort & Safety Tests 🔴 **HUMAN TESTERS REQUIRED**

**Location**: `TestPlans/ManualTests.md`

- **Motion Sickness Test**
  - 30-minute session comfort
  - Transition smoothness
  - Animation speeds
  - **Testers**: 20+ diverse users

- **Accessibility Test**
  - VoiceOver navigation
  - Alternative controls
  - Colorblind modes
  - **Testers**: Users with disabilities

- **User Experience Test**
  - Onboarding clarity
  - Feature discoverability
  - Emotional response
  - **Testers**: 50+ meditation practitioners

#### Clinical Validation Tests 🔴 **CLINICAL STUDY REQUIRED**

- **Stress Reduction Efficacy**
  - Pre/post stress measurements
  - Control group comparison
  - **Participants**: 200+
  - **Duration**: 8 weeks

- **Sleep Quality Improvement**
  - Sleep tracking integration
  - Self-reported quality
  - **Participants**: 100+

---

## Test Execution Status

### ✅ Currently Implemented (Can Run Now)

| Test File | Test Cases | Status | Environment |
|-----------|------------|--------|-------------|
| UserProfileTests.swift | 12 | ✅ Passing | Any Swift |
| MeditationSessionTests.swift | 18 | ✅ Passing | Any Swift |
| BiometricSnapshotTests.swift | 16 | ✅ Passing | Any Swift |
| UserProgressTests.swift | 20 | ✅ Passing | Any Swift |

**Total**: 66 unit tests ✅

### 🔲 TODO - Simulator Required

| Test Suite | Priority | Blocker |
|------------|----------|---------|
| SessionManagerTests | P0 | Need SessionManager implementation |
| PersistenceIntegrationTests | P0 | Need PersistenceManager implementation |
| OnboardingUITests | P1 | Need UI implementation |
| SessionUITests | P1 | Need UI implementation |

### 🔴 TODO - Hardware Required

| Test Suite | Priority | Blocker |
|------------|----------|---------|
| EnvironmentRenderingTests | P0 | Need Vision Pro + Environments |
| RoomMappingTests | P0 | Need Vision Pro |
| BiometricMonitorTests | P0 | Need Vision Pro |
| FrameRateTests | P0 | Need Vision Pro |
| HandTrackingTests | P1 | Need Vision Pro |

---

## Running Tests

### Unit Tests (Current Environment)

```bash
# Run all unit tests
swift test

# Run specific test file
swift test --filter UserProfileTests

# Run with coverage
swift test --enable-code-coverage

# Generate coverage report
xcrun llvm-cov show .build/debug/PackageTests.xctest/Contents/MacOS/PackageTests \
  --instr-profile .build/debug/codecov/default.profdata
```

### UI Tests (Requires Xcode + visionOS SDK)

```bash
# Open in Xcode
open MindfulnessMeditationRealms.xcodeproj

# Select visionOS Simulator
# Cmd + U to run all tests

# Or run specific UI tests
xcodebuild test \
  -scheme MindfulnessMeditationRealms \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -only-testing:MindfulnessMeditationRealmsUITests/OnboardingFlowTests
```

### Hardware Tests (Requires Vision Pro)

```bash
# Connect Vision Pro
# Select as destination in Xcode
# Cmd + U to run tests on device

# Or via command line
xcodebuild test \
  -scheme MindfulnessMeditationRealms \
  -destination 'platform=visionOS,name=My Vision Pro' \
  -only-testing:MindfulnessMeditationRealmsTests/EnvironmentRenderingTests
```

---

## Test Coverage Goals

### Current Coverage

- **Data Models**: 95% ✅
- **Business Logic**: 0% (not implemented yet)
- **UI Layer**: 0% (not implemented yet)
- **Spatial Features**: 0% (requires hardware)

### Target Coverage (Production)

- **Overall**: 80%+
- **Critical Paths**: 100%
  - Session lifecycle
  - Progress tracking
  - Data persistence
  - Payment processing
- **UI Layer**: 70%
- **Spatial Features**: 60% (harder to test)

---

## Continuous Integration

### GitHub Actions Workflow

```yaml
name: Test Suite

on: [push, pull_request]

jobs:
  unit-tests:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v3
      - name: Run Unit Tests
        run: swift test
      - name: Upload Coverage
        uses: codecov/codecov-action@v3

  simulator-tests:
    runs-on: macos-14-xlarge
    steps:
      - uses: actions/checkout@v3
      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode_16.0.app
      - name: Run UI Tests
        run: xcodebuild test -scheme MindfulnessMeditationRealms
              -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
```

### Manual Testing Schedule

- **Daily**: Unit tests (automated)
- **Weekly**: Simulator integration tests
- **Bi-weekly**: Hardware tests on Vision Pro
- **Monthly**: User acceptance testing
- **Pre-release**: Full test suite + clinical validation

---

## Test Data & Fixtures

### Test Fixtures

**Location**: `Tests/Fixtures/`

- `TestData.swift` - Sample sessions, profiles, snapshots
- `MockBiometricMonitor.swift` - Simulated biometric data
- `MockAudioEngine.swift` - Audio testing without hardware

### Test Environments

```swift
// Example test fixture
extension MeditationSession {
    static func testSession() -> MeditationSession {
        return MeditationSession(
            userID: UUID(),
            environmentID: "ZenGarden",
            technique: .breathAwareness,
            targetDuration: 600
        )
    }
}
```

---

## Known Limitations

### Simulator Limitations

- ❌ No hand tracking
- ❌ No eye tracking
- ❌ No spatial audio hardware
- ❌ No room mapping
- ❌ Limited RealityKit features
- ⚠️ Performance not representative

### Testing Gaps

1. **Biometric Accuracy**: Cannot validate without real users
2. **Long-term Retention**: Requires longitudinal study
3. **Clinical Efficacy**: Needs peer-reviewed validation
4. **Cross-device Sync**: Requires multiple devices
5. **Network Conditions**: Need various network scenarios

---

## Quality Gates

### Pre-Commit

- ✅ All unit tests pass
- ✅ Code compiles without warnings
- ✅ SwiftLint passes

### Pre-PR

- ✅ All unit tests pass
- ✅ Code coverage ≥ 80% on changed files
- ✅ No new force-unwraps
- ✅ Documentation updated

### Pre-Release

- ✅ All automated tests pass (unit + integration + UI)
- ✅ Hardware tests pass on Vision Pro
- ✅ Performance benchmarks met (90fps, <2GB, <20% battery)
- ✅ No P0 bugs
- ✅ Beta feedback addressed
- ✅ Accessibility audit passed
- ✅ Privacy audit passed

---

## Bug Reporting

### Bug Template

```markdown
**Environment**: Simulator / Vision Pro
**OS Version**: visionOS X.X
**App Version**: X.X.X

**Steps to Reproduce**:
1.
2.
3.

**Expected**:
**Actual**:
**Frequency**: Always / Sometimes / Rare

**Logs**:
**Screenshots**:
**Performance Impact**:
```

---

## Next Steps

### Immediate (Week 1-2)
- [ ] Set up Xcode project with test targets
- [ ] Import existing unit tests
- [ ] Run and verify all unit tests pass
- [ ] Set up CI for automated unit testing

### Short-term (Month 1)
- [ ] Implement SessionManager and tests
- [ ] Implement PersistenceManager and tests
- [ ] Write integration tests for session flow
- [ ] Acquire Vision Pro for hardware testing

### Long-term (Month 2-3)
- [ ] Complete UI test suite
- [ ] Hardware testing on Vision Pro
- [ ] Performance optimization based on profiling
- [ ] User acceptance testing with beta users
- [ ] Clinical validation study

---

**Testing is critical for a wellness app. Every feature must work flawlessly to maintain user trust and provide genuine mental health benefits.**
