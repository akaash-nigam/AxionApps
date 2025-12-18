import Foundation
import QuartzCore

/// Main game loop that drives all game systems
@MainActor
public final class GameLoop {
    private var displayLink: CADisplayLink?
    private var lastUpdateTime: TimeInterval = 0
    private var systems: [any GameSystem] = []
    private var isRunning = false

    // Performance tracking
    private var frameCount: Int = 0
    private var accumulatedTime: TimeInterval = 0
    public private(set) var currentFPS: Double = 0

    public init() {}

    // MARK: - System Management

    /// Add a system to the game loop
    public func addSystem(_ system: any GameSystem) {
        systems.append(system)
        systems.sort { $0.priority > $1.priority }
    }

    /// Remove a system from the game loop
    public func removeSystem(_ system: any GameSystem) {
        systems.removeAll { $0.priority == system.priority }
    }

    /// Remove all systems
    public func clearSystems() {
        systems.removeAll()
    }

    // MARK: - Loop Control

    /// Start the game loop
    public func start() {
        guard !isRunning else { return }

        isRunning = true
        lastUpdateTime = CACurrentMediaTime()

        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink?.preferredFrameRateRange = CAFrameRateRange(
            minimum: 90,
            maximum: 120,
            preferred: 120
        )
        displayLink?.add(to: .main, forMode: .default)
    }

    /// Stop the game loop
    public func stop() {
        displayLink?.invalidate()
        displayLink = nil
        isRunning = false
    }

    // MARK: - Update Loop

    @objc private func update() {
        let currentTime = CACurrentMediaTime()
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        // Update FPS
        frameCount += 1
        accumulatedTime += deltaTime

        if accumulatedTime >= 1.0 {
            currentFPS = Double(frameCount) / accumulatedTime
            frameCount = 0
            accumulatedTime = 0
        }

        // Update all systems
        Task {
            await updateSystems(deltaTime: deltaTime)
        }
    }

    /// Update all systems for this frame
    private func updateSystems(deltaTime: TimeInterval) async {
        let entities = await EntityManager.shared.activeEntities

        for system in systems {
            await system.update(deltaTime: deltaTime, entities: entities)
        }
    }

    /// Manual update for testing
    public func updateOnce(deltaTime: TimeInterval = 0.016) async {
        await updateSystems(deltaTime: deltaTime)
    }

    // MARK: - State

    /// Check if the game loop is running
    public var running: Bool {
        return isRunning
    }

    /// Get all registered systems
    public var registeredSystems: [any GameSystem] {
        return systems
    }
}
