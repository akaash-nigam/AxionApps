import Foundation
import Observation

/// Game phase enumeration
public enum GamePhase: Sendable {
    case mainMenu
    case training
    case matchmaking
    case inMatch(matchID: UUID)
    case spectating(matchID: UUID)
    case postMatch(results: MatchResults)
}

/// Match results
public struct MatchResults: Sendable, Codable {
    public let matchID: UUID
    public let winner: Match.Winner
    public let playerStats: [UUID: PlayerMatchStats]
    public let duration: TimeInterval

    public init(
        matchID: UUID,
        winner: Match.Winner,
        playerStats: [UUID: PlayerMatchStats],
        duration: TimeInterval
    ) {
        self.matchID = matchID
        self.winner = winner
        self.playerStats = playerStats
        self.duration = duration
    }
}

/// Player statistics for a single match
public struct PlayerMatchStats: Sendable, Codable {
    public var kills: Int
    public var deaths: Int
    public var assists: Int
    public var damageDealt: Float
    public var accuracy: Float

    public init(
        kills: Int = 0,
        deaths: Int = 0,
        assists: Int = 0,
        damageDealt: Float = 0,
        accuracy: Float = 0
    ) {
        self.kills = kills
        self.deaths = deaths
        self.assists = assists
        self.damageDealt = damageDealt
        self.accuracy = accuracy
    }

    public var kda: Double {
        guard deaths > 0 else { return Double(kills + assists) }
        return Double(kills + assists) / Double(deaths)
    }
}

/// Observable game state
@Observable
@MainActor
public final class GameState {
    public var currentPhase: GamePhase = .mainMenu
    public var localPlayer: Player?
    public var currentMatch: Match?

    // Performance metrics
    public var currentFPS: Double = 0
    public var latency: TimeInterval = 0
    public var frameTime: TimeInterval = 0

    public init() {}

    /// Check if player is in an active match
    public var isInMatch: Bool {
        if case .inMatch = currentPhase {
            return true
        }
        return false
    }

    /// Check if player is spectating
    public var isSpectating: Bool {
        if case .spectating = currentPhase {
            return true
        }
        return false
    }
}

/// State machine for game flow
public actor GameStateMachine {
    private var state: GameState

    public init(state: GameState) {
        self.state = state
    }

    /// Transition to a new game phase
    public func transition(to newPhase: GamePhase) async throws {
        // Capture state for MainActor access
        let localState = state

        // Get current phase from MainActor
        let currentPhase = await MainActor.run { localState.currentPhase }

        // Validate transition
        guard canTransition(from: currentPhase, to: newPhase) else {
            throw GameStateError.invalidTransition(
                from: currentPhase,
                to: newPhase
            )
        }

        // Cleanup old phase
        await cleanup(phase: currentPhase)

        // Update state
        await MainActor.run {
            localState.currentPhase = newPhase
        }

        // Setup new phase
        await setup(phase: newPhase)
    }

    /// Check if transition is valid
    private func canTransition(from: GamePhase, to: GamePhase) -> Bool {
        switch (from, to) {
        case (.mainMenu, .training),
             (.mainMenu, .matchmaking):
            return true

        case (.training, .mainMenu):
            return true

        case (.matchmaking, .inMatch),
             (.matchmaking, .mainMenu):
            return true

        case (.inMatch, .postMatch),
             (.inMatch, .mainMenu):
            return true

        case (.postMatch, .mainMenu),
             (.postMatch, .matchmaking):
            return true

        case (.spectating, .mainMenu):
            return true

        default:
            return false
        }
    }

    /// Cleanup when leaving a phase
    private func cleanup(phase: GamePhase) async {
        switch phase {
        case .inMatch:
            // Disconnect from match
            break
        case .matchmaking:
            // Leave matchmaking queue
            break
        default:
            break
        }
    }

    /// Setup when entering a phase
    private func setup(phase: GamePhase) async {
        switch phase {
        case .inMatch:
            // Initialize match
            break
        case .training:
            // Load training environment
            break
        default:
            break
        }
    }

    /// Get current phase
    public var currentPhase: GamePhase {
        get async {
            let localState = state
            return await MainActor.run { localState.currentPhase }
        }
    }
}

/// Game state errors
public enum GameStateError: Error {
    case invalidTransition(from: GamePhase, to: GamePhase)
    case matchNotFound
    case playerNotFound
}
