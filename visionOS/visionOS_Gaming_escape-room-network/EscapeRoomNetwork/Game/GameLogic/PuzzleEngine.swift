import Foundation
import simd

/// Core puzzle engine responsible for puzzle generation, validation, and management
class PuzzleEngine {
    // MARK: - Properties

    private var currentPuzzle: Puzzle?
    private var puzzleProgress: PuzzleProgress?
    private let puzzleGenerator: PuzzleGenerator
    private let puzzleValidator: PuzzleValidator
    private let hintSystem: AdaptiveHintSystem

    // MARK: - Initialization

    init() {
        self.puzzleGenerator = PuzzleGenerator()
        self.puzzleValidator = PuzzleValidator()
        self.hintSystem = AdaptiveHintSystem()
    }

    // MARK: - Puzzle Generation

    func generatePuzzle(
        type: PuzzleType,
        difficulty: Puzzle.Difficulty,
        roomData: RoomData
    ) -> Puzzle {
        print("🎲 Generating \(difficulty) \(type) puzzle...")

        let puzzle = puzzleGenerator.create(
            type: type,
            difficulty: difficulty,
            roomData: roomData
        )

        currentPuzzle = puzzle
        puzzleProgress = PuzzleProgress(puzzleId: puzzle.id)

        print("✓ Puzzle generated: \(puzzle.title)")
        return puzzle
    }

    // MARK: - Solution Validation

    func validateSolution(
        puzzle: Puzzle,
        solution: PuzzleSolution
    ) -> ValidationResult {
        return puzzleValidator.validate(puzzle: puzzle, solution: solution)
    }

    // MARK: - Hints

    func provideHint(
        puzzle: Puzzle,
        progress: PuzzleProgress
    ) -> Hint {
        return hintSystem.generateHint(for: puzzle, given: progress)
    }

    // MARK: - Progress Management

    func updateProgress(
        completedObjective: UUID
    ) {
        guard var progress = puzzleProgress else { return }
        progress.completedObjectives.append(completedObjective)
        puzzleProgress = progress

        print("✓ Objective completed: \(progress.completedObjectives.count)/\(currentPuzzle?.objectives.count ?? 0)")
    }

    func discoverClue(_ clueId: UUID) {
        guard var progress = puzzleProgress else { return }
        if !progress.discoveredClues.contains(clueId) {
            progress.discoveredClues.append(clueId)
            puzzleProgress = progress
            print("🔍 Clue discovered!")
        }
    }

    func revealHint(_ hintId: UUID) {
        guard var progress = puzzleProgress else { return }
        if !progress.revealedHints.contains(hintId) {
            progress.revealedHints.append(hintId)
            progress.hintCount += 1
            puzzleProgress = progress
            print("💡 Hint revealed")
        }
    }

    // MARK: - Current Puzzle

    func getCurrentPuzzle() -> Puzzle? {
        return currentPuzzle
    }

    func getCurrentProgress() -> PuzzleProgress? {
        return puzzleProgress
    }

    func isPuzzleCompleted() -> Bool {
        guard let puzzle = currentPuzzle,
              let progress = puzzleProgress else {
            return false
        }

        return progress.completedObjectives.count == puzzle.objectives.count
    }
}

// MARK: - Puzzle Types

enum PuzzleType: String, CaseIterable {
    case logic          // Code breaking, pattern matching
    case spatial        // 3D positioning, alignment
    case sequential     // Ordered actions
    case collaborative  // Multi-player coordination
    case observation    // Hidden object finding
    case manipulation   // Physical interaction
}

// MARK: - Puzzle Generator

class PuzzleGenerator {
    func create(
        type: PuzzleType,
        difficulty: Puzzle.Difficulty,
        roomData: RoomData
    ) -> Puzzle {
        switch type {
        case .logic:
            return generateLogicPuzzle(difficulty: difficulty, roomData: roomData)
        case .spatial:
            return generateSpatialPuzzle(difficulty: difficulty, roomData: roomData)
        case .sequential:
            return generateSequentialPuzzle(difficulty: difficulty, roomData: roomData)
        case .collaborative:
            return generateCollaborativePuzzle(difficulty: difficulty, roomData: roomData)
        case .observation:
            return generateObservationPuzzle(difficulty: difficulty, roomData: roomData)
        case .manipulation:
            return generateManipulationPuzzle(difficulty: difficulty, roomData: roomData)
        }
    }

    // MARK: - Specific Puzzle Generators

    private func generateLogicPuzzle(
        difficulty: Puzzle.Difficulty,
        roomData: RoomData
    ) -> Puzzle {
        let codeLength = difficulty == .beginner ? 4 : (difficulty == .intermediate ? 5 : 6)
        let correctCode = String((0..<codeLength).map { _ in String(Int.random(in: 0...9)) }.joined())

        let elements = createCodePanels(count: 4, roomData: roomData)
        let objectives = [
            Objective(
                title: "Find the Code",
                description: "Discover the \(codeLength)-digit code hidden in the room",
                requiredElements: elements.map { $0.id }
            ),
            Objective(
                title: "Enter the Code",
                description: "Enter the correct code into the safe"
            )
        ]

        let hints = [
            Hint(text: "Look for numbers on the walls", difficulty: 1),
            Hint(text: "The symbols correspond to the number panels", difficulty: 2),
            Hint(text: "The code is: \(correctCode)", difficulty: 3)
        ]

        return Puzzle(
            title: "The Hidden Code",
            description: "A mysterious safe appears. Find the code to unlock it.",
            difficulty: difficulty,
            estimatedTime: difficulty == .beginner ? 900 : 1800,  // 15-30 minutes
            requiredRoomSize: .small,
            puzzleElements: elements,
            objectives: objectives,
            hints: hints
        )
    }

    private func generateSpatialPuzzle(
        difficulty: Puzzle.Difficulty,
        roomData: RoomData
    ) -> Puzzle {
        let elements = createAlignmentBeacons(count: 3, roomData: roomData)

        let objectives = [
            Objective(
                title: "Align the Beacons",
                description: "Position yourself so all three beacons align",
                requiredElements: elements.map { $0.id }
            )
        ]

        let hints = [
            Hint(text: "The beacons should form a straight line from your perspective", difficulty: 1),
            Hint(text: "Try moving around the room and looking from different angles", difficulty: 2)
        ]

        return Puzzle(
            title: "Spatial Alignment",
            description: "Three mysterious beacons appear. Find the right perspective.",
            difficulty: difficulty,
            estimatedTime: difficulty == .beginner ? 600 : 1200,
            requiredRoomSize: .medium,
            puzzleElements: elements,
            objectives: objectives,
            hints: hints
        )
    }

    private func generateSequentialPuzzle(
        difficulty: Puzzle.Difficulty,
        roomData: RoomData
    ) -> Puzzle {
        let stepCount = difficulty == .beginner ? 3 : 5
        let elements = createSequenceButtons(count: stepCount, roomData: roomData)

        let objectives = [
            Objective(
                title: "Activate in Order",
                description: "Press the buttons in the correct sequence",
                requiredElements: elements.map { $0.id }
            )
        ]

        let hints = [
            Hint(text: "Look for numbers or symbols indicating order", difficulty: 1),
            Hint(text: "The sequence might be hidden in the room's features", difficulty: 2)
        ]

        return Puzzle(
            title: "Sequential Activation",
            description: "Buttons appear throughout the room. Order matters.",
            difficulty: difficulty,
            estimatedTime: 900,
            requiredRoomSize: .medium,
            puzzleElements: elements,
            objectives: objectives,
            hints: hints
        )
    }

    private func generateCollaborativePuzzle(
        difficulty: Puzzle.Difficulty,
        roomData: RoomData
    ) -> Puzzle {
        let elements = createSynchronizedSwitches(count: 2, roomData: roomData)

        let objectives = [
            Objective(
                title: "Synchronized Action",
                description: "All players must activate their switches simultaneously",
                requiredElements: elements.map { $0.id }
            )
        ]

        let hints = [
            Hint(text: "This requires teamwork - coordinate with your partners", difficulty: 1),
            Hint(text: "Count down together and activate at the same time", difficulty: 2)
        ]

        return Puzzle(
            title: "Synchronized Actions",
            description: "Teamwork makes the dream work. Act together.",
            difficulty: difficulty,
            estimatedTime: 1200,
            requiredRoomSize: .large,
            puzzleElements: elements,
            objectives: objectives,
            hints: hints
        )
    }

    private func generateObservationPuzzle(
        difficulty: Puzzle.Difficulty,
        roomData: RoomData
    ) -> Puzzle {
        let clueCount = difficulty == .beginner ? 3 : 6
        let elements = createHiddenClues(count: clueCount, roomData: roomData)

        let objectives = [
            Objective(
                title: "Find All Clues",
                description: "Discover all \(clueCount) hidden clues in the room",
                requiredElements: elements.map { $0.id }
            )
        ]

        let hints = [
            Hint(text: "Look carefully at all surfaces - walls, floor, ceiling", difficulty: 1),
            Hint(text: "Some clues might be very small or partially hidden", difficulty: 2)
        ]

        return Puzzle(
            title: "Hidden Objects",
            description: "Clues are hidden throughout your space. Find them all.",
            difficulty: difficulty,
            estimatedTime: 1800,
            requiredRoomSize: .medium,
            puzzleElements: elements,
            objectives: objectives,
            hints: hints
        )
    }

    private func generateManipulationPuzzle(
        difficulty: Puzzle.Difficulty,
        roomData: RoomData
    ) -> Puzzle {
        let elements = createRotatableObjects(count: 3, roomData: roomData)

        let objectives = [
            Objective(
                title: "Align the Symbols",
                description: "Rotate objects until all symbols align correctly",
                requiredElements: elements.map { $0.id }
            )
        ]

        let hints = [
            Hint(text: "You can rotate objects by grabbing and turning them", difficulty: 1),
            Hint(text: "Look for matching symbols or patterns", difficulty: 2)
        ]

        return Puzzle(
            title: "Physical Manipulation",
            description: "Objects need to be rotated into the correct positions.",
            difficulty: difficulty,
            estimatedTime: 1200,
            requiredRoomSize: .small,
            puzzleElements: elements,
            objectives: objectives,
            hints: hints
        )
    }

    // MARK: - Element Creation Helpers

    private func createCodePanels(count: Int, roomData: RoomData) -> [PuzzleElement] {
        (0..<count).map { index in
            PuzzleElement(
                type: .clue,
                position: SIMD3<Float>(Float(index), 1.5, 0),
                modelName: "code_panel_\(index)",
                interactionType: .examine,
                metadata: ["digit": "\(Int.random(in: 0...9))"]
            )
        }
    }

    private func createAlignmentBeacons(count: Int, roomData: RoomData) -> [PuzzleElement] {
        (0..<count).map { index in
            PuzzleElement(
                type: .mechanism,
                position: SIMD3<Float>(Float(index) * 2, 1.5, Float(index)),
                modelName: "beacon_\(index)",
                interactionType: .examine
            )
        }
    }

    private func createSequenceButtons(count: Int, roomData: RoomData) -> [PuzzleElement] {
        (0..<count).map { index in
            PuzzleElement(
                type: .mechanism,
                position: SIMD3<Float>(Float.random(in: -2...2), 1.0, Float.random(in: -2...2)),
                modelName: "button_\(index)",
                interactionType: .tap,
                metadata: ["sequence": "\(index)"]
            )
        }
    }

    private func createSynchronizedSwitches(count: Int, roomData: RoomData) -> [PuzzleElement] {
        (0..<count).map { index in
            PuzzleElement(
                type: .mechanism,
                position: SIMD3<Float>(Float(index) * 3, 1.2, 0),
                modelName: "switch_\(index)",
                interactionType: .tap,
                metadata: ["player": "\(index)"]
            )
        }
    }

    private func createHiddenClues(count: Int, roomData: RoomData) -> [PuzzleElement] {
        (0..<count).map { index in
            PuzzleElement(
                type: .clue,
                position: SIMD3<Float>(Float.random(in: -3...3), Float.random(in: 0.5...2), Float.random(in: -3...3)),
                scale: SIMD3<Float>(0.1, 0.1, 0.1),  // Small clues
                modelName: "clue_\(index)",
                interactionType: .examine
            )
        }
    }

    private func createRotatableObjects(count: Int, roomData: RoomData) -> [PuzzleElement] {
        (0..<count).map { index in
            PuzzleElement(
                type: .mechanism,
                position: SIMD3<Float>(Float(index - 1) * 1.5, 1.0, 0),
                modelName: "rotatable_\(index)",
                interactionType: .rotate,
                metadata: ["target_rotation": "\(Int.random(in: 0...360))"]
            )
        }
    }
}

// MARK: - Puzzle Validator

class PuzzleValidator {
    func validate(puzzle: Puzzle, solution: PuzzleSolution) -> ValidationResult {
        // Basic validation logic
        // In a real implementation, this would check puzzle-specific solution criteria

        let isCorrect = !solution.answer.isEmpty
        let feedback = isCorrect ? "Correct!" : "Incorrect solution"

        return ValidationResult(
            isCorrect: isCorrect,
            feedback: feedback,
            completedObjectives: isCorrect ? puzzle.objectives.map { $0.id } : []
        )
    }
}

// MARK: - Adaptive Hint System

class AdaptiveHintSystem {
    func generateHint(for puzzle: Puzzle, given progress: PuzzleProgress) -> Hint {
        // Determine appropriate hint difficulty based on progress
        let hintsRevealed = progress.revealedHints.count
        let availableHints = puzzle.hints.filter { !progress.revealedHints.contains($0.id) }

        if let hint = availableHints.first {
            return hint
        }

        // Fallback hint if all are revealed
        return Hint(
            text: "You've revealed all hints. Keep trying!",
            difficulty: 1
        )
    }
}
