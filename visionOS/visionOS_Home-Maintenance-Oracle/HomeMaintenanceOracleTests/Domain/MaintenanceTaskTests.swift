//
//  MaintenanceTaskTests.swift
//  HomeMaintenanceOracleTests
//
//  Created on 2025-11-24.
//  Unit tests for MaintenanceTask domain model
//

import XCTest
@testable import HomeMaintenanceOracle

final class MaintenanceTaskTests: XCTestCase {

    // MARK: - Overdue Tests

    func testIsOverdue_WhenPastDueAndNotCompleted_ReturnsTrue() {
        // Given
        let task = MaintenanceTask(
            applianceId: UUID(),
            title: "Test Task",
            frequency: .monthly,
            nextDueDate: Date().addingTimeInterval(-86400), // Yesterday
            isCompleted: false
        )

        // Then
        XCTAssertTrue(task.isOverdue)
    }

    func testIsOverdue_WhenPastDueButCompleted_ReturnsFalse() {
        // Given
        let task = MaintenanceTask(
            applianceId: UUID(),
            title: "Test Task",
            frequency: .monthly,
            nextDueDate: Date().addingTimeInterval(-86400),
            isCompleted: true
        )

        // Then
        XCTAssertFalse(task.isOverdue)
    }

    func testIsOverdue_WhenFutureDue_ReturnsFalse() {
        // Given
        let task = MaintenanceTask(
            applianceId: UUID(),
            title: "Test Task",
            frequency: .monthly,
            nextDueDate: Date().addingTimeInterval(86400),
            isCompleted: false
        )

        // Then
        XCTAssertFalse(task.isOverdue)
    }

    // MARK: - Days Until Due Tests

    func testDaysUntilDue_FutureDueDate_ReturnsPositive() {
        // Given
        let dueDate = Calendar.current.date(byAdding: .day, value: 5, to: Date())!
        let task = MaintenanceTask(
            applianceId: UUID(),
            title: "Test Task",
            frequency: .monthly,
            nextDueDate: dueDate
        )

        // Then
        XCTAssertEqual(task.daysUntilDue, 5)
    }

    func testDaysUntilDue_PastDueDate_ReturnsNegative() {
        // Given
        let dueDate = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
        let task = MaintenanceTask(
            applianceId: UUID(),
            title: "Test Task",
            frequency: .monthly,
            nextDueDate: dueDate
        )

        // Then
        XCTAssertEqual(task.daysUntilDue, -3)
    }

    func testDaysUntilDue_Today_ReturnsZero() {
        // Given
        let today = Calendar.current.startOfDay(for: Date())
        let task = MaintenanceTask(
            applianceId: UUID(),
            title: "Test Task",
            frequency: .monthly,
            nextDueDate: today
        )

        // Then
        XCTAssertEqual(task.daysUntilDue, 0)
    }

    // MARK: - Calculate Next Due Date Tests

    func testCalculateNextDueDate_Weekly_AddsOneWeek() {
        // Given
        let baseDate = Date()
        let task = MaintenanceTask(
            applianceId: UUID(),
            title: "Test Task",
            frequency: .weekly,
            nextDueDate: baseDate
        )

        // When
        let nextDate = task.calculateNextDueDate(from: baseDate)

        // Then
        let expectedDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: baseDate)!
        let difference = abs(nextDate.timeIntervalSince(expectedDate))
        XCTAssertLessThan(difference, 1)
    }

    func testCalculateNextDueDate_Monthly_AddsOneMonth() {
        // Given
        let baseDate = Date()
        let task = MaintenanceTask(
            applianceId: UUID(),
            title: "Test Task",
            frequency: .monthly,
            nextDueDate: baseDate
        )

        // When
        let nextDate = task.calculateNextDueDate(from: baseDate)

        // Then
        let expectedDate = Calendar.current.date(byAdding: .month, value: 1, to: baseDate)!
        let difference = abs(nextDate.timeIntervalSince(expectedDate))
        XCTAssertLessThan(difference, 1)
    }

    func testCalculateNextDueDate_Quarterly_AddsThreeMonths() {
        // Given
        let baseDate = Date()
        let task = MaintenanceTask(
            applianceId: UUID(),
            title: "Test Task",
            frequency: .quarterly,
            nextDueDate: baseDate
        )

        // When
        let nextDate = task.calculateNextDueDate(from: baseDate)

        // Then
        let expectedDate = Calendar.current.date(byAdding: .month, value: 3, to: baseDate)!
        let difference = abs(nextDate.timeIntervalSince(expectedDate))
        XCTAssertLessThan(difference, 1)
    }

    func testCalculateNextDueDate_Annually_AddsOneYear() {
        // Given
        let baseDate = Date()
        let task = MaintenanceTask(
            applianceId: UUID(),
            title: "Test Task",
            frequency: .annually,
            nextDueDate: baseDate
        )

        // When
        let nextDate = task.calculateNextDueDate(from: baseDate)

        // Then
        let expectedDate = Calendar.current.date(byAdding: .year, value: 1, to: baseDate)!
        let difference = abs(nextDate.timeIntervalSince(expectedDate))
        XCTAssertLessThan(difference, 1)
    }

    func testCalculateNextDueDate_Custom_AddsCustomDays() {
        // Given
        let baseDate = Date()
        let task = MaintenanceTask(
            applianceId: UUID(),
            title: "Test Task",
            frequency: .custom(days: 45),
            nextDueDate: baseDate
        )

        // When
        let nextDate = task.calculateNextDueDate(from: baseDate)

        // Then
        let expectedDate = Calendar.current.date(byAdding: .day, value: 45, to: baseDate)!
        let difference = abs(nextDate.timeIntervalSince(expectedDate))
        XCTAssertLessThan(difference, 1)
    }

    func testCalculateNextDueDate_OneTime_ReturnsSameDate() {
        // Given
        let baseDate = Date()
        let task = MaintenanceTask(
            applianceId: UUID(),
            title: "Test Task",
            frequency: .oneTime,
            nextDueDate: baseDate
        )

        // When
        let nextDate = task.calculateNextDueDate(from: baseDate)

        // Then
        XCTAssertEqual(nextDate, baseDate)
    }

    // MARK: - Frequency Tests

    func testMaintenanceFrequency_DisplayNames() {
        XCTAssertEqual(MaintenanceFrequency.weekly.displayName, "Weekly")
        XCTAssertEqual(MaintenanceFrequency.monthly.displayName, "Monthly")
        XCTAssertEqual(MaintenanceFrequency.quarterly.displayName, "Quarterly")
        XCTAssertEqual(MaintenanceFrequency.annually.displayName, "Annually")
        XCTAssertEqual(MaintenanceFrequency.oneTime.displayName, "One-time")
        XCTAssertEqual(MaintenanceFrequency.custom(days: 30).displayName, "Every 30 days")
    }

    func testMaintenanceFrequency_Icons() {
        XCTAssertEqual(MaintenanceFrequency.weekly.icon, "calendar.badge.clock")
        XCTAssertEqual(MaintenanceFrequency.monthly.icon, "calendar")
        XCTAssertEqual(MaintenanceFrequency.annually.icon, "calendar.circle")
        XCTAssertEqual(MaintenanceFrequency.oneTime.icon, "calendar.badge.checkmark")
    }

    // MARK: - Priority Tests

    func testTaskPriority_DisplayNames() {
        XCTAssertEqual(TaskPriority.low.displayName, "Low")
        XCTAssertEqual(TaskPriority.medium.displayName, "Medium")
        XCTAssertEqual(TaskPriority.high.displayName, "High")
        XCTAssertEqual(TaskPriority.critical.displayName, "Critical")
    }

    func testTaskPriority_Colors() {
        XCTAssertEqual(TaskPriority.low.color, "gray")
        XCTAssertEqual(TaskPriority.medium.color, "blue")
        XCTAssertEqual(TaskPriority.high.color, "orange")
        XCTAssertEqual(TaskPriority.critical.color, "red")
    }

    // MARK: - Service Type Tests

    func testServiceType_AllCases() {
        let allTypes = ServiceType.allCases
        XCTAssertEqual(allTypes.count, 8)
        XCTAssertTrue(allTypes.contains(.routine))
        XCTAssertTrue(allTypes.contains(.repair))
        XCTAssertTrue(allTypes.contains(.inspection))
    }

    func testServiceType_Icons() {
        XCTAssertEqual(ServiceType.routine.icon, "calendar.badge.checkmark")
        XCTAssertEqual(ServiceType.repair.icon, "wrench.and.screwdriver")
        XCTAssertEqual(ServiceType.inspection.icon, "magnifyingglass")
        XCTAssertEqual(ServiceType.emergency.icon, "exclamationmark.triangle.fill")
    }

    // MARK: - Codable Tests

    func testMaintenanceTask_Codable() throws {
        // Given
        let task = MaintenanceTask(
            applianceId: UUID(),
            title: "Test Task",
            taskDescription: "Description",
            frequency: .monthly,
            nextDueDate: Date(),
            priority: .high
        )

        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(task)
        let decoder = JSONDecoder()
        let decodedTask = try decoder.decode(MaintenanceTask.self, from: data)

        // Then
        XCTAssertEqual(task.id, decodedTask.id)
        XCTAssertEqual(task.title, decodedTask.title)
        XCTAssertEqual(task.taskDescription, decodedTask.taskDescription)
        XCTAssertEqual(task.priority, decodedTask.priority)
    }

    func testServiceHistory_Codable() throws {
        // Given
        let history = ServiceHistory(
            applianceId: UUID(),
            serviceDate: Date(),
            serviceType: .repair,
            technicianName: "John Doe",
            company: "ACME Repair",
            cost: 150.00,
            partsReplaced: ["Part 1", "Part 2"]
        )

        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(history)
        let decoder = JSONDecoder()
        let decodedHistory = try decoder.decode(ServiceHistory.self, from: data)

        // Then
        XCTAssertEqual(history.id, decodedHistory.id)
        XCTAssertEqual(history.serviceType, decodedHistory.serviceType)
        XCTAssertEqual(history.technicianName, decodedHistory.technicianName)
        XCTAssertEqual(history.cost, decodedHistory.cost)
        XCTAssertEqual(history.partsReplaced, decodedHistory.partsReplaced)
    }
}
