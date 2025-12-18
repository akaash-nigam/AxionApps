//
//  MovementMechanics.swift
//  Parkour Pathways
//
//  Parkour movement mechanics implementation
//

import Foundation
import simd

// MARK: - Precision Jump Mechanic

class PrecisionJumpMechanic {
    // Physics parameters
    let gravity: Float = 9.81 // m/s²
    let minJumpHeight: Float = 0.2 // meters
    let maxJumpHeight: Float = 0.8 // meters

    // Accuracy requirements
    let targetRadius: Float = 0.15 // meters
    let perfectRadius: Float = 0.05 // meters

    // MARK: - Scoring

    func calculateScore(
        landingPosition: SIMD3<Float>,
        targetPosition: SIMD3<Float>
    ) -> Float {
        let distance = simd_distance(landingPosition, targetPosition)

        if distance <= perfectRadius {
            return 1.0 // Perfect landing
        } else if distance <= targetRadius {
            // Linear falloff from perfect to edge
            let ratio = (targetRadius - distance) / (targetRadius - perfectRadius)
            return 0.5 + (0.5 * ratio)
        } else {
            return 0.0 // Missed target
        }
    }

    // MARK: - Physics Validation

    func isPhysicallyPossible(
        from: SIMD3<Float>,
        to: SIMD3<Float>,
        playerAttributes: PhysicalProfile
    ) -> Bool {
        let horizontalDistance = simd_distance(
            SIMD2(from.x, from.z),
            SIMD2(to.x, to.z)
        )
        let verticalDistance = to.y - from.y

        // Calculate required jump velocity
        let requiredHeight = verticalDistance + (horizontalDistance * 0.5)
        return requiredHeight <= Float(playerAttributes.jumpHeight)
    }

    func calculateJumpVelocity(
        from: SIMD3<Float>,
        to: SIMD3<Float>
    ) -> SIMD3<Float> {
        let displacement = to - from
        let horizontalDisplacement = SIMD2(displacement.x, displacement.z)
        let horizontalDistance = simd_length(horizontalDisplacement)

        // Time of flight calculation
        let timeOfFlight = sqrt(2 * abs(displacement.y) / gravity + (horizontalDistance / 5.0))

        // Calculate velocity components
        let horizontalVelocity = horizontalDisplacement / timeOfFlight
        let verticalVelocity = (displacement.y + 0.5 * gravity * timeOfFlight * timeOfFlight) / timeOfFlight

        return SIMD3<Float>(horizontalVelocity.x, verticalVelocity, horizontalVelocity.y)
    }
}

// MARK: - Vaulting System

class VaultMechanic {
    enum VaultType {
        case stepVault     // One hand, stepping motion
        case speedVault    // One hand, legs to side
        case kongVault     // Two hands, legs between
        case lazyVault     // One hand, legs over side
    }

    // Hand placement detection
    struct HandPlacement {
        let position: SIMD3<Float>
        let normal: SIMD3<Float>
        let gripStrength: Float
        let timestamp: Date
    }

    // MARK: - Vault Type Detection

    func detectVaultType(
        leftHand: HandPlacement?,
        rightHand: HandPlacement?,
        bodyVelocity: SIMD3<Float>,
        obstacleHeight: Float
    ) -> VaultType? {
        let speed = simd_length(bodyVelocity)
        let twoHandPlacement = leftHand != nil && rightHand != nil

        if twoHandPlacement && speed > 2.0 {
            return .kongVault
        } else if speed > 1.5 {
            return .speedVault
        } else if obstacleHeight < 0.8 {
            return .stepVault
        } else {
            return .lazyVault
        }
    }

    // MARK: - Technique Scoring

    func scoreTechnique(
        vaultType: VaultType,
        handPlacement: [HandPlacement],
        trajectoryData: [MovementSample]
    ) -> TechniqueScore {
        var score = TechniqueScore()

        // Hand placement accuracy
        score.handPlacement = scoreHandPlacement(handPlacement)

        // Body positioning
        score.bodyForm = scoreBodyForm(trajectoryData)

        // Fluidity
        score.fluidity = scoreFluidity(trajectoryData)

        // Speed
        score.speed = scoreSpeed(trajectoryData)

        return score
    }

    private func scoreHandPlacement(_ placements: [HandPlacement]) -> Float {
        guard !placements.isEmpty else { return 0 }

        // Check grip strength
        let avgGripStrength = placements.map { $0.gripStrength }.reduce(0, +) / Float(placements.count)

        // Check hand positioning consistency
        let consistency = calculatePlacementConsistency(placements)

        return (avgGripStrength + consistency) / 2.0
    }

    private func calculatePlacementConsistency(_ placements: [HandPlacement]) -> Float {
        guard placements.count >= 2 else { return 1.0 }

        // Calculate variance in hand positions
        let positions = placements.map { $0.position }
        let avgPosition = positions.reduce(SIMD3<Float>.zero, +) / Float(positions.count)

        let variance = positions.map { simd_distance($0, avgPosition) }.reduce(0, +) / Float(positions.count)

        // Lower variance = better consistency
        return max(0, 1.0 - variance)
    }

    private func scoreBodyForm(_ trajectoryData: [MovementSample]) -> Float {
        guard trajectoryData.count >= 3 else { return 0 }

        // Analyze body orientation during vault
        let orientations = trajectoryData.map { $0.headOrientation }

        // Check for smooth rotation
        var smoothness: Float = 1.0
        for i in 1..<orientations.count {
            let angleDiff = calculateAngleDifference(orientations[i-1], orientations[i])
            if angleDiff > 0.5 { // Rad threshold
                smoothness *= 0.9
            }
        }

        return smoothness
    }

    private func calculateAngleDifference(_ q1: simd_quatf, _ q2: simd_quatf) -> Float {
        let dot = simd_dot(q1.vector, q2.vector)
        return acos(min(abs(dot), 1.0))
    }

    private func scoreFluidity(_ trajectoryData: [MovementSample]) -> Float {
        guard trajectoryData.count >= 3 else { return 0 }

        // Calculate velocity changes
        var totalChange: Float = 0
        for i in 1..<trajectoryData.count {
            let velocityChange = simd_length(trajectoryData[i].velocity - trajectoryData[i-1].velocity)
            totalChange += velocityChange
        }

        let avgChange = totalChange / Float(trajectoryData.count - 1)

        // Lower average change = more fluid
        return max(0, 1.0 - avgChange / 10.0)
    }

    private func scoreSpeed(_ trajectoryData: [MovementSample]) -> Float {
        guard !trajectoryData.isEmpty else { return 0 }

        let speeds = trajectoryData.map { simd_length($0.velocity) }
        let maxSpeed = speeds.max() ?? 0

        // Normalize to expected range (0-5 m/s)
        return min(maxSpeed / 5.0, 1.0)
    }
}

// MARK: - Wall Run System

class WallRunMechanic {
    // Physics constraints
    let minApproachSpeed: Float = 1.5 // m/s
    let maxAngleFromWall: Float = 45.0 // degrees
    let gravityReduction: Float = 0.6 // 40% less gravity
    let maxDuration: TimeInterval = 2.0 // seconds

    // State machine
    enum WallRunState {
        case approaching
        case engaged
        case disengaging
        case completed
    }

    struct WallRunSession {
        var state: WallRunState
        var startTime: Date
        var wallNormal: SIMD3<Float>
        var contactPoint: SIMD3<Float>
        var initialVelocity: SIMD3<Float>
    }

    // MARK: - Wall Run Validation

    func canInitiateWallRun(
        playerVelocity: SIMD3<Float>,
        wallNormal: SIMD3<Float>,
        contactPoint: SIMD3<Float>
    ) -> Bool {
        let speed = simd_length(playerVelocity)
        guard speed >= minApproachSpeed else { return false }

        // Calculate approach angle
        let velocityDirection = simd_normalize(playerVelocity)
        let angle = acos(simd_dot(velocityDirection, -wallNormal))
        let angleDegrees = angle * 180.0 / .pi

        return angleDegrees <= maxAngleFromWall
    }

    func updateWallRun(
        session: inout WallRunSession,
        footContact: Bool
    ) {
        let timeElapsed = Date().timeIntervalSince(session.startTime)

        switch session.state {
        case .engaged:
            if !footContact || timeElapsed > maxDuration {
                session.state = .disengaging
            }
        case .disengaging:
            session.state = .completed
        default:
            break
        }
    }

    // MARK: - Physics Application

    func applyWallRunPhysics(
        currentVelocity: SIMD3<Float>,
        wallNormal: SIMD3<Float>,
        deltaTime: Float
    ) -> SIMD3<Float> {
        var velocity = currentVelocity

        // Reduce gravity effect
        let modifiedGravity = SIMD3<Float>(0, -9.81 * gravityReduction, 0)
        velocity += modifiedGravity * deltaTime

        // Add lateral force along wall
        let upVector = SIMD3<Float>(0, 1, 0)
        let lateralDirection = simd_normalize(simd_cross(wallNormal, upVector))
        let lateralForce = lateralDirection * 5.0
        velocity += lateralForce * deltaTime

        // Maintain wall contact (project velocity along wall)
        velocity = velocity - wallNormal * simd_dot(velocity, wallNormal)

        return velocity
    }

    func calculateWallRunScore(session: WallRunSession) -> Float {
        let duration = Date().timeIntervalSince(session.startTime)
        let maxPoints: Float = 1.0

        // Score based on duration (longer = better)
        let durationScore = min(Float(duration / maxDuration), 1.0)

        return durationScore * maxPoints
    }
}

// MARK: - Balance Training

class BalanceMechanic {
    // Balance parameters
    let stabilityThreshold: Float = 0.1 // meters
    let maxDeviation: Float = 0.3 // meters
    let recoveryTime: TimeInterval = 1.0 // seconds

    struct BalanceState {
        var centerOfMass: SIMD3<Float>
        var supportBase: SIMD3<Float>
        var deviation: Float
        var isStable: Bool
        var timeUnstable: TimeInterval
    }

    // MARK: - Balance Calculation

    func calculateBalance(
        bodyPosition: SIMD3<Float>,
        footPositions: [SIMD3<Float>],
        headPosition: SIMD3<Float>
    ) -> BalanceState {
        // Calculate center of mass (simplified)
        let centerOfMass = calculateCenterOfMass(
            body: bodyPosition,
            head: headPosition
        )

        // Calculate support base (average foot position)
        let supportBase = footPositions.isEmpty ? bodyPosition :
            footPositions.reduce(SIMD3<Float>.zero, +) / Float(footPositions.count)

        // Calculate horizontal deviation
        let deviation = simd_distance(
            SIMD2(centerOfMass.x, centerOfMass.z),
            SIMD2(supportBase.x, supportBase.z)
        )

        // Determine stability
        let isStable = deviation <= stabilityThreshold

        return BalanceState(
            centerOfMass: centerOfMass,
            supportBase: supportBase,
            deviation: deviation,
            isStable: isStable,
            timeUnstable: 0
        )
    }

    private func calculateCenterOfMass(
        body: SIMD3<Float>,
        head: SIMD3<Float>
    ) -> SIMD3<Float> {
        // Simplified center of mass calculation
        // Body weight ~87%, head weight ~13%
        return body * 0.87 + head * 0.13
    }

    // MARK: - Balance Assistance

    func provideBalanceAssistance(_ state: BalanceState) -> BalanceGuidance {
        if !state.isStable {
            // Calculate correction direction
            let correctionDirection = state.supportBase - state.centerOfMass
            let correctionMagnitude = state.deviation / maxDeviation

            return BalanceGuidance(
                shouldProvideGuidance: true,
                correctionDirection: simd_normalize(correctionDirection),
                urgency: correctionMagnitude,
                hapticIntensity: correctionMagnitude,
                visualIndicatorPosition: state.centerOfMass
            )
        }

        return BalanceGuidance(shouldProvideGuidance: false)
    }

    func scoreBalance(samples: [BalanceState]) -> Float {
        guard !samples.isEmpty else { return 0 }

        // Calculate percentage of time stable
        let stableCount = samples.filter { $0.isStable }.count
        let stabilityRatio = Float(stableCount) / Float(samples.count)

        // Calculate average deviation
        let avgDeviation = samples.map { $0.deviation }.reduce(0, +) / Float(samples.count)
        let deviationScore = max(0, 1.0 - (avgDeviation / maxDeviation))

        // Combine scores
        return (stabilityRatio * 0.6) + (deviationScore * 0.4)
    }
}

// MARK: - Supporting Types

struct TechniqueScore {
    var handPlacement: Float = 0
    var bodyForm: Float = 0
    var fluidity: Float = 0
    var speed: Float = 0

    var overall: Float {
        (handPlacement + bodyForm + fluidity + speed) / 4.0
    }
}

struct BalanceGuidance {
    var shouldProvideGuidance: Bool
    var correctionDirection: SIMD3<Float> = .zero
    var urgency: Float = 0
    var hapticIntensity: Float = 0
    var visualIndicatorPosition: SIMD3<Float> = .zero
}

// MARK: - Movement Coordinator

class MovementCoordinator {
    private let precisionJump = PrecisionJumpMechanic()
    private let vault = VaultMechanic()
    private let wallRun = WallRunMechanic()
    private let balance = BalanceMechanic()

    // Track current movement
    private var currentMovement: ActiveMovement?

    enum ActiveMovement {
        case jumping(start: SIMD3<Float>, target: SIMD3<Float>)
        case vaulting(type: VaultMechanic.VaultType, startTime: Date)
        case wallRunning(session: WallRunMechanic.WallRunSession)
        case balancing(startTime: Date)
    }

    func processMovement(
        playerPosition: SIMD3<Float>,
        playerVelocity: SIMD3<Float>,
        handPositions: (left: SIMD3<Float>?, right: SIMD3<Float>?),
        footPositions: [SIMD3<Float>],
        headPosition: SIMD3<Float>
    ) -> MovementResult {
        // Detect and process current movement

        // Check for vault
        if let vaultType = detectVault(handPositions: handPositions, velocity: playerVelocity) {
            return MovementResult(
                type: .vault(vaultType),
                score: 0, // Will be calculated on completion
                feedback: "Vaulting..."
            )
        }

        // Check for wall run
        if let wallRunState = detectWallRun(position: playerPosition, velocity: playerVelocity) {
            return MovementResult(
                type: .wallRun,
                score: 0,
                feedback: "Wall running..."
            )
        }

        // Check balance
        let balanceState = balance.calculateBalance(
            bodyPosition: playerPosition,
            footPositions: footPositions,
            headPosition: headPosition
        )

        if !balanceState.isStable {
            return MovementResult(
                type: .balancing,
                score: 0,
                feedback: "Maintain balance..."
            )
        }

        return MovementResult(
            type: .idle,
            score: 0,
            feedback: ""
        )
    }

    private func detectVault(
        handPositions: (left: SIMD3<Float>?, right: SIMD3<Float>?),
        velocity: SIMD3<Float>
    ) -> VaultMechanic.VaultType? {
        // Simple vault detection logic
        if handPositions.left != nil || handPositions.right != nil {
            let speed = simd_length(velocity)
            if speed > 1.5 {
                return .speedVault
            } else {
                return .stepVault
            }
        }
        return nil
    }

    private func detectWallRun(
        position: SIMD3<Float>,
        velocity: SIMD3<Float>
    ) -> WallRunMechanic.WallRunState? {
        // Simplified wall run detection
        // In real implementation, would check against room walls
        return nil
    }
}

struct MovementResult {
    enum MovementType {
        case idle
        case vault(VaultMechanic.VaultType)
        case wallRun
        case balancing
        case jumping
    }

    let type: MovementType
    let score: Float
    let feedback: String
}
