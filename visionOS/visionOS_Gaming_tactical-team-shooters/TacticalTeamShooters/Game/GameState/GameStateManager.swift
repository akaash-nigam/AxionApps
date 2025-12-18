import Foundation
import Observation

@Observable
class GameStateManager {
    var currentState: GameState = .mainMenu
    var matchState: MatchState?
    var localPlayer: Player?

    // MARK: - Game State

    enum GameState {
        case mainMenu
        case matchmaking
        case lobby
        case inGame(GamePhase)
        case pauseMenu
        case endGame(GameResult)
    }

    enum GamePhase {
        case warmup
        case freezeTime
        case roundActive
        case roundEnd
    }

    struct GameResult {
        let winner: Team
        let finalScore: (attackers: Int, defenders: Int)
        let mvp: Player
        let matchDuration: TimeInterval
    }

    // MARK: - State Transitions

    func transition(to newState: GameState) {
        exitState(currentState)
        currentState = newState
        enterState(newState)
    }

    private func exitState(_ state: GameState) {
        switch state {
        case .inGame:
            cleanupGameSession()
        case .matchmaking:
            cancelMatchmaking()
        default:
            break
        }
    }

    private func enterState(_ state: GameState) {
        switch state {
        case .inGame(let phase):
            setupGameSession(phase: phase)
        case .matchmaking:
            startMatchmaking()
        case .endGame(let result):
            processGameResult(result)
        default:
            break
        }
    }

    // MARK: - Game Session Management

    private func setupGameSession(phase: GamePhase) {
        // Initialize match state
        matchState = MatchState()

        // Start game systems
        NotificationCenter.default.post(name: .gameSessionStarted, object: nil)
    }

    private func cleanupGameSession() {
        // Stop game systems
        matchState = nil
        NotificationCenter.default.post(name: .gameSessionEnded, object: nil)
    }

    private func startMatchmaking() {
        // Start matchmaking process
        NotificationCenter.default.post(name: .matchmakingStarted, object: nil)
    }

    private func cancelMatchmaking() {
        NotificationCenter.default.post(name: .matchmakingCancelled, object: nil)
    }

    private func processGameResult(_ result: GameResult) {
        // Save statistics
        // Update rankings
        // Award XP and rewards
    }
}

// MARK: - Match State

struct MatchState: Codable {
    var matchId: UUID = UUID()
    var currentRound: Int = 0
    var attackersScore: Int = 0
    var defendersScore: Int = 0
    var roundStartTime: Date = Date()
    var roundTimeRemaining: TimeInterval = 120.0

    var teams: [Team] = []
    var currentPhase: GameStateManager.GamePhase = .warmup
}

// MARK: - Notifications

extension Notification.Name {
    static let gameSessionStarted = Notification.Name("gameSessionStarted")
    static let gameSessionEnded = Notification.Name("gameSessionEnded")
    static let matchmakingStarted = Notification.Name("matchmakingStarted")
    static let matchmakingCancelled = Notification.Name("matchmakingCancelled")
}
