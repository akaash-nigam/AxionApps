import Foundation
import SwiftData
import simd

// MARK: - Employee Model
@Model
final class Employee {
    // MARK: - Identity
    @Attribute(.unique) var id: UUID
    var employeeNumber: String

    // MARK: - Personal Information
    var firstName: String
    var lastName: String
    var preferredName: String?
    var email: String
    var phoneNumber: String?
    var pronouns: String?
    var birthday: Date?
    var photoURL: URL?

    // MARK: - Job Information
    var title: String
    var level: JobLevel
    var departmentName: String
    var location: String
    var employmentType: EmploymentType
    var hireDate: Date
    var salary: Decimal?

    // MARK: - Relationships
    @Relationship(deleteRule: .nullify, inverse: \Employee.directReports)
    var manager: Employee?

    @Relationship(deleteRule: .nullify)
    var directReports: [Employee] = []

    @Relationship(deleteRule: .nullify)
    var team: Team?

    @Relationship(deleteRule: .nullify)
    var department: Department?

    // MARK: - Performance & Engagement
    @Relationship(deleteRule: .cascade)
    var performance: PerformanceData?

    @Relationship(deleteRule: .cascade)
    var skills: [Skill] = []

    @Relationship(deleteRule: .cascade)
    var goals: [Goal] = []

    @Relationship(deleteRule: .cascade)
    var achievements: [Achievement] = []

    var engagementScore: Double = 0.0 // 0-100
    var wellbeingScore: Double = 0.0 // 0-100

    // MARK: - AI Predictions
    var flightRiskScore: Double = 0.0 // 0-100
    var potentialScore: Double = 0.0 // 0-100

    // MARK: - Spatial Visualization
    var spatialPositionX: Float = 0.0
    var spatialPositionY: Float = 0.0
    var spatialPositionZ: Float = 0.0

    var visualColor: String = "#4A90E2" // Hex color for department

    // MARK: - Privacy & Access Control
    var privacyLevel: PrivacyLevel = .internal
    var isActive: Bool = true

    // MARK: - Timestamps
    var createdAt: Date
    var updatedAt: Date
    var lastSyncedAt: Date?

    // MARK: - Initialization
    init(
        id: UUID = UUID(),
        employeeNumber: String,
        firstName: String,
        lastName: String,
        email: String,
        title: String,
        level: JobLevel = .individual,
        departmentName: String,
        location: String,
        employmentType: EmploymentType = .fullTime,
        hireDate: Date
    ) {
        self.id = id
        self.employeeNumber = employeeNumber
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.title = title
        self.level = level
        self.departmentName = departmentName
        self.location = location
        self.employmentType = employmentType
        self.hireDate = hireDate
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Computed Properties
    var fullName: String {
        "\(firstName) \(lastName)"
    }

    var displayName: String {
        preferredName ?? firstName
    }

    var tenure: TimeInterval {
        Date().timeIntervalSince(hireDate)
    }

    var tenureYears: Double {
        tenure / (365.25 * 24 * 60 * 60)
    }

    var spatialPosition: SIMD3<Float> {
        get { SIMD3<Float>(spatialPositionX, spatialPositionY, spatialPositionZ) }
        set {
            spatialPositionX = newValue.x
            spatialPositionY = newValue.y
            spatialPositionZ = newValue.z
        }
    }

    var performanceRating: Double {
        performance?.currentRating ?? 0.0
    }

    var isHighPotential: Bool {
        potentialScore >= 80.0
    }

    var isFlightRisk: Bool {
        flightRiskScore >= 70.0
    }

    var isNewHire: Bool {
        let threeMonths: TimeInterval = 90 * 24 * 60 * 60
        return tenure < threeMonths
    }
}

// MARK: - Job Level
enum JobLevel: String, Codable {
    case individual = "Individual Contributor"
    case seniorIndividual = "Senior Individual Contributor"
    case lead = "Lead"
    case manager = "Manager"
    case seniorManager = "Senior Manager"
    case director = "Director"
    case seniorDirector = "Senior Director"
    case vp = "Vice President"
    case svp = "Senior Vice President"
    case cLevel = "C-Level Executive"
}

// MARK: - Employment Type
enum EmploymentType: String, Codable {
    case fullTime = "Full-Time"
    case partTime = "Part-Time"
    case contract = "Contract"
    case intern = "Intern"
    case consultant = "Consultant"
}

// MARK: - Privacy Level
enum PrivacyLevel: String, Codable {
    case `public` = "Public"
    case `internal` = "Internal"
    case confidential = "Confidential"
    case restricted = "Restricted"
}

// MARK: - User (for authentication)
struct User: Codable, Identifiable {
    let id: UUID
    let employeeId: UUID
    let email: String
    let firstName: String
    let lastName: String
    let role: UserRole
    let permissions: Set<Permission>

    var fullName: String {
        "\(firstName) \(lastName)"
    }
}

// MARK: - User Role
enum UserRole: String, Codable {
    case employee
    case manager
    case hrBusinessPartner
    case hrAdmin
    case chro
    case systemAdmin
}

// MARK: - Permission
enum Permission: String, Codable, Hashable {
    case viewOwnProfile
    case viewTeamMembers
    case viewAllEmployees
    case editEmployeeData
    case viewCompensation
    case editCompensation
    case viewAnalytics
    case manageOrganization
    case systemConfiguration
}
