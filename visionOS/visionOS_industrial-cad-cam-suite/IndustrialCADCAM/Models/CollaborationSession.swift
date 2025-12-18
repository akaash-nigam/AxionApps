import Foundation
import SwiftData

@Model
final class CollaborationSession {
    @Attribute(.unique) var id: UUID
    var sessionName: String
    var projectID: UUID

    var startTime: Date
    var endTime: Date?

    @Relationship
    var participants: [User]

    var isActive: Bool

    // Session data
    var annotations: [SpatialAnnotation]
    var chatMessages: [ChatMessage]

    @Attribute(.externalStorage)
    var recordingData: Data?

    init(sessionName: String, projectID: UUID) {
        self.id = UUID()
        self.sessionName = sessionName
        self.projectID = projectID
        self.startTime = Date()
        self.participants = []
        self.isActive = true
        self.annotations = []
        self.chatMessages = []
    }

    // MARK: - Methods
    func addParticipant(_ user: User) {
        participants.append(user)
    }

    func endSession() {
        isActive = false
        endTime = Date()
    }

    var duration: TimeInterval {
        if let end = endTime {
            return end.timeIntervalSince(startTime)
        }
        return Date().timeIntervalSince(startTime)
    }
}

// MARK: - Supporting Types
struct SpatialAnnotation: Codable {
    var id: UUID = UUID()
    var authorID: UUID
    var authorName: String
    var timestamp: Date
    var position: Position3D
    var content: String
    var attachedToPartID: UUID?
}

struct ChatMessage: Codable {
    var id: UUID = UUID()
    var senderID: UUID
    var senderName: String
    var timestamp: Date
    var message: String
}
