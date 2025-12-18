//
//  Field.swift
//  SmartAgriculture
//
//  Created by Claude Code
//  Copyright © 2025 Smart Agriculture. All rights reserved.
//

import Foundation
import SwiftData
import CoreLocation

// MARK: - Field Model

@Model
final class Field {
    @Attribute(.unique) var id: UUID
    var name: String
    var acreage: Double
    var cropTypeRaw: String
    var growthStageRaw: String

    var plantingDate: Date?
    var expectedHarvestDate: Date?

    // Center point
    var centerLatitude: Double
    var centerLongitude: Double

    // Current health
    var currentHealthScore: Double?
    var lastUpdated: Date

    // Predicted yield
    var predictedYield: Double?
    var actualYield: Double?

    @Relationship(inverse: \Farm.fields)
    var farm: Farm?

    init(
        id: UUID = UUID(),
        name: String,
        acreage: Double,
        cropType: CropType,
        growthStage: GrowthStage = .preseason,
        centerLatitude: Double,
        centerLongitude: Double
    ) {
        self.id = id
        self.name = name
        self.acreage = acreage
        self.cropTypeRaw = cropType.rawValue
        self.growthStageRaw = growthStage.rawValue
        self.centerLatitude = centerLatitude
        self.centerLongitude = centerLongitude
        self.lastUpdated = Date()
    }

    // Computed properties
    var cropType: CropType {
        get { CropType(rawValue: cropTypeRaw) ?? .other }
        set { cropTypeRaw = newValue.rawValue }
    }

    var growthStage: GrowthStage {
        get { GrowthStage(rawValue: growthStageRaw) ?? .preseason }
        set { growthStageRaw = newValue.rawValue }
    }

    var centerPoint: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude)
    }

    var healthStatus: HealthStatus {
        guard let health = currentHealthScore else { return .poor }
        switch health {
        case 80...100: return .excellent
        case 60..<80: return .good
        case 40..<60: return .moderate
        case 20..<40: return .poor
        default: return .critical
        }
    }

    var needsAttention: Bool {
        guard let health = currentHealthScore else { return true }
        return health < 70.0
    }

    var estimatedHarvestDate: Date? {
        guard let plantingDate = plantingDate else { return nil }
        let growingDays = cropType.growingSeasonDays
        return Calendar.current.date(byAdding: .day, value: growingDays, to: plantingDate)
    }

    func updateHealth(score: Double) {
        self.currentHealthScore = score
        self.lastUpdated = Date()
    }
}

// MARK: - Mock Data

extension Field {
    static func mock(
        name: String = "Field 1",
        acreage: Double = 320,
        cropType: CropType = .corn,
        farm: Farm? = nil,
        health: Double = 85.0
    ) -> Field {
        let field = Field(
            name: name,
            acreage: acreage,
            cropType: cropType,
            growthStage: .vegetative,
            centerLatitude: 40.7128 + Double.random(in: -0.1...0.1),
            centerLongitude: -95.0059 + Double.random(in: -0.1...0.1)
        )

        field.plantingDate = Calendar.current.date(byAdding: .day, value: -60, to: Date())
        field.currentHealthScore = health
        field.predictedYield = cropType.typicalYield * (health / 100.0)
        field.farm = farm

        return field
    }

    static func mockWithIssues() -> Field {
        let field = Field(
            name: "Problem Field",
            acreage: 420,
            cropType: .soybeans,
            growthStage: .vegetative,
            centerLatitude: 40.7128,
            centerLongitude: -95.0059
        )

        field.plantingDate = Calendar.current.date(byAdding: .day, value: -60, to: Date())
        field.currentHealthScore = 62.0
        field.predictedYield = 30.0  // Low yield

        return field
    }
}
