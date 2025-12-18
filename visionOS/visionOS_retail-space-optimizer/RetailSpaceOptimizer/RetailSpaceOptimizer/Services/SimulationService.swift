import Foundation

@Observable
class SimulationService {
    func simulateCustomerFlow(
        layout: StoreLayout,
        personas: [CustomerPersona],
        duration: TimeInterval
    ) async throws -> SimulationResult {
        #if DEBUG
        if Configuration.useMockData {
            // Simulate processing time
            try await Task.sleep(for: .seconds(1))

            return SimulationResult(
                journeys: CustomerJourney.mockArray(count: personas.count),
                aggregateMetrics: PerformanceMetric.mock(),
                heatMap: mockHeatMap()
            )
        }
        #endif

        // Run actual simulation
        // This would use pathfinding algorithms, behavior modeling, etc.

        return SimulationResult(
            journeys: [],
            aggregateMetrics: PerformanceMetric.mock(),
            heatMap: mockHeatMap()
        )
    }

    func predictPerformance(layout: StoreLayout) async throws -> PerformanceProjection {
        #if DEBUG
        if Configuration.useMockData {
            try await Task.sleep(for: .seconds(1))

            return PerformanceProjection(
                expectedSalesPerSqFt: 2450.0,
                expectedConversionRate: 0.265,
                expectedDwellTime: 19 * 60,
                confidenceInterval: 0.15
            )
        }
        #endif

        // Use ML model to predict performance
        return PerformanceProjection(
            expectedSalesPerSqFt: 2000.0,
            expectedConversionRate: 0.20,
            expectedDwellTime: 15 * 60,
            confidenceInterval: 0.20
        )
    }

    private func mockHeatMap() -> [[Float]] {
        let width = 20
        let height = 30

        var heatMap: [[Float]] = []
        for _ in 0..<height {
            var row: [Float] = []
            for _ in 0..<width {
                row.append(Float.random(in: 0...1))
            }
            heatMap.append(row)
        }
        return heatMap
    }
}

// MARK: - Simulation Result

struct SimulationResult: Codable {
    var journeys: [CustomerJourney]
    var aggregateMetrics: PerformanceMetric
    var heatMap: [[Float]]
}

// MARK: - Performance Projection

struct PerformanceProjection: Codable {
    var expectedSalesPerSqFt: Float
    var expectedConversionRate: Float
    var expectedDwellTime: TimeInterval
    var confidenceInterval: Float // ± percentage
}
