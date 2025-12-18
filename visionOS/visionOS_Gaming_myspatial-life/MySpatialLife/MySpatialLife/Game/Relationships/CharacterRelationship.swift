import Foundation

/// Represents a relationship between two characters
struct CharacterRelationship: Codable, Identifiable {
    let id: UUID
    let characterA: UUID
    let characterB: UUID

    var relationshipType: RelationshipType
    var relationshipScore: Float  // -100 to 100
    var romanceLevel: Float       // 0.0 to 1.0
    var friendshipLevel: Float    // 0.0 to 1.0

    var sharedMemoryIDs: [UUID] = []

    var lastInteraction: Date
    var interactionCount: Int

    // Relationship-specific data
    var isMarried: Bool = false
    var marriageDate: Date?
    var isDating: Bool = false
    var datingStartDate: Date?

    init(
        id: UUID = UUID(),
        characterA: UUID,
        characterB: UUID,
        relationshipType: RelationshipType = .stranger,
        relationshipScore: Float = 0.0
    ) {
        self.id = id
        self.characterA = characterA
        self.characterB = characterB
        self.relationshipType = relationshipType
        self.relationshipScore = relationshipScore
        self.romanceLevel = 0.0
        self.friendshipLevel = 0.0
        self.lastInteraction = Date()
        self.interactionCount = 0
    }

    /// Update relationship score
    mutating func updateScore(by delta: Float) {
        relationshipScore = max(-100, min(100, relationshipScore + delta))
        updateRelationshipType()
    }

    /// Update friendship level
    mutating func updateFriendship(by delta: Float) {
        friendshipLevel = max(0.0, min(1.0, friendshipLevel + delta))
        updateRelationshipType()
    }

    /// Update romance level
    mutating func updateRomance(by delta: Float) {
        romanceLevel = max(0.0, min(1.0, romanceLevel + delta))
        updateRelationshipType()
    }

    /// Record an interaction
    mutating func recordInteraction() {
        lastInteraction = Date()
        interactionCount += 1
    }

    /// Apply decay for lack of interaction
    mutating func applyDecay(daysSinceLastInteraction: Int) {
        let decayAmount = Float(daysSinceLastInteraction) * 0.5

        // Don't decay below friendship threshold
        if relationshipScore > 20.0 {
            relationshipScore = max(20.0, relationshipScore - decayAmount)
        } else if relationshipScore > 0 {
            relationshipScore = max(0, relationshipScore - decayAmount)
        }

        updateRelationshipType()
    }

    /// Update relationship type based on scores
    private mutating func updateRelationshipType() {
        if isMarried {
            relationshipType = .spouse
        } else if romanceLevel > 0.85 {
            relationshipType = .soulmate
        } else if romanceLevel > 0.7 {
            relationshipType = .romantic
        } else if friendshipLevel > 0.7 || relationshipScore > 70 {
            relationshipType = .bestFriend
        } else if friendshipLevel > 0.5 || relationshipScore > 50 {
            relationshipType = .friend
        } else if friendshipLevel > 0.2 || relationshipScore > 20 {
            relationshipType = .acquaintance
        } else if relationshipScore < -50 {
            relationshipType = .enemy
        } else {
            relationshipType = .stranger
        }
    }

    /// Start dating
    mutating func startDating() {
        isDating = true
        datingStartDate = Date()
        updateRelationshipType()
    }

    /// Get married
    mutating func marry() {
        isMarried = true
        marriageDate = Date()
        isDating = false
        relationshipType = .spouse
    }

    /// Divorce
    mutating func divorce() {
        isMarried = false
        marriageDate = nil
        romanceLevel = max(0, romanceLevel - 0.5)
        relationshipScore -= 30
        updateRelationshipType()
    }
}

enum RelationshipType: String, Codable {
    case stranger
    case acquaintance
    case friend
    case bestFriend
    case romantic
    case soulmate
    case spouse
    case parent
    case child
    case sibling
    case enemy
}
