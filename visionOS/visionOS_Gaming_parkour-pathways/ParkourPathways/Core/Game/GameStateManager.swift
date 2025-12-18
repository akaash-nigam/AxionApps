//
//  GameStateManager.swift
//  Parkour Pathways
//
//  Manages game state and state transitions
//

import Foundation
import Combine

@MainActor
class GameStateManager: ObservableObject {
    // Published state
    @Published var currentState: GameState = .initializing
    @Published var playerData: PlayerData?
    @Published var courseData: CourseData?
    @Published var sessionMetrics: SessionMetrics?

    // State history
    private var stateHistory: [GameState] = []

    // State machine
    private var stateMachine: StateMachine<GameState>

    init() {
        self.stateMachine = StateMachine(initialState: .initializing)
        setupStateMachine()
    }

    private func setupStateMachine() {
        // Define valid state transitions
        stateMachine.addTransition(from: .initializing, to: .roomScanning)
        stateMachine.addTransition(from: .roomScanning, to: .mainMenu)
        stateMachine.addTransition(from: .mainMenu, to: .courseSetup)
        stateMachine.addTransition(from: .mainMenu, to: .trainingMode)
        stateMachine.addTransition(from: .courseSetup, to: .courseActive)
        stateMachine.addTransition(from: .courseActive, to: .coursePaused)
        stateMachine.addTransition(from: .coursePaused, to: .courseActive)
        stateMachine.addTransition(from: .coursePaused, to: .mainMenu)
        stateMachine.addTransition(from: .courseActive, to: .courseCompleted)
        stateMachine.addTransition(from: .courseCompleted, to: .mainMenu)
        stateMachine.addTransition(from: .courseCompleted, to: .courseSetup)
    }

    // MARK: - State Transitions

    func transition(to newState: GameState) async throws {
        // Validate transition
        guard stateMachine.canTransition(to: newState) else {
            throw GameStateError.invalidTransition(from: currentState, to: newState)
        }

        // Execute exit actions
        await executeStateExit(currentState)

        // Update state
        let previousState = currentState
        currentState = newState
        stateHistory.append(previousState)

        // Execute entry actions
        await executeStateEntry(newState)

        // Notify observers
        NotificationCenter.default.post(
            name: .gameStateChanged,
            object: GameStateTransition(from: previousState, to: newState)
        )
    }

    // MARK: - State Actions

    private func executeStateExit(_ state: GameState) async {
        switch state {
        case .courseActive:
            // Pause timers, save progress
            sessionMetrics?.endTime = Date()
        case .coursePaused:
            break
        default:
            break
        }
    }

    private func executeStateEntry(_ state: GameState) async {
        switch state {
        case .roomScanning:
            // Start room scanning
            break
        case .courseActive:
            // Start course timer
            startSession()
        case .courseCompleted:
            // Calculate final scores
            calculateFinalScore()
        default:
            break
        }
    }

    // MARK: - Session Management

    private func startSession() {
        guard let course = courseData else { return }
        sessionMetrics = SessionMetrics(
            startTime: Date(),
            courseId: course.id
        )
    }

    private func calculateFinalScore() {
        guard var metrics = sessionMetrics else { return }

        // Calculate completion time
        if let startTime = metrics.startTime {
            metrics.completionTime = Date().timeIntervalSince(startTime)
        }

        // Calculate score from technique and speed
        let techniqueScore = calculateAverageTechniqueScore()
        let speedBonus = calculateSpeedBonus()
        metrics.score = techniqueScore + speedBonus

        sessionMetrics = metrics
    }

    private func calculateAverageTechniqueScore() -> Float {
        guard let metrics = sessionMetrics else { return 0 }
        let scores = metrics.techniqueScores.values
        return scores.isEmpty ? 0 : scores.reduce(0, +) / Float(scores.count)
    }

    private func calculateSpeedBonus() -> Float {
        guard let metrics = sessionMetrics,
              let completionTime = metrics.completionTime,
              let course = courseData else { return 0 }

        // Bonus for completing faster than estimated duration
        let timeRatio = Float(completionTime / course.estimatedDuration)
        if timeRatio < 0.8 {
            return 1000 * (0.8 - timeRatio)
        }
        return 0
    }

    // MARK: - Helper Methods

    func canTransition(to state: GameState) -> Bool {
        stateMachine.canTransition(to: state)
    }

    func resetState() async {
        currentState = .mainMenu
        sessionMetrics = nil
        stateHistory.removeAll()
    }
}

// MARK: - Game State Enum

enum GameState: String, Codable {
    case initializing
    case roomScanning
    case calibrating
    case mainMenu
    case courseSetup
    case courseActive
    case coursePaused
    case courseCompleted
    case trainingMode
    case competitionMode
    case multiplayerSync
}

// MARK: - State Machine

class StateMachine<State: Hashable> {
    private var currentState: State
    private var transitions: [State: Set<State>] = [:]

    init(initialState: State) {
        self.currentState = initialState
    }

    func addTransition(from: State, to: State) {
        if transitions[from] == nil {
            transitions[from] = Set()
        }
        transitions[from]?.insert(to)
    }

    func canTransition(to newState: State) -> Bool {
        transitions[currentState]?.contains(newState) ?? false
    }
}

// MARK: - Errors

enum GameStateError: Error {
    case invalidTransition(from: GameState, to: GameState)
}

// MARK: - Notifications

extension Notification.Name {
    static let gameStateChanged = Notification.Name("gameStateChanged")
}

struct GameStateTransition {
    let from: GameState
    let to: GameState
}
