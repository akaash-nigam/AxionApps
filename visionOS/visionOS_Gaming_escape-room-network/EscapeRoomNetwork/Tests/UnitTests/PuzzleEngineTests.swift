import XCTest
@testable import EscapeRoomNetwork

/// Unit tests for puzzle engine
final class PuzzleEngineTests: XCTestCase {

    var sut: PuzzleEngine!
    var mockRoomData: RoomData!

    override func setUp() {
        super.setUp()
        sut = PuzzleEngine()
        mockRoomData = createMockRoomData()
    }

    override func tearDown() {
        sut = nil
        mockRoomData = nil
        super.tearDown()
    }

    // MARK: - Helpers

    private func createMockRoomData() -> RoomData {
        var roomData = RoomData()
        roomData.dimensions = SIMD3<Float>(5, 3, 5)
        return roomData
    }

    // MARK: - Puzzle Generation Tests

    func testGenerateLogicPuzzle() {
        // When
        let puzzle = sut.generatePuzzle(
            type: .logic,
            difficulty: .beginner,
            roomData: mockRoomData
        )

        // Then
        XCTAssertNotNil(puzzle)
        XCTAssertEqual(puzzle.difficulty, .beginner)
        XCTAssertFalse(puzzle.puzzleElements.isEmpty)
        XCTAssertFalse(puzzle.objectives.isEmpty)
        XCTAssertFalse(puzzle.hints.isEmpty)
    }

    func testGenerateSpatialPuzzle() {
        // When
        let puzzle = sut.generatePuzzle(
            type: .spatial,
            difficulty: .intermediate,
            roomData: mockRoomData
        )

        // Then
        XCTAssertNotNil(puzzle)
        XCTAssertEqual(puzzle.difficulty, .intermediate)
        XCTAssertFalse(puzzle.puzzleElements.isEmpty)
    }

    func testGenerateSequentialPuzzle() {
        // When
        let puzzle = sut.generatePuzzle(
            type: .sequential,
            difficulty: .advanced,
            roomData: mockRoomData
        )

        // Then
        XCTAssertNotNil(puzzle)
        XCTAssertEqual(puzzle.difficulty, .advanced)
    }

    func testGenerateCollaborativePuzzle() {
        // When
        let puzzle = sut.generatePuzzle(
            type: .collaborative,
            difficulty: .expert,
            roomData: mockRoomData
        )

        // Then
        XCTAssertNotNil(puzzle)
        XCTAssertEqual(puzzle.difficulty, .expert)
    }

    func testGenerateObservationPuzzle() {
        // When
        let puzzle = sut.generatePuzzle(
            type: .observation,
            difficulty: .beginner,
            roomData: mockRoomData
        )

        // Then
        XCTAssertNotNil(puzzle)
        XCTAssertFalse(puzzle.puzzleElements.isEmpty)
    }

    func testGenerateManipulationPuzzle() {
        // When
        let puzzle = sut.generatePuzzle(
            type: .manipulation,
            difficulty: .intermediate,
            roomData: mockRoomData
        )

        // Then
        XCTAssertNotNil(puzzle)
        XCTAssertFalse(puzzle.puzzleElements.isEmpty)
    }

    func testGenerateAllPuzzleTypes() {
        // When/Then - Generate all puzzle types
        for type in PuzzleType.allCases {
            let puzzle = sut.generatePuzzle(
                type: type,
                difficulty: .beginner,
                roomData: mockRoomData
            )

            XCTAssertNotNil(puzzle)
            XCTAssertFalse(puzzle.title.isEmpty)
            XCTAssertFalse(puzzle.description.isEmpty)
        }
    }

    // MARK: - Difficulty Scaling Tests

    func testBeginnerPuzzleComplexity() {
        // When
        let puzzle = sut.generatePuzzle(
            type: .logic,
            difficulty: .beginner,
            roomData: mockRoomData
        )

        // Then
        XCTAssertEqual(puzzle.difficulty, .beginner)
        XCTAssertLessThanOrEqual(puzzle.puzzleElements.count, 5)
    }

    func testExpertPuzzleComplexity() {
        // When
        let puzzle = sut.generatePuzzle(
            type: .observation,
            difficulty: .expert,
            roomData: mockRoomData
        )

        // Then
        XCTAssertEqual(puzzle.difficulty, .expert)
        // Expert observation puzzles should have more clues
        XCTAssertGreaterThanOrEqual(puzzle.puzzleElements.count, 5)
    }

    // MARK: - Solution Validation Tests

    func testValidateSolutionCorrect() {
        // Given
        let puzzle = createMockPuzzle()
        let solution = PuzzleSolution(answer: "correct")

        // When
        let result = sut.validateSolution(puzzle: puzzle, solution: solution)

        // Then
        XCTAssertTrue(result.isCorrect)
        XCTAssertEqual(result.feedback, "Correct!")
    }

    func testValidateSolutionIncorrect() {
        // Given
        let puzzle = createMockPuzzle()
        let solution = PuzzleSolution(answer: "")

        // When
        let result = sut.validateSolution(puzzle: puzzle, solution: solution)

        // Then
        XCTAssertFalse(result.isCorrect)
        XCTAssertEqual(result.feedback, "Incorrect solution")
    }

    // MARK: - Hint System Tests

    func testProvideHint() {
        // Given
        let puzzle = sut.generatePuzzle(
            type: .logic,
            difficulty: .beginner,
            roomData: mockRoomData
        )
        let progress = PuzzleProgress(puzzleId: puzzle.id)

        // When
        let hint = sut.provideHint(puzzle: puzzle, progress: progress)

        // Then
        XCTAssertNotNil(hint)
        XCTAssertFalse(hint.text.isEmpty)
    }

    func testProvideMultipleHints() {
        // Given
        let puzzle = sut.generatePuzzle(
            type: .logic,
            difficulty: .beginner,
            roomData: mockRoomData
        )
        var progress = PuzzleProgress(puzzleId: puzzle.id)

        // When - Get first hint
        let hint1 = sut.provideHint(puzzle: puzzle, progress: progress)
        progress.revealedHints.append(hint1.id)

        // When - Get second hint
        let hint2 = sut.provideHint(puzzle: puzzle, progress: progress)

        // Then
        XCTAssertNotEqual(hint1.id, hint2.id)
    }

    func testHintAfterAllRevealed() {
        // Given
        let puzzle = sut.generatePuzzle(
            type: .logic,
            difficulty: .beginner,
            roomData: mockRoomData
        )
        var progress = PuzzleProgress(puzzleId: puzzle.id)

        // Reveal all hints
        for hint in puzzle.hints {
            progress.revealedHints.append(hint.id)
        }

        // When
        let fallbackHint = sut.provideHint(puzzle: puzzle, progress: progress)

        // Then - Should get fallback hint
        XCTAssertNotNil(fallbackHint)
        XCTAssertFalse(fallbackHint.text.isEmpty)
    }

    // MARK: - Progress Management Tests

    func testUpdateProgress() {
        // Given
        let puzzle = sut.generatePuzzle(
            type: .logic,
            difficulty: .beginner,
            roomData: mockRoomData
        )
        let objectiveId = puzzle.objectives.first!.id

        // When
        sut.updateProgress(completedObjective: objectiveId)

        // Then
        let progress = sut.getCurrentProgress()
        XCTAssertNotNil(progress)
        XCTAssertTrue(progress!.completedObjectives.contains(objectiveId))
    }

    func testDiscoverClue() {
        // Given
        let puzzle = sut.generatePuzzle(
            type: .logic,
            difficulty: .beginner,
            roomData: mockRoomData
        )
        let clueId = puzzle.puzzleElements.first!.id

        // When
        sut.discoverClue(clueId)

        // Then
        let progress = sut.getCurrentProgress()
        XCTAssertNotNil(progress)
        XCTAssertTrue(progress!.discoveredClues.contains(clueId))
    }

    func testRevealHint() {
        // Given
        let puzzle = sut.generatePuzzle(
            type: .logic,
            difficulty: .beginner,
            roomData: mockRoomData
        )
        let hintId = puzzle.hints.first!.id

        // When
        sut.revealHint(hintId)

        // Then
        let progress = sut.getCurrentProgress()
        XCTAssertNotNil(progress)
        XCTAssertTrue(progress!.revealedHints.contains(hintId))
        XCTAssertEqual(progress!.hintCount, 1)
    }

    func testDiscoverClueDuplicate() {
        // Given
        let puzzle = sut.generatePuzzle(
            type: .logic,
            difficulty: .beginner,
            roomData: mockRoomData
        )
        let clueId = puzzle.puzzleElements.first!.id

        // When - Discover same clue twice
        sut.discoverClue(clueId)
        sut.discoverClue(clueId)

        // Then - Should only count once
        let progress = sut.getCurrentProgress()
        XCTAssertEqual(progress!.discoveredClues.filter { $0 == clueId }.count, 1)
    }

    // MARK: - Puzzle Completion Tests

    func testIsPuzzleCompleted() {
        // Given
        let puzzle = sut.generatePuzzle(
            type: .logic,
            difficulty: .beginner,
            roomData: mockRoomData
        )

        // When - Complete all objectives
        for objective in puzzle.objectives {
            sut.updateProgress(completedObjective: objective.id)
        }

        // Then
        XCTAssertTrue(sut.isPuzzleCompleted())
    }

    func testIsPuzzleNotCompleted() {
        // Given
        _ = sut.generatePuzzle(
            type: .logic,
            difficulty: .beginner,
            roomData: mockRoomData
        )

        // When - Don't complete any objectives

        // Then
        XCTAssertFalse(sut.isPuzzleCompleted())
    }

    // MARK: - Current State Tests

    func testGetCurrentPuzzle() {
        // Given
        let puzzle = sut.generatePuzzle(
            type: .logic,
            difficulty: .beginner,
            roomData: mockRoomData
        )

        // When
        let currentPuzzle = sut.getCurrentPuzzle()

        // Then
        XCTAssertNotNil(currentPuzzle)
        XCTAssertEqual(currentPuzzle?.id, puzzle.id)
    }

    func testGetCurrentProgress() {
        // Given
        let puzzle = sut.generatePuzzle(
            type: .logic,
            difficulty: .beginner,
            roomData: mockRoomData
        )

        // When
        let progress = sut.getCurrentProgress()

        // Then
        XCTAssertNotNil(progress)
        XCTAssertEqual(progress?.puzzleId, puzzle.id)
    }

    // MARK: - Performance Tests

    func testPuzzleGenerationPerformance() {
        measure {
            _ = sut.generatePuzzle(
                type: .logic,
                difficulty: .intermediate,
                roomData: mockRoomData
            )
        }
    }

    func testMultiplePuzzleGenerationPerformance() {
        measure {
            for type in PuzzleType.allCases {
                _ = sut.generatePuzzle(
                    type: type,
                    difficulty: .beginner,
                    roomData: mockRoomData
                )
            }
        }
    }

    // MARK: - Helper Methods

    private func createMockPuzzle() -> Puzzle {
        return Puzzle(
            title: "Mock Puzzle",
            description: "A test puzzle",
            difficulty: .beginner,
            estimatedTime: 600,
            requiredRoomSize: .small,
            puzzleElements: [],
            objectives: [
                Objective(title: "Test Objective", description: "Complete this")
            ],
            hints: [
                Hint(text: "Test hint", difficulty: 1)
            ]
        )
    }
}
