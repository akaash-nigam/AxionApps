//
//  VisualizationServiceTests.swift
//  CultureArchitectureSystemTests
//
//  Created on 2025-01-20
//

import XCTest
@testable import CultureArchitectureSystem

final class VisualizationServiceTests: XCTestCase {

    var sut: VisualizationService!

    override func setUp() {
        super.setUp()
        sut = VisualizationService()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testGenerateLandscape() async throws {
        // Given
        let organization = Organization.mock()

        // When
        let landscape = try await sut.generateLandscape(from: organization)

        // Then
        XCTAssertEqual(landscape.organizationId, organization.id)
        XCTAssertEqual(landscape.regions.count, organization.culturalValues.count)
        XCTAssertNotNil(landscape.lastUpdated)
    }

    func testGeneratedRegionsHaveCorrectPositions() async throws {
        // Given
        let organization = Organization.mock()

        // When
        let landscape = try await sut.generateLandscape(from: organization)

        // Then - Regions should be positioned in a circle
        for region in landscape.regions {
            let distance = sqrt(
                region.positionX * region.positionX +
                region.positionZ * region.positionZ
            )

            // Should be approximately 5.0 meters from center
            XCTAssertGreaterThan(distance, 4.5)
            XCTAssertLessThan(distance, 5.5)

            // Y should be at ground level
            XCTAssertEqual(region.positionY, 0)
        }
    }

    func testGeneratedRegionsHaveCorrectTypes() async throws {
        // Given
        let organization = Organization.mock()

        // When
        let landscape = try await sut.generateLandscape(from: organization)

        // Then - Each region should have a valid type
        for region in landscape.regions {
            XCTAssertNotNil(region.regionType)

            // Verify region type matches value characteristics
            let validTypes: [RegionType] = [
                .mountain, .valley, .river, .bridge,
                .forest, .plaza, .amphitheater, .pool,
                .territory, .lab
            ]
            XCTAssertTrue(validTypes.contains(region.regionType))
        }
    }

    func testRegionsInheritHealthScores() async throws {
        // Given
        let organization = Organization.mock()
        organization.culturalValues.forEach { value in
            value.alignmentScore = 75.0
        }

        // When
        let landscape = try await sut.generateLandscape(from: organization)

        // Then
        for region in landscape.regions {
            XCTAssertEqual(region.healthScore, 75.0)
        }
    }
}
