//
//  DepartmentViewModel.swift
//  BusinessOperatingSystem
//
//  Created by BOS Team on 2025-01-20.
//

import Foundation
import Observation

@MainActor
@Observable
final class DepartmentViewModel {
    // MARK: - Published State

    var department: Department?
    var employees: [Employee] = []
    var kpis: [KPI] = []
    var projects: [Project] = []

    var isLoading: Bool = false
    var error: Error?

    // MARK: - Dependencies

    private let departmentID: Department.ID
    private let repository: BusinessDataRepository
    private let analytics: AnalyticsService

    // MARK: - Initialization

    init(departmentID: Department.ID,
         repository: BusinessDataRepository,
         analytics: AnalyticsService) {
        self.departmentID = departmentID
        self.repository = repository
        self.analytics = analytics
    }

    // MARK: - Public Methods

    @MainActor
    func loadDepartment() async {
        isLoading = true
        error = nil

        do {
            // Track analytics
            await analytics.trackEvent(.departmentSelected(departmentID))

            // Load department data
            async let deptTask = repository.fetchDepartment(id: departmentID)
            async let kpisTask = repository.fetchKPIs(for: departmentID)
            async let employeesTask = repository.fetchEmployees(for: departmentID)

            let (dept, fetchedKPIs, fetchedEmployees) = try await (deptTask, kpisTask, employeesTask)

            department = dept
            kpis = fetchedKPIs
            employees = fetchedEmployees
            projects = generateMockProjects()

            isLoading = false
        } catch {
            self.error = error
            isLoading = false
            print("Error loading department: \(error)")
        }
    }

    @MainActor
    func refresh() async {
        await loadDepartment()
    }

    // MARK: - Computed Properties

    var budgetUtilization: Double {
        guard let dept = department else { return 0 }
        return dept.budget.utilizationPercent
    }

    var budgetStatus: BudgetStatus {
        let utilization = budgetUtilization
        switch utilization {
        case 0..<70:
            return .underUtilized
        case 70..<85:
            return .healthy
        case 85..<100:
            return .nearLimit
        default:
            return .overBudget
        }
    }

    var teamSize: Int {
        department?.headcount ?? 0
    }

    var activeEmployees: [Employee] {
        employees.filter { $0.status == .active }
    }

    var criticalKPIs: [KPI] {
        kpis.filter { $0.performanceStatus == .critical || $0.performanceStatus == .belowTarget }
    }

    // MARK: - Private Methods

    private func generateMockProjects() -> [Project] {
        [
            Project(
                id: UUID(),
                name: "Cloud Migration",
                status: .inProgress,
                progress: 0.67,
                dueDate: Date().addingTimeInterval(86400 * 30)
            ),
            Project(
                id: UUID(),
                name: "Mobile App v2",
                status: .planning,
                progress: 0.15,
                dueDate: Date().addingTimeInterval(86400 * 60)
            ),
            Project(
                id: UUID(),
                name: "Security Audit",
                status: .onHold,
                progress: 0.40,
                dueDate: Date().addingTimeInterval(86400 * 45)
            )
        ]
    }
}

// MARK: - Supporting Types

struct Project: Identifiable {
    let id: UUID
    var name: String
    var status: ProjectStatus
    var progress: Double
    var dueDate: Date

    enum ProjectStatus: String {
        case planning = "Planning"
        case inProgress = "In Progress"
        case onHold = "On Hold"
        case completed = "Completed"

        var color: String {
            switch self {
            case .planning: return "#5AC8FA"
            case .inProgress: return "#007AFF"
            case .onHold: return "#FF9500"
            case .completed: return "#34C759"
            }
        }
    }
}

enum BudgetStatus {
    case underUtilized
    case healthy
    case nearLimit
    case overBudget

    var color: String {
        switch self {
        case .underUtilized: return "#5AC8FA"
        case .healthy: return "#34C759"
        case .nearLimit: return "#FF9500"
        case .overBudget: return "#FF3B30"
        }
    }

    var description: String {
        switch self {
        case .underUtilized: return "Under-utilized"
        case .healthy: return "Healthy"
        case .nearLimit: return "Near Limit"
        case .overBudget: return "Over Budget"
        }
    }
}
