import Foundation
import Observation
import SwiftData

@Observable
class DesignService {
    private var modelContext: ModelContext?

    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
    }

    // MARK: - Project Operations
    func createProject(name: String, description: String = "") async throws -> DesignProject {
        let project = DesignProject(name: name, description: description)

        if let context = modelContext {
            context.insert(project)
            try context.save()
        }

        return project
    }

    func loadProjects() async throws -> [DesignProject] {
        guard let context = modelContext else { return [] }

        let descriptor = FetchDescriptor<DesignProject>(
            sortBy: [SortDescriptor(\.modifiedDate, order: .reverse)]
        )

        return try context.fetch(descriptor)
    }

    func deleteProject(_ project: DesignProject) async throws {
        guard let context = modelContext else { return }
        context.delete(project)
        try context.save()
    }

    // MARK: - Part Operations
    func createPart(name: String, in project: DesignProject) async throws -> Part {
        let part = Part(name: name)
        project.addPart(part)

        if let context = modelContext {
            context.insert(part)
            try context.save()
        }

        return part
    }

    func createPrimitive(type: PrimitiveType, dimensions: PrimitiveDimensions) async throws -> Part {
        let part = Part(name: type.displayName)

        // Generate simple geometry data (placeholder)
        let geometryData = try await generatePrimitiveGeometry(type: type, dimensions: dimensions)
        part.geometryData = geometryData

        // Calculate properties based on primitive
        let properties = calculatePrimitiveProperties(type: type, dimensions: dimensions)
        part.volume = properties.volume
        part.surfaceArea = properties.surfaceArea
        part.mass = part.calculateMass()

        return part
    }

    func modifyPart(_ part: Part, operation: GeometryOperation) async throws -> Part {
        // Apply geometry modification
        // In production, this would use a CAD kernel
        part.touch()

        if let context = modelContext {
            try context.save()
        }

        return part
    }

    // MARK: - Assembly Operations
    func createAssembly(name: String, in project: DesignProject) async throws -> Assembly {
        let assembly = Assembly(name: name)
        project.addAssembly(assembly)

        if let context = modelContext {
            context.insert(assembly)
            try context.save()
        }

        return assembly
    }

    func addPartToAssembly(_ part: Part, assembly: Assembly, at position: Transform3D) async throws {
        assembly.addPart(part, at: position)

        if let context = modelContext {
            try context.save()
        }
    }

    func analyzeInterference(_ assembly: Assembly) async throws -> [InterferenceResult] {
        // Simplified interference detection
        // In production, would use proper collision detection
        var interferences: [InterferenceResult] = []

        for (index, part1) in assembly.parts.enumerated() {
            for (jndex, part2) in assembly.parts.enumerated() where jndex > index {
                if checkIntersection(part1, part2, assembly: assembly) {
                    interferences.append(InterferenceResult(
                        part1ID: part1.id,
                        part2ID: part2.id,
                        volume: 0.0
                    ))
                }
            }
        }

        return interferences
    }

    // MARK: - Private Helpers
    private func generatePrimitiveGeometry(type: PrimitiveType, dimensions: PrimitiveDimensions) async throws -> Data {
        // Placeholder: would generate actual mesh data
        return Data()
    }

    private func calculatePrimitiveProperties(type: PrimitiveType, dimensions: PrimitiveDimensions) -> (volume: Double, surfaceArea: Double) {
        switch type {
        case .cube:
            let side = dimensions.width
            return (
                volume: side * side * side,
                surfaceArea: 6 * side * side
            )
        case .cylinder:
            let r = dimensions.diameter / 2
            let h = dimensions.height
            return (
                volume: Double.pi * r * r * h,
                surfaceArea: 2 * Double.pi * r * (r + h)
            )
        case .sphere:
            let r = dimensions.diameter / 2
            return (
                volume: (4.0 / 3.0) * Double.pi * r * r * r,
                surfaceArea: 4 * Double.pi * r * r
            )
        }
    }

    private func checkIntersection(_ part1: Part, _ part2: Part, assembly: Assembly) -> Bool {
        // Simplified bounding box check
        // Production would use actual mesh intersection
        return false
    }
}

// MARK: - Supporting Types
enum PrimitiveType {
    case cube
    case cylinder
    case sphere

    var displayName: String {
        switch self {
        case .cube: return "Cube"
        case .cylinder: return "Cylinder"
        case .sphere: return "Sphere"
        }
    }
}

struct PrimitiveDimensions {
    var width: Double = 100 // mm
    var height: Double = 100
    var depth: Double = 100
    var diameter: Double = 50
}

enum GeometryOperation {
    case extrude(distance: Double)
    case revolve(angle: Double)
    case fillet(radius: Double)
    case chamfer(distance: Double)
    case shell(thickness: Double)
}

struct InterferenceResult {
    var part1ID: UUID
    var part2ID: UUID
    var volume: Double
}
