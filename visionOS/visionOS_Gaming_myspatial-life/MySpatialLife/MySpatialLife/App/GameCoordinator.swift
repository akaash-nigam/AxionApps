import SwiftUI
import Observation

@Observable
@MainActor
class GameCoordinator {
    // Core game systems
    private(set) var gameLoop: GameLoop?
    private(set) var gameState: GameState?

    // Lifecycle state
    var isGameRunning: Bool = false
    var isPaused: Bool = false

    // Current family
    var currentFamily: Family?

    init() {
        // Game coordinator initializes but doesn't start game loop yet
    }

    func startNewGame(family: Family) async {
        self.currentFamily = family

        // Initialize game state
        let newGameState = GameState()
        newGameState.currentFamily = family
        self.gameState = newGameState

        // Initialize and start game loop
        let loop = GameLoop(gameState: newGameState)
        self.gameLoop = loop

        isGameRunning = true
        isPaused = false

        // Start the game loop
        await loop.start()
    }

    func pauseGame() {
        isPaused = true
        gameLoop?.pause()
    }

    func resumeGame() {
        isPaused = false
        gameLoop?.resume()
    }

    func stopGame() async {
        await gameLoop?.stop()
        isGameRunning = false
        gameLoop = nil
    }

    func saveGame(name: String) async throws {
        guard let gameState = gameState else {
            throw GameError.noActiveGame
        }

        let saveManager = SaveManager()
        try await saveManager.saveGame(gameState: gameState, name: name)
    }

    func loadGame(saveID: UUID) async throws {
        let saveManager = SaveManager()
        let loadedState = try await saveManager.loadGame(saveID: saveID)

        self.gameState = loadedState
        self.currentFamily = loadedState.currentFamily

        if let gameState = self.gameState {
            let loop = GameLoop(gameState: gameState)
            self.gameLoop = loop

            isGameRunning = true
            isPaused = false

            await loop.start()
        }
    }
}

enum GameError: Error {
    case noActiveGame
    case saveFailure
    case loadFailure
}

// Placeholder for SaveManager (will implement in Persistence phase)
actor SaveManager {
    func saveGame(gameState: GameState, name: String) async throws {
        // TODO: Implement save functionality
    }

    func loadGame(saveID: UUID) async throws -> GameState {
        // TODO: Implement load functionality
        throw GameError.loadFailure
    }
}
