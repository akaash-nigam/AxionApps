import XCTest
@testable import EscapeRoomNetwork

/// Unit tests for game data models
final class GameModelsTests: XCTestCase {

    // MARK: - Puzzle Tests

    func testPuzzleInitialization() {
        // Given
        let puzzle = Puzzle(
            title: "Test Puzzle",
            description: "A test puzzle",
            difficulty: .beginner,
            estimatedTime: 900,
            requiredRoomSize: .small,
            puzzleElements: [],
            objectives: [],
            hints: []
        )

        // Then
        XCTAssertEqual(puzzle.title, "Test Puzzle")
        XCTAssertEqual(puzzle.difficulty, .beginner)
        XCTAssertEqual(puzzle.estimatedTime, 900)
        XCTAssertEqual(puzzle.requiredRoomSize, .small)
    }

    func testPuzzleDifficultyMultiplier() {
        // Then
        XCTAssertEqual(Puzzle.Difficulty.beginner.difficultyMultiplier, 0.8)
        XCTAssertEqual(Puzzle.Difficulty.intermediate.difficultyMultiplier, 1.0)
        XCTAssertEqual(Puzzle.Difficulty.advanced.difficultyMultiplier, 1.2)
        XCTAssertEqual(Puzzle.Difficulty.expert.difficultyMultiplier, 1.5)
    }

    func testPuzzleCodable() throws {
        // Given
        let originalPuzzle = Puzzle(
            title: "Code Test",
            description: "Testing Codable",
            difficulty: .intermediate,
            estimatedTime: 1200,
            requiredRoomSize: .medium,
            puzzleElements: [],
            objectives: [],
            hints: []
        )

        // When
        let encoded = try JSONEncoder().encode(originalPuzzle)
        let decoded = try JSONDecoder().decode(Puzzle.self, from: encoded)

        // Then
        XCTAssertEqual(decoded.title, originalPuzzle.title)
        XCTAssertEqual(decoded.difficulty, originalPuzzle.difficulty)
        XCTAssertEqual(decoded.estimatedTime, originalPuzzle.estimatedTime)
    }

    // MARK: - PuzzleElement Tests

    func testPuzzleElementInitialization() {
        // Given
        let position = SIMD3<Float>(1.0, 2.0, 3.0)
        let element = PuzzleElement(
            type: .clue,
            position: position,
            modelName: "test_model",
            interactionType: .grab
        )

        // Then
        XCTAssertEqual(element.type, .clue)
        XCTAssertEqual(element.position, position)
        XCTAssertEqual(element.modelName, "test_model")
        XCTAssertEqual(element.interactionType, .grab)
    }

    func testPuzzleElementCodable() throws {
        // Given
        let element = PuzzleElement(
            type: .key,
            position: SIMD3<Float>(0, 1, 0),
            modelName: "key_model",
            interactionType: .tap,
            metadata: ["color": "gold"]
        )

        // When
        let encoded = try JSONEncoder().encode(element)
        let decoded = try JSONDecoder().decode(PuzzleElement.self, from: encoded)

        // Then
        XCTAssertEqual(decoded.type, element.type)
        XCTAssertEqual(decoded.position, element.position)
        XCTAssertEqual(decoded.modelName, element.modelName)
        XCTAssertEqual(decoded.metadata["color"], "gold")
    }

    // MARK: - RoomData Tests

    func testRoomDataInitialization() {
        // Given
        let roomData = RoomData()

        // Then
        XCTAssertNotNil(roomData.id)
        XCTAssertEqual(roomData.dimensions, SIMD3<Float>.zero)
        XCTAssertTrue(roomData.furniture.isEmpty)
        XCTAssertTrue(roomData.anchorPoints.isEmpty)
    }

    func testRoomDataWithFurniture() {
        // Given
        let table = RoomData.FurnitureItem(
            id: UUID(),
            type: .table,
            boundingBox: RoomData.BoundingBox(
                center: SIMD3<Float>(0, 0.5, 0),
                extents: SIMD3<Float>(1, 1, 1)
            ),
            surfaceNormals: [SIMD3<Float>(0, 1, 0)]
        )

        var roomData = RoomData()
        roomData.furniture.append(table)

        // Then
        XCTAssertEqual(roomData.furniture.count, 1)
        XCTAssertEqual(roomData.furniture.first?.type, .table)
    }

    func testRoomDataCodable() throws {
        // Given
        var roomData = RoomData()
        roomData.dimensions = SIMD3<Float>(5, 3, 5)

        // When
        let encoded = try JSONEncoder().encode(roomData)
        let decoded = try JSONDecoder().decode(RoomData.self, from: encoded)

        // Then
        XCTAssertEqual(decoded.dimensions, roomData.dimensions)
    }

    // MARK: - Player Tests

    func testPlayerInitialization() {
        // Given
        let player = Player(username: "TestPlayer")

        // Then
        XCTAssertEqual(player.username, "TestPlayer")
        XCTAssertEqual(player.statistics.totalPuzzlesSolved, 0)
        XCTAssertEqual(player.statistics.currentLevel, 1)
        XCTAssertTrue(player.achievements.isEmpty)
    }

    func testPlayerStatisticsUpdate() {
        // Given
        var player = Player(username: "TestPlayer")

        // When
        player.statistics.totalPuzzlesSolved = 5
        player.statistics.totalPlayTime = 3600
        player.statistics.currentLevel = 3
        player.statistics.currentXP = 500

        // Then
        XCTAssertEqual(player.statistics.totalPuzzlesSolved, 5)
        XCTAssertEqual(player.statistics.totalPlayTime, 3600)
        XCTAssertEqual(player.statistics.currentLevel, 3)
        XCTAssertEqual(player.statistics.currentXP, 500)
    }

    // MARK: - Objective Tests

    func testObjectiveCompletion() {
        // Given
        var objective = Objective(
            title: "Find the key",
            description: "Locate the hidden key",
            isCompleted: false
        )

        // When
        XCTAssertFalse(objective.isCompleted)

        objective.isCompleted = true

        // Then
        XCTAssertTrue(objective.isCompleted)
    }

    // MARK: - Hint Tests

    func testHintDifficultyLevels() {
        // Given
        let easyHint = Hint(text: "Look around", difficulty: 1)
        let mediumHint = Hint(text: "Check the table", difficulty: 2)
        let hardHint = Hint(text: "The answer is 1234", difficulty: 3)

        // Then
        XCTAssertEqual(easyHint.difficulty, 1)
        XCTAssertEqual(mediumHint.difficulty, 2)
        XCTAssertEqual(hardHint.difficulty, 3)
    }

    func testHintReveal() {
        // Given
        var hint = Hint(text: "Secret hint", difficulty: 2, isRevealed: false)

        // When
        XCTAssertFalse(hint.isRevealed)

        hint.isRevealed = true

        // Then
        XCTAssertTrue(hint.isRevealed)
    }

    // MARK: - PuzzleProgress Tests

    func testPuzzleProgressInitialization() {
        // Given
        let puzzleId = UUID()
        let progress = PuzzleProgress(puzzleId: puzzleId)

        // Then
        XCTAssertEqual(progress.puzzleId, puzzleId)
        XCTAssertTrue(progress.completedObjectives.isEmpty)
        XCTAssertTrue(progress.discoveredClues.isEmpty)
        XCTAssertTrue(progress.revealedHints.isEmpty)
        XCTAssertEqual(progress.elapsedTime, 0)
        XCTAssertEqual(progress.hintCount, 0)
    }

    func testPuzzleProgressTracking() {
        // Given
        let puzzleId = UUID()
        var progress = PuzzleProgress(puzzleId: puzzleId)

        let objectiveId = UUID()
        let clueId = UUID()
        let hintId = UUID()

        // When
        progress.completedObjectives.append(objectiveId)
        progress.discoveredClues.append(clueId)
        progress.revealedHints.append(hintId)
        progress.elapsedTime = 600
        progress.hintCount = 1

        // Then
        XCTAssertEqual(progress.completedObjectives.count, 1)
        XCTAssertEqual(progress.discoveredClues.count, 1)
        XCTAssertEqual(progress.revealedHints.count, 1)
        XCTAssertEqual(progress.elapsedTime, 600)
        XCTAssertEqual(progress.hintCount, 1)
    }

    // MARK: - ValidationResult Tests

    func testValidationResultCorrect() {
        // Given
        let result = ValidationResult(
            isCorrect: true,
            feedback: "Well done!",
            completedObjectives: [UUID()]
        )

        // Then
        XCTAssertTrue(result.isCorrect)
        XCTAssertEqual(result.feedback, "Well done!")
        XCTAssertEqual(result.completedObjectives.count, 1)
    }

    func testValidationResultIncorrect() {
        // Given
        let result = ValidationResult(
            isCorrect: false,
            feedback: "Try again"
        )

        // Then
        XCTAssertFalse(result.isCorrect)
        XCTAssertEqual(result.feedback, "Try again")
        XCTAssertTrue(result.completedObjectives.isEmpty)
    }

    // MARK: - SIMD Codable Tests

    func testSIMD3Codable() throws {
        // Given
        let vector = SIMD3<Float>(1.5, 2.5, 3.5)

        // When
        let encoded = try JSONEncoder().encode(vector)
        let decoded = try JSONDecoder().decode(SIMD3<Float>.self, from: encoded)

        // Then
        XCTAssertEqual(decoded.x, vector.x, accuracy: 0.001)
        XCTAssertEqual(decoded.y, vector.y, accuracy: 0.001)
        XCTAssertEqual(decoded.z, vector.z, accuracy: 0.001)
    }

    func testQuatfCodable() throws {
        // Given
        let quat = simd_quatf(angle: Float.pi / 4, axis: SIMD3<Float>(0, 1, 0))

        // When
        let encoded = try JSONEncoder().encode(quat)
        let decoded = try JSONDecoder().decode(simd_quatf.self, from: encoded)

        // Then
        XCTAssertEqual(decoded.real, quat.real, accuracy: 0.001)
        XCTAssertEqual(decoded.imag.x, quat.imag.x, accuracy: 0.001)
        XCTAssertEqual(decoded.imag.y, quat.imag.y, accuracy: 0.001)
        XCTAssertEqual(decoded.imag.z, quat.imag.z, accuracy: 0.001)
    }
}
