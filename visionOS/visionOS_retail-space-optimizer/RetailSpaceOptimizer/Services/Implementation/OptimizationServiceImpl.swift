import Foundation

final class OptimizationServiceImpl: OptimizationService {
    private let networkClient: NetworkClient
    private let storeService: StoreService

    init(networkClient: NetworkClient, storeService: StoreService) {
        self.networkClient = networkClient
        self.storeService = storeService
    }

    func generateSuggestions(storeID: UUID, parameters: OptimizationParameters? = nil) async throws -> [OptimizationSuggestion] {
        // Request AI-generated suggestions from server
        let suggestions: [OptimizationSuggestion] = try await networkClient.request(
            .generateSuggestions(storeID: storeID, parameters: parameters)
        )

        return suggestions.sorted { $0.priority.sortOrder > $1.priority.sortOrder }
    }

    func applySuggestion(suggestionID: UUID) async throws {
        // Implementation to apply suggestion changes
        // This would update the store layout with the suggested changes
    }

    func simulateLayoutChange(storeID: UUID, changes: [LayoutChange]) async throws -> SimulationResult {
        // Request simulation from server
        let result: SimulationResult = try await networkClient.request(
            .simulateChanges(storeID: storeID, changes: changes)
        )

        return result
    }

    func predictSalesImpact(storeID: UUID, scenario: LayoutScenario) async throws -> ImpactMetrics {
        // Request prediction from ML model
        let result = try await simulateLayoutChange(storeID: storeID, changes: scenario.changes)

        // Convert simulation result to impact metrics
        return ImpactMetrics(
            salesIncrease: 0,  // Calculate from simulation
            conversionIncrease: 0,
            dwellTimeChange: 0,
            trafficChange: 0,
            revenueImpact: result.totalRevenue,
            marginImpact: 0,
            customerSatisfactionChange: 0
        )
    }

    func getSuggestionHistory(storeID: UUID) async throws -> [OptimizationSuggestion] {
        let suggestions: [OptimizationSuggestion] = try await networkClient.request(
            .getSuggestionHistory(storeID: storeID)
        )

        return suggestions.sorted { $0.generatedAt > $1.generatedAt }
    }

    func updateSuggestionStatus(suggestionID: UUID, status: SuggestionStatus) async throws {
        try await networkClient.request(
            .updateSuggestionStatus(suggestionID: suggestionID, status: status)
        )
    }
}
