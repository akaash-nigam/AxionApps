import Foundation

/// Game state enumeration
enum GameState: Equatable {
    case initialization
    case roomScanning
    case roomMapping
    case loadingPuzzle
    case playing
    case paused
    case puzzleCompleted
    case gameOver
    case multiplayerLobby
    case multiplayerSession
}

/// Protocol for game state behavior
protocol GameStateProtocol {
    func onEnter()
    func onUpdate(deltaTime: TimeInterval)
    func onExit()
    func canTransition(to newState: GameState) -> Bool
}

/// Game state machine managing state transitions
class GameStateMachine {
    private(set) var currentState: GameState
    private var states: [GameState: GameStateProtocol] = [:]
    private var stateChangeListeners: [(GameState, GameState) -> Void] = []

    init(initialState: GameState = .initialization) {
        self.currentState = initialState
        setupStates()
    }

    private func setupStates() {
        states[.initialization] = InitializationState()
        states[.roomScanning] = RoomScanningState()
        states[.roomMapping] = RoomMappingState()
        states[.loadingPuzzle] = LoadingPuzzleState()
        states[.playing] = PlayingState()
        states[.paused] = PausedState()
        states[.puzzleCompleted] = PuzzleCompletedState()
        states[.gameOver] = GameOverState()
        states[.multiplayerLobby] = MultiplayerLobbyState()
        states[.multiplayerSession] = MultiplayerSessionState()
    }

    func transition(to newState: GameState) -> Bool {
        guard currentState != newState else {
            return false
        }

        guard states[currentState]?.canTransition(to: newState) == true else {
            print("⚠️ Cannot transition from \(currentState) to \(newState)")
            return false
        }

        let previousState = currentState

        // Exit current state
        states[currentState]?.onExit()

        // Update state
        currentState = newState

        // Enter new state
        states[currentState]?.onEnter()

        // Notify listeners
        stateChangeListeners.forEach { $0(previousState, newState) }

        print("✓ State transition: \(previousState) → \(newState)")
        return true
    }

    func update(deltaTime: TimeInterval) {
        states[currentState]?.onUpdate(deltaTime: deltaTime)
    }

    func addStateChangeListener(_ listener: @escaping (GameState, GameState) -> Void) {
        stateChangeListeners.append(listener)
    }
}

// MARK: - State Implementations

class InitializationState: GameStateProtocol {
    func onEnter() {
        print("🎮 Initializing game...")
    }

    func onUpdate(deltaTime: TimeInterval) {
        // Initialization logic
    }

    func onExit() {
        print("✓ Game initialized")
    }

    func canTransition(to newState: GameState) -> Bool {
        switch newState {
        case .roomScanning, .multiplayerLobby:
            return true
        default:
            return false
        }
    }
}

class RoomScanningState: GameStateProtocol {
    func onEnter() {
        print("📷 Starting room scan...")
    }

    func onUpdate(deltaTime: TimeInterval) {
        // Room scanning update logic
    }

    func onExit() {
        print("✓ Room scan complete")
    }

    func canTransition(to newState: GameState) -> Bool {
        switch newState {
        case .roomMapping, .initialization:
            return true
        default:
            return false
        }
    }
}

class RoomMappingState: GameStateProtocol {
    func onEnter() {
        print("🗺️ Mapping room...")
    }

    func onUpdate(deltaTime: TimeInterval) {
        // Room mapping logic
    }

    func onExit() {
        print("✓ Room mapping complete")
    }

    func canTransition(to newState: GameState) -> Bool {
        switch newState {
        case .loadingPuzzle, .roomScanning:
            return true
        default:
            return false
        }
    }
}

class LoadingPuzzleState: GameStateProtocol {
    func onEnter() {
        print("⏳ Loading puzzle...")
    }

    func onUpdate(deltaTime: TimeInterval) {
        // Puzzle loading logic
    }

    func onExit() {
        print("✓ Puzzle loaded")
    }

    func canTransition(to newState: GameState) -> Bool {
        switch newState {
        case .playing, .roomMapping:
            return true
        default:
            return false
        }
    }
}

class PlayingState: GameStateProtocol {
    func onEnter() {
        print("🎯 Starting gameplay...")
    }

    func onUpdate(deltaTime: TimeInterval) {
        // Main gameplay update logic
    }

    func onExit() {
        print("⏸️ Gameplay paused")
    }

    func canTransition(to newState: GameState) -> Bool {
        switch newState {
        case .paused, .puzzleCompleted, .gameOver:
            return true
        default:
            return false
        }
    }
}

class PausedState: GameStateProtocol {
    func onEnter() {
        print("⏸️ Game paused")
    }

    func onUpdate(deltaTime: TimeInterval) {
        // Paused state logic (minimal updates)
    }

    func onExit() {
        print("▶️ Resuming game")
    }

    func canTransition(to newState: GameState) -> Bool {
        switch newState {
        case .playing, .gameOver, .initialization:
            return true
        default:
            return false
        }
    }
}

class PuzzleCompletedState: GameStateProtocol {
    func onEnter() {
        print("🎉 Puzzle completed!")
    }

    func onUpdate(deltaTime: TimeInterval) {
        // Completion celebration logic
    }

    func onExit() {
        print("✓ Moving to next puzzle")
    }

    func canTransition(to newState: GameState) -> Bool {
        switch newState {
        case .loadingPuzzle, .gameOver, .initialization:
            return true
        default:
            return false
        }
    }
}

class GameOverState: GameStateProtocol {
    func onEnter() {
        print("🏁 Game over")
    }

    func onUpdate(deltaTime: TimeInterval) {
        // Game over screen logic
    }

    func onExit() {
        print("✓ Exiting game over")
    }

    func canTransition(to newState: GameState) -> Bool {
        switch newState {
        case .initialization:
            return true
        default:
            return false
        }
    }
}

class MultiplayerLobbyState: GameStateProtocol {
    func onEnter() {
        print("👥 Entering multiplayer lobby...")
    }

    func onUpdate(deltaTime: TimeInterval) {
        // Lobby update logic
    }

    func onExit() {
        print("✓ Leaving lobby")
    }

    func canTransition(to newState: GameState) -> Bool {
        switch newState {
        case .multiplayerSession, .initialization:
            return true
        default:
            return false
        }
    }
}

class MultiplayerSessionState: GameStateProtocol {
    func onEnter() {
        print("👥 Starting multiplayer session...")
    }

    func onUpdate(deltaTime: TimeInterval) {
        // Multiplayer session logic
    }

    func onExit() {
        print("✓ Ending multiplayer session")
    }

    func canTransition(to newState: GameState) -> Bool {
        switch newState {
        case .roomScanning, .loadingPuzzle, .multiplayerLobby:
            return true
        default:
            return false
        }
    }
}
