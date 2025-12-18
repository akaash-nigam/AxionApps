# Test Update Guide

**⚠️ IMPORTANT**: The test files were created in a Linux environment without Swift compiler or Xcode access. They will need updates when first compiled.

## Expected Issues

### 1. API Signature Mismatches

#### StoryDirectorAI

**Tests Expect**:
```swift
func detectPlayerArchetype(choiceHistory: [Choice], playtime: TimeInterval) -> PlayerArchetype
```

**Actual Implementation**:
```swift
private func analyzePlayerArchetype(_ history: [ChoiceRecord]) -> PlayerArchetype
```

**Fix Required**:
- Remove or update tests that call `detectPlayerArchetype`
- Tests should use public API: `selectBranch(availableBranches:playerHistory:)`
- Or make `analyzePlayerArchetype` public if needed for testing

#### Example Fix:
```swift
// Instead of:
let archetype = storyDirector.detectPlayerArchetype(choiceHistory: history, playtime: 3600)

// Use:
let choiceRecords = history.map { ChoiceRecord(from: $0) }
let branch = storyDirector.selectBranch(
    availableBranches: testBranches,
    playerHistory: choiceRecords
)
// Then verify branch selection matches expected archetype
```

### 2. Missing Helper Types

The following types are used in tests but may not be defined:

#### DialogueContext
```swift
struct DialogueContext {
    let situationType: SituationType
    let previousDialogues: [DialogueNode]
    let playerChoices: [Choice]
    let environmentalFactors: [String]
    let characterMemories: [CharacterMemory]
    var variables: [String: String] = [:]
}

enum SituationType {
    case greeting
    case conflict
    case storytelling
    case conversation
    case celebration
    case danger
    case followUp
    case intimateMoment
    case gratitude
    case response
}
```

#### StoryEvent
```swift
struct StoryEvent {
    let type: EventType
    let timestamp: Date

    enum EventType {
        case playerChoice(Choice)
        case dialogueCompleted(UUID)
        case chapterCompleted(UUID)
        case achievementUnlocked(UUID)
    }
}
```

#### RelationshipImpact
```swift
enum RelationshipImpact {
    case trust(Float)
    case affection(Float)
    case fear(Float)
    case anger(Float)
}
```

#### UnlockCondition
```swift
enum UnlockCondition {
    case choicesMade(Int)
    case chapterCompleted(UUID)
    case relationshipLevel(characterID: UUID, level: Float)
}
```

#### Achievement
```swift
struct Achievement {
    let id: UUID
    let title: String
    let description: String
    let iconName: String
    let unlockCondition: UnlockCondition
    var isUnlocked: Bool
    var unlockedDate: Date?
}
```

**Action**: Add these types to appropriate files or create test fixtures.

### 3. Test Extension Implementations

Several test extensions provide mock implementations:

#### AppModel Extensions
```swift
extension AppModel {
    var choiceHistory: [Choice] { get set }
    var achievements: [Achievement] { get set }

    func makeChoice(_ choice: Choice)
    func checkAchievements()
}
```

**Action**: Either:
- Add these properties/methods to AppModel, or
- Create `AppModel+Testing.swift` with test-only extensions

#### Mock Types

Several mock types are defined at bottom of test files:

```swift
class MockDialogueView
struct GazeMetrics
enum ThermalState
enum HapticType
```

**Action**: Move to dedicated `TestHelpers.swift` or `Mocks.swift` file.

### 4. Import Issues

**Tests Use**:
```swift
@testable import NarrativeStoryWorlds
```

**Verify**:
- Module name matches project configuration
- Test target has proper dependencies on app target
- All types are accessible (public or internal with @testable)

### 5. Type Mismatches

#### Choice vs ChoiceRecord

Tests often use `Choice` where implementation expects `ChoiceRecord`.

**Fix**: Create conversion helper:
```swift
extension ChoiceRecord {
    init(from choice: Choice, selectedOption: UUID, type: ChoiceType) {
        self.choiceID = choice.id
        self.optionSelected = selectedOption
        self.timestamp = Date()
        self.choiceType = type
    }
}
```

#### StoryBranch

Tests reference `StoryBranch` but this type may not exist.

**Options**:
1. Define `StoryBranch` type
2. Use existing `Chapter` or `Scene` types
3. Update tests to use actual types

---

## Compilation Fix Process

### Step 1: Build for Testing
```bash
xcodebuild build-for-testing \
  -scheme NarrativeStoryWorlds \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
```

This will show all compilation errors.

### Step 2: Fix Errors by Category

1. **Missing Types**
   - Add type definitions to appropriate files
   - Or create `TestHelpers.swift` with test-only types

2. **API Mismatches**
   - Update test method calls to match actual signatures
   - Or expose additional methods for testing

3. **Import Issues**
   - Verify target membership
   - Check module name in project settings

### Step 3: Organize Test Fixtures

Create `Tests/Fixtures/` directory:
```
Tests/
├── Fixtures/
│   ├── TestHelpers.swift      # Helper functions
│   ├── MockTypes.swift         # Mock implementations
│   ├── TestData.swift          # Test data factories
│   └── Extensions.swift        # Test-only extensions
├── AISystemTests.swift
├── IntegrationTests.swift
└── PerformanceTests.swift
```

### Step 4: Run Tests

```bash
xcodebuild test \
  -scheme NarrativeStoryWorlds \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
```

### Step 5: Fix Test Logic

After compilation succeeds, tests may fail due to:
- Incorrect expectations
- Logic errors
- Actual behavior differs from assumed

Iterate on these until tests pass.

---

## Recommended Updates by File

### AISystemTests.swift

**Priority**: High (P0)

**Issues**:
- `detectPlayerArchetype` method doesn't exist
- Need `StoryEvent`, `DialogueContext` types
- Character memory methods may not be public

**Fixes**:
1. Add missing type definitions
2. Update player archetype tests to use public API
3. Make `recallRelevantMemories` public or test differently
4. Add `DialogueContext` type or use actual context type

**Estimated Time**: 2-3 hours

### IntegrationTests.swift

**Priority**: High (P0)

**Issues**:
- `AppModel.makeChoice(_:)` may not exist
- `AppModel.checkAchievements()` may not exist
- `Achievement`, `UnlockCondition`, `RelationshipImpact` types missing
- `StoryState` serialization helpers needed

**Fixes**:
1. Add achievement system to AppModel
2. Implement choice history tracking
3. Add relationship impact system
4. Create test extensions for AppModel

**Estimated Time**: 3-4 hours

### PerformanceTests.swift

**Priority**: Medium (P1)

**Issues**:
- Mock types used extensively
- Some methods may have different signatures
- Performance baselines need hardware validation

**Fixes**:
1. Create proper mock implementations
2. Update method signatures
3. Run on hardware to establish real baselines
4. Adjust baseline expectations

**Estimated Time**: 2-3 hours

---

## Priority Order

### Phase 1: Critical Fixes (Compile Tests)
1. Add missing type definitions
2. Fix import statements
3. Update API signatures
4. Get tests to compile

**Target**: All tests compile without errors

### Phase 2: Test Logic (Run Tests)
1. Fix test logic errors
2. Add proper mock implementations
3. Update expectations to match actual behavior
4. Get core tests passing

**Target**: 80%+ of tests pass

### Phase 3: Coverage (Complete Suite)
1. Add missing test cases
2. Improve coverage of edge cases
3. Add UI tests (requires simulator/hardware)
4. Verify coverage goals met

**Target**: 70%+ overall coverage, 80%+ AI systems

### Phase 4: Hardware Validation
1. Run performance tests on Vision Pro
2. Establish real performance baselines
3. Execute hardware test procedures
4. Update baselines with real data

**Target**: All P0 hardware tests pass

---

## Quick Reference

### Test Files
- `AISystemTests.swift` - 34 unit tests for AI systems
- `IntegrationTests.swift` - 14 integration tests
- `PerformanceTests.swift` - 25+ performance tests

### Documentation
- `TEST_STRATEGY.md` - Overall test strategy
- `VISIONOS_HARDWARE_TESTS.md` - Hardware test procedures
- `README.md` - Test execution guide

### CI/CD
- `.github/workflows/test.yml` - Automated testing
- `.swiftlint.yml` - Code quality

---

## Getting Help

### Compilation Errors

If stuck on compilation errors:
1. Check error messages carefully
2. Look for missing types in error details
3. Verify import statements
4. Check target membership in File Inspector

### Test Failures

If tests fail after compilation:
1. Read test names to understand intent
2. Compare expected vs actual values
3. Check if behavior changed from design
4. Update test or implementation accordingly

### Coverage Issues

If coverage is below target:
1. Run coverage report to see gaps
2. Add tests for uncovered code paths
3. Remove dead code if found
4. Focus on critical paths first

---

## Success Criteria

**Phase 1 Complete** ✅
- [ ] All test files compile
- [ ] No import errors
- [ ] All dependencies resolved

**Phase 2 Complete** ✅
- [ ] 80%+ of tests pass
- [ ] No critical test failures
- [ ] Coverage data generated

**Phase 3 Complete** ✅
- [ ] 70%+ overall coverage
- [ ] 80%+ AI systems coverage
- [ ] All P0 tests pass

**Phase 4 Complete** ✅
- [ ] Performance baselines established on hardware
- [ ] All P0 hardware tests pass
- [ ] Production-ready test suite

---

**Created**: 2025-11-19
**Purpose**: Guide for fixing tests when opening in Xcode
**Estimated Total Time**: 10-15 hours across all phases
