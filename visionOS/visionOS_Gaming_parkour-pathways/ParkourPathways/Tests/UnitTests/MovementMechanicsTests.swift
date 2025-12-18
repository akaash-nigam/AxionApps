//
//  MovementMechanicsTests.swift
//  Parkour Pathways Tests
//
//  Unit tests for movement mechanics
//

import XCTest
@testable import ParkourPathways

final class PrecisionJumpMechanicTests: XCTestCase {
    var mechanic: PrecisionJumpMechanic!

    override func setUp() {
        super.setUp()
        mechanic = PrecisionJumpMechanic()
    }

    override func tearDown() {
        mechanic = nil
        super.tearDown()
    }

    // MARK: - Score Calculation Tests

    func testPerfectLanding() {
        // Perfect landing (exact center)
        let score = mechanic.calculateScore(
            landingPosition: SIMD3<Float>(0, 0, 0),
            targetPosition: SIMD3<Float>(0, 0, 0)
        )

        XCTAssertEqual(score, 1.0, accuracy: 0.01, "Perfect landing should score 1.0")
    }

    func testGoodLanding() {
        // Good landing (within target radius but not perfect)
        let score = mechanic.calculateScore(
            landingPosition: SIMD3<Float>(0.1, 0, 0),
            targetPosition: SIMD3<Float>(0, 0, 0)
        )

        XCTAssertGreaterThan(score, 0.5, "Good landing should score > 0.5")
        XCTAssertLessThan(score, 1.0, "Good landing should score < 1.0")
    }

    func testMissedTarget() {
        // Missed target (outside radius)
        let score = mechanic.calculateScore(
            landingPosition: SIMD3<Float>(1.0, 0, 0),
            targetPosition: SIMD3<Float>(0, 0, 0)
        )

        XCTAssertEqual(score, 0.0, "Missed landing should score 0.0")
    }

    func testPerfectRadiusLanding() {
        // Landing exactly at perfect radius edge
        let perfectRadius = mechanic.perfectRadius
        let score = mechanic.calculateScore(
            landingPosition: SIMD3<Float>(perfectRadius, 0, 0),
            targetPosition: SIMD3<Float>(0, 0, 0)
        )

        XCTAssertGreaterThan(score, 0.9, "Landing at perfect radius edge should score high")
    }

    // MARK: - Physics Validation Tests

    func testPhysicallyPossibleJump() {
        let playerProfile = PhysicalProfile(
            height: 1.7,
            reach: 0.7,
            jumpHeight: 0.6,
            fitnessLevel: .intermediate
        )

        let isPossible = mechanic.isPhysicallyPossible(
            from: SIMD3<Float>(0, 0, 0),
            to: SIMD3<Float>(1, 0.3, 0),
            playerAttributes: playerProfile
        )

        XCTAssertTrue(isPossible, "Reasonable jump should be physically possible")
    }

    func testPhysicallyImpossibleJump() {
        let playerProfile = PhysicalProfile(
            height: 1.7,
            reach: 0.7,
            jumpHeight: 0.3,
            fitnessLevel: .beginner
        )

        let isPossible = mechanic.isPhysicallyPossible(
            from: SIMD3<Float>(0, 0, 0),
            to: SIMD3<Float>(5, 2, 0),
            playerAttributes: playerProfile
        )

        XCTAssertFalse(isPossible, "Unrealistic jump should not be physically possible")
    }

    func testJumpVelocityCalculation() {
        let velocity = mechanic.calculateJumpVelocity(
            from: SIMD3<Float>(0, 0, 0),
            to: SIMD3<Float>(2, 0.5, 0)
        )

        XCTAssertGreaterThan(velocity.y, 0, "Upward velocity should be positive")
        XCTAssertGreaterThan(simd_length(velocity), 0, "Velocity should be non-zero")
    }
}

// MARK: - Vault Mechanic Tests

final class VaultMechanicTests: XCTestCase {
    var mechanic: VaultMechanic!

    override func setUp() {
        super.setUp()
        mechanic = VaultMechanic()
    }

    override func tearDown() {
        mechanic = nil
        super.tearDown()
    }

    // MARK: - Vault Type Detection

    func testKongVaultDetection() {
        let leftHand = VaultMechanic.HandPlacement(
            position: SIMD3<Float>(0, 1, 0),
            normal: SIMD3<Float>(0, 1, 0),
            gripStrength: 0.9,
            timestamp: Date()
        )

        let rightHand = VaultMechanic.HandPlacement(
            position: SIMD3<Float>(0.3, 1, 0),
            normal: SIMD3<Float>(0, 1, 0),
            gripStrength: 0.9,
            timestamp: Date()
        )

        let vaultType = mechanic.detectVaultType(
            leftHand: leftHand,
            rightHand: rightHand,
            bodyVelocity: SIMD3<Float>(0, 0, 2.5),
            obstacleHeight: 0.8
        )

        XCTAssertEqual(vaultType, .kongVault, "Two hands + high speed should detect Kong vault")
    }

    func testSpeedVaultDetection() {
        let rightHand = VaultMechanic.HandPlacement(
            position: SIMD3<Float>(0, 1, 0),
            normal: SIMD3<Float>(0, 1, 0),
            gripStrength: 0.8,
            timestamp: Date()
        )

        let vaultType = mechanic.detectVaultType(
            leftHand: nil,
            rightHand: rightHand,
            bodyVelocity: SIMD3<Float>(0, 0, 2.0),
            obstacleHeight: 0.7
        )

        XCTAssertEqual(vaultType, .speedVault, "One hand + high speed should detect Speed vault")
    }

    func testStepVaultDetection() {
        let rightHand = VaultMechanic.HandPlacement(
            position: SIMD3<Float>(0, 0.5, 0),
            normal: SIMD3<Float>(0, 1, 0),
            gripStrength: 0.7,
            timestamp: Date()
        )

        let vaultType = mechanic.detectVaultType(
            leftHand: nil,
            rightHand: rightHand,
            bodyVelocity: SIMD3<Float>(0, 0, 1.0),
            obstacleHeight: 0.6
        )

        XCTAssertEqual(vaultType, .stepVault, "Low obstacle + low speed should detect Step vault")
    }

    // MARK: - Technique Scoring

    func testTechniqueScoring() {
        let handPlacement = VaultMechanic.HandPlacement(
            position: SIMD3<Float>(0, 1, 0),
            normal: SIMD3<Float>(0, 1, 0),
            gripStrength: 0.9,
            timestamp: Date()
        )

        let trajectoryData = createMockTrajectoryData()

        let score = mechanic.scoreTechnique(
            vaultType: .speedVault,
            handPlacement: [handPlacement],
            trajectoryData: trajectoryData
        )

        XCTAssertGreaterThan(score.overall, 0, "Technique score should be positive")
        XCTAssertLessThanOrEqual(score.overall, 1.0, "Technique score should not exceed 1.0")
    }

    private func createMockTrajectoryData() -> [MovementSample] {
        var samples: [MovementSample] = []
        for i in 0..<10 {
            samples.append(MovementSample(
                timestamp: TimeInterval(i) * 0.1,
                bodyPosition: SIMD3<Float>(0, Float(i) * 0.1, Float(i) * 0.2),
                velocity: SIMD3<Float>(0, 1, 2),
                acceleration: SIMD3<Float>(0, 0, 0),
                handPositions: (left: .zero, right: .zero),
                headOrientation: simd_quatf(),
                jointAngles: [:]
            ))
        }
        return samples
    }
}

// MARK: - Wall Run Mechanic Tests

final class WallRunMechanicTests: XCTestCase {
    var mechanic: WallRunMechanic!

    override func setUp() {
        super.setUp()
        mechanic = WallRunMechanic()
    }

    override func tearDown() {
        mechanic = nil
        super.tearDown()
    }

    func testCanInitiateWallRun_ValidConditions() {
        let playerVelocity = SIMD3<Float>(2, 0, 0)
        let wallNormal = SIMD3<Float>(-1, 0, 0)
        let contactPoint = SIMD3<Float>(1, 1, 0)

        let canInitiate = mechanic.canInitiateWallRun(
            playerVelocity: playerVelocity,
            wallNormal: wallNormal,
            contactPoint: contactPoint
        )

        XCTAssertTrue(canInitiate, "Valid wall run conditions should allow initiation")
    }

    func testCanInitiateWallRun_TooSlow() {
        let playerVelocity = SIMD3<Float>(0.5, 0, 0)
        let wallNormal = SIMD3<Float>(-1, 0, 0)
        let contactPoint = SIMD3<Float>(1, 1, 0)

        let canInitiate = mechanic.canInitiateWallRun(
            playerVelocity: playerVelocity,
            wallNormal: wallNormal,
            contactPoint: contactPoint
        )

        XCTAssertFalse(canInitiate, "Too slow velocity should prevent wall run")
    }

    func testWallRunPhysics() {
        let currentVelocity = SIMD3<Float>(2, 0, 0)
        let wallNormal = SIMD3<Float>(-1, 0, 0)
        let deltaTime: Float = 0.016 // ~60 FPS

        let newVelocity = mechanic.applyWallRunPhysics(
            currentVelocity: currentVelocity,
            wallNormal: wallNormal,
            deltaTime: deltaTime
        )

        XCTAssertGreaterThan(newVelocity.y, currentVelocity.y, "Wall run should add upward velocity")
    }

    func testWallRunStateTransition() {
        var session = WallRunMechanic.WallRunSession(
            state: .engaged,
            startTime: Date(),
            wallNormal: SIMD3<Float>(-1, 0, 0),
            contactPoint: SIMD3<Float>(1, 1, 0),
            initialVelocity: SIMD3<Float>(2, 0, 0)
        )

        mechanic.updateWallRun(session: &session, footContact: false)

        XCTAssertEqual(session.state, .disengaging, "Loss of foot contact should disengage wall run")
    }
}

// MARK: - Balance Mechanic Tests

final class BalanceMechanicTests: XCTestCase {
    var mechanic: BalanceMechanic!

    override func setUp() {
        super.setUp()
        mechanic = BalanceMechanic()
    }

    override func tearDown() {
        mechanic = nil
        super.tearDown()
    }

    func testCalculateBalance_Stable() {
        let bodyPosition = SIMD3<Float>(0, 1, 0)
        let footPositions = [SIMD3<Float>(0, 0, 0)]
        let headPosition = SIMD3<Float>(0, 1.7, 0)

        let balanceState = mechanic.calculateBalance(
            bodyPosition: bodyPosition,
            footPositions: footPositions,
            headPosition: headPosition
        )

        XCTAssertTrue(balanceState.isStable, "Aligned position should be stable")
        XCTAssertLessThan(balanceState.deviation, mechanic.stabilityThreshold)
    }

    func testCalculateBalance_Unstable() {
        let bodyPosition = SIMD3<Float>(0.3, 1, 0)
        let footPositions = [SIMD3<Float>(0, 0, 0)]
        let headPosition = SIMD3<Float>(0.5, 1.7, 0)

        let balanceState = mechanic.calculateBalance(
            bodyPosition: bodyPosition,
            footPositions: footPositions,
            headPosition: headPosition
        )

        XCTAssertFalse(balanceState.isStable, "Offset position should be unstable")
        XCTAssertGreaterThan(balanceState.deviation, mechanic.stabilityThreshold)
    }

    func testProvideBalanceAssistance() {
        let unstableState = BalanceMechanic.BalanceState(
            centerOfMass: SIMD3<Float>(0.2, 1, 0),
            supportBase: SIMD3<Float>(0, 0, 0),
            deviation: 0.2,
            isStable: false,
            timeUnstable: 0.5
        )

        let guidance = mechanic.provideBalanceAssistance(unstableState)

        XCTAssertTrue(guidance.shouldProvideGuidance, "Unstable state should trigger guidance")
        XCTAssertGreaterThan(guidance.urgency, 0, "Guidance should have urgency")
    }

    func testScoreBalance() {
        var samples: [BalanceMechanic.BalanceState] = []

        // 80% stable samples
        for i in 0..<10 {
            samples.append(BalanceMechanic.BalanceState(
                centerOfMass: SIMD3<Float>(0, 1, 0),
                supportBase: SIMD3<Float>(0, 0, 0),
                deviation: i < 8 ? 0.05 : 0.2,
                isStable: i < 8,
                timeUnstable: 0
            ))
        }

        let score = mechanic.scoreBalance(samples: samples)

        XCTAssertGreaterThan(score, 0.7, "80% stability should score > 0.7")
        XCTAssertLessThanOrEqual(score, 1.0, "Score should not exceed 1.0")
    }
}

// MARK: - Movement Coordinator Tests

final class MovementCoordinatorTests: XCTestCase {
    var coordinator: MovementCoordinator!

    override func setUp() {
        super.setUp()
        coordinator = MovementCoordinator()
    }

    override func tearDown() {
        coordinator = nil
        super.tearDown()
    }

    func testProcessMovement_Idle() {
        let result = coordinator.processMovement(
            playerPosition: SIMD3<Float>(0, 1, 0),
            playerVelocity: SIMD3<Float>(0, 0, 0),
            handPositions: (left: nil, right: nil),
            footPositions: [SIMD3<Float>(0, 0, 0)],
            headPosition: SIMD3<Float>(0, 1.7, 0)
        )

        XCTAssertEqual(result.type, .idle, "No movement should result in idle state")
    }

    func testProcessMovement_DetectsVault() {
        let result = coordinator.processMovement(
            playerPosition: SIMD3<Float>(0, 1, 0),
            playerVelocity: SIMD3<Float>(0, 0, 2.0),
            handPositions: (left: nil, right: SIMD3<Float>(0, 1, 0)),
            footPositions: [SIMD3<Float>(0, 0, 0)],
            headPosition: SIMD3<Float>(0, 1.7, 0)
        )

        if case .vault = result.type {
            XCTAssert(true, "Hand placement with speed should detect vault")
        } else {
            XCTFail("Expected vault detection")
        }
    }
}
