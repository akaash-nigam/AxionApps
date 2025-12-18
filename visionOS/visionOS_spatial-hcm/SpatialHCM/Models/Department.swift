import Foundation
import SwiftData
import simd

// MARK: - Department Model
@Model
final class Department {
    // MARK: - Identity
    @Attribute(.unique) var id: UUID
    var name: String
    var description: String
    var code: String // e.g., "ENG", "HR", "SALES"

    // MARK: - Leadership
    @Relationship(deleteRule: .nullify)
    var headOfDepartment: Employee?

    // MARK: - Structure
    @Relationship(deleteRule: .nullify, inverse: \Team.department)
    var teams: [Team] = []

    @Relationship(deleteRule: .nullify, inverse: \Employee.department)
    var employees: [Employee] = []

    @Relationship(deleteRule: .nullify)
    var parentDepartment: Department?

    @Relationship(deleteRule: .nullify, inverse: \Department.parentDepartment)
    var childDepartments: [Department] = []

    // MARK: - Metrics
    var headcount: Int {
        employees.count
    }

    var budget: Decimal?
    var avgEngagement: Double = 0.0
    var avgPerformance: Double = 0.0
    var turnoverRate: Double = 0.0

    // MARK: - Spatial Visualization
    var spatialPositionX: Float = 0.0
    var spatialPositionY: Float = 0.0
    var spatialPositionZ: Float = 0.0

    var colorHex: String = "#4A90E2"
    var icon: String = "building.2"

    // MARK: - Timestamps
    var createdAt: Date
    var updatedAt: Date

    // MARK: - Initialization
    init(
        id: UUID = UUID(),
        name: String,
        code: String,
        description: String = ""
    ) {
        self.id = id
        self.name = name
        self.code = code
        self.description = description
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Computed Properties
    var spatialPosition: SIMD3<Float> {
        get { SIMD3<Float>(spatialPositionX, spatialPositionY, spatialPositionZ) }
        set {
            spatialPositionX = newValue.x
            spatialPositionY = newValue.y
            spatialPositionZ = newValue.z
        }
    }

    var teamCount: Int {
        teams.count
    }

    var healthScore: Double {
        // Composite score of engagement, performance, turnover
        let engagementWeight = 0.4
        let performanceWeight = 0.4
        let retentionWeight = 0.2

        let retentionScore = max(0, 100 - (turnoverRate * 10))

        return (avgEngagement * engagementWeight) +
               (avgPerformance * performanceWeight) +
               (retentionScore * retentionWeight)
    }
}
