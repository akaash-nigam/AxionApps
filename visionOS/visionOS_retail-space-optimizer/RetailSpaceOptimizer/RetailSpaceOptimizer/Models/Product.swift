import Foundation
import SwiftData

@Model
final class Product {
    @Attribute(.unique) var sku: String
    var name: String
    var category: String
    var subcategory: String
    var brand: String
    var price: Decimal
    var dimensions: SIMD3<Float>
    var thumbnail: String
    var model3D: String?
    var salesVelocity: Float // items per day
    var margin: Float // percentage
    var stockLevel: Int

    init(
        sku: String,
        name: String,
        category: String,
        subcategory: String = "",
        brand: String,
        price: Decimal,
        dimensions: SIMD3<Float>,
        thumbnail: String,
        model3D: String? = nil,
        salesVelocity: Float = 0,
        margin: Float = 0,
        stockLevel: Int = 0
    ) {
        self.sku = sku
        self.name = name
        self.category = category
        self.subcategory = subcategory
        self.brand = brand
        self.price = price
        self.dimensions = dimensions
        self.thumbnail = thumbnail
        self.model3D = model3D
        self.salesVelocity = salesVelocity
        self.margin = margin
        self.stockLevel = stockLevel
    }
}

// MARK: - Mock Data

extension Product {
    static func mock() -> Product {
        Product(
            sku: "APP-TS-001",
            name: "Classic T-Shirt",
            category: "Apparel",
            subcategory: "Tops",
            brand: "RetailBrand",
            price: 29.99,
            dimensions: SIMD3(0.3, 0.4, 0.02),
            thumbnail: "tshirt_thumbnail",
            model3D: "tshirt_model",
            salesVelocity: 5.2,
            margin: 45.0,
            stockLevel: 120
        )
    }

    static func mockArray(count: Int = 50) -> [Product] {
        let categories = ["Apparel", "Footwear", "Accessories", "Electronics"]
        let brands = ["RetailBrand", "PremiumCo", "ValueLine", "TrendSetter"]

        return (0..<count).map { index in
            Product(
                sku: "PRD-\(String(format: "%03d", index))",
                name: "Product \(index + 1)",
                category: categories[index % categories.count],
                brand: brands[index % brands.count],
                price: Decimal(Double.random(in: 19.99...199.99)),
                dimensions: SIMD3(0.3, 0.4, 0.2),
                thumbnail: "product_\(index)_thumb",
                model3D: "product_\(index)_model",
                salesVelocity: Float.random(in: 1...10),
                margin: Float.random(in: 20...60),
                stockLevel: Int.random(in: 0...200)
            )
        }
    }
}
