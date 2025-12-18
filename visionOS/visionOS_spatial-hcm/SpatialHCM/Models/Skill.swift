import Foundation
import SwiftData

// MARK: - Skill Model
@Model
final class Skill {
    // MARK: - Identity
    @Attribute(.unique) var id: UUID
    var name: String
    var category: SkillCategory

    // MARK: - Employee Reference
    @Relationship(deleteRule: .nullify, inverse: \Employee.skills)
    var employee: Employee?

    // MARK: - Proficiency
    var proficiencyLevel: ProficiencyLevel
    var proficiencyScore: Double = 0.0 // 0-100
    var yearsOfExperience: Double = 0.0

    // MARK: - Validation & Certification
    var certifications: [String] = [] // Certification names
    var lastAssessed: Date?
    var assessedBy: String? // Name or ID of assessor

    // MARK: - Market Demand
    var inDemand: Bool = false
    var demandScore: Double = 0.0 // 0-100 (market demand indicator)

    // MARK: - Development
    var targetProficiency: ProficiencyLevel?
    var developmentInProgress: Bool = false

    // MARK: - Timestamps
    var createdAt: Date
    var updatedAt: Date

    // MARK: - Initialization
    init(
        id: UUID = UUID(),
        name: String,
        category: SkillCategory,
        proficiencyLevel: ProficiencyLevel = .intermediate,
        yearsOfExperience: Double = 0.0
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.proficiencyLevel = proficiencyLevel
        self.yearsOfExperience = yearsOfExperience
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Computed Properties
    var isCertified: Bool {
        !certifications.isEmpty
    }

    var needsUpdate: Bool {
        guard let lastAssessed = lastAssessed else { return true }
        let sixMonthsAgo = Calendar.current.date(byAdding: .month, value: -6, to: Date())!
        return lastAssessed < sixMonthsAgo
    }

    var displayName: String {
        isCertified ? "\(name) ✓" : name
    }
}

// MARK: - Skill Category
enum SkillCategory: String, Codable, CaseIterable {
    case technical = "Technical"
    case leadership = "Leadership"
    case communication = "Communication"
    case business = "Business"
    case design = "Design"
    case analytics = "Analytics"
    case product = "Product"
    case sales = "Sales"
    case marketing = "Marketing"
    case operations = "Operations"
    case finance = "Finance"
    case hr = "Human Resources"
    case legal = "Legal"
    case other = "Other"

    var icon: String {
        switch self {
        case .technical: return "cpu"
        case .leadership: return "person.3.fill"
        case .communication: return "bubble.left.and.bubble.right"
        case .business: return "briefcase.fill"
        case .design: return "paintbrush.fill"
        case .analytics: return "chart.bar.fill"
        case .product: return "app.fill"
        case .sales: return "dollarsign.circle.fill"
        case .marketing: return "megaphone.fill"
        case .operations: return "gearshape.fill"
        case .finance: return "dollarsign.square.fill"
        case .hr: return "person.2.fill"
        case .legal: return "doc.text.fill"
        case .other: return "star.fill"
        }
    }
}

// MARK: - Proficiency Level
enum ProficiencyLevel: String, Codable, CaseIterable, Comparable {
    case novice = "Novice"
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case expert = "Expert"
    case master = "Master"

    var score: Double {
        switch self {
        case .novice: return 10
        case .beginner: return 30
        case .intermediate: return 50
        case .advanced: return 70
        case .expert: return 90
        case .master: return 100
        }
    }

    var color: String {
        switch self {
        case .novice, .beginner: return "#FF3B30" // Red
        case .intermediate: return "#FF9500" // Orange
        case .advanced: return "#FFCC00" // Yellow
        case .expert: return "#34C759" // Green
        case .master: return "#5856D6" // Purple
        }
    }

    static func < (lhs: ProficiencyLevel, rhs: ProficiencyLevel) -> Bool {
        lhs.score < rhs.score
    }
}
