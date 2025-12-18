import Foundation

/// Main game loop that updates all game systems
actor GameLoop {
    // Target frame rate (30 FPS for life simulation)
    private let targetFrameRate: Double = 30.0
    private var targetFrameTime: TimeInterval {
        1.0 / targetFrameRate
    }

    private var lastUpdateTime: TimeInterval = 0
    private var isRunning: Bool = false
    private var isPaused: Bool = false

    private let gameState: GameState
    private var updateTask: Task<Void, Never>?

    // Game systems (will be initialized as we build them)
    private var needsSystem: NeedsSystem?
    private var relationshipSystem: RelationshipSystem?
    private var aiScheduler: AIScheduler?
    private var spatialBehaviorSystem: SpatialBehaviorSystem?

    init(gameState: GameState) {
        self.gameState = gameState
    }

    func start() async {
        guard !isRunning else { return }

        isRunning = true
        isPaused = false
        lastUpdateTime = CACurrentMediaTime()

        // Start the game loop
        updateTask = Task {
            await runLoop()
        }
    }

    func pause() {
        isPaused = true
    }

    func resume() {
        isPaused = false
        lastUpdateTime = CACurrentMediaTime()
    }

    func stop() async {
        isRunning = false
        updateTask?.cancel()
        updateTask = nil
    }

    private func runLoop() async {
        while isRunning && !Task.isCancelled {
            let currentTime = CACurrentMediaTime()

            if !isPaused {
                let deltaTime = currentTime - lastUpdateTime
                await update(deltaTime: deltaTime)
            }

            lastUpdateTime = currentTime

            // Sleep to maintain target frame rate
            let sleepDuration = max(0, targetFrameTime - (CACurrentMediaTime() - currentTime))
            try? await Task.sleep(for: .seconds(sleepDuration))
        }
    }

    private func update(deltaTime: TimeInterval) async {
        // 1. Update game time
        await gameState.advanceTime(by: deltaTime)

        // 2. Update character needs
        if let needsSystem = needsSystem {
            await needsSystem.update(deltaTime: deltaTime, gameTime: gameState.gameTime)
        }

        // 3. Update AI scheduler (processes character decisions)
        if let aiScheduler = aiScheduler {
            await aiScheduler.update(deltaTime: deltaTime)
        }

        // 4. Update relationships
        if let relationshipSystem = relationshipSystem {
            await relationshipSystem.update(deltaTime: deltaTime)
        }

        // 5. Update spatial behaviors
        if let spatialBehaviorSystem = spatialBehaviorSystem {
            await spatialBehaviorSystem.update(deltaTime: deltaTime)
        }

        // 6. Process events
        await gameState.processEvents()
    }

    // Methods to inject systems (will be called during initialization)
    func setNeedsSystem(_ system: NeedsSystem) {
        self.needsSystem = system
    }

    func setRelationshipSystem(_ system: RelationshipSystem) {
        self.relationshipSystem = system
    }

    func setAIScheduler(_ scheduler: AIScheduler) {
        self.aiScheduler = scheduler
    }

    func setSpatialBehaviorSystem(_ system: SpatialBehaviorSystem) {
        self.spatialBehaviorSystem = system
    }
}

// Placeholder types (will implement these next)
actor NeedsSystem {
    func update(deltaTime: TimeInterval, gameTime: GameTime) async {
        // TODO: Implement
    }
}

actor RelationshipSystem {
    func update(deltaTime: TimeInterval) async {
        // TODO: Implement
    }
}

actor AIScheduler {
    func update(deltaTime: TimeInterval) async {
        // TODO: Implement
    }
}

actor SpatialBehaviorSystem {
    func update(deltaTime: TimeInterval) async {
        // TODO: Implement
    }
}
