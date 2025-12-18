//
//  FarmTests.swift
//  SmartAgricultureTests
//
//  Created by Claude Code
//  Copyright © 2025 Smart Agriculture. All rights reserved.
//

import Testing
@testable import SmartAgriculture

@Suite("Farm Model Tests")
struct FarmTests {

    @Test("Farm creation with valid data")
    func testFarmCreation() {
        let farm = Farm(
            name: "Test Farm",
            latitude: 40.7128,
            longitude: -95.0059,
            totalAcres: 500.0
        )

        #expect(farm.name == "Test Farm")
        #expect(farm.totalAcres == 500.0)
        #expect(farm.fields.isEmpty)
        #expect(farm.location.latitude == 40.7128)
        #expect(farm.location.longitude == -95.0059)
    }

    @Test("Farm average health calculation with no fields")
    func testAverageHealthNoFields() {
        let farm = Farm(
            name: "Empty Farm",
            latitude: 40.0,
            longitude: -95.0,
            totalAcres: 100.0
        )

        #expect(farm.averageHealth == 0)
    }

    @Test("Farm average health calculation with fields")
    func testAverageHealthWithFields() {
        let farm = Farm.mock()

        // Mock farm has 8 fields with known health scores
        let averageHealth = farm.averageHealth

        #expect(averageHealth > 0)
        #expect(averageHealth <= 100)
    }

    @Test("Farm health status calculation")
    func testFarmHealthStatus() {
        let farm = Farm.mock()

        let status = farm.healthStatus

        // Based on the mock data, average health should be good or excellent
        #expect(status == .good || status == .excellent)
    }

    @Test("Farm total fields count")
    func testTotalFieldsCount() {
        let farm = Farm.mock()

        #expect(farm.totalFields == 8)
    }
}
