import Foundation
import QuartzCore

@MainActor
class GameLoop {
    private var displayLink: CADisplayLink?
    private var lastUpdateTime: TimeInterval = 0
    private let targetFPS: Double = 90

    private let stateManager: GameStateManager
    private var isRunning = false

    init(stateManager: GameStateManager) {
        self.stateManager = stateManager
    }

    func start() {
        guard !isRunning else { return }

        isRunning = true
        lastUpdateTime = CACurrentMediaTime()

        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink?.preferredFramesPerSecond = Int(targetFPS)
        displayLink?.add(to: .main, forMode: .common)
    }

    func stop() {
        isRunning = false
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc private func update(_ displayLink: CADisplayLink) {
        let currentTime = displayLink.timestamp
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        Task {
            // Update game state
            await stateManager.update(deltaTime: deltaTime)

            // Update systems would go here
            // await physicsSystem.update(deltaTime: deltaTime)
            // await audioSystem.update(deltaTime: deltaTime)
            // etc.
        }
    }
}
