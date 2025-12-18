import SwiftUI
import RealityKit
import Combine

@MainActor
class GameManager: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var gameState: GameState = .mainMenu
    @Published private(set) var players: [Player] = []
    @Published private(set) var currentRound: Int = 0
    @Published private(set) var totalGamesPlayed: Int = 0

    // MARK: - Dependencies
    private let stateManager: GameStateManager
    private let eventBus: EventBus
    private let persistenceManager: PersistenceManager
    private let gameLoop: GameLoop

    // MARK: - Computed Properties
    var hasPlayers: Bool {
        !players.isEmpty
    }

    var playerCount: Int {
        players.count
    }

    // MARK: - Initialization
    init() {
        // Initialize dependencies
        self.eventBus = EventBus()
        self.persistenceManager = PersistenceManager()
        self.stateManager = GameStateManager(eventBus: eventBus)
        self.gameLoop = GameLoop(stateManager: stateManager)

        // Subscribe to state changes
        subscribeToStateChanges()

        // Load persisted data
        loadPersistedData()
    }

    // MARK: - Game Lifecycle
    func startNewGame() async {
        currentRound = 0
        await stateManager.transition(to: .roomScanning)
    }

    func endGame() async {
        totalGamesPlayed += 1
        await saveGameData()
        await stateManager.transition(to: .mainMenu)
    }

    func pauseGame() async {
        let currentState = stateManager.currentState
        await stateManager.transition(to: .paused(previousState: currentState))
    }

    func resumeGame() async {
        if case .paused(let previousState) = stateManager.currentState {
            await stateManager.transition(to: previousState)
        }
    }

    // MARK: - Player Management
    func addPlayer(_ player: Player) {
        players.append(player)
        Task {
            try? await persistenceManager.savePlayerProfile(player)
        }
    }

    func removePlayer(id: UUID) {
        players.removeAll { $0.id == id }
    }

    func updatePlayer(_ player: Player) {
        if let index = players.firstIndex(where: { $0.id == player.id }) {
            players[index] = player
            Task {
                try? await persistenceManager.savePlayerProfile(player)
            }
        }
    }

    // MARK: - Private Methods
    private func subscribeToStateChanges() {
        Task {
            await eventBus.subscribe { [weak self] event in
                guard let self = self else { return }
                await self.handleGameEvent(event)
            }
        }
    }

    private func handleGameEvent(_ event: GameEvent) async {
        switch event {
        case .stateChanged(_, let newState):
            gameState = newState

        case .playerFound(let player, let foundBy):
            print("Player \(player.name) found by \(foundBy.name)")

        case .roundComplete(let winner):
            currentRound += 1
            print("Round \(currentRound) complete. Winner: \(winner)")

        case .achievementUnlocked(let achievement, let player):
            print("Achievement unlocked for \(player.name): \(achievement)")

        default:
            break
        }
    }

    private func loadPersistedData() {
        // Load total games played and other stats
        // This would typically load from UserDefaults or a database
        totalGamesPlayed = UserDefaults.standard.integer(forKey: "totalGamesPlayed")
    }

    private func saveGameData() async {
        UserDefaults.standard.set(totalGamesPlayed, forKey: "totalGamesPlayed")

        // Save player stats
        for player in players {
            try? await persistenceManager.savePlayerProfile(player)
        }
    }
}

// MARK: - GameEvent Extension
extension GameEvent {
    static func roundComplete(winner: PlayerRole) -> GameEvent {
        return .stateChanged(from: .seeking(timeRemaining: 0), to: .roundEnd(winner: winner))
    }
}
