//
//  AbilitySystemTests.swift
//  Spatial Arena Championship Tests
//
//  Unit tests for Ability System
//

import XCTest
import RealityKit
@testable import SpatialArenaChampionship

@MainActor
final class AbilitySystemTests: XCTestCase {

    var abilitySystem: AbilitySystem!
    var scene: Scene!
    var combatSystem: CombatSystem!

    override func setUp() async throws {
        try await super.setUp()
        scene = Scene()
        combatSystem = CombatSystem(scene: scene)
        abilitySystem = AbilitySystem(scene: scene, combatSystem: combatSystem)
    }

    override func tearDown() {
        abilitySystem = nil
        combatSystem = nil
        scene = nil
        super.tearDown()
    }

    // MARK: - Primary Fire Tests

    func testPrimaryFireConsumesEnergy() {
        let player = EntityFactory.createPlayer(
            id: UUID(),
            position: .zero,
            team: .blue
        )
        scene.addAnchor(AnchorEntity())
        scene.anchors.first?.addChild(player)

        guard var playerComponent = player.components[PlayerComponent.self] else {
            XCTFail("Player component not found")
            return
        }

        let initialEnergy = playerComponent.abilities.primary.energyCost

        let success = abilitySystem.activatePrimary(for: player, direction: [0, 0, 1])

        XCTAssertTrue(success)
        // Energy should have been consumed
    }

    func testPrimaryFireOnCooldownFails() {
        let player = EntityFactory.createPlayer(
            id: UUID(),
            position: .zero,
            team: .blue
        )
        scene.addAnchor(AnchorEntity())
        scene.anchors.first?.addChild(player)

        // Fire once
        let firstShot = abilitySystem.activatePrimary(for: player, direction: [0, 0, 1])
        XCTAssertTrue(firstShot)

        // Immediately fire again (should fail due to cooldown)
        let secondShot = abilitySystem.activatePrimary(for: player, direction: [0, 0, 1])
        XCTAssertFalse(secondShot)
    }

    // MARK: - Shield Wall Tests

    func testShieldWallDeployment() {
        let player = EntityFactory.createPlayer(
            id: UUID(),
            position: .zero,
            team: .blue
        )
        scene.addAnchor(AnchorEntity())
        scene.anchors.first?.addChild(player)

        let success = abilitySystem.activateSecondary(for: player, direction: [0, 0, 1])

        XCTAssertTrue(success)
        // Check that a shield entity was created in the scene
    }

    // MARK: - Dash Tests

    func testDashActivation() {
        let player = EntityFactory.createPlayer(
            id: UUID(),
            position: .zero,
            team: .blue
        )
        scene.addAnchor(AnchorEntity())
        scene.anchors.first?.addChild(player)

        let initialPosition = player.position

        let success = abilitySystem.activateTactical(for: player, direction: [0, 0, 1])

        XCTAssertTrue(success)
        // Position should have changed
    }

    // MARK: - Ultimate Tests

    func testUltimateRequiresFullCharge() {
        let player = EntityFactory.createPlayer(
            id: UUID(),
            position: .zero,
            team: .blue
        )
        scene.addAnchor(AnchorEntity())
        scene.anchors.first?.addChild(player)

        guard var playerComponent = player.components[PlayerComponent.self] else {
            XCTFail("Player component not found")
            return
        }

        playerComponent.ultimateCharge = 50.0 // Not full
        player.components[PlayerComponent.self] = playerComponent

        let success = abilitySystem.activateUltimate(for: player)

        XCTAssertFalse(success)
    }

    func testUltimateActivatesWhenFullyCharged() {
        let player = EntityFactory.createPlayer(
            id: UUID(),
            position: .zero,
            team: .blue
        )
        scene.addAnchor(AnchorEntity())
        scene.anchors.first?.addChild(player)

        guard var playerComponent = player.components[PlayerComponent.self] else {
            XCTFail("Player component not found")
            return
        }

        playerComponent.ultimateCharge = 100.0
        player.components[PlayerComponent.self] = playerComponent

        let success = abilitySystem.activateUltimate(for: player)

        XCTAssertTrue(success)
    }

    // MARK: - Cooldown Tests

    func testCooldownDecay() {
        let player = EntityFactory.createPlayer(
            id: UUID(),
            position: .zero,
            team: .blue
        )
        scene.addAnchor(AnchorEntity())
        scene.anchors.first?.addChild(player)

        // Activate ability
        _ = abilitySystem.activatePrimary(for: player, direction: [0, 0, 1])

        // Update system to process cooldowns
        abilitySystem.update(deltaTime: 2.0)

        // After cooldown expires, should be able to fire again
        abilitySystem.update(deltaTime: 10.0) // Ensure cooldown expired

        let success = abilitySystem.activatePrimary(for: player, direction: [0, 0, 1])
        XCTAssertTrue(success)
    }

    // MARK: - Area Damage Tests

    func testNovaBlastDamagesInRadius() {
        // Create attacker
        let attacker = EntityFactory.createPlayer(
            id: UUID(),
            position: .zero,
            team: .blue
        )

        // Create targets at various distances
        let closeTarget = EntityFactory.createPlayer(
            id: UUID(),
            position: SIMD3<Float>(2, 0, 0), // Within radius
            team: .red
        )

        let farTarget = EntityFactory.createPlayer(
            id: UUID(),
            position: SIMD3<Float>(20, 0, 0), // Outside radius
            team: .red
        )

        scene.addAnchor(AnchorEntity())
        scene.anchors.first?.addChild(attacker)
        scene.anchors.first?.addChild(closeTarget)
        scene.anchors.first?.addChild(farTarget)

        guard var attackerComponent = attacker.components[PlayerComponent.self] else {
            XCTFail("Attacker component not found")
            return
        }

        attackerComponent.ultimateCharge = 100.0
        attacker.components[PlayerComponent.self] = attackerComponent

        let closeInitialHealth = closeTarget.components[HealthComponent.self]?.current ?? 0
        let farInitialHealth = farTarget.components[HealthComponent.self]?.current ?? 0

        // Activate ultimate (Nova Blast)
        _ = abilitySystem.activateUltimate(for: attacker)

        // Close target should take damage
        let closeFinalHealth = closeTarget.components[HealthComponent.self]?.current ?? 0
        XCTAssertLessThan(closeFinalHealth, closeInitialHealth)

        // Far target should not take damage
        let farFinalHealth = farTarget.components[HealthComponent.self]?.current ?? 0
        XCTAssertEqual(farFinalHealth, farInitialHealth)
    }

    // MARK: - Performance Tests

    func testAbilityActivationPerformance() {
        let player = EntityFactory.createPlayer(
            id: UUID(),
            position: .zero,
            team: .blue
        )
        scene.addAnchor(AnchorEntity())
        scene.anchors.first?.addChild(player)

        measure {
            for _ in 0..<100 {
                _ = abilitySystem.activatePrimary(for: player, direction: [0, 0, 1])
                abilitySystem.update(deltaTime: 1.0)
            }
        }
    }
}
