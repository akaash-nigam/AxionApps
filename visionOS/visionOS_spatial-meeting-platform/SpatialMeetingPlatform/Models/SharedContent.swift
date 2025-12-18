import Foundation
import SwiftData
import simd

@Model
class SharedContent {
    @Attribute(.unique) var id: UUID
    var meetingId: UUID
    var creatorId: UUID
    var type: ContentType
    var title: String

    // Content data
    var data: Data?
    var url: URL?
    var thumbnailData: Data?

    // Spatial properties
    var position: SpatialPosition
    var scale: Float
    var orientation: simd_quatf

    // Interaction
    var isLocked: Bool
    var permissions: ContentPermissions
    var collaborators: [UUID]

    // Versioning
    var version: Int
    var createdAt: Date
    var modifiedAt: Date
    var modifiedBy: UUID

    // Annotations
    @Relationship(deleteRule: .cascade) var annotations: [Annotation]

    init(
        meetingId: UUID,
        creatorId: UUID,
        type: ContentType,
        title: String,
        url: URL? = nil
    ) {
        self.id = UUID()
        self.meetingId = meetingId
        self.creatorId = creatorId
        self.type = type
        self.title = title
        self.url = url
        self.position = SpatialPosition(x: 0, y: 1.5, z: -2)
        self.scale = 1.0
        self.orientation = simd_quatf(angle: 0, axis: [0, 1, 0])
        self.isLocked = false
        self.permissions = ContentPermissions(viewOnly: false, collaborative: true, restrictedEdit: [])
        self.collaborators = []
        self.version = 1
        self.createdAt = Date()
        self.modifiedAt = Date()
        self.modifiedBy = creatorId
        self.annotations = []
    }
}

enum ContentType: String, Codable {
    case document
    case presentation
    case whiteboard
    case model3D
    case dataVisualization
    case video
    case screen
    case webpage
}

struct ContentPermissions: Codable {
    var viewOnly: Bool
    var collaborative: Bool
    var restrictedEdit: [UUID]
}

@Model
class Annotation {
    @Attribute(.unique) var id: UUID
    var contentId: UUID
    var authorId: UUID
    var text: String
    var position: SpatialPosition
    var timestamp: Date
    var color: String

    init(contentId: UUID, authorId: UUID, text: String, position: SpatialPosition) {
        self.id = UUID()
        self.contentId = contentId
        self.authorId = authorId
        self.text = text
        self.position = position
        self.timestamp = Date()
        self.color = "#007AFF"
    }
}

@Model
class AgendaItem {
    @Attribute(.unique) var id: UUID
    var title: String
    var description: String?
    var duration: TimeInterval
    var order: Int
    var isCompleted: Bool

    init(title: String, duration: TimeInterval, order: Int) {
        self.id = UUID()
        self.title = title
        self.duration = duration
        self.order = order
        self.isCompleted = false
    }
}

@Model
class Recording {
    @Attribute(.unique) var id: UUID
    var meetingId: UUID
    var startTime: Date
    var endTime: Date?
    var fileURL: URL?
    var fileSize: Int64
    var format: RecordingFormat

    init(meetingId: UUID) {
        self.id = UUID()
        self.meetingId = meetingId
        self.startTime = Date()
        self.fileSize = 0
        self.format = .mp4
    }
}

enum RecordingFormat: String, Codable {
    case mp4
    case mov
    case webm
}
