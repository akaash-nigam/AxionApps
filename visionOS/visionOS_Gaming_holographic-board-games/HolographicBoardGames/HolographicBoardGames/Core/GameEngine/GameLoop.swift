//
//  GameLoop.swift
//  HolographicBoardGames
//
//  Core game loop managing update cycles
//

import Foundation
import QuartzCore

protocol GameLoopDelegate: AnyObject {
    func gameLoop(_ gameLoop: GameLoop, didUpdate deltaTime: TimeInterval)
    func gameLoop(_ gameLoop: GameLoop, didFixedUpdate deltaTime: TimeInterval)
}

final class GameLoop {
    // MARK: - Properties

    weak var delegate: GameLoopDelegate?

    private(set) var isRunning = false
    private var displayLink: CADisplayLink?

    private let targetFPS: Double = 90.0
    private var lastUpdateTime: TimeInterval = 0
    private var accumulator: TimeInterval = 0
    private let fixedDeltaTime: TimeInterval = 1.0 / 60.0  // Fixed physics update at 60Hz

    // Performance tracking
    private(set) var currentFPS: Double = 0
    private var frameCount: Int = 0
    private var fpsUpdateTime: TimeInterval = 0

    // MARK: - Lifecycle

    init() {}

    /// Start the game loop
    func start() {
        guard !isRunning else { return }

        isRunning = true
        lastUpdateTime = CACurrentMediaTime()
        fpsUpdateTime = lastUpdateTime

        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink?.preferredFrameRateRange = CAFrameRateRange(
            minimum: 60,
            maximum: 120,
            preferred: 90
        )
        displayLink?.add(to: .main, forMode: .common)
    }

    /// Stop the game loop
    func stop() {
        guard isRunning else { return }

        isRunning = false
        displayLink?.invalidate()
        displayLink = nil
    }

    // MARK: - Update

    @objc private func update() {
        let currentTime = CACurrentMediaTime()
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        // Update FPS counter
        updateFPS(currentTime: currentTime)

        // Variable update for rendering and input
        delegate?.gameLoop(self, didUpdate: deltaTime)

        // Fixed update for physics
        accumulator += deltaTime
        while accumulator >= fixedDeltaTime {
            delegate?.gameLoop(self, didFixedUpdate: fixedDeltaTime)
            accumulator -= fixedDeltaTime
        }
    }

    private func updateFPS(currentTime: TimeInterval) {
        frameCount += 1

        let fpsUpdateInterval: TimeInterval = 1.0
        if currentTime - fpsUpdateTime >= fpsUpdateInterval {
            currentFPS = Double(frameCount) / (currentTime - fpsUpdateTime)
            frameCount = 0
            fpsUpdateTime = currentTime
        }
    }

    deinit {
        stop()
    }
}
