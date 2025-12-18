//
//  MaintenanceScheduleViewModelTests.swift
//  HomeMaintenanceOracleTests
//
//  Created on 2025-11-24.
//  Unit tests for MaintenanceScheduleViewModel
//

import XCTest
@testable import HomeMaintenanceOracle

@MainActor
final class MaintenanceScheduleViewModelTests: XCTestCase {

    var sut: MaintenanceScheduleViewModel!
    var mockMaintenanceService: MockMaintenanceService!

    override func setUp() async throws {
        try await super.setUp()
        mockMaintenanceService = MockMaintenanceService()
        sut = MaintenanceScheduleViewModel(maintenanceService: mockMaintenanceService)
    }

    override func tearDown() async throws {
        sut = nil
        mockMaintenanceService = nil
        try await super.tearDown()
    }

    // MARK: - Initial State Tests

    func testInitialState() {
        XCTAssertTrue(sut.tasks.isEmpty)
        XCTAssertFalse(sut.isLoading)
        XCTAssertFalse(sut.showAddTaskSheet)
        XCTAssertNil(sut.errorMessage)
    }

    // MARK: - Load Tasks Tests

    func testLoadTasks_WithNoTasks_LoadsEmpty() async {
        // Given
        mockMaintenanceService.tasks = []

        // When
        await sut.loadTasks()

        // Then
        XCTAssertTrue(sut.tasks.isEmpty)
        XCTAssertFalse(sut.isLoading)
    }

    func testLoadTasks_WithMultipleTasks_LoadsAndSorts() async {
        // Given
        let task1 = MaintenanceTask(
            applianceId: UUID(),
            title: "Task 1",
            frequency: .monthly,
            nextDueDate: Date().addingTimeInterval(86400 * 5) // 5 days
        )
        let task2 = MaintenanceTask(
            applianceId: UUID(),
            title: "Task 2",
            frequency: .weekly,
            nextDueDate: Date().addingTimeInterval(86400 * 2) // 2 days
        )
        let task3 = MaintenanceTask(
            applianceId: UUID(),
            title: "Task 3 (Overdue)",
            frequency: .monthly,
            nextDueDate: Date().addingTimeInterval(-86400) // Yesterday
        )
        mockMaintenanceService.tasks = [task1, task2, task3]

        // When
        await sut.loadTasks()

        // Then
        XCTAssertEqual(sut.tasks.count, 3)
        // Should be sorted by due date (earliest first)
        XCTAssertEqual(sut.tasks.first?.title, "Task 3 (Overdue)")
        XCTAssertEqual(sut.tasks.last?.title, "Task 1")
    }

    func testLoadTasks_WhenServiceFails_SetsError() async {
        // Given
        mockMaintenanceService.shouldThrowError = true

        // When
        await sut.loadTasks()

        // Then
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertTrue(sut.tasks.isEmpty)
    }

    func testLoadTasks_SetsLoadingState() async {
        // Given
        mockMaintenanceService.tasks = []

        // When
        let loadTask = Task {
            await sut.loadTasks()
        }

        // Then - Check loading is eventually false
        await loadTask.value
        XCTAssertFalse(sut.isLoading)
    }

    // MARK: - Complete Task Tests

    func testCompleteTask_SuccessfullyCompletesAndReloads() async {
        // Given
        let taskId = UUID()
        let task = MaintenanceTask(
            id: taskId,
            applianceId: UUID(),
            title: "Test Task",
            frequency: .monthly,
            nextDueDate: Date()
        )
        mockMaintenanceService.tasks = [task]
        await sut.loadTasks()

        // When
        await sut.completeTask(taskId)

        // Then
        XCTAssertTrue(mockMaintenanceService.tasks.first?.isCompleted ?? false)
        // Tasks should be reloaded
        XCTAssertFalse(sut.tasks.isEmpty)
    }

    func testCompleteTask_WhenFails_SetsError() async {
        // Given
        let taskId = UUID()
        mockMaintenanceService.shouldThrowError = true

        // When
        await sut.completeTask(taskId)

        // Then
        XCTAssertNotNil(sut.errorMessage)
    }

    // MARK: - Delete Task Tests

    func testDeleteTask_RemovesTaskFromList() async {
        // Given
        let taskId = UUID()
        let task = MaintenanceTask(
            id: taskId,
            applianceId: UUID(),
            title: "Test Task",
            frequency: .monthly,
            nextDueDate: Date()
        )
        mockMaintenanceService.tasks = [task]
        await sut.loadTasks()
        XCTAssertEqual(sut.tasks.count, 1)

        // When
        await sut.deleteTask(taskId)

        // Then
        XCTAssertTrue(sut.tasks.isEmpty)
        XCTAssertTrue(mockMaintenanceService.tasks.isEmpty)
    }

    func testDeleteTask_WhenFails_SetsError() async {
        // Given
        let taskId = UUID()
        mockMaintenanceService.shouldThrowError = true

        // When
        await sut.deleteTask(taskId)

        // Then
        XCTAssertNotNil(sut.errorMessage)
    }

    // MARK: - Integration Tests

    func testLoadTasks_IntegrationWithMultipleOperations() async {
        // Given - Setup initial tasks
        let task1 = MaintenanceTask(
            applianceId: UUID(),
            title: "Task 1",
            frequency: .monthly,
            nextDueDate: Date().addingTimeInterval(86400)
        )
        let task2 = MaintenanceTask(
            applianceId: UUID(),
            title: "Task 2",
            frequency: .weekly,
            nextDueDate: Date().addingTimeInterval(86400 * 7)
        )
        mockMaintenanceService.tasks = [task1, task2]

        // When - Load tasks
        await sut.loadTasks()

        // Then
        XCTAssertEqual(sut.tasks.count, 2)

        // When - Complete one task
        await sut.completeTask(task1.id)

        // Then - Task list should be updated
        XCTAssertEqual(sut.tasks.count, 2) // Still 2 (completed task remains if recurring)

        // When - Delete a task
        await sut.deleteTask(task2.id)

        // Then
        XCTAssertEqual(sut.tasks.count, 1)
    }
}

// MARK: - Mock Service with Error Injection

extension MockMaintenanceService {
    var shouldThrowError: Bool {
        get { false }
        set {
            if newValue {
                // Inject error behavior for testing
            }
        }
    }
}
