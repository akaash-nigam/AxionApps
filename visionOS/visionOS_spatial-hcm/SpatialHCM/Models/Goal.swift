import Foundation
import SwiftData

// MARK: - Goal Model
@Model
final class Goal {
    // MARK: - Identity
    @Attribute(.unique) var id: UUID
    var title: String
    var description: String

    // MARK: - Employee Reference
    @Relationship(deleteRule: .nullify, inverse: \Employee.goals)
    var employee: Employee?

    // MARK: - Goal Details
    var category: GoalCategory
    var priority: GoalPriority = .medium
    var status: GoalStatus = .notStarted

    // MARK: - Timeline
    var startDate: Date
    var targetDate: Date
    var completedDate: Date?

    // MARK: - Progress
    var progressPercentage: Double = 0.0 // 0-100
    var milestones: [Milestone] = []

    // MARK: - Metrics
    var measurementCriteria: String?
    var targetMetric: Double?
    var currentMetric: Double?

    // MARK: - Collaboration
    var isTeamGoal: Bool = false
    var collaborators: [String] = [] // Employee IDs or names

    // MARK: - Timestamps
    var createdAt: Date
    var updatedAt: Date

    // MARK: - Initialization
    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        category: GoalCategory,
        startDate: Date = Date(),
        targetDate: Date
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.startDate = startDate
        self.targetDate = targetDate
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Computed Properties
    var isOverdue: Bool {
        guard status != .completed else { return false }
        return Date() > targetDate
    }

    var daysRemaining: Int {
        guard status != .completed else { return 0 }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: targetDate)
        return max(0, components.day ?? 0)
    }

    var daysOverdue: Int {
        guard isOverdue else { return 0 }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: targetDate, to: Date())
        return components.day ?? 0
    }

    var completedMilestones: Int {
        milestones.filter { $0.isCompleted }.count
    }

    var milestoneProgress: Double {
        guard !milestones.isEmpty else { return progressPercentage }
        return Double(completedMilestones) / Double(milestones.count) * 100.0
    }

    var isOnTrack: Bool {
        guard !isOverdue else { return false }

        let totalDuration = targetDate.timeIntervalSince(startDate)
        let elapsed = Date().timeIntervalSince(startDate)
        let expectedProgress = (elapsed / totalDuration) * 100.0

        return progressPercentage >= expectedProgress - 10.0
    }
}

// MARK: - Goal Category
enum GoalCategory: String, Codable {
    case performance = "Performance"
    case skillDevelopment = "Skill Development"
    case leadership = "Leadership"
    case project = "Project"
    case businessResult = "Business Result"
    case innovation = "Innovation"
    case collaboration = "Collaboration"
    case other = "Other"

    var icon: String {
        switch self {
        case .performance: return "chart.line.uptrend.xyaxis"
        case .skillDevelopment: return "book.fill"
        case .leadership: return "person.3.fill"
        case .project: return "list.bullet.rectangle"
        case .businessResult: return "target"
        case .innovation: return "lightbulb.fill"
        case .collaboration: return "person.2.fill"
        case .other: return "star.fill"
        }
    }
}

// MARK: - Goal Priority
enum GoalPriority: String, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case critical = "Critical"

    var color: String {
        switch self {
        case .low: return "#8E8E93"
        case .medium: return "#FF9500"
        case .high: return "#FF3B30"
        case .critical: return "#D70015"
        }
    }
}

// MARK: - Goal Status
enum GoalStatus: String, Codable {
    case notStarted = "Not Started"
    case inProgress = "In Progress"
    case onHold = "On Hold"
    case completed = "Completed"
    case cancelled = "Cancelled"

    var icon: String {
        switch self {
        case .notStarted: return "circle"
        case .inProgress: return "circle.lefthalf.filled"
        case .onHold: return "pause.circle"
        case .completed: return "checkmark.circle.fill"
        case .cancelled: return "xmark.circle"
        }
    }

    var color: String {
        switch self {
        case .notStarted: return "#8E8E93"
        case .inProgress: return "#0A84FF"
        case .onHold: return "#FF9500"
        case .completed: return "#30D158"
        case .cancelled: return "#FF3B30"
        }
    }
}

// MARK: - Milestone
struct Milestone: Codable, Identifiable {
    let id: UUID
    var title: String
    var targetDate: Date
    var isCompleted: Bool
    var completedDate: Date?

    init(
        id: UUID = UUID(),
        title: String,
        targetDate: Date,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.title = title
        self.targetDate = targetDate
        self.isCompleted = isCompleted
    }
}
