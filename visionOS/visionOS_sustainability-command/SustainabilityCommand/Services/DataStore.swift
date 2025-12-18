import Foundation
import SwiftData

// MARK: - Data Store

actor DataStore {
    private var modelContext: ModelContext?

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    // MARK: - Carbon Footprint

    func getCurrentFootprint() async -> CarbonFootprint? {
        guard let context = modelContext else { return nil }

        let descriptor = FetchDescriptor<CarbonFootprintModel>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )

        guard let models = try? context.fetch(descriptor),
              let latest = models.first else {
            return nil
        }

        return CarbonFootprint(from: latest)
    }

    func saveFootprint(_ footprint: CarbonFootprint) async throws {
        guard let context = modelContext else { return }

        // Convert to SwiftData model and insert
        // Implementation would go here
    }

    // MARK: - Goals

    func getGoals() async -> [SustainabilityGoal] {
        guard let context = modelContext else { return [] }

        let descriptor = FetchDescriptor<SustainabilityGoalModel>(
            sortBy: [SortDescriptor(\.targetDate)]
        )

        guard let models = try? context.fetch(descriptor) else {
            return []
        }

        return models.map { SustainabilityGoal(from: $0) }
    }

    func saveGoal(_ goal: SustainabilityGoal) async throws {
        guard let context = modelContext else { return }

        // Convert and save
        // Implementation would go here
    }

    // MARK: - Facilities

    func getFacilities() async -> [Facility] {
        guard let context = modelContext else { return [] }

        let descriptor = FetchDescriptor<FacilityModel>(
            sortBy: [SortDescriptor(\.name)]
        )

        guard let models = try? context.fetch(descriptor) else {
            return []
        }

        return models.map { Facility(from: $0) }
    }
}
