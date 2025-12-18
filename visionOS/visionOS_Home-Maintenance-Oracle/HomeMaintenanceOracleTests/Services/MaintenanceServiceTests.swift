//
//  MaintenanceServiceTests.swift
//  HomeMaintenanceOracleTests
//
//  Created on 2025-11-24.
//  Unit tests for MaintenanceService
//

import XCTest
@testable import HomeMaintenanceOracle

final class MaintenanceServiceTests: XCTestCase {

    var sut: MaintenanceService!
    var mockRepository: MockMaintenanceRepository!
    var mockNotificationManager: MockNotificationManager!

    override func setUp() async throws {
        try await super.setUp()
        mockRepository = MockMaintenanceRepository()
        mockNotificationManager = MockNotificationManager()
        sut = MaintenanceService(
            repository: mockRepository,
            notificationManager: mockNotificationManager
        )
    }

    override func tearDown() async throws {
        sut = nil
        mockRepository = nil
        mockNotificationManager = nil
        try await super.tearDown()
    }

    // MARK: - Get Tasks Tests

    func testGetTasks_ForAppliance_ReturnsFilteredTasks() async throws {
        // Given
        let applianceId = UUID()
        let task1 = MaintenanceTask(
            applianceId: applianceId,
            title: "Task 1",
            frequency: .monthly,
            nextDueDate: Date()
        )
        let task2 = MaintenanceTask(
            applianceId: UUID(), // Different appliance
            title: "Task 2",
            frequency: .monthly,
            nextDueDate: Date()
        )
        mockRepository.tasks = [task1, task2]

        // When
        let tasks = try await sut.getTasks(for: applianceId)

        // Then
        XCTAssertEqual(tasks.count, 1)
        XCTAssertEqual(tasks.first?.title, "Task 1")
    }

    func testGetUpcomingTasks_ReturnsLimitedSortedTasks() async throws {
        // Given
        let task1 = MaintenanceTask(
            applianceId: UUID(),
            title: "Task 1",
            frequency: .monthly,
            nextDueDate: Date().addingTimeInterval(86400 * 2)
        )
        let task2 = MaintenanceTask(
            applianceId: UUID(),
            title: "Task 2",
            frequency: .monthly,
            nextDueDate: Date().addingTimeInterval(86400 * 5)
        )
        let task3 = MaintenanceTask(
            applianceId: UUID(),
            title: "Task 3",
            frequency: .monthly,
            nextDueDate: Date().addingTimeInterval(86400)
        )
        mockRepository.tasks = [task1, task2, task3]

        // When
        let tasks = try await sut.getUpcomingTasks(limit: 2)

        // Then
        XCTAssertEqual(tasks.count, 2)
        XCTAssertEqual(tasks.first?.title, "Task 3") // Earliest
    }

    func testGetOverdueTasks_ReturnsOnlyOverdueTasks() async throws {
        // Given
        let overdueTask = MaintenanceTask(
            applianceId: UUID(),
            title: "Overdue Task",
            frequency: .monthly,
            nextDueDate: Date().addingTimeInterval(-86400) // Yesterday
        )
        let upcomingTask = MaintenanceTask(
            applianceId: UUID(),
            title: "Upcoming Task",
            frequency: .monthly,
            nextDueDate: Date().addingTimeInterval(86400) // Tomorrow
        )
        mockRepository.tasks = [overdueTask, upcomingTask]

        // When
        let tasks = try await sut.getOverdueTasks()

        // Then
        XCTAssertEqual(tasks.count, 1)
        XCTAssertEqual(tasks.first?.title, "Overdue Task")
        XCTAssertTrue(tasks.first?.isOverdue ?? false)
    }

    // MARK: - Create Task Tests

    func testCreateTask_SavesTaskAndSchedulesNotification() async throws {
        // Given
        let task = MaintenanceTask(
            applianceId: UUID(),
            title: "New Task",
            frequency: .monthly,
            nextDueDate: Date().addingTimeInterval(86400 * 30)
        )

        // When
        try await sut.createTask(task)

        // Then
        XCTAssertEqual(mockRepository.tasks.count, 1)
        XCTAssertEqual(mockRepository.tasks.first?.title, "New Task")
        XCTAssertTrue(mockNotificationManager.scheduledNotifications.contains(task.id.uuidString))
    }

    // MARK: - Update Task Tests

    func testUpdateTask_UpdatesTaskAndReschedulesNotification() async throws {
        // Given
        var task = MaintenanceTask(
            applianceId: UUID(),
            title: "Original Task",
            frequency: .monthly,
            nextDueDate: Date()
        )
        try await sut.createTask(task)

        // When
        task.title = "Updated Task"
        try await sut.updateTask(task)

        // Then
        let updatedTask = mockRepository.tasks.first
        XCTAssertEqual(updatedTask?.title, "Updated Task")
        XCTAssertNotNil(updatedTask?.updatedAt)
    }

    // MARK: - Delete Task Tests

    func testDeleteTask_RemovesTaskAndCancelsNotification() async throws {
        // Given
        let task = MaintenanceTask(
            applianceId: UUID(),
            title: "Task to Delete",
            frequency: .monthly,
            nextDueDate: Date()
        )
        try await sut.createTask(task)
        XCTAssertEqual(mockRepository.tasks.count, 1)

        // When
        try await sut.deleteTask(task.id)

        // Then
        XCTAssertTrue(mockRepository.tasks.isEmpty)
        XCTAssertTrue(mockNotificationManager.cancelledNotifications.contains(task.id.uuidString))
    }

    // MARK: - Complete Task Tests

    func testCompleteTask_OneTime_MarksAsCompleted() async throws {
        // Given
        let task = MaintenanceTask(
            applianceId: UUID(),
            title: "One-time Task",
            frequency: .oneTime,
            nextDueDate: Date()
        )
        try await sut.createTask(task)

        // When
        try await sut.completeTask(task.id, completionNotes: "Completed successfully")

        // Then
        let completedTask = mockRepository.tasks.first
        XCTAssertTrue(completedTask?.isCompleted ?? false)
        XCTAssertNotNil(completedTask?.lastCompletedDate)
        XCTAssertEqual(completedTask?.notes, "Completed successfully")
    }

    func testCompleteTask_Recurring_ResetsAndSchedulesNext() async throws {
        // Given
        let originalDate = Date()
        let task = MaintenanceTask(
            applianceId: UUID(),
            title: "Recurring Task",
            frequency: .monthly,
            nextDueDate: originalDate
        )
        try await sut.createTask(task)

        // When
        try await sut.completeTask(task.id, completionNotes: nil)

        // Then
        let updatedTask = mockRepository.tasks.first
        XCTAssertFalse(updatedTask?.isCompleted ?? true) // Reset for next occurrence
        XCTAssertNotNil(updatedTask?.lastCompletedDate)
        // Next due date should be ~1 month from now
        let nextDue = updatedTask?.nextDueDate ?? Date()
        let expectedDate = Calendar.current.date(byAdding: .month, value: 1, to: originalDate)!
        let difference = abs(nextDue.timeIntervalSince(expectedDate))
        XCTAssertLessThan(difference, 60) // Within 60 seconds
    }

    func testCompleteTask_NonExistent_ThrowsError() async {
        // Given
        let nonExistentId = UUID()

        // When/Then
        do {
            try await sut.completeTask(nonExistentId, completionNotes: nil)
            XCTFail("Should have thrown error")
        } catch {
            XCTAssertTrue(error is MaintenanceServiceError)
        }
    }

    // MARK: - Generate Recommended Tasks Tests

    func testGenerateRecommendedTasks_Refrigerator_GeneratesCorrectTasks() {
        // Given
        let appliance = Appliance(
            brand: "Samsung",
            model: "RF28R7351SR",
            category: .refrigerator
        )

        // When
        let tasks = sut.generateRecommendedTasks(for: appliance)

        // Then
        XCTAssertEqual(tasks.count, 2)
        XCTAssertTrue(tasks.contains { $0.title.contains("condenser coils") })
        XCTAssertTrue(tasks.contains { $0.title.contains("water filter") })
        XCTAssertTrue(tasks.allSatisfy { $0.frequency == .biannually })
    }

    func testGenerateRecommendedTasks_HVAC_GeneratesCorrectTasks() {
        // Given
        let appliance = Appliance(
            brand: "Carrier",
            model: "123ABC",
            category: .hvac
        )

        // When
        let tasks = sut.generateRecommendedTasks(for: appliance)

        // Then
        XCTAssertEqual(tasks.count, 2)
        XCTAssertTrue(tasks.contains { $0.title.contains("air filter") })
        XCTAssertTrue(tasks.contains { $0.title.contains("inspection") })
        // Air filter should be high priority
        let airFilterTask = tasks.first { $0.title.contains("air filter") }
        XCTAssertEqual(airFilterTask?.priority, .high)
    }

    func testGenerateRecommendedTasks_WasherDryer_GeneratesCorrectTasks() {
        // Given
        let washer = Appliance(
            brand: "Whirlpool",
            model: "WFW123",
            category: .washer
        )

        // When
        let tasks = sut.generateRecommendedTasks(for: washer)

        // Then
        XCTAssertEqual(tasks.count, 1)
        XCTAssertTrue(tasks.first?.title.contains("lint") ?? false)
        XCTAssertEqual(tasks.first?.frequency, .monthly)
    }

    func testGenerateRecommendedTasks_Other_GeneratesNoTasks() {
        // Given
        let appliance = Appliance(
            brand: "Generic",
            model: "123",
            category: .other
        )

        // When
        let tasks = sut.generateRecommendedTasks(for: appliance)

        // Then
        XCTAssertTrue(tasks.isEmpty)
    }

    // MARK: - Service History Tests

    func testGetServiceHistory_ReturnsHistoryForAppliance() async throws {
        // Given
        let applianceId = UUID()
        let record1 = ServiceHistory(
            applianceId: applianceId,
            serviceDate: Date(),
            serviceType: .routine
        )
        let record2 = ServiceHistory(
            applianceId: UUID(), // Different appliance
            serviceDate: Date(),
            serviceType: .repair
        )
        mockRepository.history = [record1, record2]

        // When
        let history = try await sut.getServiceHistory(for: applianceId)

        // Then
        XCTAssertEqual(history.count, 1)
        XCTAssertEqual(history.first?.serviceType, .routine)
    }

    func testAddServiceRecord_SavesRecord() async throws {
        // Given
        let record = ServiceHistory(
            applianceId: UUID(),
            serviceDate: Date(),
            serviceType: .repair,
            cost: 150.00
        )

        // When
        try await sut.addServiceRecord(record)

        // Then
        XCTAssertEqual(mockRepository.history.count, 1)
        XCTAssertEqual(mockRepository.history.first?.cost, 150.00)
    }

    func testDeleteServiceRecord_RemovesRecord() async throws {
        // Given
        let record = ServiceHistory(
            applianceId: UUID(),
            serviceDate: Date(),
            serviceType: .repair
        )
        try await sut.addServiceRecord(record)

        // When
        try await sut.deleteServiceRecord(record.id)

        // Then
        XCTAssertTrue(mockRepository.history.isEmpty)
    }
}

// MARK: - Mock Repository

class MockMaintenanceRepository: MaintenanceRepositoryProtocol {
    var tasks: [MaintenanceTask] = []
    var history: [ServiceHistory] = []

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
        return history.filter { $0.applianceId == applianceId }
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

// MARK: - Mock Notification Manager

class MockNotificationManager: NotificationManager {
    var scheduledNotifications: Set<String> = []
    var cancelledNotifications: Set<String> = []

    override func scheduleNotification(id: String, title: String, body: String, date: Date) {
        scheduledNotifications.insert(id)
    }

    override func cancelNotification(withId id: String) {
        cancelledNotifications.insert(id)
    }
}
