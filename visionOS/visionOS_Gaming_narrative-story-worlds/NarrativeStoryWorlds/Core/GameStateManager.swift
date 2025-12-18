import Foundation

/// Manages the overall game state and state transitions
@MainActor
class GameStateManager: @unchecked Sendable {
    // MARK: - Properties
    private(set) var currentState: GameState = .initializing
    private var stateHistory: [GameState] = []

    // MARK: - Update
    func update(deltaTime: TimeInterval) {
        // Update based on current state
        switch currentState {
        case .playingStory:
            updateGameplay(deltaTime: deltaTime)
        case .choicePresentation:
            updateChoiceTimer(deltaTime: deltaTime)
        default:
            break
        }
    }

    // MARK: - State Transitions
    func transition(to newState: GameState) {
        guard isValidTransition(from: currentState, to: newState) else {
            print("⚠️ Invalid state transition: \(currentState) -> \(newState)")
            return
        }

        // Store previous state
        stateHistory.append(currentState)

        // Perform transition
        exitState(currentState)
        currentState = newState
        enterState(newState)

        print("✓ State transition: \(stateHistory.last ?? .initializing) -> \(currentState)")
    }

    func revertToPreviousState() {
        guard let previousState = stateHistory.popLast() else {
            return
        }
        transition(to: previousState)
    }

    // MARK: - State Validation
    private func isValidTransition(from: GameState, to: GameState) -> Bool {
        switch (from, to) {
        case (.initializing, .menuNavigation),
             (.menuNavigation, .roomCalibration),
             (.roomCalibration, .storyPlaying),
             (.storyPlaying, .choicePresentation),
             (.storyPlaying, .paused),
             (.choicePresentation, .storyPlaying),
             (.paused, .storyPlaying),
             (.paused, .menuNavigation),
             (_, .loading):
            return true
        default:
            return false
        }
    }

    // MARK: - State Lifecycle
    private func exitState(_ state: GameState) {
        switch state {
        case .storyPlaying:
            // Pause audio, etc.
            break
        case .choicePresentation:
            // Clean up choice UI
            break
        default:
            break
        }
    }

    private func enterState(_ state: GameState) {
        switch state {
        case .roomCalibration:
            // Start room scanning
            break
        case .storyPlaying:
            // Resume story
            break
        case .choicePresentation:
            // Show choices
            break
        case .paused:
            // Show pause menu
            break
        default:
            break
        }
    }

    // MARK: - Private Update Methods
    private func updateGameplay(deltaTime: TimeInterval) {
        // Update gameplay systems
    }

    private var choiceTimer: TimeInterval = 0
    private func updateChoiceTimer(deltaTime: TimeInterval) {
        choiceTimer += deltaTime
        // Handle choice timeout if applicable
    }
}

// MARK: - Game State
enum GameState: Equatable {
    case initializing
    case menuNavigation
    case roomCalibration
    case storyPlaying(chapter: String, scene: String)
    case choicePresentation(choice: String)
    case characterInteraction(characterID: String)
    case paused
    case loading(progress: Float)

    // Simplified equality for switch statements
    static func == (lhs: GameState, rhs: GameState) -> Bool {
        switch (lhs, rhs) {
        case (.initializing, .initializing),
             (.menuNavigation, .menuNavigation),
             (.roomCalibration, .roomCalibration),
             (.paused, .paused):
            return true
        case (.storyPlaying, .storyPlaying),
             (.choicePresentation, .choicePresentation),
             (.characterInteraction, .characterInteraction),
             (.loading, .loading):
            return true
        default:
            return false
        }
    }
}
