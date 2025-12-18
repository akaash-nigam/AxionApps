import Foundation
import QuartzCore

/// Main game loop managing update cycles
@MainActor
class GameLoopSystem {
    // MARK: - Properties

    // Fixed timestep for physics (60 Hz)
    private let fixedDeltaTime: TimeInterval = 1.0 / 60.0

    // Target frame rate (90 Hz for visionOS)
    private let targetFrameRate: TimeInterval = 1.0 / 90.0

    // Time tracking
    private var lastUpdateTime: TimeInterval = 0
    private var accumulator: TimeInterval = 0

    // State
    private var isRunning: Bool = false
    private weak var gameStateManager: GameStateManager?

    // Systems to update
    private var updateSystems: [any UpdateSystem] = []

    // Performance metrics
    private(set) var currentFPS: Double = 0
    private(set) var averageFrameTime: TimeInterval = 0
    private var frameTimeHistory: [TimeInterval] = []
    private let frameHistorySize = 90 // Track last 90 frames

    // MARK: - Initialization

    init(gameStateManager: GameStateManager) {
        self.gameStateManager = gameStateManager
        setupSystems()
    }

    // MARK: - Setup

    private func setupSystems() {
        // Systems will be added here as they're implemented
        // updateSystems.append(PhysicsSystem())
        // updateSystems.append(AISystem())
        // updateSystems.append(NarrativeSystem())
        // updateSystems.append(AudioSystem())
    }

    // MARK: - Game Loop

    /// Start the game loop
    func start() {
        isRunning = true
        lastUpdateTime = CACurrentMediaTime()
        print("Game loop started - Target FPS: \(1.0 / targetFrameRate)")
    }

    /// Stop the game loop
    func stop() {
        isRunning = false
        print("Game loop stopped - Final FPS: \(currentFPS)")
    }

    /// Main update function called each frame
    func update(currentTime: TimeInterval) {
        guard isRunning else { return }

        // Calculate delta time
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        // Track frame time for metrics
        trackFrameTime(deltaTime)

        // Accumulate time for fixed timestep
        accumulator += deltaTime

        // Fixed timestep updates (physics, AI, etc.)
        var fixedUpdateCount = 0
        let maxFixedUpdates = 3 // Prevent spiral of death

        while accumulator >= fixedDeltaTime && fixedUpdateCount < maxFixedUpdates {
            performFixedUpdate(fixedDeltaTime)
            accumulator -= fixedDeltaTime
            fixedUpdateCount += 1
        }

        // Variable timestep updates (rendering, audio, etc.)
        performVariableUpdate(deltaTime)

        // Calculate interpolation factor for smooth rendering
        let interpolationFactor = accumulator / fixedDeltaTime
        performRenderUpdate(deltaTime, interpolation: Float(interpolationFactor))

        // Update game state timing
        gameStateManager?.updateProgress(deltaTime: deltaTime)
    }

    // MARK: - Update Phases

    /// Fixed timestep update for deterministic systems
    private func performFixedUpdate(_ deltaTime: TimeInterval) {
        for system in updateSystems where system.updateMode == .fixed {
            system.update(deltaTime: deltaTime)
        }
    }

    /// Variable timestep update for responsive systems
    private func performVariableUpdate(_ deltaTime: TimeInterval) {
        for system in updateSystems where system.updateMode == .variable {
            system.update(deltaTime: deltaTime)
        }
    }

    /// Rendering update with interpolation
    private func performRenderUpdate(_ deltaTime: TimeInterval, interpolation: Float) {
        // Rendering logic will be handled by RealityKit
        // This is where we'd update entity positions with interpolation
    }

    // MARK: - Performance Metrics

    private func trackFrameTime(_ deltaTime: TimeInterval) {
        frameTimeHistory.append(deltaTime)

        // Keep only recent history
        if frameTimeHistory.count > frameHistorySize {
            frameTimeHistory.removeFirst()
        }

        // Calculate average frame time
        averageFrameTime = frameTimeHistory.reduce(0, +) / Double(frameTimeHistory.count)

        // Calculate FPS
        currentFPS = averageFrameTime > 0 ? 1.0 / averageFrameTime : 0
    }

    /// Get performance statistics
    func getPerformanceStats() -> PerformanceStats {
        let sortedFrameTimes = frameTimeHistory.sorted()
        let percentile95Index = Int(Double(sortedFrameTimes.count) * 0.95)
        let percentile99Index = Int(Double(sortedFrameTimes.count) * 0.99)

        return PerformanceStats(
            currentFPS: currentFPS,
            averageFrameTime: averageFrameTime,
            minFrameTime: sortedFrameTimes.first ?? 0,
            maxFrameTime: sortedFrameTimes.last ?? 0,
            percentile95FrameTime: percentile95Index < sortedFrameTimes.count ? sortedFrameTimes[percentile95Index] : 0,
            percentile99FrameTime: percentile99Index < sortedFrameTimes.count ? sortedFrameTimes[percentile99Index] : 0
        )
    }

    /// Check if performance targets are being met
    func isPerformanceTargetMet() -> Bool {
        let stats = getPerformanceStats()
        // Target: 90 FPS (11.1ms per frame), 95th percentile should be under target
        return stats.percentile95FrameTime < (targetFrameRate * 1.1) // 10% tolerance
    }

    // MARK: - System Management

    /// Add an update system
    func addSystem(_ system: any UpdateSystem) {
        updateSystems.append(system)
        print("Added system: \(type(of: system))")
    }

    /// Remove an update system
    func removeSystem(_ system: any UpdateSystem) {
        updateSystems.removeAll { ObjectIdentifier($0) == ObjectIdentifier(system) }
    }
}

// MARK: - Supporting Types

/// Protocol for systems that need update calls
protocol UpdateSystem: AnyObject {
    var updateMode: UpdateMode { get }
    func update(deltaTime: TimeInterval)
}

enum UpdateMode {
    case fixed      // For physics, AI decisions, etc.
    case variable   // For animation, input, etc.
}

/// Performance statistics
struct PerformanceStats {
    let currentFPS: Double
    let averageFrameTime: TimeInterval
    let minFrameTime: TimeInterval
    let maxFrameTime: TimeInterval
    let percentile95FrameTime: TimeInterval
    let percentile99FrameTime: TimeInterval

    var isHealthy: Bool {
        // Performance is healthy if 95th percentile is under 11.1ms (90 FPS)
        percentile95FrameTime < 0.0111
    }

    var performanceRating: PerformanceRating {
        if currentFPS >= 85 {
            return .excellent
        } else if currentFPS >= 60 {
            return .good
        } else if currentFPS >= 45 {
            return .fair
        } else {
            return .poor
        }
    }
}

enum PerformanceRating {
    case excellent  // 85+ FPS
    case good       // 60-85 FPS
    case fair       // 45-60 FPS
    case poor       // <45 FPS
}
