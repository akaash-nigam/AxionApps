import Foundation
import SwiftData

@Model
final class PerformanceMetric {
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    var salesPerSquareFoot: Decimal
    var trafficCount: Int
    var dwellTime: TimeInterval
    var conversionRate: Float
    var averageBasketSize: Decimal
    var customerSatisfaction: Float
    var period: Period

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        salesPerSquareFoot: Decimal,
        trafficCount: Int,
        dwellTime: TimeInterval,
        conversionRate: Float,
        averageBasketSize: Decimal,
        customerSatisfaction: Float,
        period: Period = .daily
    ) {
        self.id = id
        self.timestamp = timestamp
        self.salesPerSquareFoot = salesPerSquareFoot
        self.trafficCount = trafficCount
        self.dwellTime = dwellTime
        self.conversionRate = conversionRate
        self.averageBasketSize = averageBasketSize
        self.customerSatisfaction = customerSatisfaction
        self.period = period
    }

    enum Period: String, Codable {
        case hourly, daily, weekly, monthly
    }
}

// MARK: - Heat Map Data

struct HeatMapData: Codable {
    var gridResolution: SIMD2<Int>
    var dataPoints: [[Float]]  // 2D array of intensity values
    var metric: HeatMapMetric
    var timeRange: DateInterval

    enum HeatMapMetric: String, Codable {
        case traffic = "Traffic"
        case sales = "Sales"
        case dwellTime = "Dwell Time"
        case conversion = "Conversion"
        case engagement = "Engagement"
    }
}

// MARK: - Mock Data

extension PerformanceMetric {
    static func mock() -> PerformanceMetric {
        PerformanceMetric(
            salesPerSquareFoot: 2340.50,
            trafficCount: 1245,
            dwellTime: 18 * 60, // 18 minutes
            conversionRate: 0.245,
            averageBasketSize: 87.50,
            customerSatisfaction: 4.2,
            period: .daily
        )
    }

    static func mockArray(count: Int = 30) -> [PerformanceMetric] {
        let calendar = Calendar.current
        let now = Date()

        return (0..<count).map { index in
            let date = calendar.date(byAdding: .day, value: -index, to: now)!

            return PerformanceMetric(
                timestamp: date,
                salesPerSquareFoot: Decimal(Double.random(in: 2000...2500)),
                trafficCount: Int.random(in: 1000...1500),
                dwellTime: TimeInterval.random(in: 900...1800), // 15-30 min
                conversionRate: Float.random(in: 0.20...0.30),
                averageBasketSize: Decimal(Double.random(in: 70...100)),
                customerSatisfaction: Float.random(in: 3.8...4.5),
                period: .daily
            )
        }
    }
}
