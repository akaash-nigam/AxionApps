//
//  CloseTask.swift
//  Financial Operations Platform
//
//  Month-end close task management models
//

import Foundation
import SwiftData
import simd

@Model
final class CloseTask: Identifiable {
    // MARK: - Properties

    @Attribute(.unique) var id: UUID
    var taskName: String
    var taskDescription: String
    var period: ClosePeriod
    var assignee: String
    var status: TaskStatus
    var priority: TaskPriority
    var dueDate: Date
    var completedDate: Date?
    var verifiedBy: String?
    var verifiedDate: Date?
    var dependencyIds: [String] // UUIDs of dependent tasks
    var estimatedHours: Double
    var actualHours: Double?
    var notes: String?
    var createdAt: Date
    var updatedAt: Date

    // 3D Visualization in Close Environment
    var mountainHeight: Float // Task complexity
    var spatialPositionX: Float
    var spatialPositionY: Float
    var spatialPositionZ: Float

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        taskName: String,
        taskDescription: String,
        period: ClosePeriod,
        assignee: String,
        status: TaskStatus = .notStarted,
        priority: TaskPriority = .medium,
        dueDate: Date,
        dependencyIds: [String] = [],
        estimatedHours: Double,
        mountainHeight: Float = 1.0,
        spatialPosition: SIMD3<Float> = SIMD3<Float>(0, 0, 0),
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.taskName = taskName
        self.taskDescription = taskDescription
        self.period = period
        self.assignee = assignee
        self.status = status
        self.priority = priority
        self.dueDate = dueDate
        self.dependencyIds = dependencyIds
        self.estimatedHours = estimatedHours
        self.mountainHeight = mountainHeight
        self.spatialPositionX = spatialPosition.x
        self.spatialPositionY = spatialPosition.y
        self.spatialPositionZ = spatialPosition.z
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // MARK: - Computed Properties

    var spatialPosition: SIMD3<Float> {
        get {
            SIMD3<Float>(spatialPositionX, spatialPositionY, spatialPositionZ)
        }
        set {
            spatialPositionX = newValue.x
            spatialPositionY = newValue.y
            spatialPositionZ = newValue.z
        }
    }

    var isComplete: Bool {
        status == .completed || status == .verified
    }

    var isBlocked: Bool {
        status == .blocked
    }

    var isOverdue: Bool {
        !isComplete && dueDate < Date()
    }

    var progressPercent: Double {
        guard let actual = actualHours, estimatedHours > 0 else {
            return 0
        }
        return min((actual / estimatedHours) * 100, 100)
    }

    var hoursRemaining: Double {
        guard !isComplete else { return 0 }
        if let actual = actualHours {
            return max(estimatedHours - actual, 0)
        }
        return estimatedHours
    }

    var daysUntilDue: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: dueDate).day ?? 0
    }

    var statusColor: String {
        if isOverdue { return "red" }
        return status.color
    }
}

// MARK: - Task Status

enum TaskStatus: String, Codable, CaseIterable {
    case notStarted = "not_started"
    case inProgress = "in_progress"
    case blocked
    case completed
    case verified

    var displayName: String {
        switch self {
        case .notStarted: return "Not Started"
        case .inProgress: return "In Progress"
        case .blocked: return "Blocked"
        case .completed: return "Completed"
        case .verified: return "Verified"
        }
    }

    var color: String {
        switch self {
        case .notStarted: return "gray"
        case .inProgress: return "blue"
        case .blocked: return "red"
        case .completed: return "green"
        case .verified: return "green"
        }
    }

    var icon: String {
        switch self {
        case .notStarted: return "circle"
        case .inProgress: return "circle.lefthalf.filled"
        case .blocked: return "exclamationmark.triangle"
        case .completed: return "checkmark.circle"
        case .verified: return "checkmark.seal.fill"
        }
    }
}

// MARK: - Task Priority

enum TaskPriority: String, Codable, CaseIterable {
    case low
    case medium
    case high
    case critical

    var displayName: String {
        rawValue.capitalized
    }

    var color: String {
        switch self {
        case .low: return "gray"
        case .medium: return "blue"
        case .high: return "orange"
        case .critical: return "red"
        }
    }

    var sortOrder: Int {
        switch self {
        case .low: return 0
        case .medium: return 1
        case .high: return 2
        case .critical: return 3
        }
    }
}

// MARK: - Close Process

@Model
final class CloseProcess: Identifiable {
    @Attribute(.unique) var id: UUID
    var period: ClosePeriod
    var status: CloseStatus
    var startDate: Date
    var targetCloseDate: Date
    var actualCloseDate: Date?
    var totalTasks: Int
    var completedTasks: Int
    var blockedTasks: Int
    var totalEstimatedHours: Double
    var totalActualHours: Double
    var createdBy: String
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        period: ClosePeriod,
        status: CloseStatus = .notStarted,
        startDate: Date = Date(),
        targetCloseDate: Date,
        totalTasks: Int = 0,
        completedTasks: Int = 0,
        blockedTasks: Int = 0,
        totalEstimatedHours: Double = 0,
        totalActualHours: Double = 0,
        createdBy: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.period = period
        self.status = status
        self.startDate = startDate
        self.targetCloseDate = targetCloseDate
        self.totalTasks = totalTasks
        self.completedTasks = completedTasks
        self.blockedTasks = blockedTasks
        self.totalEstimatedHours = totalEstimatedHours
        self.totalActualHours = totalActualHours
        self.createdBy = createdBy
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var progressPercent: Double {
        guard totalTasks > 0 else { return 0 }
        return (Double(completedTasks) / Double(totalTasks)) * 100
    }

    var isOnTrack: Bool {
        let daysToTarget = Calendar.current.dateComponents([.day], from: Date(), to: targetCloseDate).day ?? 0
        let requiredProgress = 100.0 - (Double(daysToTarget) / 10.0 * 100.0)
        return progressPercent >= requiredProgress
    }

    var daysRemaining: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: targetCloseDate).day ?? 0
    }
}

// MARK: - Close Status

enum CloseStatus: String, Codable, CaseIterable {
    case notStarted = "not_started"
    case inProgress = "in_progress"
    case review
    case approved
    case locked

    var displayName: String {
        switch self {
        case .notStarted: return "Not Started"
        case .inProgress: return "In Progress"
        case .review: return "Under Review"
        case .approved: return "Approved"
        case .locked: return "Locked"
        }
    }

    var color: String {
        switch self {
        case .notStarted: return "gray"
        case .inProgress: return "blue"
        case .review: return "orange"
        case .approved: return "green"
        case .locked: return "purple"
        }
    }
}

// MARK: - Close Report

struct CloseReport: Codable {
    let period: ClosePeriod
    let closedDate: Date
    let totalTasks: Int
    let completedOnTime: Int
    let completedLate: Int
    let totalHours: Double
    let issuesEncountered: [CloseIssue]
    let keyMetrics: CloseMetrics
    let generatedAt: Date
    let generatedBy: String

    struct CloseIssue: Codable, Identifiable {
        let id: UUID
        let description: String
        let severity: RiskSeverity
        let resolution: String?
        let hoursImpact: Double
    }

    struct CloseMetrics: Codable {
        let closeDuration: Int // days
        let efficiency: Double // % compared to estimate
        let qualityScore: Double // 0-100
        let teamUtilization: Double // % of capacity
    }
}
