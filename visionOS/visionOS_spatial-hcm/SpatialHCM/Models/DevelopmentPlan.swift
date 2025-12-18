import Foundation
import SwiftData

// MARK: - Development Plan Model
@Model
final class DevelopmentPlan {
    // MARK: - Identity
    @Attribute(.unique) var id: UUID
    var title: String
    var description: String

    // MARK: - Employee Reference
    @Relationship(deleteRule: .nullify, inverse: \PerformanceData.developmentPlan)
    var performanceData: PerformanceData?

    // MARK: - Career Goals
    var currentRole: String
    var targetRole: String?
    var careerPath: CareerPath = .specialist
    var targetTimeframe: TimeInterval // In months

    // MARK: - Development Areas
    var developmentAreas: [DevelopmentArea] = []
    var strengthsToLeverage: [String] = []
    var areasForImprovement: [String] = []

    // MARK: - Actions
    var learningActivities: [LearningActivity] = []
    var mentorshipGoals: [String] = []
    var stretchAssignments: [String] = []

    // MARK: - Progress
    var overallProgress: Double = 0.0 // 0-100
    var status: DevelopmentPlanStatus = .active

    // MARK: - Review
    var lastReviewDate: Date?
    var nextReviewDate: Date?
    var reviewNotes: String?

    // MARK: - Timestamps
    var createdAt: Date
    var updatedAt: Date

    // MARK: - Initialization
    init(
        id: UUID = UUID(),
        title: String,
        currentRole: String,
        targetTimeframe: TimeInterval = 12.0 // 12 months default
    ) {
        self.id = id
        self.title = title
        self.description = ""
        self.currentRole = currentRole
        self.targetTimeframe = targetTimeframe
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Computed Properties
    var isActive: Bool {
        status == .active
    }

    var isOverdue: Bool {
        guard let nextReview = nextReviewDate else { return false }
        return Date() > nextReview
    }

    var completedActivities: Int {
        learningActivities.filter { $0.isCompleted }.count
    }

    var activitiesCompletionRate: Double {
        guard !learningActivities.isEmpty else { return 0.0 }
        return Double(completedActivities) / Double(learningActivities.count) * 100.0
    }
}

// MARK: - Career Path
enum CareerPath: String, Codable {
    case specialist = "Technical Specialist"
    case management = "People Management"
    case hybrid = "Hybrid (Tech + Management)"
    case executive = "Executive Leadership"
    case entrepreneur = "Entrepreneurial"
}

// MARK: - Development Plan Status
enum DevelopmentPlanStatus: String, Codable {
    case draft = "Draft"
    case active = "Active"
    case onHold = "On Hold"
    case completed = "Completed"
    case archived = "Archived"
}

// MARK: - Development Area
struct DevelopmentArea: Codable, Identifiable {
    let id: UUID
    var area: String
    var currentLevel: ProficiencyLevel
    var targetLevel: ProficiencyLevel
    var priority: GoalPriority
    var actions: [String]

    init(
        id: UUID = UUID(),
        area: String,
        currentLevel: ProficiencyLevel,
        targetLevel: ProficiencyLevel,
        priority: GoalPriority = .medium
    ) {
        self.id = id
        self.area = area
        self.currentLevel = currentLevel
        self.targetLevel = targetLevel
        self.priority = priority
        self.actions = []
    }
}

// MARK: - Learning Activity
struct LearningActivity: Codable, Identifiable {
    let id: UUID
    var title: String
    var type: LearningActivityType
    var provider: String?
    var duration: TimeInterval // in hours
    var targetCompletionDate: Date
    var isCompleted: Bool
    var completedDate: Date?
    var certificateURL: URL?

    init(
        id: UUID = UUID(),
        title: String,
        type: LearningActivityType,
        duration: TimeInterval,
        targetCompletionDate: Date
    ) {
        self.id = id
        self.title = title
        self.type = type
        self.duration = duration
        self.targetCompletionDate = targetCompletionDate
        self.isCompleted = false
    }
}

// MARK: - Learning Activity Type
enum LearningActivityType: String, Codable {
    case course = "Online Course"
    case certification = "Certification"
    case conference = "Conference"
    case workshop = "Workshop"
    case reading = "Reading"
    case project = "Project"
    case mentorship = "Mentorship"
    case coaching = "Coaching"
    case shadowing = "Job Shadowing"
    case other = "Other"

    var icon: String {
        switch self {
        case .course: return "play.rectangle.fill"
        case .certification: return "rosette"
        case .conference: return "person.3.fill"
        case .workshop: return "hammer.fill"
        case .reading: return "book.fill"
        case .project: return "folder.fill"
        case .mentorship: return "person.2.fill"
        case .coaching: return "figure.walk"
        case .shadowing: return "eye.fill"
        case .other: return "star.fill"
        }
    }
}
