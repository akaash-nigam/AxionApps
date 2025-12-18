//
//  MaintenanceTask.swift
//  HomeMaintenanceOracle
//
//  Created on 2025-11-24.
//  Domain model for maintenance tasks
//

import Foundation

struct MaintenanceTask: Identifiable, Codable {
    let id: UUID
    let applianceId: UUID
    var title: String
    var taskDescription: String?
    var frequency: MaintenanceFrequency
    var lastCompletedDate: Date?
    var nextDueDate: Date
    var isCompleted: Bool
    var priority: TaskPriority
    var estimatedDurationMinutes: Int?
    var notes: String?
    var createdAt: Date
    var updatedAt: Date

    var isOverdue: Bool {
        nextDueDate < Date() && !isCompleted
    }

    var daysUntilDue: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: nextDueDate).day ?? 0
    }

    init(
        id: UUID = UUID(),
        applianceId: UUID,
        title: String,
        taskDescription: String? = nil,
        frequency: MaintenanceFrequency,
        lastCompletedDate: Date? = nil,
        nextDueDate: Date,
        isCompleted: Bool = false,
        priority: TaskPriority = .medium,
        estimatedDurationMinutes: Int? = nil,
        notes: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.applianceId = applianceId
        self.title = title
        self.taskDescription = taskDescription
        self.frequency = frequency
        self.lastCompletedDate = lastCompletedDate
        self.nextDueDate = nextDueDate
        self.isCompleted = isCompleted
        self.priority = priority
        self.estimatedDurationMinutes = estimatedDurationMinutes
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // Calculate next due date based on frequency
    func calculateNextDueDate(from baseDate: Date = Date()) -> Date {
        let calendar = Calendar.current
        switch frequency {
        case .weekly:
            return calendar.date(byAdding: .weekOfYear, value: 1, to: baseDate) ?? baseDate
        case .biweekly:
            return calendar.date(byAdding: .weekOfYear, value: 2, to: baseDate) ?? baseDate
        case .monthly:
            return calendar.date(byAdding: .month, value: 1, to: baseDate) ?? baseDate
        case .quarterly:
            return calendar.date(byAdding: .month, value: 3, to: baseDate) ?? baseDate
        case .biannually:
            return calendar.date(byAdding: .month, value: 6, to: baseDate) ?? baseDate
        case .annually:
            return calendar.date(byAdding: .year, value: 1, to: baseDate) ?? baseDate
        case .custom(let days):
            return calendar.date(byAdding: .day, value: days, to: baseDate) ?? baseDate
        case .oneTime:
            return baseDate
        }
    }
}

// MARK: - MaintenanceFrequency

enum MaintenanceFrequency: Codable, Equatable {
    case weekly
    case biweekly
    case monthly
    case quarterly
    case biannually
    case annually
    case custom(days: Int)
    case oneTime

    var displayName: String {
        switch self {
        case .weekly: return "Weekly"
        case .biweekly: return "Every 2 weeks"
        case .monthly: return "Monthly"
        case .quarterly: return "Quarterly"
        case .biannually: return "Twice a year"
        case .annually: return "Annually"
        case .custom(let days): return "Every \(days) days"
        case .oneTime: return "One-time"
        }
    }

    var icon: String {
        switch self {
        case .weekly, .biweekly: return "calendar.badge.clock"
        case .monthly: return "calendar"
        case .quarterly, .biannually: return "calendar.badge.plus"
        case .annually: return "calendar.circle"
        case .custom: return "calendar.badge.exclamationmark"
        case .oneTime: return "calendar.badge.checkmark"
        }
    }
}

// MARK: - TaskPriority

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

    var icon: String {
        switch self {
        case .low: return "arrow.down.circle"
        case .medium: return "minus.circle"
        case .high: return "arrow.up.circle"
        case .critical: return "exclamationmark.triangle.fill"
        }
    }
}

// MARK: - ServiceHistory

struct ServiceHistory: Identifiable, Codable {
    let id: UUID
    let applianceId: UUID
    var serviceDate: Date
    var serviceType: ServiceType
    var technicianName: String?
    var company: String?
    var cost: Double?
    var notes: String?
    var partsReplaced: [String]
    var nextServiceRecommendation: Date?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        applianceId: UUID,
        serviceDate: Date,
        serviceType: ServiceType,
        technicianName: String? = nil,
        company: String? = nil,
        cost: Double? = nil,
        notes: String? = nil,
        partsReplaced: [String] = [],
        nextServiceRecommendation: Date? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.applianceId = applianceId
        self.serviceDate = serviceDate
        self.serviceType = serviceType
        self.technicianName = technicianName
        self.company = company
        self.cost = cost
        self.notes = notes
        self.partsReplaced = partsReplaced
        self.nextServiceRecommendation = nextServiceRecommendation
        self.createdAt = createdAt
    }
}

// MARK: - ServiceType

enum ServiceType: String, Codable, CaseIterable {
    case routine = "Routine Maintenance"
    case repair = "Repair"
    case inspection = "Inspection"
    case cleaning = "Deep Cleaning"
    case partReplacement = "Part Replacement"
    case warranty = "Warranty Service"
    case emergency = "Emergency Service"
    case other = "Other"

    var icon: String {
        switch self {
        case .routine: return "calendar.badge.checkmark"
        case .repair: return "wrench.and.screwdriver"
        case .inspection: return "magnifyingglass"
        case .cleaning: return "sparkles"
        case .partReplacement: return "cube.box"
        case .warranty: return "doc.text"
        case .emergency: return "exclamationmark.triangle.fill"
        case .other: return "ellipsis.circle"
        }
    }
}
