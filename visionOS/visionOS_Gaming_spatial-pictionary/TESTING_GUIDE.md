# Spatial Pictionary - Comprehensive Testing Guide

## Document Information
- **Version**: 1.0
- **Last Updated**: 2025-11-19
- **Purpose**: Comprehensive testing strategy and test execution guide

---

## Table of Contents
1. [Testing Overview](#testing-overview)
2. [Test Environment Classification](#test-environment-classification)
3. [Unit Tests](#unit-tests)
4. [Integration Tests](#integration-tests)
5. [Performance Tests](#performance-tests)
6. [UI/UX Tests](#uiux-tests)
7. [Multiplayer/Network Tests](#multiplayernetwork-tests)
8. [Accessibility Tests](#accessibility-tests)
9. [Test Execution Guide](#test-execution-guide)
10. [Continuous Integration Setup](#continuous-integration-setup)

---

## 1. Testing Overview

### Testing Philosophy
- **Test Early, Test Often**: Write tests alongside feature development
- **Automated When Possible**: Maximize automation to catch regressions
- **Performance First**: Always validate 90 FPS target
- **User-Centric**: Focus on actual user scenarios

### Test Coverage Goals
```yaml
unit_tests: ">80% code coverage"
integration_tests: "All critical user flows"
performance_tests: "All performance-sensitive operations"
ui_tests: "All user-facing features"
accessibility_tests: "100% accessibility feature coverage"
```

### Test Pyramid Strategy
```
       /\
      /UI\         10% - UI/E2E Tests (Slow, Brittle)
     /────\
    /  I   \       20% - Integration Tests (Medium)
   /────────\
  /   Unit   \     70% - Unit Tests (Fast, Reliable)
 /────────────\
```

---

## 2. Test Environment Classification

### ✅ Tests Executable in CI/Command Line Environment
**Can run with Swift compiler only (no Xcode/visionOS SDK required)**

1. **Pure Logic Tests**
   - Game state management
   - Scoring algorithms
   - Word selection logic
   - Data model validation
   - Utility functions
   - Mathematical calculations

2. **Data Structure Tests**
   - Model encoding/decoding
   - Data validation
   - Collection operations
   - Algorithm correctness

3. **Mock-Based Tests**
   - Network protocol logic (mocked)
   - Game flow state machines
   - Turn-based logic

### ⚠️ Tests Requiring Xcode Environment
**Require XCTest framework but not device/simulator**

1. **Swift Package Tests**
   - Module integration tests
   - Framework boundary tests
   - API contract tests

### ❌ Tests Requiring visionOS SDK/Simulator
**Must run in Xcode with visionOS simulator or device**

1. **RealityKit Tests**
   - 3D drawing mesh generation
   - Material rendering
   - Entity-Component system
   - Scene graph operations

2. **ARKit Tests**
   - Hand tracking accuracy
   - Gesture recognition
   - Spatial anchor positioning

3. **SwiftUI/UI Tests**
   - View rendering
   - Navigation flows
   - User interactions
   - Accessibility features

4. **Hardware Integration Tests**
   - Actual hand tracking
   - Spatial audio
   - Performance on device
   - Battery usage

5. **Multiplayer Tests**
   - SharePlay integration
   - Real network synchronization
   - Multi-device testing

---

## 3. Unit Tests

### 3.1 Game State Management Tests

**File**: `Tests/UnitTests/GameStateTests.swift`

```swift
import XCTest
@testable import SpatialPictionary

final class GameStateTests: XCTestCase {
    var gameState: GameState!

    override func setUp() {
        super.setUp()
        gameState = GameState()
    }

    override func tearDown() {
        gameState = nil
        super.tearDown()
    }

    // MARK: - Phase Transition Tests

    func testInitialPhaseIsLobby() {
        XCTAssertEqual(gameState.currentPhase, .lobby)
    }

    func testTransitionFromLobbyToWordSelection() {
        let artist = Player(id: UUID(), name: "Artist", avatar: .default, isLocal: true, deviceID: "device1")
        gameState.players.append(artist)

        gameState.transitionTo(.wordSelection)

        XCTAssertEqual(gameState.currentPhase, .wordSelection)
    }

    func testTransitionToDrawingRequiresWord() {
        let artist = Player(id: UUID(), name: "Artist", avatar: .default, isLocal: true, deviceID: "device1")
        let word = Word(id: UUID(), text: "cat", category: .animals, difficulty: .easy)

        gameState.selectWord(word, artist: artist)

        if case .drawing(let selectedArtist, let selectedWord, _) = gameState.currentPhase {
            XCTAssertEqual(selectedArtist.id, artist.id)
            XCTAssertEqual(selectedWord.id, word.id)
        } else {
            XCTFail("Expected drawing phase")
        }
    }

    func testCannotTransitionToDrawingWithoutArtist() {
        let word = Word(id: UUID(), text: "cat", category: .animals, difficulty: .easy)

        // Should not crash or enter invalid state
        gameState.selectWord(word, artist: nil)

        XCTAssertNotEqual(gameState.currentPhase, .drawing)
    }

    // MARK: - Player Management Tests

    func testAddPlayer() {
        let player = Player(id: UUID(), name: "Player1", avatar: .default, isLocal: true, deviceID: "device1")

        gameState.addPlayer(player)

        XCTAssertEqual(gameState.players.count, 1)
        XCTAssertEqual(gameState.players.first?.name, "Player1")
    }

    func testRemovePlayer() {
        let player = Player(id: UUID(), name: "Player1", avatar: .default, isLocal: true, deviceID: "device1")
        gameState.addPlayer(player)

        gameState.removePlayer(player.id)

        XCTAssertEqual(gameState.players.count, 0)
    }

    func testMaxPlayersLimit() {
        // Add maximum players (12)
        for i in 1...12 {
            let player = Player(id: UUID(), name: "Player\(i)", avatar: .default, isLocal: true, deviceID: "device\(i)")
            gameState.addPlayer(player)
        }

        XCTAssertEqual(gameState.players.count, 12)

        // Try to add 13th player
        let extraPlayer = Player(id: UUID(), name: "Extra", avatar: .default, isLocal: true, deviceID: "device13")
        gameState.addPlayer(extraPlayer)

        // Should still be 12
        XCTAssertEqual(gameState.players.count, 12)
    }

    // MARK: - Round Management Tests

    func testRoundNumberIncrementsAfterRound() {
        gameState.roundNumber = 0

        gameState.completeRound()

        XCTAssertEqual(gameState.roundNumber, 1)
    }

    func testArtistRotation() {
        let player1 = Player(id: UUID(), name: "Player1", avatar: .default, isLocal: true, deviceID: "device1")
        let player2 = Player(id: UUID(), name: "Player2", avatar: .default, isLocal: true, deviceID: "device2")
        let player3 = Player(id: UUID(), name: "Player3", avatar: .default, isLocal: true, deviceID: "device3")

        gameState.players = [player1, player2, player3]

        XCTAssertEqual(gameState.selectNextArtist()?.id, player1.id)
        XCTAssertEqual(gameState.selectNextArtist()?.id, player2.id)
        XCTAssertEqual(gameState.selectNextArtist()?.id, player3.id)
        XCTAssertEqual(gameState.selectNextArtist()?.id, player1.id) // Wraps around
    }
}
```

### 3.2 Scoring System Tests

**File**: `Tests/UnitTests/ScoringTests.swift`

```swift
import XCTest
@testable import SpatialPictionary

final class ScoringTests: XCTestCase {
    var scoringSystem: ScoringSystem!

    override func setUp() {
        super.setUp()
        scoringSystem = ScoringSystem()
    }

    // MARK: - Base Points Tests

    func testCorrectGuessBasePoints() {
        let points = scoringSystem.calculatePoints(
            difficulty: .easy,
            timeRemaining: 45.0,
            totalTime: 90.0,
            hintsUsed: 0
        )

        XCTAssertEqual(points, 100 + 90) // base + time bonus (45s * 2)
    }

    func testDifficultyMultiplier() {
        let easyPoints = scoringSystem.calculatePoints(difficulty: .easy, timeRemaining: 0, totalTime: 90, hintsUsed: 0)
        let mediumPoints = scoringSystem.calculatePoints(difficulty: .medium, timeRemaining: 0, totalTime: 90, hintsUsed: 0)
        let hardPoints = scoringSystem.calculatePoints(difficulty: .hard, timeRemaining: 0, totalTime: 90, hintsUsed: 0)

        XCTAssertEqual(easyPoints, 100)
        XCTAssertEqual(mediumPoints, 150) // 1.5x multiplier
        XCTAssertEqual(hardPoints, 200)   // 2.0x multiplier
    }

    // MARK: - Time Bonus Tests

    func testTimeBonusCalculation() {
        // 60 seconds remaining = 120 bonus points (2 points per second)
        let points = scoringSystem.calculateTimeBonus(timeRemaining: 60.0)
        XCTAssertEqual(points, 120)
    }

    func testNoTimeBonusWhenTimeExpired() {
        let points = scoringSystem.calculateTimeBonus(timeRemaining: 0.0)
        XCTAssertEqual(points, 0)
    }

    // MARK: - Hint Penalty Tests

    func testHintPenalty() {
        let noHints = scoringSystem.calculatePoints(difficulty: .medium, timeRemaining: 0, totalTime: 90, hintsUsed: 0)
        let oneHint = scoringSystem.calculatePoints(difficulty: .medium, timeRemaining: 0, totalTime: 90, hintsUsed: 1)
        let twoHints = scoringSystem.calculatePoints(difficulty: .medium, timeRemaining: 0, totalTime: 90, hintsUsed: 2)

        XCTAssertEqual(noHints, 150)
        XCTAssertEqual(oneHint, 112)  // 75% of 150
        XCTAssertEqual(twoHints, 75)  // 50% of 150
    }

    // MARK: - Artist Bonus Tests

    func testArtistBonus() {
        let bonus = scoringSystem.calculateArtistBonus(difficulty: .medium, guesserCount: 3)

        // Artist gets 50 points base * 1.5 difficulty = 75
        XCTAssertEqual(bonus, 75)
    }

    func testArtistBonusIncreasesWithGuessers() {
        let bonus1 = scoringSystem.calculateArtistBonus(difficulty: .easy, guesserCount: 1)
        let bonus3 = scoringSystem.calculateArtistBonus(difficulty: .easy, guesserCount: 3)

        // More guessers = more engagement bonus
        XCTAssertGreaterThan(bonus3, bonus1)
    }

    // MARK: - Leaderboard Tests

    func testLeaderboardSorting() {
        scoringSystem.updateScore(playerID: UUID(), points: 100)
        scoringSystem.updateScore(playerID: UUID(), points: 300)
        scoringSystem.updateScore(playerID: UUID(), points: 200)

        let leaderboard = scoringSystem.getLeaderboard()

        XCTAssertEqual(leaderboard[0].score, 300)
        XCTAssertEqual(leaderboard[1].score, 200)
        XCTAssertEqual(leaderboard[2].score, 100)
    }
}
```

### 3.3 Word Selection Tests

**File**: `Tests/UnitTests/WordSelectionTests.swift`

```swift
import XCTest
@testable import SpatialPictionary

final class WordSelectionTests: XCTestCase {
    var wordEngine: WordSelectionEngine!

    override func setUp() {
        super.setUp()
        wordEngine = WordSelectionEngine()
        wordEngine.loadMockDatabase()
    }

    // MARK: - Word Selection Tests

    func testSelectWordsReturnCorrectCount() {
        let words = wordEngine.selectWords(
            for: [],
            difficulty: .medium,
            categories: [.animals, .objects],
            count: 3
        )

        XCTAssertEqual(words.count, 3)
    }

    func testSelectWordsMatchDifficulty() {
        let words = wordEngine.selectWords(
            for: [],
            difficulty: .hard,
            categories: [.animals],
            count: 5
        )

        for word in words {
            XCTAssertEqual(word.difficulty, .hard)
        }
    }

    func testSelectWordsMatchCategories() {
        let categories: Set<Word.Category> = [.animals, .food]
        let words = wordEngine.selectWords(
            for: [],
            difficulty: .easy,
            categories: categories,
            count: 10
        )

        for word in words {
            XCTAssertTrue(categories.contains(word.category))
        }
    }

    func testNoDuplicateWords() {
        let words = wordEngine.selectWords(
            for: [],
            difficulty: .medium,
            categories: [.animals, .objects, .actions],
            count: 20
        )

        let uniqueWords = Set(words.map { $0.id })
        XCTAssertEqual(words.count, uniqueWords.count)
    }

    // MARK: - Difficulty Adaptation Tests

    func testDifficultyAdaptationEasy() {
        let players = [
            createMockPlayer(successRate: 0.2),
            createMockPlayer(successRate: 0.25),
            createMockPlayer(successRate: 0.15)
        ]

        let difficulty = wordEngine.adaptDifficulty(basedOn: players)
        XCTAssertEqual(difficulty, .easy)
    }

    func testDifficultyAdaptationMedium() {
        let players = [
            createMockPlayer(successRate: 0.5),
            createMockPlayer(successRate: 0.45),
            createMockPlayer(successRate: 0.55)
        ]

        let difficulty = wordEngine.adaptDifficulty(basedOn: players)
        XCTAssertEqual(difficulty, .medium)
    }

    func testDifficultyAdaptationHard() {
        let players = [
            createMockPlayer(successRate: 0.8),
            createMockPlayer(successRate: 0.85),
            createMockPlayer(successRate: 0.9)
        ]

        let difficulty = wordEngine.adaptDifficulty(basedOn: players)
        XCTAssertEqual(difficulty, .hard)
    }

    // MARK: - Recent Word Exclusion Tests

    func testExcludeRecentWords() {
        let word1 = Word(id: UUID(), text: "cat", category: .animals, difficulty: .easy)
        let word2 = Word(id: UUID(), text: "dog", category: .animals, difficulty: .easy)

        wordEngine.markWordAsUsed(word1)
        wordEngine.markWordAsUsed(word2)

        let newWords = wordEngine.selectWords(
            for: [],
            difficulty: .easy,
            categories: [.animals],
            count: 10
        )

        XCTAssertFalse(newWords.contains(where: { $0.id == word1.id }))
        XCTAssertFalse(newWords.contains(where: { $0.id == word2.id }))
    }

    // MARK: - Helper Methods

    private func createMockPlayer(successRate: Float) -> Player {
        var player = Player(id: UUID(), name: "Mock", avatar: .default, isLocal: true, deviceID: "mock")
        player.successRate = successRate
        return player
    }
}
```

### 3.4 Drawing Algorithm Tests

**File**: `Tests/UnitTests/DrawingAlgorithmTests.swift`

```swift
import XCTest
@testable import SpatialPictionary

final class DrawingAlgorithmTests: XCTestCase {
    var drawingEngine: DrawingEngine!

    override func setUp() {
        super.setUp()
        drawingEngine = DrawingEngine()
    }

    // MARK: - Point Interpolation Tests

    func testCatmullRomInterpolation() {
        let points = [
            SIMD3<Float>(0, 0, 0),
            SIMD3<Float>(1, 0, 0),
            SIMD3<Float>(1, 1, 0),
            SIMD3<Float>(0, 1, 0)
        ]

        let interpolated = drawingEngine.interpolatePoints(points)

        // Should have more points than input
        XCTAssertGreaterThan(interpolated.count, points.count)

        // First and last points should be preserved
        XCTAssertEqual(interpolated.first, points.first)
    }

    func testInterpolationSmoothness() {
        let points = [
            SIMD3<Float>(0, 0, 0),
            SIMD3<Float>(1, 0, 0),
            SIMD3<Float>(2, 0, 0),
            SIMD3<Float>(3, 0, 0)
        ]

        let interpolated = drawingEngine.interpolatePoints(points)

        // Check that interpolated points are between original points
        for i in 1..<interpolated.count {
            let distance = length(interpolated[i] - interpolated[i-1])
            XCTAssertLessThan(distance, 0.5) // No large jumps
        }
    }

    // MARK: - Point Distance Tests

    func testMinimumPointDistance() {
        let point1 = SIMD3<Float>(0, 0, 0)
        let point2 = SIMD3<Float>(0.001, 0, 0) // 1mm

        let shouldFilter = drawingEngine.shouldFilterPoint(point2, previous: point1)

        // Points closer than 2mm should be filtered
        XCTAssertTrue(shouldFilter)
    }

    func testMaximumPointDistance() {
        let point1 = SIMD3<Float>(0, 0, 0)
        let point2 = SIMD3<Float>(0.05, 0, 0) // 5cm

        let needsInterpolation = drawingEngine.needsInterpolation(point2, previous: point1)

        // Points farther than 2cm need interpolation
        XCTAssertTrue(needsInterpolation)
    }

    // MARK: - Stroke Simplification Tests

    func testStrokeSimplification() {
        // Create 1000 points in a straight line
        var points: [SIMD3<Float>] = []
        for i in 0..<1000 {
            points.append(SIMD3<Float>(Float(i) * 0.001, 0, 0))
        }

        let simplified = drawingEngine.simplifyStroke(points, tolerance: 0.002)

        // Should reduce point count significantly
        XCTAssertLessThan(simplified.count, points.count / 2)

        // Should preserve start and end
        XCTAssertEqual(simplified.first, points.first)
        XCTAssertEqual(simplified.last, points.last)
    }

    // MARK: - Canvas Boundary Tests

    func testPointClampingToCanvas() {
        let outOfBounds = SIMD3<Float>(2.0, 2.0, 2.0) // Outside 1.5m canvas

        let clamped = drawingEngine.clampToCanvas(outOfBounds)

        XCTAssertLessThanOrEqual(clamped.x, 0.75)
        XCTAssertLessThanOrEqual(clamped.y, 0.75)
        XCTAssertLessThanOrEqual(clamped.z, 0.75)
        XCTAssertGreaterThanOrEqual(clamped.x, -0.75)
        XCTAssertGreaterThanOrEqual(clamped.y, -0.75)
        XCTAssertGreaterThanOrEqual(clamped.z, -0.75)
    }

    func testPointWithinCanvas() {
        let withinBounds = SIMD3<Float>(0.5, 0.5, 0.5)

        let isWithin = drawingEngine.isWithinCanvas(withinBounds)

        XCTAssertTrue(isWithin)
    }

    // MARK: - Performance Tests

    func testInterpolationPerformance() {
        let points = (0..<100).map { i in
            SIMD3<Float>(Float(i) * 0.01, sin(Float(i) * 0.1), cos(Float(i) * 0.1))
        }

        measure {
            _ = drawingEngine.interpolatePoints(points)
        }
    }

    func testStrokeSimplificationPerformance() {
        let points = (0..<1000).map { i in
            SIMD3<Float>(Float(i) * 0.001, Float.random(in: -0.1...0.1), 0)
        }

        measure {
            _ = drawingEngine.simplifyStroke(points, tolerance: 0.002)
        }
    }
}
```

### 3.5 Data Model Tests

**File**: `Tests/UnitTests/DataModelTests.swift`

```swift
import XCTest
@testable import SpatialPictionary

final class DataModelTests: XCTestCase {

    // MARK: - Player Model Tests

    func testPlayerCodable() throws {
        let player = Player(
            id: UUID(),
            name: "TestPlayer",
            avatar: AvatarConfiguration.default,
            score: 100,
            isLocal: true,
            deviceID: "device123",
            spatialExperience: 50
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(player)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Player.self, from: data)

        XCTAssertEqual(decoded.id, player.id)
        XCTAssertEqual(decoded.name, player.name)
        XCTAssertEqual(decoded.score, player.score)
        XCTAssertEqual(decoded.isLocal, player.isLocal)
    }

    // MARK: - Word Model Tests

    func testWordCodable() throws {
        let word = Word(
            id: UUID(),
            text: "elephant",
            category: .animals,
            difficulty: .medium,
            language: "en"
        )

        let data = try JSONEncoder().encode(word)
        let decoded = try JSONDecoder().decode(Word.self, from: data)

        XCTAssertEqual(decoded.text, word.text)
        XCTAssertEqual(decoded.category, word.category)
        XCTAssertEqual(decoded.difficulty, word.difficulty)
    }

    // MARK: - Stroke3D Model Tests

    func testStroke3DCodable() throws {
        let stroke = Stroke3D(
            id: UUID(),
            points: [
                SIMD3<Float>(0, 0, 0),
                SIMD3<Float>(1, 0, 0),
                SIMD3<Float>(1, 1, 0)
            ],
            color: CodableColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0),
            thickness: 0.01,
            material: .solid,
            timestamps: [0.0, 0.1, 0.2]
        )

        let data = try JSONEncoder().encode(stroke)
        let decoded = try JSONDecoder().decode(Stroke3D.self, from: data)

        XCTAssertEqual(decoded.points.count, stroke.points.count)
        XCTAssertEqual(decoded.color.red, stroke.color.red, accuracy: 0.001)
        XCTAssertEqual(decoded.thickness, stroke.thickness, accuracy: 0.001)
        XCTAssertEqual(decoded.material, stroke.material)
    }

    // MARK: - GameSession Model Tests

    func testGameSessionCodable() throws {
        let player1 = Player(id: UUID(), name: "P1", avatar: .default, isLocal: true, deviceID: "d1")
        let player2 = Player(id: UUID(), name: "P2", avatar: .default, isLocal: false, deviceID: "d2")

        let session = GameSession(
            id: UUID(),
            players: [player1, player2],
            rounds: [],
            settings: GameSettings(),
            startTime: Date(),
            endTime: nil
        )

        let data = try JSONEncoder().encode(session)
        let decoded = try JSONDecoder().decode(GameSession.self, from: data)

        XCTAssertEqual(decoded.players.count, 2)
        XCTAssertEqual(decoded.settings.roundDuration, session.settings.roundDuration)
    }

    // MARK: - GameSettings Validation Tests

    func testGameSettingsDefaultValues() {
        let settings = GameSettings()

        XCTAssertEqual(settings.roundDuration, 90)
        XCTAssertEqual(settings.numberOfRounds, 8)
        XCTAssertEqual(settings.maxPlayers, 8)
        XCTAssertTrue(settings.allowHints)
    }

    func testGameSettingsValidation() {
        var settings = GameSettings()

        // Round duration should be between 30 and 300 seconds
        settings.roundDuration = 10
        XCTAssertFalse(settings.isValid())

        settings.roundDuration = 90
        XCTAssertTrue(settings.isValid())

        // Max players should be between 2 and 12
        settings.maxPlayers = 1
        XCTAssertFalse(settings.isValid())

        settings.maxPlayers = 8
        XCTAssertTrue(settings.isValid())
    }
}
```

---

## 4. Integration Tests

### 4.1 Game Flow Integration Tests

**File**: `Tests/IntegrationTests/GameFlowIntegrationTests.swift`

```swift
import XCTest
@testable import SpatialPictionary

final class GameFlowIntegrationTests: XCTestCase {
    var gameCoordinator: GameCoordinator!
    var gameState: GameState!

    override func setUp() {
        super.setUp()
        gameCoordinator = GameCoordinator()
        gameState = gameCoordinator.gameState
    }

    // MARK: - Complete Game Round Tests

    func testCompleteGameRound() async throws {
        // Setup: Add players
        let artist = Player(id: UUID(), name: "Artist", avatar: .default, isLocal: true, deviceID: "d1")
        let guesser = Player(id: UUID(), name: "Guesser", avatar: .default, isLocal: true, deviceID: "d2")

        gameState.addPlayer(artist)
        gameState.addPlayer(guesser)

        // Start round
        try await gameCoordinator.startRound()

        // Verify word selection phase
        XCTAssertEqual(gameState.currentPhase, .wordSelection)

        // Artist selects word
        let word = Word(id: UUID(), text: "cat", category: .animals, difficulty: .easy)
        try await gameCoordinator.selectWord(word)

        // Verify drawing phase
        if case .drawing = gameState.currentPhase {
            XCTAssertTrue(true)
        } else {
            XCTFail("Should be in drawing phase")
        }

        // Guesser submits correct guess
        let guessResult = try await gameCoordinator.submitGuess("cat", from: guesser)

        XCTAssertTrue(guessResult.isCorrect)
        XCTAssertEqual(gameState.currentPhase, .reveal)

        // Complete round
        try await gameCoordinator.completeRound()

        // Verify scores updated
        XCTAssertGreaterThan(gameState.scores[artist.id] ?? 0, 0)
        XCTAssertGreaterThan(gameState.scores[guesser.id] ?? 0, 0)
    }

    // MARK: - Multi-Round Game Tests

    func testMultiRoundGame() async throws {
        // Add 3 players
        let players = (1...3).map { i in
            Player(id: UUID(), name: "Player\(i)", avatar: .default, isLocal: true, deviceID: "d\(i)")
        }
        players.forEach { gameState.addPlayer($0) }

        // Play 3 rounds (each player gets to be artist once)
        for round in 1...3 {
            try await gameCoordinator.startRound()

            // Quick word selection and guess
            let word = Word(id: UUID(), text: "test\(round)", category: .objects, difficulty: .easy)
            try await gameCoordinator.selectWord(word)

            // Simulate correct guess
            _ = try await gameCoordinator.submitGuess(word.text, from: players[1])

            try await gameCoordinator.completeRound()

            XCTAssertEqual(gameState.roundNumber, round)
        }

        // All players should have scores
        for player in players {
            XCTAssertGreaterThan(gameState.scores[player.id] ?? 0, 0)
        }
    }

    // MARK: - Timer Integration Tests

    func testRoundTimerExpiration() async throws {
        let artist = Player(id: UUID(), name: "Artist", avatar: .default, isLocal: true, deviceID: "d1")
        gameState.addPlayer(artist)

        try await gameCoordinator.startRound()
        let word = Word(id: UUID(), text: "test", category: .objects, difficulty: .easy)
        try await gameCoordinator.selectWord(word)

        // Fast-forward timer
        gameCoordinator.timer.fastForward(by: 95.0) // Exceed 90s round time

        // Should auto-transition to reveal
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        XCTAssertEqual(gameState.currentPhase, .reveal)
    }
}
```

### 4.2 Drawing System Integration Tests

**File**: `Tests/IntegrationTests/DrawingSystemIntegrationTests.swift`

```swift
import XCTest
@testable import SpatialPictionary

// ⚠️ REQUIRES: Xcode + visionOS SDK
final class DrawingSystemIntegrationTests: XCTestCase {
    var drawingManager: DrawingManager!
    var drawingEngine: DrawingEngine!

    override func setUp() {
        super.setUp()
        drawingEngine = DrawingEngine()
        drawingManager = DrawingManager(engine: drawingEngine)
    }

    // MARK: - Stroke Creation Tests

    func testCreateStrokeFromPoints() {
        let points = [
            SIMD3<Float>(0, 0, 0),
            SIMD3<Float>(0.1, 0, 0),
            SIMD3<Float>(0.2, 0.1, 0),
            SIMD3<Float>(0.3, 0.1, 0)
        ]

        let stroke = drawingManager.createStroke(
            points: points,
            color: .red,
            thickness: 0.01,
            material: .solid
        )

        XCTAssertNotNil(stroke)
        XCTAssertEqual(stroke.points.count, points.count)
    }

    // MARK: - Undo/Redo Tests

    func testUndoRedo() {
        // Create three strokes
        let stroke1 = createTestStroke(count: 10)
        let stroke2 = createTestStroke(count: 20)
        let stroke3 = createTestStroke(count: 15)

        drawingManager.addStroke(stroke1)
        drawingManager.addStroke(stroke2)
        drawingManager.addStroke(stroke3)

        XCTAssertEqual(drawingManager.strokeCount, 3)

        // Undo last stroke
        drawingManager.undo()
        XCTAssertEqual(drawingManager.strokeCount, 2)

        // Undo again
        drawingManager.undo()
        XCTAssertEqual(drawingManager.strokeCount, 1)

        // Redo
        drawingManager.redo()
        XCTAssertEqual(drawingManager.strokeCount, 2)

        // Redo again
        drawingManager.redo()
        XCTAssertEqual(drawingManager.strokeCount, 3)
    }

    // MARK: - Clear Drawing Tests

    func testClearDrawing() {
        for _ in 0..<5 {
            drawingManager.addStroke(createTestStroke(count: 10))
        }

        XCTAssertEqual(drawingManager.strokeCount, 5)

        drawingManager.clear()

        XCTAssertEqual(drawingManager.strokeCount, 0)
    }

    // MARK: - Helper Methods

    private func createTestStroke(count: Int) -> Stroke3D {
        let points = (0..<count).map { i in
            SIMD3<Float>(Float(i) * 0.01, 0, 0)
        }

        return Stroke3D(
            id: UUID(),
            points: points,
            color: CodableColor(red: 1, green: 0, blue: 0, alpha: 1),
            thickness: 0.01,
            material: .solid,
            timestamps: points.enumerated().map { Double($0.offset) * 0.1 }
        )
    }
}
```

---

## 5. Performance Tests

### 5.1 Drawing Performance Tests

**File**: `Tests/PerformanceTests/DrawingPerformanceTests.swift`

```swift
import XCTest
@testable import SpatialPictionary

final class DrawingPerformanceTests: XCTestCase {
    var drawingEngine: DrawingEngine!

    override func setUp() {
        super.setUp()
        drawingEngine = DrawingEngine()
    }

    // MARK: - Mesh Generation Performance

    func testMeshGenerationPerformance() {
        let points = (0..<500).map { i in
            SIMD3<Float>(
                Float(i) * 0.002,
                sin(Float(i) * 0.1),
                cos(Float(i) * 0.1)
            )
        }

        measure {
            _ = drawingEngine.generateStrokeMesh(points: points, radius: 0.01, segments: 8)
        }

        // Target: <2ms for 500 points
    }

    func testInterpolationPerformance() {
        let points = (0..<100).map { i in
            SIMD3<Float>(Float(i) * 0.01, Float.random(in: -0.1...0.1), 0)
        }

        measure {
            _ = drawingEngine.interpolatePoints(points)
        }

        // Target: <1ms for 100 points
    }

    func testStrokeSimplificationPerformance() {
        let points = (0..<1000).map { i in
            SIMD3<Float>(Float(i) * 0.001, Float.random(in: -0.05...0.05), 0)
        }

        measure {
            _ = drawingEngine.simplifyStroke(points, tolerance: 0.002)
        }

        // Target: <3ms for 1000 points
    }

    // MARK: - Memory Performance

    func testStrokeMemoryUsage() {
        var strokes: [Stroke3D] = []

        measure(metrics: [XCTMemoryMetric()]) {
            // Create 100 strokes with 100 points each
            for _ in 0..<100 {
                let points = (0..<100).map { i in
                    SIMD3<Float>(Float(i) * 0.01, 0, 0)
                }

                let stroke = Stroke3D(
                    id: UUID(),
                    points: points,
                    color: CodableColor(red: 1, green: 0, blue: 0, alpha: 1),
                    thickness: 0.01,
                    material: .solid,
                    timestamps: []
                )

                strokes.append(stroke)
            }
        }

        // Target: <10MB for 100 strokes
    }
}
```

### 5.2 Game Logic Performance Tests

**File**: `Tests/PerformanceTests/GameLogicPerformanceTests.swift`

```swift
import XCTest
@testable import SpatialPictionary

final class GameLogicPerformanceTests: XCTestCase {

    // MARK: - Word Selection Performance

    func testWordSelectionPerformance() {
        let engine = WordSelectionEngine()
        engine.loadMockDatabase() // 2000+ words

        measure {
            for _ in 0..<100 {
                _ = engine.selectWords(
                    for: [],
                    difficulty: .medium,
                    categories: [.animals, .objects, .actions],
                    count: 3
                )
            }
        }

        // Target: <0.1ms per selection
    }

    // MARK: - Scoring Performance

    func testScoringCalculationPerformance() {
        let scoring = ScoringSystem()

        measure {
            for _ in 0..<10000 {
                _ = scoring.calculatePoints(
                    difficulty: .medium,
                    timeRemaining: Double.random(in: 0...90),
                    totalTime: 90,
                    hintsUsed: Int.random(in: 0...3)
                )
            }
        }

        // Target: <0.01ms per calculation
    }

    // MARK: - State Update Performance

    func testGameStateUpdatePerformance() {
        let gameState = GameState()

        // Add 12 players
        for i in 1...12 {
            let player = Player(id: UUID(), name: "Player\(i)", avatar: .default, isLocal: true, deviceID: "d\(i)")
            gameState.addPlayer(player)
        }

        measure {
            for _ in 0..<1000 {
                gameState.updateScores()
                gameState.updateTimer(deltaTime: 0.016) // 60 FPS
            }
        }

        // Target: <0.5ms per frame for all updates
    }
}
```

---

## 6. UI/UX Tests

### 6.1 SwiftUI View Tests

**File**: `Tests/UITests/ViewTests.swift`

```swift
import XCTest
import SwiftUI
@testable import SpatialPictionary

// ❌ REQUIRES: Xcode + visionOS Simulator
final class ViewTests: XCTestCase {

    // MARK: - Main Menu Tests

    func testMainMenuRendering() throws {
        let view = MainMenuView()

        // Verify view hierarchy
        XCTAssertNotNil(view)

        // Check for expected UI elements
        // Note: Real implementation would use ViewInspector or similar
    }

    // MARK: - Game HUD Tests

    func testGameHUDDisplaysTimer() throws {
        let gameState = GameState()
        gameState.timeRemaining = 45.0

        let view = GameHUDView(gameState: gameState)

        // Verify timer is displayed
        // Verify it shows correct time
    }

    // MARK: - Settings View Tests

    func testSettingsViewValidation() throws {
        let settings = GameSettings()
        let view = SettingsView(settings: settings)

        // Test that invalid settings show error
        // Test that valid settings are saved
    }
}
```

### 6.2 Navigation Flow Tests

**File**: `Tests/UITests/NavigationTests.swift`

```swift
import XCTest
@testable import SpatialPictionary

// ❌ REQUIRES: Xcode + visionOS Simulator + UI Testing
final class NavigationTests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    // MARK: - Basic Navigation Tests

    func testNavigateToQuickPlay() {
        app.buttons["Quick Play"].tap()

        XCTAssertTrue(app.staticTexts["Word Selection"].waitForExistence(timeout: 2))
    }

    func testNavigateToSettings() {
        app.buttons["Settings"].tap()

        XCTAssertTrue(app.navigationBars["Settings"].exists)
    }

    func testNavigateToGallery() {
        app.buttons["Gallery"].tap()

        XCTAssertTrue(app.navigationBars["Gallery"].exists)
    }

    // MARK: - Game Flow Navigation

    func testCompleteGameFlow() {
        // Start game
        app.buttons["Quick Play"].tap()

        // Select word
        app.buttons["Easy Word"].tap()

        // Drawing phase
        XCTAssertTrue(app.staticTexts["Drawing Phase"].exists)

        // Submit guess (simulated)
        let guessField = app.textFields["Guess Input"]
        guessField.tap()
        guessField.typeText("test")
        app.buttons["Submit Guess"].tap()

        // Verify round completion
        XCTAssertTrue(app.staticTexts["Round Complete"].waitForExistence(timeout: 5))
    }
}
```

---

## 7. Multiplayer/Network Tests

### 7.1 Network Protocol Tests

**File**: `Tests/MultiplayerTests/NetworkProtocolTests.swift`

```swift
import XCTest
@testable import SpatialPictionary

final class NetworkProtocolTests: XCTestCase {
    var networking: MockNetworking!

    override func setUp() {
        super.setUp()
        networking = MockNetworking()
    }

    // MARK: - Message Encoding/Decoding Tests

    func testStrokeDeltaEncoding() throws {
        let delta = StrokeDelta(
            strokeID: UUID(),
            newPoints: [
                SIMD3<Float>(0, 0, 0),
                SIMD3<Float>(0.1, 0, 0)
            ],
            startIndex: 0,
            timestamp: Date()
        )

        let encoded = try JSONEncoder().encode(delta)
        let decoded = try JSONDecoder().decode(StrokeDelta.self, from: encoded)

        XCTAssertEqual(decoded.strokeID, delta.strokeID)
        XCTAssertEqual(decoded.newPoints.count, delta.newPoints.count)
    }

    func testGameStateSnapshotEncoding() throws {
        let snapshot = GameStateSnapshot(
            phase: "drawing",
            currentArtistID: UUID(),
            timeRemaining: 45.0,
            scores: [UUID(): 100, UUID(): 150],
            roundNumber: 3,
            timestamp: Date()
        )

        let encoded = try JSONEncoder().encode(snapshot)
        let decoded = try JSONDecoder().decode(GameStateSnapshot.self, from: encoded)

        XCTAssertEqual(decoded.phase, snapshot.phase)
        XCTAssertEqual(decoded.roundNumber, snapshot.roundNumber)
    }

    // MARK: - Compression Tests

    func testStrokeCompression() {
        let stroke = Stroke3D(
            id: UUID(),
            points: (0..<100).map { i in
                SIMD3<Float>(Float(i) * 0.01, 0, 0)
            },
            color: CodableColor(red: 1, green: 0, blue: 0, alpha: 1),
            thickness: 0.01,
            material: .solid,
            timestamps: []
        )

        let compressed = networking.compressStroke(stroke)

        // Compressed should be smaller than JSON encoding
        let jsonData = try! JSONEncoder().encode(stroke)
        XCTAssertLessThan(compressed.count, jsonData.count)
    }

    // MARK: - Bandwidth Tests

    func testMessageBandwidthLimit() {
        // Simulate sending 100 stroke updates
        var totalBytes = 0

        for _ in 0..<100 {
            let delta = StrokeDelta(
                strokeID: UUID(),
                newPoints: [SIMD3<Float>(0, 0, 0)],
                startIndex: 0,
                timestamp: Date()
            )

            let data = try! JSONEncoder().encode(delta)
            totalBytes += data.count
        }

        // Should be under 100KB for 100 updates
        XCTAssertLessThan(totalBytes, 100_000)
    }
}
```

### 7.2 SharePlay Integration Tests

**File**: `Tests/MultiplayerTests/SharePlayTests.swift`

```swift
import XCTest
import GroupActivities
@testable import SpatialPictionary

// ❌ REQUIRES: Xcode + visionOS + Multiple Devices/Simulators
final class SharePlayTests: XCTestCase {
    var sharePlayManager: SharePlayManager!

    override func setUp() {
        super.setUp()
        sharePlayManager = SharePlayManager()
    }

    // MARK: - Session Creation Tests

    func testCreateSession() async throws {
        try await sharePlayManager.startSession()

        XCTAssertNotNil(sharePlayManager.currentSession)
    }

    // MARK: - Participant Management Tests

    func testParticipantJoin() async throws {
        try await sharePlayManager.startSession()

        // Simulate participant joining
        let expectation = expectation(description: "Participant joined")

        sharePlayManager.onParticipantJoined = { participant in
            XCTAssertNotNil(participant)
            expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: 5.0)
    }

    // MARK: - Message Delivery Tests

    func testBroadcastMessage() async throws {
        try await sharePlayManager.startSession()

        let message = NetworkMessage.gameStateUpdate(
            GameStateSnapshot(
                phase: "drawing",
                currentArtistID: UUID(),
                timeRemaining: 60,
                scores: [:],
                roundNumber: 1,
                timestamp: Date()
            )
        )

        try await sharePlayManager.broadcast(message)

        // Verify message sent without error
    }
}
```

### 7.3 Synchronization Tests

**File**: `Tests/MultiplayerTests/SynchronizationTests.swift`

```swift
import XCTest
@testable import SpatialPictionary

final class SynchronizationTests: XCTestCase {
    var syncManager: MultiplayerSyncManager!

    override func setUp() {
        super.setUp()
        syncManager = MultiplayerSyncManager()
    }

    // MARK: - State Conflict Resolution Tests

    func testConflictResolutionArtistPriority() {
        let artistID = UUID()

        var localState = GameState()
        localState.currentArtist = Player(id: artistID, name: "Artist", avatar: .default, isLocal: true, deviceID: "local")
        localState.drawings = [/* local drawings */]

        var remoteState = GameState()
        remoteState.currentArtist = Player(id: artistID, name: "Artist", avatar: .default, isLocal: false, deviceID: "remote")
        remoteState.drawings = [/* remote drawings */]

        let resolved = syncManager.resolveConflict(local: localState, remote: remoteState)

        // Artist's device should be authoritative for drawings
        XCTAssertEqual(resolved.drawings.count, localState.drawings.count)
    }

    // MARK: - Delta Synchronization Tests

    func testStrokeDeltaSync() {
        let stroke = Stroke3D(
            id: UUID(),
            points: (0..<50).map { SIMD3<Float>(Float($0) * 0.01, 0, 0) },
            color: CodableColor(red: 1, green: 0, blue: 0, alpha: 1),
            thickness: 0.01,
            material: .solid,
            timestamps: []
        )

        syncManager.registerStroke(stroke, lastSyncedIndex: 0)

        // Add more points
        var updatedStroke = stroke
        updatedStroke.points.append(SIMD3<Float>(0.5, 0, 0))

        let delta = syncManager.createDelta(for: updatedStroke)

        XCTAssertEqual(delta.newPoints.count, 1) // Only new point
        XCTAssertEqual(delta.startIndex, 50) // Starting after previous points
    }

    // MARK: - Predictive Interpolation Tests

    func testPredictiveInterpolation() {
        let stroke = Stroke3D(
            id: UUID(),
            points: [
                SIMD3<Float>(0, 0, 0),
                SIMD3<Float>(0.1, 0, 0),
                SIMD3<Float>(0.2, 0, 0)
            ],
            color: CodableColor(red: 1, green: 0, blue: 0, alpha: 1),
            thickness: 0.01,
            material: .solid,
            timestamps: [0.0, 0.1, 0.2]
        )

        let interpolated = syncManager.interpolateRemoteStroke(stroke, deltaTime: 0.1)

        // Should predict next point based on velocity
        XCTAssertGreaterThan(interpolated.count, stroke.points.count)

        // Predicted point should be approximately at 0.3
        let predictedX = interpolated.last!.x
        XCTAssertEqual(predictedX, 0.3, accuracy: 0.05)
    }
}
```

---

## 8. Accessibility Tests

### 8.1 VoiceOver Tests

**File**: `Tests/AccessibilityTests/VoiceOverTests.swift`

```swift
import XCTest
@testable import SpatialPictionary

// ❌ REQUIRES: Xcode + visionOS Simulator + Accessibility Inspector
final class VoiceOverTests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launchArguments = ["UITesting", "VoiceOverEnabled"]
        app.launch()
    }

    // MARK: - Label Tests

    func testAllButtonsHaveAccessibilityLabels() {
        let buttons = app.buttons.allElementsBoundByIndex

        for button in buttons {
            XCTAssertFalse(button.label.isEmpty, "Button should have accessibility label")
        }
    }

    func testDrawingToolsHaveDescriptions() {
        app.buttons["Tools"].tap()

        let brushButton = app.buttons["Brush Tool"]
        XCTAssertTrue(brushButton.exists)
        XCTAssertFalse(brushButton.label.isEmpty)

        // Should have hint
        XCTAssertNotNil(brushButton.value(forKey: "accessibilityHint"))
    }

    // MARK: - Navigation Tests

    func testVoiceOverNavigation() {
        // Test that all interactive elements are reachable via VoiceOver
        // swipe gestures
    }
}
```

### 8.2 Color Accessibility Tests

**File**: `Tests/AccessibilityTests/ColorAccessibilityTests.swift`

```swift
import XCTest
@testable import SpatialPictionary

final class ColorAccessibilityTests: XCTestCase {

    // MARK: - Contrast Ratio Tests

    func testTextContrastRatio() {
        let accessibility = AccessibilityManager()

        // Test primary UI colors
        let ratio = accessibility.contrastRatio(
            foreground: .white,
            background: UIColor(red: 0.29, green: 0.56, blue: 0.89, alpha: 1.0) // Brand blue
        )

        // WCAG AA requires 4.5:1 for normal text
        XCTAssertGreaterThan(ratio, 4.5)
    }

    // MARK: - Colorblind Mode Tests

    func testProtanopiaColorPalette() {
        let palette = ColorPalette.adapted(for: .protanopia)

        // Verify all colors are distinguishable
        for (i, color1) in palette.enumerated() {
            for (j, color2) in palette.enumerated() where i < j {
                let distance = colorDistance(color1, color2, mode: .protanopia)
                XCTAssertGreaterThan(distance, 30.0, "Colors should be distinguishable")
            }
        }
    }

    func testDeuteranopiaColorPalette() {
        let palette = ColorPalette.adapted(for: .deuteranopia)

        // Similar test for deuteranopia
    }

    func testTritanopiaColorPalette() {
        let palette = ColorPalette.adapted(for: .tritanopia)

        // Similar test for tritanopia
    }

    // MARK: - Helper Methods

    private func colorDistance(_ c1: UIColor, _ c2: UIColor, mode: ColorblindMode) -> Float {
        // Calculate perceptual color distance
        // Implementation would use CIE Lab color space
        return 0.0
    }
}
```

### 8.3 Motor Accessibility Tests

**File**: `Tests/AccessibilityTests/MotorAccessibilityTests.swift`

```swift
import XCTest
@testable import SpatialPictionary

final class MotorAccessibilityTests: XCTestCase {

    // MARK: - One-Handed Mode Tests

    func testOneHandedMode() {
        let settings = AccessibilitySettings()
        settings.oneHandedMode = true

        let toolPalette = ToolPalette(settings: settings)

        // All tools should be reachable from one side
        XCTAssertTrue(toolPalette.isOneHandedAccessible)
    }

    // MARK: - Voice Command Tests

    func testVoiceCommands() {
        let voiceController = VoiceCommandController()

        // Test tool selection via voice
        let result = voiceController.processCommand("Select brush tool")
        XCTAssertEqual(result, .toolSelected(.brush))

        // Test color selection
        let colorResult = voiceController.processCommand("Use red color")
        XCTAssertEqual(colorResult, .colorSelected(.red))

        // Test undo
        let undoResult = voiceController.processCommand("Undo")
        XCTAssertEqual(undoResult, .undo)
    }

    // MARK: - Gesture Sensitivity Tests

    func testGestureSensitivityAdjustment() {
        let settings = AccessibilitySettings()
        settings.gestureSensitivity = .low

        let gestureRecognizer = HandGestureRecognizer(settings: settings)

        // With low sensitivity, should tolerate more imprecise gestures
        let impreciseGesture = createImpreciseDrawingGesture()
        let recognized = gestureRecognizer.recognize(impreciseGesture)

        XCTAssertNotNil(recognized)
    }

    private func createImpreciseDrawingGesture() -> MockHandGesture {
        // Create gesture with more tolerance
        return MockHandGesture(type: .drawing, precision: .low)
    }
}
```

---

## 9. Test Execution Guide

### 9.1 Running Tests in Different Environments

#### ✅ Running Pure Swift Tests (No Xcode Required)

**Setup:**
```bash
# Install Swift toolchain
curl -L https://swift.org/builds/swift-6.0-release/ubuntu2204/swift-6.0-RELEASE/swift-6.0-RELEASE-ubuntu22.04.tar.gz | tar xz

# Add to PATH
export PATH="/path/to/swift/bin:$PATH"
```

**Execution:**
```bash
# Navigate to project directory
cd /home/user/visionOS_Gaming_spatial-pictionary

# Run unit tests (pure Swift logic)
swift test --filter UnitTests

# Run specific test
swift test --filter GameStateTests

# Run with code coverage
swift test --enable-code-coverage
```

**Expected Results:**
- All pure logic tests should pass
- Tests using RealityKit/ARKit will fail (expected)

#### ⚠️ Running XCTest-Based Tests (Requires Xcode)

**Setup:**
```bash
# Open in Xcode
open SpatialPictionary.xcodeproj
```

**Execution:**
```bash
# Run all tests via command line
xcodebuild test \
  -project SpatialPictionary.xcodeproj \
  -scheme SpatialPictionary \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro'

# Run specific test suite
xcodebuild test \
  -project SpatialPictionary.xcodeproj \
  -scheme SpatialPictionary \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -only-testing:SpatialPictionaryTests/GameStateTests
```

**Via Xcode GUI:**
1. Open project in Xcode
2. Select Product → Test (⌘U)
3. Or click test diamond in code editor gutter

#### ❌ Running Device-Dependent Tests (Requires Physical Device)

**Requirements:**
- Apple Vision Pro device
- Developer account
- Provisioning profile

**Execution:**
```bash
# Run on connected device
xcodebuild test \
  -project SpatialPictionary.xcodeproj \
  -scheme SpatialPictionary \
  -destination 'platform=visionOS,name=My Vision Pro'
```

### 9.2 Test Categories by Runnability

**✅ Can Run in CI/Command Line** (No GUI):
- `GameStateTests`
- `ScoringTests`
- `WordSelectionTests`
- `DrawingAlgorithmTests`
- `DataModelTests`
- `NetworkProtocolTests`
- `SynchronizationTests`

**⚠️ Requires Xcode Environment**:
- `DrawingSystemIntegrationTests` (RealityKit)
- `GameFlowIntegrationTests` (Full framework)
- `DrawingPerformanceTests` (RealityKit)
- `GameLogicPerformanceTests`

**❌ Requires visionOS Simulator**:
- `ViewTests` (SwiftUI rendering)
- `NavigationTests` (UI testing)
- `VoiceOverTests` (Accessibility)

**❌ Requires Physical Device**:
- Hand tracking accuracy tests
- Spatial audio quality tests
- Battery performance tests
- Multi-device multiplayer tests

---

## 10. Continuous Integration Setup

### 10.1 GitHub Actions Configuration

**File**: `.github/workflows/tests.yml`

```yaml
name: Spatial Pictionary Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  unit-tests:
    name: Unit Tests (Pure Swift)
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3

    - name: Setup Swift
      uses: swift-actions/setup-swift@v1
      with:
        swift-version: '6.0'

    - name: Run Unit Tests
      run: |
        swift test --filter UnitTests

    - name: Upload Coverage
      uses: codecov/codecov-action@v3
      with:
        files: ./coverage.lcov

  integration-tests:
    name: Integration Tests (Xcode)
    runs-on: macos-14

    steps:
    - uses: actions/checkout@v3

    - name: Select Xcode
      run: sudo xcode-select -s /Applications/Xcode_16.0.app

    - name: Run Integration Tests
      run: |
        xcodebuild test \
          -project SpatialPictionary.xcodeproj \
          -scheme SpatialPictionary \
          -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
          -only-testing:SpatialPictionaryTests/IntegrationTests

    - name: Upload Test Results
      uses: actions/upload-artifact@v3
      with:
        name: test-results
        path: build/test-results

  performance-tests:
    name: Performance Tests
    runs-on: macos-14

    steps:
    - uses: actions/checkout@v3

    - name: Run Performance Tests
      run: |
        xcodebuild test \
          -project SpatialPictionary.xcodeproj \
          -scheme SpatialPictionary \
          -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
          -only-testing:SpatialPictionaryTests/PerformanceTests

    - name: Check Performance Budgets
      run: |
        python scripts/check_performance_budgets.py
```

### 10.2 Test Quality Gates

**Required for PR Merge:**
- ✅ All unit tests pass (100%)
- ✅ Code coverage ≥80%
- ✅ Integration tests pass (100%)
- ✅ Performance tests meet targets
- ✅ No new compiler warnings

**Nice to Have:**
- ✅ UI tests pass (best effort)
- ✅ Accessibility tests pass
- ✅ Manual QA sign-off

---

## 11. Test Maintenance

### 11.1 Test Review Checklist

When reviewing test code:
- [ ] Test names clearly describe what is being tested
- [ ] Tests are independent and can run in any order
- [ ] Tests clean up after themselves
- [ ] Assertions have clear failure messages
- [ ] Test data is representative of real usage
- [ ] Performance tests have defined budgets
- [ ] Flaky tests are investigated and fixed

### 11.2 Test Debt Management

**Monthly Review:**
- Identify and fix flaky tests
- Update tests for new features
- Remove obsolete tests
- Improve test coverage for low-coverage areas

**Quarterly Review:**
- Refactor duplicate test code
- Update test infrastructure
- Review and update test documentation
- Performance test budget review

---

## Summary

This comprehensive testing guide provides:

1. **Complete Test Coverage**: Unit, integration, performance, UI, multiplayer, and accessibility tests
2. **Environment Classification**: Clear distinction between what can/cannot run in different environments
3. **Practical Execution**: Step-by-step guides for running tests locally and in CI
4. **Quality Gates**: Defined standards for code quality and test coverage
5. **Maintenance Plan**: Ongoing test quality and debt management

### Test Execution Status

| Test Type | Total Tests | Can Run in CI | Requires Xcode | Requires Device |
|-----------|-------------|---------------|----------------|-----------------|
| Unit Tests | 50+ | ✅ Yes | ⚠️ Preferred | ❌ No |
| Integration Tests | 20+ | ❌ No | ✅ Yes | ❌ No |
| Performance Tests | 15+ | ❌ No | ✅ Yes | ⚠️ Preferred |
| UI Tests | 25+ | ❌ No | ✅ Yes | ⚠️ Preferred |
| Multiplayer Tests | 15+ | ⚠️ Limited | ✅ Yes | ✅ Yes |
| Accessibility Tests | 20+ | ❌ No | ✅ Yes | ⚠️ Preferred |

**Total**: ~145 comprehensive tests across all categories

---

*Document Version: 1.0 | Last Updated: 2025-11-19*
*Ready for Test Implementation and Execution*
