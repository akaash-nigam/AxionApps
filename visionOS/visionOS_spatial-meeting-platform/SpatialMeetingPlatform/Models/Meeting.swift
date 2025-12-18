import Foundation
import SwiftData

@Model
class Meeting {
    @Attribute(.unique) var id: UUID
    var title: String
    var description: String?
    var startTime: Date
    var endTime: Date
    var organizerId: UUID

    @Relationship(deleteRule: .cascade) var participants: [Participant]
    @Relationship(deleteRule: .cascade) var agendaItems: [AgendaItem]
    @Relationship(deleteRule: .cascade) var recordings: [Recording]?
    @Relationship(deleteRule: .nullify) var environment: MeetingEnvironment?

    var status: MeetingStatus
    var recurrenceRule: RecurrenceRule?
    var privacyLevel: PrivacyLevel
    var maxParticipants: Int

    // Spatial properties
    var roomConfiguration: RoomConfiguration
    var spatialLayout: SpatialLayout

    // Integration
    var calendarEventId: String?
    var externalMeetingLinks: [ExternalLink]?

    // Analytics
    var analytics: MeetingAnalytics?

    init(
        title: String,
        startTime: Date,
        endTime: Date,
        organizerId: UUID,
        description: String? = nil,
        privacyLevel: PrivacyLevel = .standard,
        maxParticipants: Int = 50,
        roomConfiguration: RoomConfiguration = .boardroom,
        spatialLayout: SpatialLayout = .circle
    ) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.startTime = startTime
        self.endTime = endTime
        self.organizerId = organizerId
        self.participants = []
        self.agendaItems = []
        self.status = .scheduled
        self.privacyLevel = privacyLevel
        self.maxParticipants = maxParticipants
        self.roomConfiguration = roomConfiguration
        self.spatialLayout = spatialLayout
    }

    // Computed properties
    var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }

    var isActive: Bool {
        status == .live
    }

    var participantCount: Int {
        participants.count
    }
}

enum MeetingStatus: String, Codable {
    case scheduled
    case live
    case ended
    case cancelled
}

enum PrivacyLevel: String, Codable {
    case `public`
    case standard
    case confidential
    case restricted
}

enum RoomConfiguration: String, Codable {
    case boardroom
    case openSpace
    case auditorium
    case cafe
    case outdoor
    case custom
}

enum SpatialLayout: String, Codable {
    case circle
    case theater
    case classroom
    case uShape
    case custom
}

struct RecurrenceRule: Codable {
    var frequency: RecurrenceFrequency
    var interval: Int
    var endDate: Date?
    var count: Int?
}

enum RecurrenceFrequency: String, Codable {
    case daily
    case weekly
    case monthly
    case yearly
}

struct ExternalLink: Codable, Identifiable {
    var id: UUID = UUID()
    var platform: String
    var url: URL
}
