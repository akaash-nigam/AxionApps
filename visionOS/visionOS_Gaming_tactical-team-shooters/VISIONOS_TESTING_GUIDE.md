# visionOS-Specific Testing Guide

This document details all tests that require Apple Vision Pro hardware or visionOS simulator to execute.

## Overview

**Total visionOS-Specific Tests:** ~30 test categories
**Estimated Test Time:** 40-60 hours
**Required Equipment:** Apple Vision Pro + Xcode 16+ with visionOS 2.0+ SDK

---

## Test Categories

### 1. ARKit Integration Tests
### 2. RealityKit Performance Tests
### 3. Hand Tracking Tests
### 4. Eye Tracking Tests
### 5. Spatial Audio Tests
### 6. Room Mapping Tests
### 7. Immersive Space Tests
### 8. UI/UX Tests
### 9. Comfort & Safety Tests
### 10. End-to-End Gameplay Tests

---

## 1. ARKit Integration Tests

**Location:** `TacticalTeamShooters/Tests/visionOS/ARKitTests.swift`

### ARKit Session Tests

```swift
@available(visionOS 2.0, *)
final class ARKitSessionTests: XCTestCase {

    var arSession: ARKitSession!
    var worldTracking: WorldTrackingProvider!

    override func setUp() async throws {
        arSession = ARKitSession()
        worldTracking = WorldTrackingProvider()
    }

    override func tearDown() async throws {
        arSession.stop()
    }

    // REQUIRED: Vision Pro Hardware
    func testARSessionInitialization() async throws {
        XCTAssertNotNil(arSession)
    }

    // REQUIRED: Vision Pro Hardware
    func testARSessionStart() async throws {
        do {
            try await arSession.run([worldTracking])
            // Session should start successfully
        } catch {
            XCTFail("ARKit session failed to start: \(error)")
        }
    }

    // REQUIRED: Vision Pro Hardware
    func testWorldTrackingProvider() async throws {
        try await arSession.run([worldTracking])

        // Test device anchor tracking
        let deviceAnchor = worldTracking.queryDeviceAnchor(atTimestamp: CACurrentMediaTime())
        XCTAssertNotNil(deviceAnchor)
    }
}
```

### Scene Reconstruction Tests

```swift
// REQUIRED: Vision Pro Hardware
func testSceneReconstructionStart() async throws {
    let sceneReconstruction = SceneReconstructionProvider()

    try await arSession.run([sceneReconstruction])

    // Verify scene reconstruction is running
}

// REQUIRED: Vision Pro Hardware
func testRoomMeshGeneration() async throws {
    let sceneReconstruction = SceneReconstructionProvider()
    try await arSession.run([sceneReconstruction])

    // Wait for mesh generation
    try await Task.sleep(for: .seconds(5))

    // Verify mesh anchors are created
    // Test furniture detection
    // Check mesh quality
}
```

---

## 2. RealityKit Performance Tests

**Location:** `TacticalTeamShooters/Tests/visionOS/RealityKitTests.swift`

### Entity Performance Tests

```swift
// REQUIRED: Vision Pro Hardware
func testEntityCreationPerformance() {
    measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
        var entities: [ModelEntity] = []

        for _ in 0..<100 {
            let entity = ModelEntity(
                mesh: .generateBox(size: 0.1),
                materials: [SimpleMaterial(color: .white, isMetallic: false)]
            )
            entities.append(entity)
        }

        // Should create 100 entities quickly
    }
}

// REQUIRED: Vision Pro Hardware
func testPhysicsSimulationPerformance() {
    let scene = Scene()

    measure(metrics: [XCTCPUMetric(), XCTClockMetric()]) {
        // Create 50 physics bodies
        for _ in 0..<50 {
            let entity = ModelEntity(
                mesh: .generateSphere(radius: 0.05),
                materials: [SimpleMaterial()]
            )
            entity.components[PhysicsBodyComponent.self] = PhysicsBodyComponent(
                massProperties: .default,
                mode: .dynamic
            )
            scene.addAnchor(entity)
        }

        // Simulate for 1 second
        // Should maintain 120 FPS
    }
}
```

### Frame Rate Tests

```swift
// REQUIRED: Vision Pro Hardware
func testGameSceneFrameRate() async throws {
    let gameScene = GameScene()

    // Measure frame rate during active gameplay
    var frameCount = 0
    let startTime = CACurrentMediaTime()
    let duration: TimeInterval = 10.0 // 10 seconds

    while CACurrentMediaTime() - startTime < duration {
        gameScene.update(deltaTime: 1.0 / 120.0)
        frameCount += 1
    }

    let fps = Double(frameCount) / duration

    // Should achieve 120 FPS target
    XCTAssertGreaterThanOrEqual(fps, 90.0, "Frame rate below minimum 90 FPS")
    print("Average FPS: \(fps)")
}
```

---

## 3. Hand Tracking Tests

**Location:** `TacticalTeamShooters/Tests/visionOS/HandTrackingTests.swift`

### Hand Detection Tests

```swift
// REQUIRED: Vision Pro Hardware + User Hands
func testHandTrackingInitialization() async throws {
    let handTracking = HandTrackingProvider()

    try await arSession.run([handTracking])

    // Verify hand tracking is active
}

// REQUIRED: Vision Pro Hardware + User Hands
func testBothHandsDetected() async throws {
    let handTracking = HandTrackingProvider()
    try await arSession.run([handTracking])

    // Wait for hands to be detected
    try await Task.sleep(for: .seconds(2))

    // Test both hands are tracked
    // This requires user to have hands visible
}
```

### Gesture Recognition Tests

```swift
// REQUIRED: Vision Pro Hardware + User performing gestures
func testPinchGestureDetection() async throws {
    let weaponControl = WeaponControlSystem()

    // User performs pinch gesture
    // Verify trigger pull detected
    // Check gesture accuracy
}

// REQUIRED: Vision Pro Hardware + User performing gestures
func testReloadGestureDetection() async throws {
    let weaponControl = WeaponControlSystem()

    // User brings hands together
    // Verify reload gesture detected
    // Check gesture timing
}
```

### Weapon Control Tests

```swift
// REQUIRED: Vision Pro Hardware + User holding virtual weapon
func testTwoHandedWeaponGrip() async throws {
    let weaponControl = WeaponControlSystem()

    // User grips virtual weapon with both hands
    // Verify grip stability
    // Check aim precision
    // Test recoil simulation
}

// REQUIRED: Vision Pro Hardware
func testAimPrecision() async throws {
    let weaponControl = WeaponControlSystem()

    // Measure aim jitter
    // Should achieve sub-millimeter accuracy
    XCTAssertLessThan(aimJitter, 0.001) // < 1mm
}
```

---

## 4. Eye Tracking Tests

**Location:** `TacticalTeamShooters/Tests/visionOS/EyeTrackingTests.swift`

### Gaze Detection Tests

```swift
// REQUIRED: Vision Pro Hardware + User gaze
func testEyeTrackingInitialization() async throws {
    let eyeTracking = EyeTrackingProvider()

    try await arSession.run([eyeTracking])

    // Verify eye tracking active
}

// REQUIRED: Vision Pro Hardware + User looking at targets
func testGazePointAccuracy() async throws {
    let tacticalAwareness = TacticalAwarenessSystem()

    // User looks at known targets
    // Measure gaze point accuracy
    // Should be within 1 degree
}

// REQUIRED: Vision Pro Hardware + User gaze patterns
func testThreatDetectionViaGaze() async throws {
    // Spawn virtual enemy
    // Track user gaze
    // Verify enemy highlighted when looked at
    // Measure detection latency
}
```

---

## 5. Spatial Audio Tests

**Location:** `TacticalTeamShooters/Tests/visionOS/SpatialAudioTests.swift`

### Audio Positioning Tests

```swift
// REQUIRED: Vision Pro Hardware + Headphones
func testSpatialAudioInitialization() {
    let audioEngine = TacticalAudioEngine()
    audioEngine.setupSpatialAudio()

    XCTAssertNotNil(audioEngine.engine)
    XCTAssertNotNil(audioEngine.environment)
}

// REQUIRED: Vision Pro Hardware + User listening
func testSoundDirectionality() async throws {
    let audioEngine = TacticalAudioEngine()

    let positions = [
        SIMD3<Float>(1, 0, 0),   // Right
        SIMD3<Float>(-1, 0, 0),  // Left
        SIMD3<Float>(0, 1, 0),   // Above
        SIMD3<Float>(0, -1, 0),  // Below
        SIMD3<Float>(0, 0, 1),   // Front
        SIMD3<Float>(0, 0, -1)   // Behind
    ]

    for position in positions {
        audioEngine.playWeaponSound(.gunshot, at: position)
        try await Task.sleep(for: .seconds(1))

        // User verifies sound comes from correct direction
    }
}

// REQUIRED: Vision Pro Hardware
func testAudioOcclusion() async throws {
    // Place sound source behind virtual wall
    // Verify volume reduction
    // Check frequency filtering
    // Confirm occlusion calculation
}
```

### Audio Distance Tests

```swift
// REQUIRED: Vision Pro Hardware
func testAudioDistanceAttenuation() {
    let audioEngine = TacticalAudioEngine()

    let distances: [Float] = [1.0, 5.0, 10.0, 25.0, 50.0, 100.0]

    for distance in distances {
        audioEngine.playWeaponSound(.gunshot, at: SIMD3<Float>(0, 0, distance))

        // Verify volume decreases with distance
        // Check follows inverse square law
    }
}
```

---

## 6. Room Mapping Tests

**Location:** `TacticalTeamShooters/Tests/visionOS/RoomMappingTests.swift`

### Room Scanning Tests

```swift
// REQUIRED: Vision Pro Hardware + Physical Room
func testRoomScanInitiation() async throws {
    let roomMapping = RoomMappingSystem()

    let meshAnchors = await roomMapping.scanRoom()

    XCTAssertNotNil(meshAnchors)
    XCTAssertFalse(meshAnchors!.isEmpty)
}

// REQUIRED: Vision Pro Hardware + Furniture
func testFurnitureDetection() async throws {
    let roomMapping = RoomMappingSystem()

    let tacticalPositions = await roomMapping.analyzeTacticalPositions()

    // Verify furniture detected
    XCTAssertFalse(tacticalPositions.isEmpty)

    // Check cover positions identified
    let coverPositions = tacticalPositions.filter { $0.type != .none }
    XCTAssertGreaterThan(coverPositions.count, 0)
}

// REQUIRED: Vision Pro Hardware + Different room sizes
func testRoomSizeAdaptation() async throws {
    let roomSizes = ["small", "medium", "large"]

    for size in roomSizes {
        // Test in different room sizes
        // Verify gameplay scales appropriately
        // Check boundary management
    }
}
```

### Cover System Tests

```swift
// REQUIRED: Vision Pro Hardware + Physical objects
func testCoverDetection() async throws {
    let coverSystem = CoverSystem()

    // Scan room with tables, chairs, walls
    let coverPoints = coverSystem.generateCoverPoints(from: roomMesh)

    // Verify cover points at furniture locations
    XCTAssertGreaterThan(coverPoints.count, 0)

    // Check cover quality ratings
    for coverPoint in coverPoints {
        XCTAssertNotEqual(coverPoint.quality, .none)
    }
}
```

---

## 7. Immersive Space Tests

**Location:** `TacticalTeamShooters/Tests/visionOS/ImmersiveSpaceTests.swift`

### Space Transition Tests

```swift
// REQUIRED: Vision Pro Hardware
func testImmersiveSpaceOpen() async throws {
    let app = TacticalTeamShootersApp()

    // Open immersive space
    // Verify successful transition
    // Check rendering active
}

// REQUIRED: Vision Pro Hardware
func testImmersiveSpaceClose() async throws {
    // Close immersive space
    // Verify clean shutdown
    // Check resources released
}

// REQUIRED: Vision Pro Hardware
func testProgressiveImmersion() async throws {
    // Test progressive immersion levels
    // Verify smooth transitions
    // Check user comfort
}
```

---

## 8. UI/UX Tests

**Location:** `TacticalTeamShooters/Tests/visionOS/UITests.swift`

### Menu Navigation Tests

```swift
// REQUIRED: Vision Pro Hardware
func testMainMenuNavigation() async throws {
    // Launch app
    // Navigate through menus
    // Verify all buttons responsive
    // Check spatial layout
}

// REQUIRED: Vision Pro Hardware
func testHUDVisibility() async throws {
    // Enter game
    // Verify HUD elements visible
    // Check readability
    // Test different lighting conditions
}
```

### Ornament Tests

```swift
// REQUIRED: Vision Pro Hardware
func testOrnamentPlacement() async throws {
    // Verify ornaments positioned correctly
    // Check they follow windows
    // Test in different positions
}
```

---

## 9. Comfort & Safety Tests

**Location:** `TacticalTeamShooters/Tests/visionOS/ComfortTests.swift`

### Motion Sickness Prevention

```swift
// REQUIRED: Vision Pro Hardware + Multiple Testers
func testComfortDuringGameplay() async throws {
    // Extended gameplay session (30 minutes)
    // Monitor user comfort
    // Check for motion sickness symptoms
    // Verify comfort ratings > 4/5
}

// REQUIRED: Vision Pro Hardware
func testSafetyBoundaries() async throws {
    // Test boundary visualization
    // Verify warnings when approaching boundaries
    // Check collision prevention
}
```

### Fatigue Tests

```swift
// REQUIRED: Vision Pro Hardware + Long Session
func testExtendedPlaySession() async throws {
    // 2-hour gameplay session
    // Monitor eye strain
    // Check physical fatigue
    // Verify break reminders
}
```

---

## 10. End-to-End Gameplay Tests

**Location:** `TacticalTeamShooters/Tests/E2E/GameplayE2ETests.swift`

### Complete Match Flow

```swift
// REQUIRED: Vision Pro Hardware + 30-45 minutes
func testCompleteCompetitiveMatch() async throws {
    // 1. Launch app
    // 2. Navigate to Competitive mode
    // 3. Find match (matchmaking)
    // 4. Complete 5v5 match
    // 5. Verify stats updated
    // 6. Check rank progression

    XCTAssertTrue(matchCompleted)
    XCTAssertNotNil(updatedStats)
    XCTAssertNotNil(rankChange)
}
```

### Training Mode Tests

```swift
// REQUIRED: Vision Pro Hardware + 20 minutes
func testTrainingScenarioCompletion() async throws {
    // 1. Enter training mode
    // 2. Complete aim training
    // 3. Complete tactical scenario
    // 4. Verify certification progress
}
```

### Multiplayer Tests

```swift
// REQUIRED: 2+ Vision Pro devices
func testMultiplayerMatch() async throws {
    // 1. Two players join same match
    // 2. Play 10-minute match
    // 3. Verify synchronization
    // 4. Check voice chat quality
    // 5. Confirm no desync issues
}
```

---

## Running visionOS Tests

### Prerequisites

1. **Hardware:**
   - Apple Vision Pro (required)
   - macOS Sonoma 14.0+
   - Xcode 16.0+

2. **Software:**
   - visionOS 2.0+ SDK
   - Valid Apple Developer account

3. **Environment:**
   - Physical room with furniture (for room mapping tests)
   - Good lighting conditions
   - Clear play space (8x8 feet minimum)

### Setup Instructions

#### 1. Connect Vision Pro

```bash
# Ensure Vision Pro is on same network
# Enable Developer Mode on Vision Pro:
Settings → Privacy & Security → Developer Mode → ON
```

#### 2. Configure Xcode

```bash
# Open project in Xcode
xcodebuild -project TacticalTeamShooters.xcodeproj \
           -scheme TacticalTeamShooters \
           -destination 'platform=visionOS,name=Apple Vision Pro'
```

#### 3. Run Tests

```bash
# Run all visionOS tests
xcodebuild test \
  -project TacticalTeamShooters.xcodeproj \
  -scheme TacticalTeamShooters \
  -destination 'platform=visionOS,name=Apple Vision Pro' \
  -only-testing:TacticalTeamShootersTests/visionOS
```

#### 4. Run Specific Test Suites

```bash
# ARKit tests only
xcodebuild test -only-testing:TacticalTeamShootersTests/ARKitTests

# Hand tracking tests only
xcodebuild test -only-testing:TacticalTeamShootersTests/HandTrackingTests

# Spatial audio tests only
xcodebuild test -only-testing:TacticalTeamShootersTests/SpatialAudioTests
```

---

## Test Execution Checklist

### Pre-Test Checklist
- [ ] Vision Pro fully charged
- [ ] Developer mode enabled
- [ ] Room scanned and mapped
- [ ] Good lighting conditions
- [ ] Clear play space
- [ ] Xcode connected to device

### ARKit Tests (2-3 hours)
- [ ] AR session initialization
- [ ] World tracking
- [ ] Scene reconstruction
- [ ] Room mesh generation
- [ ] Spatial anchors

### Hand Tracking Tests (1-2 hours)
- [ ] Hand detection
- [ ] Gesture recognition
- [ ] Weapon control
- [ ] Aim precision
- [ ] Two-handed grip

### Eye Tracking Tests (1 hour)
- [ ] Gaze detection
- [ ] Threat awareness
- [ ] UI interaction
- [ ] Calibration

### Spatial Audio Tests (1-2 hours)
- [ ] 3D positioning
- [ ] Distance attenuation
- [ ] Occlusion
- [ ] Directionality

### Room Mapping Tests (2-3 hours)
- [ ] Room scanning
- [ ] Furniture detection
- [ ] Cover identification
- [ ] Size adaptation

### Performance Tests (2-3 hours)
- [ ] Frame rate (120 FPS)
- [ ] Memory usage
- [ ] Battery life
- [ ] Thermal performance

### Gameplay Tests (4-6 hours)
- [ ] Complete matches
- [ ] Training modes
- [ ] Multiplayer sessions
- [ ] Progression tracking

### Comfort Tests (4-6 hours)
- [ ] Extended sessions
- [ ] Motion sickness check
- [ ] Eye strain monitoring
- [ ] Physical fatigue

### Total Estimated Time: 40-60 hours

---

## Known Limitations

### Simulator Limitations
The visionOS simulator **cannot** test:
- Hand tracking
- Eye tracking
- Actual spatial audio (can test code only)
- Room mapping
- Real performance metrics
- Comfort/safety

### Hardware-Only Tests
These tests **require** physical Vision Pro:
- All ARKit integration tests
- All hand tracking tests
- All eye tracking tests
- Spatial audio quality tests
- Room mapping tests
- Performance benchmarks
- Comfort validation

---

## Debugging Tips

### ARKit Issues
```swift
// Enable ARKit logging
import os
let logger = Logger(subsystem: "com.tactical.shooters", category: "ARKit")
logger.debug("ARKit state: \(arSession.state)")
```

### Hand Tracking Issues
```swift
// Check hand tracking availability
if !HandTrackingProvider.isSupported {
    print("Hand tracking not supported")
}
```

### Performance Issues
```swift
// Use Instruments for profiling
// Xcode → Product → Profile
// Select "Time Profiler" or "Allocations"
```

---

## Reporting Test Results

### Test Report Format

```markdown
## visionOS Test Results

**Date:** YYYY-MM-DD
**Device:** Apple Vision Pro
**visionOS:** X.X.X
**Tester:** Name

### Summary
- Total Tests: XXX
- Passed: XXX
- Failed: XXX
- Skipped: XXX

### Failed Tests
1. Test Name: Description of failure
2. ...

### Performance Metrics
- Average FPS: XXX
- Memory Usage: XXX MB
- Battery Drain: XX% per hour

### Notes
- Any observations
- Recommendations
```

---

## Continuous Integration

visionOS tests **cannot** run in CI/CD pipelines due to hardware requirements.

**Recommendation:** Manual testing schedule:
- **Daily:** Simulator-compatible tests
- **Weekly:** Critical visionOS tests on hardware
- **Before Release:** Full visionOS test suite

---

This guide ensures comprehensive testing of all visionOS-specific features before production release.
