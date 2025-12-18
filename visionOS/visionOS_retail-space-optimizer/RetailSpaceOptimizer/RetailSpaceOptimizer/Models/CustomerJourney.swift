import Foundation
import SwiftData

@Model
final class CustomerJourney {
    @Attribute(.unique) var id: UUID
    var customerPersona: CustomerPersona
    var entryPoint: SIMD3<Float>
    var exitPoint: SIMD3<Float>
    var pathPoints: [PathPoint]
    var dwellZones: [DwellZone]
    var purchasePoints: [PurchasePoint]
    var totalTime: TimeInterval
    var conversionValue: Decimal

    init(
        id: UUID = UUID(),
        customerPersona: CustomerPersona,
        entryPoint: SIMD3<Float>,
        exitPoint: SIMD3<Float>,
        pathPoints: [PathPoint] = [],
        dwellZones: [DwellZone] = [],
        purchasePoints: [PurchasePoint] = [],
        totalTime: TimeInterval,
        conversionValue: Decimal
    ) {
        self.id = id
        self.customerPersona = customerPersona
        self.entryPoint = entryPoint
        self.exitPoint = exitPoint
        self.pathPoints = pathPoints
        self.dwellZones = dwellZones
        self.purchasePoints = purchasePoints
        self.totalTime = totalTime
        self.conversionValue = conversionValue
    }
}

// MARK: - Customer Persona

struct CustomerPersona: Codable, Hashable {
    var demographicProfile: String
    var shoppingMission: ShoppingMission
    var timeConstraint: TimeConstraint
    var priceSensitivity: Float // 0-1
    var brandPreferences: [String]

    enum ShoppingMission: String, Codable {
        case browsing = "Browsing"
        case quickShop = "Quick Shop"
        case planned = "Planned Purchase"
        case recreational = "Recreational"
    }

    enum TimeConstraint: String, Codable {
        case none = "No Constraint"
        case moderate = "Moderate"
        case severe = "Time Limited"
    }
}

// MARK: - Path Point

struct PathPoint: Codable, Hashable, Identifiable {
    var id: UUID = UUID()
    var position: SIMD3<Float>
    var timestamp: TimeInterval
    var activity: CustomerActivity

    enum CustomerActivity: String, Codable {
        case walking = "Walking"
        case browsing = "Browsing"
        case examining = "Examining"
        case deciding = "Deciding"
        case purchasing = "Purchasing"
        case waiting = "Waiting"
    }
}

// MARK: - Dwell Zone

struct DwellZone: Codable, Hashable, Identifiable {
    var id: UUID = UUID()
    var position: SIMD3<Float>
    var duration: TimeInterval
    var engagement: Float // 0-1
    var zoneId: UUID?
}

// MARK: - Purchase Point

struct PurchasePoint: Codable, Hashable, Identifiable {
    var id: UUID = UUID()
    var position: SIMD3<Float>
    var timestamp: TimeInterval
    var productSKU: String
    var value: Decimal
}

// MARK: - Mock Data

extension CustomerJourney {
    static func mock() -> CustomerJourney {
        CustomerJourney(
            customerPersona: CustomerPersona(
                demographicProfile: "Adult 25-35, Urban",
                shoppingMission: .planned,
                timeConstraint: .moderate,
                priceSensitivity: 0.5,
                brandPreferences: ["RetailBrand", "PremiumCo"]
            ),
            entryPoint: SIMD3(10, 0, 0),
            exitPoint: SIMD3(10, 0, 30),
            pathPoints: [
                PathPoint(position: SIMD3(10, 0, 5), timestamp: 30, activity: .walking),
                PathPoint(position: SIMD3(5, 0, 10), timestamp: 90, activity: .browsing),
                PathPoint(position: SIMD3(5, 0, 15), timestamp: 240, activity: .examining),
                PathPoint(position: SIMD3(15, 0, 20), timestamp: 420, activity: .purchasing)
            ],
            dwellZones: [
                DwellZone(position: SIMD3(5, 0, 10), duration: 150, engagement: 0.8)
            ],
            purchasePoints: [
                PurchasePoint(position: SIMD3(15, 0, 20), timestamp: 420, productSKU: "APP-TS-001", value: 29.99)
            ],
            totalTime: 480, // 8 minutes
            conversionValue: 29.99
        )
    }

    static func mockArray(count: Int = 100) -> [CustomerJourney] {
        let missions: [CustomerPersona.ShoppingMission] = [.browsing, .quickShop, .planned, .recreational]

        return (0..<count).map { index in
            CustomerJourney(
                customerPersona: CustomerPersona(
                    demographicProfile: "Customer Profile \(index % 10)",
                    shoppingMission: missions[index % missions.count],
                    timeConstraint: index % 3 == 0 ? .severe : .moderate,
                    priceSensitivity: Float.random(in: 0.3...0.9),
                    brandPreferences: ["RetailBrand"]
                ),
                entryPoint: SIMD3(10, 0, 0),
                exitPoint: SIMD3(10, 0, 30),
                totalTime: TimeInterval.random(in: 180...900), // 3-15 minutes
                conversionValue: index % 4 == 0 ? Decimal(Double.random(in: 20...150)) : 0
            )
        }
    }
}
