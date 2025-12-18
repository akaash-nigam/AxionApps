import Foundation
import QuartzCore

/// Manages the main game loop and frame timing
class GameLoopManager {
    // MARK: - Properties

    private var displayLink: CADisplayLink?
    private let targetFrameRate: Double
    private var lastUpdateTime: TimeInterval = 0
    private var isRunning: Bool = false

    // Systems to update
    private var updateSystems: [System] = []

    // Performance tracking
    private(set) var currentFPS: Double = 0
    private var frameCount: Int = 0
    private var lastFPSUpdate: TimeInterval = 0

    // MARK: - Initialization

    init(targetFrameRate: Double = 90.0) {
        self.targetFrameRate = targetFrameRate
    }

    // MARK: - Game Loop Control

    func start() {
        guard !isRunning else {
            print("⚠️ Game loop already running")
            return
        }

        isRunning = true
        lastUpdateTime = CACurrentMediaTime()
        lastFPSUpdate = lastUpdateTime

        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink?.preferredFramesPerSecond = Int(targetFrameRate)
        displayLink?.add(to: .main, forMode: .common)

        print("▶️ Game loop started at \(targetFrameRate) FPS target")
    }

    func stop() {
        guard isRunning else {
            print("⚠️ Game loop not running")
            return
        }

        isRunning = false
        displayLink?.invalidate()
        displayLink = nil

        print("⏹️ Game loop stopped")
    }

    // MARK: - Update Loop

    @objc private func update(displayLink: CADisplayLink) {
        let currentTime = CACurrentMediaTime()
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        // Update all systems
        for system in updateSystems {
            system.update(deltaTime: deltaTime)
        }

        // Update FPS counter
        updateFPSCounter(currentTime: currentTime)
    }

    private func updateFPSCounter(currentTime: TimeInterval) {
        frameCount += 1

        if currentTime - lastFPSUpdate >= 1.0 {
            currentFPS = Double(frameCount)
            frameCount = 0
            lastFPSUpdate = currentTime

            // Log performance warnings
            if currentFPS < targetFrameRate * 0.9 {
                print("⚠️ Performance: FPS \(Int(currentFPS)) below target \(Int(targetFrameRate))")
            }
        }
    }

    // MARK: - System Management

    func addSystem(_ system: System) {
        updateSystems.append(system)
        print("✓ Added system: \(type(of: system))")
    }

    func removeSystem(_ system: System) {
        updateSystems.removeAll { $0 === system }
        print("✓ Removed system: \(type(of: system))")
    }

    func removeAllSystems() {
        updateSystems.removeAll()
        print("✓ Removed all systems")
    }
}

/// Base protocol for game systems
protocol System: AnyObject {
    func update(deltaTime: TimeInterval)
}

/// Input system for processing user input
class InputSystem: System {
    func update(deltaTime: TimeInterval) {
        // Process input events
    }
}

/// Physics system for physical simulations
class PhysicsSystem: System {
    func update(deltaTime: TimeInterval) {
        // Update physics simulation
    }
}

/// Puzzle system for puzzle logic updates
class PuzzleSystem: System {
    func update(deltaTime: TimeInterval) {
        // Update puzzle state
    }
}

/// Audio system for sound management
class AudioSystem: System {
    func update(deltaTime: TimeInterval) {
        // Update audio (fade in/out, positional audio, etc.)
    }
}

/// Network system for multiplayer synchronization
class NetworkSystem: System {
    func update(deltaTime: TimeInterval) {
        // Process network messages and synchronization
    }
}
