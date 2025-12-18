import Foundation
import SwiftData
import simd

// MARK: - Team Model
@Model
final class Team {
    // MARK: - Identity
    @Attribute(.unique) var id: UUID
    var name: String
    var description: String

    // MARK: - Leadership
    @Relationship(deleteRule: .nullify)
    var teamLead: Employee?

    // MARK: - Members
    @Relationship(deleteRule: .nullify, inverse: \Employee.team)
    var members: [Employee] = []

    // MARK: - Organization
    @Relationship(deleteRule: .nullify)
    var department: Department

    // MARK: - Team Health Metrics
    var cohesionScore: Double = 0.0 // 0-100
    var productivityScore: Double = 0.0 // 0-100
    var innovationScore: Double = 0.0 // 0-100
    var diversityIndex: Double = 0.0 // 0-100
    var collaborationScore: Double = 0.0 // 0-100

    // MARK: - Spatial Visualization
    var spatialPositionX: Float = 0.0
    var spatialPositionY: Float = 0.0
    var spatialPositionZ: Float = 0.0

    // MARK: - Timestamps
    var createdAt: Date
    var updatedAt: Date

    // MARK: - Initialization
    init(
        id: UUID = UUID(),
        name: String,
        description: String = "",
        department: Department
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.department = department
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Computed Properties
    var memberCount: Int {
        members.count
    }

    var spatialPosition: SIMD3<Float> {
        get { SIMD3<Float>(spatialPositionX, spatialPositionY, spatialPositionZ) }
        set {
            spatialPositionX = newValue.x
            spatialPositionY = newValue.y
            spatialPositionZ = newValue.z
        }
    }

    var avgEngagement: Double {
        guard !members.isEmpty else { return 0.0 }
        return members.map(\.engagementScore).reduce(0, +) / Double(members.count)
    }

    var avgPerformance: Double {
        guard !members.isEmpty else { return 0.0 }
        return members.map(\.performanceRating).reduce(0, +) / Double(members.count)
    }

    var teamHealth: Double {
        // Composite health score
        let weights: [(Double, Double)] = [
            (cohesionScore, 0.25),
            (productivityScore, 0.25),
            (innovationScore, 0.15),
            (diversityIndex, 0.15),
            (collaborationScore, 0.20)
        ]

        return weights.reduce(0.0) { $0 + ($1.0 * $1.1) }
    }

    var hasHighPerformers: Bool {
        members.contains { $0.performanceRating >= 90 }
    }

    var hasFlightRisks: Bool {
        members.contains { $0.isFlightRisk }
    }
}
