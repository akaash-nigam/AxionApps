//
//  GameSystems.swift
//  Parkour Pathways
//
//  RealityKit ECS Systems for game logic
//

import RealityKit
import simd
import Foundation

// MARK: - Obstacle Interaction System

class ObstacleInteractionSystem: System {
    static let query = EntityQuery(where: .has(ObstacleComponent.self))

    private var playerPosition: SIMD3<Float> = .zero
    private var playerVelocity: SIMD3<Float> = .zero

    required init(scene: Scene) {
        // Initialize system
    }

    func update(context: SceneUpdateContext) {
        // Update player position from tracking
        updatePlayerTracking()

        // Process all obstacles
        context.scene.performQuery(Self.query).forEach { entity in
            guard var obstacle = entity.components[ObstacleComponent.self] else { return }

            let distance = simd_distance(playerPosition, entity.position)

            // Update interaction state based on distance
            let previousState = obstacle.interactionState
            updateInteractionState(&obstacle, distance: distance, entity: entity)

            // Handle state transitions
            if obstacle.interactionState != previousState {
                handleStateTransition(entity, from: previousState, to: obstacle.interactionState)
            }

            // Update component
            entity.components[ObstacleComponent.self] = obstacle
        }
    }

    private func updatePlayerTracking() {
        // This would be updated from ARKit tracking
        // Placeholder for now
    }

    private func updateInteractionState(
        _ obstacle: inout ObstacleComponent,
        distance: Float,
        entity: Entity
    ) {
        if distance < obstacle.safetyZone * 0.5 {
            obstacle.interactionState = .engaged
        } else if distance < obstacle.safetyZone {
            obstacle.interactionState = .nearby
        } else if obstacle.interactionState == .completed {
            // Keep completed state
        } else {
            obstacle.interactionState = .idle
        }
    }

    private func handleStateTransition(
        _ entity: Entity,
        from: ObstacleComponent.InteractionState,
        to: ObstacleComponent.InteractionState
    ) {
        switch to {
        case .nearby:
            // Highlight obstacle
            if entity.components[HighlightComponent.self] == nil {
                entity.components.set(HighlightComponent(isHighlighted: true))
            }

        case .engaged:
            // Trigger haptic feedback
            // Play interaction sound
            triggerHapticFeedback()
            playInteractionSound(entity)

        case .completed:
            // Show completion effect
            showCompletionEffect(entity)

        case .idle:
            // Remove highlight
            if var highlight = entity.components[HighlightComponent.self] {
                highlight.isHighlighted = false
                entity.components[HighlightComponent.self] = highlight
            }
        }
    }

    private func triggerHapticFeedback() {
        // Trigger device haptics
    }

    private func playInteractionSound(_ entity: Entity) {
        // Play spatial audio
    }

    private func showCompletionEffect(_ entity: Entity) {
        // Add particle effect
        entity.components.set(ParticleEffectComponent(
            effectType: .completion,
            isActive: true,
            startTime: Date()
        ))
    }
}

// MARK: - Movement Analysis System

class MovementAnalysisSystem: System {
    static let query = EntityQuery(where: .has(MovementTrackingComponent.self))

    private let analysisEngine = MovementAnalysisEngine()

    required init(scene: Scene) {
        // Initialize system
    }

    func update(context: SceneUpdateContext) {
        context.scene.performQuery(Self.query).forEach { entity in
            guard var tracking = entity.components[MovementTrackingComponent.self] else { return }

            // Calculate current velocity and acceleration
            if tracking.movementHistory.count >= 2 {
                let recent = Array(tracking.movementHistory.suffix(2))
                tracking.currentVelocity = calculateVelocity(recent)

                if tracking.movementHistory.count >= 3 {
                    tracking.currentAcceleration = calculateAcceleration(
                        Array(tracking.movementHistory.suffix(3))
                    )
                }
            }

            // Analyze technique if enough samples
            if tracking.movementHistory.count >= 10 {
                let analysis = analysisEngine.analyzeTechnique(
                    samples: Array(tracking.movementHistory.suffix(30))
                )
                provideFeedback(entity, analysis: analysis)
            }

            // Update component
            entity.components[MovementTrackingComponent.self] = tracking
        }
    }

    private func calculateVelocity(_ samples: [MovementSample]) -> SIMD3<Float> {
        guard samples.count >= 2 else { return .zero }
        let deltaPos = samples[1].bodyPosition - samples[0].bodyPosition
        let deltaTime = Float(samples[1].timestamp - samples[0].timestamp)
        return deltaTime > 0 ? deltaPos / deltaTime : .zero
    }

    private func calculateAcceleration(_ samples: [MovementSample]) -> SIMD3<Float> {
        guard samples.count >= 3 else { return .zero }
        let v0 = samples[1].bodyPosition - samples[0].bodyPosition
        let v1 = samples[2].bodyPosition - samples[1].bodyPosition
        let dt = Float(samples[1].timestamp - samples[0].timestamp)
        return dt > 0 ? (v1 - v0) / (dt * dt) : .zero
    }

    private func provideFeedback(_ entity: Entity, analysis: TechniqueAnalysis) {
        if var feedback = entity.components[TechniqueFeedbackComponent.self] {
            // Add feedback based on analysis
            if analysis.score >= 0.9 {
                feedback.addFeedback("Perfect technique!", type: .perfect)
            } else if analysis.score >= 0.7 {
                feedback.addFeedback("Good form!", type: .good)
            } else {
                feedback.addFeedback(analysis.feedback.first ?? "Keep practicing", type: .needsImprovement)
            }

            entity.components[TechniqueFeedbackComponent.self] = feedback
        }
    }
}

// MARK: - Safety Monitoring System

class SafetyMonitoringSystem: System {
    static let query = EntityQuery(where: .has(SafetyComponent.self))
    static let priority: SystemPriority = .high

    private var roomBoundaries: [SIMD3<Float>] = []
    private var obstacles: [Entity] = []

    required init(scene: Scene) {
        // Initialize with room boundaries
    }

    func update(context: SceneUpdateContext) {
        let playerPosition = getPlayerPosition()
        let playerVelocity = getPlayerVelocity()

        context.scene.performQuery(Self.query).forEach { entity in
            guard var safety = entity.components[SafetyComponent.self] else { return }

            // Check boundary distance
            safety.boundaryDistance = calculateBoundaryDistance(playerPosition)

            // Predict collision risk
            safety.collisionRisk = predictCollisionRisk(
                position: playerPosition,
                velocity: playerVelocity
            )

            // Determine warning level
            safety.warningLevel = determineWarningLevel(
                boundaryDistance: safety.boundaryDistance,
                collisionRisk: safety.collisionRisk
            )

            // Update safe zone status
            safety.isInSafeZone = safety.warningLevel == .none

            // Take action based on warning level
            handleWarningLevel(safety.warningLevel)

            // Update component
            entity.components[SafetyComponent.self] = safety
        }
    }

    private func getPlayerPosition() -> SIMD3<Float> {
        // Get from ARKit tracking
        return .zero
    }

    private func getPlayerVelocity() -> SIMD3<Float> {
        // Get from tracking data
        return .zero
    }

    private func calculateBoundaryDistance(_ position: SIMD3<Float>) -> Float {
        var minDistance: Float = .infinity
        for boundary in roomBoundaries {
            let distance = simd_distance(position, boundary)
            minDistance = min(minDistance, distance)
        }
        return minDistance
    }

    private func predictCollisionRisk(position: SIMD3<Float>, velocity: SIMD3<Float>) -> Float {
        // Predict position in next 0.5 seconds
        let futurePosition = position + velocity * 0.5
        var maxRisk: Float = 0.0

        for obstacle in obstacles {
            let distance = simd_distance(futurePosition, obstacle.position)
            if distance < 0.5 {
                let risk = 1.0 - (distance / 0.5)
                maxRisk = max(maxRisk, risk)
            }
        }

        return maxRisk
    }

    private func determineWarningLevel(boundaryDistance: Float, collisionRisk: Float) -> SafetyComponent.WarningLevel {
        if boundaryDistance < 0.3 || collisionRisk > 0.8 {
            return .critical
        } else if boundaryDistance < 0.6 || collisionRisk > 0.5 {
            return .warning
        } else if boundaryDistance < 1.0 || collisionRisk > 0.3 {
            return .caution
        }
        return .none
    }

    private func handleWarningLevel(_ level: SafetyComponent.WarningLevel) {
        switch level {
        case .critical:
            triggerEmergencyWarning()
        case .warning:
            displayBoundaryWarning()
        case .caution:
            subtleWarningFeedback()
        case .none:
            break
        }
    }

    private func triggerEmergencyWarning() {
        // Show critical warning
        // Trigger strong haptic
        // Play warning sound
    }

    private func displayBoundaryWarning() {
        // Show visual boundary indicator
    }

    private func subtleWarningFeedback() {
        // Subtle haptic feedback
    }
}

// MARK: - Score Calculation System

class ScoreCalculationSystem: System {
    static let query = EntityQuery(where: .has(ScoreComponent.self))

    required init(scene: Scene) {}

    func update(context: SceneUpdateContext) {
        context.scene.performQuery(Self.query).forEach { entity in
            guard var score = entity.components[ScoreComponent.self] else { return }

            // Update technique multiplier from recent performance
            if let tracking = entity.components[MovementTrackingComponent.self] {
                score.techniqueMultiplier = calculateTechniqueMultiplier(tracking)
            }

            // Update combo multiplier
            score.comboMultiplier = calculateComboMultiplier(entity)

            // Update component
            entity.components[ScoreComponent.self] = score
        }
    }

    private func calculateTechniqueMultiplier(_ tracking: MovementTrackingComponent) -> Float {
        // Analyze recent movements for technique quality
        // Return multiplier between 0.5 and 2.0
        return 1.0
    }

    private func calculateComboMultiplier(_ entity: Entity) -> Float {
        // Calculate based on consecutive successful obstacles
        return 1.0
    }
}

// MARK: - Animation System

class AnimationSystem: System {
    static let query = EntityQuery(where: .has(AnimationStateComponent.self))

    required init(scene: Scene) {}

    func update(context: SceneUpdateContext) {
        context.scene.performQuery(Self.query).forEach { entity in
            guard var animState = entity.components[AnimationStateComponent.self] else { return }

            if animState.isPlaying, let animName = animState.currentAnimation {
                // Update animation playback
                updateAnimation(entity, animationName: animName, loopMode: animState.loopMode)
            }

            entity.components[AnimationStateComponent.self] = animState
        }
    }

    private func updateAnimation(_ entity: Entity, animationName: String, loopMode: AnimationStateComponent.AnimationLoopMode) {
        // Play animation on entity
    }
}

// MARK: - Particle Effect System

class ParticleEffectSystem: System {
    static let query = EntityQuery(where: .has(ParticleEffectComponent.self))

    required init(scene: Scene) {}

    func update(context: SceneUpdateContext) {
        context.scene.performQuery(Self.query).forEach { entity in
            guard var particle = entity.components[ParticleEffectComponent.self] else { return }

            if particle.isActive {
                if let startTime = particle.startTime {
                    let elapsed = Date().timeIntervalSince(startTime)

                    if elapsed >= particle.duration {
                        // Effect completed
                        particle.isActive = false
                        removeParticleEffect(entity, type: particle.effectType)
                    } else {
                        // Update particle effect
                        updateParticleEffect(entity, type: particle.effectType, progress: Float(elapsed / particle.duration))
                    }
                } else {
                    // Start effect
                    particle.startTime = Date()
                    createParticleEffect(entity, type: particle.effectType)
                }
            }

            entity.components[ParticleEffectComponent.self] = particle
        }
    }

    private func createParticleEffect(_ entity: Entity, type: ParticleEffectComponent.EffectType) {
        // Create and attach particle emitter
    }

    private func updateParticleEffect(_ entity: Entity, type: ParticleEffectComponent.EffectType, progress: Float) {
        // Update particle parameters
    }

    private func removeParticleEffect(_ entity: Entity, type: ParticleEffectComponent.EffectType) {
        // Remove particle emitter
    }
}

// MARK: - Checkpoint System

class CheckpointSystem: System {
    static let query = EntityQuery(where: .has(CheckpointComponent.self))

    private var playerPosition: SIMD3<Float> = .zero

    required init(scene: Scene) {}

    func update(context: SceneUpdateContext) {
        context.scene.performQuery(Self.query).forEach { entity in
            guard var checkpoint = entity.components[CheckpointComponent.self] else { return }

            if !checkpoint.isReached && checkpoint.canActivate {
                let distance = simd_distance(playerPosition, entity.position)

                if distance < 0.5 { // Within checkpoint radius
                    checkpoint.isReached = true
                    triggerCheckpointReached(entity)
                }
            }

            entity.components[CheckpointComponent.self] = checkpoint
        }
    }

    private func triggerCheckpointReached(_ entity: Entity) {
        // Play checkpoint sound
        // Show checkpoint effect
        // Update game state
        NotificationCenter.default.post(
            name: .checkpointReached,
            object: entity.id
        )
    }
}

// MARK: - Ghost Playback System

class GhostPlaybackSystem: System {
    static let query = EntityQuery(where: .has(GhostComponent.self))

    required init(scene: Scene) {}

    func update(context: SceneUpdateContext) {
        let deltaTime = Float(context.deltaTime)

        context.scene.performQuery(Self.query).forEach { entity in
            guard var ghost = entity.components[GhostComponent.self] else { return }

            if ghost.isPlaying {
                let recording = ghost.recording

                if ghost.currentSampleIndex < recording.samples.count {
                    let sample = recording.samples[ghost.currentSampleIndex]

                    // Update entity position and rotation
                    entity.position = sample.position
                    entity.orientation = sample.rotation

                    // Advance to next sample
                    ghost.currentSampleIndex += 1
                } else {
                    // Recording complete
                    ghost.isPlaying = false
                    ghost.currentSampleIndex = 0
                }
            }

            entity.components[GhostComponent.self] = ghost
        }
    }
}

// MARK: - Helper Structs

struct TechniqueAnalysis {
    var score: Float
    var feedback: [String]
    var improvementAreas: [String]
}

class MovementAnalysisEngine {
    func analyzeTechnique(samples: [MovementSample]) -> TechniqueAnalysis {
        // Analyze movement samples
        // Return technique analysis
        return TechniqueAnalysis(
            score: 0.8,
            feedback: ["Good form"],
            improvementAreas: []
        )
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let checkpointReached = Notification.Name("checkpointReached")
}
