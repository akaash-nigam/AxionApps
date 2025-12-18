//
//  Component.swift
//  FieldServiceAR
//
//  Equipment component model
//

import Foundation
import SwiftData

@Model
final class Component {
    @Attribute(.unique) var id: UUID
    var name: String
    var partNumber: String
    var componentDescription: String?

    // Spatial properties
    var positionX: Float = 0.0
    var positionY: Float = 0.0
    var positionZ: Float = 0.0

    // Condition
    var currentCondition: ComponentCondition = .good
    var wearPercentage: Float = 0.0

    // Maintenance
    var lastReplacedDate: Date?
    var replacementIntervalDays: Int?
    var estimatedLifespanHours: Int?

    // Relationships
    @Relationship(inverse: \Equipment.components)
    var equipment: Equipment?

    init(
        id: UUID = UUID(),
        name: String,
        partNumber: String,
        componentDescription: String? = nil
    ) {
        self.id = id
        self.name = name
        self.partNumber = partNumber
        self.componentDescription = componentDescription
    }

    var position: SIMD3<Float> {
        SIMD3<Float>(positionX, positionY, positionZ)
    }

    func setPosition(_ position: SIMD3<Float>) {
        self.positionX = position.x
        self.positionY = position.y
        self.positionZ = position.z
    }

    var needsReplacement: Bool {
        currentCondition == .critical || wearPercentage > 80.0
    }
}

// Component Condition
enum ComponentCondition: String, Codable {
    case excellent = "Excellent"
    case good = "Good"
    case fair = "Fair"
    case worn = "Worn"
    case critical = "Critical"

    var color: String {
        switch self {
        case .excellent: return "#34C759"
        case .good: return "#34C759"
        case .fair: return "#FFD700"
        case .worn: return "#FF9500"
        case .critical: return "#FF3B30"
        }
    }
}
