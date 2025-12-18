//
//  AIDirectorService.swift
//  MilitaryDefenseTraining
//
//  Created by Claude Code
//

import Foundation
import simd

actor AIDirectorService {
    private var activeEnemies: [UUID: OpForUnit] = [:]
    private var spawnPoints: [SIMD3<Float>] = []
    private var difficultyMultiplier: Float = 1.0
    private var maxActiveEnemies: Int = 20
    private var playerPerformance: Float = 0.5 // 0-1 scale

    // MARK: - Enemy Spawning

    func spawnEnemy(
        type: OpForType,
        position: SIMD3<Float>,
        difficulty: AIDifficulty,
        doctrine: TacticalDoctrine = .conventional
    ) async -> OpForUnit {
        let enemy = OpForUnit(
            unitType: type,
            doctrine: doctrine,
            aiDifficulty: difficulty
        )

        activeEnemies[enemy.id] = enemy
        return enemy
    }

    func spawnSquad(
        size: Int,
        position: SIMD3<Float>,
        difficulty: AIDifficulty,
        doctrine: TacticalDoctrine
    ) async -> [OpForUnit] {
        let squadID = UUID()
        var squad: [OpForUnit] = []

        for i in 0..<size {
            // Spread squad members around spawn point
            let offset = SIMD3<Float>(
                Float.random(in: -5...5),
                0,
                Float.random(in: -5...5)
            )

            var enemy = await spawnEnemy(
                type: .infantry,
                position: position + offset,
                difficulty: difficulty,
                doctrine: doctrine
            )

            enemy.squadID = squadID
            squad.append(enemy)
        }

        return squad
    }

    func despawnEnemy(_ id: UUID) {
        activeEnemies.removeValue(forKey: id)
    }

    func getActiveEnemies() -> [OpForUnit] {
        return Array(activeEnemies.values)
    }

    // MARK: - Adaptive Difficulty

    func adjustDifficulty(basedOn metrics: PerformanceMetrics) async {
        // Calculate player skill level
        let accuracy = metrics.accuracy / 100.0
        let survival = 1.0 - Float(min(metrics.casualtiesTaken, 3)) / 3.0
        let objectiveSuccess = Float(metrics.objectivesCompleted) / Float(max(metrics.totalObjectives, 1))

        playerPerformance = (accuracy + survival + objectiveSuccess) / 3.0

        // Adjust difficulty multiplier
        if playerPerformance > 0.8 {
            // Player is doing too well, increase difficulty
            difficultyMultiplier = min(2.0, difficultyMultiplier + 0.1)
        } else if playerPerformance < 0.4 {
            // Player is struggling, decrease difficulty
            difficultyMultiplier = max(0.5, difficultyMultiplier - 0.1)
        }

        // Adjust active enemy count
        if playerPerformance > 0.7 {
            maxActiveEnemies = min(30, maxActiveEnemies + 2)
        } else if playerPerformance < 0.5 {
            maxActiveEnemies = max(10, maxActiveEnemies - 2)
        }

        print("Difficulty adjusted: multiplier=\(difficultyMultiplier), maxEnemies=\(maxActiveEnemies)")
    }

    func getDifficultyMultiplier() -> Float {
        return difficultyMultiplier
    }

    // MARK: - Reinforcement System

    func shouldSpawnReinforcements() async -> Bool {
        let activeCount = activeEnemies.count

        if activeCount < maxActiveEnemies / 2 {
            // Half of enemies defeated, spawn reinforcements
            return true
        }

        // Random chance based on difficulty
        let chance = difficultyMultiplier * 0.2
        return Float.random(in: 0...1) < chance
    }

    func spawnReinforcements(
        near position: SIMD3<Float>,
        count: Int,
        difficulty: AIDifficulty
    ) async -> [OpForUnit] {
        var reinforcements: [OpForUnit] = []

        for _ in 0..<count {
            // Spawn at random position around the area
            let spawnPos = position + SIMD3<Float>(
                Float.random(in: -20...20),
                0,
                Float.random(in: -20...20)
            )

            let enemy = await spawnEnemy(
                type: .infantry,
                position: spawnPos,
                difficulty: difficulty
            )
            reinforcements.append(enemy)
        }

        return reinforcements
    }

    // MARK: - Squad Coordination

    func coordinateSquad(_ squad: [OpForUnit], target: SIMD3<Float>) async {
        guard !squad.isEmpty else { return }

        // Assign different tactical roles
        for (index, enemy) in squad.enumerated() {
            switch index % 3 {
            case 0:
                // Suppression fire
                enemy.currentObjective = .suppress(target: target)
            case 1:
                // Flank left
                enemy.currentObjective = .flank(target: target, direction: .left)
            case 2:
                // Flank right
                enemy.currentObjective = .flank(target: target, direction: .right)
            default:
                // Advance
                enemy.currentObjective = .attack(target: target)
            }
        }
    }

    func formDefensivePerimeter(squad: [OpForUnit], center: SIMD3<Float>, radius: Float) async {
        let angleStep = 2.0 * Float.pi / Float(squad.count)

        for (index, enemy) in squad.enumerated() {
            let angle = Float(index) * angleStep
            let position = SIMD3<Float>(
                center.x + radius * cos(angle),
                center.y,
                center.z + radius * sin(angle)
            )

            enemy.currentObjective = .defend(position: position, radius: 5.0)
        }
    }

    // MARK: - Tactical AI Behaviors

    func updateEnemyBehaviors(playerPosition: SIMD3<Float>, deltaTime: TimeInterval) async {
        for enemy in activeEnemies.values {
            // Update awareness based on player distance
            guard let enemyEntity = enemy.combatEntity else { continue }

            let distance = simd_distance(enemyEntity.position, playerPosition)
            let isVisible = distance < enemy.detectionRadius
            enemy.updateAwareness(playerVisible: isVisible, distance: distance)

            // Determine behavior based on state
            switch enemy.alertState {
            case .unaware:
                // Patrol or idle
                if enemy.currentObjective == nil {
                    assignPatrolObjective(to: enemy)
                }

            case .suspicious:
                // Investigate
                enemy.currentObjective = .patrol(waypoints: [
                    enemy.lastKnownPlayerPosition ?? playerPosition
                ])

            case .alert:
                // Move to better position
                enemy.currentObjective = .takecover(near: enemyEntity.position)

            case .combat:
                // Engage player
                if distance > 30 {
                    // Close distance
                    enemy.currentObjective = .attack(target: playerPosition)
                } else {
                    // Tactical maneuvers
                    if enemy.morale > 50 {
                        // Aggressive
                        enemy.currentObjective = .suppress(target: playerPosition)
                    } else {
                        // Defensive
                        enemy.currentObjective = .takecover(near: enemyEntity.position)
                    }
                }
            }

            // Update morale
            updateMorale(enemy: enemy, playerDistance: distance)
        }
    }

    private func assignPatrolObjective(to enemy: OpForUnit) {
        guard let entity = enemy.combatEntity else { return }

        // Generate random patrol waypoints
        let waypoints = [
            entity.position + SIMD3<Float>(10, 0, 0),
            entity.position + SIMD3<Float>(10, 0, 10),
            entity.position + SIMD3<Float>(0, 0, 10),
            entity.position
        ]

        enemy.currentObjective = .patrol(waypoints: waypoints)
    }

    private func updateMorale(enemy: OpForUnit, playerDistance: Float) {
        guard let entity = enemy.combatEntity else { return }

        // Morale decreases when wounded
        if entity.health < entity.maxHealth * 0.5 {
            enemy.morale = max(0, enemy.morale - 0.5)
        }

        // Morale decreases when player is very close
        if playerDistance < 10 {
            enemy.morale = max(0, enemy.morale - 0.2)
        }

        // Morale increases when at distance
        if playerDistance > 50 {
            enemy.morale = min(100, enemy.morale + 0.1)
        }

        // Low morale = retreat
        if enemy.morale < 30 {
            enemy.currentObjective = .retreat(to: entity.position + SIMD3<Float>(50, 0, 0))
        }
    }

    // MARK: - Director Control

    func setSpawnPoints(_ points: [SIMD3<Float>]) {
        self.spawnPoints = points
    }

    func getRandomSpawnPoint() -> SIMD3<Float>? {
        return spawnPoints.randomElement()
    }

    func reset() {
        activeEnemies.removeAll()
        difficultyMultiplier = 1.0
        maxActiveEnemies = 20
        playerPerformance = 0.5
    }

    // MARK: - Analytics

    func getEnemyStats() -> EnemyStatistics {
        let totalEnemies = activeEnemies.count
        let alertEnemies = activeEnemies.values.filter { $0.alertState == .combat }.count
        let averageMorale = activeEnemies.values.reduce(0.0) { $0 + $1.morale } / Float(max(totalEnemies, 1))

        return EnemyStatistics(
            totalActive: totalEnemies,
            inCombat: alertEnemies,
            averageMorale: averageMorale,
            difficultyMultiplier: difficultyMultiplier
        )
    }
}

// MARK: - Supporting Types

struct EnemyStatistics {
    var totalActive: Int
    var inCombat: Int
    var averageMorale: Float
    var difficultyMultiplier: Float
}
