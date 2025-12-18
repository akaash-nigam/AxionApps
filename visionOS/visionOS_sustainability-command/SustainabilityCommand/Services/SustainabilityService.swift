import Foundation
import Observation

// MARK: - Sustainability Service

@Observable
final class SustainabilityService {
    // Dependencies
    private let apiClient: APIClient
    private let dataStore: DataStore

    // State
    var currentFootprint: CarbonFootprint?
    var goals: [SustainabilityGoal] = []
    var facilities: [Facility] = []
    var supplyChains: [SupplyChain] = []

    init(apiClient: APIClient, dataStore: DataStore) {
        self.apiClient = apiClient
        self.dataStore = dataStore
    }

    // MARK: - Carbon Footprint

    func fetchCurrentFootprint() async throws -> CarbonFootprint {
        // Try to fetch from API first
        do {
            let footprintData: CarbonFootprintResponse = try await apiClient.get(
                endpoint: "/api/v1/footprint/current"
            )
            let footprint = footprintData.toDomain()
            currentFootprint = footprint
            return footprint
        } catch {
            // Fall back to local data if available
            if let cached = await dataStore.getCurrentFootprint() {
                return cached
            }
            throw error
        }
    }

    func updateEmissionData(_ data: EmissionData) async throws {
        try await apiClient.post(
            endpoint: "/api/v1/emissions",
            body: data
        )

        // Refresh current footprint
        currentFootprint = try await fetchCurrentFootprint()
    }

    // MARK: - Facilities

    func fetchFacilities() async throws -> [Facility] {
        let facilitiesData: [FacilityResponse] = try await apiClient.get(
            endpoint: "/api/v1/facilities"
        )
        facilities = facilitiesData.map { $0.toDomain() }
        return facilities
    }

    func fetchFacility(id: UUID) async throws -> Facility {
        let facilityData: FacilityResponse = try await apiClient.get(
            endpoint: "/api/v1/facilities/\(id.uuidString)"
        )
        return facilityData.toDomain()
    }

    // MARK: - Goals

    func fetchGoals() async throws -> [SustainabilityGoal] {
        let goalsData: [GoalResponse] = try await apiClient.get(
            endpoint: "/api/v1/goals"
        )
        goals = goalsData.map { $0.toDomain() }
        return goals
    }

    func createGoal(_ goal: SustainabilityGoal) async throws -> SustainabilityGoal {
        let request = CreateGoalRequest(from: goal)
        let response: GoalResponse = try await apiClient.post(
            endpoint: "/api/v1/goals",
            body: request
        )
        let newGoal = response.toDomain()

        // Add to local array
        goals.append(newGoal)

        return newGoal
    }

    func updateGoal(_ goal: SustainabilityGoal) async throws {
        let request = UpdateGoalRequest(from: goal)
        try await apiClient.put(
            endpoint: "/api/v1/goals/\(goal.id.uuidString)",
            body: request
        )

        // Update local array
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index] = goal
        }
    }

    func deleteGoal(id: UUID) async throws {
        try await apiClient.delete(
            endpoint: "/api/v1/goals/\(id.uuidString)"
        )

        // Remove from local array
        goals.removeAll { $0.id == id }
    }

    // MARK: - Supply Chains

    func fetchSupplyChains() async throws -> [SupplyChain] {
        let chainsData: [SupplyChainResponse] = try await apiClient.get(
            endpoint: "/api/v1/supply-chains"
        )
        supplyChains = chainsData.map { $0.toDomain() }
        return supplyChains
    }

    // MARK: - Calculations

    func calculateTotalEmissions() -> Double {
        currentFootprint?.totalEmissions ?? 0
    }

    func calculateEmissionsByCategory() -> [EmissionCategory: Double] {
        guard let footprint = currentFootprint else { return [:] }

        var result: [EmissionCategory: Double] = [:]
        for source in footprint.emissionSources {
            result[source.category, default: 0] += source.emissions
        }
        return result
    }

    func calculateGoalProgress() -> Double {
        guard !goals.isEmpty else { return 0 }

        let totalProgress = goals.reduce(0.0) { $0 + $1.progress }
        return totalProgress / Double(goals.count)
    }
}

// MARK: - API Response Models

struct CarbonFootprintResponse: Codable {
    let id: String
    let timestamp: String
    let organizationId: String
    let scope1: Double
    let scope2: Double
    let scope3: Double
    let sources: [EmissionSourceResponse]

    func toDomain() -> CarbonFootprint {
        // Convert to domain model
        // This would use actual conversion logic
        fatalError("Not implemented - would convert API response to domain model")
    }
}

struct EmissionSourceResponse: Codable {
    let id: String
    let name: String
    let category: String
    let emissions: Double
}

struct FacilityResponse: Codable {
    let id: String
    let name: String
    let type: String
    let latitude: Double
    let longitude: Double
    let emissions: Double

    func toDomain() -> Facility {
        fatalError("Not implemented - would convert API response to domain model")
    }
}

struct GoalResponse: Codable {
    let id: String
    let title: String
    let description: String
    let category: String
    let currentValue: Double
    let targetValue: Double

    func toDomain() -> SustainabilityGoal {
        fatalError("Not implemented - would convert API response to domain model")
    }
}

struct SupplyChainResponse: Codable {
    let id: String
    let productId: String
    let productName: String
    let totalEmissions: Double

    func toDomain() -> SupplyChain {
        fatalError("Not implemented - would convert API response to domain model")
    }
}

// MARK: - Request Models

struct EmissionData: Codable {
    let facilityId: String
    let emissions: Double
    let timestamp: Date
}

struct CreateGoalRequest: Codable {
    let title: String
    let description: String
    let category: String
    let targetValue: Double
    let targetDate: String

    init(from goal: SustainabilityGoal) {
        self.title = goal.title
        self.description = goal.description
        self.category = goal.category.rawValue
        self.targetValue = goal.targetValue
        self.targetDate = ISO8601DateFormatter().string(from: goal.targetDate)
    }
}

struct UpdateGoalRequest: Codable {
    let currentValue: Double
    let status: String

    init(from goal: SustainabilityGoal) {
        self.currentValue = goal.currentValue
        self.status = goal.status.rawValue
    }
}
