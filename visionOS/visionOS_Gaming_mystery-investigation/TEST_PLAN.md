# Mystery Investigation - Comprehensive Test Plan

## Overview

This document outlines all testing requirements for Mystery Investigation to ensure production readiness on Apple Vision Pro. Tests are categorized by type and execution environment.

---

## Test Categories

### ✅ Can Run in Current Environment
- Unit Tests (Business Logic)
- Data Model Tests
- Manager Tests (non-UI)
- JSON Serialization Tests
- Algorithm Tests

### 🔶 Requires visionOS Simulator
- UI Component Tests
- SwiftUI View Tests
- Navigation Flow Tests
- Basic Integration Tests

### 🔴 Requires Physical Vision Pro Device
- Spatial Computing Tests
- ARKit Integration Tests
- Hand Tracking Tests
- Eye Tracking Tests
- Performance Tests (90 FPS)
- User Experience Tests
- Comfort Tests

---

## 1. Unit Tests (✅ Can Run Now)

### 1.1 Data Model Tests

**File**: `Tests/UnitTests/DataModelTests.swift`

#### CaseData Tests
```swift
- testCaseDataInitialization()
- testCaseDataCodable()
- testDifficultyLevels()
- testCaseDataValidation()
```

#### Evidence Tests
```swift
- testEvidenceCreation()
- testEvidenceTypeEnum()
- testEvidenceCodable()
- testSpatialAnchorData()
- testForensicDataStructure()
```

#### Suspect Tests
```swift
- testSuspectCreation()
- testPersonalityProfile()
- testSuspectCodable()
- testGuiltyInnocentLogic()
```

#### Player Progress Tests
```swift
- testPlayerProgressInitialization()
- testXPAccumulation()
- testRankProgression()
- testAchievementUnlocking()
- testStatisticsTracking()
```

### 1.2 Manager Tests

**File**: `Tests/UnitTests/ManagerTests.swift`

#### CaseManager Tests
```swift
- testCaseLoading()
- testCaseValidation()
- testSolutionValidation()
- testTutorialCaseGeneration()
- testCaseQuery()
```

#### EvidenceManager Tests
```swift
- testEvidenceDiscovery()
- testEvidenceCollection()
- testEvidenceQuery()
- testRelatedEvidenceLookup()
- testForensicAnalysis()
```

#### SaveGameManager Tests
```swift
- testSavePlayerProgress()
- testLoadPlayerProgress()
- testSaveSettings()
- testLoadSettings()
- testCaseProgressPersistence()
- testDataDeletion()
```

### 1.3 Game Logic Tests

**File**: `Tests/UnitTests/GameLogicTests.swift`

```swift
- testScoreCalculation()
- testHintPenalty()
- testTimeBonus()
- testEvidenceCompletionBonus()
- testDifficultyScaling()
- testTheoryValidation()
```

### 1.4 Algorithm Tests

**File**: `Tests/UnitTests/AlgorithmTests.swift`

```swift
- testEvidencePlacementAlgorithm()
- testRoomAdaptationLogic()
- testSurfaceTypeSelection()
- testSpatialDistribution()
```

---

## 2. Integration Tests (🔶 Requires visionOS Simulator)

### 2.1 System Integration Tests

**File**: `Tests/IntegrationTests/SystemIntegrationTests.swift`

```swift
- testGameCoordinatorInitialization()
- testCaseStartFlow()
- testEvidenceDiscoveryFlow()
- testInterrogationFlow()
- testCaseCompletionFlow()
- testSaveLoadIntegration()
```

### 2.2 View Integration Tests

**File**: `Tests/IntegrationTests/ViewIntegrationTests.swift`

```swift
- testMainMenuNavigation()
- testCaseSelectionFlow()
- testInvestigationUIUpdates()
- testSettingsIntegration()
```

---

## 3. UI Tests (🔶 Requires visionOS Simulator)

### 3.1 SwiftUI View Tests

**File**: `Tests/UITests/ViewTests.swift`

#### MainMenuView Tests
```swift
- testMainMenuRender()
- testMenuButtonsVisible()
- testNavigationToSelection()
- testPlayerStatsDisplay()
```

#### CaseSelectionView Tests
```swift
- testCaseCardsRender()
- testDifficultyDisplay()
- testCaseSelection()
- testBackNavigation()
```

#### InvestigationHUD Tests
```swift
- testHUDElements()
- testEvidenceCounter()
- testObjectiveDisplay()
- testToolBeltVisibility()
```

### 3.2 Navigation Tests

**File**: `Tests/UITests/NavigationTests.swift`

```swift
- testFullNavigationFlow()
- testDeepLinking()
- testBackNavigation()
- testStateRestoration()
```

---

## 4. Spatial Computing Tests (🔴 Requires Vision Pro)

### 4.1 ARKit Integration Tests

**File**: `Tests/SpatialTests/ARKitTests.swift`

#### Room Scanning Tests
```swift
- testRoomScanningInitialization()
- testPlaneDetection()
- testSceneReconstruction()
- testWorldTracking()
- testSessionRecovery()
```

#### Spatial Anchoring Tests
```swift
- testAnchorCreation()
- testAnchorPersistence()
- testAnchorLoading()
- testAnchorAccuracy()
- testMultipleAnchors()
```

#### Evidence Placement Tests
```swift
- testEvidencePlacementOnFloor()
- testEvidencePlacementOnWall()
- testEvidencePlacementOnTable()
- testEvidencePlacementAccuracy()
- testEvidencePersistence()
```

### 4.2 Hand Tracking Tests

**File**: `Tests/SpatialTests/HandTrackingTests.swift`

```swift
- testHandTrackingInitialization()
- testPinchGestureRecognition()
- testSpreadGestureRecognition()
- testSwipeGestureRecognition()
- testAirWritingGesture()
- testGestureAccuracy()
- testGestureLatency()
- testTwoHandGestures()
```

### 4.3 Eye Tracking Tests

**File**: `Tests/SpatialTests/EyeTrackingTests.swift`

```swift
- testEyeTrackingInitialization()
- testGazeRaycast()
- testDwellTimeDetection()
- testGazeStability()
- testEvidenceHighlighting()
- testUIFocusing()
```

### 4.4 Spatial Audio Tests

**File**: `Tests/SpatialTests/SpatialAudioTests.swift`

```swift
- testSpatialAudioInitialization()
- test3DPositioning()
- testDistanceAttenuation()
- testOcclusionEffects()
- testMusicPlayback()
- testSFXPositioning()
```

---

## 5. Performance Tests (🔴 Requires Vision Pro)

### 5.1 Frame Rate Tests

**File**: `Tests/PerformanceTests/FrameRateTests.swift`

```swift
- testAverageFrameRate()
- testMinimumFrameRate()
- testFrameRateStability()
- testFrameRateWithMaxEvidence()
- testFrameRateDuringInterrogation()
```

**Success Criteria:**
- Average FPS: ≥ 90
- Minimum FPS: ≥ 60
- Frame time variance: < 10ms

### 5.2 Memory Tests

**File**: `Tests/PerformanceTests/MemoryTests.swift`

```swift
- testBaseMemoryUsage()
- testPerCaseMemoryUsage()
- testMemoryLeaks()
- testMemoryPeaks()
- testMemoryRecovery()
```

**Success Criteria:**
- Base app: < 500MB
- Per case: < 200MB additional
- No memory leaks
- Graceful memory recovery

### 5.3 Load Time Tests

**File**: `Tests/PerformanceTests/LoadTimeTests.swift`

```swift
- testAppLaunchTime()
- testCaseLoadTime()
- testSceneTransitionTime()
- testEvidenceLoadTime()
- testAssetLoadTime()
```

**Success Criteria:**
- App launch: < 3 seconds
- Case load: < 2 seconds
- Scene transition: < 1 second

### 5.4 Battery Tests

**File**: `Tests/PerformanceTests/BatteryTests.swift`

```swift
- testBatteryDrainRate()
- testThermalManagement()
- testPowerSavingMode()
```

**Success Criteria:**
- 60 minutes gameplay on full charge
- No thermal throttling
- < 15% battery per hour

---

## 6. User Experience Tests (🔴 Requires Vision Pro)

### 6.1 Comfort Tests

**File**: `Tests/UXTests/ComfortTests.swift`

#### Physical Comfort
```swift
- testSeatedPlayability()
- testStandingPlayability()
- testPlayAreaBoundaries()
- testNeckStrainPrevention()
- testArmFatiguePrevention()
```

**Success Criteria:**
- 60 minutes comfortable play
- No motion sickness reports
- < 5% discomfort incidents

#### Visual Comfort
```swift
- testTextLegibility()
- testUIReadability()
- testDepthPerception()
- testEyeStrainPrevention()
```

**Success Criteria:**
- All text readable at 1.5m
- No eye strain after 30 min
- Proper depth cues

### 6.2 Interaction Tests

**File**: `Tests/UXTests/InteractionTests.swift`

```swift
- testEvidencePickupNaturalness()
- testToolUsageIntuitiveness()
- testInterrogationFlow()
- testGestureDiscoverability()
- testVoiceCommandAccuracy()
```

**Success Criteria:**
- 90% gesture recognition
- < 50ms interaction latency
- Intuitive for first-time users

### 6.3 Gameplay Tests

**File**: `Tests/UXTests/GameplayTests.swift`

```swift
- testTutorialCompletionRate()
- testCaseDifficultyProgression()
- testHintSystemEffectiveness()
- testSolutionSatisfaction()
```

**Success Criteria:**
- 90% tutorial completion
- 75% case completion rate
- Balanced difficulty curve

---

## 7. Accessibility Tests (🔶 Requires visionOS Simulator)

### 7.1 VoiceOver Tests

**File**: `Tests/AccessibilityTests/VoiceOverTests.swift`

```swift
- testVoiceOverNavigation()
- testEvidenceDescriptions()
- testUILabelAccuracy()
- testFocusOrder()
```

### 7.2 Alternative Input Tests

**File**: `Tests/AccessibilityTests/AlternativeInputTests.swift`

```swift
- testOneHandedMode()
- testSeatedMode()
- testGameControllerSupport()
- testVoiceOnlyControl()
```

### 7.3 Visual Accessibility Tests

**File**: `Tests/AccessibilityTests/VisualAccessibilityTests.swift`

```swift
- testColorBlindModes()
- testHighContrastMode()
- testTextScaling()
- testColorContrast()
```

**Success Criteria:**
- WCAG 2.1 AA compliance
- 90% feature accessibility

---

## 8. Multiplayer Tests (🔴 Requires Vision Pro)

### 8.1 SharePlay Tests

**File**: `Tests/MultiplayerTests/SharePlayTests.swift`

```swift
- testSessionCreation()
- testSessionJoining()
- testEvidenceSynchronization()
- testStateSynchronization()
- testDisconnectionHandling()
- testReconnection()
```

### 8.2 Network Tests

**File**: `Tests/MultiplayerTests/NetworkTests.swift`

```swift
- testLowBandwidthPerformance()
- testHighLatencyHandling()
- testPacketLoss()
- testNetworkRecovery()
```

**Success Criteria:**
- < 200ms latency acceptable
- Graceful degradation
- Auto-reconnection

---

## 9. Security & Privacy Tests (✅ Can Run Now)

### 9.1 Data Privacy Tests

**File**: `Tests/SecurityTests/PrivacyTests.swift`

```swift
- testNoSpatialDataUpload()
- testEncryptedSaveFiles()
- testDataDeletion()
- testMinimalDataCollection()
```

### 9.2 Input Validation Tests

**File**: `Tests/SecurityTests/ValidationTests.swift`

```swift
- testInvalidCaseDataHandling()
- testCorruptedSaveFiles()
- testMalformedJSON()
- testInputSanitization()
```

---

## 10. Edge Case Tests (🔶 Requires visionOS Simulator)

### 10.1 Error Handling Tests

**File**: `Tests/EdgeCaseTests/ErrorHandlingTests.swift`

```swift
- testARKitSessionFailure()
- testNoRoomScanData()
- testInsufficientSpace()
- testLowMemoryHandling()
- testCorruptedCaseData()
```

### 10.2 Boundary Tests

**File**: `Tests/EdgeCaseTests/BoundaryTests.swift`

```swift
- testMinimumRoomSize()
- testMaximumRoomSize()
- testMaximumEvidence()
- testLongGameSessions()
- testRapidStateChanges()
```

---

## 11. Localization Tests (🔶 Requires visionOS Simulator)

### 11.1 Language Tests

**File**: `Tests/LocalizationTests/LanguageTests.swift`

```swift
- testEnglishLocalization()
- testSpanishLocalization()
- testFrenchLocalization()
- testGermanLocalization()
- testJapaneseLocalization()
- testChineseLocalization()
```

### 11.2 Cultural Tests

```swift
- testDateFormatting()
- testNumberFormatting()
- testTextDirection()
- testUILayout()
```

---

## 12. Regression Tests

### 12.1 Core Feature Regression

**File**: `Tests/RegressionTests/CoreFeatureTests.swift`

Run after each update:
```swift
- testEvidenceCollectionStillWorks()
- testInterrogationStillWorks()
- testCaseSolvingStillWorks()
- testSaveLoadStillWorks()
```

---

## Test Execution Strategy

### Phase 1: Unit Tests (Current Environment)
**Timeline**: Week 1
- ✅ Run all data model tests
- ✅ Run manager tests
- ✅ Run business logic tests
- ✅ Document results

### Phase 2: Integration Tests (Simulator)
**Timeline**: Week 2-3
- 🔶 Set up visionOS simulator
- 🔶 Run view integration tests
- 🔶 Run navigation tests
- 🔶 Run accessibility tests

### Phase 3: Spatial Tests (Physical Device)
**Timeline**: Week 4-6
- 🔴 Acquire Vision Pro devices
- 🔴 Run ARKit tests
- 🔴 Run hand/eye tracking tests
- 🔴 Run performance tests

### Phase 4: User Testing (Physical Device)
**Timeline**: Week 7-8
- 🔴 Beta tester recruitment (50-100 users)
- 🔴 Comfort testing
- 🔴 UX testing
- 🔴 Gameplay testing

### Phase 5: Final Validation
**Timeline**: Week 9-10
- Run full test suite
- Fix all critical issues
- Regression testing
- Performance optimization

---

## Test Automation

### Continuous Integration
```yaml
# .github/workflows/tests.yml
name: Test Suite

on: [push, pull_request]

jobs:
  unit-tests:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run Unit Tests
        run: swift test

  ui-tests:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run UI Tests
        run: xcodebuild test -scheme MysteryInvestigation -destination 'platform=visionOS Simulator'
```

### Test Coverage Goals
- **Unit Tests**: 80% code coverage
- **Integration Tests**: 70% feature coverage
- **UI Tests**: 60% screen coverage
- **Overall**: 75% coverage minimum

---

## Success Criteria Summary

### Critical (Must Pass)
- ✅ Zero crashes in 10 hours playtime
- ✅ 90 FPS average performance
- ✅ All core features functional
- ✅ Save/load works 100%
- ✅ No data loss scenarios

### Important (Should Pass)
- ✅ 95% gesture recognition
- ✅ < 3 second load times
- ✅ 75% case completion rate
- ✅ Comfortable for 60 min sessions
- ✅ Accessible to 90% users

### Nice to Have (Can Iterate)
- Enhanced visual polish
- Additional cases
- Advanced features
- Community features

---

## Bug Severity Classification

### P0 - Critical (Blocker)
- App crashes
- Data loss
- Core feature broken
- Security vulnerability
- **Fix immediately**

### P1 - High (Major)
- Performance issues
- UX problems
- Comfort issues
- **Fix before launch**

### P2 - Medium (Minor)
- Polish issues
- Minor bugs
- Edge cases
- **Fix if time permits**

### P3 - Low (Enhancement)
- Nice-to-have features
- Optimizations
- Future improvements
- **Backlog**

---

## Testing Tools

### Development Tools
- Xcode 16+
- Reality Composer Pro
- Instruments (profiling)
- Network Link Conditioner
- Accessibility Inspector

### Third-Party Tools
- TestFlight (beta distribution)
- Crashlytics/Sentry (crash reporting)
- Analytics (user behavior)

### Hardware Required
- Vision Pro devices (3-5 units)
- Various room sizes for testing
- Different lighting conditions

---

## Test Deliverables

### Documentation
- [ ] Test plan (this document)
- [ ] Test cases (detailed)
- [ ] Test results
- [ ] Bug reports
- [ ] Performance reports

### Code
- [ ] Unit test suite
- [ ] Integration test suite
- [ ] UI test suite
- [ ] Performance test suite

### Reports
- [ ] Code coverage report
- [ ] Performance benchmarks
- [ ] User testing findings
- [ ] Bug triage report
- [ ] Final QA sign-off

---

## Next Steps

1. **Immediate** (Can do now):
   - Implement unit tests
   - Set up test infrastructure
   - Document test cases

2. **Short-term** (Need simulator):
   - UI component tests
   - Integration tests
   - Accessibility tests

3. **Long-term** (Need device):
   - Spatial computing tests
   - Performance tests
   - User testing
   - Beta program

---

**This test plan ensures Mystery Investigation meets the highest quality standards before App Store launch.**
