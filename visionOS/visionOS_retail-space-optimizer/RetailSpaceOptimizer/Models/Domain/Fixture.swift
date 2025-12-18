import Foundation
import SwiftData

@Model
final class Fixture {
    @Attribute(.unique) var id: UUID
    var type: FixtureType
    var name: String
    var dimensions: FixtureDimensions
    var position: SIMD3<Double>
    var rotation: SIMD3<Double>  // Euler angles in radians
    var capacity: Int
    var products: [ProductPlacement]
    var modelAsset: String  // Reference to 3D model file
    var isLocked: Bool
    var createdAt: Date
    var updatedAt: Date

    // Relationship
    var store: Store?

    init(type: FixtureType, name: String, dimensions: FixtureDimensions) {
        self.id = UUID()
        self.type = type
        self.name = name
        self.dimensions = dimensions
        self.position = SIMD3(0, 0, 0)
        self.rotation = SIMD3(0, 0, 0)
        self.capacity = 0
        self.products = []
        self.modelAsset = type.defaultModelAsset
        self.isLocked = false
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Computed Properties
    var bounds: BoundingBox {
        let halfSize = SIMD3(
            dimensions.width / 2,
            dimensions.height / 2,
            dimensions.depth / 2
        )
        return BoundingBox(
            min: position - halfSize,
            max: position + halfSize
        )
    }

    var occupancy: Double {
        guard capacity > 0 else { return 0 }
        return Double(products.count) / Double(capacity)
    }

    var isEmpty: Bool {
        products.isEmpty
    }

    // MARK: - Methods
    func canAccommodate(product: Product, count: Int = 1) -> Bool {
        let availableSpace = capacity - products.count
        return availableSpace >= count
    }

    func addProduct(_ placement: ProductPlacement) {
        guard canAccommodate(product: Product(sku: "", name: "", category: "", price: 0)) else {
            return
        }
        products.append(placement)
        updatedAt = Date()
    }

    func removeProduct(at index: Int) {
        guard index < products.count else { return }
        products.remove(at: index)
        updatedAt = Date()
    }
}

// MARK: - Supporting Types

enum FixtureType: String, Codable, CaseIterable {
    case shelf
    case rack
    case display
    case endcap
    case table
    case mannequin
    case gondola
    case refrigerator
    case checkoutCounter
    case custom

    var defaultModelAsset: String {
        switch self {
        case .shelf: return "Models/shelf_standard"
        case .rack: return "Models/rack_clothing"
        case .display: return "Models/display_glass"
        case .endcap: return "Models/endcap_promotional"
        case .table: return "Models/table_display"
        case .mannequin: return "Models/mannequin"
        case .gondola: return "Models/gondola"
        case .refrigerator: return "Models/refrigerator"
        case .checkoutCounter: return "Models/checkout_counter"
        case .custom: return "Models/placeholder"
        }
    }

    var displayName: String {
        switch self {
        case .shelf: return "Shelf"
        case .rack: return "Clothing Rack"
        case .display: return "Display"
        case .endcap: return "Endcap"
        case .table: return "Table"
        case .mannequin: return "Mannequin"
        case .gondola: return "Gondola"
        case .refrigerator: return "Refrigerator"
        case .checkoutCounter: return "Checkout Counter"
        case .custom: return "Custom"
        }
    }

    var icon: String {
        switch self {
        case .shelf: return "rectangle.stack.fill"
        case .rack: return "hanger"
        case .display: return "square.grid.2x2.fill"
        case .endcap: return "rectangle.portrait.fill"
        case .table: return "square.fill"
        case .mannequin: return "figure.stand"
        case .gondola: return "rectangle.3.group.fill"
        case .refrigerator: return "refrigerator.fill"
        case .checkoutCounter: return "cart.fill"
        case .custom: return "cube.fill"
        }
    }
}

struct FixtureDimensions: Codable, Hashable {
    var width: Double   // meters
    var height: Double  // meters
    var depth: Double   // meters

    var volume: Double {
        width * height * depth
    }

    static let standard = FixtureDimensions(width: 1.2, height: 2.0, depth: 0.5)
    static let compact = FixtureDimensions(width: 0.8, height: 1.5, depth: 0.4)
    static let large = FixtureDimensions(width: 2.0, height: 2.5, depth: 0.6)
}

struct ProductPlacement: Codable, Hashable, Identifiable {
    var id: UUID = UUID()
    var productID: UUID
    var position: SIMD3<Double>  // Relative to fixture origin
    var facingCount: Int  // Number of products facing forward
    var stockDepth: Int   // Number of products deep
    var createdAt: Date

    init(productID: UUID, position: SIMD3<Double>, facingCount: Int = 1, stockDepth: Int = 1) {
        self.productID = productID
        self.position = position
        self.facingCount = facingCount
        self.stockDepth = stockDepth
        self.createdAt = Date()
    }

    var totalUnits: Int {
        facingCount * stockDepth
    }
}
