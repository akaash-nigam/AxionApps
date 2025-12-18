//
//  FieldTests.swift
//  SmartAgricultureTests
//
//  Created by Claude Code
//  Copyright © 2025 Smart Agriculture. All rights reserved.
//

import Testing
@testable import SmartAgriculture

@Suite("Field Model Tests")
struct FieldTests {

    @Test("Field creation with valid data")
    func testFieldCreation() {
        let field = Field(
            name: "Test Field",
            acreage: 320.0,
            cropType: .corn,
            centerLatitude: 40.7,
            centerLongitude: -95.0
        )

        #expect(field.name == "Test Field")
        #expect(field.acreage == 320.0)
        #expect(field.cropType == .corn)
        #expect(field.centerPoint.latitude == 40.7)
        #expect(field.centerPoint.longitude == -95.0)
    }

    @Test("Field health status calculation")
    func testFieldHealthStatus() {
        let field = Field.mock(health: 92.0)

        #expect(field.healthStatus == .excellent)

        let poorField = Field.mock(health: 35.0)
        #expect(poorField.healthStatus == .poor)
    }

    @Test("Field needs attention flag")
    func testNeedsAttention() {
        let healthyField = Field.mock(health: 85.0)
        #expect(healthyField.needsAttention == false)

        let problemField = Field.mock(health: 62.0)
        #expect(problemField.needsAttention == true)
    }

    @Test("Field health update")
    func testUpdateHealth() {
        let field = Field.mock(health: 80.0)

        let initialHealth = field.currentHealthScore
        #expect(initialHealth == 80.0)

        field.updateHealth(score: 75.0)
        #expect(field.currentHealthScore == 75.0)
    }

    @Test("Crop type properties")
    func testCropTypeProperties() {
        let cornField = Field(
            name: "Corn Field",
            acreage: 200,
            cropType: .corn,
            centerLatitude: 40.0,
            centerLongitude: -95.0
        )

        #expect(cornField.cropType.displayName == "Corn")
        #expect(cornField.cropType.typicalYield == 180.0)
        #expect(cornField.cropType.growingSeasonDays == 120)
    }

    @Test("Estimated harvest date calculation")
    func testEstimatedHarvestDate() {
        let field = Field.mock()

        if let plantingDate = field.plantingDate,
           let harvestDate = field.estimatedHarvestDate {
            let calendar = Calendar.current
            let days = calendar.dateComponents([.day], from: plantingDate, to: harvestDate).day

            // Should be approximately the growing season days
            let expectedDays = field.cropType.growingSeasonDays
            #expect(days == expectedDays)
        }
    }
}
