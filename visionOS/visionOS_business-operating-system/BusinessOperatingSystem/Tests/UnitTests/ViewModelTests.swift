//
//  ViewModelTests.swift
//  BusinessOperatingSystemTests
//
//  Created by BOS Team on 2025-01-20.
//

import XCTest
@testable import BusinessOperatingSystem

@MainActor
final class ViewModelTests: XCTestCase {
    var mockRepository: MockBusinessRepository!
    var mockAnalytics: MockAnalyticsService!

    override func setUp() async throws {
        mockRepository = MockBusinessRepository()
        mockAnalytics = MockAnalyticsService()
    }

    override func tearDown() async throws {
        mockRepository = nil
        mockAnalytics = nil
    }

    // MARK: - DashboardViewModel Tests

    func testDashboardViewModelInitialization() {
        // Given/When
        let viewModel = DashboardViewModel(
            repository: mockRepository,
            analytics: mockAnalytics
        )

        // Then
        XCTAssertNil(viewModel.organization)
        XCTAssertTrue(viewModel.departments.isEmpty)
        XCTAssertTrue(viewModel.kpis.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
    }

    func testDashboardViewModelLoadSuccess() async {
        // Given
        let viewModel = DashboardViewModel(
            repository: mockRepository,
            analytics: mockAnalytics
        )

        mockRepository.organizationToReturn = .mock()
        mockRepository.departmentsToReturn = [
            .mock(name: "Engineering", type: .engineering),
            .mock(name: "Sales", type: .sales)
        ]
        mockRepository.kpisToReturn = [
            .mock(name: "Revenue", value: 1_000_000)
        ]

        // When
        await viewModel.loadDashboard()

        // Then
        XCTAssertNotNil(viewModel.organization)
        XCTAssertEqual(viewModel.departments.count, 2)
        XCTAssertGreaterThan(viewModel.kpis.count, 0)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
        XCTAssertNotNil(viewModel.lastRefreshed)

        // Verify analytics was called
        XCTAssertTrue(mockAnalytics.screenViewsCalled.contains("Dashboard"))
    }

    func testDashboardViewModelLoadFailure() async {
        // Given
        let viewModel = DashboardViewModel(
            repository: mockRepository,
            analytics: mockAnalytics
        )

        mockRepository.shouldFail = true

        // When
        await viewModel.loadDashboard()

        // Then
        XCTAssertNil(viewModel.organization)
        XCTAssertTrue(viewModel.departments.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.error)
    }

    func testDashboardViewModelRefresh() async {
        // Given
        let viewModel = DashboardViewModel(
            repository: mockRepository,
            analytics: mockAnalytics
        )

        mockRepository.organizationToReturn = .mock()
        mockRepository.departmentsToReturn = [.mock()]
        mockRepository.kpisToReturn = [.mock()]

        await viewModel.loadDashboard()
        let firstRefresh = viewModel.lastRefreshed

        // Wait a bit
        try? await Task.sleep(for: .milliseconds(100))

        // When
        await viewModel.refresh()

        // Then
        XCTAssertNotNil(viewModel.lastRefreshed)
        if let first = firstRefresh, let second = viewModel.lastRefreshed {
            XCTAssertGreaterThan(second, first)
        }
    }

    func testDashboardViewModelKPISorting() async {
        // Given
        let viewModel = DashboardViewModel(
            repository: mockRepository,
            analytics: mockAnalytics
        )

        mockRepository.organizationToReturn = .mock()
        mockRepository.departmentsToReturn = [.mock()]
        mockRepository.kpisToReturn = [
            KPI.mock(name: "Good KPI", value: 1_600_000),      // Exceeding
            KPI.mock(name: "Critical KPI", value: 900_000),     // Critical
            KPI.mock(name: "On Track KPI", value: 1_450_000),  // On Track
            KPI.mock(name: "Below Target KPI", value: 1_200_000) // Below Target
        ]

        // When
        await viewModel.loadDashboard()

        // Then
        XCTAssertEqual(viewModel.kpis.count, 4)
        // Critical should be first (highest priority)
        XCTAssertEqual(viewModel.kpis.first?.performanceStatus, .critical)
        // Exceeding should be last (lowest priority)
        XCTAssertEqual(viewModel.kpis.last?.performanceStatus, .exceeding)
    }

    // MARK: - DepartmentViewModel Tests

    func testDepartmentViewModelInitialization() {
        // Given
        let departmentID = UUID()

        // When
        let viewModel = DepartmentViewModel(
            departmentID: departmentID,
            repository: mockRepository,
            analytics: mockAnalytics
        )

        // Then
        XCTAssertNil(viewModel.department)
        XCTAssertTrue(viewModel.employees.isEmpty)
        XCTAssertTrue(viewModel.kpis.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testDepartmentViewModelLoadSuccess() async {
        // Given
        let departmentID = UUID()
        let viewModel = DepartmentViewModel(
            departmentID: departmentID,
            repository: mockRepository,
            analytics: mockAnalytics
        )

        let mockDept = Department.mock()
        mockRepository.departmentToReturn = mockDept
        mockRepository.kpisToReturn = [.mock()]
        mockRepository.employeesToReturn = [.mock(), .mock(), .mock()]

        // When
        await viewModel.loadDepartment()

        // Then
        XCTAssertNotNil(viewModel.department)
        XCTAssertEqual(viewModel.kpis.count, 1)
        XCTAssertEqual(viewModel.employees.count, 3)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
    }

    func testDepartmentViewModelBudgetStatus() async {
        // Given
        let departmentID = UUID()
        let viewModel = DepartmentViewModel(
            departmentID: departmentID,
            repository: mockRepository,
            analytics: mockAnalytics
        )

        // Test Under-utilized (60%)
        var dept = Department.mock()
        dept.budget = Budget(allocated: 1_000_000, spent: 600_000)
        mockRepository.departmentToReturn = dept
        await viewModel.loadDepartment()
        XCTAssertEqual(viewModel.budgetStatus, .underUtilized)

        // Test Healthy (75%)
        dept.budget = Budget(allocated: 1_000_000, spent: 750_000)
        mockRepository.departmentToReturn = dept
        await viewModel.loadDepartment()
        XCTAssertEqual(viewModel.budgetStatus, .healthy)

        // Test Near Limit (90%)
        dept.budget = Budget(allocated: 1_000_000, spent: 900_000)
        mockRepository.departmentToReturn = dept
        await viewModel.loadDepartment()
        XCTAssertEqual(viewModel.budgetStatus, .nearLimit)

        // Test Over Budget (105%)
        dept.budget = Budget(allocated: 1_000_000, spent: 1_050_000)
        mockRepository.departmentToReturn = dept
        await viewModel.loadDepartment()
        XCTAssertEqual(viewModel.budgetStatus, .overBudget)
    }

    func testDepartmentViewModelActiveEmployees() async {
        // Given
        let departmentID = UUID()
        let viewModel = DepartmentViewModel(
            departmentID: departmentID,
            repository: mockRepository,
            analytics: mockAnalytics
        )

        var activeEmp = Employee.mock()
        activeEmp.status = .active

        var onLeaveEmp = Employee.mock()
        onLeaveEmp.status = .onLeave

        var terminatedEmp = Employee.mock()
        terminatedEmp.status = .terminated

        mockRepository.departmentToReturn = .mock()
        mockRepository.employeesToReturn = [activeEmp, onLeaveEmp, terminatedEmp]

        // When
        await viewModel.loadDepartment()

        // Then
        XCTAssertEqual(viewModel.activeEmployees.count, 1)
        XCTAssertEqual(viewModel.activeEmployees.first?.status, .active)
    }

    func testDepartmentViewModelCriticalKPIs() async {
        // Given
        let departmentID = UUID()
        let viewModel = DepartmentViewModel(
            departmentID: departmentID,
            repository: mockRepository,
            analytics: mockAnalytics
        )

        mockRepository.departmentToReturn = .mock()
        mockRepository.kpisToReturn = [
            KPI.mock(name: "Good", value: 1_600_000),      // Exceeding
            KPI.mock(name: "Critical", value: 900_000),    // Critical
            KPI.mock(name: "Below", value: 1_200_000)      // Below Target
        ]

        // When
        await viewModel.loadDepartment()

        // Then
        XCTAssertEqual(viewModel.criticalKPIs.count, 2)  // Critical + Below Target
    }
}

// MARK: - Mock Repository

class MockBusinessRepository: BusinessDataRepository {
    var shouldFail = false
    var organizationToReturn: Organization?
    var departmentsToReturn: [Department] = []
    var departmentToReturn: Department?
    var kpisToReturn: [KPI] = []
    var employeesToReturn: [Employee] = []

    func initialize() async throws {}
    func shutdown() async {}

    func fetchOrganization() async throws -> Organization {
        if shouldFail {
            throw NSError(domain: "Test", code: 1, userInfo: nil)
        }
        return organizationToReturn ?? .mock()
    }

    func fetchDepartments() async throws -> [Department] {
        if shouldFail {
            throw NSError(domain: "Test", code: 1, userInfo: nil)
        }
        return departmentsToReturn
    }

    func fetchDepartment(id: Department.ID) async throws -> Department {
        if shouldFail {
            throw NSError(domain: "Test", code: 1, userInfo: nil)
        }
        return departmentToReturn ?? .mock()
    }

    func fetchKPIs(for departmentID: Department.ID) async throws -> [KPI] {
        if shouldFail {
            throw NSError(domain: "Test", code: 1, userInfo: nil)
        }
        return kpisToReturn
    }

    func fetchEmployees(for departmentID: Department.ID) async throws -> [Employee] {
        if shouldFail {
            throw NSError(domain: "Test", code: 1, userInfo: nil)
        }
        return employeesToReturn
    }

    func observeRealtimeUpdates() -> AsyncStream<BusinessUpdate> {
        AsyncStream { _ in }
    }
}

// MARK: - Mock Analytics

class MockAnalyticsService: AnalyticsService {
    var eventsCalled: [AnalyticsEvent] = []
    var screenViewsCalled: [String] = []

    func initialize() async throws {}
    func shutdown() async {}

    func trackEvent(_ event: AnalyticsEvent) async {
        eventsCalled.append(event)
    }

    func trackScreenView(_ screen: String) async {
        screenViewsCalled.append(screen)
    }
}
