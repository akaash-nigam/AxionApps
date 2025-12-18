# Tasks for visionOS/Xcode Environment

This document lists all tasks that **require macOS with Xcode** or **Apple Vision Pro hardware** to complete.

---

## Environment Requirements

### Minimum Requirements
- macOS 14.0+ (Sonoma)
- Xcode 15.2+ with visionOS SDK
- Apple Silicon Mac (M1+) recommended
- 16+ GB RAM
- 50+ GB free disk space

### Hardware Requirements (for full testing)
- Apple Vision Pro with visionOS 2.0+
- USB-C cable for device connection
- Apple Developer account ($99/year)
- Provisioning profile with visionOS entitlements

---

## Phase 1: Initial Compilation (CRITICAL - Priority P0)

**Estimated Time**: 4-6 hours

### 1.1 Open Project in Xcode
- [ ] Clone repository if not already done
- [ ] Open `NarrativeStoryWorlds.xcodeproj` in Xcode
- [ ] Select visionOS Simulator as destination
- [ ] Verify all files are visible in Project Navigator

### 1.2 Resolve Build Dependencies
- [ ] Verify Swift 6.0 compatibility
- [ ] Check all import statements
- [ ] Resolve any package dependencies
- [ ] Configure bundle identifier
- [ ] Set up signing & capabilities

### 1.3 Compile Main App
```bash
xcodebuild build \
  -scheme NarrativeStoryWorlds \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
```

**Expected Issues**:
- [ ] Fix any compilation errors in main app code
- [ ] Update deprecated APIs if any
- [ ] Resolve type mismatches
- [ ] Fix import issues

### 1.4 Compile Tests
```bash
xcodebuild build-for-testing \
  -scheme NarrativeStoryWorlds \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
```

**Expected Issues** (see `TEST_UPDATE_GUIDE.md`):
- [ ] Add missing helper types (`DialogueContext`, `StoryEvent`, etc.)
- [ ] Fix API signature mismatches
- [ ] Add test extensions for `AppModel`
- [ ] Create `TestHelpers.swift` with mock types
- [ ] Update method calls to match actual implementation

**Success Criteria**: ✅ All code compiles without errors or warnings

---

## Phase 2: Test Fixes (HIGH PRIORITY - Priority P0)

**Estimated Time**: 10-15 hours

### 2.1 Fix Unit Tests

**AISystemTests.swift** (34 tests):
- [ ] Fix `StoryDirectorAI` tests
  - [ ] Remove/update `detectPlayerArchetype` calls
  - [ ] Use public API `selectBranch` instead
  - [ ] Update test expectations
- [ ] Fix `CharacterAI` tests
  - [ ] Add `StoryEvent` type definition
  - [ ] Verify `updateEmotionalState` signature
  - [ ] Test `recallRelevantMemories` if public
- [ ] Fix `EmotionRecognitionAI` tests
  - [ ] Add mock blend shape data
  - [ ] Verify emotion classification logic
- [ ] Fix `DialogueGenerator` tests
  - [ ] Add `DialogueContext` type
  - [ ] Verify `generateDialogue` signature
  - [ ] Test context awareness

**Target**: All 34 unit tests compile and run

### 2.2 Fix Integration Tests

**IntegrationTests.swift** (14 tests):
- [ ] Add achievement system to `AppModel`
- [ ] Implement `makeChoice(_:)` method
- [ ] Implement `checkAchievements()` method
- [ ] Add `Achievement` and `UnlockCondition` types
- [ ] Add `RelationshipImpact` type
- [ ] Test story progression flow
- [ ] Test save/restore functionality

**Target**: All 14 integration tests compile and run

### 2.3 Fix Performance Tests

**PerformanceTests.swift** (25+ tests):
- [ ] Create proper mock implementations
- [ ] Update method signatures
- [ ] Verify performance baselines (adjust for simulator)
- [ ] Test memory management
- [ ] Test concurrency

**Target**: All 25+ performance tests compile and run

### 2.4 Run All Tests
```bash
xcodebuild test \
  -scheme NarrativeStoryWorlds \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
```

**Success Criteria**: ✅ 80%+ of tests pass

---

## Phase 3: Test Coverage & Quality (HIGH PRIORITY - Priority P1)

**Estimated Time**: 6-8 hours

### 3.1 Measure Code Coverage
```bash
xcodebuild test \
  -scheme NarrativeStoryWorlds \
  -enableCodeCoverage YES \
  -resultBundlePath ./TestResults.xcresult

xcrun xccov view --report ./TestResults.xcresult
```

**Tasks**:
- [ ] Generate coverage report
- [ ] Identify uncovered code paths
- [ ] Verify coverage goals:
  - [ ] Overall: 70%+
  - [ ] AI Systems: 80%+
  - [ ] Story Models: 85%+
  - [ ] Core Systems: 75%+

### 3.2 Add Missing Tests
- [ ] Add tests for uncovered code paths
- [ ] Add edge case tests
- [ ] Add error handling tests
- [ ] Add boundary condition tests

### 3.3 Create UI Tests (visionOS Simulator)

**Create**: `VisionOSUITests.swift`

**Test Coverage**:
- [ ] App launch and initialization
- [ ] Main menu navigation
- [ ] Story start flow
- [ ] Dialogue view rendering
- [ ] Choice selection UI
- [ ] HUD visibility and auto-hide
- [ ] Settings screen
- [ ] Accessibility labels (VoiceOver)

**Example Test**:
```swift
func testChoiceSelection() {
    let app = XCUIApplication()
    app.launch()

    // Navigate to story
    app.buttons["Start Story"].tap()

    // Wait for choice interface
    let choiceButton = app.buttons["choice_option_1"]
    XCTAssertTrue(choiceButton.waitForExistence(timeout: 5))

    // Select choice
    choiceButton.tap()

    // Verify progression
    let nextDialogue = app.staticTexts["next_dialogue"]
    XCTAssertTrue(nextDialogue.waitForExistence(timeout: 3))
}
```

**Target**: 10+ UI tests covering main user flows

### 3.4 Run SwiftLint
```bash
brew install swiftlint
swiftlint
```

**Tasks**:
- [ ] Fix all SwiftLint errors
- [ ] Fix all SwiftLint warnings
- [ ] Verify zero warnings in strict mode

**Success Criteria**:
- ✅ 70%+ overall coverage achieved
- ✅ 80%+ AI systems coverage achieved
- ✅ 10+ UI tests created
- ✅ SwiftLint shows zero warnings

---

## Phase 4: Simulator Testing (MEDIUM PRIORITY - Priority P1)

**Estimated Time**: 4-6 hours

### 4.1 Run on visionOS Simulator

**Setup**:
```bash
# List available simulators
xcrun simctl list devices visionOS

# Boot simulator if needed
xcrun simctl boot "Apple Vision Pro"
```

**Tasks**:
- [ ] Launch app on simulator (⌘R)
- [ ] Test main menu UI
- [ ] Start story experience
- [ ] Navigate through Episode 1
- [ ] Test all dialogue flows
- [ ] Test choice selection
- [ ] Test save/load functionality
- [ ] Test settings and preferences

### 4.2 Manual Testing Scenarios

**Story Flow**:
- [ ] Complete Episode 1 (main path)
- [ ] Test all major branching choices
- [ ] Verify character relationship changes
- [ ] Test achievement unlocking
- [ ] Test story state persistence across app restarts

**UI/UX**:
- [ ] Verify all UI elements render correctly
- [ ] Test dialogue typewriter effect
- [ ] Test choice presentation and selection
- [ ] Test HUD auto-hide functionality
- [ ] Test animations and transitions

**Error Handling**:
- [ ] Test invalid save file handling
- [ ] Test network failures (CloudKit)
- [ ] Test low memory scenarios
- [ ] Test background/foreground transitions

### 4.3 Performance on Simulator

**Measure** (Note: Simulator ≠ Hardware):
- [ ] Frame rate during dialogue
- [ ] Memory usage during long sessions
- [ ] Launch time
- [ ] Story load time
- [ ] CPU usage

**Profile with Instruments**:
```bash
# Press ⌘I in Xcode or:
instruments -t "Time Profiler" -D trace.trace ./NarrativeStoryWorlds.app
```

**Success Criteria**:
- ✅ App runs smoothly on simulator
- ✅ All major user flows work
- ✅ No crashes during normal usage

---

## Phase 5: Hardware Testing (CRITICAL - Priority P0)

**Estimated Time**: 20-30 hours
**Requires**: Apple Vision Pro

### 5.1 Device Setup

**Preparation**:
- [ ] Enable Developer Mode on Vision Pro
  - Settings → Privacy & Security → Developer Mode
- [ ] Connect Vision Pro to Mac via USB-C
- [ ] Trust computer on Vision Pro
- [ ] Verify device appears in Xcode (Window → Devices and Simulators)

**Build for Device**:
```bash
xcodebuild build \
  -scheme NarrativeStoryWorlds \
  -destination 'platform=visionOS,name=My Vision Pro'
```

### 5.2 Execute Hardware Test Suite

See **`VISIONOS_HARDWARE_TESTS.md`** for complete procedures.

**Priority P0 Tests** (Must Pass for Release):

#### ARKit Integration (4 tests)
- [ ] `ARK-001`: Room Scan Accuracy (≥90%)
- [ ] `ARK-002`: Anchor Placement Precision (±3cm)
- [ ] `ARK-003`: Anchor Persistence Across Sessions
- [ ] `ARK-004`: Multi-Room Persistence

#### Spatial Audio (3 tests)
- [ ] `AUD-001`: Character Dialogue Spatial Position (>95%)
- [ ] `AUD-002`: Head-Tracked Audio Persistence (±10°)
- [ ] `AUD-004`: Distance-Based Volume Falloff

#### Hand Tracking (3 tests)
- [ ] `HND-001`: Pinch Gesture Detection (>95%)
- [ ] `HND-002`: Point Gesture Recognition (>90%)
- [ ] `HND-005`: Gesture Timeout Handling

#### Eye Tracking (2 tests)
- [ ] `EYE-001`: Gaze Target Detection (>90%)
- [ ] `EYE-002`: Dwell Time Measurement (±200ms)

#### Face Tracking & Emotion (4 tests)
- [ ] `EMO-001`: Happy Emotion Detection (>80%)
- [ ] `EMO-002`: Sad Emotion Detection (>75%)
- [ ] `EMO-003`: Surprised Emotion Detection (>80%)
- [ ] `EMO-005`: Real-Time Emotion Adaptation (>70%)

#### Character Spatial (3 tests)
- [ ] `CHR-001`: Character Walking on Real Surfaces (100%)
- [ ] `CHR-003`: Character Scale Perception (±5%)
- [ ] `CHR-005`: Multiple Characters Spatial Awareness

#### Performance (6 tests)
- [ ] `PERF-001`: Sustained 90 FPS During Dialogue
- [ ] `PERF-002`: Frame Rate with Multiple Characters (≥90 FPS)
- [ ] `PERF-003`: Frame Time Consistency (<2ms variance)
- [ ] `PERF-004`: Memory Usage Long Session (<1.5 GB)
- [ ] `PERF-006`: Thermal Rise (<15°C)
- [ ] `PERF-007`: Quality Degradation Response

#### User Movement (2 tests)
- [ ] `MOV-001`: Walking Around Characters (stable)
- [ ] `MOV-002`: Viewing from Different Angles

#### Persistence (3 tests)
- [ ] `PER-001`: Story Progress Persistence (100%)
- [ ] `PER-002`: Character Relationship Persistence (±0.01)
- [ ] `PER-004`: Character Memory Persistence

**Total P0 Tests**: 33 critical hardware tests

### 5.3 Performance Baseline Establishment

**Measure on Hardware**:
- [ ] Frame rate: _____ FPS (target: ≥90 FPS)
- [ ] Frame time: _____ ms (target: <11ms)
- [ ] Memory usage: _____ GB (target: <1.5 GB)
- [ ] Launch time: _____ seconds (target: <3s)
- [ ] Story load: _____ ms (target: <500ms)
- [ ] AI response: _____ ms (target: <100ms)
- [ ] Emotion recognition: _____ ms (target: <20ms)
- [ ] Battery drain: _____ % per hour (target: <40%)
- [ ] Thermal rise: _____ °C (target: <15°C)

**Update** `PerformanceTests.swift` baselines with real measurements.

### 5.4 Accessibility Testing

**VoiceOver**:
- [ ] `ACC-001`: VoiceOver Dialogue Navigation (100%)
- [ ] `ACC-002`: VoiceOver Choice Selection
- [ ] Enable VoiceOver and navigate entire app
- [ ] Verify all UI elements have proper labels
- [ ] Test story playthrough with VoiceOver only

**Other Accessibility**:
- [ ] `ACC-003`: Reduced Motion Mode
- [ ] `ACC-004`: High Contrast Mode (7:1 ratio)
- [ ] Test Dynamic Type (larger text sizes)

**Success Criteria**:
- ✅ All 33 P0 hardware tests pass
- ✅ Performance baselines established
- ✅ App is fully accessible

---

## Phase 6: Content & Polish (MEDIUM PRIORITY - Priority P1)

**Estimated Time**: 10-20 hours

### 6.1 Complete Episode 1 Content

**Story Content**:
- [ ] Proofread all dialogue for typos
- [ ] Verify all story branches work correctly
- [ ] Test all achievement unlocks
- [ ] Verify story completion time (30-45 min target)
- [ ] Balance difficulty and engagement

**Character Development**:
- [ ] Test Sarah's personality consistency
- [ ] Verify emotional state transitions
- [ ] Test character memory callbacks
- [ ] Validate relationship progression

### 6.2 Add Assets

**Audio**:
- [ ] Record/acquire dialogue audio clips
- [ ] Add background music tracks
- [ ] Add sound effects
- [ ] Add ambient audio
- [ ] Test spatial audio positioning
- [ ] Optimize audio file sizes

**Visual**:
- [ ] Create character 3D models (or placeholders)
- [ ] Create app icon (all sizes)
- [ ] Create launch screen
- [ ] Create App Store screenshots (5+ required)
- [ ] Create App Store preview video (optional)

**Optimization**:
- [ ] Compress all audio files
- [ ] Optimize image sizes
- [ ] Test asset loading performance

### 6.3 Localization (Optional)

If supporting multiple languages:
- [ ] Externalize all user-facing strings
- [ ] Create localization files
- [ ] Test UI layout with different languages
- [ ] Test right-to-left languages (Arabic, Hebrew)

**Success Criteria**:
- ✅ Episode 1 content complete and polished
- ✅ All assets integrated
- ✅ App ready for beta testing

---

## Phase 7: Beta Testing (HIGH PRIORITY - Priority P0)

**Estimated Time**: 2-4 weeks

### 7.1 TestFlight Setup

**Preparation**:
- [ ] Create App Store Connect account
- [ ] Register app in App Store Connect
- [ ] Configure app metadata
- [ ] Set up TestFlight

**Build & Upload**:
```bash
# Archive the app
xcodebuild archive \
  -scheme NarrativeStoryWorlds \
  -archivePath NarrativeStoryWorlds.xcarchive

# Export for TestFlight
xcodebuild -exportArchive \
  -archivePath NarrativeStoryWorlds.xcarchive \
  -exportPath Export \
  -exportOptionsPlist ExportOptions.plist

# Upload (or use Xcode Organizer)
xcrun altool --upload-app \
  --type visionos \
  --file "Export/NarrativeStoryWorlds.ipa" \
  --apiKey <API_KEY> \
  --apiIssuer <ISSUER_ID>
```

### 7.2 Recruit Beta Testers

**Target**: 10-20 beta testers with Vision Pro

**Recruit via**:
- [ ] Apple Developer Forums
- [ ] Reddit (r/VisionPro)
- [ ] Twitter/X
- [ ] Discord communities
- [ ] Personal network

**Provide**:
- [ ] TestFlight invitation link
- [ ] Beta testing guidelines
- [ ] Feedback survey
- [ ] Bug report template

### 7.3 Beta Testing Period

**Duration**: 1-2 weeks minimum

**Collect**:
- [ ] Crash reports
- [ ] User feedback survey responses
- [ ] Bug reports
- [ ] Usability observations
- [ ] Performance reports
- [ ] Feature requests

**Track**:
- [ ] Completion rate (% who finish Episode 1)
- [ ] Session length
- [ ] Crash rate
- [ ] User ratings
- [ ] NPS score

### 7.4 Address Beta Feedback

**Priority P0** (Must Fix):
- [ ] Fix all crashes
- [ ] Fix data loss bugs
- [ ] Fix progression blockers
- [ ] Fix critical performance issues

**Priority P1** (Should Fix):
- [ ] Fix major usability issues
- [ ] Address common confusion points
- [ ] Improve tutorial/onboarding
- [ ] Polish rough edges

**Success Criteria**:
- ✅ 10+ beta testers recruited
- ✅ Beta testing completed (1-2 weeks)
- ✅ All P0 bugs fixed
- ✅ Positive beta tester feedback

---

## Phase 8: App Store Submission (CRITICAL - Priority P0)

**Estimated Time**: 1-2 weeks (including review)

### 8.1 Pre-Submission Checklist

See **`RELEASE_CHECKLIST.md`** for complete checklist (100+ items).

**Critical Items**:
- [ ] All tests pass (100%)
- [ ] Code coverage ≥70%
- [ ] All P0 hardware tests pass
- [ ] SwiftLint shows zero warnings
- [ ] Privacy manifest complete
- [ ] App Store metadata complete
- [ ] Screenshots uploaded (5+ required)
- [ ] App Store description written
- [ ] Keywords selected
- [ ] Support URL provided
- [ ] Privacy policy published

### 8.2 Final Build

**Create Archive**:
- [ ] Increment build number
- [ ] Set version number (e.g., 1.0.0)
- [ ] Archive in Xcode (Product → Archive)
- [ ] Validate archive (no errors)
- [ ] Distribute to App Store

### 8.3 Submit for Review

**In App Store Connect**:
- [ ] Select build
- [ ] Complete all metadata fields
- [ ] Add release notes
- [ ] Submit for review
- [ ] Monitor review status daily

**Response Plan**:
- [ ] Respond to reviewer questions within 24 hours
- [ ] Address rejection issues immediately
- [ ] Resubmit if needed

### 8.4 App Approval & Release

**Upon Approval**:
- [ ] Verify app is live
- [ ] Test download from App Store
- [ ] Verify screenshots display correctly
- [ ] Test in-app purchases (if any)

**Launch Activities**:
- [ ] Post social media announcement
- [ ] Send press release (if applicable)
- [ ] Notify beta testers
- [ ] Monitor reviews and ratings
- [ ] Respond to user reviews
- [ ] Monitor crash reports

**Success Criteria**:
- ✅ App approved by Apple
- ✅ App live on App Store
- ✅ Launch announcement published

---

## Phase 9: Post-Launch Monitoring (CRITICAL - Priority P0)

**Duration**: First 4 weeks post-launch

### 9.1 Week 1: Critical Monitoring

**Daily Tasks**:
- [ ] Monitor crash reports (aim for <1% crash rate)
- [ ] Check user reviews (respond within 24 hours)
- [ ] Track download numbers
- [ ] Monitor analytics (engagement, retention)
- [ ] Watch for critical bugs

**Metrics to Track**:
- [ ] Downloads per day
- [ ] Daily active users (DAU)
- [ ] Session length
- [ ] Completion rate
- [ ] Crash rate
- [ ] Average rating
- [ ] Review sentiment

### 9.2 Week 2-4: Stabilization

**Weekly Tasks**:
- [ ] Review aggregated analytics
- [ ] Prioritize bug fixes
- [ ] Plan hotfix if needed (for P0 bugs)
- [ ] Collect feature requests
- [ ] Update roadmap

**Hotfix Criteria** (Deploy immediately):
- Critical crash affecting >5% of users
- Data loss bug
- Security vulnerability
- Major feature broken for all users

### 9.3 Prepare v1.1

**Based on Feedback**:
- [ ] List top user requests
- [ ] List most common bugs
- [ ] List performance issues
- [ ] Plan improvements for v1.1

**Success Criteria**:
- ✅ Crash rate <1%
- ✅ Average rating ≥4.0 stars
- ✅ No critical bugs in production
- ✅ Roadmap for v1.1 defined

---

## CI/CD Integration (OPTIONAL - Priority P2)

**Estimated Time**: 4-8 hours

### Set Up GitHub Actions Runners

**For macOS Runners** (if not using GitHub-hosted):
- [ ] Set up macOS machine as self-hosted runner
- [ ] Install Xcode 15.2+
- [ ] Configure runner to accept jobs
- [ ] Test runner with simple workflow

### Configure Secrets

**In GitHub Repository Settings**:
- [ ] `APP_STORE_CONNECT_API_KEY_ID`
- [ ] `APP_STORE_CONNECT_ISSUER_ID`
- [ ] `APP_STORE_CONNECT_PRIVATE_KEY`
- [ ] Code signing certificates (if using CI)

### Test Workflows

**Verify**:
- [ ] `.github/workflows/test.yml` runs successfully
- [ ] `.github/workflows/lint.yml` runs successfully
- [ ] `.github/workflows/release.yml` runs successfully
- [ ] Coverage reports generated
- [ ] PR comments work

### Set Up Xcode Cloud (Alternative)

**If using Xcode Cloud instead of GitHub Actions**:
- [ ] Connect repository to Xcode Cloud
- [ ] Configure build workflows
- [ ] Configure test workflows
- [ ] Configure TestFlight deployment
- [ ] Test workflows

**Success Criteria**:
- ✅ Automated tests run on every PR
- ✅ Coverage reports generated automatically
- ✅ Release builds automated

---

## Summary Checklist

### Must Complete Before Release (P0)

- [ ] **Phase 1**: Project compiles without errors
- [ ] **Phase 2**: 80%+ of tests pass
- [ ] **Phase 3**: 70%+ code coverage achieved
- [ ] **Phase 4**: App runs smoothly on simulator
- [ ] **Phase 5**: All 33 P0 hardware tests pass
- [ ] **Phase 6**: Episode 1 content complete
- [ ] **Phase 7**: Beta testing completed
- [ ] **Phase 8**: App approved and live on App Store
- [ ] **Phase 9**: Post-launch monitoring active

### Recommended (P1)

- [ ] **Phase 3**: 10+ UI tests created
- [ ] **Phase 5**: All accessibility tests pass
- [ ] **Phase 6**: All assets (audio, visual) integrated
- [ ] **Phase 9**: v1.1 roadmap defined

### Optional (P2)

- [ ] **Phase 6**: Localization for additional languages
- [ ] **CI/CD**: Automated workflows set up
- [ ] **Phase 9**: Community engagement (Discord, social)

---

## Time Estimates by Phase

| Phase | Description | Time | Priority |
|-------|-------------|------|----------|
| 1 | Initial Compilation | 4-6 hours | P0 |
| 2 | Test Fixes | 10-15 hours | P0 |
| 3 | Coverage & Quality | 6-8 hours | P1 |
| 4 | Simulator Testing | 4-6 hours | P1 |
| 5 | Hardware Testing | 20-30 hours | P0 |
| 6 | Content & Polish | 10-20 hours | P1 |
| 7 | Beta Testing | 2-4 weeks | P0 |
| 8 | App Store Submission | 1-2 weeks | P0 |
| 9 | Post-Launch | 4 weeks | P0 |
| CI/CD | Optional Setup | 4-8 hours | P2 |

**Total Development Time**: 60-100 hours (not including beta/review/post-launch periods)

**Total Calendar Time**: 8-12 weeks from start to launch

---

## Resources

### Documentation
- [TEST_UPDATE_GUIDE.md](NarrativeStoryWorlds/Tests/TEST_UPDATE_GUIDE.md) - Detailed test fix guide
- [VISIONOS_HARDWARE_TESTS.md](NarrativeStoryWorlds/Tests/VISIONOS_HARDWARE_TESTS.md) - Hardware test procedures
- [RELEASE_CHECKLIST.md](RELEASE_CHECKLIST.md) - Pre-release checklist
- [CONTRIBUTING.md](CONTRIBUTING.md) - Development guidelines

### Apple Resources
- [visionOS Documentation](https://developer.apple.com/documentation/visionos)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [TestFlight Guide](https://developer.apple.com/testflight/)

### Tools
- Xcode 15.2+
- Instruments (profiling)
- SwiftLint (code quality)
- Xcode Cloud or GitHub Actions (CI/CD)

---

**Created**: 2025-11-19
**Purpose**: Track all tasks requiring visionOS/Xcode environment
**Estimated Total**: 60-100 hours development + 8-12 weeks to launch
