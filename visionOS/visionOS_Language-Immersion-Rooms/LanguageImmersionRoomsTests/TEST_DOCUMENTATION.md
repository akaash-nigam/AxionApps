# Test Documentation

Complete testing guide for Language Immersion Rooms visionOS app.

## Table of Contents

1. [Test Overview](#test-overview)
2. [Test Types](#test-types)
3. [Running Tests](#running-tests)
4. [Test Coverage](#test-coverage)
5. [Environment Requirements](#environment-requirements)
6. [Test Results Documentation](#test-results-documentation)

---

## Test Overview

This test suite provides comprehensive coverage of the Language Immersion Rooms app across multiple layers:

- **Unit Tests**: 3 files, ~60 test methods
- **Integration Tests**: 1 file, ~15 test methods
- **UI Tests**: 1 file, ~20 test methods
- **Performance Tests**: 1 file, ~25 test methods
- **End-to-End Tests**: 1 file, ~10 test scenarios

**Total**: ~130 test methods covering all app functionality

---

## Test Types

### 1. Unit Tests ✅ CAN RUN

**Location**: `LanguageImmersionRoomsTests/Unit/`

**Files**:
- `Models/CoreModelsTests.swift` (25 tests)
- `Services/VocabularyServiceTests.swift` (23 tests)
- `Services/ObjectDetectionServiceTests.swift` (12 tests)
- `ViewModels/AppStateTests.swift` (18 tests)

**What They Test**:
- Data model initialization and properties
- Codable conformance (JSON encoding/decoding)
- Service layer business logic
- State management and updates
- Edge cases and validation

**Requirements**:
- ✅ Xcode 16.0+
- ✅ Swift 6.0+
- ✅ No external dependencies
- ✅ No network required
- ✅ No API keys required

**How to Run**:
```bash
# Command line
cd visionOS_Language-Immersion-Rooms
xcodebuild test \
  -scheme LanguageImmersionRooms \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -only-testing:LanguageImmersionRoomsTests/Unit

# Or in Xcode
# 1. Open project
# 2. Press ⌘+U (Test All)
# 3. Or right-click test file → Run Tests
```

**Expected Results**:
- ✅ CoreModelsTests: All 25 tests should pass
- ✅ VocabularyServiceTests: All 23 tests should pass
- ✅ ObjectDetectionServiceTests: All 12 tests should pass
- ✅ AppStateTests: All 18 tests should pass

**Total**: 78/78 tests passing

---

### 2. Integration Tests ⚠️  PARTIAL RUN

**Location**: `LanguageImmersionRoomsTests/Integration/`

**File**: `ServiceIntegrationTests.swift` (15 tests)

**What They Test**:
- Object detection → Vocabulary translation pipeline
- Vocabulary service → Conversation service integration
- OpenAI API integration
- Speech services integration
- Memory usage across services
- Concurrent service operations

**Requirements**:
- ✅ Xcode 16.0+
- ⚠️  OpenAI API key (for conversation tests)
- ⚠️  Network connection (for API tests)
- ✅ Simulator or device

**How to Run**:

**Without API Key** (partial):
```bash
xcodebuild test \
  -scheme LanguageImmersionRooms \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -only-testing:LanguageImmersionRoomsTests/Integration/ServiceIntegrationTests/testDetectAndTranslateObjects \
  -only-testing:LanguageImmersionRoomsTests/Integration/ServiceIntegrationTests/testDetectObjectsAndCreateVocabularyWords \
  -only-testing:LanguageImmersionRoomsTests/Integration/ServiceIntegrationTests/testConcurrentDetectionAndTranslation
```

**With API Key** (full):
```bash
# Set API key
export OPENAI_API_KEY="your-api-key-here"

# Run all integration tests
xcodebuild test \
  -scheme LanguageImmersionRooms \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -only-testing:LanguageImmersionRoomsTests/Integration
```

**Expected Results**:
- Without API: 3/15 tests pass (detection + vocabulary)
- With API: 15/15 tests pass (includes conversation tests)

**Tests Requiring API Key**:
- `testConversationWithVocabulary()`
- `testConversationGreeting()`
- `testConversationGrammarCheck()`
- `testFullLearningPipeline()` (Step 4)

---

### 3. UI Tests ❌ CANNOT RUN (Requires Xcode UI Testing)

**Location**: `LanguageImmersionRoomsTests/UI/`

**File**: `NavigationFlowTests.swift` (20 tests)

**What They Test**:
- Sign-in flow
- Onboarding navigation (3 screens)
- Main menu navigation
- Settings interactions
- Immersive space entry/exit
- Label interactions
- Conversation UI flow
- Accessibility
- VoiceOver support

**Requirements**:
- ✅ Xcode 16.0+
- ❌ Running simulator or device
- ❌ UI testing framework
- ⚠️  Sign in with Apple (requires Apple ID)
- ⚠️  Microphone permissions

**Why Cannot Run in CI/Command Line**:
- Requires interactive UI
- Needs simulator GUI running
- Depends on system UI elements (alerts, permissions)
- May require human approval for Sign in with Apple

**How to Run** (Manual in Xcode):
```
1. Open project in Xcode
2. Select LanguageImmersionRoomsUITests scheme
3. Select destination: Apple Vision Pro (Simulator)
4. Press ⌘+U or Product → Test
5. Watch simulator perform UI interactions
```

**Expected Results**:
- Most tests should pass in simulator
- Some may require real device (ARKit, speech)
- Sign-in tests may require manual Apple ID approval

**Estimated Time**: 5-10 minutes for full suite

---

### 4. Performance Tests ⚠️  REQUIRES INSTRUMENTS

**Location**: `LanguageImmersionRoomsTests/Performance/`

**File**: `PerformanceTests.swift` (25 tests)

**What They Test**:
- Service method performance
- Data model creation/encoding speed
- Collection operations (filter, map, search)
- Memory usage under load
- Concurrent operations performance
- Baseline metrics

**Requirements**:
- ✅ Xcode 16.0+
- ⚠️  Xcode Instruments (for detailed profiling)
- ✅ Simulator or device
- ⚠️  Consistent hardware (for comparisons)

**How to Run**:

**Basic Performance Tests**:
```bash
xcodebuild test \
  -scheme LanguageImmersionRooms \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -only-testing:LanguageImmersionRoomsTests/Performance
```

**With Profiling** (Xcode):
```
1. Open project in Xcode
2. Product → Profile (⌘+I)
3. Choose "Time Profiler" or "Allocations"
4. Run specific performance tests
5. Analyze results in Instruments
```

**Expected Results**:
- All tests should complete without timeout
- Measure blocks will show timing data
- Memory tests will show allocation metrics

**Performance Targets**:
- Vocabulary translation: < 0.001ms per call
- Object detection: < 3s for full scan
- State updates: < 0.0001ms per update
- Memory: < 100MB increase under load

---

### 5. End-to-End Tests ❌ CANNOT RUN (Requires Full Environment)

**Location**: `LanguageImmersionRoomsTests/EndToEnd/`

**File**: `UserJourneyTests.swift` (10 scenarios)

**What They Test**:
- Complete first-time user journey (sign in → onboarding → learning)
- Returning user workflows
- Complete learning sessions
- Error recovery paths
- Multi-session tracking
- Settings changes across app
- Accessibility compliance

**Requirements**:
- ✅ Xcode 16.0+
- ❌ Running simulator with UI
- ⚠️  OpenAI API key
- ⚠️  Sign in with Apple configured
- ⚠️  Microphone permissions
- ⚠️  Network connection
- ❌ Manual observation recommended

**Why Cannot Run Automatically**:
- Requires complete app environment
- Needs user interaction (Sign in with Apple)
- Depends on external services (OpenAI API)
- May require visual verification
- Long-running (5-15 minutes per journey)

**How to Run** (Manual in Xcode):
```
1. Open project in Xcode
2. Configure OpenAI API key in scheme
3. Select LanguageImmersionRoomsUITests scheme
4. Run specific journey test
5. Observe simulator performing full workflow
6. Verify expected outcomes manually
```

**Test Scenarios**:
1. **First-Time User** (2-3 min): Sign in → Onboarding → First session
2. **Returning User** (1-2 min): Check progress → Settings → Quick session
3. **Learning Session** (3-5 min): Scan → Learn vocabulary → Conversation
4. **Error Recovery** (2-3 min): Network errors → Permission errors
5. **Multiple Sessions** (3-4 min): 3 sequential sessions with progress
6. **Settings Change** (1-2 min): Change settings → Verify in session
7. **Performance** (1-2 min): Timed user flow
8. **Accessibility** (1-2 min): VoiceOver and accessibility checks

---

## Running Tests

### Prerequisites

1. **Install Xcode 16.0+**
   ```bash
   xcode-select --install
   xcode-select -p  # Verify installation
   ```

2. **Set Up API Keys** (for integration tests)
   ```bash
   # In Xcode:
   # Product → Scheme → Edit Scheme → Run → Environment Variables
   # Add: OPENAI_API_KEY = your_key_here

   # Or via command line:
   export OPENAI_API_KEY="your-api-key"
   ```

3. **Configure Simulator**
   ```bash
   # List available simulators
   xcrun simctl list devices

   # Boot Vision Pro simulator
   xcrun simctl boot "Apple Vision Pro"
   ```

### Running All Unit Tests

```bash
cd visionOS_Language-Immersion-Rooms

xcodebuild test \
  -scheme LanguageImmersionRooms \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -only-testing:LanguageImmersionRoomsTests/Unit \
  | xcpretty
```

### Running Specific Test File

```bash
xcodebuild test \
  -scheme LanguageImmersionRooms \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -only-testing:LanguageImmersionRoomsTests/Unit/Models/CoreModelsTests
```

### Running Specific Test Method

```bash
xcodebuild test \
  -scheme LanguageImmersionRooms \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -only-testing:LanguageImmersionRoomsTests/Unit/Models/CoreModelsTests/testLanguageRawValues
```

### Running Tests in Xcode

1. **Open Project**: `open LanguageImmersionRooms.xcodeproj`
2. **Select Test Navigator**: ⌘+6
3. **Run All Tests**: ⌘+U
4. **Run Specific Test**: Click ◆ next to test method
5. **View Results**: Test Navigator shows ✅ or ❌

### Continuous Integration

**GitHub Actions Example**:
```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v3

      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode_16.0.app

      - name: Run Unit Tests
        run: |
          xcodebuild test \
            -scheme LanguageImmersionRooms \
            -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
            -only-testing:LanguageImmersionRoomsTests/Unit

      - name: Run Integration Tests (No API)
        run: |
          xcodebuild test \
            -scheme LanguageImmersionRooms \
            -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
            -only-testing:LanguageImmersionRoomsTests/Integration/ServiceIntegrationTests/testDetectAndTranslateObjects
```

---

## Test Coverage

### Current Coverage by Component

| Component | Unit Tests | Integration Tests | UI Tests | Total |
|-----------|------------|-------------------|----------|-------|
| **Models** | 25 | 3 | 0 | 28 |
| **Services** | 35 | 12 | 0 | 47 |
| **ViewModels** | 18 | 0 | 5 | 23 |
| **UI Views** | 0 | 0 | 15 | 15 |
| **Navigation** | 0 | 0 | 8 | 8 |
| **Integration** | 0 | 10 | 12 | 22 |
| **Total** | **78** | **25** | **40** | **143** |

### Code Coverage Targets

- **Critical Paths**: 90%+ (authentication, learning session)
- **Services**: 80%+ (vocabulary, detection, conversation)
- **Models**: 100% (simple data structures)
- **UI**: 60%+ (basic interaction coverage)
- **Overall**: 75%+

### Measuring Coverage

**In Xcode**:
```
1. Edit Scheme (⌘+<)
2. Test → Options
3. Enable "Gather coverage for: All targets"
4. Run tests (⌘+U)
5. Show Report Navigator (⌘+9)
6. Select latest test run → Coverage tab
```

**Command Line**:
```bash
xcodebuild test \
  -scheme LanguageImmersionRooms \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -enableCodeCoverage YES \
  -only-testing:LanguageImmersionRoomsTests/Unit

# View coverage report
xcrun xccov view --report DerivedData/Logs/Test/*.xcresult
```

---

## Environment Requirements

### ✅ Can Run Without Special Setup

**Unit Tests** - Models, Services (no API), ViewModels:
- ✅ Xcode 16.0+
- ✅ visionOS 2.0 SDK
- ✅ Simulator (no device needed)
- ✅ No network
- ✅ No API keys
- ✅ No permissions

**Estimated Run Time**: 10-30 seconds

---

### ⚠️  Requires Configuration

**Integration Tests** - Full Service Integration:
- ✅ Xcode 16.0+
- ⚠️  OpenAI API key
- ⚠️  Network connection (for API calls)
- ⚠️  May incur API costs (~$0.01-0.10 per test run)

**Setup**:
```bash
export OPENAI_API_KEY="sk-..."
```

**Estimated Run Time**: 30-60 seconds (with network delay)

---

### ❌ Cannot Run in Current Environment

**UI Tests** - Requires Interactive Xcode:
- ❌ GUI simulator running
- ❌ UI testing framework
- ❌ User interaction for auth
- ❌ System permission dialogs
- ❌ Cannot run headless

**Workaround**: Run manually in Xcode on developer machine

**Estimated Run Time**: 5-10 minutes

---

**Performance Tests** - Requires Instruments:
- ⚠️  Xcode Instruments (optional for detailed profiling)
- ⚠️  Consistent hardware (for baseline comparisons)
- ⚠️  Multiple runs for statistical significance

**Can Run**: Basic timing tests via xcodebuild
**Cannot Run**: Detailed Instruments profiling

**Estimated Run Time**: 2-5 minutes

---

**End-to-End Tests** - Requires Full Environment:
- ❌ Complete app setup
- ❌ OpenAI API key
- ❌ Sign in with Apple (user interaction)
- ❌ Microphone permission
- ❌ Network connection
- ❌ Manual verification recommended

**Workaround**: Run manually in Xcode with supervision

**Estimated Run Time**: 10-20 minutes per full journey

---

## Test Results Documentation

### How to Document Test Results

After running tests, document results in this format:

```markdown
## Test Run: [Date]

**Environment**:
- macOS: [version]
- Xcode: [version]
- Simulator: Apple Vision Pro (visionOS [version])
- API Key: [Yes/No]

**Results**:

### Unit Tests
- CoreModelsTests: ✅ 25/25 passed
- VocabularyServiceTests: ✅ 23/23 passed
- ObjectDetectionServiceTests: ✅ 12/12 passed
- AppStateTests: ✅ 18/18 passed
- **Total: 78/78 (100%)**

### Integration Tests
- Without API: ✅ 3/3 passed
- With API: ✅ 12/12 passed
- **Total: 15/15 (100%)**

### UI Tests
- [Not run] / ✅ 20/20 passed
- **Manual verification**: [Yes/No]

### Performance Tests
- All tests completed: ✅ Yes
- Within targets: ✅ Yes
- Baseline established: [Yes/No]

### Coverage
- Overall: 78.5%
- Models: 100%
- Services: 82.3%
- ViewModels: 91.2%
- UI: 45.6%
```

### Test Failure Documentation

When tests fail, document:

1. **Test Name**: Exact test method name
2. **Error Message**: Full error output
3. **Expected**: What should happen
4. **Actual**: What actually happened
5. **Environment**: OS, Xcode, simulator details
6. **Reproducibility**: Always/Sometimes/Once
7. **Fix**: What was changed to fix it

**Example**:
```markdown
### Test Failure Report

**Test**: `testConversationWithVocabulary`
**Date**: 2025-11-24
**Status**: ❌ Failed

**Error**:
```
XCTAssertTrue failed: Response should reference the word
```

**Expected**: AI response contains "mesa" or "table"
**Actual**: AI response was generic, didn't mention specific word

**Environment**:
- macOS 14.0, Xcode 16.0
- visionOS Simulator 2.0

**Reproducibility**: Sometimes (3/5 runs failed)

**Root Cause**: GPT-4 response varies, doesn't always mention exact word

**Fix**: Updated assertion to check for related words or context
```

---

## Quick Reference

### Run Everything That Can Run

```bash
#!/bin/bash
# run_tests.sh

echo "🧪 Running all executable tests..."

# Unit tests (always work)
echo "\n📦 Unit Tests..."
xcodebuild test \
  -scheme LanguageImmersionRooms \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -only-testing:LanguageImmersionRoomsTests/Unit

# Integration tests (without API)
echo "\n🔗 Integration Tests (no API)..."
xcodebuild test \
  -scheme LanguageImmersionRooms \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -only-testing:LanguageImmersionRoomsTests/Integration/ServiceIntegrationTests/testDetectAndTranslateObjects

# If API key set, run full integration
if [ -n "$OPENAI_API_KEY" ]; then
  echo "\n🤖 Integration Tests (with API)..."
  xcodebuild test \
    -scheme LanguageImmersionRooms \
    -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
    -only-testing:LanguageImmersionRoomsTests/Integration
fi

echo "\n✅ Tests complete!"
```

---

## Summary

| Test Type | Count | Can Run? | Requirements | Time |
|-----------|-------|----------|--------------|------|
| **Unit Tests** | 78 | ✅ Yes | Xcode only | 30s |
| **Integration** | 15 | ⚠️  Partial | +API key | 60s |
| **UI Tests** | 20 | ❌ Xcode GUI | +Simulator GUI | 10m |
| **Performance** | 25 | ⚠️  Basic | +Instruments for detail | 5m |
| **End-to-End** | 10 | ❌ Manual | +Full setup | 20m |
| **Total** | **148** | **~60%** | - | **~36m** |

**Recommendation**:
1. Run unit tests on every commit (fast, reliable)
2. Run integration tests daily (with API key)
3. Run UI/E2E tests before releases (manual, supervised)
4. Run performance tests weekly (establish baselines)

---

**Last Updated**: 2025-11-24
**Test Suite Version**: 1.0
**App Version**: MVP 1.0
