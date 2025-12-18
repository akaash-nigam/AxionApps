import Foundation
import SwiftData

// MARK: - Employee
@Model
final class Employee {
    @Attribute(.unique) var id: UUID
    var employeeNumber: String
    var firstName: String
    var lastName: String
    var email: String
    var phone: String?
    var jobTitle: String
    var hireDate: Date
    var status: EmployeeStatus
    var salary: Decimal?

    @Relationship(deleteRule: .nullify) var department: Department?
    @Relationship(deleteRule: .nullify) var manager: Employee?
    @Relationship(inverse: \Employee.manager) var directReports: [Employee]

    // Computed properties
    var fullName: String {
        "\(firstName) \(lastName)"
    }

    var yearsOfService: Int {
        let calendar = Calendar.current
        return calendar.dateComponents([.year], from: hireDate, to: Date()).year ?? 0
    }

    init(
        id: UUID = UUID(),
        employeeNumber: String,
        firstName: String,
        lastName: String,
        email: String,
        phone: String? = nil,
        jobTitle: String,
        hireDate: Date,
        status: EmployeeStatus = .active,
        salary: Decimal? = nil
    ) {
        self.id = id
        self.employeeNumber = employeeNumber
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phone = phone
        self.jobTitle = jobTitle
        self.hireDate = hireDate
        self.status = status
        self.salary = salary
        self.directReports = []
    }

    static func mock() -> Employee {
        Employee(
            employeeNumber: "EMP-001",
            firstName: "John",
            lastName: "Smith",
            email: "john.smith@company.com",
            phone: "+1-555-0123",
            jobTitle: "Operations Manager",
            hireDate: Date().addingTimeInterval(-86400 * 365 * 5), // 5 years ago
            status: .active,
            salary: Decimal(95000)
        )
    }
}

enum EmployeeStatus: String, Codable {
    case active = "Active"
    case onLeave = "On Leave"
    case terminated = "Terminated"
    case retired = "Retired"
}

// MARK: - Department
@Model
final class Department {
    @Attribute(.unique) var id: UUID
    var code: String
    var name: String
    var description: String?
    var managerName: String?
    var budget: Decimal?
    var headcount: Int = 0

    @Relationship(inverse: \Employee.department) var employees: [Employee]
    @Relationship(deleteRule: .nullify) var parentDepartment: Department?
    @Relationship(inverse: \Department.parentDepartment) var subDepartments: [Department]

    // Spatial properties for org chart visualization
    var spatialPositionX: Float?
    var spatialPositionY: Float?
    var spatialPositionZ: Float?

    init(
        id: UUID = UUID(),
        code: String,
        name: String,
        description: String? = nil,
        managerName: String? = nil,
        budget: Decimal? = nil,
        headcount: Int = 0
    ) {
        self.id = id
        self.code = code
        self.name = name
        self.description = description
        self.managerName = managerName
        self.budget = budget
        self.headcount = headcount
        self.employees = []
        self.subDepartments = []
    }

    static func mock() -> Department {
        Department(
            code: "OPS",
            name: "Operations",
            description: "Manufacturing and Operations",
            managerName: "John Smith",
            budget: Decimal(5000000),
            headcount: 125
        )
    }
}

// MARK: - Location
@Model
final class Location {
    @Attribute(.unique) var id: UUID
    var code: String
    var name: String
    var type: LocationType
    var address: String
    var city: String
    var state: String?
    var country: String
    var postalCode: String
    var latitude: Double?
    var longitude: Double?
    var isActive: Bool
    var capacity: Int?

    // Spatial properties
    var spatialPositionX: Float?
    var spatialPositionY: Float?
    var spatialPositionZ: Float?

    init(
        id: UUID = UUID(),
        code: String,
        name: String,
        type: LocationType,
        address: String,
        city: String,
        state: String? = nil,
        country: String,
        postalCode: String,
        latitude: Double? = nil,
        longitude: Double? = nil,
        isActive: Bool = true,
        capacity: Int? = nil
    ) {
        self.id = id
        self.code = code
        self.name = name
        self.type = type
        self.address = address
        self.city = city
        self.state = state
        self.country = country
        self.postalCode = postalCode
        self.latitude = latitude
        self.longitude = longitude
        self.isActive = isActive
        self.capacity = capacity
    }

    static func mock() -> Location {
        Location(
            code: "LOC-HQ",
            name: "Headquarters",
            type: .office,
            address: "123 Business Pkwy",
            city: "New York",
            state: "NY",
            country: "USA",
            postalCode: "10001",
            latitude: 40.7128,
            longitude: -74.0060,
            isActive: true,
            capacity: 500
        )
    }
}

enum LocationType: String, Codable {
    case office = "Office"
    case warehouse = "Warehouse"
    case factory = "Factory"
    case distributionCenter = "Distribution Center"
    case retailStore = "Retail Store"
}

// MARK: - KPI Dashboard Supporting Types
struct KPIDashboard: Codable {
    let timestamp: Date
    let financial: FinancialKPIs
    let operations: OperationalKPIs
    let supplyChain: SupplyChainKPIs
}

struct KPIUpdate: Codable {
    let metricType: MetricType
    let value: Double
    let timestamp: Date
    let trend: TrendDirection

    enum MetricType: String, Codable {
        case revenue, profit, orders, inventory
        case production, quality, efficiency
        case fillRate, deliveryPerformance
    }

    enum TrendDirection: String, Codable {
        case up, down, stable
    }
}
