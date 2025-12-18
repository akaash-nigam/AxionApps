//
//  CulturalValueTests.swift
//  CultureArchitectureSystemTests
//
//  Created on 2025-01-20
//

import XCTest
@testable import CultureArchitectureSystem

final class CulturalValueTests: XCTestCase {

    func testCulturalValueCreation() {
        // Given
        let name = "Innovation"
        let description = "Continuous improvement"

        // When
        let value = CulturalValue(name: name, description: description)

        // Then
        XCTAssertEqual(value.name, name)
        XCTAssertEqual(value.description, description)
        XCTAssertNotNil(value.id)
        XCTAssertEqual(value.iconName, "lightbulb.fill")
        XCTAssertEqual(value.colorHex, "#8B5CF6")
        XCTAssertEqual(value.alignmentScore, 0.0)
        XCTAssertEqual(value.behaviors.count, 0)
    }

    func testValueTypeDefaults() {
        // Test all value types have correct defaults
        let types = CulturalValue.ValueType.allCases

        for type in types {
            // When
            let value = CulturalValue.create(
                type: type,
                description: "Test description for \(type.rawValue)"
            )

            // Then
            XCTAssertEqual(value.name, type.rawValue.capitalized)
            XCTAssertEqual(value.iconName, type.defaultIcon)
            XCTAssertEqual(value.colorHex, type.defaultColor)
        }
    }

    func testInnovationValueType() {
        // When
        let innovation = CulturalValue.create(
            type: .innovation,
            description: "Test"
        )

        // Then
        XCTAssertEqual(innovation.name, "Innovation")
        XCTAssertEqual(innovation.iconName, "lightbulb.fill")
        XCTAssertEqual(innovation.colorHex, "#8B5CF6")
    }

    func testCollaborationValueType() {
        // When
        let collaboration = CulturalValue.create(
            type: .collaboration,
            description: "Test"
        )

        // Then
        XCTAssertEqual(collaboration.name, "Collaboration")
        XCTAssertEqual(collaboration.iconName, "person.2.fill")
        XCTAssertEqual(collaboration.colorHex, "#3B82F6")
    }

    func testCulturalValueCodable() throws {
        // Given
        let value = CulturalValue(
            name: "Trust",
            description: "Building trust",
            iconName: "shield.fill",
            colorHex: "#F59E0B",
            alignmentScore: 85.0
        )

        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(value)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(CulturalValue.self, from: data)

        // Then
        XCTAssertEqual(decoded.name, value.name)
        XCTAssertEqual(decoded.description, value.description)
        XCTAssertEqual(decoded.alignmentScore, value.alignmentScore)
    }
}
