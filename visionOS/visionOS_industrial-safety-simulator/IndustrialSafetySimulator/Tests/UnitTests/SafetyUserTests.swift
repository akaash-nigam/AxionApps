import Testing
import Foundation
@testable import IndustrialSafetySimulator

@Suite("SafetyUser Model Tests")
struct SafetyUserTests {

    // MARK: - Initialization Tests

    @Test("User initializes with correct properties")
    func testUserInitialization() {
        // Arrange
        let name = "John Worker"
        let role = WorkerRole.operator
        let department = "Manufacturing"
        let hireDate = Date()

        // Act
        let user = SafetyUser(
            name: name,
            role: role,
            department: department,
            hireDate: hireDate
        )

        // Assert
        #expect(user.name == name)
        #expect(user.role == role)
        #expect(user.department == department)
        #expect(user.hireDate == hireDate)
        #expect(user.id != UUID(uuidString: "00000000-0000-0000-0000-000000000000"))
    }

    @Test("User initializes with optional email and employee ID")
    func testUserInitializationWithOptionals() {
        // Arrange
        let email = "john.worker@company.com"
        let employeeId = "EMP12345"

        // Act
        let user = SafetyUser(
            name: "John Worker",
            role: .operator,
            department: "Manufacturing",
            hireDate: Date(),
            email: email,
            employeeId: employeeId
        )

        // Assert
        #expect(user.email == email)
        #expect(user.employeeId == employeeId)
    }

    // MARK: - Display Properties Tests

    @Test("Display name returns user name")
    func testDisplayName() {
        // Arrange
        let userName = "Jane Safety"
        let user = SafetyUser(
            name: userName,
            role: .safetyManager,
            department: "Safety",
            hireDate: Date()
        )

        // Act & Assert
        #expect(user.displayName == userName)
    }

    @Test("Role description returns capitalized role")
    func testRoleDescription() {
        // Arrange
        let user = SafetyUser(
            name: "Test User",
            role: .operator,
            department: "Production",
            hireDate: Date()
        )

        // Act & Assert
        #expect(user.roleDescription == "Operator")
    }

    // MARK: - WorkerRole Tests

    @Test("Operator role has correct permissions", arguments: [
        (WorkerRole.operator, [Permission.viewTraining, Permission.completeScenarios]),
        (WorkerRole.supervisor, [Permission.viewTraining, Permission.completeScenarios, Permission.viewTeamMetrics]),
        (WorkerRole.safetyManager, Permission.all)
    ])
    func testRolePermissions(role: WorkerRole, expectedPermissions: Set<Permission>) {
        // Assert
        #expect(role.permissions == expectedPermissions)
    }

    @Test("All worker roles have valid permissions")
    func testAllRolesHavePermissions() {
        let roles: [WorkerRole] = [.operator, .supervisor, .safetyManager, .trainer, .contractor, .visitor]

        for role in roles {
            #expect(role.permissions.count > 0, "Role \(role) should have at least one permission")
        }
    }

    // MARK: - Certification Tests

    @Test("Certification validates expiration correctly")
    func testCertificationValidation() {
        // Arrange
        let validCert = Certification(
            name: "Basic Safety",
            issueDate: Date(),
            expirationDate: Date().addingTimeInterval(365 * 24 * 3600), // 1 year from now
            issuingOrganization: "OSHA"
        )

        let expiredCert = Certification(
            name: "Expired Cert",
            issueDate: Date().addingTimeInterval(-730 * 24 * 3600), // 2 years ago
            expirationDate: Date().addingTimeInterval(-365 * 24 * 3600), // 1 year ago
            issuingOrganization: "OSHA"
        )

        let neverExpiresCert = Certification(
            name: "Lifetime Cert",
            issueDate: Date(),
            expirationDate: nil,
            issuingOrganization: "Company"
        )

        // Assert
        #expect(validCert.isValid == true, "Valid certification should be valid")
        #expect(expiredCert.isValid == false, "Expired certification should be invalid")
        #expect(neverExpiresCert.isValid == true, "Certification without expiration should be valid")
    }

    @Test("Certification initializes with all properties")
    func testCertificationInitialization() {
        // Arrange
        let name = "Fire Safety"
        let issueDate = Date()
        let expirationDate = Date().addingTimeInterval(365 * 24 * 3600)
        let organization = "NFPA"
        let certificateNumber = "FS-12345"

        // Act
        let cert = Certification(
            name: name,
            issueDate: issueDate,
            expirationDate: expirationDate,
            issuingOrganization: organization,
            certificateNumber: certificateNumber
        )

        // Assert
        #expect(cert.name == name)
        #expect(cert.issueDate == issueDate)
        #expect(cert.expirationDate == expirationDate)
        #expect(cert.issuingOrganization == organization)
        #expect(cert.certificateNumber == certificateNumber)
    }

    // MARK: - Edge Cases

    @Test("User with empty name is allowed")
    func testEmptyName() {
        // Act
        let user = SafetyUser(
            name: "",
            role: .operator,
            department: "Test",
            hireDate: Date()
        )

        // Assert
        #expect(user.name == "")
    }

    @Test("User hire date can be in the past")
    func testPastHireDate() {
        // Arrange
        let pastDate = Date().addingTimeInterval(-365 * 24 * 3600) // 1 year ago

        // Act
        let user = SafetyUser(
            name: "Veteran Worker",
            role: .operator,
            department: "Production",
            hireDate: pastDate
        )

        // Assert
        #expect(user.hireDate == pastDate)
    }

    @Test("User can have future hire date")
    func testFutureHireDate() {
        // Arrange
        let futureDate = Date().addingTimeInterval(30 * 24 * 3600) // 30 days from now

        // Act
        let user = SafetyUser(
            name: "New Hire",
            role: .operator,
            department: "Production",
            hireDate: futureDate
        )

        // Assert
        #expect(user.hireDate == futureDate)
    }
}

// MARK: - Permission Tests

@Suite("Permission Tests")
struct PermissionTests {

    @Test("Permission.all contains all defined permissions")
    func testAllPermissions() {
        let all = Permission.all

        #expect(all.contains(.viewTraining))
        #expect(all.contains(.completeScenarios))
        #expect(all.contains(.viewTeamMetrics))
        #expect(all.contains(.createScenarios))
        #expect(all.contains(.assessUsers))
        #expect(all.contains(.manageUsers))
        #expect(all.contains(.viewReports))
        #expect(all.contains(.exportData))
    }

    @Test("Permissions are unique")
    func testPermissionsUnique() {
        let all = Permission.all
        let uniqueCount = Set(all).count

        #expect(all.count == uniqueCount, "All permissions should be unique")
    }
}
