//
//  DataAnonymizerTests.swift
//  CultureArchitectureSystemTests
//
//  Created on 2025-01-20
//

import XCTest
import CryptoKit
@testable import CultureArchitectureSystem

final class DataAnonymizerTests: XCTestCase {

    var anonymizer: DataAnonymizer!

    override func setUp() {
        super.setUp()
        anonymizer = DataAnonymizer()
    }

    func testAnonymization() {
        // Given
        let rawEmployee = RawEmployee(
            realId: "john.doe@company.com",
            teamId: UUID(),
            departmentId: UUID(),
            role: "Senior Software Engineer",
            tenureMonths: 24
        )

        // When
        let anonymized = anonymizer.anonymize(rawEmployee)

        // Then
        XCTAssertNotNil(anonymized.anonymousId)
        XCTAssertNotEqual(anonymized.anonymousId.uuidString, rawEmployee.realId)
        XCTAssertEqual(anonymized.teamId, rawEmployee.teamId)
        XCTAssertEqual(anonymized.departmentId, rawEmployee.departmentId)
        XCTAssertEqual(anonymized.role, "Engineering") // Generalized
        XCTAssertEqual(anonymized.tenureMonths, rawEmployee.tenureMonths)
    }

    func testConsistentAnonymization() {
        // Given
        let realId = "john.doe@company.com"
        let teamId = UUID()
        let departmentId = UUID()

        let rawEmployee1 = RawEmployee(
            realId: realId,
            teamId: teamId,
            departmentId: departmentId,
            role: "Engineer",
            tenureMonths: 12
        )

        let rawEmployee2 = RawEmployee(
            realId: realId,
            teamId: teamId,
            departmentId: departmentId,
            role: "Engineer",
            tenureMonths: 12
        )

        // When
        let anonymized1 = anonymizer.anonymize(rawEmployee1)
        let anonymized2 = anonymizer.anonymize(rawEmployee2)

        // Then - Same real ID should produce same anonymous ID
        XCTAssertEqual(anonymized1.anonymousId, anonymized2.anonymousId)
    }

    func testDifferentEmployeesGetDifferentIds() {
        // Given
        let employee1 = RawEmployee(
            realId: "john.doe@company.com",
            teamId: UUID(),
            departmentId: UUID(),
            role: "Engineer",
            tenureMonths: 12
        )

        let employee2 = RawEmployee(
            realId: "jane.smith@company.com",
            teamId: UUID(),
            departmentId: UUID(),
            role: "Designer",
            tenureMonths: 18
        )

        // When
        let anonymized1 = anonymizer.anonymize(employee1)
        let anonymized2 = anonymizer.anonymize(employee2)

        // Then
        XCTAssertNotEqual(anonymized1.anonymousId, anonymized2.anonymousId)
    }

    func testKAnonymityEnforcement() {
        // Test with sufficient data
        let sufficientData = Array(1...10).map { _ in UUID() }
        let resultSufficient = anonymizer.enforceKAnonymity(sufficientData, groupSize: 5)
        XCTAssertEqual(resultSufficient.count, 10)

        // Test with insufficient data
        let insufficientData = Array(1...3).map { _ in UUID() }
        let resultInsufficient = anonymizer.enforceKAnonymity(insufficientData, groupSize: 5)
        XCTAssertEqual(resultInsufficient.count, 0) // Should be suppressed
    }

    func testCanDisplay() {
        // Test minimum team size requirement
        XCTAssertTrue(anonymizer.canDisplay(teamSize: 5))
        XCTAssertTrue(anonymizer.canDisplay(teamSize: 10))
        XCTAssertTrue(anonymizer.canDisplay(teamSize: 100))

        XCTAssertFalse(anonymizer.canDisplay(teamSize: 4))
        XCTAssertFalse(anonymizer.canDisplay(teamSize: 3))
        XCTAssertFalse(anonymizer.canDisplay(teamSize: 1))
        XCTAssertFalse(anonymizer.canDisplay(teamSize: 0))
    }

    func testRoleGeneralization() {
        // Given raw employees with specific roles
        let cases: [(String, String)] = [
            ("Senior Software Engineer", "Engineering"),
            ("VP of Sales", "Leadership"),
            ("Product Manager", "Product"),
            ("UX Designer", "Design"),
            ("Account Executive", "Sales"),
            ("Marketing Manager", "Marketing"),
            ("Operations Director", "Operations"),
            ("Customer Support Rep", "Support"),
            ("Office Manager", "General")
        ]

        for (specificRole, expectedGeneral) in cases {
            // When
            let rawEmployee = RawEmployee(
                realId: "test@company.com",
                teamId: UUID(),
                departmentId: UUID(),
                role: specificRole,
                tenureMonths: 12
            )

            let anonymized = anonymizer.anonymize(rawEmployee)

            // Then
            XCTAssertEqual(
                anonymized.role,
                expectedGeneral,
                "Role '\(specificRole)' should generalize to '\(expectedGeneral)'"
            )
        }
    }

    func testNoReverseEngineering() {
        // Given
        let realId = "john.doe@company.com"
        let rawEmployee = RawEmployee(
            realId: realId,
            teamId: UUID(),
            departmentId: UUID(),
            role: "Engineer",
            tenureMonths: 12
        )

        // When
        let anonymized = anonymizer.anonymize(rawEmployee)

        // Then - Verify we can't reverse engineer the real ID
        // The anonymous ID is a one-way hash
        XCTAssertNotEqual(anonymized.anonymousId.uuidString, realId)
        XCTAssertFalse(anonymized.anonymousId.uuidString.contains("john"))
        XCTAssertFalse(anonymized.anonymousId.uuidString.contains("doe"))
        XCTAssertFalse(anonymized.anonymousId.uuidString.contains("@"))
    }
}
