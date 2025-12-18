import Foundation
import SwiftData

// MARK: - HR Data Service Protocol
protocol HRDataServiceProtocol {
    func fetchEmployees(filter: EmployeeFilter?) async throws -> [Employee]
    func getEmployee(id: UUID) async throws -> Employee
    func createEmployee(_ employee: Employee) async throws -> Employee
    func updateEmployee(_ employee: Employee) async throws -> Employee
    func deleteEmployee(id: UUID) async throws
    func searchEmployees(query: String) async throws -> [Employee]

    func fetchDepartments() async throws -> [Department]
    func fetchTeams() async throws -> [Team]
}

// MARK: - HR Data Service
@Observable
final class HRDataService: HRDataServiceProtocol {
    // MARK: - Properties
    private let apiClient: APIClient
    private let cache: CacheManager
    private let useMockData: Bool

    // MARK: - State
    var employees: [Employee] = []
    var departments: [Department] = []
    var teams: [Team] = []
    var isLoading: Bool = false
    var error: Error?

    // MARK: - Initialization
    init(apiClient: APIClient, useMockData: Bool = true) {
        self.apiClient = apiClient
        self.cache = CacheManager()
        self.useMockData = useMockData
    }

    // MARK: - Employee Operations
    func fetchEmployees(filter: EmployeeFilter? = nil) async throws -> [Employee] {
        isLoading = true
        defer { isLoading = false }

        do {
            if useMockData {
                // Return mock data for development
                let mockEmployees = MockDataGenerator.generateEmployees(count: 50)
                self.employees = mockEmployees
                return mockEmployees
            }

            // Check cache first
            if let cached = cache.getEmployees(filter: filter), !cache.isExpired(for: .employees) {
                self.employees = cached
                return cached
            }

            // Fetch from API
            let response: EmployeeListResponse = try await apiClient.get(.employees(filter: filter))
            let fetchedEmployees = response.employees

            // Update cache
            cache.store(fetchedEmployees, for: .employees)
            self.employees = fetchedEmployees

            return fetchedEmployees
        } catch {
            self.error = error
            throw error
        }
    }

    func getEmployee(id: UUID) async throws -> Employee {
        if useMockData {
            if let employee = employees.first(where: { $0.id == id }) {
                return employee
            }
            throw APIError.notFound
        }

        let response: EmployeeResponse = try await apiClient.get(.employee(id: id))
        return response.employee
    }

    func createEmployee(_ employee: Employee) async throws -> Employee {
        if useMockData {
            employees.append(employee)
            return employee
        }

        let response: EmployeeResponse = try await apiClient.post(.createEmployee, body: employee)
        employees.append(response.employee)
        return response.employee
    }

    func updateEmployee(_ employee: Employee) async throws -> Employee {
        if useMockData {
            if let index = employees.firstIndex(where: { $0.id == employee.id }) {
                employees[index] = employee
            }
            return employee
        }

        let response: EmployeeResponse = try await apiClient.put(.updateEmployee(id: employee.id), body: employee)

        if let index = employees.firstIndex(where: { $0.id == employee.id }) {
            employees[index] = response.employee
        }

        return response.employee
    }

    func deleteEmployee(id: UUID) async throws {
        if useMockData {
            employees.removeAll { $0.id == id }
            return
        }

        let _: DeleteResponse = try await apiClient.delete(.deleteEmployee(id: id))
        employees.removeAll { $0.id == id }
    }

    func searchEmployees(query: String) async throws -> [Employee] {
        if useMockData {
            return employees.filter { employee in
                employee.fullName.localizedCaseInsensitiveContains(query) ||
                employee.title.localizedCaseInsensitiveContains(query) ||
                employee.departmentName.localizedCaseInsensitiveContains(query)
            }
        }

        let filter = EmployeeFilter(searchQuery: query)
        return try await fetchEmployees(filter: filter)
    }

    // MARK: - Department Operations
    func fetchDepartments() async throws -> [Department] {
        isLoading = true
        defer { isLoading = false }

        if useMockData {
            let mockDepartments = MockDataGenerator.generateDepartments()
            self.departments = mockDepartments
            return mockDepartments
        }

        let response: DepartmentListResponse = try await apiClient.get(.departments)
        self.departments = response.departments
        return response.departments
    }

    // MARK: - Team Operations
    func fetchTeams() async throws -> [Team] {
        isLoading = true
        defer { isLoading = false }

        if useMockData {
            let mockTeams = MockDataGenerator.generateTeams(departments: departments)
            self.teams = mockTeams
            return mockTeams
        }

        let response: TeamListResponse = try await apiClient.get(.teams)
        self.teams = response.teams
        return response.teams
    }
}

// MARK: - API Response Models
struct EmployeeResponse: Codable {
    let employee: Employee
}

struct EmployeeListResponse: Codable {
    let employees: [Employee]
    let total: Int
}

struct DepartmentListResponse: Codable {
    let departments: [Department]
}

struct TeamListResponse: Codable {
    let teams: [Team]
}

struct DeleteResponse: Codable {
    let success: Bool
}

// MARK: - Cache Manager
actor CacheManager {
    private var cache: [CacheKey: CacheEntry] = [:]

    func getEmployees(filter: EmployeeFilter?) -> [Employee]? {
        let key = CacheKey.employees(filter: filter)
        return cache[key]?.value as? [Employee]
    }

    func store(_ employees: [Employee], for key: CacheKey) {
        cache[key] = CacheEntry(value: employees, expiresAt: Date().addingTimeInterval(300))
    }

    func isExpired(for key: CacheKey) -> Bool {
        guard let entry = cache[key] else { return true }
        return entry.isExpired
    }

    func clear() {
        cache.removeAll()
    }
}

// MARK: - Cache Key
enum CacheKey: Hashable {
    case employees(filter: EmployeeFilter?)
    case employee(id: UUID)
    case departments
    case teams
}

// MARK: - Cache Entry
struct CacheEntry {
    let value: Any
    let expiresAt: Date

    var isExpired: Bool {
        Date() > expiresAt
    }
}

// MARK: - Mock Data Generator
struct MockDataGenerator {
    static func generateEmployees(count: Int) -> [Employee] {
        let firstNames = ["John", "Sarah", "Michael", "Emily", "David", "Jessica", "Robert", "Jennifer", "William", "Linda"]
        let lastNames = ["Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis", "Rodriguez", "Martinez"]
        let titles = ["Software Engineer", "Senior Engineer", "Engineering Manager", "Product Manager", "Designer", "Data Scientist", "HR Manager", "Sales Director"]
        let departments = ["Engineering", "Product", "Design", "Sales", "Marketing", "HR", "Finance", "Operations"]
        let locations = ["San Francisco, CA", "New York, NY", "Austin, TX", "Seattle, WA", "Boston, MA"]

        var employees: [Employee] = []

        for i in 0..<count {
            let firstName = firstNames[i % firstNames.count]
            let lastName = lastNames[(i / firstNames.count) % lastNames.count]
            let title = titles[i % titles.count]
            let department = departments[i % departments.count]
            let location = locations[i % locations.count]

            let employee = Employee(
                employeeNumber: "EMP\(String(format: "%04d", i + 1))",
                firstName: firstName,
                lastName: lastName,
                email: "\(firstName.lowercased()).\(lastName.lowercased())@company.com",
                title: title,
                level: JobLevel.allCases.randomElement() ?? .individual,
                departmentName: department,
                location: location,
                employmentType: .fullTime,
                hireDate: Date().addingTimeInterval(-Double.random(in: 0...1095) * 24 * 60 * 60) // Random hire date in last 3 years
            )

            // Set random metrics
            employee.engagementScore = Double.random(in: 40...95)
            employee.wellbeingScore = Double.random(in: 50...95)
            employee.flightRiskScore = Double.random(in: 5...75)
            employee.potentialScore = Double.random(in: 30...95)

            // Set spatial position (for 3D visualization)
            employee.spatialPosition = SIMD3<Float>(
                Float.random(in: -1...1),
                Float.random(in: -1...1),
                Float.random(in: -1...1)
            )

            employees.append(employee)
        }

        return employees
    }

    static func generateDepartments() -> [Department] {
        let deptData: [(String, String, String)] = [
            ("Engineering", "ENG", "#4A90E2"),
            ("Product", "PRD", "#7B68EE"),
            ("Design", "DES", "#F5A623"),
            ("Sales", "SAL", "#50E3C2"),
            ("Marketing", "MKT", "#E94B3C"),
            ("HR", "HR", "#BD10E0"),
            ("Finance", "FIN", "#417505"),
            ("Operations", "OPS", "#8B572A")
        ]

        return deptData.map { name, code, color in
            let dept = Department(name: name, code: code, description: "\(name) Department")
            dept.colorHex = color
            dept.avgEngagement = Double.random(in: 60...85)
            dept.avgPerformance = Double.random(in: 65...90)
            dept.turnoverRate = Double.random(in: 5...15)
            return dept
        }
    }

    static func generateTeams(departments: [Department]) -> [Team] {
        var teams: [Team] = []

        for department in departments {
            let teamCount = Int.random(in: 2...4)
            for i in 0..<teamCount {
                let team = Team(
                    name: "\(department.name) Team \(i + 1)",
                    description: "Team \(i + 1) in \(department.name)",
                    department: department
                )

                team.cohesionScore = Double.random(in: 60...95)
                team.productivityScore = Double.random(in: 65...90)
                team.innovationScore = Double.random(in: 55...85)
                team.diversityIndex = Double.random(in: 50...90)
                team.collaborationScore = Double.random(in: 60...90)

                teams.append(team)
            }
        }

        return teams
    }
}
