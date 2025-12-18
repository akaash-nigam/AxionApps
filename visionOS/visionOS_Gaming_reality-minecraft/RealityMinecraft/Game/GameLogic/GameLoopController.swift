//
//  GameLoopController.swift
//  Reality Minecraft
//
//  Main game loop running at 90 FPS
//

import Foundation
import QuartzCore
import Combine

/// Main game loop controller
@MainActor
class GameLoopController: ObservableObject {
    // Target frame rate
    static var targetFrameRate: Double = 90.0

    // Display link for game loop
    private var displayLink: CADisplayLink?
    private var lastUpdateTime: TimeInterval = 0
    private var deltaTime: TimeInterval = 0

    // Systems to update
    private weak var gameStateManager: GameStateManager?
    private var entityManager: EntityManager?
    private var physicsSystem: PhysicsSystem?
    private var inputSystem: InputSystem?
    private var audioSystem: AudioSystem?

    // Performance monitoring
    private let performanceMonitor = PerformanceMonitor()

    // Published properties
    @Published private(set) var isRunning: Bool = false
    @Published private(set) var currentFPS: Double = 0.0

    init(gameStateManager: GameStateManager) {
        self.gameStateManager = gameStateManager
    }

    // MARK: - Lifecycle

    /// Start the game loop
    func start() {
        guard !isRunning else { return }

        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink?.preferredFramesPerSecond = Int(Self.targetFrameRate)
        displayLink?.add(to: .main, forMode: .common)

        isRunning = true
        lastUpdateTime = CACurrentMediaTime()

        print("🎮 Game loop started at \(Self.targetFrameRate) FPS")
    }

    /// Stop the game loop
    func stop() {
        guard isRunning else { return }

        displayLink?.invalidate()
        displayLink = nil
        isRunning = false

        print("⏹ Game loop stopped")
    }

    /// Pause the game loop
    func pause() {
        displayLink?.isPaused = true
    }

    /// Resume the game loop
    func resume() {
        displayLink?.isPaused = false
        lastUpdateTime = CACurrentMediaTime()
    }

    // MARK: - Game Loop

    @objc private func update(displayLink: CADisplayLink) {
        let currentTime = displayLink.timestamp
        deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        // Update FPS counter
        if deltaTime > 0 {
            currentFPS = 1.0 / deltaTime
        }

        // Check if game is paused
        guard let gameState = gameStateManager?.currentState else { return }
        if case .paused = gameState { return }
        if case .playing = gameState { } else { return }

        // Performance monitoring
        performanceMonitor.beginFrame()

        // Game loop phases
        performanceMonitor.measureSystem("input") {
            processInput(deltaTime: deltaTime)
        }

        performanceMonitor.measureSystem("gameLogic") {
            updateGameLogic(deltaTime: deltaTime)
        }

        performanceMonitor.measureSystem("physics") {
            updatePhysics(deltaTime: deltaTime)
        }

        performanceMonitor.measureSystem("ai") {
            updateAI(deltaTime: deltaTime)
        }

        performanceMonitor.measureSystem("audio") {
            updateAudio(deltaTime: deltaTime)
        }

        // End frame
        performanceMonitor.endFrame()

        // Check for performance issues
        if performanceMonitor.averageFPS < 60.0 {
            handlePerformanceIssue()
        }
    }

    // MARK: - Update Phases

    private func processInput(deltaTime: TimeInterval) {
        inputSystem?.update(deltaTime: deltaTime)
    }

    private func updateGameLogic(deltaTime: TimeInterval) {
        entityManager?.update(deltaTime: deltaTime)
    }

    private func updatePhysics(deltaTime: TimeInterval) {
        physicsSystem?.update(deltaTime: deltaTime)
    }

    private func updateAI(deltaTime: TimeInterval) {
        // Update mob AI
        entityManager?.updateAI(deltaTime: deltaTime)
    }

    private func updateAudio(deltaTime: TimeInterval) {
        audioSystem?.update(deltaTime: deltaTime)
    }

    // MARK: - Performance

    private func handlePerformanceIssue() {
        // Reduce quality settings if performance drops
        print("⚠️ Performance issue detected: \(performanceMonitor.averageFPS) FPS")
        // Could reduce render distance, disable particles, etc.
    }

    // MARK: - System Registration

    func registerSystems(
        entityManager: EntityManager,
        physicsSystem: PhysicsSystem,
        inputSystem: InputSystem,
        audioSystem: AudioSystem
    ) {
        self.entityManager = entityManager
        self.physicsSystem = physicsSystem
        self.inputSystem = inputSystem
        self.audioSystem = audioSystem
    }
}

// MARK: - Performance Monitor

/// Performance monitoring utility
class PerformanceMonitor {
    private var frameStartTime: TimeInterval = 0
    private var frameTimes: [TimeInterval] = []
    private let maxSamples = 60

    var timings: [String: TimeInterval] = [:]

    var averageFPS: Double {
        guard !frameTimes.isEmpty else { return 0 }
        let avgFrameTime = frameTimes.reduce(0, +) / Double(frameTimes.count)
        return avgFrameTime > 0 ? 1.0 / avgFrameTime : 0
    }

    func beginFrame() {
        frameStartTime = CACurrentMediaTime()
        timings.removeAll()
    }

    func endFrame() {
        let frameTime = CACurrentMediaTime() - frameStartTime
        frameTimes.append(frameTime)

        if frameTimes.count > maxSamples {
            frameTimes.removeFirst()
        }

        // Log if frame time exceeds budget (11.11ms for 90 FPS)
        let frameBudget = 1.0 / 90.0
        if frameTime > frameBudget {
            print("⚠️ Frame time exceeded budget: \(frameTime * 1000)ms")
        }
    }

    func measureSystem(_ name: String, _ block: () -> Void) {
        let start = CACurrentMediaTime()
        block()
        let elapsed = CACurrentMediaTime() - start
        timings[name] = elapsed

        // Warn if system over budget
        if let budget = getSystemBudget(name), elapsed > budget {
            print("⚠️ \(name) over budget: \(elapsed * 1000)ms / \(budget * 1000)ms")
        }
    }

    func getPerformanceMetrics() -> PerformanceMetrics {
        return PerformanceMetrics(
            fps: averageFPS,
            frameTime: frameTimes.last ?? 0,
            memoryUsage: getMemoryUsage(),
            systemTimings: timings
        )
    }

    private func getSystemBudget(_ system: String) -> TimeInterval? {
        // Budget in seconds (based on TECHNICAL_SPEC.md)
        switch system {
        case "gameLogic": return 0.002  // 2ms
        case "physics": return 0.0015   // 1.5ms
        case "ai": return 0.001         // 1ms
        case "input": return 0.0005     // 0.5ms
        case "audio": return 0.0005     // 0.5ms
        default: return nil
        }
    }

    private func getMemoryUsage() -> UInt64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4

        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }

        return result == KERN_SUCCESS ? info.resident_size : 0
    }
}

struct PerformanceMetrics {
    let fps: Double
    let frameTime: TimeInterval
    let memoryUsage: UInt64
    let systemTimings: [String: TimeInterval]

    var memoryUsageMB: Double {
        return Double(memoryUsage) / 1024.0 / 1024.0
    }
}
