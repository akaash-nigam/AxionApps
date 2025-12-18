import Foundation
import SwiftUI
import simd

// MARK: - Organization State
@Observable
final class OrganizationState {
    // MARK: - Data
    var employees: [Employee] = []
    var departments: [Department] = []
    var teams: [Team] = []

    // MARK: - Loading State
    var isLoading: Bool = false
    var error: Error?

    // MARK: - Filtering
    var filterCriteria: EmployeeFilter?
    var searchQuery: String = ""

    // MARK: - Selection
    var selectedEmployee: Employee?
    var selectedDepartment: Department?
    var selectedTeam: Team?

    // MARK: - Visualization
    var visualizationMode: VisualizationMode = .galaxy
    var showConnections: Bool = true
    var highlightedNodeIds: Set<UUID> = []

    // MARK: - Spatial State
    var cameraPosition: SIMD3<Float> = [0, 0, 2]
    var selectedNodeId: UUID?
    var hoveredNodeId: UUID?

    // MARK: - Computed Properties
    var filteredEmployees: [Employee] {
        var filtered = employees

        if !searchQuery.isEmpty {
            filtered = filtered.filter { employee in
                employee.fullName.localizedCaseInsensitiveContains(searchQuery) ||
                employee.title.localizedCaseInsensitiveContains(searchQuery)
            }
        }

        if let departmentId = filterCriteria?.departmentId {
            filtered = filtered.filter { $0.department?.id == departmentId }
        }

        if let teamId = filterCriteria?.teamId {
            filtered = filtered.filter { $0.team?.id == teamId }
        }

        return filtered
    }

    var employeeCount: Int {
        employees.count
    }

    var departmentCount: Int {
        departments.count
    }

    var avgEngagement: Double {
        guard !employees.isEmpty else { return 0.0 }
        return employees.map(\.engagementScore).reduce(0, +) / Double(employees.count)
    }

    var avgPerformance: Double {
        guard !employees.isEmpty else { return 0.0 }
        return employees.map(\.performanceRating).reduce(0, +) / Double(employees.count)
    }

    var flightRisks: [Employee] {
        employees.filter { $0.isFlightRisk }
    }

    var highPotential: [Employee] {
        employees.filter { $0.isHighPotential }
    }

    var newHires: [Employee] {
        employees.filter { $0.isNewHire }
    }

    // MARK: - Methods
    @MainActor
    func loadOrganization(using hrService: HRDataService) async {
        isLoading = true
        error = nil

        do {
            async let employeesTask = hrService.fetchEmployees()
            async let departmentsTask = hrService.fetchDepartments()
            async let teamsTask = hrService.fetchTeams()

            (employees, departments, teams) = try await (employeesTask, departmentsTask, teamsTask)

            print("✅ Loaded \(employees.count) employees, \(departments.count) departments, \(teams.count) teams")
        } catch {
            self.error = error
            print("❌ Failed to load organization: \(error)")
        }

        isLoading = false
    }

    func selectEmployee(_ employee: Employee) {
        selectedEmployee = employee
        selectedNodeId = employee.id
    }

    func clearSelection() {
        selectedEmployee = nil
        selectedNodeId = nil
    }

    func applyFilter(_ filter: EmployeeFilter) {
        filterCriteria = filter
    }

    func clearFilter() {
        filterCriteria = nil
        searchQuery = ""
    }
}

// MARK: - Visualization Mode
enum VisualizationMode: String, CaseIterable {
    case galaxy = "Organizational Galaxy"
    case hierarchy = "Hierarchy Tree"
    case network = "Network Graph"
    case landscape = "Talent Landscape"

    var icon: String {
        switch self {
        case .galaxy: return "sparkles"
        case .hierarchy: return "chart.tree"
        case .network: return "network"
        case .landscape: return "mountain.2.fill"
        }
    }
}
