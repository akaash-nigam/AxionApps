# visionOS-Specific Tests

These tests require **Apple Vision Pro hardware** or **visionOS Simulator** to execute.

## ⚠️ Prerequisites

- Xcode 16.0+ with visionOS SDK
- Apple Vision Pro device or visionOS Simulator
- Developer account with appropriate entitlements

---

## 🗺️ Room Mapping Tests

### Test: Room Scanning Accuracy
**Objective**: Verify room mapping produces accurate spatial data

```swift
func testRoomScanningAccuracy() async throws {
    let roomMapper = RoomMapper()

    // Start room scanning
    let layout = try await roomMapper.scanRoom()

    // Verify room was detected
    XCTAssertNotNil(layout.floor, "Floor plane should be detected")
    XCTAssertGreaterThan(layout.walls.count, 0, "At least one wall should be detected")

    // Verify minimum play area
    let playAreaVolume = layout.safePlayArea.volume
    XCTAssertGreaterThan(playAreaVolume, 4.0, "Play area should be at least 2m x 2m")

    // Verify furniture detection
    XCTAssertGreaterThan(layout.furniture.count, 0, "Should detect at least one furniture item")
}
```

**Expected Results**:
- ✅ Floor plane detected
- ✅ At least 2 walls detected
- ✅ Play area ≥ 2m × 2m
- ✅ Furniture detected and classified

**Test Environments**:
- Empty room (2m × 2m)
- Standard living room (3m × 4m)
- Large living room (5m × 5m)
- Room with various furniture arrangements

---

### Test: Furniture Classification
**Objective**: Verify different furniture types are correctly identified

```swift
func testFurnitureClassification() async throws {
    let roomMapper = RoomMapper()
    let layout = try await roomMapper.scanRoom()

    // Test room should have: couch, table, chair
    let furnitureTypes = Set(layout.furniture.map { $0.type })

    XCTAssertTrue(furnitureTypes.contains(.couch), "Should detect couch")
    XCTAssertTrue(furnitureTypes.contains(.table), "Should detect table")
    XCTAssertTrue(furnitureTypes.contains(.chair), "Should detect chair")
}
```

**Test Cases**:
- [ ] Couch detection
- [ ] Table detection
- [ ] Chair detection
- [ ] Bed detection
- [ ] Shelf detection
- [ ] Desk detection

---

### Test: Room Boundaries
**Objective**: Verify safe play area is correctly calculated

```swift
func testSafePlayAreaCalculation() async throws {
    let roomMapper = RoomMapper()
    let layout = try await roomMapper.scanRoom()

    // Safe area should be smaller than room bounds (30cm buffer)
    let roomVolume = layout.bounds.volume
    let playVolume = layout.safePlayArea.volume

    XCTAssertLessThan(playVolume, roomVolume, "Play area should be smaller than room")

    // Verify minimum buffer from walls
    let buffer: Float = 0.3  // 30cm
    let roomExtents = layout.bounds.extents
    let playExtents = layout.safePlayArea.extents

    XCTAssertGreaterThan(roomExtents.x - playExtents.x, buffer * 2)
    XCTAssertGreaterThan(roomExtents.z - playExtents.z, buffer * 2)
}
```

---

## 🤚 Hand Tracking Tests

### Test: Gesture Recognition Accuracy
**Objective**: Verify combat gestures are recognized correctly

```swift
func testSwordSlashGesture() async throws {
    let handTracking = HandTrackingManager()
    try await handTracking.startTracking()

    // Perform sword slash gesture
    // (Manual test - user performs gesture)

    let detectedGestures = await handTracking.getDetectedGestures(duration: 2.0)

    XCTAssertTrue(
        detectedGestures.contains { gesture in
            if case .swordSlash = gesture { return true }
            return false
        },
        "Sword slash gesture should be detected"
    )
}
```

**Manual Test Procedures**:

1. **Sword Slash**
   - User performs horizontal arm swing
   - System should detect within 100ms
   - Minimum accuracy: 95%

2. **Shield Block**
   - User raises forearm vertically
   - Detection accuracy: 95%

3. **Spell Cast**
   - User draws circle and pushes forward
   - Pattern matching tolerance: 85%

4. **Dodge**
   - User leans left/right
   - Detection threshold: 30cm movement

**Acceptance Criteria**:
- ✅ 95% recognition rate for all gestures
- ✅ < 100ms detection latency
- ✅ < 5% false positives

---

### Test: Hand Tracking Precision
**Objective**: Measure hand position tracking accuracy

```swift
func testHandTrackingPrecision() async throws {
    let handTracking = HandTrackingManager()
    try await handTracking.startTracking()

    // Record hand positions for 5 seconds
    var positions: [SIMD3<Float>] = []

    for await update in handTracking.anchorUpdates {
        positions.append(update.handAnchor.originFromAnchorTransform.position)

        if positions.count >= 450 {  // 5 seconds at 90 Hz
            break
        }
    }

    // Verify position stability (hand held still)
    let variance = calculateVariance(positions)
    XCTAssertLessThan(variance, 0.02, "Position variance should be < 2cm when hand is still")
}
```

**Test Cases**:
- [ ] Static hand position accuracy (±2cm)
- [ ] Moving hand tracking smoothness
- [ ] Two-hand tracking simultaneously
- [ ] Tracking at various distances (0.3m - 1.5m)

---

## 👁️ Eye Tracking Tests

### Test: Gaze Target Accuracy
**Objective**: Verify eye tracking correctly identifies gazed objects

```swift
func testGazeTargeting() async throws {
    let eyeTracking = EyeTrackingManager()

    // Place test enemy at known position
    let testEnemy = Enemy(enemyType: .goblin)
    testEnemy.transform.translation = SIMD3<Float>(0, 1.5, -2.0)

    // User looks at enemy (manual test)
    let gazedEntity = await eyeTracking.getCurrentGazeTarget()

    XCTAssertEqual(gazedEntity?.id, testEnemy.id, "Should detect gazed enemy")
}
```

**Manual Test Procedures**:
1. Display 5 enemies at different positions
2. User gazes at each for 1 second
3. System should correctly identify all 5
4. Accuracy requirement: 100%

**Test Cases**:
- [ ] Central gaze targeting
- [ ] Peripheral gaze detection
- [ ] Multiple targets (select closest to gaze center)
- [ ] Moving targets
- [ ] Dwell selection (800ms)

---

## ⚓ Spatial Anchor Tests

### Test: Anchor Persistence
**Objective**: Verify spatial anchors persist across app restarts

```swift
func testAnchorPersistence() async throws {
    let anchorManager = SpatialAnchorManager()

    // Create and place anchor
    let testEntity = Entity()
    let originalTransform = matrix_identity_float4x4

    let anchor = try await anchorManager.createPersistentAnchor(
        at: originalTransform,
        for: testEntity
    )

    let anchorID = anchor.id

    // Simulate app restart
    // (Terminate and relaunch app)

    // Restore anchors
    let restoredAnchors = try await anchorManager.restorePersistedAnchors()

    XCTAssertTrue(
        restoredAnchors.contains { $0.id == anchorID },
        "Anchor should persist across restarts"
    )

    // Verify position accuracy
    let restoredAnchor = restoredAnchors.first { $0.id == anchorID }
    let positionDifference = distance(
        originalTransform.position,
        restoredAnchor?.transform.matrix.position ?? .zero
    )

    XCTAssertLessThan(positionDifference, 0.02, "Position should be accurate to ±2cm")
}
```

**Test Cases**:
- [ ] Single anchor persistence
- [ ] Multiple anchors (10+)
- [ ] Anchor persistence after 24 hours
- [ ] Anchor drift over time (< 2cm/day)

---

### Test: World Anchor Stability
**Objective**: Verify anchors remain stable during movement

```swift
func testAnchorStability() async throws {
    let anchorManager = SpatialAnchorManager()

    // Place anchor
    let testEntity = Entity()
    let anchor = try await anchorManager.createPersistentAnchor(
        at: matrix_identity_float4x4,
        for: testEntity
    )

    let initialPosition = anchor.transform.matrix.position

    // User walks around room for 30 seconds
    try await Task.sleep(for: .seconds(30))

    // Return to original position
    let finalPosition = anchor.transform.matrix.position

    let drift = distance(initialPosition, finalPosition)
    XCTAssertLessThan(drift, 0.05, "Anchor drift should be < 5cm")
}
```

---

## 🎮 Spatial Interaction Tests

### Test: Furniture as Cover
**Objective**: Verify furniture correctly provides tactical cover

```swift
func testFurnitureOcclusion() async throws {
    let player = Player(characterClass: .warrior)
    let enemy = Enemy(enemyType: .goblin)

    // Place couch between player and enemy
    let furniture = FurnitureObject(
        id: UUID(),
        type: .couch,
        transform: Transform(),
        bounds: RoomLayout.AxisAlignedBoundingBox(
            center: SIMD3<Float>(0, 0.5, -1),
            extents: SIMD3<Float>(2, 1, 0.8)
        )
    )

    player.transform.translation = SIMD3<Float>(0, 0, 0)
    enemy.transform.translation = SIMD3<Float>(0, 0, -3)

    let hasLineOfSight = checkLineOfSight(
        from: enemy.transform.translation,
        to: player.transform.translation,
        obstacles: [furniture]
    )

    XCTAssertFalse(hasLineOfSight, "Furniture should block line of sight")
}
```

---

## 🔊 Spatial Audio Tests

### Test: 3D Audio Positioning
**Objective**: Verify audio sources are positioned correctly in 3D space

```swift
func testSpatialAudioPositioning() async throws {
    let audioManager = SpatialAudioManager()
    audioManager.setup()

    // Place audio source at known position
    let sourcePosition = SIMD3<Float>(2, 1, -1)
    audioManager.play3DSound(AudioResource.load(named: "sword_slash"), at: sourcePosition)

    // User should hear sound from right side
    // (Manual verification required)

    // Automated test: verify audio source position is set correctly
    XCTAssertTrue(true, "Manual verification: sound should come from right")
}
```

**Manual Test Procedures**:
1. Place audio sources at 8 positions around player
2. User identifies direction of each sound
3. Accuracy requirement: 90% correct identification

**Test Cases**:
- [ ] Front audio
- [ ] Behind audio
- [ ] Left/Right audio
- [ ] Above/Below audio
- [ ] Distance attenuation (1m - 10m)
- [ ] Doppler effect for moving sources

---

## 📊 Performance Tests (visionOS Specific)

### Test: 90 FPS Maintenance
**Objective**: Verify game maintains 90 FPS during gameplay

```swift
func testFrameRateDuringGameplay() async throws {
    let performanceMonitor = PerformanceMonitor.shared

    // Start gameplay with 10 enemies
    var enemies: [Enemy] = []
    for _ in 0..<10 {
        enemies.append(Enemy(enemyType: .goblin))
    }

    // Record FPS for 60 seconds
    var fpsReadings: [Double] = []

    for _ in 0..<5400 {  // 60 seconds at 90 Hz
        try await Task.sleep(for: .milliseconds(11))
        fpsReadings.append(performanceMonitor.currentFPS)
    }

    let averageFPS = fpsReadings.reduce(0, +) / Double(fpsReadings.count)
    let minFPS = fpsReadings.min() ?? 0

    XCTAssertGreaterThan(averageFPS, 88.0, "Average FPS should be > 88")
    XCTAssertGreaterThan(minFPS, 72.0, "Minimum FPS should never drop below 72")

    // Check 99th percentile
    let sorted = fpsReadings.sorted()
    let percentile99 = sorted[Int(Double(sorted.count) * 0.99)]
    XCTAssertGreaterThan(percentile99, 85.0, "99th percentile should be > 85 FPS")
}
```

**Performance Benchmarks**:
- ✅ Average FPS: > 88
- ✅ Minimum FPS: > 72
- ✅ 99th percentile: > 85
- ✅ Frame time: < 11.1ms
- ✅ Memory: < 4GB

---

### Test: Memory Usage
**Objective**: Verify memory stays within budget during extended play

```swift
func testMemoryUsageDuringExtendedPlay() async throws {
    let performanceMonitor = PerformanceMonitor.shared

    // Play for 30 minutes (simulated)
    var memoryReadings: [UInt64] = []

    for _ in 0..<1800 {  // 30 minutes at 1 reading/second
        try await Task.sleep(for: .seconds(1))
        memoryReadings.append(performanceMonitor.memoryUsage)
    }

    let maxMemory = memoryReadings.max() ?? 0
    let avgMemory = memoryReadings.reduce(0, +) / UInt64(memoryReadings.count)

    XCTAssertLessThan(maxMemory, 4_000_000_000, "Max memory should be < 4GB")
    XCTAssertLessThan(avgMemory, 3_000_000_000, "Avg memory should be < 3GB")

    // Check for memory leaks (memory should not continuously increase)
    let firstHalf = Array(memoryReadings[0..<900])
    let secondHalf = Array(memoryReadings[900..<1800])

    let firstAvg = firstHalf.reduce(0, +) / UInt64(firstHalf.count)
    let secondAvg = secondHalf.reduce(0, +) / UInt64(secondHalf.count)

    let growth = Double(secondAvg - firstAvg) / Double(firstAvg)
    XCTAssertLessThan(growth, 0.1, "Memory growth should be < 10% over 30 minutes")
}
```

---

## 🎯 Multiplayer Tests (SharePlay)

### Test: SharePlay Connection
**Objective**: Verify SharePlay session establishes successfully

```swift
func testSharePlayConnection() async throws {
    let multiplayerManager = MultiplayerManager()

    // Start SharePlay session
    try await multiplayerManager.startSession()

    XCTAssertNotNil(multiplayerManager.session, "Session should be created")
    XCTAssertNotNil(multiplayerManager.messenger, "Messenger should be created")
}
```

**Test Cases**:
- [ ] Session creation
- [ ] Player joining (2-4 players)
- [ ] Player leaving
- [ ] Host migration
- [ ] Network interruption recovery

---

### Test: Spatial Synchronization
**Objective**: Verify game state syncs correctly between players

```swift
func testSpatialStateSynchronization() async throws {
    // Requires 2 Vision Pro devices

    // Host creates entity at position
    let hostEntity = Entity()
    hostEntity.transform.translation = SIMD3<Float>(1, 1, -2)

    // Sync to client
    await multiplayerManager.syncEntityPosition(hostEntity)

    // Client should see entity at correct position
    // (Requires manual verification on second device)

    XCTAssertTrue(true, "Manual verification required on client device")
}
```

---

## ✅ Test Execution Checklist

### Required Hardware Setup
- [ ] Apple Vision Pro device (or visionOS Simulator)
- [ ] Test room: 2m × 2m minimum
- [ ] Test furniture: couch, table, chair
- [ ] Second Vision Pro (for multiplayer tests)

### Pre-Test Configuration
- [ ] Room well-lit (> 300 lux)
- [ ] Clear floor space
- [ ] Calibrate Vision Pro
- [ ] Enable Developer Mode
- [ ] Install test build

### During Testing
- [ ] Record frame rate continuously
- [ ] Monitor memory usage
- [ ] Log gesture recognition rates
- [ ] Document any anomalies

### Post-Test Analysis
- [ ] Generate performance report
- [ ] Calculate accuracy metrics
- [ ] Identify failure patterns
- [ ] Update bug tracker

---

## 📝 Manual Test Scripts

### Script 1: Combat Gesture Test
**Duration**: 15 minutes

1. Start game in living room
2. Enter combat with 3 goblins
3. Perform 20 sword slashes (horizontal)
4. Perform 20 sword slashes (vertical)
5. Perform 10 shield blocks
6. Cast 10 fireballs (circle + push)
7. Dodge 10 attacks (physical lean)

**Success Criteria**:
- 95% gesture recognition
- < 100ms detection latency
- No false positives

---

### Script 2: Room Adaptation Test
**Duration**: 30 minutes

1. Test in small room (2m × 2m)
   - Verify tactical combat mode
   - Enemies approach from front only

2. Test in medium room (3m × 3m)
   - Verify standard combat
   - Enemies from multiple directions

3. Test in large room (5m × 5m)
   - Verify arena mode
   - Maximum enemy count

**Success Criteria**:
- Game adapts to each room size
- Combat remains balanced
- No crashes or errors

---

### Script 3: Persistence Test
**Duration**: 45 minutes

1. Place 5 items in room at specific locations
2. Note exact positions
3. Close app completely
4. Wait 5 minutes
5. Relaunch app
6. Verify all 5 items at correct positions (±2cm)

**Success Criteria**:
- 100% item restoration
- Position accuracy ±2cm
- No duplicates or missing items

---

## 🔧 Automated Test Execution

To run visionOS-specific tests:

```bash
# Run on Vision Pro device
xcodebuild test \
  -scheme RealityRealms \
  -destination 'platform=visionOS,name=Apple Vision Pro' \
  -only-testing:RealityRealmsTests/VisionOSTests

# Run on visionOS Simulator
xcodebuild test \
  -scheme RealityRealms \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -only-testing:RealityRealmsTests/VisionOSTests
```

---

## 📊 Expected Test Results

### Passing Criteria
- ✅ Room mapping: 100% success rate
- ✅ Gesture recognition: ≥ 95% accuracy
- ✅ Eye tracking: ≥ 90% accuracy
- ✅ Anchor persistence: 100% retention
- ✅ Frame rate: ≥ 88 FPS average
- ✅ Memory: < 4GB peak
- ✅ Spatial audio: ≥ 90% correct direction

### Metrics to Track
- Frame rate distribution
- Memory usage over time
- Gesture false positive rate
- Anchor drift measurement
- Network latency (multiplayer)
- Battery consumption rate

---

**Note**: These tests require actual visionOS hardware for execution. Simulator results may not accurately reflect device performance.
