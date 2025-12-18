import Foundation
import Observation

/// Central game state - Observable for UI binding
@Observable
@MainActor
class GameState {
    // Game flow states
    enum PlayState {
        case notStarted
        case familyCreation
        case playing
        case paused
        case lifeEvent(LifeEventType)
    }

    // Current state
    var playState: PlayState = .notStarted
    var gameTime: GameTime = GameTime()

    // Current family
    var currentFamily: Family?

    // All characters in the game
    var allCharacters: [Character] = []

    // Generation tracking
    var generation: Int = 1

    // Event queue
    private var eventQueue: [GameEvent] = []

    init() {
        // Initialize with default values
    }

    /// Advance game time
    func advanceTime(by deltaTime: TimeInterval) {
        gameTime.advance(by: deltaTime)

        // Check for time-based events (birthdays, aging, etc.)
        checkTimeBasedEvents()
    }

    /// Process queued events
    func processEvents() {
        // Process all queued events
        for event in eventQueue {
            handleEvent(event)
        }
        eventQueue.removeAll()
    }

    /// Queue an event to be processed
    func queueEvent(_ event: GameEvent) {
        eventQueue.append(event)
    }

    private func handleEvent(_ event: GameEvent) {
        // TODO: Implement event handling
        switch event.eventType {
        case .characterAction:
            // Handle character actions
            break
        case .relationshipChange:
            // Handle relationship changes
            break
        case .needsCritical:
            // Handle critical needs
            break
        case .lifeStage:
            // Handle life stage transitions
            break
        case .career:
            // Handle career events
            break
        case .spatial:
            // Handle spatial events
            break
        }
    }

    private func checkTimeBasedEvents() {
        // Check if any characters have birthdays today
        let today = gameTime.gameDay

        for character in allCharacters {
            // Check birthday
            let birthdayDay = Calendar.current.component(.day, from: character.birthDate)
            let currentDay = Calendar.current.component(.day, from: gameTime.currentDate)

            if birthdayDay == currentDay {
                queueEvent(GameEvent(
                    timestamp: gameTime.currentDate,
                    eventID: UUID(),
                    eventType: .lifeStage(character.id, character.lifeStage)
                ))
            }
        }
    }

    /// Add a character to the game
    func addCharacter(_ character: Character) {
        allCharacters.append(character)
    }

    /// Remove a character from the game
    func removeCharacter(_ characterID: UUID) {
        allCharacters.removeAll { $0.id == characterID }
    }

    /// Get character by ID
    func character(withID id: UUID) -> Character? {
        allCharacters.first { $0.id == id }
    }
}

// Placeholder for LifeEventType (will implement with Events)
enum LifeEventType {
    case birthday
    case wedding
    case birth
    case death
    case promotion
    case fired
}
