//
//  OrganizationTests.swift
//  CultureArchitectureSystemTests
//
//  Created on 2025-01-20
//

import XCTest
import SwiftData
@testable import CultureArchitectureSystem

final class OrganizationTests: XCTestCase {

    func testOrganizationCreation() {
        // Given
        let name = "Test Organization"

        // When
        let organization = Organization(name: name)

        // Then
        XCTAssertEqual(organization.name, name)
        XCTAssertNotNil(organization.id)
        XCTAssertEqual(organization.culturalValues.count, 0)
        XCTAssertEqual(organization.departments.count, 0)
        XCTAssertEqual(organization.cultureHealthScore, 0.0)
        XCTAssertNotNil(organization.createdAt)
        XCTAssertNotNil(organization.updatedAt)
    }

    func testOrganizationUpdate() {
        // Given
        let organization = Organization(name: "Original Name")
        let originalUpdatedAt = organization.updatedAt

        // When
        let updatedOrg = Organization(name: "Updated Name")
        organization.update(from: updatedOrg)

        // Then
        XCTAssertEqual(organization.name, "Updated Name")
        XCTAssertGreaterThan(organization.updatedAt, originalUpdatedAt)
    }

    func testOrganizationWithValues() {
        // Given
        let organization = Organization(name: "Test Org")
        let innovation = CulturalValue(name: "Innovation", description: "Test")
        let collaboration = CulturalValue(name: "Collaboration", description: "Test")

        // When
        organization.culturalValues = [innovation, collaboration]

        // Then
        XCTAssertEqual(organization.culturalValues.count, 2)
        XCTAssertTrue(organization.culturalValues.contains { $0.name == "Innovation" })
        XCTAssertTrue(organization.culturalValues.contains { $0.name == "Collaboration" })
    }

    func testMockOrganization() {
        // When
        let mockOrg = Organization.mock()

        // Then
        XCTAssertEqual(mockOrg.name, "TechForward Inc")
        XCTAssertEqual(mockOrg.culturalValues.count, 3)
        XCTAssertEqual(mockOrg.cultureHealthScore, 85.0)
    }

    func testOrganizationCodable() throws {
        // Given
        let organization = Organization(name: "Codable Test")
        organization.cultureHealthScore = 75.5

        // When
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(organization)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(Organization.self, from: data)

        // Then
        XCTAssertEqual(decoded.name, organization.name)
        XCTAssertEqual(decoded.cultureHealthScore, organization.cultureHealthScore)
    }
}
