import Foundation
import Observation

/// Main game state manager using Swift's Observation framework
/// This is the single source of truth for the entire game state
@Observable
class GameState {
    // MARK: - Game Phase

    enum Phase: Equatable {
        case lobby
        case tutorial
        case wordSelection
        case drawing(artist: Player, word: Word, timeRemaining: TimeInterval)
        case guessing(artist: Player, word: Word, guesses: [Guess])
        case reveal(word: Word, winner: Player?, drawing: Drawing3D)
        case scoring(results: RoundResults)
        case gameOver
    }

    // MARK: - State Properties

    var currentPhase: Phase = .lobby
    var players: [Player] = []
    var currentArtist: Player?
    var currentWord: Word?
    var drawings: [Drawing3D] = []
    var scores: [UUID: Int] = [:]
    var roundNumber: Int = 0
    var timeRemaining: TimeInterval = 0
    var settings: GameSettings = GameSettings()

    // MARK: - Computed Properties

    var maxPlayers: Int { 12 }

    var isGameActive: Bool {
        switch currentPhase {
        case .drawing, .guessing:
            return true
        default:
            return false
        }
    }

    // MARK: - Initialization

    init() {
        // Initialize with default state
    }

    // MARK: - Phase Transitions

    func transitionTo(_ newPhase: Phase) {
        // Handle cleanup of current phase
        exitCurrentPhase()

        // Transition to new phase
        currentPhase = newPhase

        // Initialize new phase
        enterNewPhase(newPhase)
    }

    private func exitCurrentPhase() {
        // Cleanup based on current phase
        switch currentPhase {
        case .drawing:
            // Stop timer, finalize drawing
            break
        case .guessing:
            // Process final guesses
            break
        default:
            break
        }
    }

    private func enterNewPhase(_ phase: Phase) {
        // Initialize based on new phase
        switch phase {
        case .drawing(_, _, let time):
            timeRemaining = time
            startTimer()
        case .lobby:
            resetRound()
        default:
            break
        }
    }

    // MARK: - Player Management

    func addPlayer(_ player: Player) {
        guard players.count < maxPlayers else {
            print("Cannot add player: max players reached")
            return
        }

        if !players.contains(where: { $0.id == player.id }) {
            players.append(player)
            scores[player.id] = 0
        }
    }

    func removePlayer(_ playerID: UUID) {
        players.removeAll { $0.id == playerID }
        scores.removeValue(forKey: playerID)
    }

    func selectNextArtist() -> Player? {
        guard !players.isEmpty else { return nil }

        if let current = currentArtist,
           let currentIndex = players.firstIndex(where: { $0.id == current.id }) {
            let nextIndex = (currentIndex + 1) % players.count
            currentArtist = players[nextIndex]
        } else {
            currentArtist = players.first
        }

        return currentArtist
    }

    // MARK: - Word Selection

    func selectWord(_ word: Word, artist: Player) {
        currentWord = word
        currentArtist = artist

        currentPhase = .drawing(
            artist: artist,
            word: word,
            timeRemaining: settings.roundDuration
        )
    }

    // MARK: - Scoring

    func addScore(_ points: Int, to playerID: UUID) {
        scores[playerID, default: 0] += points
    }

    func getLeaderboard() -> [(playerID: UUID, score: Int)] {
        scores.sorted { $0.value > $1.value }
            .map { (playerID: $0.key, score: $0.value) }
    }

    // MARK: - Round Management

    func completeRound() {
        roundNumber += 1
    }

    func resetRound() {
        currentWord = nil
        drawings.removeAll()
        timeRemaining = 0
    }

    func resetGame() {
        currentPhase = .lobby
        players.removeAll()
        scores.removeAll()
        roundNumber = 0
        resetRound()
    }

    // MARK: - Timer

    private var timer: Timer?

    func startTimer() {
        stopTimer()

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func updateTimer() {
        guard timeRemaining > 0 else {
            stopTimer()
            handleTimeExpired()
            return
        }

        timeRemaining -= 1
    }

    private func handleTimeExpired() {
        // Time's up - transition to reveal
        if case .drawing(let artist, let word, _) = currentPhase {
            currentPhase = .reveal(
                word: word,
                winner: nil,
                drawing: drawings.first ?? Drawing3D.mock()
            )
        }
    }

    // MARK: - Update Methods

    func updateScores() {
        // Recalculate scores based on current state
    }

    func updateTimer(deltaTime: TimeInterval) {
        if timeRemaining > 0 {
            timeRemaining -= deltaTime
        }
    }
}

// MARK: - Supporting Types

struct Guess: Codable {
    var playerID: UUID
    var text: String
    var timestamp: TimeInterval
    var isCorrect: Bool
}

struct RoundResults: Codable {
    var roundNumber: Int
    var artist: UUID
    var word: Word
    var winner: UUID?
    var drawing: Drawing3D?
    var scores: [UUID: Int]
    var guesses: [Guess]
}

// MARK: - Game Settings

struct GameSettings: Codable {
    var roundDuration: TimeInterval = 90 // seconds
    var numberOfRounds: Int = 8
    var difficulty: Word.Difficulty = .medium
    var categories: Set<Word.Category> = [.animals, .objects, .actions]
    var maxPlayers: Int = 8
    var allowHints: Bool = true
    var customWordList: [Word] = []

    // Spatial settings
    var spatialMode: String = "volume"
    var canvasSize: Float = 1.0 // meters
    var enableParticles: Bool = true

    func isValid() -> Bool {
        return roundDuration >= 30 && roundDuration <= 300 &&
               numberOfRounds >= 1 && numberOfRounds <= 20 &&
               maxPlayers >= 2 && maxPlayers <= 12
    }
}
