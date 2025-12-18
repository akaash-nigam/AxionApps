import Foundation
import SwiftData
import simd

@Model
class Participant {
    @Attribute(.unique) var id: UUID
    var userId: UUID
    var displayName: String
    var email: String
    var avatarAsset: String?

    var role: ParticipantRole
    var status: ParticipantStatus
    var joinedAt: Date?
    var leftAt: Date?

    // Spatial positioning
    var spatialPosition: SpatialPosition?
    var avatarConfiguration: AvatarConfiguration

    // Communication
    var audioEnabled: Bool
    var handRaised: Bool
    var speakingTime: TimeInterval

    // Permissions
    var canShare: Bool
    var canRecord: Bool
    var canInvite: Bool

    // Analytics
    var engagementScore: Double?
    var interactionCount: Int

    init(
        userId: UUID,
        displayName: String,
        email: String,
        role: ParticipantRole = .attendee,
        avatarConfiguration: AvatarConfiguration = .default
    ) {
        self.id = UUID()
        self.userId = userId
        self.displayName = displayName
        self.email = email
        self.role = role
        self.status = .invited
        self.audioEnabled = true
        self.handRaised = false
        self.speakingTime = 0
        self.canShare = true
        self.canRecord = false
        self.canInvite = false
        self.interactionCount = 0
        self.avatarConfiguration = avatarConfiguration
    }

    // Computed properties
    var isActive: Bool {
        status == .joined
    }

    var isSpeaking: Bool {
        audioEnabled && (engagementScore ?? 0) > 0.5
    }
}

enum ParticipantRole: String, Codable {
    case host
    case coHost
    case presenter
    case attendee
    case observer
}

enum ParticipantStatus: String, Codable {
    case invited
    case accepted
    case declined
    case tentative
    case joined
    case left
}

struct SpatialPosition: Codable {
    var x: Float
    var y: Float
    var z: Float
    var rotation: simd_quatf

    init(x: Float = 0, y: Float = 0, z: Float = 0, rotation: simd_quatf = simd_quatf(angle: 0, axis: [0, 1, 0])) {
        self.x = x
        self.y = y
        self.z = z
        self.rotation = rotation
    }

    var simd3: SIMD3<Float> {
        SIMD3(x, y, z)
    }
}

struct AvatarConfiguration: Codable {
    var style: AvatarStyle
    var color: String
    var accessories: [String]

    static var `default`: AvatarConfiguration {
        AvatarConfiguration(style: .minimal, color: "#007AFF", accessories: [])
    }
}

enum AvatarStyle: String, Codable {
    case realistic
    case stylized
    case minimal
    case custom
}
