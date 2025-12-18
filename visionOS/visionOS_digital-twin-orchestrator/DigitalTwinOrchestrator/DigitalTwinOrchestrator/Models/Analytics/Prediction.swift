import Foundation
import SwiftData

/// Prediction Model - AI/ML predictions about asset failures and optimizations
@Model
final class Prediction {
    @Attribute(.unique) var id: UUID
    var predictionType: PredictionType
    var confidence: Double
    var predictedDate: Date
    var createdDate: Date

    // Prediction details
    var title: String
    var predictionDescription: String
    var affectedComponents: [String]
    var severity: Severity
    var estimatedImpact: ImpactEstimate?

    // Recommendations
    var recommendedActions: [String]
    var preventiveMeasures: [String]
    var estimatedCost: Decimal?

    // Validation (filled in after event occurs)
    var actualOutcome: PredictionOutcome?
    var actualDate: Date?
    var accuracy: Double?
    var wasActionTaken: Bool
    var notes: String?

    @Relationship(inverse: \DigitalTwin.predictions)
    var digitalTwin: DigitalTwin?

    init(
        id: UUID = UUID(),
        predictionType: PredictionType,
        confidence: Double,
        predictedDate: Date,
        title: String,
        predictionDescription: String,
        severity: Severity = .medium
    ) {
        self.id = id
        self.predictionType = predictionType
        self.confidence = confidence
        self.predictedDate = predictedDate
        self.createdDate = Date()
        self.title = title
        self.predictionDescription = predictionDescription
        self.severity = severity
        self.affectedComponents = []
        self.recommendedActions = []
        self.preventiveMeasures = []
        self.wasActionTaken = false
    }

    // MARK: - Computed Properties

    var isHighConfidence: Bool {
        confidence >= 0.85
    }

    var daysUntilPredicted: Int {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: predictedDate).day ?? 0
        return max(0, days)
    }

    var timeUntilPredicted: String {
        let days = daysUntilPredicted

        if days == 0 {
            return "Today"
        } else if days == 1 {
            return "Tomorrow"
        } else if days < 7 {
            return "\(days) days"
        } else if days < 30 {
            let weeks = days / 7
            return "\(weeks) week\(weeks == 1 ? "" : "s")"
        } else {
            let months = days / 30
            return "\(months) month\(months == 1 ? "" : "s")"
        }
    }

    var severityColor: String {
        switch severity {
        case .low: return "blue"
        case .medium: return "yellow"
        case .high: return "orange"
        case .critical: return "red"
        }
    }

    var confidencePercentage: String {
        String(format: "%.0f%%", confidence * 100)
    }

    // MARK: - Methods

    func recordOutcome(
        outcome: PredictionOutcome,
        actualDate: Date,
        notes: String? = nil
    ) {
        self.actualOutcome = outcome
        self.actualDate = actualDate
        self.notes = notes

        // Calculate accuracy based on date precision
        if let actualDate = self.actualDate {
            let daysDifference = abs(Calendar.current.dateComponents(
                [.day],
                from: predictedDate,
                to: actualDate
            ).day ?? 0)

            // Accuracy decreases with larger date difference
            accuracy = max(0, 1.0 - (Double(daysDifference) / 30.0))
        }
    }
}

// MARK: - Supporting Types

enum PredictionType: String, Codable {
    case failure
    case performanceDegradation
    case maintenanceWindow
    case energyOptimization
    case qualityIssue
    case efficiency
    case costReduction

    var displayName: String {
        switch self {
        case .failure: return "Equipment Failure"
        case .performanceDegradation: return "Performance Degradation"
        case .maintenanceWindow: return "Maintenance Opportunity"
        case .energyOptimization: return "Energy Optimization"
        case .qualityIssue: return "Quality Issue"
        case .efficiency: return "Efficiency Improvement"
        case .costReduction: return "Cost Reduction"
        }
    }

    var iconName: String {
        switch self {
        case .failure: return "exclamationmark.triangle.fill"
        case .performanceDegradation: return "chart.line.downtrend.xyaxis"
        case .maintenanceWindow: return "wrench.and.screwdriver.fill"
        case .energyOptimization: return "bolt.fill"
        case .qualityIssue: return "checkmark.seal.fill"
        case .efficiency: return "chart.line.uptrend.xyaxis"
        case .costReduction: return "dollarsign.circle.fill"
        }
    }
}

enum Severity: String, Codable {
    case low
    case medium
    case high
    case critical

    var displayName: String {
        rawValue.capitalized
    }

    var priority: Int {
        switch self {
        case .low: return 1
        case .medium: return 2
        case .high: return 3
        case .critical: return 4
        }
    }
}

struct ImpactEstimate: Codable {
    var downtimeHours: Double?
    var costEstimate: Decimal?
    var productionLoss: Double?
    var safetyRisk: SafetyLevel
    var environmentalImpact: EnvironmentalImpact?

    var summary: String {
        var parts: [String] = []

        if let downtime = downtimeHours {
            parts.append("\(Int(downtime))h downtime")
        }

        if let cost = costEstimate {
            parts.append("$\(cost)")
        }

        if let production = productionLoss {
            parts.append("\(Int(production)) units lost")
        }

        return parts.joined(separator: ", ")
    }
}

enum SafetyLevel: String, Codable {
    case none
    case low
    case medium
    case high
    case critical

    var displayName: String {
        rawValue.capitalized
    }
}

enum EnvironmentalImpact: String, Codable {
    case none
    case minimal
    case moderate
    case significant

    var displayName: String {
        rawValue.capitalized
    }
}

enum PredictionOutcome: String, Codable {
    case occurred            // Prediction was correct
    case prevented           // Issue was prevented by taking action
    case didNotOccur        // Prediction was incorrect
    case tooEarlyToTell     // Still within prediction window

    var displayName: String {
        switch self {
        case .occurred: return "Occurred as Predicted"
        case .prevented: return "Successfully Prevented"
        case .didNotOccur: return "Did Not Occur"
        case .tooEarlyToTell: return "Too Early to Tell"
        }
    }

    var iconName: String {
        switch self {
        case .occurred: return "checkmark.circle.fill"
        case .prevented: return "shield.checkmark.fill"
        case .didNotOccur: return "xmark.circle.fill"
        case .tooEarlyToTell: return "clock.fill"
        }
    }
}

// MARK: - Extensions

extension Prediction {
    /// Create a sample prediction for testing
    static func sample(
        type: PredictionType,
        daysAhead: Int,
        severity: Severity
    ) -> Prediction {
        let prediction = Prediction(
            predictionType: type,
            confidence: Double.random(in: 0.75...0.95),
            predictedDate: Date().addingTimeInterval(Double(daysAhead) * 24 * 3600),
            title: "\(type.displayName) Predicted",
            predictionDescription: "Based on current operating patterns and sensor data, \(type.displayName.lowercased()) is likely to occur.",
            severity: severity
        )

        prediction.affectedComponents = [
            "Main Bearing",
            "Rotor Assembly"
        ]

        prediction.recommendedActions = [
            "Schedule maintenance during next planned downtime",
            "Order replacement parts",
            "Prepare maintenance crew"
        ]

        prediction.preventiveMeasures = [
            "Reduce operating speed by 10%",
            "Increase lubrication frequency",
            "Monitor vibration closely"
        ]

        prediction.estimatedImpact = ImpactEstimate(
            downtimeHours: Double.random(in: 4...48),
            costEstimate: Decimal(Double.random(in: 5000...50000)),
            productionLoss: Double.random(in: 100...1000),
            safetyRisk: .low,
            environmentalImpact: .minimal
        )

        return prediction
    }

    /// Create sample predictions
    static func samplePredictions() -> [Prediction] {
        [
            sample(type: .failure, daysAhead: 3, severity: .critical),
            sample(type: .performanceDegradation, daysAhead: 14, severity: .medium),
            sample(type: .maintenanceWindow, daysAhead: 7, severity: .low),
            sample(type: .energyOptimization, daysAhead: 1, severity: .medium),
            sample(type: .qualityIssue, daysAhead: 21, severity: .high)
        ]
    }
}
