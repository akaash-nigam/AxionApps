# visionOS Hardware-Specific Tests

This document outlines all tests that **require actual Apple Vision Pro hardware** to execute. These tests cannot be fully validated in the simulator or on macOS/Linux environments.

---

## Table of Contents

1. [ARKit Integration Tests](#arkit-integration-tests)
2. [Spatial Audio Tests](#spatial-audio-tests)
3. [Hand Tracking Tests](#hand-tracking-tests)
4. [Eye Tracking Tests](#eye-tracking-tests)
5. [Face Tracking & Emotion Recognition Tests](#face-tracking--emotion-recognition-tests)
6. [Character Spatial Behavior Tests](#character-spatial-behavior-tests)
7. [Performance & Thermal Tests](#performance--thermal-tests)
8. [User Movement & Room-Scale Tests](#user-movement--room-scale-tests)
9. [Accessibility Tests](#accessibility-tests)
10. [Multi-Session Persistence Tests](#multi-session-persistence-tests)

---

## ARKit Integration Tests

### Room Mapping & World Tracking

**Test ID**: `ARK-001`
**Name**: Room Scan Accuracy
**Requirement**: Apple Vision Pro hardware
**Procedure**:
1. Launch app in a new room (not previously scanned)
2. Allow ARKit to perform room scan
3. Verify room mesh is generated
4. Check that surfaces (floor, walls, furniture) are detected
5. Verify mesh quality and accuracy (within 5cm tolerance)

**Expected Result**: Room mesh covers >90% of visible surfaces

**Test ID**: `ARK-002`
**Name**: Anchor Placement Precision
**Requirement**: Apple Vision Pro hardware
**Procedure**:
1. Complete room scan
2. Place a character on a flat surface (table, floor)
3. Measure physical distance from reference point
4. Verify virtual placement matches physical location (±3cm)
5. Repeat for 10 different positions

**Expected Result**: 95% of placements within ±3cm accuracy

**Test ID**: `ARK-003`
**Name**: Anchor Persistence Across Sessions
**Requirement**: Apple Vision Pro hardware
**Procedure**:
1. Place character in specific location (e.g., on coffee table)
2. Note exact position coordinates
3. Close app completely
4. Re-launch app in same room
5. Verify character reappears in same location

**Expected Result**: Character repositions within ±5cm of original placement

**Test ID**: `ARK-004`
**Name**: Multi-Room Persistence
**Requirement**: Apple Vision Pro hardware, 3+ rooms
**Procedure**:
1. Place characters in 3 different rooms
2. Save positions for each room
3. Navigate between rooms
4. Verify characters persist in correct rooms
5. Close and re-launch app
6. Verify all characters remain in correct rooms

**Expected Result**: 100% of characters persist in correct rooms

---

## Spatial Audio Tests

### 3D Audio Positioning

**Test ID**: `AUD-001`
**Name**: Character Dialogue Spatial Position
**Requirement**: Apple Vision Pro hardware, spatial audio
**Procedure**:
1. Place character 2m in front of user
2. Play character dialogue
3. User reports perceived audio direction
4. Repeat with character at 90°, 180°, 270° positions
5. Repeat with character at different distances (1m, 3m, 5m)

**Expected Result**: User correctly identifies audio direction >95% of time

**Test ID**: `AUD-002`
**Name**: Head-Tracked Audio Persistence
**Requirement**: Apple Vision Pro hardware
**Procedure**:
1. Place character and start dialogue
2. User turns head left 90° (character should be on right)
3. Verify audio comes from right ear
4. User turns head right 180° (character should be on left)
5. Verify audio comes from left ear
6. User walks around character in circle
7. Verify audio direction updates correctly throughout

**Expected Result**: Audio direction matches character position within ±10°

**Test ID**: `AUD-003`
**Name**: Audio Occlusion by Physical Objects
**Requirement**: Apple Vision Pro hardware, room with furniture
**Procedure**:
1. Place character behind physical wall/furniture
2. Play character dialogue
3. Verify audio is muffled/attenuated
4. Move to direct line of sight with character
5. Verify audio is clear and unmuffled

**Expected Result**: Noticeable occlusion when object blocks direct path

**Test ID**: `AUD-004`
**Name**: Distance-Based Volume Falloff
**Requirement**: Apple Vision Pro hardware
**Procedure**:
1. Place character 1m away, play dialogue
2. Measure perceived volume (user rating 1-10)
3. Move character to 2m, 3m, 4m, 5m
4. Verify volume decreases with distance
5. Calculate falloff curve

**Expected Result**: Volume follows realistic inverse square law (±20%)

**Test ID**: `AUD-005`
**Name**: Room Reverb Adaptation
**Requirement**: Apple Vision Pro hardware, multiple room types
**Procedure**:
1. Test in small room (bathroom, closet)
2. Play dialogue, note reverb characteristics
3. Test in medium room (bedroom, office)
4. Test in large room (living room, open space)
5. Verify reverb adapts to room size

**Expected Result**: Noticeable reverb difference between room sizes

---

## Hand Tracking Tests

### Gesture Recognition

**Test ID**: `HND-001`
**Name**: Pinch Gesture Detection Accuracy
**Requirement**: Apple Vision Pro hardware
**Procedure**:
1. Display choice interface
2. User performs pinch gesture 100 times
3. Count successful detections
4. Vary pinch speed (slow, medium, fast)
5. Vary hand position (different heights, distances)

**Expected Result**: >95% detection rate across all variations

**Test ID**: `HND-002`
**Name**: Point Gesture Recognition
**Requirement**: Apple Vision Pro hardware
**Procedure**:
1. Display 10 selectable UI elements
2. User points at each element
3. Verify correct element is highlighted
4. Test from different angles and distances
5. Test with both left and right hands

**Expected Result**: >90% correct element selection

**Test ID**: `HND-003`
**Name**: Grab Gesture for Character Interaction
**Requirement**: Apple Vision Pro hardware
**Procedure**:
1. Place character in scene
2. User performs grab gesture toward character
3. Verify character responds appropriately
4. Test grab-and-hold (>2 seconds)
5. Test quick grab-release

**Expected Result**: Character responds to 95%+ of grab attempts

**Test ID**: `HND-004`
**Name**: Wave Gesture for Character Greeting
**Requirement**: Apple Vision Pro hardware
**Procedure**:
1. Start scene with character
2. User waves at character
3. Verify character acknowledges wave
4. Test different wave speeds and amplitudes
5. Test from different distances (1m, 2m, 3m)

**Expected Result**: Character acknowledges 90%+ of waves

**Test ID**: `HND-005`
**Name**: Gesture Timeout Handling
**Requirement**: Apple Vision Pro hardware
**Procedure**:
1. Display timed choice (60 second timeout)
2. User does not perform any gesture
3. Verify timeout triggers default choice
4. Test with partial gesture (start pinch, don't complete)
5. Verify partial gestures don't interfere

**Expected Result**: Timeout works reliably, no false positives from partial gestures

---

## Eye Tracking Tests

### Gaze Detection

**Test ID**: `EYE-001`
**Name**: Gaze Target Detection Accuracy
**Requirement**: Apple Vision Pro hardware
**Procedure**:
1. Display 9 UI elements in 3x3 grid
2. User looks at each element for 2 seconds
3. Verify correct element is detected as gaze target
4. Repeat 10 times for each element (90 total trials)

**Expected Result**: >90% correct gaze target detection

**Test ID**: `EYE-002`
**Name**: Dwell Time Measurement
**Requirement**: Apple Vision Pro hardware
**Procedure**:
1. Display choice interface
2. User gazes at choice for 3 seconds
3. Verify dwell time is accurately measured (±200ms)
4. Test with different dwell durations (1s, 2s, 3s, 5s)

**Expected Result**: Dwell time accuracy within ±200ms

**Test ID**: `EYE-003`
**Name**: Engagement Level from Gaze Patterns
**Requirement**: Apple Vision Pro hardware
**Procedure**:
1. Play story scene
2. Track user gaze patterns
3. User watches attentively (high engagement scenario)
4. User looks away frequently (low engagement scenario)
5. Verify engagement metrics distinguish between scenarios

**Expected Result**: >80% accuracy in classifying engagement level

**Test ID**: `EYE-004`
**Name**: Character Eye Contact Detection
**Requirement**: Apple Vision Pro hardware
**Procedure**:
1. Place character in scene
2. User looks directly at character's eyes
3. Verify system detects eye contact
4. Character should respond to eye contact
5. Test from different distances (1m, 2m, 3m)

**Expected Result**: Eye contact detected >85% of time

---

## Face Tracking & Emotion Recognition Tests

### Emotion Classification

**Test ID**: `EMO-001`
**Name**: Happy Emotion Detection
**Requirement**: Apple Vision Pro hardware
**Procedure**:
1. User smiles naturally
2. System classifies emotion
3. Verify "happy" is detected
4. Test with varying smile intensities (subtle to broad)
5. Test 50 times with different users

**Expected Result**: >80% accuracy for happy emotion

**Test ID**: `EMO-002`
**Name**: Sad Emotion Detection
**Requirement**: Apple Vision Pro hardware
**Procedure**:
1. User makes sad expression (frown, downturned mouth)
2. System classifies emotion
3. Verify "sad" is detected
4. Test 50 times with different users

**Expected Result**: >75% accuracy for sad emotion

**Test ID**: `EMO-003`
**Name**: Surprised Emotion Detection
**Requirement**: Apple Vision Pro hardware
**Procedure**:
1. User makes surprised expression (wide eyes, open mouth)
2. System classifies emotion
3. Verify "surprised" is detected
4. Test 50 times with different users

**Expected Result**: >80% accuracy for surprised emotion

**Test ID**: `EMO-004`
**Name**: Emotion Confidence Scoring
**Requirement**: Apple Vision Pro hardware
**Procedure**:
1. User makes exaggerated happy expression
2. Check confidence score (should be >0.8)
3. User makes subtle happy expression
4. Check confidence score (should be <0.6)
5. Verify confidence correlates with expression intensity

**Expected Result**: Confidence score reflects expression clarity

**Test ID**: `EMO-005`
**Name**: Real-Time Emotion Adaptation
**Requirement**: Apple Vision Pro hardware
**Procedure**:
1. Play story scene
2. User displays confused expression
3. Verify story director adjusts pacing/provides clarification
4. User displays happy expression
5. Verify story maintains current pacing

**Expected Result**: Story adapts to user emotions >70% of time

**Test ID**: `EMO-006`
**Name**: ARKit Blend Shape Capture Rate
**Requirement**: Apple Vision Pro hardware
**Procedure**:
1. Monitor face tracking frame rate
2. Verify face anchor updates are received
3. Check blend shape update rate
4. Ensure minimum 60 Hz update rate

**Expected Result**: Face tracking maintains ≥60 Hz consistently

---

## Character Spatial Behavior Tests

### Navigation & Placement

**Test ID**: `CHR-001`
**Name**: Character Walking on Real Surfaces
**Requirement**: Apple Vision Pro hardware
**Procedure**:
1. Place character on floor
2. Command character to walk to different location
3. Verify character path stays on floor mesh
4. Repeat with table, counter, other surfaces
5. Verify character adapts height to surface

**Expected Result**: Character stays on surfaces 100% of time

**Test ID**: `CHR-002`
**Name**: Obstacle Avoidance
**Requirement**: Apple Vision Pro hardware, furniture
**Procedure**:
1. Place character on one side of room
2. Command character to walk to opposite side
3. Verify character navigates around furniture
4. Character should not walk through walls
5. Test with different room layouts

**Expected Result**: Character avoids obstacles >90% of time

**Test ID**: `CHR-003`
**Name**: Character Scale Perception
**Requirement**: Apple Vision Pro hardware
**Procedure**:
1. Place character in scene at defined height (1.65m)
2. User stands next to character
3. Verify character appears life-sized
4. Take photo and measure perceived height
5. Test in different lighting conditions

**Expected Result**: Character appears within ±5% of target height

**Test ID**: `CHR-004`
**Name**: Lighting Adaptation
**Requirement**: Apple Vision Pro hardware, controllable lighting
**Procedure**:
1. Place character in bright room
2. Verify character rendering adapts to lighting
3. Dim lights, verify character darkens appropriately
4. Turn on colored lights, verify character tone adapts

**Expected Result**: Character lighting matches environment

**Test ID**: `CHR-005`
**Name**: Multiple Characters - Spatial Awareness
**Requirement**: Apple Vision Pro hardware
**Procedure**:
1. Place 3 characters in scene
2. Verify characters maintain realistic distances (1-2m apart)
3. Characters should not overlap or intersect
4. Test conversation scenario with turn-taking
5. Verify characters face each other appropriately

**Expected Result**: Characters maintain proper spatial relationships

---

## Performance & Thermal Tests

### Frame Rate Tests

**Test ID**: `PERF-001`
**Name**: Sustained 90 FPS During Dialogue
**Requirement**: Apple Vision Pro hardware
**Procedure**:
1. Start dialogue scene with 1 character
2. Monitor frame rate for 5 minutes
3. Verify frame rate stays ≥90 FPS
4. Record any drops below 90 FPS

**Expected Result**: Frame rate ≥90 FPS for >95% of frames

**Test ID**: `PERF-002`
**Name**: Frame Rate with Multiple Characters
**Requirement**: Apple Vision Pro hardware
**Procedure**:
1. Load scene with 3 characters
2. Monitor frame rate during dialogue
3. Verify frame rate stays ≥90 FPS
4. Test with characters moving simultaneously

**Expected Result**: Frame rate ≥90 FPS with up to 3 characters

**Test ID**: `PERF-003`
**Name**: Frame Time Consistency
**Requirement**: Apple Vision Pro hardware
**Procedure**:
1. Monitor frame time during 10-minute session
2. Calculate frame time variance
3. Verify frame times are consistent (<2ms variance)

**Expected Result**: Frame time variance <2ms (smooth experience)

### Memory Tests

**Test ID**: `PERF-004`
**Name**: Memory Usage During Long Session
**Requirement**: Apple Vision Pro hardware
**Procedure**:
1. Launch app and start story
2. Play for 2 hours continuously
3. Monitor memory usage every 5 minutes
4. Verify no memory leaks (steady or decreasing usage)

**Expected Result**: Memory usage <1.5 GB, no leaks

**Test ID**: `PERF-005`
**Name**: Memory Usage with Asset Loading
**Requirement**: Apple Vision Pro hardware
**Procedure**:
1. Monitor baseline memory
2. Load character with audio assets
3. Check memory increase
4. Unload character
5. Verify memory returns to baseline

**Expected Result**: Memory properly released after asset unload

### Thermal Tests

**Test ID**: `PERF-006`
**Name**: Thermal Rise During Intensive AI Processing
**Requirement**: Apple Vision Pro hardware, thermal sensor
**Procedure**:
1. Measure baseline device temperature
2. Run intensive AI processing (emotion recognition + dialogue generation)
3. Monitor temperature every minute for 30 minutes
4. Record peak temperature

**Expected Result**: Temperature rise <15°C from baseline

**Test ID**: `PERF-007`
**Name**: Quality Degradation Response to Thermal State
**Requirement**: Apple Vision Pro hardware
**Procedure**:
1. Trigger thermal throttling (intensive processing)
2. Verify app reduces quality (lower LOD, fewer effects)
3. Verify frame rate maintained
4. Allow device to cool
5. Verify quality returns to normal

**Expected Result**: App reduces quality to maintain performance

**Test ID**: `PERF-008`
**Name**: Battery Impact - 2 Hour Session
**Requirement**: Apple Vision Pro hardware, fully charged
**Procedure**:
1. Start with 100% battery
2. Play story for 2 hours continuously
3. Monitor battery drain
4. Record final battery percentage

**Expected Result**: Battery drain <60% for 2-hour session

---

## User Movement & Room-Scale Tests

### Physical Movement

**Test ID**: `MOV-001`
**Name**: Walking Around Characters
**Requirement**: Apple Vision Pro hardware, open space
**Procedure**:
1. Place character in center of room
2. User walks 360° around character
3. Verify character remains anchored in space
4. Verify character gaze follows user
5. Dialogue should continue uninterrupted

**Expected Result**: Character tracking stable during user movement

**Test ID**: `MOV-002`
**Name**: Viewing Characters from Different Angles
**Requirement**: Apple Vision Pro hardware
**Procedure**:
1. Place character in scene
2. View character from front (0°)
3. View from side (90°)
4. View from behind (180°)
5. Verify character rendering is correct from all angles

**Expected Result**: Character appears correctly from all viewpoints

**Test ID**: `MOV-003`
**Name**: Seated to Standing Transition
**Requirement**: Apple Vision Pro hardware
**Procedure**:
1. Start app while seated
2. Begin story scene
3. Stand up during scene
4. Verify character positions adjust appropriately
5. Verify UI remains accessible

**Expected Result**: Smooth transition, no broken interactions

**Test ID**: `MOV-004`
**Name**: Multi-Room Navigation
**Requirement**: Apple Vision Pro hardware, 2+ rooms
**Procedure**:
1. Start scene in Room A with Character 1
2. Walk to Room B
3. Verify Character 1 does not follow
4. Interact with Character 2 in Room B
5. Return to Room A
6. Verify Character 1 still present and remembers conversation

**Expected Result**: Room-specific character persistence works correctly

---

## Accessibility Tests

### VoiceOver Integration

**Test ID**: `ACC-001`
**Name**: VoiceOver Dialogue Navigation
**Requirement**: Apple Vision Pro hardware, VoiceOver enabled
**Procedure**:
1. Enable VoiceOver
2. Start story scene
3. Navigate dialogue with VoiceOver gestures
4. Verify all dialogue is read aloud
5. Verify character names are announced

**Expected Result**: 100% of dialogue accessible via VoiceOver

**Test ID**: `ACC-002`
**Name**: VoiceOver Choice Selection
**Requirement**: Apple Vision Pro hardware, VoiceOver enabled
**Procedure**:
1. Enable VoiceOver
2. Navigate to choice interface
3. Use VoiceOver to navigate between choices
4. Select choice using VoiceOver gesture
5. Verify choice is registered correctly

**Expected Result**: All choices selectable via VoiceOver

**Test ID**: `ACC-003`
**Name**: Reduced Motion Mode
**Requirement**: Apple Vision Pro hardware, Reduce Motion enabled
**Procedure**:
1. Enable Reduce Motion in settings
2. Launch app
3. Verify animations are simplified/disabled
4. Verify core functionality remains intact
5. Test choice transitions, character movement

**Expected Result**: App respects Reduce Motion setting

**Test ID**: `ACC-004`
**Name**: High Contrast Mode
**Requirement**: Apple Vision Pro hardware, Increase Contrast enabled
**Procedure**:
1. Enable Increase Contrast
2. Launch app
3. Verify UI text has sufficient contrast
4. Verify choices are easily readable
5. Test in different lighting conditions

**Expected Result**: All text meets WCAG AAA contrast (7:1 ratio)

---

## Multi-Session Persistence Tests

### Save/Load Functionality

**Test ID**: `PER-001`
**Name**: Story Progress Persistence
**Requirement**: Apple Vision Pro hardware
**Procedure**:
1. Play story for 30 minutes
2. Make 10 choices
3. Note current scene and character states
4. Force quit app
5. Relaunch and verify all progress restored

**Expected Result**: 100% of progress restored

**Test ID**: `PER-002`
**Name**: Character Relationship Persistence
**Requirement**: Apple Vision Pro hardware
**Procedure**:
1. Build trust with character (make positive choices)
2. Note trust level (e.g., 0.85)
3. Close app
4. Relaunch after 24 hours
5. Verify trust level is same

**Expected Result**: Relationship values persist accurately (±0.01)

**Test ID**: `PER-003`
**Name**: CloudKit Sync Between Devices
**Requirement**: 2 Apple Vision Pro devices, same iCloud account
**Procedure**:
1. Play story on Device A, make progress
2. Wait for CloudKit sync (check iCloud dashboard)
3. Launch app on Device B
4. Verify progress appears on Device B
5. Make more progress on Device B
6. Return to Device A, verify sync

**Expected Result**: Progress syncs bidirectionally <5 minutes

**Test ID**: `PER-004`
**Name**: Character Memory Persistence
**Requirement**: Apple Vision Pro hardware
**Procedure**:
1. Have conversation with character
2. Character stores memory of event
3. Exit app
4. Relaunch 1 week later
5. Resume conversation
6. Verify character references previous conversation

**Expected Result**: Long-term memories persist across sessions

---

## Test Execution Guidelines

### Prerequisites

- **Hardware**: Apple Vision Pro with visionOS 2.0+
- **Environment**: Well-lit room with mixed surfaces (floor, walls, furniture)
- **Space**: Minimum 2m x 2m open space for movement tests
- **Time**: Allocate 20-30 hours for complete test suite
- **Personnel**: 2-3 testers for varied user testing (emotion recognition, etc.)

### Test Execution Order

1. **Setup Tests** (ARK-001 to ARK-004) - Verify basic ARKit functionality
2. **Interaction Tests** (HND-*, EYE-*) - Validate input systems
3. **Core Feature Tests** (CHR-*, AUD-*, EMO-*) - Test main features
4. **Performance Tests** (PERF-*) - Long-running sessions
5. **Accessibility Tests** (ACC-*) - Final validation
6. **Persistence Tests** (PER-*) - Multi-session tests

### Pass/Fail Criteria

- **Critical (P0)**: Must pass 100% - blocks release
- **High (P1)**: Must pass ≥95% - should fix before release
- **Medium (P2)**: Must pass ≥80% - fix if time permits

### Bug Reporting Template

```markdown
**Test ID**: [e.g., ARK-001]
**Test Name**: [e.g., Room Scan Accuracy]
**Result**: FAIL
**Expected**: [What should happen]
**Actual**: [What actually happened]
**Repro Steps**: [Detailed steps]
**Frequency**: [Always / Intermittent]
**Severity**: [P0 / P1 / P2 / P3]
**Video/Screenshot**: [Attachment]
**Device**: [Vision Pro model, visionOS version]
**Environment**: [Room type, lighting]
```

---

## Automated Testing (Where Possible)

While these tests require hardware, some can be partially automated:

### XCTest UI Tests

Create `VisionOSUITests.swift` for automated UI testing:

```swift
func testChoiceSelectionWithGesture() {
    let app = XCUIApplication()
    app.launch()

    // Wait for choice interface
    let choiceButton = app.buttons["choice_option_1"]
    XCTAssertTrue(choiceButton.waitForExistence(timeout: 5))

    // Simulate pinch gesture (in visionOS)
    choiceButton.tap()

    // Verify progression
    let nextDialogue = app.staticTexts["next_dialogue"]
    XCTAssertTrue(nextDialogue.waitForExistence(timeout: 3))
}
```

### Instruments Profiling

Use Xcode Instruments for automated performance monitoring:
- **Time Profiler**: CPU usage during AI processing
- **Allocations**: Memory leak detection
- **System Trace**: Frame rate and thermal monitoring
- **Energy Log**: Battery impact assessment

---

## Continuous Hardware Testing

### Nightly Test Runs

Set up nightly automated test runs on physical hardware using Xcode Cloud or dedicated Vision Pro device:

1. Deploy latest build to test device
2. Run automated UI test suite
3. Run 4-hour stress test
4. Collect performance metrics
5. Generate test report
6. Alert on failures

### Beta Testing Program

Recruit 20-50 beta testers with Vision Pro hardware:

- Distribute TestFlight builds weekly
- Collect telemetry and crash reports
- Survey for subjective experience (immersion, comfort, emotion accuracy)
- Track completion rates and engagement metrics

---

## Conclusion

This document provides comprehensive hardware test coverage for Narrative Story Worlds on visionOS. All tests marked as requiring "Apple Vision Pro hardware" must be executed on physical devices before production release.

**Estimated Total Testing Time**: 25-30 hours across all test cases
**Minimum Passing Criteria**: P0 tests: 100%, P1 tests: 95%, P2 tests: 80%

**Last Updated**: 2025-11-19
**Next Review**: Before each major release
