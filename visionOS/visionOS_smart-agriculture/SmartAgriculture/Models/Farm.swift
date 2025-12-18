//
//  Farm.swift
//  SmartAgriculture
//
//  Created by Claude Code
//  Copyright © 2025 Smart Agriculture. All rights reserved.
//

import Foundation
import SwiftData
import CoreLocation

// MARK: - Farm Model

@Model
final class Farm {
    @Attribute(.unique) var id: UUID
    var name: String
    var latitude: Double
    var longitude: Double
    var totalAcres: Double

    @Relationship(deleteRule: .cascade)
    var fields: [Field]

    var createdAt: Date
    var updatedAt: Date

    // Spatial representation
    var centerPointX: Float
    var centerPointY: Float
    var centerPointZ: Float
    var spatialScale: Float

    init(
        id: UUID = UUID(),
        name: String,
        latitude: Double,
        longitude: Double,
        totalAcres: Double
    ) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.totalAcres = totalAcres
        self.fields = []
        self.createdAt = Date()
        self.updatedAt = Date()
        self.centerPointX = 0
        self.centerPointY = 0
        self.centerPointZ = 0
        self.spatialScale = 1.0
    }

    // Computed properties
    var location: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var averageHealth: Double {
        guard !fields.isEmpty else { return 0 }
        let totalHealth = fields.compactMap { $0.currentHealthScore }.reduce(0, +)
        return totalHealth / Double(fields.count)
    }

    var totalFields: Int {
        fields.count
    }

    var healthStatus: HealthStatus {
        switch averageHealth {
        case 80...100: return .excellent
        case 60..<80: return .good
        case 40..<60: return .moderate
        case 20..<40: return .poor
        default: return .critical
        }
    }
}

// MARK: - Mock Data

extension Farm {
    static func mock(name: String = "Riverside Farm", acreage: Double = 5200) -> Farm {
        let farm = Farm(
            name: name,
            latitude: 40.7128,
            longitude: -95.0059,
            totalAcres: acreage
        )

        // Add mock fields
        farm.fields = [
            Field.mock(name: "Field 1", acreage: 320, cropType: .corn, farm: farm, health: 92),
            Field.mock(name: "Field 2", acreage: 280, cropType: .soybeans, farm: farm, health: 85),
            Field.mock(name: "Field 3", acreage: 450, cropType: .wheat, farm: farm, health: 78),
            Field.mock(name: "Field 4", acreage: 310, cropType: .corn, farm: farm, health: 88),
            Field.mock(name: "Field 5", acreage: 290, cropType: .corn, farm: farm, health: 94),
            Field.mock(name: "Field 6", acreage: 380, cropType: .wheat, farm: farm, health: 81),
            Field.mock(name: "Field 7", acreage: 420, cropType: .soybeans, farm: farm, health: 62),
            Field.mock(name: "Field 8", acreage: 350, cropType: .corn, farm: farm, health: 89),
        ]

        return farm
    }
}
