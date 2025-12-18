import Foundation
import SwiftData

// MARK: - Sustainability Goal Model (SwiftData)

@Model
final class SustainabilityGoalModel {
    @Attribute(.unique) var id: UUID
    var title: String
    var description: String
    var category: String

    // Metrics
    var baselineValue: Double
    var currentValue: Double
    var targetValue: Double
    var unit: String

    // Timeline
    var startDate: Date
    var targetDate: Date

    // Status
    var status: String  // onTrack, atRisk, behind, achieved
    var progress: Double  // 0.0 - 1.0

    // Metadata
    var createdAt: Date
    var updatedAt: Date
    var achievedAt: Date?

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        category: String,
        baselineValue: Double,
        currentValue: Double,
        targetValue: Double,
        unit: String,
        startDate: Date,
        targetDate: Date,
        status: String = "onTrack"
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.baselineValue = baselineValue
        self.currentValue = currentValue
        self.targetValue = targetValue
        self.unit = unit
        self.startDate = startDate
        self.targetDate = targetDate
        self.status = status
        self.createdAt = Date()
        self.updatedAt = Date()

        // Calculate progress
        if targetValue == baselineValue {
            self.progress = 0.0
        } else {
            self.progress = abs(currentValue - baselineValue) / abs(targetValue - baselineValue)
        }
    }
}

// MARK: - View Model (Non-persistent)

struct SustainabilityGoal: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let category: GoalCategory

    let baselineValue: Double
    let currentValue: Double
    let targetValue: Double
    let unit: String

    let startDate: Date
    let targetDate: Date

    let status: GoalStatus
    let progress: Double  // 0.0 - 1.0

    let achievedAt: Date?

    var daysRemaining: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: targetDate).day ?? 0
    }

    var isOverdue: Bool {
        targetDate < Date() && status != .achieved
    }

    var progressPercentage: Int {
        Int(progress * 100)
    }

    init(from model: SustainabilityGoalModel) {
        self.id = model.id
        self.title = model.title
        self.description = model.description
        self.category = GoalCategory(rawValue: model.category) ?? .other
        self.baselineValue = model.baselineValue
        self.currentValue = model.currentValue
        self.targetValue = model.targetValue
        self.unit = model.unit
        self.startDate = model.startDate
        self.targetDate = model.targetDate
        self.status = GoalStatus(rawValue: model.status) ?? .onTrack
        self.progress = model.progress
        self.achievedAt = model.achievedAt
    }
}

// MARK: - Supporting Types

enum GoalCategory: String, Codable, CaseIterable {
    case carbonReduction = "Carbon Reduction"
    case energyEfficiency = "Energy Efficiency"
    case wasteReduction = "Waste Reduction"
    case waterConservation = "Water Conservation"
    case renewableEnergy = "Renewable Energy"
    case circularEconomy = "Circular Economy"
    case other = "Other"

    var icon: String {
        switch self {
        case .carbonReduction: return "leaf.fill"
        case .energyEfficiency: return "bolt.fill"
        case .wasteReduction: return "trash.slash"
        case .waterConservation: return "drop.fill"
        case .renewableEnergy: return "sun.max.fill"
        case .circularEconomy: return "arrow.triangle.2.circlepath"
        case .other: return "flag.fill"
        }
    }

    var color: String {
        switch self {
        case .carbonReduction: return "#27AE60"
        case .energyEfficiency: return "#F9A826"
        case .wasteReduction: return "#828282"
        case .waterConservation: return "#56CCF2"
        case .renewableEnergy: return "#F2C94C"
        case .circularEconomy: return "#9B51E0"
        case .other: return "#2D9CDB"
        }
    }
}

enum GoalStatus: String, Codable {
    case onTrack = "onTrack"
    case atRisk = "atRisk"
    case behind = "behind"
    case achieved = "achieved"

    var displayName: String {
        switch self {
        case .onTrack: return "On Track"
        case .atRisk: return "At Risk"
        case .behind: return "Behind Schedule"
        case .achieved: return "Achieved"
        }
    }

    var color: String {
        switch self {
        case .onTrack: return "#27AE60"
        case .atRisk: return "#F2C94C"
        case .behind: return "#E34034"
        case .achieved: return "#2D9CDB"
        }
    }

    var icon: String {
        switch self {
        case .onTrack: return "checkmark.circle.fill"
        case .atRisk: return "exclamationmark.triangle.fill"
        case .behind: return "xmark.circle.fill"
        case .achieved: return "star.fill"
        }
    }
}

struct Milestone: Identifiable {
    let id: UUID
    let title: String
    let targetDate: Date
    let targetValue: Double
    var isCompleted: Bool
    let completedAt: Date?
}
