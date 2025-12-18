import Foundation
import SwiftData

@Model
final class TrainingModule {
    var id: UUID
    var title: String
    var moduleDescription: String
    var category: SafetyCategory
    var difficultyLevel: DifficultyLevel
    var estimatedDuration: TimeInterval
    var imageURL: String?
    var createdDate: Date
    var lastUpdated: Date

    @Relationship(deleteRule: .cascade)
    var scenarios: [SafetyScenario] = []

    var requiredCertifications: [String] = []
    var learningObjectives: [String] = []
    var assessmentCriteria: [String] = []

    var isCompleted: Bool = false
    var completionPercentage: Double = 0.0

    init(
        title: String,
        description: String,
        category: SafetyCategory,
        difficultyLevel: DifficultyLevel,
        estimatedDuration: TimeInterval
    ) {
        self.id = UUID()
        self.title = title
        self.moduleDescription = description
        self.category = category
        self.difficultyLevel = difficultyLevel
        self.estimatedDuration = estimatedDuration
        self.createdDate = Date()
        self.lastUpdated = Date()
    }
}

// MARK: - Safety Category

enum SafetyCategory: String, Codable, CaseIterable {
    case hazardRecognition = "Hazard Recognition"
    case emergencyResponse = "Emergency Response"
    case equipmentSafety = "Equipment Safety"
    case chemicalHandling = "Chemical Handling"
    case heightWork = "Work at Heights"
    case confinedSpace = "Confined Space"
    case lockoutTagout = "Lockout/Tagout"
    case fireEvacuation = "Fire Evacuation"
    case firstAid = "First Aid"
    case electricalSafety = "Electrical Safety"
    case fallProtection = "Fall Protection"
    case ppe = "Personal Protective Equipment"

    var icon: String {
        switch self {
        case .hazardRecognition: return "exclamationmark.triangle.fill"
        case .emergencyResponse: return "alarm.fill"
        case .equipmentSafety: return "wrench.and.screwdriver.fill"
        case .chemicalHandling: return "drop.fill"
        case .heightWork: return "arrow.up.to.line"
        case .confinedSpace: return "door.left.hand.closed"
        case .lockoutTagout: return "lock.fill"
        case .fireEvacuation: return "flame.fill"
        case .firstAid: return "cross.case.fill"
        case .electricalSafety: return "bolt.fill"
        case .fallProtection: return "figure.fall"
        case .ppe: return "figure.stand"
        }
    }
}

// MARK: - Difficulty Level

enum DifficultyLevel: String, Codable, Comparable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case expert = "Expert"

    var order: Int {
        switch self {
        case .beginner: return 0
        case .intermediate: return 1
        case .advanced: return 2
        case .expert: return 3
        }
    }

    static func < (lhs: DifficultyLevel, rhs: DifficultyLevel) -> Bool {
        lhs.order < rhs.order
    }
}
