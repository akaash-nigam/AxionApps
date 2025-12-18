//
//  GameStateManager.swift
//  Reality Realms RPG
//
//  Manages high-level game state and transitions
//

import Foundation
import SwiftUI

/// High-level game states
enum GameState: Equatable {
    case initialization
    case roomScanning
    case tutorial
    case gameplay(GameplayState)
    case paused
    case loading(String)  // Loading context
    case error(String)    // Error message

    var description: String {
        switch self {
        case .initialization: return "Initializing"
        case .roomScanning: return "Scanning Room"
        case .tutorial: return "Tutorial"
        case .gameplay(let state): return "Playing (\(state))"
        case .paused: return "Paused"
        case .loading(let context): return "Loading: \(context)"
        case .error(let message): return "Error: \(message)"
        }
    }
}

/// Sub-states during gameplay
enum GameplayState: Equatable {
    case exploration
    case combat(enemyCount: Int)
    case dialogue(npcID: UUID)
    case inventory
    case multiplayer(sessionID: String)
    case questManagement
}

/// Game errors
enum GameError: Error, LocalizedError {
    case roomMappingFailed
    case spatialTrackingLost
    case saveDataCorrupted
    case multiplayerConnectionFailed
    case insufficientSpace

    var errorDescription: String? {
        switch self {
        case .roomMappingFailed:
            return "Failed to map your room. Please ensure you have adequate lighting."
        case .spatialTrackingLost:
            return "Spatial tracking lost. Please look around to re-establish tracking."
        case .saveDataCorrupted:
            return "Save data is corrupted. Starting new game."
        case .multiplayerConnectionFailed:
            return "Failed to connect to multiplayer session."
        case .insufficientSpace:
            return "Insufficient play space. Please ensure at least 2m x 2m of clear area."
        }
    }
}

/// Manages game state transitions and history
@MainActor
class GameStateManager: ObservableObject {
    static let shared = GameStateManager()

    @Published private(set) var currentState: GameState = .initialization
    @Published var isGameActive: Bool = false

    private var stateHistory: [GameState] = []
    private let maxHistorySize = 10

    private init() {
        print("🎮 GameStateManager initialized")
        setupEventSubscriptions()
    }

    // MARK: - State Transitions

    func transition(to newState: GameState) {
        let oldState = currentState

        // Validate transition
        guard canTransition(from: oldState, to: newState) else {
            print("⚠️ Invalid state transition from \(oldState) to \(newState)")
            return
        }

        // Update history
        stateHistory.append(oldState)
        if stateHistory.count > maxHistorySize {
            stateHistory.removeFirst()
        }

        // Perform transition
        currentState = newState
        isGameActive = isActiveState(newState)

        print("📊 State transition: \(oldState.description) → \(newState.description)")

        // Publish event
        EventBus.shared.publish(StateChangeEvent(from: oldState, to: newState))

        // Handle state-specific logic
        onStateEntered(newState)
    }

    /// Check if transition is valid
    private func canTransition(from: GameState, to: GameState) -> Bool {
        // Define valid transitions
        switch (from, to) {
        case (.initialization, .roomScanning):
            return true
        case (.roomScanning, .tutorial):
            return true
        case (.tutorial, .gameplay):
            return true
        case (.gameplay, .paused):
            return true
        case (.paused, .gameplay):
            return true
        case (_, .error):
            return true  // Can error from any state
        case (_, .loading):
            return true  // Can load from any state
        default:
            return false
        }
    }

    /// Handle state entry logic
    private func onStateEntered(_ state: GameState) {
        switch state {
        case .initialization:
            initializeGame()

        case .roomScanning:
            startRoomScanning()

        case .tutorial:
            startTutorial()

        case .gameplay(let gameplayState):
            handleGameplayState(gameplayState)

        case .paused:
            pauseGame()

        case .loading(let context):
            print("📦 Loading: \(context)")

        case .error(let message):
            handleError(message)
        }
    }

    /// Determine if state represents active gameplay
    private func isActiveState(_ state: GameState) -> Bool {
        switch state {
        case .gameplay:
            return true
        default:
            return false
        }
    }

    // MARK: - State-Specific Logic

    private func initializeGame() {
        print("🎮 Initializing game systems...")
        // Initialize game systems here
        Task {
            try? await Task.sleep(for: .seconds(1))
            transition(to: .roomScanning)
        }
    }

    private func startRoomScanning() {
        print("📡 Starting room scan...")
        // Room scanning will be triggered in spatial components
    }

    private func startTutorial() {
        print("📚 Starting tutorial...")
        // Tutorial logic
    }

    private func handleGameplayState(_ state: GameplayState) {
        switch state {
        case .exploration:
            print("🗺️ Entering exploration mode")

        case .combat(let enemyCount):
            print("⚔️ Entering combat with \(enemyCount) enemies")

        case .dialogue(let npcID):
            print("💬 Starting dialogue with NPC: \(npcID)")

        case .inventory:
            print("🎒 Opening inventory")

        case .multiplayer(let sessionID):
            print("👥 Joining multiplayer session: \(sessionID)")

        case .questManagement:
            print("📜 Opening quest log")
        }
    }

    private func pauseGame() {
        print("⏸️ Game paused")
    }

    private func handleError(_ message: String) {
        print("❌ Error: \(message)")
    }

    // MARK: - Public Methods

    func startGame() {
        transition(to: .gameplay(.exploration))
    }

    func pauseGame(_ pause: Bool) {
        if pause {
            if case .gameplay = currentState {
                transition(to: .paused)
            }
        } else {
            if case .paused = currentState {
                // Return to last gameplay state
                if let lastGameplay = stateHistory.last(where: {
                    if case .gameplay = $0 { return true }
                    return false
                }), case .gameplay(let gameplayState) = lastGameplay {
                    transition(to: .gameplay(gameplayState))
                } else {
                    transition(to: .gameplay(.exploration))
                }
            }
        }
    }

    func enterCombat(enemyCount: Int) {
        transition(to: .gameplay(.combat(enemyCount: enemyCount)))
    }

    func exitCombat() {
        transition(to: .gameplay(.exploration))
    }

    func showInventory() {
        transition(to: .gameplay(.inventory))
    }

    func closeInventory() {
        transition(to: .gameplay(.exploration))
    }

    func reportError(_ error: GameError) {
        transition(to: .error(error.localizedDescription))
    }

    // MARK: - Event Subscriptions

    private func setupEventSubscriptions() {
        // Subscribe to room mapping completion
        EventBus.shared.subscribe(RoomMappingCompleteEvent.self) { [weak self] event in
            guard let self = self else { return }

            if event.roomLayout != nil {
                // Room mapping successful
                if case .roomScanning = self.currentState {
                    self.transition(to: .tutorial)
                }
            } else {
                // Room mapping failed
                self.reportError(.roomMappingFailed)
            }
        }

        // Subscribe to combat events
        EventBus.shared.subscribe(EntityDefeatedEvent.self) { [weak self] event in
            guard let self = self else { return }

            // Check if all enemies defeated
            if case .gameplay(.combat(let count)) = self.currentState {
                if count <= 1 {
                    self.exitCombat()
                } else {
                    self.transition(to: .gameplay(.combat(enemyCount: count - 1)))
                }
            }
        }
    }
}
