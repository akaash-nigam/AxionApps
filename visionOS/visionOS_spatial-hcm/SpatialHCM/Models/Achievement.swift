import Foundation
import SwiftData

// MARK: - Achievement Model
@Model
final class Achievement {
    // MARK: - Identity
    @Attribute(.unique) var id: UUID
    var title: String
    var description: String

    // MARK: - Employee Reference
    @Relationship(deleteRule: .nullify, inverse: \Employee.achievements)
    var employee: Employee?

    // MARK: - Achievement Details
    var category: AchievementCategory
    var impact: ImpactLevel = .medium
    var visibility: VisibilityLevel = .team

    // MARK: - Recognition
    var recognizedBy: String? // Manager or peer name
    var recognitionDate: Date
    var isPublic: Bool = true

    // MARK: - Associated Data
    var associatedGoalId: UUID?
    var associatedProjectId: UUID?
    var tags: [String] = []

    // MARK: - Evidence
    var evidence: [String] = [] // URLs or descriptions
    var metrics: [String: Double] = [:] // Key-value metrics

    // MARK: - Timestamps
    var createdAt: Date
    var updatedAt: Date

    // MARK: - Initialization
    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        category: AchievementCategory,
        recognitionDate: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.recognitionDate = recognitionDate
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Computed Properties
    var isRecent: Bool {
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        return recognitionDate > thirtyDaysAgo
    }

    var hasEvidence: Bool {
        !evidence.isEmpty
    }

    var hasMetrics: Bool {
        !metrics.isEmpty
    }
}

// MARK: - Achievement Category
enum AchievementCategory: String, Codable {
    case projectCompletion = "Project Completion"
    case innovation = "Innovation"
    case leadership = "Leadership"
    case collaboration = "Collaboration"
    case customerImpact = "Customer Impact"
    case efficiency = "Efficiency Improvement"
    case mentoring = "Mentoring"
    case skillMastery = "Skill Mastery"
    case revenue = "Revenue Impact"
    case quality = "Quality Improvement"
    case other = "Other"

    var icon: String {
        switch self {
        case .projectCompletion: return "checkmark.circle.fill"
        case .innovation: return "lightbulb.fill"
        case .leadership: return "person.3.fill"
        case .collaboration: return "person.2.fill"
        case .customerImpact: return "heart.fill"
        case .efficiency: return "speedometer"
        case .mentoring: return "person.crop.circle.badge.checkmark"
        case .skillMastery: return "star.fill"
        case .revenue: return "dollarsign.circle.fill"
        case .quality: return "seal.fill"
        case .other: return "trophy.fill"
        }
    }
}

// MARK: - Impact Level
enum ImpactLevel: String, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case transformational = "Transformational"

    var color: String {
        switch self {
        case .low: return "#8E8E93"
        case .medium: return "#0A84FF"
        case .high: return "#FF9500"
        case .transformational: return "#FFD700"
        }
    }

    var score: Double {
        switch self {
        case .low: return 25
        case .medium: return 50
        case .high: return 75
        case .transformational: return 100
        }
    }
}

// MARK: - Visibility Level
enum VisibilityLevel: String, Codable {
    case `private` = "Private"
    case team = "Team"
    case department = "Department"
    case organization = "Organization"
    case external = "External"
}
