import Foundation
import Observation

/// Manages game state transitions and state stack for the game
@Observable
class GameStateManager {
    // MARK: - Properties

    private(set) var currentState: GameState = .initializing
    private(set) var previousState: GameState?
    private var stateStack: [GameState] = []

    // State transition callbacks
    private var onStateEnter: [(GameState) -> Void] = []
    private var onStateExit: [(GameState) -> Void] = []

    // MARK: - Initialization

    init(initialState: GameState = .initializing) {
        self.currentState = initialState
    }

    // MARK: - State Transitions

    /// Transition to a new game state
    /// - Parameter newState: The state to transition to
    func transition(to newState: GameState) {
        guard currentState != newState else {
            print("⚠️ Already in state \(newState), ignoring transition")
            return
        }

        print("🔄 State transition: \(currentState) → \(newState)")

        // Execute exit callbacks for current state
        executeExitCallbacks(for: currentState)

        // Update states
        previousState = currentState
        currentState = newState

        // Execute enter callbacks for new state
        executeEnterCallbacks(for: newState)

        // Handle spatial mode changes
        handleSpatialModeChange(for: newState)
    }

    /// Push a new state onto the stack, allowing return to current state
    /// - Parameter state: The state to push
    func pushState(_ state: GameState) {
        print("⬆️ Pushing state: \(state), current: \(currentState)")
        stateStack.append(currentState)
        transition(to: state)
    }

    /// Pop back to the previous state on the stack
    /// - Returns: True if a state was popped, false if stack was empty
    @discardableResult
    func popState() -> Bool {
        guard let previousState = stateStack.popLast() else {
            print("⚠️ State stack is empty, cannot pop")
            return false
        }

        print("⬇️ Popping to state: \(previousState)")
        transition(to: previousState)
        return true
    }

    /// Clear the entire state stack
    func clearStateStack() {
        print("🗑️ Clearing state stack (\(stateStack.count) states)")
        stateStack.removeAll()
    }

    /// Check if we can return to a previous state
    var canPopState: Bool {
        !stateStack.isEmpty
    }

    // MARK: - State Observers

    /// Register a callback to be called when entering a state
    /// - Parameter callback: The callback to execute on state enter
    func onEnter(_ callback: @escaping (GameState) -> Void) {
        onStateEnter.append(callback)
    }

    /// Register a callback to be called when exiting a state
    /// - Parameter callback: The callback to execute on state exit
    func onExit(_ callback: @escaping (GameState) -> Void) {
        onStateExit.append(callback)
    }

    // MARK: - Private Methods

    private func executeEnterCallbacks(for state: GameState) {
        onStateEnter.forEach { $0(state) }
    }

    private func executeExitCallbacks(for state: GameState) {
        onStateExit.forEach { $0(state) }
    }

    private func handleSpatialModeChange(for state: GameState) {
        // Determine if spatial mode needs to change based on state
        if state.requiresImmersiveSpace {
            print("🌌 State requires immersive space")
            // SpatialModeManager will handle actual transition
        } else {
            print("🪟 State uses window mode")
        }
    }

    // MARK: - State Queries

    /// Check if currently in an active gameplay state
    var isInActiveGameplay: Bool {
        currentState.isActiveGameplay
    }

    /// Get the current era being explored, if any
    var currentEra: HistoricalEra? {
        switch currentState {
        case .loadingEra(let era), .exploring(let era):
            return era
        default:
            return nil
        }
    }

    /// Check if background audio should be playing
    var shouldPlayBackgroundAudio: Bool {
        currentState.allowsBackgroundAudio
    }
}

// MARK: - State Validation

extension GameStateManager {
    /// Validate if a state transition is allowed
    /// - Parameters:
    ///   - from: Source state
    ///   - to: Destination state
    /// - Returns: True if transition is valid
    func isValidTransition(from: GameState, to: GameState) -> Bool {
        // Define invalid transitions
        switch (from, to) {
        case (.initializing, .exploring):
            // Can't go directly to exploring without calibration
            return false
        case (.calibrating, .exploring):
            // Need to select era first
            return false
        default:
            return true
        }
    }

    /// Get a list of valid next states from current state
    var validNextStates: [GameState] {
        switch currentState {
        case .initializing:
            return [.calibrating, .mainMenu]
        case .calibrating:
            return [.mainMenu]
        case .mainMenu:
            return [.selectingEra, .settings, .viewingTimeline]
        case .selectingEra:
            return [.mainMenu] // Plus .loadingEra for specific eras
        case .exploring:
            return [.mainMenu, .pause, .viewingTimeline]
            // Plus examining artifacts, conversing, solving mysteries
        case .pause:
            return [currentState == .pause ? previousState ?? .mainMenu : .mainMenu]
        default:
            return [.mainMenu]
        }
    }
}

// MARK: - Debug

extension GameStateManager: CustomDebugStringConvertible {
    var debugDescription: String {
        """
        GameStateManager(
          current: \(currentState),
          previous: \(previousState?.description ?? "nil"),
          stack depth: \(stateStack.count),
          in gameplay: \(isInActiveGameplay)
        )
        """
    }
}
