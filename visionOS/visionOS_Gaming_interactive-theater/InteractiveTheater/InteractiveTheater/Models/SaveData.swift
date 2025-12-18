import Foundation

/// Represents a saved performance progress
struct SaveData: Codable, Identifiable {
    let id: UUID
    let timestamp: Date
    let performanceID: UUID
    let performanceTitle: String

    // Progress
    let currentNodeID: UUID
    let completedNodes: [UUID]
    let choiceHistory: [PlayerChoice]
    let playthroughNumber: Int

    // Character states
    let characterStates: [UUID: CharacterSaveState]
    let relationshipStates: [RelationshipKey: RelationshipState]

    // Statistics
    let totalPlayTime: TimeInterval
    let decisionPoints: Int
    let explorationType: ExplorationType

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        performanceID: UUID,
        performanceTitle: String,
        currentNodeID: UUID,
        completedNodes: [UUID],
        choiceHistory: [PlayerChoice],
        playthroughNumber: Int,
        characterStates: [UUID: CharacterSaveState],
        relationshipStates: [RelationshipKey: RelationshipState],
        totalPlayTime: TimeInterval,
        decisionPoints: Int,
        explorationType: ExplorationType
    ) {
        self.id = id
        self.timestamp = timestamp
        self.performanceID = performanceID
        self.performanceTitle = performanceTitle
        self.currentNodeID = currentNodeID
        self.completedNodes = completedNodes
        self.choiceHistory = choiceHistory
        self.playthroughNumber = playthroughNumber
        self.characterStates = characterStates
        self.relationshipStates = relationshipStates
        self.totalPlayTime = totalPlayTime
        self.decisionPoints = decisionPoints
        self.explorationType = explorationType
    }
}

// MARK: - Supporting Types

struct PlayerChoice: Codable, Identifiable {
    let id: UUID
    let choiceID: UUID
    let selectedOptionID: UUID
    let timestamp: Date
    let choiceContext: String

    init(
        id: UUID = UUID(),
        choiceID: UUID,
        selectedOptionID: UUID,
        timestamp: Date = Date(),
        choiceContext: String
    ) {
        self.id = id
        self.choiceID = choiceID
        self.selectedOptionID = selectedOptionID
        self.timestamp = timestamp
        self.choiceContext = choiceContext
    }
}

struct CharacterSaveState: Codable {
    let characterID: UUID
    let emotionalState: EmotionalState
    let currentObjective: String?
    let playerRelationship: Relationship
    let conversationHistory: [ConversationRecord]
}

struct ConversationRecord: Codable, Identifiable {
    let id: UUID
    let timestamp: Date
    let characterID: UUID
    let playerInput: String
    let characterResponse: String
}

struct RelationshipKey: Codable, Hashable {
    let character1ID: UUID
    let character2ID: UUID

    init(_ id1: UUID, _ id2: UUID) {
        // Ensure consistent ordering for key
        if id1.uuidString < id2.uuidString {
            self.character1ID = id1
            self.character2ID = id2
        } else {
            self.character1ID = id2
            self.character2ID = id1
        }
    }
}

struct RelationshipState: Codable {
    let trust: Float
    let affection: Float
    let respect: Float
}

enum ExplorationType: String, Codable {
    case heroic        // Brave, selfless choices
    case pragmatic     // Practical, logical choices
    case empathetic    // Emotional, caring choices
    case ambitious     // Power-seeking, assertive choices
    case cautious      // Risk-averse, careful choices
    case chaotic       // Unpredictable, varied choices
}
