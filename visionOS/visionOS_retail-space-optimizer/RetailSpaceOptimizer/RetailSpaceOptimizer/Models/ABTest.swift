import Foundation
import SwiftData

@Model
final class ABTest {
    @Attribute(.unique) var id: UUID
    var name: String
    var testDescription: String
    var layoutAId: UUID
    var layoutBId: UUID
    var startDate: Date
    var endDate: Date?
    var status: TestStatus
    var winningLayoutId: UUID?

    @Relationship(deleteRule: .nullify)
    var metricsA: PerformanceMetric?

    @Relationship(deleteRule: .nullify)
    var metricsB: PerformanceMetric?

    var confidenceLevel: Float?
    var improvementPercentage: Float?

    init(
        id: UUID = UUID(),
        name: String,
        testDescription: String,
        layoutAId: UUID,
        layoutBId: UUID,
        startDate: Date = Date(),
        endDate: Date? = nil,
        status: TestStatus = .planned,
        winningLayoutId: UUID? = nil,
        confidenceLevel: Float? = nil,
        improvementPercentage: Float? = nil
    ) {
        self.id = id
        self.name = name
        self.testDescription = testDescription
        self.layoutAId = layoutAId
        self.layoutBId = layoutBId
        self.startDate = startDate
        self.endDate = endDate
        self.status = status
        self.winningLayoutId = winningLayoutId
        self.confidenceLevel = confidenceLevel
        self.improvementPercentage = improvementPercentage
    }

    func analyzeResults() {
        guard let metricsA = metricsA,
              let metricsB = metricsB,
              status == .completed else {
            return
        }

        // Simple analysis - compare sales per square foot
        let salesA = Float(truncating: metricsA.salesPerSquareFoot as NSNumber)
        let salesB = Float(truncating: metricsB.salesPerSquareFoot as NSNumber)

        if salesB > salesA {
            winningLayoutId = layoutBId
            improvementPercentage = ((salesB - salesA) / salesA) * 100
        } else {
            winningLayoutId = layoutAId
            improvementPercentage = ((salesA - salesB) / salesB) * 100
        }

        // Simplified confidence level (would use statistical analysis in production)
        confidenceLevel = 0.95
    }
}

// MARK: - Test Status

enum TestStatus: String, Codable {
    case planned = "Planned"
    case running = "Running"
    case completed = "Completed"
    case archived = "Archived"
}

// MARK: - Mock Data

extension ABTest {
    static func mock() -> ABTest {
        ABTest(
            name: "Entrance Layout Optimization",
            testDescription: "Testing new entrance layout with promotional display",
            layoutAId: UUID(),
            layoutBId: UUID(),
            startDate: Date().addingTimeInterval(-7 * 24 * 60 * 60), // 7 days ago
            endDate: Date(),
            status: .completed,
            confidenceLevel: 0.95,
            improvementPercentage: 18.5
        )
    }
}
