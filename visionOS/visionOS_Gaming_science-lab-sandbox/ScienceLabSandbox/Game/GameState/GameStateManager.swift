//
//  GameStateManager.swift
//  Science Lab Sandbox
//
//  Manages game state transitions and lifecycle
//

import Foundation
import Combine

// MARK: - Game State

enum GameState: String, Codable {
    case initializing
    case mainMenu
    case laboratorySelection
    case experimentSetup
    case activeExperiment
    case experimentAnalysis
    case paused
    case settings
}

// MARK: - Game State Manager

@MainActor
class GameStateManager: ObservableObject {

    // MARK: - Published Properties

    @Published var currentState: GameState = .initializing
    @Published var previousState: GameState?

    // MARK: - Private Properties

    private var stateStack: [GameState] = []
    private var stateEntryTime: [GameState: Date] = [:]
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init() {
        setupObservers()
    }

    // MARK: - State Transitions

    func transition(to newState: GameState) {
        guard newState != currentState else { return }

        // Handle state exit
        handleStateExit(currentState)

        // Update state stack
        previousState = currentState
        stateStack.append(currentState)

        // Update current state
        currentState = newState
        stateEntryTime[newState] = Date()

        // Handle state enter
        handleStateEnter(newState)

        print("State transition: \(previousState?.rawValue ?? "nil") -> \(currentState.rawValue)")
    }

    func popState() {
        guard let previousState = stateStack.popLast() else {
            print("Warning: No previous state to pop")
            return
        }

        transition(to: previousState)
    }

    func resetToMainMenu() {
        stateStack.removeAll()
        transition(to: .mainMenu)
    }

    // MARK: - State Lifecycle

    private func handleStateEnter(_ state: GameState) {
        switch state {
        case .initializing:
            // Perform initialization tasks
            performInitialization()

        case .mainMenu:
            // Load main menu assets
            break

        case .laboratorySelection:
            // Load laboratory selection assets
            break

        case .experimentSetup:
            // Prepare experiment environment
            break

        case .activeExperiment:
            // Start experiment session
            break

        case .experimentAnalysis:
            // Prepare analysis tools
            break

        case .paused:
            // Pause active systems
            break

        case .settings:
            // Load settings
            break
        }
    }

    private func handleStateExit(_ state: GameState) {
        // Calculate time in state
        if let entryTime = stateEntryTime[state] {
            let duration = Date().timeIntervalSince(entryTime)
            print("Time in \(state.rawValue): \(duration)s")
        }

        switch state {
        case .activeExperiment:
            // Save experiment progress
            break

        case .paused:
            // Resume systems
            break

        default:
            break
        }
    }

    // MARK: - State Queries

    func canTransition(to newState: GameState) -> Bool {
        // Define valid state transitions
        switch (currentState, newState) {
        case (.initializing, .mainMenu):
            return true

        case (.mainMenu, .laboratorySelection),
             (.mainMenu, .settings):
            return true

        case (.laboratorySelection, .experimentSetup),
             (.laboratorySelection, .mainMenu):
            return true

        case (.experimentSetup, .activeExperiment),
             (.experimentSetup, .laboratorySelection):
            return true

        case (.activeExperiment, .paused),
             (.activeExperiment, .experimentAnalysis):
            return true

        case (.paused, .activeExperiment),
             (.paused, .mainMenu):
            return true

        case (.experimentAnalysis, .laboratorySelection),
             (.experimentAnalysis, .mainMenu):
            return true

        case (.settings, .mainMenu):
            return true

        default:
            return false
        }
    }

    func timeInCurrentState() -> TimeInterval {
        guard let entryTime = stateEntryTime[currentState] else {
            return 0
        }
        return Date().timeIntervalSince(entryTime)
    }

    // MARK: - Update Loop

    func update(deltaTime: TimeInterval) {
        // Update state-specific logic
        switch currentState {
        case .activeExperiment:
            // Experiment is running
            break

        default:
            break
        }
    }

    // MARK: - Initialization

    private func performInitialization() {
        // Simulate initialization tasks
        Task {
            // Load essential resources
            try? await Task.sleep(nanoseconds: 500_000_000)  // 0.5 seconds

            // Transition to main menu
            transition(to: .mainMenu)
        }
    }

    // MARK: - Observers

    private func setupObservers() {
        // Observe state changes for logging or analytics
        $currentState
            .sink { newState in
                print("📊 Game State: \(newState.rawValue)")
            }
            .store(in: &cancellables)
    }
}
