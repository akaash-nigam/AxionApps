import Foundation
import SwiftData

@Model
final class StoreZone {
    @Attribute(.unique) var id: UUID
    var name: String
    var zoneType: ZoneType
    var boundary: [SIMD2<Float>] // Polygon points
    var category: String
    var targetDemographic: String

    @Relationship(deleteRule: .cascade)
    var performanceMetric: PerformanceMetric?

    var area: Float {
        calculateArea(boundary)
    }

    init(
        id: UUID = UUID(),
        name: String,
        zoneType: ZoneType,
        boundary: [SIMD2<Float>],
        category: String = "",
        targetDemographic: String = ""
    ) {
        self.id = id
        self.name = name
        self.zoneType = zoneType
        self.boundary = boundary
        self.category = category
        self.targetDemographic = targetDemographic
    }

    private func calculateArea(_ polygon: [SIMD2<Float>]) -> Float {
        guard polygon.count >= 3 else { return 0 }

        var area: Float = 0
        for i in 0..<polygon.count {
            let j = (i + 1) % polygon.count
            area += polygon[i].x * polygon[j].y
            area -= polygon[j].x * polygon[i].y
        }
        return abs(area) / 2.0
    }
}

// MARK: - Zone Type

enum ZoneType: String, Codable, CaseIterable {
    case sales = "Sales"
    case checkout = "Checkout"
    case entrance = "Entrance"
    case service = "Service"
    case storage = "Storage"
    case display = "Display"
    case fitting = "Fitting Rooms"
}

// MARK: - Mock Data

extension StoreZone {
    static func mock() -> StoreZone {
        StoreZone(
            name: "Zone A: Apparel",
            zoneType: .sales,
            boundary: [
                SIMD2(0, 0),
                SIMD2(10, 0),
                SIMD2(10, 15),
                SIMD2(0, 15)
            ],
            category: "Apparel",
            targetDemographic: "Adults 25-45"
        )
    }

    static func mockArray(count: Int = 5) -> [StoreZone] {
        let types: [ZoneType] = [.sales, .checkout, .display, .service, .entrance]
        let categories = ["Apparel", "Footwear", "Accessories", "Electronics", "Services"]

        return (0..<count).map { index in
            StoreZone(
                name: "Zone \(Character(UnicodeScalar(65 + index)!)): \(categories[index])",
                zoneType: types[index],
                boundary: [
                    SIMD2(Float(index) * 5, 0),
                    SIMD2(Float(index + 1) * 5, 0),
                    SIMD2(Float(index + 1) * 5, 10),
                    SIMD2(Float(index) * 5, 10)
                ],
                category: categories[index],
                targetDemographic: "All ages"
            )
        }
    }
}
