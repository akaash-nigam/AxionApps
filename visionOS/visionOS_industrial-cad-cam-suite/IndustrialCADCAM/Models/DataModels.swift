//
//  DataModels.swift
//  IndustrialCADCAM
//
//  Core data models for CAD/CAM functionality
//

import Foundation
import SwiftData
import RealityKit

// MARK: - Project

@Model
final class Project {
    @Attribute(.unique) var id: UUID
    var name: String
    var createdDate: Date
    var modifiedDate: Date
    var projectDescription: String?

    @Relationship(deleteRule: .cascade) var parts: [Part]
    @Relationship(deleteRule: .cascade) var assemblies: [Assembly]

    init(name: String, description: String? = nil) {
        self.id = UUID()
        self.name = name
        self.createdDate = Date()
        self.modifiedDate = Date()
        self.projectDescription = description
        self.parts = []
        self.assemblies = []
    }
}

// MARK: - Part

@Model
final class Part {
    @Attribute(.unique) var id: UUID
    var name: String
    var version: Int
    var createdDate: Date
    var modifiedDate: Date

    // Geometry data (stored externally for large files)
    @Attribute(.externalStorage) var geometryData: Data?
    @Attribute(.externalStorage) var meshData: Data?

    // Bounding box
    var boundingBoxMin: SIMD3<Float>
    var boundingBoxMax: SIMD3<Float>

    // Material properties
    var materialName: String
    var materialDensity: Double // g/cm³
    var materialYieldStrength: Double? // MPa

    // Mass properties
    var mass: Double // grams
    var volume: Double // cm³
    var surfaceArea: Double // cm²
    var centerOfGravity: SIMD3<Float>

    // Manufacturing specifications
    var toleranceClass: String // e.g., "±0.1mm"
    var surfaceFinish: String // e.g., "Ra 3.2"
    var manufacturingNotes: String?

    // Relationships
    @Relationship var project: Project?
    @Relationship(deleteRule: .cascade) var features: [Feature]
    @Relationship var assembly: Assembly?

    init(name: String, material: String = "Steel") {
        self.id = UUID()
        self.name = name
        self.version = 1
        self.createdDate = Date()
        self.modifiedDate = Date()

        self.geometryData = nil
        self.meshData = nil

        self.boundingBoxMin = SIMD3<Float>(0, 0, 0)
        self.boundingBoxMax = SIMD3<Float>(0, 0, 0)

        self.materialName = material
        self.materialDensity = 7.85 // Steel default
        self.materialYieldStrength = 250.0

        self.mass = 0.0
        self.volume = 0.0
        self.surfaceArea = 0.0
        self.centerOfGravity = SIMD3<Float>(0, 0, 0)

        self.toleranceClass = "±0.1mm"
        self.surfaceFinish = "Ra 6.3"
        self.manufacturingNotes = nil

        self.features = []
    }
}

// MARK: - Feature

@Model
final class Feature {
    @Attribute(.unique) var id: UUID
    var name: String
    var type: FeatureType
    var order: Int
    var isActive: Bool
    var isSuppressed: Bool

    // Parameters stored as JSON
    @Attribute(.externalStorage) var parametersData: Data?

    @Relationship var part: Part?

    init(name: String, type: FeatureType, order: Int) {
        self.id = UUID()
        self.name = name
        self.type = type
        self.order = order
        self.isActive = true
        self.isSuppressed = false
        self.parametersData = nil
    }
}

enum FeatureType: String, Codable {
    case sketch = "Sketch"
    case extrude = "Extrude"
    case revolve = "Revolve"
    case fillet = "Fillet"
    case chamfer = "Chamfer"
    case hole = "Hole"
    case pattern = "Pattern"
    case mirror = "Mirror"
    case shell = "Shell"
    case draft = "Draft"
    case booleanUnion = "Union"
    case booleanSubtract = "Subtract"
    case booleanIntersect = "Intersect"
}

// MARK: - Assembly

@Model
final class Assembly {
    @Attribute(.unique) var id: UUID
    var name: String
    var version: Int
    var createdDate: Date
    var modifiedDate: Date

    @Relationship var project: Project?
    @Relationship(deleteRule: .cascade) var components: [AssemblyComponent]
    @Relationship(deleteRule: .cascade) var constraints: [AssemblyConstraint]

    init(name: String) {
        self.id = UUID()
        self.name = name
        self.version = 1
        self.createdDate = Date()
        self.modifiedDate = Date()
        self.components = []
        self.constraints = []
    }
}

// MARK: - Assembly Component

@Model
final class AssemblyComponent {
    @Attribute(.unique) var id: UUID
    var partId: UUID
    var instanceName: String

    // Transform
    var position: SIMD3<Float>
    var rotation: simd_quatf
    var scale: SIMD3<Float>

    var isVisible: Bool
    var isFixed: Bool

    @Relationship var assembly: Assembly?

    init(partId: UUID, instanceName: String) {
        self.id = UUID()
        self.partId = partId
        self.instanceName = instanceName

        self.position = SIMD3<Float>(0, 0, 0)
        self.rotation = simd_quatf(angle: 0, axis: SIMD3<Float>(0, 1, 0))
        self.scale = SIMD3<Float>(1, 1, 1)

        self.isVisible = true
        self.isFixed = false
    }
}

// MARK: - Assembly Constraint

@Model
final class AssemblyConstraint {
    @Attribute(.unique) var id: UUID
    var type: ConstraintType
    var component1Id: UUID
    var component2Id: UUID
    var offset: Float

    @Relationship var assembly: Assembly?

    init(type: ConstraintType, component1: UUID, component2: UUID, offset: Float = 0.0) {
        self.id = UUID()
        self.type = type
        self.component1Id = component1
        self.component2Id = component2
        self.offset = offset
    }
}

enum ConstraintType: String, Codable {
    case coincident = "Coincident"
    case parallel = "Parallel"
    case perpendicular = "Perpendicular"
    case concentric = "Concentric"
    case tangent = "Tangent"
    case distance = "Distance"
    case angle = "Angle"
}

// MARK: - Manufacturing Process

@Model
final class ManufacturingProcess {
    @Attribute(.unique) var id: UUID
    var partId: UUID
    var processName: String
    var processType: ManufacturingType

    var setupTime: TimeInterval
    var cycleTime: TimeInterval
    var estimatedCost: Decimal

    @Attribute(.externalStorage) var toolpathData: Data?
    @Attribute(.externalStorage) var gCodeData: Data?

    @Relationship(deleteRule: .cascade) var operations: [MachiningOperation]

    init(partId: UUID, name: String, type: ManufacturingType) {
        self.id = UUID()
        self.partId = partId
        self.processName = name
        self.processType = type

        self.setupTime = 0
        self.cycleTime = 0
        self.estimatedCost = 0

        self.toolpathData = nil
        self.gCodeData = nil
        self.operations = []
    }
}

enum ManufacturingType: String, Codable {
    case cncMilling = "CNC Milling"
    case cncTurning = "CNC Turning"
    case additiveManufacturing = "3D Printing"
    case sheetMetal = "Sheet Metal"
    case casting = "Casting"
    case forging = "Forging"
}

// MARK: - Machining Operation

@Model
final class MachiningOperation {
    @Attribute(.unique) var id: UUID
    var operationName: String
    var operationType: String
    var toolId: String
    var cuttingSpeed: Double
    var feedRate: Double
    var depthOfCut: Double
    var operationTime: TimeInterval

    @Relationship var process: ManufacturingProcess?

    init(name: String, type: String, toolId: String) {
        self.id = UUID()
        self.operationName = name
        self.operationType = type
        self.toolId = toolId
        self.cuttingSpeed = 100.0
        self.feedRate = 0.1
        self.depthOfCut = 1.0
        self.operationTime = 0
    }
}

// MARK: - Simulation Result

@Model
final class SimulationResult {
    @Attribute(.unique) var id: UUID
    var partId: UUID
    var simulationType: SimulationType
    var timestamp: Date

    // Results
    var maxStress: Double?
    var maxDisplacement: Double?
    var safetyFactor: Double?
    var maxTemperature: Double?
    var minTemperature: Double?

    // Result data (mesh with scalar/vector fields)
    @Attribute(.externalStorage) var resultData: Data?

    init(partId: UUID, type: SimulationType) {
        self.id = UUID()
        self.partId = partId
        self.simulationType = type
        self.timestamp = Date()

        self.maxStress = nil
        self.maxDisplacement = nil
        self.safetyFactor = nil
        self.maxTemperature = nil
        self.minTemperature = nil

        self.resultData = nil
    }
}

enum SimulationType: String, Codable {
    case structural = "Structural Analysis (FEA)"
    case thermal = "Thermal Analysis"
    case modal = "Modal Analysis"
    case cfd = "Computational Fluid Dynamics"
    case electromagnetic = "Electromagnetic"
}

// MARK: - Material Definition

struct Material: Codable {
    var name: String
    var category: MaterialCategory
    var density: Double // g/cm³
    var youngsModulus: Double? // GPa
    var poissonsRatio: Double?
    var yieldStrength: Double? // MPa
    var ultimateStrength: Double? // MPa
    var thermalConductivity: Double? // W/(m·K)
    var specificHeat: Double? // J/(kg·K)
    var color: String // Hex color for visualization
}

enum MaterialCategory: String, Codable {
    case steel = "Steel"
    case aluminum = "Aluminum"
    case titanium = "Titanium"
    case plastic = "Plastic"
    case composite = "Composite"
    case ceramic = "Ceramic"
    case custom = "Custom"
}

// MARK: - Standard Materials Library

extension Material {
    static let standardMaterials: [Material] = [
        Material(
            name: "Steel 1045",
            category: .steel,
            density: 7.85,
            youngsModulus: 200,
            poissonsRatio: 0.29,
            yieldStrength: 310,
            ultimateStrength: 565,
            thermalConductivity: 49.8,
            specificHeat: 486,
            color: "#A8A8A8"
        ),
        Material(
            name: "Aluminum 6061-T6",
            category: .aluminum,
            density: 2.70,
            youngsModulus: 68.9,
            poissonsRatio: 0.33,
            yieldStrength: 276,
            ultimateStrength: 310,
            thermalConductivity: 167,
            specificHeat: 896,
            color: "#D4D4D4"
        ),
        Material(
            name: "Titanium Ti-6Al-4V",
            category: .titanium,
            density: 4.43,
            youngsModulus: 113.8,
            poissonsRatio: 0.342,
            yieldStrength: 880,
            ultimateStrength: 950,
            thermalConductivity: 6.7,
            specificHeat: 526,
            color: "#C0C0C0"
        ),
        Material(
            name: "ABS Plastic",
            category: .plastic,
            density: 1.05,
            youngsModulus: 2.3,
            poissonsRatio: 0.35,
            yieldStrength: 40,
            ultimateStrength: 44,
            thermalConductivity: 0.25,
            specificHeat: 1386,
            color: "#E8E8E8"
        )
    ]
}
