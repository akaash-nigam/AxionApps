import Foundation
import SwiftData

/// Component Model - Represents a physical component of an asset
@Model
final class Component {
    @Attribute(.unique) var id: UUID
    var name: String
    var componentType: String
    var manufacturer: String?
    var modelNumber: String?
    var serialNumber: String?

    // Hierarchy
    var parentComponentId: UUID?
    @Relationship var subComponents: [Component]

    // 3D model
    var modelResourceName: String?
    var localTransformMatrix: [Float]  // 4x4 matrix as flat array

    // Lifecycle
    var installDate: Date?
    var lastMaintenanceDate: Date?
    var expectedLifespanHours: Double?
    var operatingHours: Double

    // Status
    var healthScore: Double
    var wearLevel: Double
    var isOperational: Bool

    // Maintenance
    var maintenanceSchedule: MaintenanceSchedule?
    var maintenanceHistory: [MaintenanceRecord]

    @Relationship(inverse: \DigitalTwin.components)
    var digitalTwin: DigitalTwin?

    init(
        id: UUID = UUID(),
        name: String,
        componentType: String,
        manufacturer: String? = nil,
        modelNumber: String? = nil,
        healthScore: Double = 100.0,
        wearLevel: Double = 0.0
    ) {
        self.id = id
        self.name = name
        self.componentType = componentType
        self.manufacturer = manufacturer
        self.modelNumber = modelNumber
        self.healthScore = healthScore
        self.wearLevel = wearLevel
        self.isOperational = true
        self.operatingHours = 0
        self.subComponents = []
        self.maintenanceHistory = []

        // Identity matrix
        self.localTransformMatrix = [
            1, 0, 0, 0,
            0, 1, 0, 0,
            0, 0, 1, 0,
            0, 0, 0, 1
        ]
    }

    // MARK: - Computed Properties

    var remainingLifeHours: Double? {
        guard let expectedLifespan = expectedLifespanHours else {
            return nil
        }
        return max(0, expectedLifespan - operatingHours)
    }

    var remainingLifePercentage: Double? {
        guard let expectedLifespan = expectedLifespanHours, expectedLifespan > 0 else {
            return nil
        }
        return (remainingLifeHours ?? 0) / expectedLifespan * 100
    }

    var statusColor: String {
        switch healthScore {
        case 90...100: return "green"
        case 70..<90: return "yellow"
        case 0..<70: return "red"
        default: return "gray"
        }
    }

    var maintenanceDue: Bool {
        guard let lastMaintenance = lastMaintenanceDate,
              let schedule = maintenanceSchedule else {
            return false
        }

        let nextMaintenance = Calendar.current.date(
            byAdding: .day,
            value: schedule.intervalDays,
            to: lastMaintenance
        )

        return nextMaintenance ?? Date() <= Date()
    }

    // MARK: - Methods

    func updateOperatingHours(_ hours: Double) {
        operatingHours += hours

        // Update wear level based on operating hours
        if let expectedLifespan = expectedLifespanHours {
            wearLevel = min(100, (operatingHours / expectedLifespan) * 100)
            healthScore = max(0, 100 - wearLevel)
        }
    }

    func performMaintenance(description: String, cost: Decimal? = nil) {
        let record = MaintenanceRecord(
            date: Date(),
            description: description,
            performedBy: "System",
            cost: cost
        )

        maintenanceHistory.append(record)
        lastMaintenanceDate = Date()

        // Improve health score slightly
        healthScore = min(100, healthScore + 5)
        wearLevel = max(0, wearLevel - 5)
    }
}

// MARK: - Supporting Types

struct MaintenanceSchedule: Codable {
    var type: MaintenanceType
    var intervalDays: Int
    var description: String?

    enum MaintenanceType: String, Codable {
        case preventive
        case predictive
        case corrective
        case breakdown
    }
}

struct MaintenanceRecord: Codable, Identifiable {
    var id: UUID = UUID()
    var date: Date
    var description: String
    var performedBy: String
    var cost: Decimal?
    var partsReplaced: [String]?
    var notes: String?
}

// MARK: - Extensions

extension Component {
    /// Create a sample component for testing
    static func sample(name: String, type: String) -> Component {
        let component = Component(
            name: name,
            componentType: type,
            manufacturer: "Industrial Components Ltd.",
            modelNumber: "IC-\(type.prefix(3).uppercased())-3000",
            healthScore: Double.random(in: 70...100),
            wearLevel: Double.random(in: 0...30)
        )

        component.serialNumber = "SN-\(UUID().uuidString.prefix(8))"
        component.installDate = Date().addingTimeInterval(-365 * 24 * 3600) // 1 year ago
        component.lastMaintenanceDate = Date().addingTimeInterval(-90 * 24 * 3600) // 90 days ago
        component.expectedLifespanHours = 50000
        component.operatingHours = Double.random(in: 10000...30000)

        component.maintenanceSchedule = MaintenanceSchedule(
            type: .preventive,
            intervalDays: 180,
            description: "Regular preventive maintenance"
        )

        return component
    }
}
