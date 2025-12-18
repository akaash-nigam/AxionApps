import Foundation

// MARK: - Game State Definition
enum GameState: Equatable {
    case mainMenu
    case roomScanning
    case playerSetup
    case roleSelection
    case hiding(timeRemaining: TimeInterval)
    case seeking(timeRemaining: TimeInterval)
    case roundEnd(winner: PlayerRole)
    case gameOver(results: GameResults)
    case paused(previousState: GameState)

    static func == (lhs: GameState, rhs: GameState) -> Bool {
        switch (lhs, rhs) {
        case (.mainMenu, .mainMenu),
             (.roomScanning, .roomScanning),
             (.playerSetup, .playerSetup),
             (.roleSelection, .roleSelection):
            return true
        case (.hiding(let t1), .hiding(let t2)),
             (.seeking(let t1), .seeking(let t2)):
            return abs(t1 - t2) < 0.01
        case (.roundEnd(let w1), .roundEnd(let w2)):
            return w1 == w2
        case (.gameOver(let r1), .gameOver(let r2)):
            return r1.id == r2.id
        case (.paused(let s1), .paused(let s2)):
            return s1 == s2
        default:
            return false
        }
    }
}

// MARK: - Game Results
struct GameResults: Identifiable {
    let id: UUID
    let totalRounds: Int
    let hidersWon: Int
    let seekersWon: Int
    let playerStats: [UUID: PlayerStats]

    init(id: UUID = UUID(), totalRounds: Int, hidersWon: Int, seekersWon: Int, playerStats: [UUID: PlayerStats]) {
        self.id = id
        self.totalRounds = totalRounds
        self.hidersWon = hidersWon
        self.seekersWon = seekersWon
        self.playerStats = playerStats
    }
}

// MARK: - Game State Manager
@MainActor
class GameStateManager: ObservableObject {
    @Published private(set) var currentState: GameState = .mainMenu
    @Published private(set) var players: [Player] = []
    @Published private(set) var currentRound: Int = 0

    private let eventBus: EventBus
    private let persistenceManager: PersistenceManager

    init(eventBus: EventBus, persistenceManager: PersistenceManager = PersistenceManager()) {
        self.eventBus = eventBus
        self.persistenceManager = persistenceManager
    }

    func transition(to newState: GameState) async {
        let oldState = currentState
        currentState = newState

        // Emit state change event
        await eventBus.emit(.stateChanged(from: oldState, to: newState))

        // Perform state-specific setup
        await handleStateEntry(newState)
    }

    func update(deltaTime: TimeInterval) async {
        // Update current state based on delta time
        switch currentState {
        case .hiding(let timeRemaining):
            if timeRemaining > 0 {
                await transition(to: .hiding(timeRemaining: timeRemaining - deltaTime))
            } else {
                // Hiding time expired, start seeking phase
                await transition(to: .seeking(timeRemaining: 180)) // 3 minutes
            }

        case .seeking(let timeRemaining):
            if timeRemaining > 0 {
                await transition(to: .seeking(timeRemaining: timeRemaining - deltaTime))
            } else {
                // Seeking time expired, hiders win
                await transition(to: .roundEnd(winner: .hider))
            }

        default:
            break
        }
    }

    private func handleStateEntry(_ state: GameState) async {
        switch state {
        case .roomScanning:
            print("Starting room scanning...")

        case .hiding(let timeRemaining):
            print("Hiding phase started. Time: \(timeRemaining)s")
            await startHidingPhase(duration: timeRemaining)

        case .seeking(let timeRemaining):
            print("Seeking phase started. Time: \(timeRemaining)s")
            await startSeekingPhase(duration: timeRemaining)

        case .roundEnd(let winner):
            print("Round ended. Winner: \(winner)")
            await processRoundEnd(winner: winner)

        default:
            break
        }
    }

    private func startHidingPhase(duration: TimeInterval) async {
        // Initialize hiding phase
        // - Reset player positions
        // - Activate hiding abilities
        // - Start timer
    }

    private func startSeekingPhase(duration: TimeInterval) async {
        // Initialize seeking phase
        // - Reset seeker positions
        // - Activate seeking abilities
        // - Start clue generation
        // - Start timer
    }

    private func processRoundEnd(winner: PlayerRole) async {
        currentRound += 1

        // Update player stats
        for i in 0..<players.count {
            if players[i].role == winner {
                players[i].stats.gamesWon += 1
            }
            players[i].stats.totalGamesPlayed += 1
        }

        // Save progress
        for player in players {
            try? await persistenceManager.savePlayerProfile(player)
        }

        // Emit round complete event
        await eventBus.emit(.stateChanged(from: currentState, to: .roleSelection))
    }
}
