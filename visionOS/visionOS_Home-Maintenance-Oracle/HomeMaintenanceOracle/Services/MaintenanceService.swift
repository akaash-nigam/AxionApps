//
//  MaintenanceService.swift
//  HomeMaintenanceOracle
//
//  Created on 2025-11-24.
//  Service for managing maintenance tasks and service history
//

import Foundation

protocol MaintenanceServiceProtocol {
    // Maintenance Tasks
    func getTasks(for applianceId: UUID) async throws -> [MaintenanceTask]
    func getUpcomingTasks(limit: Int) async throws -> [MaintenanceTask]
    func getOverdueTasks() async throws -> [MaintenanceTask]
    func createTask(_ task: MaintenanceTask) async throws
    func updateTask(_ task: MaintenanceTask) async throws
    func deleteTask(_ taskId: UUID) async throws
    func completeTask(_ taskId: UUID, completionNotes: String?) async throws

    // Service History
    func getServiceHistory(for applianceId: UUID) async throws -> [ServiceHistory]
    func addServiceRecord(_ record: ServiceHistory) async throws
    func deleteServiceRecord(_ recordId: UUID) async throws

    // Scheduling
    func generateRecommendedTasks(for appliance: Appliance) -> [MaintenanceTask]
    func scheduleReminder(for task: MaintenanceTask) throws
}

class MaintenanceService: MaintenanceServiceProtocol {
    private let repository: MaintenanceRepositoryProtocol
    private let notificationManager: NotificationManager

    init(
        repository: MaintenanceRepositoryProtocol = MaintenanceRepository(),
        notificationManager: NotificationManager = NotificationManager.shared
    ) {
        self.repository = repository
        self.notificationManager = notificationManager
    }

    // MARK: - Maintenance Tasks

    func getTasks(for applianceId: UUID) async throws -> [MaintenanceTask] {
        return try await repository.getTasks(for: applianceId)
    }

    func getUpcomingTasks(limit: Int = 10) async throws -> [MaintenanceTask] {
        return try await repository.getUpcomingTasks(limit: limit)
    }

    func getOverdueTasks() async throws -> [MaintenanceTask] {
        return try await repository.getOverdueTasks()
    }

    func createTask(_ task: MaintenanceTask) async throws {
        try await repository.saveTask(task)

        // Schedule notification
        try scheduleReminder(for: task)
    }

    func updateTask(_ task: MaintenanceTask) async throws {
        var updatedTask = task
        updatedTask.updatedAt = Date()
        try await repository.saveTask(updatedTask)

        // Update notification
        try scheduleReminder(for: updatedTask)
    }

    func deleteTask(_ taskId: UUID) async throws {
        try await repository.deleteTask(taskId)

        // Cancel notification
        notificationManager.cancelNotification(withId: taskId.uuidString)
    }

    func completeTask(_ taskId: UUID, completionNotes: String?) async throws {
        guard var task = try await repository.getTask(taskId) else {
            throw MaintenanceServiceError.taskNotFound
        }

        // Mark as completed
        task.isCompleted = true
        task.lastCompletedDate = Date()
        task.updatedAt = Date()

        // If recurring, calculate next due date
        if task.frequency != .oneTime {
            task.nextDueDate = task.calculateNextDueDate(from: Date())
            task.isCompleted = false // Reset for next occurrence
        }

        if let notes = completionNotes {
            task.notes = notes
        }

        try await repository.saveTask(task)

        // Reschedule notification for next occurrence if recurring
        if task.frequency != .oneTime {
            try scheduleReminder(for: task)
        }
    }

    // MARK: - Service History

    func getServiceHistory(for applianceId: UUID) async throws -> [ServiceHistory] {
        return try await repository.getServiceHistory(for: applianceId)
    }

    func addServiceRecord(_ record: ServiceHistory) async throws {
        try await repository.saveServiceRecord(record)
    }

    func deleteServiceRecord(_ recordId: UUID) async throws {
        try await repository.deleteServiceRecord(recordId)
    }

    // MARK: - Scheduling

    func generateRecommendedTasks(for appliance: Appliance) -> [MaintenanceTask] {
        var tasks: [MaintenanceTask] = []

        // Generate recommended tasks based on appliance category
        switch appliance.category {
        case .refrigerator:
            tasks.append(MaintenanceTask(
                applianceId: appliance.id,
                title: "Clean condenser coils",
                taskDescription: "Remove dust and debris from condenser coils",
                frequency: .biannually,
                nextDueDate: Date().addingTimeInterval(86400 * 180)
            ))
            tasks.append(MaintenanceTask(
                applianceId: appliance.id,
                title: "Replace water filter",
                taskDescription: "Replace refrigerator water filter",
                frequency: .biannually,
                nextDueDate: Date().addingTimeInterval(86400 * 180)
            ))

        case .hvac:
            tasks.append(MaintenanceTask(
                applianceId: appliance.id,
                title: "Replace air filter",
                taskDescription: "Replace HVAC air filter",
                frequency: .quarterly,
                nextDueDate: Date().addingTimeInterval(86400 * 90),
                priority: .high
            ))
            tasks.append(MaintenanceTask(
                applianceId: appliance.id,
                title: "Professional HVAC inspection",
                taskDescription: "Schedule professional HVAC system inspection",
                frequency: .annually,
                nextDueDate: Date().addingTimeInterval(86400 * 365),
                priority: .medium
            ))

        case .washer, .dryer:
            tasks.append(MaintenanceTask(
                applianceId: appliance.id,
                title: "Clean lint trap and vent",
                taskDescription: "Remove lint buildup",
                frequency: .monthly,
                nextDueDate: Date().addingTimeInterval(86400 * 30)
            ))

        case .dishwasher:
            tasks.append(MaintenanceTask(
                applianceId: appliance.id,
                title: "Clean filter and spray arms",
                taskDescription: "Remove and clean dishwasher filter and spray arms",
                frequency: .monthly,
                nextDueDate: Date().addingTimeInterval(86400 * 30)
            ))

        case .waterHeater:
            tasks.append(MaintenanceTask(
                applianceId: appliance.id,
                title: "Flush water heater tank",
                taskDescription: "Drain and flush sediment from tank",
                frequency: .annually,
                nextDueDate: Date().addingTimeInterval(86400 * 365),
                priority: .high
            ))

        case .garageDoor:
            tasks.append(MaintenanceTask(
                applianceId: appliance.id,
                title: "Lubricate moving parts",
                taskDescription: "Lubricate hinges, rollers, and tracks",
                frequency: .quarterly,
                nextDueDate: Date().addingTimeInterval(86400 * 90)
            ))

        default:
            break
        }

        return tasks
    }

    func scheduleReminder(for task: MaintenanceTask) throws {
        // Schedule notification 1 day before due date
        let notificationDate = Calendar.current.date(byAdding: .day, value: -1, to: task.nextDueDate) ?? task.nextDueDate

        notificationManager.scheduleNotification(
            id: task.id.uuidString,
            title: "Maintenance Due Tomorrow",
            body: task.title,
            date: notificationDate
        )
    }
}

// MARK: - Mock Implementation

class MockMaintenanceService: MaintenanceServiceProtocol {
    var tasks: [MaintenanceTask] = []
    var serviceHistory: [ServiceHistory] = []

    func getTasks(for applianceId: UUID) async throws -> [MaintenanceTask] {
        return tasks.filter { $0.applianceId == applianceId }
    }

    func getUpcomingTasks(limit: Int) async throws -> [MaintenanceTask] {
        return Array(tasks.filter { !$0.isOverdue }.prefix(limit))
    }

    func getOverdueTasks() async throws -> [MaintenanceTask] {
        return tasks.filter { $0.isOverdue }
    }

    func createTask(_ task: MaintenanceTask) async throws {
        tasks.append(task)
    }

    func updateTask(_ task: MaintenanceTask) async throws {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
        }
    }

    func deleteTask(_ taskId: UUID) async throws {
        tasks.removeAll { $0.id == taskId }
    }

    func completeTask(_ taskId: UUID, completionNotes: String?) async throws {
        if let index = tasks.firstIndex(where: { $0.id == taskId }) {
            tasks[index].isCompleted = true
            tasks[index].lastCompletedDate = Date()
        }
    }

    func getServiceHistory(for applianceId: UUID) async throws -> [ServiceHistory] {
        return serviceHistory.filter { $0.applianceId == applianceId }
    }

    func addServiceRecord(_ record: ServiceHistory) async throws {
        serviceHistory.append(record)
    }

    func deleteServiceRecord(_ recordId: UUID) async throws {
        serviceHistory.removeAll { $0.id == recordId }
    }

    func generateRecommendedTasks(for appliance: Appliance) -> [MaintenanceTask] {
        return []
    }

    func scheduleReminder(for task: MaintenanceTask) throws {
        // Mock implementation
    }
}

// MARK: - Errors

enum MaintenanceServiceError: Error, LocalizedError {
    case taskNotFound
    case invalidTask
    case notificationSchedulingFailed

    var errorDescription: String? {
        switch self {
        case .taskNotFound:
            return "Maintenance task not found"
        case .invalidTask:
            return "Invalid maintenance task data"
        case .notificationSchedulingFailed:
            return "Failed to schedule notification"
        }
    }
}

// MARK: - Repository Protocol

protocol MaintenanceRepositoryProtocol {
    func getTasks(for applianceId: UUID) async throws -> [MaintenanceTask]
    func getUpcomingTasks(limit: Int) async throws -> [MaintenanceTask]
    func getOverdueTasks() async throws -> [MaintenanceTask]
    func getTask(_ taskId: UUID) async throws -> MaintenanceTask?
    func saveTask(_ task: MaintenanceTask) async throws
    func deleteTask(_ taskId: UUID) async throws

    func getServiceHistory(for applianceId: UUID) async throws -> [ServiceHistory]
    func saveServiceRecord(_ record: ServiceHistory) async throws
    func deleteServiceRecord(_ recordId: UUID) async throws
}

// MARK: - Mock Repository

class MaintenanceRepository: MaintenanceRepositoryProtocol {
    // TODO: Implement Core Data repository
    private var tasks: [MaintenanceTask] = []
    private var history: [ServiceHistory] = []

    func getTasks(for applianceId: UUID) async throws -> [MaintenanceTask] {
        return tasks.filter { $0.applianceId == applianceId }
    }

    func getUpcomingTasks(limit: Int) async throws -> [MaintenanceTask] {
        return Array(tasks
            .filter { $0.nextDueDate >= Date() && !$0.isCompleted }
            .sorted { $0.nextDueDate < $1.nextDueDate }
            .prefix(limit))
    }

    func getOverdueTasks() async throws -> [MaintenanceTask] {
        return tasks.filter { $0.isOverdue }
    }

    func getTask(_ taskId: UUID) async throws -> MaintenanceTask? {
        return tasks.first { $0.id == taskId }
    }

    func saveTask(_ task: MaintenanceTask) async throws {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
        } else {
            tasks.append(task)
        }
    }

    func deleteTask(_ taskId: UUID) async throws {
        tasks.removeAll { $0.id == taskId }
    }

    func getServiceHistory(for applianceId: UUID) async throws -> [ServiceHistory] {
        return history.filter { $0.applianceId == applianceId }.sorted { $0.serviceDate > $1.serviceDate }
    }

    func saveServiceRecord(_ record: ServiceHistory) async throws {
        if let index = history.firstIndex(where: { $0.id == record.id }) {
            history[index] = record
        } else {
            history.append(record)
        }
    }

    func deleteServiceRecord(_ recordId: UUID) async throws {
        history.removeAll { $0.id == recordId }
    }
}
