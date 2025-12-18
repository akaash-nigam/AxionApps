//
//  DataModels.swift
//  SpatialMeetingPlatform
//
//  Core data models for the application
//

import Foundation
import SwiftData
import simd

// MARK: - Meeting Domain

@Model
class Meeting {
    @Attribute(.unique) var id: UUID
    var title: String
    var meetingDescription: String?
    var scheduledStart: Date
    var scheduledEnd: Date
    var actualStart: Date?
    var actualEnd: Date?
    var status: MeetingStatus
    var meetingType: MeetingType

    // Relationships
    @Relationship(deleteRule: .cascade) var participants: [Participant]
    @Relationship(deleteRule: .cascade) var sharedContent: [SharedContent]
    var organizer: User

    // Metadata
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID,
        title: String,
        description: String? = nil,
        scheduledStart: Date,
        scheduledEnd: Date,
        status: MeetingStatus,
        meetingType: MeetingType,
        organizer: User,
        participants: [Participant] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.meetingDescription = description
        self.scheduledStart = scheduledStart
        self.scheduledEnd = scheduledEnd
        self.status = status
        self.meetingType = meetingType
        self.organizer = organizer
        self.participants = participants
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

enum MeetingStatus: String, Codable {
    case scheduled
    case inProgress
    case completed
    case cancelled
}

enum MeetingType: String, Codable, CaseIterable {
    case boardroom
    case innovationLab
    case auditorium
    case cafe
    case outdoor
    case custom

    var displayName: String {
        switch self {
        case .boardroom: return "Boardroom"
        case .innovationLab: return "Innovation Lab"
        case .auditorium: return "Auditorium"
        case .cafe: return "Cafe"
        case .outdoor: return "Outdoor"
        case .custom: return "Custom"
        }
    }

    var icon: String {
        switch self {
        case .boardroom: return "person.3.fill"
        case .innovationLab: return "lightbulb.fill"
        case .auditorium: return "theatermasks.fill"
        case .cafe: return "cup.and.saucer.fill"
        case .outdoor: return "tree.fill"
        case .custom: return "building.2.fill"
        }
    }
}

// MARK: - User Domain

@Model
class User {
    @Attribute(.unique) var id: UUID
    var email: String
    var displayName: String
    var avatarURL: String?
    var organization: String?
    var department: String?
    var role: String?

    // Preferences stored as JSON
    var preferencesData: Data?

    init(
        id: UUID,
        email: String,
        displayName: String,
        avatarURL: String? = nil,
        organization: String? = nil,
        department: String? = nil,
        role: String? = nil
    ) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.avatarURL = avatarURL
        self.organization = organization
        self.department = department
        self.role = role
    }

    var preferences: UserPreferences {
        get {
            guard let data = preferencesData,
                  let prefs = try? JSONDecoder().decode(UserPreferences.self, from: data) else {
                return UserPreferences()
            }
            return prefs
        }
        set {
            preferencesData = try? JSONEncoder().encode(newValue)
        }
    }
}

struct UserPreferences: Codable {
    var defaultEnvironment: MeetingType
    var spatialAudioEnabled: Bool
    var handTrackingEnabled: Bool
    var eyeTrackingEnabled: Bool
    var preferredPosition: SpatialPosition?
    var accessibilitySettings: AccessibilitySettings

    init(
        defaultEnvironment: MeetingType = .boardroom,
        spatialAudioEnabled: Bool = true,
        handTrackingEnabled: Bool = true,
        eyeTrackingEnabled: Bool = false,
        preferredPosition: SpatialPosition? = nil,
        accessibilitySettings: AccessibilitySettings = AccessibilitySettings()
    ) {
        self.defaultEnvironment = defaultEnvironment
        self.spatialAudioEnabled = spatialAudioEnabled
        self.handTrackingEnabled = handTrackingEnabled
        self.eyeTrackingEnabled = eyeTrackingEnabled
        self.preferredPosition = preferredPosition
        self.accessibilitySettings = accessibilitySettings
    }
}

struct AccessibilitySettings: Codable {
    var voiceOverEnabled: Bool
    var largeTextEnabled: Bool
    var reduceMotionEnabled: Bool
    var highContrastEnabled: Bool

    init(
        voiceOverEnabled: Bool = false,
        largeTextEnabled: Bool = false,
        reduceMotionEnabled: Bool = false,
        highContrastEnabled: Bool = false
    ) {
        self.voiceOverEnabled = voiceOverEnabled
        self.largeTextEnabled = largeTextEnabled
        self.reduceMotionEnabled = reduceMotionEnabled
        self.highContrastEnabled = highContrastEnabled
    }
}

// MARK: - Participant Domain

@Model
class Participant {
    @Attribute(.unique) var id: UUID
    var user: User
    var role: ParticipantRole
    var joinedAt: Date?
    var leftAt: Date?
    var audioEnabled: Bool
    var videoEnabled: Bool
    var presenceState: PresenceState

    // Spatial position stored as JSON
    var spatialPositionData: Data?

    // Engagement metrics
    var speakingTime: TimeInterval
    var engagementScore: Double
    var interactions: Int

    init(
        id: UUID,
        user: User,
        role: ParticipantRole,
        audioEnabled: Bool = true,
        videoEnabled: Bool = true,
        presenceState: PresenceState = .active
    ) {
        self.id = id
        self.user = user
        self.role = role
        self.audioEnabled = audioEnabled
        self.videoEnabled = videoEnabled
        self.presenceState = presenceState
        self.speakingTime = 0
        self.engagementScore = 0
        self.interactions = 0
    }

    var spatialPosition: SpatialPosition? {
        get {
            guard let data = spatialPositionData,
                  let pos = try? JSONDecoder().decode(SpatialPosition.self, from: data) else {
                return nil
            }
            return pos
        }
        set {
            spatialPositionData = try? JSONEncoder().encode(newValue)
        }
    }
}

enum ParticipantRole: String, Codable {
    case organizer
    case presenter
    case participant
    case observer
}

enum PresenceState: String, Codable {
    case active
    case idle
    case speaking
    case away
    case offline
}

struct SpatialPosition: Codable {
    var x: Float
    var y: Float
    var z: Float
    var rotation: CodableQuaternion
    var scale: Float

    init(x: Float, y: Float, z: Float, rotation: simd_quatf = simd_quatf(angle: 0, axis: SIMD3(0, 1, 0)), scale: Float = 1.0) {
        self.x = x
        self.y = y
        self.z = z
        self.rotation = CodableQuaternion(rotation)
        self.scale = scale
    }
}

struct CodableQuaternion: Codable {
    var x: Float
    var y: Float
    var z: Float
    var w: Float

    init(_ quat: simd_quatf) {
        self.x = quat.vector.x
        self.y = quat.vector.y
        self.z = quat.vector.z
        self.w = quat.vector.w
    }

    var simdQuaternion: simd_quatf {
        return simd_quatf(ix: x, iy: y, iz: z, r: w)
    }
}

// MARK: - Content Domain

@Model
class SharedContent {
    @Attribute(.unique) var id: UUID
    var type: ContentType
    var title: String
    var url: String
    var thumbnailURL: String?
    var sharedBy: User
    var sharedAt: Date

    // Spatial transform stored as JSON
    var spatialTransformData: Data?

    init(
        id: UUID,
        type: ContentType,
        title: String,
        url: String,
        thumbnailURL: String? = nil,
        sharedBy: User,
        sharedAt: Date = Date()
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.url = url
        self.thumbnailURL = thumbnailURL
        self.sharedBy = sharedBy
        self.sharedAt = sharedAt
    }

    var spatialTransform: SpatialTransform {
        get {
            guard let data = spatialTransformData,
                  let transform = try? JSONDecoder().decode(SpatialTransform.self, from: data) else {
                return SpatialTransform()
            }
            return transform
        }
        set {
            spatialTransformData = try? JSONEncoder().encode(newValue)
        }
    }
}

enum ContentType: String, Codable {
    case document
    case presentation
    case image
    case video
    case model3D
    case whiteboard
    case screenShare
}

struct SpatialTransform: Codable {
    var position: CodableVector3
    var rotation: CodableQuaternion
    var scale: CodableVector3

    init(
        position: SIMD3<Float> = SIMD3(0, 1.5, -2),
        rotation: simd_quatf = simd_quatf(angle: 0, axis: SIMD3(0, 1, 0)),
        scale: SIMD3<Float> = SIMD3(1, 1, 1)
    ) {
        self.position = CodableVector3(position)
        self.rotation = CodableQuaternion(rotation)
        self.scale = CodableVector3(scale)
    }
}

struct CodableVector3: Codable {
    var x: Float
    var y: Float
    var z: Float

    init(_ vector: SIMD3<Float>) {
        self.x = vector.x
        self.y = vector.y
        self.z = vector.z
    }

    var simdVector: SIMD3<Float> {
        return SIMD3(x, y, z)
    }
}

// MARK: - AI Domain

@Model
class Transcript {
    @Attribute(.unique) var id: UUID
    var meetingID: UUID
    var segmentsData: Data?
    var summary: String?
    var generatedAt: Date

    @Relationship(deleteRule: .cascade) var actionItems: [ActionItem]
    @Relationship(deleteRule: .cascade) var decisions: [Decision]

    init(id: UUID, meetingID: UUID, generatedAt: Date = Date()) {
        self.id = id
        self.meetingID = meetingID
        self.generatedAt = generatedAt
        self.actionItems = []
        self.decisions = []
    }

    var segments: [TranscriptSegment] {
        get {
            guard let data = segmentsData,
                  let segs = try? JSONDecoder().decode([TranscriptSegment].self, from: data) else {
                return []
            }
            return segs
        }
        set {
            segmentsData = try? JSONEncoder().encode(newValue)
        }
    }
}

struct TranscriptSegment: Codable, Identifiable {
    var id: UUID
    var speakerID: UUID
    var text: String
    var timestamp: TimeInterval
    var confidence: Double
    var language: String

    init(id: UUID = UUID(), speakerID: UUID, text: String, timestamp: TimeInterval, confidence: Double, language: String = "en") {
        self.id = id
        self.speakerID = speakerID
        self.text = text
        self.timestamp = timestamp
        self.confidence = confidence
        self.language = language
    }
}

@Model
class ActionItem {
    @Attribute(.unique) var id: UUID
    var itemDescription: String
    var assignedTo: User?
    var dueDate: Date?
    var status: ActionItemStatus
    var extractedAt: Date

    init(
        id: UUID,
        description: String,
        assignedTo: User? = nil,
        dueDate: Date? = nil,
        status: ActionItemStatus = .pending,
        extractedAt: Date = Date()
    ) {
        self.id = id
        self.itemDescription = description
        self.assignedTo = assignedTo
        self.dueDate = dueDate
        self.status = status
        self.extractedAt = extractedAt
    }
}

enum ActionItemStatus: String, Codable {
    case pending
    case inProgress
    case completed
    case cancelled
}

@Model
class Decision {
    @Attribute(.unique) var id: UUID
    var decisionDescription: String
    var context: String
    var timestamp: Date
    var confidence: Double

    init(id: UUID, description: String, context: String, timestamp: Date, confidence: Double) {
        self.id = id
        self.decisionDescription = description
        self.context = context
        self.timestamp = timestamp
        self.confidence = confidence
    }
}

// MARK: - Analytics Domain

@Model
class MeetingAnalytics {
    @Attribute(.unique) var id: UUID
    var meetingID: UUID
    var totalDuration: TimeInterval
    var participantCount: Int
    var engagementScore: Double
    var decisionCount: Int
    var actionItemCount: Int

    // Speaking distribution stored as JSON
    var speakingDistributionData: Data?

    // AI insights stored as JSON
    var aiInsightsData: Data?

    init(id: UUID, meetingID: UUID, totalDuration: TimeInterval, participantCount: Int, engagementScore: Double) {
        self.id = id
        self.meetingID = meetingID
        self.totalDuration = totalDuration
        self.participantCount = participantCount
        self.engagementScore = engagementScore
        self.decisionCount = 0
        self.actionItemCount = 0
    }

    var aiInsights: [AIInsight] {
        get {
            guard let data = aiInsightsData,
                  let insights = try? JSONDecoder().decode([AIInsight].self, from: data) else {
                return []
            }
            return insights
        }
        set {
            aiInsightsData = try? JSONEncoder().encode(newValue)
        }
    }
}

struct AIInsight: Codable, Identifiable {
    var id: UUID
    var type: InsightType
    var title: String
    var description: String
    var confidence: Double
    var timestamp: Date

    init(id: UUID = UUID(), type: InsightType, title: String, description: String, confidence: Double, timestamp: Date = Date()) {
        self.id = id
        self.type = type
        self.title = title
        self.description = description
        self.confidence = confidence
        self.timestamp = timestamp
    }
}

enum InsightType: String, Codable {
    case participationImbalance
    case meetingTooLong
    case lowEngagement
    case positiveEnergy
    case conflictDetected
    case consensusReached
}

// MARK: - Mock Data Helpers

extension Meeting {
    static func mockMeeting() -> Meeting {
        let user = User(
            id: UUID(),
            email: "john@example.com",
            displayName: "John Doe",
            organization: "Acme Corp"
        )

        return Meeting(
            id: UUID(),
            title: "Product Review",
            description: "Q4 product roadmap discussion",
            scheduledStart: Date().addingTimeInterval(3600),
            scheduledEnd: Date().addingTimeInterval(7200),
            status: .scheduled,
            meetingType: .boardroom,
            organizer: user
        )
    }

    static func mockMeetings() -> [Meeting] {
        return [
            mockMeeting(),
            Meeting(
                id: UUID(),
                title: "Design Critique",
                scheduledStart: Date().addingTimeInterval(10800),
                scheduledEnd: Date().addingTimeInterval(14400),
                status: .scheduled,
                meetingType: .innovationLab,
                organizer: User(id: UUID(), email: "jane@example.com", displayName: "Jane Smith")
            ),
            Meeting(
                id: UUID(),
                title: "All Hands",
                scheduledStart: Date().addingTimeInterval(18000),
                scheduledEnd: Date().addingTimeInterval(21600),
                status: .scheduled,
                meetingType: .auditorium,
                organizer: User(id: UUID(), email: "ceo@example.com", displayName: "CEO")
            )
        ]
    }
}
