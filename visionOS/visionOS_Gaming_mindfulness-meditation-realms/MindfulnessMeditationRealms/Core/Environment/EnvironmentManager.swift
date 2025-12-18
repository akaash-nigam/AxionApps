import Foundation
import Combine

/// Manages meditation environment state and transitions (business logic only)
/// Note: RealityKit/Spatial rendering logic belongs in Spatial/EnvironmentRenderer.swift
@MainActor
class EnvironmentManager: ObservableObject {

    // MARK: - Published Properties

    @Published private(set) var currentEnvironment: MeditationEnvironment?
    @Published private(set) var environmentState: EnvironmentState = .idle
    @Published private(set) var availableEnvironments: [MeditationEnvironment] = []

    // MARK: - Types

    enum EnvironmentState {
        case idle
        case loading
        case loaded
        case transitioning(from: String, to: String)
        case error(Error)
    }

    enum EnvironmentError: Error, LocalizedError {
        case environmentNotFound(String)
        case loadingFailed(String)
        case transitionFailed
        case notLoaded

        var errorDescription: String? {
            switch self {
            case .environmentNotFound(let id):
                return "Environment '\(id)' not found"
            case .loadingFailed(let id):
                return "Failed to load environment '\(id)'"
            case .transitionFailed:
                return "Failed to transition between environments"
            case .notLoaded:
                return "No environment is currently loaded"
            }
        }
    }

    // MARK: - Private Properties

    private let catalog: EnvironmentCatalog
    private var loadedAssets: Set<String> = []

    // Environment settings
    private(set) var currentTimeOfDay: TimeOfDay = .day
    private(set) var currentWeather: WeatherMood = .clear
    private(set) var visualIntensity: Float = 0.7 // 0.0-1.0

    enum TimeOfDay: String, CaseIterable {
        case sunrise
        case day
        case sunset
        case night

        var lightingMultiplier: Float {
            switch self {
            case .sunrise: return 0.6
            case .day: return 1.0
            case .sunset: return 0.5
            case .night: return 0.3
            }
        }
    }

    enum WeatherMood: String, CaseIterable {
        case clear
        case mist
        case gentleRain
        case snow

        var particleIntensity: Float {
            switch self {
            case .clear: return 0.0
            case .mist: return 0.4
            case .gentleRain: return 0.6
            case .snow: return 0.5
            }
        }
    }

    // MARK: - Initialization

    init(catalog: EnvironmentCatalog = EnvironmentCatalog()) {
        self.catalog = catalog
        self.availableEnvironments = catalog.getAllEnvironments()
    }

    // MARK: - Environment Loading

    func loadEnvironment(_ environmentID: String) async throws {
        guard let environment = catalog.getEnvironment(by: environmentID) else {
            environmentState = .error(EnvironmentError.environmentNotFound(environmentID))
            throw EnvironmentError.environmentNotFound(environmentID)
        }

        environmentState = .loading

        do {
            // Simulate asset loading (actual RealityKit loading would happen in EnvironmentRenderer)
            try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds

            currentEnvironment = environment
            loadedAssets.insert(environmentID)
            environmentState = .loaded

        } catch {
            environmentState = .error(EnvironmentError.loadingFailed(environmentID))
            throw EnvironmentError.loadingFailed(environmentID)
        }
    }

    func unloadEnvironment() {
        currentEnvironment = nil
        environmentState = .idle
        // Keep assets cached for faster reload
    }

    // MARK: - Environment Transitions

    func transitionTo(_ newEnvironmentID: String, duration: TimeInterval = 2.0) async throws {
        guard let fromEnvironment = currentEnvironment else {
            throw EnvironmentError.notLoaded
        }

        guard let toEnvironment = catalog.getEnvironment(by: newEnvironmentID) else {
            throw EnvironmentError.environmentNotFound(newEnvironmentID)
        }

        environmentState = .transitioning(from: fromEnvironment.id, to: newEnvironmentID)

        // Transition sequence:
        // 1. Fade out current environment
        // 2. Load new environment
        // 3. Fade in new environment

        do {
            // Simulate transition
            try await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))

            currentEnvironment = toEnvironment
            loadedAssets.insert(newEnvironmentID)
            environmentState = .loaded

        } catch {
            environmentState = .error(EnvironmentError.transitionFailed)
            throw EnvironmentError.transitionFailed
        }
    }

    // MARK: - Environment Customization

    func setTimeOfDay(_ timeOfDay: TimeOfDay) {
        self.currentTimeOfDay = timeOfDay
        // Notify renderer to update lighting
    }

    func setWeather(_ weather: WeatherMood) {
        self.currentWeather = weather
        // Notify renderer to update particles/effects
    }

    func setVisualIntensity(_ intensity: Float) {
        self.visualIntensity = max(0.0, min(1.0, intensity))
        // Notify renderer to update visual complexity
    }

    func adjustEnvironmentForBiometrics(_ snapshot: BiometricSnapshot) {
        // Auto-adjust environment based on user state

        // High stress - calm the environment
        if snapshot.estimatedStressLevel > 0.7 {
            setVisualIntensity(0.4) // Reduce visual stimulation
            setWeather(.mist) // Calming weather
        }

        // Deep meditation - minimal distractions
        if snapshot.meditationDepth == .deep {
            setVisualIntensity(0.2) // Very minimal
            setWeather(.clear)
        }

        // Settling in - gentle engagement
        if snapshot.meditationDepth == .settling {
            setVisualIntensity(0.6)
            // Keep current weather
        }
    }

    // MARK: - Environment Discovery

    func getAvailableEnvironments(for userProgress: UserProgress) -> [MeditationEnvironment] {
        return availableEnvironments.filter { environment in
            // Check if unlocked
            if userProgress.unlockedEnvironments.contains(environment.id) {
                return true
            }

            // Check if starter environment (always available)
            if !environment.isPremium {
                return true
            }

            return false
        }
    }

    func getEnvironmentsByCategory(_ category: EnvironmentCategory) -> [MeditationEnvironment] {
        return availableEnvironments.filter { $0.category == category }
    }

    func getRecommendedEnvironment(
        for technique: MeditationTechnique,
        userProgress: UserProgress
    ) -> MeditationEnvironment? {
        // Recommend environment based on technique

        let unlockedEnvironments = getAvailableEnvironments(for: userProgress)

        switch technique {
        case .breathAwareness:
            return unlockedEnvironments.first { $0.id == "ZenGarden" } ?? unlockedEnvironments.first

        case .bodyScan:
            return unlockedEnvironments.first { $0.id == "ForestGrove" } ?? unlockedEnvironments.first

        case .lovingKindness:
            return unlockedEnvironments.first { $0.category == .nature } ?? unlockedEnvironments.first

        case .mindfulObservation:
            return unlockedEnvironments.first { $0.id == "CosmicNebula" } ?? unlockedEnvironments.first

        case .soundMeditation:
            return unlockedEnvironments.first { $0.id == "OceanDepths" } ?? unlockedEnvironments.first

        case .mantraRepetition:
            return unlockedEnvironments.first { $0.category == .sacred } ?? unlockedEnvironments.first

        case .walkingMeditation:
            return unlockedEnvironments.first { $0.category == .nature } ?? unlockedEnvironments.first

        case .visualization:
            return unlockedEnvironments.first { $0.category == .cosmic } ?? unlockedEnvironments.first
        }
    }

    // MARK: - Environment Preloading

    func preloadEnvironments(_ environmentIDs: [String]) async {
        // Preload multiple environments for faster switching
        for id in environmentIDs {
            guard !loadedAssets.contains(id) else { continue }

            // Simulate preloading (actual implementation would load RealityKit assets)
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            loadedAssets.insert(id)
        }
    }

    func clearCache() {
        loadedAssets.removeAll()
    }

    // MARK: - State Queries

    func isEnvironmentLoaded(_ environmentID: String) -> Bool {
        return currentEnvironment?.id == environmentID && environmentState == .loaded
    }

    func isEnvironmentAvailable(_ environmentID: String, for userProgress: UserProgress) -> Bool {
        guard let environment = catalog.getEnvironment(by: environmentID) else {
            return false
        }

        return !environment.isPremium || userProgress.unlockedEnvironments.contains(environmentID)
    }

    func getLoadingProgress() -> Float {
        switch environmentState {
        case .idle:
            return 0.0
        case .loading:
            return 0.5 // Simplified - real implementation would track actual progress
        case .loaded:
            return 1.0
        case .transitioning:
            return 0.7
        case .error:
            return 0.0
        }
    }
}
