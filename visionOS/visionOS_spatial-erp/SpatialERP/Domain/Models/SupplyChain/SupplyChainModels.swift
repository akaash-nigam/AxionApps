import Foundation
import SwiftData

// MARK: - Inventory
@Model
final class Inventory {
    @Attribute(.unique) var id: UUID
    var itemCode: String
    var description: String
    var category: String
    var unit: String
    var quantityOnHand: Int
    var quantityReserved: Int
    var quantityOnOrder: Int
    var reorderPoint: Int
    var safetyStock: Int
    var location: String
    var warehouseZone: String?
    var binLocation: String?
    var unitCost: Decimal
    var lastStockDate: Date?

    // Spatial properties for 3D visualization
    var spatialPositionX: Float?
    var spatialPositionY: Float?
    var spatialPositionZ: Float?

    // Computed properties
    var availableQuantity: Int {
        quantityOnHand - quantityReserved
    }

    var totalValue: Decimal {
        unitCost * Decimal(quantityOnHand)
    }

    var needsReorder: Bool {
        availableQuantity < reorderPoint
    }

    var isLowStock: Bool {
        availableQuantity < safetyStock
    }

    var stockStatus: StockStatus {
        if availableQuantity <= 0 {
            return .outOfStock
        } else if isLowStock {
            return .low
        } else if needsReorder {
            return .reorderPoint
        } else {
            return .adequate
        }
    }

    init(
        id: UUID = UUID(),
        itemCode: String,
        description: String,
        category: String,
        unit: String,
        quantityOnHand: Int,
        quantityReserved: Int = 0,
        quantityOnOrder: Int = 0,
        reorderPoint: Int,
        safetyStock: Int,
        location: String,
        warehouseZone: String? = nil,
        binLocation: String? = nil,
        unitCost: Decimal,
        lastStockDate: Date? = nil
    ) {
        self.id = id
        self.itemCode = itemCode
        self.description = description
        self.category = category
        self.unit = unit
        self.quantityOnHand = quantityOnHand
        self.quantityReserved = quantityReserved
        self.quantityOnOrder = quantityOnOrder
        self.reorderPoint = reorderPoint
        self.safetyStock = safetyStock
        self.location = location
        self.warehouseZone = warehouseZone
        self.binLocation = binLocation
        self.unitCost = unitCost
        self.lastStockDate = lastStockDate
    }

    static func mock() -> Inventory {
        Inventory(
            itemCode: "ITEM-001",
            description: "Steel Bar 10mm x 2m",
            category: "Raw Materials",
            unit: "EA",
            quantityOnHand: 250,
            quantityReserved: 50,
            quantityOnOrder: 500,
            reorderPoint: 200,
            safetyStock: 100,
            location: "Warehouse A",
            warehouseZone: "Zone 1",
            binLocation: "A-1-05",
            unitCost: Decimal(25.50),
            lastStockDate: Date()
        )
    }
}

enum StockStatus: String, Codable {
    case outOfStock = "Out of Stock"
    case low = "Low Stock"
    case reorderPoint = "Reorder Point"
    case adequate = "Adequate"
    case excess = "Excess"
}

// MARK: - Supplier
@Model
final class Supplier {
    @Attribute(.unique) var id: UUID
    var code: String
    var name: String
    var contactName: String
    var email: String
    var phone: String
    var address: String
    var city: String
    var country: String
    var rating: Double // 0.0 to 5.0
    var leadTime: Int // in days
    var paymentTerms: String
    var currency: String
    var isActive: Bool
    var certifications: [String]

    @Relationship(deleteRule: .cascade) var purchaseOrders: [PurchaseOrder]

    // Geographic coordinates for spatial visualization
    var latitude: Double?
    var longitude: Double?

    // Performance metrics
    var onTimeDeliveryRate: Double = 100.0
    var qualityRejectionRate: Double = 0.0
    var totalOrdersPlaced: Int = 0

    init(
        id: UUID = UUID(),
        code: String,
        name: String,
        contactName: String,
        email: String,
        phone: String,
        address: String,
        city: String,
        country: String,
        rating: Double,
        leadTime: Int,
        paymentTerms: String,
        currency: String = "USD",
        isActive: Bool = true,
        certifications: [String] = [],
        latitude: Double? = nil,
        longitude: Double? = nil
    ) {
        self.id = id
        self.code = code
        self.name = name
        self.contactName = contactName
        self.email = email
        self.phone = phone
        self.address = address
        self.city = city
        self.country = country
        self.rating = rating
        self.leadTime = leadTime
        self.paymentTerms = paymentTerms
        self.currency = currency
        self.isActive = isActive
        self.certifications = certifications
        self.latitude = latitude
        self.longitude = longitude
        self.purchaseOrders = []
    }

    static func mock() -> Supplier {
        Supplier(
            code: "SUP-001",
            name: "Global Steel Inc.",
            contactName: "Jane Doe",
            email: "jane@globalsteel.com",
            phone: "+1-555-0100",
            address: "123 Industrial Way",
            city: "Pittsburgh",
            country: "USA",
            rating: 4.5,
            leadTime: 14,
            paymentTerms: "Net 30",
            currency: "USD",
            isActive: true,
            certifications: ["ISO 9001", "ISO 14001"],
            latitude: 40.4406,
            longitude: -79.9959
        )
    }
}

// MARK: - Purchase Order
@Model
final class PurchaseOrder {
    @Attribute(.unique) var id: UUID
    var orderNumber: String
    var orderDate: Date
    var expectedDeliveryDate: Date
    var actualDeliveryDate: Date?
    var status: PurchaseOrderStatus
    var totalAmount: Decimal
    var currency: String
    var notes: String?

    @Relationship(deleteRule: .nullify) var supplier: Supplier?
    @Relationship(deleteRule: .cascade) var lineItems: [PurchaseOrderLineItem]

    // Computed properties
    var isLate: Bool {
        guard actualDeliveryDate == nil else { return false }
        return Date() > expectedDeliveryDate
    }

    var daysUntilDelivery: Int {
        guard actualDeliveryDate == nil else { return 0 }
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: Date(), to: expectedDeliveryDate).day ?? 0
    }

    var isCompleted: Bool {
        status == .delivered || status == .closed
    }

    init(
        id: UUID = UUID(),
        orderNumber: String,
        orderDate: Date,
        expectedDeliveryDate: Date,
        actualDeliveryDate: Date? = nil,
        status: PurchaseOrderStatus = .pending,
        totalAmount: Decimal,
        currency: String = "USD",
        notes: String? = nil
    ) {
        self.id = id
        self.orderNumber = orderNumber
        self.orderDate = orderDate
        self.expectedDeliveryDate = expectedDeliveryDate
        self.actualDeliveryDate = actualDeliveryDate
        self.status = status
        self.totalAmount = totalAmount
        self.currency = currency
        self.notes = notes
        self.lineItems = []
    }

    static func mock() -> PurchaseOrder {
        PurchaseOrder(
            orderNumber: "PO-2024-5678",
            orderDate: Date().addingTimeInterval(-86400 * 7),
            expectedDeliveryDate: Date().addingTimeInterval(86400 * 7),
            status: .inTransit,
            totalAmount: Decimal(12750.00),
            currency: "USD"
        )
    }
}

enum PurchaseOrderStatus: String, Codable {
    case pending = "Pending"
    case approved = "Approved"
    case sent = "Sent to Supplier"
    case confirmed = "Confirmed"
    case inProduction = "In Production"
    case inTransit = "In Transit"
    case delivered = "Delivered"
    case closed = "Closed"
    case cancelled = "Cancelled"
}

// MARK: - Purchase Order Line Item
@Model
final class PurchaseOrderLineItem {
    @Attribute(.unique) var id: UUID
    var lineNumber: Int
    var itemCode: String
    var description: String
    var quantity: Int
    var unitPrice: Decimal
    var totalPrice: Decimal
    var receivedQuantity: Int = 0

    init(
        id: UUID = UUID(),
        lineNumber: Int,
        itemCode: String,
        description: String,
        quantity: Int,
        unitPrice: Decimal
    ) {
        self.id = id
        self.lineNumber = lineNumber
        self.itemCode = itemCode
        self.description = description
        self.quantity = quantity
        self.unitPrice = unitPrice
        self.totalPrice = unitPrice * Decimal(quantity)
    }
}

// MARK: - Supporting Types
struct SupplyChainKPIs: Codable {
    let inventoryValue: Decimal
    let inventoryTurnover: Double
    let fillRate: Double
    let onTimeDeliveryRate: Double
    let supplierPerformanceScore: Double
    let daysInventoryOnHand: Int
}

struct ReorderRecommendation: Codable {
    let itemCode: String
    let description: String
    let currentStock: Int
    let recommendedOrderQuantity: Int
    let estimatedCost: Decimal
    let priority: Priority

    enum Priority: String, Codable {
        case critical = "Critical"
        case high = "High"
        case medium = "Medium"
        case low = "Low"
    }
}

struct ShipmentStatus: Codable {
    let trackingNumber: String
    let status: String
    let currentLocation: String
    let estimatedDelivery: Date
    let lastUpdate: Date
    let events: [ShipmentEvent]

    struct ShipmentEvent: Codable {
        let timestamp: Date
        let location: String
        let description: String
    }
}
