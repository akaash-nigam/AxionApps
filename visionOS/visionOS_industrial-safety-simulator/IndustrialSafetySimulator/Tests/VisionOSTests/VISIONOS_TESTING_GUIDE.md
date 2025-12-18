# visionOS-Specific Testing Guide

## Overview

This document outlines tests that **require Apple Vision Pro hardware** or specific visionOS features that cannot be fully tested in the simulator.

## 🔴 Hardware-Required Tests

These tests can **ONLY** be run on actual Apple Vision Pro devices.

### 1. Hand Tracking Tests

#### Test: Hand Tracking Accuracy
**Requires**: Vision Pro Hardware

```swift
@Test("Hand tracking detects pinch gesture accurately")
func testPinchGestureAccuracy() async {
    // Setup hand tracking
    let handTrackingManager = HandTrackingManager()
    await handTrackingManager.startTracking()

    // Instructions for tester:
    // 1. Perform pinch gesture with right hand
    // 2. Hold for 1 second
    // 3. Release

    // Validation:
    // - Pinch detected within 100ms
    // - No false positives
    // - Clean release detection
}
```

**Expected Results**:
- ✅ Pinch detected in < 100ms
- ✅ Pinch threshold distance < 2cm
- ✅ No ghost pinches
- ✅ Works in all lighting conditions

**Test Matrix**:
| Scenario | Expected | Priority |
|----------|----------|----------|
| Single pinch | Detected | P0 |
| Double pinch | Both detected | P1 |
| Pinch and hold | Continuous state | P0 |
| Rapid pinches | All detected | P2 |
| Weak pinch | Detects reliably | P1 |

#### Test: Hand Joint Tracking
**Requires**: Vision Pro Hardware

```swift
@Test("Hand joint positions track accurately")
func testHandJointTracking() async {
    // Test individual joint tracking
    // - Thumb tip
    // - Index finger tip
    // - Palm center
    // - Wrist

    // Validation:
    // - Smooth tracking (no jitter)
    // - Accurate positioning (< 5mm error)
    // - Consistent across hand orientations
}
```

**Expected Results**:
- ✅ Position accuracy < 5mm
- ✅ Update rate: 60 Hz minimum
- ✅ No jitter in steady hand
- ✅ Tracks in all orientations

#### Test: Equipment Manipulation
**Requires**: Vision Pro Hardware

```swift
@Test("User can pick up and manipulate equipment")
func testEquipmentManipulation() async {
    // Scenario: Pick up virtual fire extinguisher
    // 1. Reach toward object
    // 2. Pinch to grab
    // 3. Move hand to new position
    // 4. Release pinch to drop

    // Validation:
    // - Grab triggers on pinch
    // - Object follows hand smoothly
    // - Release works reliably
    // - Physics feel natural
}
```

**Expected Results**:
- ✅ Grab/release feels natural
- ✅ Object position matches hand
- ✅ No lag or stuttering
- ✅ Works with gloves (if applicable)

### 2. Eye Tracking Tests

#### Test: Gaze Targeting Accuracy
**Requires**: Vision Pro Hardware

```swift
@Test("Eye tracking accurately detects gaze targets")
func testGazeAccuracy() async {
    // Present target objects at known positions
    // Track gaze point for 2 seconds per target
    // Measure accuracy

    // Validation:
    // - Gaze accuracy < 1° visual angle
    // - Smooth gaze movement
    // - No calibration drift
}
```

**Expected Results**:
- ✅ Accuracy: < 1° visual angle
- ✅ Latency: < 20ms
- ✅ Works across full FOV
- ✅ Consistent over 30+ minute sessions

#### Test: Hazard Attention Tracking
**Requires**: Vision Pro Hardware

```swift
@Test("System detects when user looks at hazards")
func testHazardAttentionTracking() async {
    // Place hazards in training scene
    // Track if user's gaze intersects hazard volumes
    // Measure fixation duration

    // Validation:
    // - Detects gaze on hazard
    // - Calculates fixation time accurately
    // - Generates attention heatmap
}
```

**Expected Results**:
- ✅ Detects gaze intersections correctly
- ✅ Accurate fixation timing
- ✅ Heatmap generation works
- ✅ No false positives

### 3. Spatial Audio Tests

#### Test: 3D Audio Positioning
**Requires**: Vision Pro Hardware

```swift
@Test("Spatial audio positions correctly in 3D space")
func testSpatialAudioPositioning() async {
    // Place audio sources at known 3D positions
    // User identifies direction of sound

    // Test positions:
    // - Front (0°)
    // - Right (90°)
    // - Back (180°)
    // - Left (270°)
    // - Above
    // - Below

    // Validation:
    // - User can accurately identify direction
    // - Distance perception works
    // - Occlusion affects volume correctly
}
```

**Expected Results**:
- ✅ Direction accuracy: ± 15°
- ✅ Distance perception clear
- ✅ Occlusion detectable
- ✅ Head tracking updates correctly

#### Test: Emergency Alarm Spatial Audio
**Requires**: Vision Pro Hardware

```swift
@Test("Emergency alarms are audible from all positions")
func testEmergencyAlarmAudibility() async {
    // Place alarm source in scene
    // Move user position around scene
    // Measure if alarm is always audible

    // Validation:
    // - Audible from 360°
    // - Volume appropriate for urgency
    // - Not occluded by obstacles
}
```

**Expected Results**:
- ✅ Audible from all angles
- ✅ Volume > 70 dB equivalent
- ✅ Clear and recognizable
- ✅ Prioritized over other sounds

### 4. Immersion & Passthrough Tests

#### Test: Immersion Level Transitions
**Requires**: Vision Pro Hardware

```swift
@Test("Smooth transitions between immersion levels")
func testImmersionTransitions() async {
    // Test transitions:
    // - Mixed → Progressive (0% → 50%)
    // - Progressive → Full (50% → 100%)
    // - Full → Progressive (100% → 50%)
    // - Progressive → Mixed (50% → 0%)

    // Validation:
    // - Smooth visual transition (no flicker)
    // - Audio crossfades smoothly
    // - User comfort maintained
}
```

**Expected Results**:
- ✅ Transition duration: 0.5 - 1.0s
- ✅ No flicker or artifacts
- ✅ Audio crossfades smoothly
- ✅ No motion sickness induced

#### Test: Passthrough Quality
**Requires**: Vision Pro Hardware

```swift
@Test("Passthrough remains clear during training")
func testPassthroughQuality() async {
    // Run scenario in mixed reality mode
    // Monitor passthrough quality

    // Validation:
    // - Clear view of real environment
    // - No significant latency
    // - Depth perception maintained
}
```

**Expected Results**:
- ✅ Passthrough latency < 12ms
- ✅ Visual clarity acceptable
- ✅ Color reproduction good
- ✅ No distortion

### 5. Performance Tests (Hardware)

#### Test: Frame Rate Under Load
**Requires**: Vision Pro Hardware

```swift
@Test("Maintains 90 FPS in complex scenarios")
func testFrameRateComplexScenario() async {
    // Load factory floor with:
    // - 50+ entities
    // - Active particle systems (smoke, fire)
    // - Multiple animated hazards
    // - Physics simulation
    // - Spatial audio

    // Measure frame rate over 5 minutes

    // Validation:
    // - Average FPS >= 90
    // - Minimum FPS >= 72
    // - No stuttering
}
```

**Expected Results**:
- ✅ Average FPS: 90
- ✅ Min FPS: 72
- ✅ Frame time variance < 2ms
- ✅ No thermal throttling

**Test Procedure**:
1. Launch app on Vision Pro
2. Enter immersive training scenario
3. Enable FPS counter (Developer settings)
4. Run scenario for 5 minutes
5. Record FPS statistics
6. Check for thermal warnings

#### Test: Memory Usage
**Requires**: Vision Pro Hardware

```swift
@Test("Memory stays within limits during long sessions")
func testMemoryUsage() async {
    // Run training session for 30 minutes
    // Monitor memory usage

    // Validation:
    // - Memory < 2GB peak
    // - No memory leaks
    // - Smooth performance throughout
}
```

**Expected Results**:
- ✅ Peak memory: < 2GB
- ✅ Average memory: < 1.5GB
- ✅ No leaks (stable over time)
- ✅ No out-of-memory crashes

#### Test: Battery Consumption
**Requires**: Vision Pro Hardware

```swift
@Test("Battery consumption is acceptable")
func testBatteryConsumption() async {
    // Fully charge Vision Pro
    // Run continuous training for 1 hour
    // Measure battery drain

    // Validation:
    // - Battery drain < 20% per hour
    // - Consistent drain rate
    // - No sudden drops
}
```

**Expected Results**:
- ✅ Drain rate: 15-20% per hour
- ✅ 2-2.5 hours continuous use
- ✅ No thermal shutdown
- ✅ Battery indicator accurate

#### Test: Thermal Performance
**Requires**: Vision Pro Hardware

```swift
@Test("Device handles thermal load appropriately")
func testThermalPerformance() async {
    // Run intensive scenario for 30 minutes
    // Monitor device temperature
    // Check for throttling

    // Validation:
    // - No user-noticeable heat
    // - No thermal warnings
    // - Performance remains stable
}
```

**Expected Results**:
- ✅ No thermal warnings
- ✅ Performance stable
- ✅ User comfort maintained
- ✅ Automatic throttling graceful

### 6. Comfort & Ergonomics Tests

#### Test: Extended Session Comfort
**Requires**: Vision Pro Hardware + Human Testers

**Test Protocol**:
1. Recruit 10 test users
2. Each completes 30-minute training session
3. Monitor comfort levels every 5 minutes
4. Collect feedback survey

**Metrics to Track**:
- Eye strain (1-10 scale)
- Neck discomfort (1-10 scale)
- Motion sickness (1-10 scale)
- Overall comfort (1-10 scale)

**Expected Results**:
- ✅ Average eye strain: < 4/10
- ✅ Average neck discomfort: < 3/10
- ✅ Motion sickness: < 2/10
- ✅ Overall comfort: > 7/10
- ✅ 90% would use again

#### Test: Spatial Ergonomics
**Requires**: Vision Pro Hardware

```swift
@Test("UI elements positioned in comfortable viewing zones")
func testUIErgonomics() async {
    // Present UI at various positions
    // User rates comfort of each position

    // Positions to test:
    // - Centered (0°, 0°)
    // - Upper (0°, +15°)
    // - Lower (0°, -15°)
    // - Left (-30°, 0°)
    // - Right (+30°, 0°)

    // Validation:
    // - Primary UI within comfort zone
    // - No neck strain
    // - Easy to read
}
```

**Expected Results**:
- ✅ Primary UI at -10° to +5° vertical
- ✅ Within 30° horizontal arc
- ✅ Distance: 0.6m - 1.2m
- ✅ No neck strain reported

### 7. Multi-User Tests

#### Test: SharePlay Synchronization
**Requires**: 2+ Vision Pro Devices

```swift
@Test("SharePlay keeps users synchronized")
func testSharePlaySync() async {
    // Setup:
    // - User A and User B on separate Vision Pro
    // - Both join same training session

    // Test actions:
    // - User A identifies hazard
    // - User B should see it highlighted
    // - Verify latency < 200ms

    // Validation:
    // - Actions sync correctly
    // - Low latency
    // - No desync issues
}
```

**Expected Results**:
- ✅ Sync latency: < 200ms
- ✅ All users see same state
- ✅ Voice chat works clearly
- ✅ No connection drops

#### Test: Spatial Voice Chat
**Requires**: 2+ Vision Pro Devices

```swift
@Test("Spatial audio for voice chat positions correctly")
func testSpatialVoiceChat() async {
    // Users A, B, C in different positions
    // Each user speaks
    // Others identify direction of voice

    // Validation:
    // - Voice comes from correct direction
    // - Distance affects volume
    // - Clear intelligibility
}
```

**Expected Results**:
- ✅ Direction accuracy: ± 20°
- ✅ Distance perception clear
- ✅ Speech intelligibility > 95%
- ✅ No echo or artifacts

## Testing Environment Setup

### Required Hardware
- ✅ Apple Vision Pro (1-3 units for multi-user tests)
- ✅ visionOS 2.0 or later
- ✅ Adequate physical space (3m x 3m minimum)
- ✅ Good lighting (500-1000 lux)
- ✅ Wireless network (for multi-user)

### Optional Equipment
- IR camera (to verify hand tracking)
- Sound level meter
- Thermal camera
- Power meter (battery testing)

## Test Execution Checklist

### Pre-Test Setup
- [ ] Charge Vision Pro to 100%
- [ ] Clear adequate physical space
- [ ] Ensure good lighting
- [ ] Connect to stable Wi-Fi
- [ ] Clean lenses
- [ ] Calibrate eye tracking
- [ ] Adjust head strap

### During Testing
- [ ] Monitor FPS (Developer menu)
- [ ] Watch for thermal warnings
- [ ] Note any glitches or issues
- [ ] Record video (if permitted)
- [ ] Take notes on user feedback
- [ ] Log crash reports

### Post-Test
- [ ] Save test results
- [ ] Export analytics data
- [ ] Document any issues
- [ ] Clean device
- [ ] Charge for next session

## Known Simulator Limitations

### Cannot Test in Simulator
- ❌ Hand tracking (simulator has none)
- ❌ Eye tracking (simulated cursor only)
- ❌ Real spatial audio (simulated)
- ❌ Actual performance metrics
- ❌ True immersion experience
- ❌ Comfort and ergonomics
- ❌ Battery consumption
- ❌ Thermal behavior

### Can Test in Simulator
- ✅ UI layout and navigation
- ✅ Logic and data flow
- ✅ Basic 3D rendering
- ✅ Scene composition
- ✅ Accessibility features
- ✅ Network operations

## Test Reporting

### Required Information for Hardware Tests
```markdown
## Test Report: [Test Name]

**Date**: YYYY-MM-DD
**Device**: Vision Pro (Serial: XXX)
**visionOS**: X.X.X
**App Version**: X.X.X

### Environment
- Room size: X m x Y m
- Lighting: XXX lux
- Temperature: XX°C

### Results
- [ ] Test passed
- [ ] Test failed

### Metrics
- FPS: Average XX, Min XX, Max XX
- Memory: Average XX MB, Peak XX MB
- Battery: XX% drain in YY minutes

### Issues Found
1. Issue description
2. Reproduction steps
3. Screenshots/video

### Notes
Additional observations...
```

## Safety Considerations

### Tester Safety
- ⚠️ Take breaks every 20 minutes
- ⚠️ Stop if experiencing discomfort
- ⚠️ Clear hazards from physical space
- ⚠️ Have spotter for complex tests
- ⚠️ Don't test while fatigued

### Device Safety
- ⚠️ Don't overheat device
- ⚠️ Protect from physical damage
- ⚠️ Clean regularly
- ⚠️ Store properly
- ⚠️ Update to latest visionOS

## Test Schedule Recommendation

### Phase 1: Basic Functionality (Week 1)
- Hand tracking basic gestures
- Eye tracking accuracy
- UI interaction
- Scene rendering

### Phase 2: Performance (Week 2)
- Frame rate testing
- Memory profiling
- Battery testing
- Thermal testing

### Phase 3: User Experience (Week 3)
- Comfort testing
- Ergonomics validation
- Extended session testing
- User feedback collection

### Phase 4: Advanced Features (Week 4)
- Multi-user testing
- SharePlay validation
- Complex scenarios
- Edge cases

## Success Criteria

For production release, all P0 (critical) tests must pass with:
- ✅ 100% pass rate
- ✅ No critical bugs
- ✅ Performance within targets
- ✅ Positive user feedback (> 80% satisfaction)

---

## Summary

These visionOS-specific tests require actual Apple Vision Pro hardware and cannot be simulated. They are critical for production readiness and must be executed before release.

**Estimated Testing Time**: 40-60 hours
**Required Resources**: 1-3 Vision Pro devices, dedicated testing space, 2-3 testers
**Cost**: Hardware investment + tester time

All tests should be documented, recorded, and results stored for regulatory compliance and future reference.
