//
//  GameLoop.swift
//  Reality Realms RPG
//
//  Main game loop running at 90 FPS
//

import Foundation
import QuartzCore

/// Main game loop synchronized with display refresh
@MainActor
class GameLoop {
    private var displayLink: CADisplayLink?
    private let targetFPS: Double = 90.0
    private var lastUpdateTime: CFTimeInterval = 0
    private var deltaTime: TimeInterval = 0

    // Systems to update
    private var updateSystems: [GameSystem] = []

    // State
    private(set) var isRunning = false
    private var frameCount: UInt64 = 0

    init() {
        print("🔄 GameLoop initialized (target: \(targetFPS) FPS)")
    }

    // MARK: - Lifecycle

    func start() {
        guard !isRunning else { return }

        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink?.preferredFramesPerSecond = Int(targetFPS)
        displayLink?.add(to: .main, forMode: .common)

        isRunning = true
        print("▶️ GameLoop started")
    }

    func stop() {
        guard isRunning else { return }

        displayLink?.invalidate()
        displayLink = nil

        isRunning = false
        print("⏹️ GameLoop stopped")
    }

    func pause() {
        displayLink?.isPaused = true
    }

    func resume() {
        displayLink?.isPaused = false
        lastUpdateTime = CACurrentMediaTime()  // Reset to avoid large delta
    }

    // MARK: - Update Loop

    @objc private func update(_ displayLink: CADisplayLink) {
        PerformanceMonitor.shared.beginFrame()

        let currentTime = displayLink.targetTimestamp
        deltaTime = lastUpdateTime > 0 ? currentTime - lastUpdateTime : 0
        lastUpdateTime = currentTime

        // Clamp delta time to prevent spiral of death
        let maxDeltaTime = 1.0 / 30.0  // 30 FPS minimum
        deltaTime = min(deltaTime, maxDeltaTime)

        // Fixed update phases
        processInput(deltaTime)
        updatePhysics(deltaTime)
        updateGameLogic(deltaTime)
        updateAI(deltaTime)
        updateAnimations(deltaTime)
        updateAudio(deltaTime)

        // Record frame for performance monitoring
        PerformanceMonitor.shared.recordFrame(deltaTime: deltaTime)
        PerformanceMonitor.shared.endFrame()

        frameCount += 1

        // Log stats every 5 seconds
        if frameCount % 450 == 0 {
            PerformanceMonitor.shared.logPerformanceStats()
        }
    }

    // MARK: - Update Phases

    private func processInput(_ deltaTime: TimeInterval) {
        // Input processing handled by InputManager
    }

    private func updatePhysics(_ deltaTime: TimeInterval) {
        // Physics simulation
        for system in updateSystems where system is PhysicsSystem {
            system.update(deltaTime: deltaTime)
        }
    }

    private func updateGameLogic(_ deltaTime: TimeInterval) {
        // Game logic
        for system in updateSystems where system is GameLogicSystem {
            system.update(deltaTime: deltaTime)
        }
    }

    private func updateAI(_ deltaTime: TimeInterval) {
        // AI systems
        for system in updateSystems where system is AISystem {
            system.update(deltaTime: deltaTime)
        }
    }

    private func updateAnimations(_ deltaTime: TimeInterval) {
        // Animation updates
        for system in updateSystems where system is AnimationSystem {
            system.update(deltaTime: deltaTime)
        }
    }

    private func updateAudio(_ deltaTime: TimeInterval) {
        // Audio updates
        // Handled by SpatialAudioManager
    }

    // MARK: - System Management

    func registerSystem(_ system: GameSystem) {
        updateSystems.append(system)
        print("✅ Registered system: \(type(of: system))")
    }

    func unregisterSystem(_ system: GameSystem) {
        updateSystems.removeAll { $0 === system }
    }

    // MARK: - Public Properties

    var currentDeltaTime: TimeInterval {
        deltaTime
    }

    var currentFrameRate: Double {
        deltaTime > 0 ? 1.0 / deltaTime : 0
    }
}

// MARK: - Game System Protocol

/// Protocol for all game systems that need updates
protocol GameSystem: AnyObject {
    func update(deltaTime: TimeInterval)
}

// Marker protocols for system categorization
protocol PhysicsSystem: GameSystem {}
protocol GameLogicSystem: GameSystem {}
protocol AISystem: GameSystem {}
protocol AnimationSystem: GameSystem {}
