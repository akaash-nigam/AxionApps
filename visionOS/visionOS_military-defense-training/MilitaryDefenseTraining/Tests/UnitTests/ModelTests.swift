//
//  ModelTests.swift
//  MilitaryDefenseTrainingTests
//
//  Created by Claude Code
//

import XCTest
@testable import MilitaryDefenseTraining

final class ModelTests: XCTestCase {

    // MARK: - Weapon System Tests

    func testWeaponFiring() {
        var weapon = WeaponSystem.m4Rifle

        let initialRounds = weapon.currentRounds
        let fired = weapon.fire()

        XCTAssertTrue(fired, "Weapon should fire successfully")
        XCTAssertEqual(weapon.currentRounds, initialRounds - 1, "Ammo count should decrease by 1")
    }

    func testWeaponReload() {
        var weapon = WeaponSystem.m4Rifle
        weapon.currentRounds = 0
        weapon.totalAmmo = 60

        weapon.reload()

        XCTAssertEqual(weapon.currentRounds, 30, "Magazine should be full after reload")
        XCTAssertEqual(weapon.totalAmmo, 30, "Total ammo should decrease by magazine capacity")
    }

    func testWeaponEmptyFire() {
        var weapon = WeaponSystem.m4Rifle
        weapon.currentRounds = 0

        let fired = weapon.fire()

        XCTAssertFalse(fired, "Weapon should not fire when empty")
    }

    // MARK: - Damage Calculation Tests

    func testBasicDamageCalculation() {
        let damageModel = DamageModel(
            baseDamage: 30,
            headMultiplier: 2.0,
            armorPenetration: 0.5,
            dropoffStart: 50,
            dropoffEnd: 300
        )

        // Test damage at close range with no armor, no headshot
        let damage = damageModel.calculateDamage(
            distance: 10,
            isHeadshot: false,
            armorValue: 0
        )

        XCTAssertEqual(damage, 30, accuracy: 0.1, "Base damage should be applied at close range")
    }

    func testHeadshotMultiplier() {
        let damageModel = DamageModel(baseDamage: 30, headMultiplier: 2.5)

        let headshotDamage = damageModel.calculateDamage(
            distance: 10,
            isHeadshot: true,
            armorValue: 0
        )

        XCTAssertEqual(headshotDamage, 75, accuracy: 0.1, "Headshot should apply 2.5x multiplier")
    }

    func testArmorReduction() {
        let damageModel = DamageModel(
            baseDamage: 30,
            armorPenetration: 0.5
        )

        let damage = damageModel.calculateDamage(
            distance: 10,
            isHeadshot: false,
            armorValue: 0.35 // Plate carrier armor
        )

        // Effective armor = 0.35 * (1 - 0.5) = 0.175
        // Damage = 30 * (1 - 0.175) = 24.75
        XCTAssertEqual(damage, 24.75, accuracy: 0.1, "Armor should reduce damage considering penetration")
    }

    // MARK: - Combat Entity Tests

    func testCombatEntityDamage() {
        let entity = CombatEntity(
            entityType: .enemy,
            health: 100,
            armor: .none
        )

        entity.takeDamage(30)

        XCTAssertEqual(entity.health, 70, "Health should decrease by damage amount")
        XCTAssertTrue(entity.isAlive, "Entity should still be alive")
    }

    func testCombatEntityDeath() {
        let entity = CombatEntity(
            entityType: .enemy,
            health: 100,
            armor: .none
        )

        entity.takeDamage(150)

        XCTAssertEqual(entity.health, 0, "Health should not go below zero")
        XCTAssertFalse(entity.isAlive, "Entity should be dead")
    }

    func testArmorDamageReduction() {
        let entity = CombatEntity(
            entityType: .enemy,
            health: 100,
            armor: .plateCarrier // 35% reduction
        )

        entity.takeDamage(100)

        // Damage after armor = 100 * (1 - 0.35) = 65
        XCTAssertEqual(entity.health, 35, accuracy: 0.1, "Plate carrier should reduce damage by 35%")
    }

    // MARK: - Performance Metrics Tests

    func testPerformanceMetricsGrading() {
        let metrics = PerformanceMetrics(
            tacticalScore: 850,
            shotsFired: 100,
            shotsHit: 75
        )

        XCTAssertEqual(metrics.grade, "B+", "Score of 850 should result in B+ grade")
        XCTAssertEqual(metrics.hitPercentage, 75, "Hit percentage should be 75%")
    }

    func testObjectiveCompletionRate() {
        let metrics = PerformanceMetrics(
            objectivesCompleted: 3,
            totalObjectives: 4
        )

        XCTAssertEqual(metrics.objectiveCompletionRate, 75, "Should calculate 75% completion")
    }

    // MARK: - OpFor AI Tests

    func testAIAwarenessIncrease() {
        let opfor = OpForUnit(
            unitType: .infantry,
            aiDifficulty: .medium
        )

        let initialAwareness = opfor.awarenessLevel

        opfor.updateAwareness(playerVisible: true, distance: 50)

        XCTAssertGreaterThan(opfor.awarenessLevel, initialAwareness, "Awareness should increase when player is visible")
    }

    func testAIAlertStates() {
        let opfor = OpForUnit(unitType: .infantry)

        opfor.awarenessLevel = 10
        XCTAssertEqual(opfor.alertState, .unaware, "Should be unaware at low awareness")

        opfor.awarenessLevel = 40
        XCTAssertEqual(opfor.alertState, .suspicious, "Should be suspicious at medium awareness")

        opfor.awarenessLevel = 65
        XCTAssertEqual(opfor.alertState, .alert, "Should be alert at high awareness")

        opfor.awarenessLevel = 90
        XCTAssertEqual(opfor.alertState, .combat, "Should be in combat at very high awareness")
    }

    // MARK: - Classification Tests

    func testClassificationComparison() {
        XCTAssertTrue(ClassificationLevel.secret > ClassificationLevel.confidential)
        XCTAssertTrue(ClassificationLevel.topSecret > ClassificationLevel.secret)
        XCTAssertTrue(ClassificationLevel.unclassified < ClassificationLevel.cui)
    }

    func testSecurityContextAccess() {
        let context = SecurityContext(
            userClearance: .secret,
            sessionClassification: .confidential
        )

        XCTAssertTrue(context.canAccess(classification: .confidential), "Secret clearance should access Confidential")
        XCTAssertTrue(context.canAccess(classification: .cui), "Secret clearance should access CUI")
        XCTAssertFalse(context.canAccess(classification: .topSecret), "Secret clearance should not access Top Secret")
    }

    // MARK: - Scenario Tests

    func testScenarioDifficulty() {
        let easyScenario = Scenario(
            name: "Test Easy",
            type: .urbanAssault,
            difficulty: .easy,
            scenarioDescription: "Test"
        )

        let expertScenario = Scenario(
            name: "Test Expert",
            type: .urbanAssault,
            difficulty: .expert,
            scenarioDescription: "Test"
        )

        XCTAssertEqual(easyScenario.difficulty.stars, 1)
        XCTAssertEqual(expertScenario.difficulty.stars, 4)
    }
}
