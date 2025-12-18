import Foundation
import SwiftData

@Model
final class StoreAnalytics {
    @Attribute(.unique) var id: UUID
    var storeID: UUID
    var dateRange: DateInterval
    var trafficData: TrafficData
    var salesData: SalesData
    var heatmaps: [Heatmap]
    var customerJourneys: [CustomerJourney]
    var generatedAt: Date

    init(storeID: UUID, dateRange: DateInterval) {
        self.id = UUID()
        self.storeID = storeID
        self.dateRange = dateRange
        self.trafficData = TrafficData()
        self.salesData = SalesData()
        self.heatmaps = []
        self.customerJourneys = []
        self.generatedAt = Date()
    }
}

// MARK: - Traffic Data

struct TrafficData: Codable, Hashable {
    var totalVisitors: Int = 0
    var uniqueVisitors: Int = 0
    var averageDwellTime: TimeInterval = 0  // seconds
    var peakHours: [Int] = []  // hours of day (0-23)
    var conversionRate: Double = 0  // percentage (0-100)
    var bounceRate: Double = 0  // percentage (0-100)
    var repeatVisitorRate: Double = 0
    var entranceUsage: [String: Int] = [:]  // entrance name -> count

    var averageDwellMinutes: Double {
        averageDwellTime / 60.0
    }

    var conversionDecimal: Double {
        conversionRate / 100.0
    }
}

// MARK: - Sales Data

struct SalesData: Codable, Hashable {
    var totalRevenue: Decimal = 0
    var totalTransactions: Int = 0
    var salesPerSquareFoot: Decimal = 0
    var averageBasketSize: Decimal = 0
    var averageItemsPerBasket: Double = 0
    var topProducts: [ProductPerformance] = []
    var categoryPerformance: [CategoryPerformance] = []
    var hourlyRevenue: [Int: Decimal] = [:]  // hour -> revenue
    var dailyRevenue: [Date: Decimal] = [:]

    var averageTransactionValue: Decimal {
        guard totalTransactions > 0 else { return 0 }
        return totalRevenue / Decimal(totalTransactions)
    }
}

// MARK: - Heatmap

struct Heatmap: Codable, Hashable, Identifiable {
    var id: UUID = UUID()
    var type: HeatmapType
    var gridResolution: Int  // cells per meter
    var data: [[Double]]  // 2D grid of values (0.0 to 1.0)
    var bounds: BoundingBox
    var timestamp: Date
    var metadata: HeatmapMetadata?

    var maxValue: Double {
        data.flatMap { $0 }.max() ?? 0
    }

    var minValue: Double {
        data.flatMap { $0 }.min() ?? 0
    }

    func normalizedValue(row: Int, col: Int) -> Double {
        guard row < data.count, col < data[row].count else { return 0 }
        let value = data[row][col]
        let range = maxValue - minValue
        return range > 0 ? (value - minValue) / range : 0
    }
}

enum HeatmapType: String, Codable, CaseIterable {
    case traffic
    case dwell
    case conversion
    case sales
    case engagement
    case abandonment

    var displayName: String {
        switch self {
        case .traffic: return "Traffic"
        case .dwell: return "Dwell Time"
        case .conversion: return "Conversion"
        case .sales: return "Sales"
        case .engagement: return "Engagement"
        case .abandonment: return "Abandonment"
        }
    }

    var icon: String {
        switch self {
        case .traffic: return "figure.walk"
        case .dwell: return "clock.fill"
        case .conversion: return "cart.fill"
        case .sales: return "dollarsign.circle.fill"
        case .engagement: return "hand.tap.fill"
        case .abandonment: return "xmark.circle.fill"
        }
    }
}

struct HeatmapMetadata: Codable, Hashable {
    var totalSamples: Int
    var samplingRate: TimeInterval
    var confidenceLevel: Double
    var notes: String?
}

// MARK: - Customer Journey

struct CustomerJourney: Codable, Hashable, Identifiable {
    var id: UUID = UUID()
    var customerID: String  // Anonymized ID
    var entryTime: Date
    var exitTime: Date
    var path: [PathPoint]
    var interactions: [Interaction]
    var purchasesMade: [PurchaseEvent]
    var dwellPoints: [DwellPoint]
    var totalDistance: Double  // meters
    var departmentVisits: [String]

    var duration: TimeInterval {
        exitTime.timeIntervalSince(entryTime)
    }

    var durationMinutes: Double {
        duration / 60.0
    }

    var converted: Bool {
        !purchasesMade.isEmpty
    }

    var averageSpeed: Double {
        duration > 0 ? totalDistance / duration : 0
    }
}

struct PathPoint: Codable, Hashable {
    var position: SIMD3<Double>
    var timestamp: TimeInterval  // offset from journey start
}

struct Interaction: Codable, Hashable, Identifiable {
    var id: UUID = UUID()
    var type: InteractionType
    var productID: UUID?
    var fixtureID: UUID?
    var position: SIMD3<Double>
    var timestamp: TimeInterval
    var duration: TimeInterval

    var durationSeconds: Double {
        duration
    }
}

enum InteractionType: String, Codable, CaseIterable {
    case browse
    case pickup
    case examine
    case compare
    case putBack
    case addToCart
    case scan
    case tryOn

    var displayName: String {
        rawValue.capitalized
    }
}

struct DwellPoint: Codable, Hashable {
    var position: SIMD3<Double>
    var startTime: TimeInterval
    var endTime: TimeInterval
    var productID: UUID?

    var duration: TimeInterval {
        endTime - startTime
    }

    var durationSeconds: Double {
        duration
    }
}

struct PurchaseEvent: Codable, Hashable {
    var productID: UUID
    var quantity: Int
    var price: Decimal
    var timestamp: TimeInterval

    var totalAmount: Decimal {
        Decimal(quantity) * price
    }
}

// MARK: - Performance Metrics

struct PerformanceMetrics: Codable {
    var salesPerSquareFoot: Decimal
    var conversionRate: Double
    var averageBasketSize: Decimal
    var trafficCount: Int
    var dwellTime: TimeInterval
    var productDiscoveryRate: Double
    var customerSatisfactionScore: Double?

    var period: DateInterval
    var comparisonToPrevious: MetricsComparison?
}

struct MetricsComparison: Codable {
    var salesChange: Double  // percentage
    var conversionChange: Double
    var trafficChange: Double
    var dwellTimeChange: Double

    var overallTrend: Trend {
        let changes = [salesChange, conversionChange, trafficChange, dwellTimeChange]
        let average = changes.reduce(0, +) / Double(changes.count)
        if average > 5 { return .improving }
        if average < -5 { return .declining }
        return .stable
    }
}

enum Trend: String, Codable {
    case improving
    case stable
    case declining
}
