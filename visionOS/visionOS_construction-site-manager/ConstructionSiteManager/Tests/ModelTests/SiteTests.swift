//
//  SiteTests.swift
//  Construction Site Manager Tests
//
//  Unit tests for Site models
//

import Testing
import Foundation
@testable import ConstructionSiteManager

@Suite("Site Model Tests")
struct SiteTests {

    @Test("Site initializes with correct values")
    func testSiteInitialization() {
        // Arrange
        let name = "Test Construction Site"
        let address = Address(
            street: "123 Main St",
            city: "San Francisco",
            state: "CA",
            zipCode: "94102",
            country: "USA"
        )
        let latitude = 37.7749
        let longitude = -122.4194

        // Act
        let site = Site(
            name: name,
            address: address,
            gpsLatitude: latitude,
            gpsLongitude: longitude
        )

        // Assert
        #expect(site.name == name)
        #expect(site.address == address)
        #expect(site.gpsLatitude == latitude)
        #expect(site.gpsLongitude == longitude)
        #expect(site.status == .planning)
        #expect(site.projects.isEmpty)
        #expect(site.team.isEmpty)
    }

    @Test("Site calculates overall progress correctly")
    func testOverallProgress() {
        // Arrange
        let site = createTestSite()
        let endDate = Calendar.current.date(byAdding: .month, value: 6, to: Date())!

        let project1 = Project(
            name: "Project 1",
            projectType: .commercial,
            progress: 0.5,
            scheduledEndDate: endDate
        )
        let project2 = Project(
            name: "Project 2",
            projectType: .commercial,
            progress: 0.7,
            scheduledEndDate: endDate
        )

        // Act
        site.projects.append(project1)
        site.projects.append(project2)

        // Assert
        let expectedProgress = (0.5 + 0.7) / 2.0
        #expect(site.overallProgress == expectedProgress)
    }

    @Test("Site with no projects has zero progress")
    func testSiteWithNoProjects() {
        // Arrange
        let site = createTestSite()

        // Assert
        #expect(site.overallProgress == 0.0)
    }

    @Test("Site coordinate conversion works")
    func testCoordinateConversion() {
        // Arrange
        let latitude = 37.7749
        let longitude = -122.4194
        let site = Site(
            name: "Test Site",
            address: createTestAddress(),
            gpsLatitude: latitude,
            gpsLongitude: longitude
        )

        // Act
        let coordinate = site.coordinate

        // Assert
        #expect(coordinate.latitude == latitude)
        #expect(coordinate.longitude == longitude)
    }

    // MARK: - Helper Methods

    func createTestSite() -> Site {
        Site(
            name: "Test Site",
            address: createTestAddress(),
            gpsLatitude: 37.7749,
            gpsLongitude: -122.4194
        )
    }

    func createTestAddress() -> Address {
        Address(
            street: "123 Test St",
            city: "Test City",
            state: "TS",
            zipCode: "12345",
            country: "USA"
        )
    }
}

@Suite("Project Model Tests")
struct ProjectTests {

    @Test("Project initializes correctly")
    func testProjectInitialization() {
        // Arrange
        let name = "Tower Construction"
        let type = ProjectType.commercial
        let budget = 1_000_000.0
        let endDate = Calendar.current.date(byAdding: .month, value: 6, to: Date())!

        // Act
        let project = Project(
            name: name,
            projectType: type,
            budget: budget,
            scheduledEndDate: endDate
        )

        // Assert
        #expect(project.name == name)
        #expect(project.projectType == type)
        #expect(project.budget == budget)
        #expect(project.progress == 0.0)
        #expect(project.actualCost == 0.0)
    }

    @Test("Project budget variance calculates correctly")
    func testBudgetVariance() {
        // Arrange
        let budget = 1_000_000.0
        let actualCost = 1_100_000.0
        let endDate = Calendar.current.date(byAdding: .month, value: 6, to: Date())!

        let project = Project(
            name: "Test Project",
            projectType: .commercial,
            budget: budget,
            actualCost: actualCost,
            scheduledEndDate: endDate
        )

        // Assert
        #expect(project.budgetVariance == 100_000.0)
        #expect(!project.isOnBudget)
    }

    @Test("Project is on budget when under budget")
    func testProjectOnBudget() {
        // Arrange
        let budget = 1_000_000.0
        let actualCost = 900_000.0
        let endDate = Calendar.current.date(byAdding: .month, value: 6, to: Date())!

        let project = Project(
            name: "Test Project",
            projectType: .commercial,
            budget: budget,
            actualCost: actualCost,
            scheduledEndDate: endDate
        )

        // Assert
        #expect(project.isOnBudget)
        #expect(project.budgetVariance == -100_000.0)
    }

    @Test("Project schedule tracking works")
    func testScheduleTracking() {
        // Arrange
        let futureDate = Calendar.current.date(byAdding: .month, value: 6, to: Date())!
        let project = Project(
            name: "Test Project",
            projectType: .commercial,
            scheduledEndDate: futureDate
        )

        // Assert
        #expect(project.isOnSchedule)
        #expect(project.actualEndDate == nil)
    }
}

@Suite("Team Member Tests")
struct TeamMemberTests {

    @Test("Team member initializes correctly")
    func testTeamMemberInitialization() {
        // Arrange
        let name = "John Doe"
        let email = "john@example.com"
        let role = TeamRole.projectManager

        // Act
        let member = TeamMember(
            name: name,
            email: email,
            phone: "555-1234",
            role: role,
            company: "Test Company"
        )

        // Assert
        #expect(member.name == name)
        #expect(member.email == email)
        #expect(member.role == role)
        #expect(member.isActive)
    }

    @Test("Team roles have correct display names")
    func testTeamRoleDisplayNames() {
        #expect(TeamRole.projectManager.displayName == "Project Manager")
        #expect(TeamRole.superintendent.displayName == "Superintendent")
        #expect(TeamRole.safetyOfficer.displayName == "Safety Officer")
    }
}
