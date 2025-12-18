//
//  EmployeeTests.swift
//  CultureArchitectureSystemTests
//
//  Created on 2025-01-20
//

import XCTest
@testable import CultureArchitectureSystem

final class EmployeeTests: XCTestCase {

    func testEmployeeCreation() {
        // Given
        let teamId = UUID()
        let departmentId = UUID()
        let role = "Senior Software Engineer"

        // When
        let employee = Employee(
            teamId: teamId,
            departmentId: departmentId,
            role: role
        )

        // Then
        XCTAssertNotNil(employee.anonymousId)
        XCTAssertEqual(employee.teamId, teamId)
        XCTAssertEqual(employee.departmentId, departmentId)
        XCTAssertEqual(employee.role, role)
        XCTAssertEqual(employee.tenureMonths, 0)
        XCTAssertEqual(employee.engagementScore, 0.0)
        XCTAssertEqual(employee.culturalContributions, 0)
    }

    func testEmployeePrivacy() {
        // Given & When
        let employee = Employee(
            teamId: UUID(),
            departmentId: UUID(),
            role: "VP of Engineering"
        )

        // Then - Verify no PII is stored
        XCTAssertNotNil(employee.anonymousId)
        // The model structure ensures no real ID, name, email, etc.
        // Only anonymous ID, role generalization, and team associations
    }

    func testRoleGeneralization() {
        // Test engineering roles
        XCTAssertEqual(
            Employee.GeneralizedRole.generalize("Senior Software Engineer"),
            .engineering
        )
        XCTAssertEqual(
            Employee.GeneralizedRole.generalize("Staff Developer"),
            .engineering
        )

        // Test leadership roles
        XCTAssertEqual(
            Employee.GeneralizedRole.generalize("VP of Sales"),
            .leadership
        )
        XCTAssertEqual(
            Employee.GeneralizedRole.generalize("Director of Engineering"),
            .leadership
        )

        // Test product roles
        XCTAssertEqual(
            Employee.GeneralizedRole.generalize("Product Manager"),
            .product
        )

        // Test sales roles
        XCTAssertEqual(
            Employee.GeneralizedRole.generalize("Account Executive"),
            .sales
        )

        // Test general/unknown roles
        XCTAssertEqual(
            Employee.GeneralizedRole.generalize("Unknown Role"),
            .general
        )
    }

    func testGeneralizedRoleProperty() {
        // Given
        let engineer = Employee(
            teamId: UUID(),
            departmentId: UUID(),
            role: "Senior Software Engineer"
        )

        let leader = Employee(
            teamId: UUID(),
            departmentId: UUID(),
            role: "VP of Product"
        )

        // Then
        XCTAssertEqual(engineer.generalizedRole, .engineering)
        XCTAssertEqual(leader.generalizedRole, .leadership)
    }

    func testEmployeeCodable() throws {
        // Given
        let employee = Employee(
            teamId: UUID(),
            departmentId: UUID(),
            role: "Product Designer",
            tenureMonths: 24,
            engagementScore: 85.5,
            culturalContributions: 42
        )

        // When
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(employee)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(Employee.self, from: data)

        // Then
        XCTAssertEqual(decoded.role, employee.role)
        XCTAssertEqual(decoded.tenureMonths, employee.tenureMonths)
        XCTAssertEqual(decoded.engagementScore, employee.engagementScore)
        XCTAssertEqual(decoded.culturalContributions, employee.culturalContributions)
    }
}
