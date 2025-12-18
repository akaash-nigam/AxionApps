import Foundation
import SwiftData

@Model
final class Product {
    @Attribute(.unique) var id: UUID
    var sku: String
    var name: String
    var category: String
    var subcategory: String?
    var price: Decimal
    var cost: Decimal?
    var dimensions: ProductDimensions
    var weight: Double?  // kilograms
    var modelAsset: String?
    var imageAsset: String?
    var salesVelocity: Double  // units per day
    var margin: Decimal
    var createdAt: Date
    var updatedAt: Date

    // Relationship
    var store: Store?

    init(sku: String, name: String, category: String, price: Decimal) {
        self.id = UUID()
        self.sku = sku
        self.name = name
        self.category = category
        self.price = price
        self.dimensions = ProductDimensions(width: 0.1, height: 0.1, depth: 0.1)
        self.salesVelocity = 0
        self.margin = 0
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Computed Properties
    var marginPercentage: Double {
        guard price > 0 else { return 0 }
        return Double(truncating: (margin / price) as NSNumber) * 100
    }

    var revenue: Decimal {
        Decimal(salesVelocity) * price
    }

    var isHighPerformer: Bool {
        salesVelocity > 5.0  // More than 5 units per day
    }

    var isSlowMover: Bool {
        salesVelocity < 0.5  // Less than 0.5 units per day
    }

    var profitPerDay: Decimal {
        Decimal(salesVelocity) * margin
    }
}

// MARK: - Supporting Types

struct ProductDimensions: Codable, Hashable {
    var width: Double   // meters
    var height: Double  // meters
    var depth: Double   // meters

    var volume: Double {
        width * height * depth
    }

    var displayArea: Double {
        width * height
    }
}

struct ProductPerformance: Codable, Identifiable {
    var id: UUID = UUID()
    var productID: UUID
    var sku: String
    var name: String
    var salesCount: Int
    var revenue: Decimal
    var margin: Decimal
    var conversionRate: Double
    var averageDwellTime: TimeInterval
    var returnRate: Double
    var periodStart: Date
    var periodEnd: Date

    var salesPerDay: Double {
        let days = periodEnd.timeIntervalSince(periodStart) / 86400
        return days > 0 ? Double(salesCount) / days : 0
    }

    var profitMarginPercentage: Double {
        guard revenue > 0 else { return 0 }
        return Double(truncating: (margin / revenue) as NSNumber) * 100
    }
}

struct CategoryPerformance: Codable, Identifiable {
    var id: UUID = UUID()
    var category: String
    var subcategory: String?
    var salesCount: Int
    var revenue: Decimal
    var margin: Decimal
    var averagePrice: Decimal
    var uniqueProducts: Int
    var topProducts: [ProductPerformance]
}
