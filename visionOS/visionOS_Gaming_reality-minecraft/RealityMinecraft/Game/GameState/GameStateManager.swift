//
//  GameStateManager.swift
//  Reality Minecraft
//
//  Manages overall game state and transitions
//

import Foundation
import Combine

/// Game state enumeration
enum GameState: Equatable {
    case mainMenu
    case worldSelection
    case loading(progress: Float)
    case playing(mode: GameMode)
    case paused
    case settings
    case multiplayer(session: String) // Session ID
    case exiting

    static func == (lhs: GameState, rhs: GameState) -> Bool {
        switch (lhs, rhs) {
        case (.mainMenu, .mainMenu),
             (.worldSelection, .worldSelection),
             (.paused, .paused),
             (.settings, .settings),
             (.exiting, .exiting):
            return true
        case (.loading(let p1), .loading(let p2)):
            return p1 == p2
        case (.playing(let m1), .playing(let m2)):
            return m1 == m2
        case (.multiplayer(let s1), .multiplayer(let s2)):
            return s1 == s2
        default:
            return false
        }
    }
}

/// Game mode enumeration
enum GameMode: Codable, Equatable {
    case creative
    case survival(difficulty: Difficulty)
    case adventure
    case spectator

    enum Difficulty: String, Codable {
        case peaceful
        case easy
        case normal
        case hard
    }
}

/// Main game state manager
@MainActor
class GameStateManager: ObservableObject {
    @Published private(set) var currentState: GameState = .mainMenu
    @Published private(set) var gameMode: GameMode = .creative
    @Published private(set) var isPaused: Bool = false

    private var stateStack: [GameState] = []
    private var cancellables = Set<AnyCancellable>()

    // Event bus for game events
    let eventBus = EventBus()

    init() {
        setupStateObservers()
    }

    // MARK: - State Transitions

    /// Transition to a new game state
    func transitionTo(_ newState: GameState) {
        let oldState = currentState
        currentState = newState

        handleStateTransition(from: oldState, to: newState)
        publishStateChange(from: oldState, to: newState)
    }

    /// Push current state and transition to new state
    func pushState(_ state: GameState) {
        stateStack.append(currentState)
        transitionTo(state)
    }

    /// Pop state stack and return to previous state
    func popState() {
        guard let previousState = stateStack.popLast() else { return }
        transitionTo(previousState)
    }

    // MARK: - Game Mode Management

    /// Set game mode
    func setGameMode(_ mode: GameMode) {
        gameMode = mode
        eventBus.publish(GameModeChangedEvent(newMode: mode))
    }

    /// Toggle pause state
    func togglePause() {
        if case .playing = currentState {
            if isPaused {
                resume()
            } else {
                pause()
            }
        }
    }

    /// Pause the game
    func pause() {
        guard case .playing = currentState else { return }
        isPaused = true
        pushState(.paused)
    }

    /// Resume the game
    func resume() {
        guard isPaused else { return }
        isPaused = false
        popState()
    }

    // MARK: - Private Methods

    private func setupStateObservers() {
        // Observe state changes for logging/analytics
        $currentState
            .sink { state in
                print("📊 Game State Changed: \(state)")
            }
            .store(in: &cancellables)
    }

    private func handleStateTransition(from oldState: GameState, to newState: GameState) {
        // Exit old state
        switch oldState {
        case .playing:
            handleExitPlaying()
        case .multiplayer:
            handleExitMultiplayer()
        default:
            break
        }

        // Enter new state
        switch newState {
        case .loading(let progress):
            handleEnterLoading(progress: progress)
        case .playing(let mode):
            handleEnterPlaying(mode: mode)
        case .multiplayer:
            handleEnterMultiplayer()
        default:
            break
        }
    }

    private func handleEnterLoading(progress: Float) {
        print("🔄 Loading... \(Int(progress * 100))%")
    }

    private func handleEnterPlaying(mode: GameMode) {
        self.gameMode = mode
        isPaused = false
        print("🎮 Entering play mode: \(mode)")
    }

    private func handleExitPlaying() {
        print("⏸ Exiting play mode")
    }

    private func handleEnterMultiplayer() {
        print("🌐 Entering multiplayer mode")
    }

    private func handleExitMultiplayer() {
        print("🌐 Exiting multiplayer mode")
    }

    private func publishStateChange(from oldState: GameState, to newState: GameState) {
        eventBus.publish(GameStateChangedEvent(
            oldState: oldState,
            newState: newState
        ))
    }
}

// MARK: - Game Events

/// Base protocol for all game events
protocol GameEvent {
    var timestamp: Date { get }
    var eventType: String { get }
}

/// Game state changed event
struct GameStateChangedEvent: GameEvent {
    let timestamp: Date = Date()
    let eventType: String = "GameStateChanged"
    let oldState: GameState
    let newState: GameState
}

/// Game mode changed event
struct GameModeChangedEvent: GameEvent {
    let timestamp: Date = Date()
    let eventType: String = "GameModeChanged"
    let newMode: GameMode
}

/// Event bus for game-wide event distribution
class EventBus {
    typealias EventHandler = (GameEvent) -> Void

    private var handlers: [String: [EventHandler]] = [:]
    private let queue = DispatchQueue(label: "com.realityminecraft.eventbus")

    /// Subscribe to a specific event type
    func subscribe<T: GameEvent>(to eventType: T.Type, handler: @escaping (T) -> Void) {
        let key = String(describing: eventType)
        let wrappedHandler: EventHandler = { event in
            if let typedEvent = event as? T {
                handler(typedEvent)
            }
        }

        queue.async { [weak self] in
            self?.handlers[key, default: []].append(wrappedHandler)
        }
    }

    /// Publish an event to all subscribers
    func publish(_ event: GameEvent) {
        let key = event.eventType

        queue.async { [weak self] in
            guard let handlers = self?.handlers[key] else { return }

            DispatchQueue.main.async {
                handlers.forEach { $0(event) }
            }
        }
    }

    /// Clear all event handlers
    func clearAll() {
        queue.async { [weak self] in
            self?.handlers.removeAll()
        }
    }
}
