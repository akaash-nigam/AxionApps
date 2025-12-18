import Foundation
import Observation

// MARK: - AI Analytics Service

@Observable
final class AIAnalyticsService {
    private let apiClient: APIClient

    var predictions: [Prediction] = []
    var recommendations: [AIRecommendation] = []

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    // MARK: - Predictive Analytics

    func generatePredictions(
        historical: [DataPoint],
        horizon: TimeInterval
    ) async throws -> [Prediction] {
        struct PredictionRequest: Codable {
            let data: [DataPoint]
            let horizonDays: Int
        }

        struct PredictionResponse: Codable {
            let predictions: [PredictionData]
        }

        let request = PredictionRequest(
            data: historical,
            horizonDays: Int(horizon / 86400)  // Convert to days
        )

        let response: PredictionResponse = try await apiClient.post(
            endpoint: "/api/v1/ai/predict",
            body: request
        )

        predictions = response.predictions.map { Prediction(from: $0) }
        return predictions
    }

    func forecastEmissions(horizon: TimeInterval) async throws -> [ForecastPoint] {
        struct ForecastResponse: Codable {
            let forecast: [ForecastData]
        }

        let response: ForecastResponse = try await apiClient.get(
            endpoint: "/api/v1/ai/forecast?days=\(Int(horizon / 86400))"
        )

        return response.forecast.map { ForecastPoint(from: $0) }
    }

    // MARK: - Recommendations

    func identifyOptimizations(
        footprint: CarbonFootprint
    ) async throws -> [AIRecommendation] {
        struct OptimizationRequest: Codable {
            let footprintId: String
            let scope1: Double
            let scope2: Double
            let scope3: Double
        }

        struct OptimizationResponse: Codable {
            let recommendations: [RecommendationData]
        }

        let request = OptimizationRequest(
            footprintId: footprint.id.uuidString,
            scope1: footprint.scope1Emissions,
            scope2: footprint.scope2Emissions,
            scope3: footprint.scope3Emissions
        )

        let response: OptimizationResponse = try await apiClient.post(
            endpoint: "/api/v1/ai/optimize",
            body: request
        )

        recommendations = response.recommendations.map { AIRecommendation(from: $0) }
        return recommendations
    }

    // MARK: - Pattern Analysis

    func analyzePatterns() async throws -> PatternAnalysis {
        struct PatternResponse: Codable {
            let patterns: [String]
            let insights: [String]
        }

        let response: PatternResponse = try await apiClient.get(
            endpoint: "/api/v1/ai/patterns"
        )

        return PatternAnalysis(
            patterns: response.patterns,
            insights: response.insights
        )
    }

    // MARK: - Risk Assessment

    func assessClimateRisk() async throws -> ClimateRiskAssessment {
        struct RiskResponse: Codable {
            let physicalRisk: String
            let transitionRisk: String
            let overallScore: Double
        }

        let response: RiskResponse = try await apiClient.get(
            endpoint: "/api/v1/ai/risk-assessment"
        )

        return ClimateRiskAssessment(
            physicalRisk: RiskLevel(rawValue: response.physicalRisk) ?? .medium,
            transitionRisk: RiskLevel(rawValue: response.transitionRisk) ?? .medium,
            overallScore: response.overallScore
        )
    }
}

// MARK: - Supporting Types

struct Prediction: Identifiable {
    let id = UUID()
    let timestamp: Date
    let value: Double
    let confidence: Double

    init(from data: PredictionData) {
        self.timestamp = ISO8601DateFormatter().date(from: data.timestamp) ?? Date()
        self.value = data.value
        self.confidence = data.confidence
    }
}

struct PredictionData: Codable {
    let timestamp: String
    let value: Double
    let confidence: Double
}

struct ForecastPoint: Identifiable {
    let id = UUID()
    let date: Date
    let emissions: Double
    let upperBound: Double
    let lowerBound: Double

    init(from data: ForecastData) {
        self.date = ISO8601DateFormatter().date(from: data.date) ?? Date()
        self.emissions = data.emissions
        self.upperBound = data.upperBound
        self.lowerBound = data.lowerBound
    }
}

struct ForecastData: Codable {
    let date: String
    let emissions: Double
    let upperBound: Double
    let lowerBound: Double
}

struct AIRecommendation: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let category: RecommendationCategory
    let impact: ImpactEstimate
    let confidence: Double

    init(from data: RecommendationData) {
        self.id = UUID(uuidString: data.id) ?? UUID()
        self.title = data.title
        self.description = data.description
        self.category = RecommendationCategory(rawValue: data.category) ?? .other
        self.impact = ImpactEstimate(
            emissionReduction: data.emissionReduction,
            costSavings: data.costSavings,
            roi: data.roi
        )
        self.confidence = data.confidence
    }
}

struct RecommendationData: Codable {
    let id: String
    let title: String
    let description: String
    let category: String
    let emissionReduction: Double
    let costSavings: Double
    let roi: Double
    let confidence: Double
}

enum RecommendationCategory: String, Codable {
    case energyEfficiency = "Energy Efficiency"
    case renewableEnergy = "Renewable Energy"
    case processOptimization = "Process Optimization"
    case supplyChain = "Supply Chain"
    case wasteReduction = "Waste Reduction"
    case other = "Other"
}

struct ImpactEstimate {
    let emissionReduction: Double  // tCO2e
    let costSavings: Double  // USD
    let roi: Double  // Return on investment ratio
}

struct PatternAnalysis {
    let patterns: [String]
    let insights: [String]
}

struct ClimateRiskAssessment {
    let physicalRisk: RiskLevel
    let transitionRisk: RiskLevel
    let overallScore: Double
}

enum RiskLevel: String, Codable {
    case low = "low"
    case medium = "medium"
    case high = "high"

    var color: String {
        switch self {
        case .low: return "#27AE60"
        case .medium: return "#F2C94C"
        case .high: return "#E34034"
        }
    }
}

struct DataPoint: Codable {
    let timestamp: Date
    let value: Double
}
