import Foundation
import SwiftData

@Model
final class ManufacturingProcess {
    @Attribute(.unique) var id: UUID
    var processName: String
    var processType: String // "CNC_Milling", "CNC_Turning", "3D_Printing", "Sheet_Metal"

    var partID: UUID
    var part: Part?

    // Process parameters
    var machineType: String
    var toolPaths: [ToolPathData]
    var setupTime: Double // minutes
    var cycleTime: Double // minutes
    var estimatedCost: Double

    // Quality parameters
    var targetTolerance: Double
    var targetSurfaceFinish: String

    // Optimization
    var isOptimized: Bool
    var optimizationScore: Double // 0-100

    var createdDate: Date
    var modifiedDate: Date
    var status: String // "planned", "simulated", "approved", "in_production"

    init(
        processName: String,
        processType: String,
        partID: UUID
    ) {
        self.id = UUID()
        self.processName = processName
        self.processType = processType
        self.partID = partID
        self.machineType = ""
        self.toolPaths = []
        self.setupTime = 0
        self.cycleTime = 0
        self.estimatedCost = 0
        self.targetTolerance = 0.05
        self.targetSurfaceFinish = "Ra 1.6 μm"
        self.isOptimized = false
        self.optimizationScore = 0
        self.createdDate = Date()
        self.modifiedDate = Date()
        self.status = "planned"
    }

    // MARK: - Methods
    var totalTime: Double {
        setupTime + cycleTime
    }

    func addToolPath(_ toolPath: ToolPathData) {
        toolPaths.append(toolPath)
        touch()
    }

    func touch() {
        modifiedDate = Date()
    }
}

// MARK: - Supporting Types
struct ToolPathData: Codable {
    var id: UUID = UUID()
    var name: String
    var toolType: String // "EndMill", "Drill", "Tap", etc.
    var toolDiameter: Double
    var feedRate: Double // mm/min
    var spindleSpeed: Double // RPM
    var depthOfCut: Double // mm
    var coordinates: [PathPoint]
    var estimatedTime: Double // minutes
}

struct PathPoint: Codable {
    var x: Double
    var y: Double
    var z: Double
    var feedRate: Double?
}
