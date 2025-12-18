//
//  Equipment.swift
//  FieldServiceAR
//
//  Equipment domain model
//

import Foundation
import SwiftData
import RealityKit

@Model
final class Equipment {
    @Attribute(.unique) var id: UUID
    var manufacturer: String
    var modelNumber: String
    var serialNumber: String?
    var category: EquipmentCategory
    var name: String
    var equipmentDescription: String?

    // 3D Model
    var modelFileName: String?
    var boundingBoxMin: SIMD3<Float>?
    var boundingBoxMax: SIMD3<Float>?

    // Recognition
    var recognitionImageNames: [String] = []
    var recognitionConfidenceThreshold: Float = 0.95

    // Relationships
    @Relationship(deleteRule: .cascade)
    var components: [Component] = []

    @Relationship(deleteRule: .nullify)
    var procedures: [RepairProcedure] = []

    // Metadata
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        manufacturer: String,
        modelNumber: String,
        serialNumber: String? = nil,
        category: EquipmentCategory,
        name: String,
        equipmentDescription: String? = nil,
        modelFileName: String? = nil
    ) {
        self.id = id
        self.manufacturer = manufacturer
        self.modelNumber = modelNumber
        self.serialNumber = serialNumber
        self.category = category
        self.name = name
        self.equipmentDescription = equipmentDescription
        self.modelFileName = modelFileName
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    func update() {
        self.updatedAt = Date()
    }
}

// Equipment Category
enum EquipmentCategory: String, Codable, CaseIterable {
    case hvac = "HVAC"
    case electrical = "Electrical"
    case plumbing = "Plumbing"
    case mechanical = "Mechanical"
    case fireSafety = "Fire Safety"
    case structural = "Structural"

    var icon: String {
        switch self {
        case .hvac: return "snowflake"
        case .electrical: return "bolt.fill"
        case .plumbing: return "drop.fill"
        case .mechanical: return "gearshape.fill"
        case .fireSafety: return "flame.fill"
        case .structural: return "building.2.fill"
        }
    }

    var color: String {
        switch self {
        case .hvac: return "#00C7BE"
        case .electrical: return "#FFD700"
        case .plumbing: return "#5E5CE6"
        case .mechanical: return "#FF9500"
        case .fireSafety: return "#FF3B30"
        case .structural: return "#8E8E93"
        }
    }
}
