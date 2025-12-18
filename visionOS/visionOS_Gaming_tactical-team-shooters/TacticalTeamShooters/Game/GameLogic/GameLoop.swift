import Foundation
import QuartzCore

/// High-performance game loop targeting 90 FPS for Vision Pro
/// Manages frame timing, delta time calculation, and system update orchestration
@MainActor
class GameLoop {

    // MARK: - Configuration

    let targetFrameRate: Double
    let targetFrameTime: TimeInterval
    let fixedDeltaTime: TimeInterval = 1.0 / 60.0  // Physics fixed timestep

    // MARK: - State

    private var isRunning: Bool = false
    private var displayLink: CADisplayLink?
    private var lastUpdateTime: TimeInterval = 0
    private var accumulator: TimeInterval = 0

    // Frame timing metrics
    private var frameCount: Int = 0
    private var fpsTimer: TimeInterval = 0
    private(set) var currentFPS: Double = 0

    // MARK: - Callbacks

    var onUpdate: ((TimeInterval) async -> Void)?
    var onFixedUpdate: ((TimeInterval) async -> Void)?

    // MARK: - Initialization

    init(targetFrameRate: Double = 90.0) {
        self.targetFrameRate = targetFrameRate
        self.targetFrameTime = 1.0 / targetFrameRate
    }

    // MARK: - Control

    func start() {
        guard !isRunning else { return }

        isRunning = true
        lastUpdateTime = CACurrentMediaTime()

        // Create display link for frame callbacks
        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink?.preferredFramesPerSecond = Int(targetFrameRate)
        displayLink?.add(to: .main, forMode: .common)

        print("GameLoop started - Target FPS: \(targetFrameRate)")
    }

    func stop() {
        guard isRunning else { return }

        isRunning = false
        displayLink?.invalidate()
        displayLink = nil

        print("GameLoop stopped - Average FPS: \(currentFPS)")
    }

    // MARK: - Update Loop

    @objc private func update(_ displayLink: CADisplayLink) {
        guard isRunning else { return }

        let currentTime = CACurrentMediaTime()
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        // Calculate FPS
        frameCount += 1
        fpsTimer += deltaTime

        if fpsTimer >= 1.0 {
            currentFPS = Double(frameCount) / fpsTimer
            frameCount = 0
            fpsTimer = 0

            // Log FPS if below target
            if currentFPS < targetFrameRate * 0.9 {
                print("⚠️ FPS below target: \(currentFPS) / \(targetFrameRate)")
            }
        }

        // Variable timestep update
        Task {
            await onUpdate?(deltaTime)
        }

        // Fixed timestep physics update
        accumulator += deltaTime
        while accumulator >= fixedDeltaTime {
            Task {
                await onFixedUpdate?(fixedDeltaTime)
            }
            accumulator -= fixedDeltaTime
        }
    }

    // MARK: - Performance Monitoring

    var averageFrameTime: TimeInterval {
        return currentFPS > 0 ? 1.0 / currentFPS : 0
    }

    var isPerformingWell: Bool {
        return currentFPS >= targetFrameRate * 0.9  // Within 10% of target
    }
}
