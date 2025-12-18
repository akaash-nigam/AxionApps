import Foundation
import SwiftData

// MARK: - Feedback Model
@Model
final class Feedback {
    // MARK: - Identity
    @Attribute(.unique) var id: UUID

    // MARK: - Recipient
    @Relationship(deleteRule: .nullify)
    var recipient: Employee?

    // MARK: - Source
    var givenBy: String // Name or ID
    var giverRole: FeedbackGiverRole

    // MARK: - Feedback Content
    var type: FeedbackType
    var category: FeedbackCategory
    var title: String
    var content: String

    // MARK: - Ratings
    var overallRating: Double? // 0-5 or 0-100
    var specificRatings: [String: Double] = [:] // Dimension: Rating

    // MARK: - Context
    var situationContext: String?
    var behaviorObserved: String?
    var impactDescription: String?
    var suggestedAction: String?

    // MARK: - Status
    var isAnonymous: Bool = false
    var isActionable: Bool = false
    var hasBeenAcknowledged: Bool = false
    var acknowledgedDate: Date?

    // MARK: - Metadata
    var relatedGoalId: UUID?
    var relatedProjectId: UUID?
    var tags: [String] = []

    // MARK: - Timestamps
    var createdAt: Date
    var updatedAt: Date

    // MARK: - Initialization
    init(
        id: UUID = UUID(),
        givenBy: String,
        giverRole: FeedbackGiverRole,
        type: FeedbackType,
        category: FeedbackCategory,
        title: String,
        content: String
    ) {
        self.id = id
        self.givenBy = givenBy
        self.giverRole = giverRole
        self.type = type
        self.category = category
        self.title = title
        self.content = content
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Computed Properties
    var isRecent: Bool {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        return createdAt > sevenDaysAgo
    }

    var needsAcknowledgment: Bool {
        !hasBeenAcknowledged && isActionable
    }

    var displayGiverName: String {
        isAnonymous ? "Anonymous" : givenBy
    }
}

// MARK: - Feedback Type
enum FeedbackType: String, Codable {
    case positive = "Positive"
    case constructive = "Constructive"
    case developmental = "Developmental"
    case recognition = "Recognition"
    case coaching = "Coaching"

    var icon: String {
        switch self {
        case .positive: return "hand.thumbsup.fill"
        case .constructive: return "lightbulb.fill"
        case .developmental: return "arrow.up.right"
        case .recognition: return "star.fill"
        case .coaching: return "person.fill.checkmark"
        }
    }

    var color: String {
        switch self {
        case .positive, .recognition: return "#30D158"
        case .constructive: return "#0A84FF"
        case .developmental: return "#FF9500"
        case .coaching: return "#5E5CE6"
        }
    }
}

// MARK: - Feedback Category
enum FeedbackCategory: String, Codable {
    case communication = "Communication"
    case leadership = "Leadership"
    case technical = "Technical Skills"
    case collaboration = "Collaboration"
    case problemSolving = "Problem Solving"
    case innovation = "Innovation"
    case execution = "Execution"
    case customerFocus = "Customer Focus"
    case growth = "Growth Mindset"
    case culture = "Culture Contribution"
    case other = "Other"
}

// MARK: - Feedback Giver Role
enum FeedbackGiverRole: String, Codable {
    case manager = "Manager"
    case peer = "Peer"
    case directReport = "Direct Report"
    case skipLevel = "Skip-Level Manager"
    case mentor = "Mentor"
    case customer = "Customer"
    case self = "Self"
    case other = "Other"
}
