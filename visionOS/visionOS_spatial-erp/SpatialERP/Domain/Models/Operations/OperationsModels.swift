import Foundation
import SwiftData

// MARK: - Production Order
@Model
final class ProductionOrder {
    @Attribute(.unique) var id: UUID
    var orderNumber: String
    var productCode: String
    var productName: String
    var quantity: Int
    var status: ProductionStatus
    var priority: Int // 1 = highest
    var startDate: Date
    var plannedCompletionDate: Date
    var actualCompletionDate: Date?
    var completedQuantity: Int = 0

    @Relationship(deleteRule: .nullify) var workCenter: WorkCenter?
    @Relationship(deleteRule: .cascade) var operations: [Operation]

    // Spatial properties
    var spatialPositionX: Float?
    var spatialPositionY: Float?
    var spatialPositionZ: Float?

    // Computed properties
    var completionPercentage: Double {
        guard quantity > 0 else { return 0 }
        return Double(completedQuantity) / Double(quantity) * 100
    }

    var isLate: Bool {
        guard actualCompletionDate == nil else { return false }
        return Date() > plannedCompletionDate
    }

    var daysRemaining: Int {
        guard actualCompletionDate == nil else { return 0 }
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: Date(), to: plannedCompletionDate).day ?? 0
    }

    init(
        id: UUID = UUID(),
        orderNumber: String,
        productCode: String,
        productName: String,
        quantity: Int,
        status: ProductionStatus = .planned,
        priority: Int = 3,
        startDate: Date,
        plannedCompletionDate: Date,
        actualCompletionDate: Date? = nil,
        completedQuantity: Int = 0
    ) {
        self.id = id
        self.orderNumber = orderNumber
        self.productCode = productCode
        self.productName = productName
        self.quantity = quantity
        self.status = status
        self.priority = priority
        self.startDate = startDate
        self.plannedCompletionDate = plannedCompletionDate
        self.actualCompletionDate = actualCompletionDate
        self.completedQuantity = completedQuantity
        self.operations = []
    }

    static func mock() -> ProductionOrder {
        ProductionOrder(
            orderNumber: "PO-2024-1234",
            productCode: "PROD-001",
            productName: "Widget A",
            quantity: 1000,
            status: .inProgress,
            priority: 1,
            startDate: Date().addingTimeInterval(-86400 * 5),
            plannedCompletionDate: Date().addingTimeInterval(86400 * 2),
            completedQuantity: 650
        )
    }
}

enum ProductionStatus: String, Codable {
    case planned = "Planned"
    case released = "Released"
    case inProgress = "In Progress"
    case onHold = "On Hold"
    case completed = "Completed"
    case cancelled = "Cancelled"
}

// MARK: - Work Center
@Model
final class WorkCenter {
    @Attribute(.unique) var id: UUID
    var code: String
    var name: String
    var capacity: Int // units per hour
    var currentLoad: Int // current units assigned
    var efficiency: Double // 0.0 to 1.0
    var status: WorkCenterStatus
    var location: String

    @Relationship(inverse: \ProductionOrder.workCenter) var orders: [ProductionOrder]
    @Relationship(deleteRule: .cascade) var equipment: [Equipment]

    // Spatial properties
    var spatialPositionX: Float?
    var spatialPositionY: Float?
    var spatialPositionZ: Float?

    // Computed properties
    var utilizationPercentage: Double {
        guard capacity > 0 else { return 0 }
        return Double(currentLoad) / Double(capacity) * 100
    }

    var isOverloaded: Bool {
        currentLoad > capacity
    }

    var effectiveCapacity: Int {
        Int(Double(capacity) * efficiency)
    }

    init(
        id: UUID = UUID(),
        code: String,
        name: String,
        capacity: Int,
        currentLoad: Int = 0,
        efficiency: Double = 1.0,
        status: WorkCenterStatus = .operational,
        location: String
    ) {
        self.id = id
        self.code = code
        self.name = name
        self.capacity = capacity
        self.currentLoad = currentLoad
        self.efficiency = efficiency
        self.status = status
        self.location = location
        self.orders = []
        self.equipment = []
    }

    static func mock() -> WorkCenter {
        WorkCenter(
            code: "WC-001",
            name: "Assembly Line A",
            capacity: 100,
            currentLoad: 85,
            efficiency: 0.92,
            status: .operational,
            location: "Building 1"
        )
    }
}

enum WorkCenterStatus: String, Codable {
    case operational = "Operational"
    case maintenance = "Maintenance"
    case breakdown = "Breakdown"
    case offline = "Offline"
}

// MARK: - Equipment
@Model
final class Equipment {
    @Attribute(.unique) var id: UUID
    var assetNumber: String
    var name: String
    var type: String
    var manufacturer: String
    var model: String
    var serialNumber: String
    var installDate: Date
    var lastMaintenanceDate: Date?
    var nextMaintenanceDate: Date?
    var status: EquipmentStatus
    var oeeScore: Double // Overall Equipment Effectiveness

    @Relationship(deleteRule: .nullify) var workCenter: WorkCenter?

    // Health metrics
    var hoursOperated: Int = 0
    var hoursSinceLastMaintenance: Int = 0
    var failureCount: Int = 0

    // Computed properties
    var needsMaintenance: Bool {
        guard let nextDate = nextMaintenanceDate else { return false }
        return Date() >= nextDate
    }

    var healthScore: Double {
        // Simple health calculation based on OEE and maintenance status
        var score = oeeScore
        if needsMaintenance { score *= 0.8 }
        if failureCount > 5 { score *= 0.9 }
        return score
    }

    init(
        id: UUID = UUID(),
        assetNumber: String,
        name: String,
        type: String,
        manufacturer: String,
        model: String,
        serialNumber: String,
        installDate: Date,
        lastMaintenanceDate: Date? = nil,
        nextMaintenanceDate: Date? = nil,
        status: EquipmentStatus = .operational,
        oeeScore: Double = 0.85
    ) {
        self.id = id
        self.assetNumber = assetNumber
        self.name = name
        self.type = type
        self.manufacturer = manufacturer
        self.model = model
        self.serialNumber = serialNumber
        self.installDate = installDate
        self.lastMaintenanceDate = lastMaintenanceDate
        self.nextMaintenanceDate = nextMaintenanceDate
        self.status = status
        self.oeeScore = oeeScore
    }

    static func mock() -> Equipment {
        Equipment(
            assetNumber: "EQ-2024-001",
            name: "CNC Machine #7",
            type: "CNC Milling Machine",
            manufacturer: "Haas Automation",
            model: "VF-4SS",
            serialNumber: "SN123456789",
            installDate: Date().addingTimeInterval(-86400 * 730), // 2 years ago
            lastMaintenanceDate: Date().addingTimeInterval(-86400 * 30), // 30 days ago
            nextMaintenanceDate: Date().addingTimeInterval(86400 * 60), // 60 days from now
            status: .operational,
            oeeScore: 0.88
        )
    }
}

enum EquipmentStatus: String, Codable {
    case operational = "Operational"
    case maintenance = "Maintenance"
    case breakdown = "Breakdown"
    case idle = "Idle"
    case offline = "Offline"
}

// MARK: - Operation
@Model
final class Operation {
    @Attribute(.unique) var id: UUID
    var sequenceNumber: Int
    var name: String
    var description: String
    var standardTime: TimeInterval // in seconds
    var actualTime: TimeInterval?
    var status: OperationStatus
    var startTime: Date?
    var endTime: Date?

    var isComplete: Bool {
        status == .completed
    }

    var isLate: Bool {
        guard let start = startTime, actualTime == nil else { return false }
        return Date().timeIntervalSince(start) > standardTime
    }

    init(
        id: UUID = UUID(),
        sequenceNumber: Int,
        name: String,
        description: String,
        standardTime: TimeInterval,
        actualTime: TimeInterval? = nil,
        status: OperationStatus = .pending,
        startTime: Date? = nil,
        endTime: Date? = nil
    ) {
        self.id = id
        self.sequenceNumber = sequenceNumber
        self.name = name
        self.description = description
        self.standardTime = standardTime
        self.actualTime = actualTime
        self.status = status
        self.startTime = startTime
        self.endTime = endTime
    }
}

enum OperationStatus: String, Codable {
    case pending = "Pending"
    case inProgress = "In Progress"
    case completed = "Completed"
    case skipped = "Skipped"
}

// MARK: - Supporting Types
struct OperationalKPIs: Codable {
    let totalOrders: Int
    let completedOrders: Int
    let onTimeDelivery: Double
    let averageOEE: Double
    let utilizationRate: Double
    let qualityRate: Double
}

struct MaintenancePrediction: Codable {
    let equipmentId: UUID
    let predictedFailureDate: Date
    let confidence: Double
    let recommendedAction: String
    let estimatedCost: Decimal
}
