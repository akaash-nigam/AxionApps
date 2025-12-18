import Foundation

/// Service for AI-powered optimization
protocol OptimizationService {
    /// Generate layout optimization suggestions
    func generateSuggestions(storeID: UUID, parameters: OptimizationParameters?) async throws -> [OptimizationSuggestion]

    /// Apply a suggestion to a store
    func applySuggestion(suggestionID: UUID) async throws

    /// Simulate layout changes and predict impact
    func simulateLayoutChange(storeID: UUID, changes: [LayoutChange]) async throws -> SimulationResult

    /// Predict sales impact of a scenario
    func predictSalesImpact(storeID: UUID, scenario: LayoutScenario) async throws -> ImpactMetrics

    /// Get optimization suggestions history
    func getSuggestionHistory(storeID: UUID) async throws -> [OptimizationSuggestion]

    /// Update suggestion status
    func updateSuggestionStatus(suggestionID: UUID, status: SuggestionStatus) async throws
}

struct OptimizationParameters: Codable {
    var focusAreas: [OptimizationType] = []
    var constraints: [LayoutConstraint] = []
    var budget: Decimal?
    var timeframe: TimeInterval?
    var minimumROI: Double?
}

struct LayoutConstraint: Codable {
    var type: ConstraintType
    var value: String
}

enum ConstraintType: String, Codable {
    case fixedFixtures  // Don't move certain fixtures
    case minimumAisleWidth
    case maximumReachHeight
    case accessibilityCompliance
    case fireCodeCompliance
    case budget
}

struct LayoutScenario: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var description: String
    var changes: [LayoutChange]
    var createdAt: Date
}
