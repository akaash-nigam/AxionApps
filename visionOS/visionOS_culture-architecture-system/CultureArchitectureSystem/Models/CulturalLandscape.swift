//
//  CulturalLandscape.swift
//  CultureArchitectureSystem
//
//  Created on 2025-01-20
//

import Foundation
import SwiftData

@Model
final class CulturalLandscape {
    @Attribute(.unique) var id: UUID
    var organizationId: UUID
    var regions: [CulturalRegion]
    var lastUpdated: Date

    init(
        id: UUID = UUID(),
        organizationId: UUID,
        regions: [CulturalRegion] = []
    ) {
        self.id = id
        self.organizationId = organizationId
        self.regions = regions
        self.lastUpdated = Date()
    }
}

@Model
final class CulturalRegion {
    @Attribute(.unique) var id: UUID
    var valueId: UUID
    var name: String
    var regionType: RegionType
    var healthScore: Double
    var activityLevel: Double
    var positionX: Float
    var positionY: Float
    var positionZ: Float

    init(
        id: UUID = UUID(),
        valueId: UUID,
        name: String,
        regionType: RegionType,
        healthScore: Double = 50.0,
        activityLevel: Double = 0.0,
        position: SIMD3<Float> = SIMD3<Float>(0, 0, 0)
    ) {
        self.id = id
        self.valueId = valueId
        self.name = name
        self.regionType = regionType
        self.healthScore = healthScore
        self.activityLevel = activityLevel
        self.positionX = position.x
        self.positionY = position.y
        self.positionZ = position.z
    }

    var position: SIMD3<Float> {
        get { SIMD3<Float>(positionX, positionY, positionZ) }
        set {
            positionX = newValue.x
            positionY = newValue.y
            positionZ = newValue.z
        }
    }
}

// MARK: - Region Types
enum RegionType: String, Codable {
    case mountain      // Purpose/Mission
    case valley        // Values/Principles
    case river         // Behavior flows
    case bridge        // Connections
    case forest        // Innovation
    case plaza         // Recognition
    case amphitheater  // Stories
    case pool          // Reflection
    case territory     // Teams
    case lab           // Experimentation
}

// MARK: - JSON Serialization Helpers
extension CulturalLandscape {
    func toDictionary() -> [String: Any] {
        [
            "id": id.uuidString,
            "organization_id": organizationId.uuidString,
            "regions": regions.map { $0.toDictionary() },
            "last_updated": lastUpdated.timeIntervalSince1970
        ]
    }
}

extension CulturalRegion {
    func toDictionary() -> [String: Any] {
        [
            "id": id.uuidString,
            "value_id": valueId.uuidString,
            "name": name,
            "region_type": regionType.rawValue,
            "health_score": healthScore,
            "activity_level": activityLevel,
            "position_x": positionX,
            "position_y": positionY,
            "position_z": positionZ
        ]
    }
}
