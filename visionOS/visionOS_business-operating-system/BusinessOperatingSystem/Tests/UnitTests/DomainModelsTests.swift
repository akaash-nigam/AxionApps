//
//  DomainModelsTests.swift
//  BusinessOperatingSystemTests
//
//  Created by BOS Team on 2025-01-20.
//

import XCTest
@testable import BusinessOperatingSystem

final class DomainModelsTests: XCTestCase {
    // MARK: - Organization Tests

    func testOrganizationCreation() {
        // Given
        let org = Organization.mock()

        // Then
        XCTAssertNotNil(org.id)
        XCTAssertEqual(org.name, "Acme Corporation")
        XCTAssertEqual(org.structure, .hierarchical)
        XCTAssertFalse(org.departments.isEmpty)
    }

    // MARK: - Department Tests

    func testDepartmentCreation() {
        // Given
        let dept = Department.mock(name: "Engineering", type: .engineering)

        // Then
        XCTAssertNotNil(dept.id)
        XCTAssertEqual(dept.name, "Engineering")
        XCTAssertEqual(dept.type, .engineering)
        XCTAssertEqual(dept.headcount, 125)
    }

    func testDepartmentBudgetCalculations() {
        // Given
        let dept = Department.mock()

        // Then
        XCTAssertGreaterThan(dept.budget.allocated, 0)
        XCTAssertGreaterThan(dept.budget.spent, 0)
        XCTAssertLessThanOrEqual(dept.budget.spent, dept.budget.allocated)

        let expectedRemaining = dept.budget.allocated - dept.budget.spent
        XCTAssertEqual(dept.budget.remaining, expectedRemaining)

        let expectedUtilization = Double(truncating: (dept.budget.spent / dept.budget.allocated) as NSDecimalNumber) * 100
        XCTAssertEqual(dept.budget.utilizationPercent, expectedUtilization, accuracy: 0.01)
    }

    func testDepartmentDefaultColor() {
        // Given/When/Then
        XCTAssertEqual(Department.DepartmentType.engineering.defaultColor, "#5AC8FA")
        XCTAssertEqual(Department.DepartmentType.sales.defaultColor, "#007AFF")
        XCTAssertEqual(Department.DepartmentType.finance.defaultColor, "#00D084")
        XCTAssertEqual(Department.DepartmentType.marketing.defaultColor, "#AF52DE")
    }

    // MARK: - KPI Tests

    func testKPICreation() {
        // Given
        let kpi = KPI.mock(name: "Revenue", value: 1_250_000)

        // Then
        XCTAssertNotNil(kpi.id)
        XCTAssertEqual(kpi.name, "Revenue")
        XCTAssertEqual(kpi.value, 1_250_000)
        XCTAssertEqual(kpi.target, 1_500_000)
    }

    func testKPIPerformanceCalculation() {
        // Given
        let kpi = KPI.mock(name: "Revenue", value: 1_350_000)

        // When
        let performance = kpi.performance

        // Then
        let expected = 1_350_000.0 / 1_500_000.0
        XCTAssertEqual(performance, expected, accuracy: 0.001)
    }

    func testKPIPerformanceStatus() {
        // Test exceeding
        var kpi = KPI.mock(name: "Test", value: 1_650_000)  // 110% of 1.5M
        XCTAssertEqual(kpi.performanceStatus, .exceeding)

        // Test on track
        kpi = KPI.mock(name: "Test", value: 1_500_000)  // 100% of 1.5M
        XCTAssertEqual(kpi.performanceStatus, .onTrack)

        // Test below target
        kpi = KPI.mock(name: "Test", value: 1_200_000)  // 80% of 1.5M
        XCTAssertEqual(kpi.performanceStatus, .belowTarget)

        // Test critical
        kpi = KPI.mock(name: "Test", value: 900_000)  // 60% of 1.5M
        XCTAssertEqual(kpi.performanceStatus, .critical)
    }

    func testKPIPerformanceStatusColors() {
        // Given/When/Then
        XCTAssertEqual(KPI.PerformanceStatus.exceeding.color, "#34C759")
        XCTAssertEqual(KPI.PerformanceStatus.onTrack.color, "#007AFF")
        XCTAssertEqual(KPI.PerformanceStatus.belowTarget.color, "#FF9500")
        XCTAssertEqual(KPI.PerformanceStatus.critical.color, "#FF3B30")
    }

    // MARK: - Employee Tests

    func testEmployeeCreation() {
        // Given
        let employee = Employee.mock()

        // Then
        XCTAssertNotNil(employee.id)
        XCTAssertEqual(employee.name, "Jane Doe")
        XCTAssertEqual(employee.email, "jane.doe@acme.com")
        XCTAssertEqual(employee.title, "Senior Engineer")
        XCTAssertEqual(employee.status, .active)
    }

    func testEmployeeAvailabilityStatusColors() {
        // Given/When/Then
        XCTAssertEqual(Employee.AvailabilityStatus.available.color, "#34C759")
        XCTAssertEqual(Employee.AvailabilityStatus.busy.color, "#FFCC00")
        XCTAssertEqual(Employee.AvailabilityStatus.offline.color, "#8E8E93")
        XCTAssertEqual(Employee.AvailabilityStatus.inMeeting.color, "#007AFF")
    }

    // MARK: - Budget Tests

    func testBudgetRemaining() {
        // Given
        let budget = Budget(allocated: 1_000_000, spent: 600_000)

        // When
        let remaining = budget.remaining

        // Then
        XCTAssertEqual(remaining, 400_000)
    }

    func testBudgetUtilization() {
        // Given
        let budget = Budget(allocated: 1_000_000, spent: 750_000)

        // When
        let utilization = budget.utilizationPercent

        // Then
        XCTAssertEqual(utilization, 75.0, accuracy: 0.01)
    }

    func testBudgetUtilizationZeroAllocated() {
        // Given
        let budget = Budget(allocated: 0, spent: 0)

        // When
        let utilization = budget.utilizationPercent

        // Then
        XCTAssertEqual(utilization, 0.0)
    }

    // MARK: - Codable Tests

    func testOrganizationCodable() throws {
        // Given
        let org = Organization.mock()

        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(org)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Organization.self, from: data)

        // Then
        XCTAssertEqual(org.id, decoded.id)
        XCTAssertEqual(org.name, decoded.name)
        XCTAssertEqual(org.structure, decoded.structure)
    }

    func testDepartmentCodable() throws {
        // Given
        let dept = Department.mock()

        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(dept)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Department.self, from: data)

        // Then
        XCTAssertEqual(dept.id, decoded.id)
        XCTAssertEqual(dept.name, decoded.name)
        XCTAssertEqual(dept.type, decoded.type)
        XCTAssertEqual(dept.headcount, decoded.headcount)
    }

    func testKPICodable() throws {
        // Given
        let kpi = KPI.mock()

        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(kpi)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(KPI.self, from: data)

        // Then
        XCTAssertEqual(kpi.id, decoded.id)
        XCTAssertEqual(kpi.name, decoded.name)
        XCTAssertEqual(kpi.value, decoded.value)
        XCTAssertEqual(kpi.target, decoded.target)
    }

    // MARK: - Hashable Tests

    func testDepartmentHashable() {
        // Given
        let dept1 = Department.mock(name: "Engineering", type: .engineering)
        let dept2 = Department.mock(name: "Sales", type: .sales)
        let dept3 = dept1

        // When
        let set: Set<Department> = [dept1, dept2, dept3]

        // Then
        XCTAssertEqual(set.count, 2)  // dept1 and dept3 are same instance
    }

    func testKPIHashable() {
        // Given
        let kpi1 = KPI.mock(name: "Revenue", value: 1_000_000)
        let kpi2 = KPI.mock(name: "Profit", value: 200_000)
        let kpi3 = kpi1

        // When
        let set: Set<KPI> = [kpi1, kpi2, kpi3]

        // Then
        XCTAssertEqual(set.count, 2)
    }
}
