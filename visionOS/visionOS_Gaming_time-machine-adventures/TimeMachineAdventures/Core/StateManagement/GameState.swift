import Foundation
import RealityKit

// MARK: - Game State
enum GameState: Equatable {
    case loading
    case mainMenu
    case roomCalibration
    case tutorial
    case exploring(era: HistoricalEra)
    case examiningArtifact(artifact: Artifact)
    case conversing(character: HistoricalCharacter)
    case solvingMystery(mystery: Mystery)
    case assessment
    case paused

    var isPlaying: Bool {
        switch self {
        case .exploring, .examiningArtifact, .conversing, .solvingMystery:
            return true
        default:
            return false
        }
    }

    var allowsInteraction: Bool {
        switch self {
        case .loading, .paused:
            return false
        default:
            return true
        }
    }

    static func == (lhs: GameState, rhs: GameState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading),
             (.mainMenu, .mainMenu),
             (.roomCalibration, .roomCalibration),
             (.tutorial, .tutorial),
             (.assessment, .assessment),
             (.paused, .paused):
            return true
        case (.exploring(let era1), .exploring(let era2)):
            return era1.id == era2.id
        case (.examiningArtifact(let artifact1), .examiningArtifact(let artifact2)):
            return artifact1.id == artifact2.id
        case (.conversing(let char1), .conversing(let char2)):
            return char1.id == char2.id
        case (.solvingMystery(let mystery1), .solvingMystery(let mystery2)):
            return mystery1.id == mystery2.id
        default:
            return false
        }
    }
}

// MARK: - Game State Manager
@MainActor
class GameStateManager: ObservableObject {
    @Published var currentState: GameState = .loading
    @Published var previousState: GameState?

    private var stateHistory: [GameState] = []
    private(set) var eventBus: EventBus

    init() {
        self.eventBus = EventBus()
    }

    func transition(to newState: GameState) {
        guard newState != currentState else { return }

        // Store previous state
        previousState = currentState
        stateHistory.append(currentState)

        // Keep history limited
        if stateHistory.count > 10 {
            stateHistory.removeFirst()
        }

        // Transition
        currentState = newState

        // Publish event
        eventBus.publish(.stateChanged(from: previousState, to: newState))

        print("State transition: \(String(describing: previousState)) → \(String(describing: newState))")
    }

    func goBack() {
        if let previous = previousState {
            transition(to: previous)
        }
    }

    func canGoBack() -> Bool {
        return previousState != nil
    }
}

// MARK: - Event Bus
actor EventBus {
    private var subscribers: [GameEventType: [UUID: (GameEvent) -> Void]] = [:]

    func publish(_ event: GameEvent) {
        Task { @MainActor in
            if let handlers = await getSubscribers(for: event.type) {
                for handler in handlers.values {
                    handler(event)
                }
            }
        }
    }

    func subscribe(for eventType: GameEventType, id: UUID = UUID(), handler: @escaping (GameEvent) -> Void) -> UUID {
        subscribers[eventType, default: [:]][id] = handler
        return id
    }

    func unsubscribe(id: UUID, from eventType: GameEventType) {
        subscribers[eventType]?.removeValue(forKey: id)
    }

    private func getSubscribers(for eventType: GameEventType) -> [UUID: (GameEvent) -> Void]? {
        return subscribers[eventType]
    }
}

// MARK: - Game Events
enum GameEventType {
    case stateChanged
    case artifactDiscovered
    case artifactExamined
    case characterMet
    case conversationStarted
    case conversationEnded
    case mysteryStarted
    case clueFound
    case mysteryCompleted
    case experienceGained
    case levelUp
    case achievementUnlocked
    case errorOccurred
}

enum GameEvent {
    case stateChanged(from: GameState?, to: GameState)
    case artifactDiscovered(artifact: Artifact)
    case artifactExamined(artifact: Artifact)
    case characterMet(character: HistoricalCharacter)
    case conversationStarted(character: HistoricalCharacter)
    case conversationEnded(character: HistoricalCharacter)
    case mysteryStarted(mystery: Mystery)
    case clueFound(clue: Clue, mystery: Mystery)
    case mysteryCompleted(mystery: Mystery, score: Double)
    case experienceGained(amount: Int, activity: Activity)
    case levelUp(newLevel: Int)
    case achievementUnlocked(achievement: Achievement)
    case errorOccurred(error: Error)

    var type: GameEventType {
        switch self {
        case .stateChanged: return .stateChanged
        case .artifactDiscovered: return .artifactDiscovered
        case .artifactExamined: return .artifactExamined
        case .characterMet: return .characterMet
        case .conversationStarted: return .conversationStarted
        case .conversationEnded: return .conversationEnded
        case .mysteryStarted: return .mysteryStarted
        case .clueFound: return .clueFound
        case .mysteryCompleted: return .mysteryCompleted
        case .experienceGained: return .experienceGained
        case .levelUp: return .levelUp
        case .achievementUnlocked: return .achievementUnlocked
        case .errorOccurred: return .errorOccurred
        }
    }
}

// MARK: - Activity Types
enum Activity {
    case artifactDiscovery
    case artifactExamination
    case characterConversation
    case mysteryCompletion
    case clueDiscovery
    case learningMilestone
}
