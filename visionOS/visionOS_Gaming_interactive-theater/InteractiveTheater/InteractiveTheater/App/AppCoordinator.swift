import SwiftUI
import Observation

/// Central coordinator managing app-wide state and navigation
@MainActor
@Observable
class AppCoordinator: ObservableObject {
    // MARK: - State
    var currentPerformance: PerformanceData?
    var isPerformanceActive: Bool = false
    var gameStateManager: GameStateManager?

    // MARK: - Initialization
    init() {
        // Initialize any required services
        setupServices()
    }

    // MARK: - Methods

    /// Start a new performance
    func startPerformance(_ performance: PerformanceData) {
        currentPerformance = performance
        gameStateManager = GameStateManager(performance: performance)
        isPerformanceActive = true
    }

    /// End current performance
    func endPerformance() {
        isPerformanceActive = false
        gameStateManager = nil
        currentPerformance = nil
    }

    /// Setup application services
    private func setupServices() {
        // Initialize analytics, cloud services, etc.
    }
}
