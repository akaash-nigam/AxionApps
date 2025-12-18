import Foundation
import SwiftData

@Model
class User {
    @Attribute(.unique) var id: UUID
    var email: String
    var displayName: String
    var organizationId: UUID?

    // Profile
    var avatarAssetId: String?
    var title: String?
    var department: String?
    var timezone: TimeZone

    // Preferences
    var preferences: UserPreferences
    var defaultAvatarConfig: AvatarConfiguration

    // Security
    var authProvider: AuthProvider
    var lastLoginAt: Date?
    var accountStatus: AccountStatus

    // Meetings
    @Relationship(deleteRule: .nullify) var organizedMeetings: [Meeting]
    @Relationship(deleteRule: .nullify) var participations: [Participant]

    init(
        email: String,
        displayName: String,
        organizationId: UUID? = nil
    ) {
        self.id = UUID()
        self.email = email
        self.displayName = displayName
        self.organizationId = organizationId
        self.timezone = .current
        self.preferences = .default
        self.defaultAvatarConfig = .default
        self.authProvider = .email
        self.accountStatus = .active
        self.organizedMeetings = []
        self.participations = []
    }
}

struct UserPreferences: Codable {
    var defaultEnvironment: UUID?
    var audioQuality: AudioQuality
    var spatialAudioEnabled: Bool
    var hapticFeedbackEnabled: Bool
    var handTrackingEnabled: Bool
    var eyeTrackingEnabled: Bool
    var defaultMeetingPrivacy: PrivacyLevel
    var autoJoinAudio: Bool
    var notificationSettings: NotificationSettings

    static var `default`: UserPreferences {
        UserPreferences(
            defaultEnvironment: nil,
            audioQuality: .high,
            spatialAudioEnabled: true,
            hapticFeedbackEnabled: true,
            handTrackingEnabled: true,
            eyeTrackingEnabled: false,
            defaultMeetingPrivacy: .standard,
            autoJoinAudio: true,
            notificationSettings: .default
        )
    }
}

enum AudioQuality: String, Codable {
    case low
    case medium
    case high
    case ultrahigh

    var sampleRate: Double {
        switch self {
        case .low: return 16000
        case .medium: return 32000
        case .high, .ultrahigh: return 48000
        }
    }

    var bitrate: Int {
        switch self {
        case .low: return 24_000
        case .medium: return 48_000
        case .high: return 96_000
        case .ultrahigh: return 128_000
        }
    }
}

struct NotificationSettings: Codable {
    var meetingReminders: Bool
    var participantJoined: Bool
    var handRaised: Bool
    var sharedContent: Bool

    static var `default`: NotificationSettings {
        NotificationSettings(
            meetingReminders: true,
            participantJoined: true,
            handRaised: true,
            sharedContent: true
        )
    }
}

enum AuthProvider: String, Codable {
    case email
    case google
    case microsoft
    case apple
    case saml
    case custom
}

enum AccountStatus: String, Codable {
    case active
    case suspended
    case deleted
    case pending
}
