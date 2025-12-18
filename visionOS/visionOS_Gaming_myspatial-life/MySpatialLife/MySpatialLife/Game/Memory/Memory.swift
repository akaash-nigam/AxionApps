import Foundation

/// Represents a memory that a character has
struct Memory: Codable, Identifiable {
    let id: UUID
    let characterID: UUID
    let memoryType: MemoryType
    var emotionalWeight: Float  // How important this memory is (0-1)
    let timestamp: Date

    var description: String
    var involvedCharacterIDs: [UUID]
    var location: SpatialLocation?

    var timesRecalled: Int = 0
    var lastRecalled: Date?

    init(
        id: UUID = UUID(),
        characterID: UUID,
        memoryType: MemoryType,
        emotionalWeight: Float,
        timestamp: Date = Date(),
        description: String,
        involvedCharacterIDs: [UUID] = [],
        location: SpatialLocation? = nil
    ) {
        self.id = id
        self.characterID = characterID
        self.memoryType = memoryType
        self.emotionalWeight = min(1.0, max(0.0, emotionalWeight))
        self.timestamp = timestamp
        self.description = description
        self.involvedCharacterIDs = involvedCharacterIDs
        self.location = location
    }

    /// Recall this memory (strengthens it)
    mutating func recall() {
        timesRecalled += 1
        lastRecalled = Date()
        // Recalling strengthens memory slightly
        emotionalWeight = min(1.0, emotionalWeight + 0.01)
    }

    /// Calculate current memory strength (decays over time unless recalled)
    func currentStrength(at currentDate: Date) -> Float {
        let daysSince = currentDate.timeIntervalSince(timestamp) / 86400
        let decayRate: Float = 0.001  // Very slow decay

        // Memories that are recalled frequently decay slower
        let recallBonus = min(0.3, Float(timesRecalled) * 0.02)

        let baseStrength = emotionalWeight - (Float(daysSince) * decayRate)
        return max(0, baseStrength + recallBonus)
    }

    /// Check if memory has faded (strength below threshold)
    func hasFaded(at currentDate: Date) -> Bool {
        currentStrength(at: currentDate) < 0.1
    }
}

enum MemoryType: Codable, Equatable {
    case firstMeeting(UUID)
    case romanticMoment(UUID)
    case argument(UUID)
    case achievement(String)
    case birthday(Int)  // Age
    case wedding(UUID)  // Spouse ID
    case birth(UUID)    // Child ID
    case death(UUID)    // Deceased ID
    case jobPromotion(String)  // Job title
    case jobFired(String)
    case movingIn
    case graduation
    case anniversary(UUID, Int)  // Spouse ID, years
}
