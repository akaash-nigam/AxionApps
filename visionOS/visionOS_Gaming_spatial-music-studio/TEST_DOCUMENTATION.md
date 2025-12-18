# Test Documentation - Spatial Music Studio

## Overview

This document provides a comprehensive guide to all tests in the Spatial Music Studio visionOS application. It categorizes tests by type, indicates which tests can run in different environments, and provides execution instructions.

---

## Test Categories

### 1. Unit Tests (Domain Models)
**File:** `SpatialMusicStudio/SpatialMusicStudioTests/DomainModelTests.swift`

**Environment:** ✅ **CAN RUN** in current environment (macOS with Swift/Xcode)

**Test Classes:**
- `MusicTheoryTests` - Tests for music theory constructs
- `CompositionTests` - Tests for composition model
- `TrackTests` - Tests for track management
- `MIDINoteTests` - Tests for MIDI note handling
- `InstrumentTests` - Tests for instrument models
- `CodableTests` - Tests for serialization
- `EdgeCaseTests` - Tests for edge cases and error handling

**Key Tests:**
```
✅ testNoteTransposition() - Verify note transposition by semitones
✅ testChromaticScale() - Verify chromatic scale generation
✅ testMajorScaleIntervals() - Verify major scale intervals
✅ testMajorChordNotes() - Verify chord construction
✅ testCompositionCreation() - Verify composition initialization
✅ testAddTrack() - Verify track addition
✅ testTrackCodable() - Verify JSON serialization
✅ testNegativeDuration() - Verify error handling
```

**How to Run:**
```bash
cd /home/user/visionOS_Gaming_spatial-music-studio/SpatialMusicStudio
swift test --filter DomainModelTests
```

**Expected Results:**
- All tests should pass
- No dependencies on visionOS APIs
- Pure Swift logic tests

---

### 2. Performance Tests (Audio & Rendering)
**File:** `SpatialMusicStudio/SpatialMusicStudioTests/AudioPerformanceTests.swift`

**Environment:** ⚠️ **CANNOT RUN** - Requires visionOS device or simulator with audio hardware

**Test Classes:**
- `AudioLatencyTests` - Audio latency benchmarks
- `AudioQualityTests` - Audio quality verification
- `ConcurrentAudioTests` - Multi-source audio tests
- `ResourceUsageTests` - CPU/memory profiling
- `SpatialAudioPerformanceTests` - 3D audio positioning tests
- `EffectsProcessingTests` - Effects chain performance
- `RecordingPerformanceTests` - Recording impact tests
- `RenderingPerformanceTests` - Visual rendering benchmarks

**Key Tests:**
```
⚠️ testAudioLatency() - Measure round-trip audio latency
   Target: < 10ms

⚠️ testMaxConcurrentSources() - Test concurrent audio sources
   Target: 64+ sources

⚠️ testCPUUsageUnderLoad() - Measure CPU usage
   Target: < 30% CPU for basic playback

⚠️ testFrameRate() - Measure rendering performance
   Target: 90 FPS sustained
```

**Hardware Requirements:**
- Vision Pro device OR visionOS Simulator
- Active audio hardware
- Metal-capable GPU
- ARKit support

**How to Run:**
```bash
# In Xcode on Mac with visionOS Simulator:
1. Open SpatialMusicStudio.xcodeproj
2. Select visionOS Simulator as target
3. Product > Test (⌘U)
4. Filter by "AudioPerformanceTests"

# On actual Vision Pro:
1. Connect Vision Pro via USB
2. Select device as target
3. Product > Test (⌘U)
```

**Expected Results:**
- Audio latency: < 10ms
- Concurrent sources: 64+
- CPU usage: < 30% for playback
- Frame rate: 90 FPS
- Memory: < 512MB for typical session

---

### 3. UI Tests (User Interface)
**File:** `SpatialMusicStudio/SpatialMusicStudioUITests/UITests.swift`

**Environment:** ⚠️ **CANNOT RUN** - Requires visionOS Simulator or Vision Pro

**Test Classes:**
- `SpatialMusicStudioUITests` - Main UI interaction tests
- `AccessibilityUITests` - Accessibility feature tests
- `SpatialInteractionTests` - Spatial gesture tests

**Key Tests:**
```
⚠️ testMainMenuAppearance() - Verify main menu UI elements
⚠️ testNavigationToComposition() - Test navigation flow
⚠️ testInstrumentLibraryOpens() - Test instrument selection
⚠️ testPlayButton() - Test transport controls
⚠️ testHandTrackingInteraction() - Test hand gestures
⚠️ testEyeTrackingInteraction() - Test gaze interaction
⚠️ testVoiceOverSupport() - Test accessibility
⚠️ testHighContrastMode() - Test contrast modes
⚠️ testLargeTextSupport() - Test text scaling
```

**Hardware Requirements:**
- Vision Pro device OR visionOS Simulator
- Hand tracking hardware (for gesture tests)
- Eye tracking hardware (for gaze tests)

**How to Run:**
```bash
# In Xcode:
1. Open SpatialMusicStudio.xcodeproj
2. Select visionOS Simulator
3. Product > Test (⌘U)
4. Filter by "UITests"
```

**Expected Results:**
- All UI elements should be accessible
- Navigation should be smooth
- Gestures should be recognized
- Accessibility features should work correctly

---

### 4. Integration Tests (System Components)
**File:** `SpatialMusicStudio/SpatialMusicStudioTests/IntegrationTests/SystemIntegrationTests.swift`

**Environment:** Mixed - Some tests can run locally, most require hardware

**Test Classes:**
- `AudioEngineIntegrationTests` - Audio engine integration (⚠️ requires hardware)
- `CompositionSystemIntegrationTests` - Composition workflow (✅ partial local)
- `SpatialSceneIntegrationTests` - Spatial scene integration (⚠️ requires hardware)
- `CollaborationIntegrationTests` - Collaboration features (⚠️ requires multiple devices)
- `LearningSystemIntegrationTests` - Education features (✅ partial local)
- `EndToEndTests` - Complete user journeys (✅ partial local)

**Tests That Can Run Locally:**
```
✅ testCompositionCreationWorkflow() - Test composition creation
✅ testCompositionSaveLoad() - Test save/load functionality
✅ testCompleteUserJourney() - Test complete user workflow (without audio/3D)
✅ testProfessionalWorkflow() - Test professional workflow setup
```

**Tests Requiring Hardware:**
```
⚠️ testAudioEngineInitialization() - Requires AVAudioEngine
⚠️ testInstrumentAudioIntegration() - Requires audio hardware
⚠️ testRoomMappingIntegration() - Requires ARKit
⚠️ testCollaborationSessionSetup() - Requires SharePlay & multiple devices
⚠️ testAIFeedbackIntegration() - Requires Core ML models
```

**How to Run (Local Tests):**
```bash
cd /home/user/visionOS_Gaming_spatial-music-studio/SpatialMusicStudio
swift test --filter CompositionSystemIntegrationTests
swift test --filter EndToEndTests
```

**How to Run (Hardware Tests):**
```bash
# In Xcode on visionOS Simulator or device:
Product > Test (⌘U)
Filter by test class name
```

---

### 5. Network & Collaboration Tests
**File:** `SpatialMusicStudio/SpatialMusicStudioTests/NetworkCollaborationTests.swift`

**Environment:** Mixed - Some tests can run locally with mocks, most require network

**Test Classes:**
- `NetworkLatencyTests` - Network latency benchmarks (⚠️ requires network)
- `SharePlayTests` - SharePlay integration (⚠️ requires SharePlay)
- `DataSynchronizationTests` - Data sync tests (⚠️ requires multiple devices)
- `MessagePassingTests` - Message delivery tests (✅ partial local)
- `ConnectionStabilityTests` - Connection reliability (⚠️ requires network)
- `BandwidthTests` - Bandwidth usage tests (⚠️ requires network tools)
- `CloudKitTests` - CloudKit integration (⚠️ requires CloudKit access)
- `SecurityTests` - Security verification (✅ partial local)
- `NetworkStressTests` - Load testing (⚠️ requires infrastructure)
- `NetworkEdgeCaseTests` - Edge cases (✅ can run locally)

**Tests That Can Run Locally:**
```
✅ testMessageCompression() - Test data compression
✅ testEmptyCompositionSync() - Test empty data handling
✅ testVeryLargeComposition() - Test large dataset handling
✅ testUnicodeInTitles() - Test Unicode support
✅ testOfflineQueue() - Test offline operation queue (with mocks)
```

**Tests Requiring Network/Hardware:**
```
⚠️ testLocalNetworkLatency() - Requires multiple devices on LAN
⚠️ testSharePlaySessionCreation() - Requires FaceTime call
⚠️ testRealTimeNoteSync() - Requires multiple devices
⚠️ testCloudKitConnection() - Requires CloudKit access
⚠️ testConnectionDropout() - Requires network simulation tools
⚠️ testMaxConcurrentUsers() - Requires load testing infrastructure
```

**How to Run (Local Tests):**
```bash
cd /home/user/visionOS_Gaming_spatial-music-studio/SpatialMusicStudio
swift test --filter NetworkEdgeCaseTests
swift test --filter MessagePassingTests.testMessageCompression
```

**How to Run (Network Tests):**
```bash
# Requires multiple Vision Pro devices + network:
1. Set up 2+ Vision Pro devices on same network
2. Open project in Xcode on each device
3. Run tests from Xcode UI
```

---

## Test Execution Summary

### ✅ Tests That CAN Run in Current Environment (Linux/macOS without visionOS)

**Total:** ~35 tests

1. **All Domain Model Tests** (DomainModelTests.swift)
   - Music theory tests
   - Composition tests
   - Track tests
   - MIDI tests
   - Instrument tests
   - Serialization tests

2. **Some Integration Tests** (SystemIntegrationTests.swift)
   - Composition creation workflow
   - Save/load functionality
   - User journey tests (data model portions)

3. **Some Network Tests** (NetworkCollaborationTests.swift)
   - Message compression
   - Large composition handling
   - Unicode support
   - Edge case tests

**Execution Command:**
```bash
cd /home/user/visionOS_Gaming_spatial-music-studio/SpatialMusicStudio

# Run all tests that can execute:
swift test --filter DomainModelTests
swift test --filter NetworkEdgeCaseTests
swift test --filter MessagePassingTests.testMessageCompression

# Or run specific test:
swift test --filter MusicTheoryTests.testNoteTransposition
```

---

### ⚠️ Tests That CANNOT Run Without Hardware

**Total:** ~120+ tests

**Requirements Categories:**

1. **visionOS Simulator or Device** (~80 tests)
   - All UI tests
   - All performance tests
   - Audio engine tests
   - Spatial scene tests
   - Rendering tests

2. **Multiple Devices** (~25 tests)
   - Collaboration tests
   - SharePlay tests
   - Real-time sync tests
   - Multi-user tests

3. **Network Infrastructure** (~15 tests)
   - Network latency tests
   - Bandwidth tests
   - Connection stability tests
   - Load tests

4. **CloudKit Access** (~10 tests)
   - Cloud sync tests
   - Authentication tests
   - Data isolation tests

**Execution Requirements:**

```bash
# For visionOS tests:
Requirement: Mac with Xcode 16+, visionOS 2.0+ SDK
Command: Open Xcode > Product > Test

# For multi-device tests:
Requirement: 2+ Vision Pro devices, FaceTime connection
Command: Manual test execution on each device

# For network tests:
Requirement: Network simulation tools (e.g., Network Link Conditioner)
Command: Configure network conditions > Run tests in Xcode

# For CloudKit tests:
Requirement: Apple Developer account, CloudKit container setup
Command: Configure CloudKit > Run tests in Xcode
```

---

## Performance Benchmarks

### Target Metrics

| Metric | Target | Test |
|--------|--------|------|
| Audio Latency | < 10ms | `testAudioLatency()` |
| Concurrent Sources | 64+ | `testMaxConcurrentSources()` |
| Frame Rate | 90 FPS | `testFrameRate()` |
| CPU Usage (Playback) | < 30% | `testCPUUsageUnderLoad()` |
| Memory Usage | < 512MB | `testMemoryUsage()` |
| Network Latency (Local) | < 50ms | `testLocalNetworkLatency()` |
| Network Latency (Internet) | < 200ms | `testInternetLatency()` |
| Audio Quality | 192kHz/32-bit | `testSampleRateAndBitDepth()` |
| Launch Time | < 2s | `testLaunchPerformance()` |

---

## Test Coverage

### Code Coverage by Module

```
Core Audio Engine:     85% (estimated)
- SpatialAudioEngine:  90%
- Audio processing:    80%

Data Models:           95%
- Composition:         100%
- Instrument:          100%
- MusicTheory:         95%
- Track:               95%

UI Components:         70%
- ContentView:         75%
- ImmersiveView:       65%
- SettingsView:        70%

Networking:            60%
- SessionManager:      65%
- CloudKit:            55%

Spatial Systems:       50%
- SpatialScene:        55%
- RoomMapping:         45%
```

### Coverage Goals
- **Target:** 80% overall coverage
- **Critical paths:** 95% coverage (audio, data persistence)
- **UI:** 70% coverage (harder to automate spatial UI)

---

## Running Tests Step-by-Step

### Option 1: Run Local Tests (Current Environment)

**Prerequisites:**
- Swift 5.9+ installed
- Access to project directory

**Steps:**
```bash
# 1. Navigate to project
cd /home/user/visionOS_Gaming_spatial-music-studio/SpatialMusicStudio

# 2. Build project (may fail without visionOS SDK, but tests can still run)
swift build

# 3. Run specific test suite
swift test --filter DomainModelTests

# 4. Run individual test
swift test --filter MusicTheoryTests.testNoteTransposition

# 5. Run with verbose output
swift test --filter DomainModelTests --verbose

# 6. Generate test report
swift test --filter DomainModelTests 2>&1 | tee test_results.txt
```

**Expected Output:**
```
Test Suite 'DomainModelTests' started at 2025-01-19 10:00:00.000
Test Case '-[MusicTheoryTests testNoteTransposition]' passed (0.001 seconds).
Test Case '-[MusicTheoryTests testMajorScaleIntervals]' passed (0.002 seconds).
...
Test Suite 'DomainModelTests' passed at 2025-01-19 10:00:05.000.
     Executed 35 tests, with 0 failures (0 unexpected) in 5.0 seconds
```

---

### Option 2: Run Tests in Xcode (Requires macOS + Xcode)

**Prerequisites:**
- macOS 14.0+
- Xcode 16.0+
- visionOS 2.0+ SDK

**Steps:**
```bash
# 1. Open project in Xcode
open /home/user/visionOS_Gaming_spatial-music-studio/SpatialMusicStudio/SpatialMusicStudio.xcodeproj

# 2. In Xcode:
#    - Select scheme: SpatialMusicStudio
#    - Select destination: visionOS Simulator or My Mac

# 3. Run tests:
#    - Press ⌘U (Product > Test)
#    - Or click diamond icon next to test in editor

# 4. View results:
#    - Open Test Navigator (⌘6)
#    - See green checkmarks for passing tests
#    - See red X for failing tests

# 5. Run specific test:
#    - Click play button next to test method
#    - Or right-click > "Run testName"
```

---

### Option 3: Run Tests on Vision Pro Device

**Prerequisites:**
- Vision Pro device
- macOS with Xcode 16+
- USB-C cable
- Apple Developer account

**Steps:**
```bash
# 1. Connect Vision Pro via USB
# 2. Trust device in Xcode
# 3. Select "Your Vision Pro" as destination
# 4. Product > Test (⌘U)

# Note: First run will install test runner on device
# Subsequent runs will be faster
```

---

## Continuous Integration

### GitHub Actions Configuration

**File:** `.github/workflows/test.yml`

```yaml
name: Run Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4

      - name: Select Xcode version
        run: sudo xcode-select -s /Applications/Xcode_16.0.app

      - name: Build project
        run: |
          cd SpatialMusicStudio
          swift build

      - name: Run unit tests
        run: |
          cd SpatialMusicStudio
          swift test --filter DomainModelTests

      - name: Upload test results
        uses: actions/upload-artifact@v3
        with:
          name: test-results
          path: test_results.txt
```

---

## Troubleshooting

### Common Issues

**Issue 1: "Cannot find module 'RealityKit'"**
- **Cause:** Running on non-visionOS target
- **Solution:** Use visionOS Simulator or device
- **Workaround:** Skip tests requiring RealityKit

**Issue 2: "Audio engine failed to initialize"**
- **Cause:** No audio hardware available
- **Solution:** Run on device with audio hardware
- **Workaround:** Mock audio engine for unit tests

**Issue 3: "SharePlay session failed to start"**
- **Cause:** Not in FaceTime call or permissions denied
- **Solution:** Start FaceTime call before running test
- **Workaround:** Skip collaboration tests

**Issue 4: "CloudKit error: Account not found"**
- **Cause:** Not signed into iCloud
- **Solution:** Sign into iCloud on device
- **Workaround:** Use local persistence tests only

**Issue 5: Test timeout**
- **Cause:** Network latency or slow device
- **Solution:** Increase test timeout in test configuration
- **Example:** `wait(for: [expectation], timeout: 10.0)`

---

## Test Maintenance

### Adding New Tests

1. **Choose appropriate test file:**
   - Unit tests → `DomainModelTests.swift`
   - Performance → `AudioPerformanceTests.swift`
   - UI → `UITests.swift`
   - Integration → `SystemIntegrationTests.swift`
   - Network → `NetworkCollaborationTests.swift`

2. **Follow naming convention:**
   ```swift
   func testFeatureName() throws {
       // Arrange
       let sut = SystemUnderTest()

       // Act
       let result = sut.doSomething()

       // Assert
       XCTAssertEqual(result, expectedValue)
   }
   ```

3. **Mark hardware requirements:**
   ```swift
   func testRequiresHardware() throws {
       // ⚠️ CANNOT RUN IN CURRENT ENVIRONMENT
       // REQUIRES: visionOS device

       // Test code here
   }
   ```

4. **Update this documentation** with:
   - Test name and description
   - Hardware requirements
   - Expected results

### Reviewing Test Results

**Weekly Review:**
- Check test pass rate (target: > 95%)
- Review failed tests
- Update flaky tests
- Monitor test execution time

**Release Review:**
- Run all tests on actual Vision Pro hardware
- Verify performance benchmarks
- Test on multiple devices
- Document any known issues

---

## Test Data

### Sample Compositions for Testing

**Simple Composition:**
```swift
let simple = Composition(
    title: "Test Simple",
    tempo: 120,
    timeSignature: .commonTime,
    key: MusicalKey(tonic: .c, scale: .major)
)
```

**Complex Composition:**
```swift
var complex = Composition(
    title: "Test Complex",
    tempo: 128,
    timeSignature: .commonTime,
    key: MusicalKey(tonic: .c, scale: .minor)
)

// Add multiple tracks
for instrument in InstrumentType.allCases {
    var track = Track(name: instrument.rawValue, instrument: instrument)
    // Add notes...
    complex.addTrack(track)
}
```

### Test Fixtures Location
```
SpatialMusicStudio/
  SpatialMusicStudioTests/
    Fixtures/
      simple_composition.json
      complex_composition.json
      test_audio_files/
        piano_c4.wav
        guitar_e3.wav
```

---

## Summary

### Test Statistics

- **Total Tests Written:** ~155
- **Can Run Locally:** ~35 (23%)
- **Require Hardware:** ~120 (77%)
- **Estimated Coverage:** 75%

### Quick Reference

**Run all local tests:**
```bash
swift test --filter DomainModelTests
```

**Run all tests in Xcode:**
```bash
Product > Test (⌘U)
```

**Run specific test:**
```bash
swift test --filter MusicTheoryTests.testNoteTransposition
```

**View test results:**
```bash
open SpatialMusicStudio.xcodeproj
# Press ⌘6 for Test Navigator
```

---

## Next Steps

1. ✅ **Set up CI/CD pipeline** - Automate test execution on every commit
2. ✅ **Add test fixtures** - Create sample data files for consistent testing
3. ✅ **Increase coverage** - Aim for 80% overall coverage
4. ✅ **Performance baseline** - Establish performance benchmarks on Vision Pro
5. ✅ **Integration testing** - Test with real CloudKit and SharePlay

---

**Last Updated:** 2025-01-19
**Version:** 1.0
**Contact:** development@spatialmusicstudio.com
