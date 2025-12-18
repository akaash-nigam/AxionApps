//
//  BotAI.swift
//  Spatial Arena Championship
//
//  Bot AI controller for single-player and training
//

import Foundation
import RealityKit
import simd

// MARK: - Bot AI Controller

@MainActor
class BotAI {
    let botEntity: Entity
    let difficulty: Difficulty

    private var currentState: BotState = .idle
    private var targetEnemy: Entity?
    private var targetObjective: Entity?
    private var lastStateChange: TimeInterval = 0
    private var lastShotTime: TimeInterval = 0
    private var lastAbilityTime: TimeInterval = 0

    // Behavior parameters based on difficulty
    private var reactionTime: TimeInterval
    private var accuracy: Float
    private var abilityUsageChance: Float
    private var objectiveAwareness: Float

    init(botEntity: Entity, difficulty: Difficulty) {
        self.botEntity = botEntity
        self.difficulty = difficulty

        // Configure based on difficulty
        switch difficulty {
        case .easy:
            self.reactionTime = 0.5
            self.accuracy = 0.3
            self.abilityUsageChance = 0.2
            self.objectiveAwareness = 0.3
        case .medium:
            self.reactionTime = 0.3
            self.accuracy = 0.5
            self.abilityUsageChance = 0.4
            self.objectiveAwareness = 0.6
        case .hard:
            self.reactionTime = 0.15
            self.accuracy = 0.7
            self.abilityUsageChance = 0.6
            self.objectiveAwareness = 0.8
        case .pro:
            self.reactionTime = 0.1
            self.accuracy = 0.85
            self.abilityUsageChance = 0.8
            self.objectiveAwareness = 1.0
        }
    }

    // MARK: - Update

    func update(deltaTime: TimeInterval, scene: Scene) {
        let currentTime = Date().timeIntervalSince1970

        // Update state machine
        updateState(currentTime: currentTime, scene: scene)

        // Execute current state behavior
        switch currentState {
        case .idle:
            executeIdle(scene: scene)
        case .seekingEnemy:
            executeSeekingEnemy(deltaTime: deltaTime, scene: scene)
        case .combat:
            executeCombat(deltaTime: deltaTime, currentTime: currentTime, scene: scene)
        case .seekingObjective:
            executeSeekingObjective(deltaTime: deltaTime, scene: scene)
        case .retreating:
            executeRetreating(deltaTime: deltaTime, scene: scene)
        case .collectingPowerUp:
            executeCollectingPowerUp(deltaTime: deltaTime, scene: scene)
        }
    }

    // MARK: - State Machine

    private func updateState(currentTime: TimeInterval, scene: Scene) {
        guard let botPlayer = botEntity.components[PlayerComponent.self],
              let health = botEntity.components[HealthComponent.self] else {
            return
        }

        // Check if should retreat (low health)
        if health.healthPercentage < 0.3 && currentState != .retreating {
            transitionTo(.retreating, at: currentTime)
            return
        }

        // Find nearest enemy
        let nearestEnemy = findNearestEnemy(scene: scene, botTeam: botPlayer.team)

        // Find nearest objective
        let nearestObjective = findNearestObjective(scene: scene, botTeam: botPlayer.team)

        // Find nearest power-up
        let nearestPowerUp = findNearestPowerUp(scene: scene)

        // Decision tree based on awareness and priorities
        if let enemy = nearestEnemy, distance(botEntity.position, enemy.position) < 5.0 {
            // Enemy in range - engage
            targetEnemy = enemy
            if currentState != .combat {
                transitionTo(.combat, at: currentTime)
            }
        } else if let powerUp = nearestPowerUp,
                  distance(botEntity.position, powerUp.position) < 3.0,
                  Float.random(in: 0...1) < objectiveAwareness {
            // Power-up nearby and aware of it
            targetObjective = powerUp
            if currentState != .collectingPowerUp {
                transitionTo(.collectingPowerUp, at: currentTime)
            }
        } else if let objective = nearestObjective,
                  Float.random(in: 0...1) < objectiveAwareness {
            // Go to objective
            targetObjective = objective
            if currentState != .seekingObjective {
                transitionTo(.seekingObjective, at: currentTime)
            }
        } else if nearestEnemy != nil {
            // Seek enemy
            targetEnemy = nearestEnemy
            if currentState != .seekingEnemy {
                transitionTo(.seekingEnemy, at: currentTime)
            }
        } else {
            // Default to idle/patrol
            if currentState != .idle {
                transitionTo(.idle, at: currentTime)
            }
        }
    }

    private func transitionTo(_ newState: BotState, at time: TimeInterval) {
        currentState = newState
        lastStateChange = time
    }

    // MARK: - State Behaviors

    private func executeIdle(scene: Scene) {
        // Random patrol movement
        if Float.random(in: 0...1) < 0.1 { // 10% chance per frame
            let randomDirection = SIMD3<Float>(
                Float.random(in: -1...1),
                0,
                Float.random(in: -1...1)
            )
            // TODO: Move in random direction
        }
    }

    private func executeSeekingEnemy(deltaTime: TimeInterval, scene: Scene) {
        guard let enemy = targetEnemy else {
            transitionTo(.idle, at: Date().timeIntervalSince1970)
            return
        }

        // Move toward enemy
        let direction = normalize(enemy.position - botEntity.position)
        moveToward(direction, deltaTime: deltaTime)
    }

    private func executeCombat(deltaTime: TimeInterval, currentTime: TimeInterval, scene: Scene) {
        guard let enemy = targetEnemy,
              let botPlayer = botEntity.components[PlayerComponent.self] else {
            transitionTo(.idle, at: currentTime)
            return
        }

        let distanceToEnemy = distance(botEntity.position, enemy.position)

        // Strafe behavior (move sideways)
        if distanceToEnemy < 4.0 {
            executeStrafeMovement(enemy: enemy, deltaTime: deltaTime)
        } else {
            // Move closer
            let direction = normalize(enemy.position - botEntity.position)
            moveToward(direction, deltaTime: deltaTime)
        }

        // Shooting with reaction time delay
        if currentTime - lastShotTime >= reactionTime {
            shootAtEnemy(enemy, currentTime: currentTime, scene: scene)
        }

        // Use abilities
        if currentTime - lastAbilityTime >= 2.0,
           Float.random(in: 0...1) < abilityUsageChance {
            useAbility(enemy: enemy, currentTime: currentTime, scene: scene)
        }
    }

    private func executeSeekingObjective(deltaTime: TimeInterval, scene: Scene) {
        guard let objective = targetObjective else {
            transitionTo(.idle, at: Date().timeIntervalSince1970)
            return
        }

        // Move toward objective
        let direction = normalize(objective.position - botEntity.position)
        moveToward(direction, deltaTime: deltaTime)

        // Check if reached
        if distance(botEntity.position, objective.position) < 1.0 {
            transitionTo(.idle, at: Date().timeIntervalSince1970)
        }
    }

    private func executeRetreating(deltaTime: TimeInterval, scene: Scene) {
        guard let health = botEntity.components[HealthComponent.self] else { return }

        // Find nearest cover or retreat away from enemies
        if let enemy = targetEnemy {
            let retreatDirection = normalize(botEntity.position - enemy.position)
            moveToward(retreatDirection, deltaTime: deltaTime)
        }

        // Return to combat when health recovered
        if health.healthPercentage > 0.7 {
            transitionTo(.idle, at: Date().timeIntervalSince1970)
        }
    }

    private func executeCollectingPowerUp(deltaTime: TimeInterval, scene: Scene) {
        guard let powerUp = targetObjective else {
            transitionTo(.idle, at: Date().timeIntervalSince1970)
            return
        }

        // Move toward power-up
        let direction = normalize(powerUp.position - botEntity.position)
        moveToward(direction, deltaTime: deltaTime)

        // Check if collected (close enough)
        if distance(botEntity.position, powerUp.position) < 0.5 {
            transitionTo(.idle, at: Date().timeIntervalSince1970)
        }
    }

    // MARK: - Movement

    private func moveToward(_ direction: SIMD3<Float>, deltaTime: TimeInterval) {
        guard var velocity = botEntity.components[VelocityComponent.self] else { return }

        let targetVelocity = direction * GameConstants.Movement.walkSpeed
        velocity.linear = targetVelocity

        botEntity.components[VelocityComponent.self] = velocity
    }

    private func executeStrafeMovement(enemy: Entity, deltaTime: TimeInterval) {
        // Strafe perpendicular to enemy direction
        let toEnemy = normalize(enemy.position - botEntity.position)
        let strafeDirection = SIMD3<Float>(-toEnemy.z, 0, toEnemy.x) // Perpendicular

        // Random strafe direction change
        let finalDirection = Float.random(in: 0...1) < 0.5 ? strafeDirection : -strafeDirection

        moveToward(finalDirection, deltaTime: deltaTime)
    }

    // MARK: - Combat Actions

    private func shootAtEnemy(_ enemy: Entity, currentTime: TimeInterval, scene: Scene) {
        guard let botPlayer = botEntity.components[PlayerComponent.self] else { return }

        // Calculate aim direction with accuracy variation
        var aimDirection = normalize(enemy.position - botEntity.position)

        // Add inaccuracy based on difficulty
        let inaccuracy = (1.0 - accuracy) * 0.3
        aimDirection.x += Float.random(in: -inaccuracy...inaccuracy)
        aimDirection.z += Float.random(in: -inaccuracy...inaccuracy)
        aimDirection = normalize(aimDirection)

        // Fire projectile (would call combat system)
        // TODO: Integrate with CombatSystem.fireProjectile

        lastShotTime = currentTime
    }

    private func useAbility(enemy: Entity, currentTime: TimeInterval, scene: Scene) {
        guard let botPlayer = botEntity.components[PlayerComponent.self],
              let energy = botEntity.components[EnergyComponent.self] else {
            return
        }

        // Decide which ability to use based on situation
        let distanceToEnemy = distance(botEntity.position, enemy.position)

        if distanceToEnemy < 3.0 && energy.current >= GameConstants.Abilities.Shield.energyCost {
            // Use shield when close
            // TODO: Activate shield ability
            lastAbilityTime = currentTime
        } else if distanceToEnemy > 6.0 && energy.current >= GameConstants.Abilities.Dash.energyCost {
            // Dash to close distance
            let dashDirection = normalize(enemy.position - botEntity.position)
            // TODO: Activate dash ability
            lastAbilityTime = currentTime
        }
    }

    // MARK: - Perception

    private func findNearestEnemy(scene: Scene, botTeam: TeamColor) -> Entity? {
        var nearest: Entity?
        var nearestDistance: Float = Float.infinity

        for entity in scene.entities {
            if let foundEnemy = searchForEnemy(in: entity, botTeam: botTeam, nearest: &nearest, nearestDistance: &nearestDistance) {
                nearest = foundEnemy
            }
        }

        return nearest
    }

    private func searchForEnemy(in entity: Entity, botTeam: TeamColor, nearest: inout Entity?, nearestDistance: inout Float) -> Entity? {
        if let player = entity.components[PlayerComponent.self],
           let health = entity.components[HealthComponent.self],
           player.team != botTeam,
           health.isAlive {
            let dist = distance(botEntity.position, entity.position)
            if dist < nearestDistance {
                nearestDistance = dist
                return entity
            }
        }

        for child in entity.children {
            if let foundEnemy = searchForEnemy(in: child, botTeam: botTeam, nearest: &nearest, nearestDistance: &nearestDistance) {
                return foundEnemy
            }
        }

        return nil
    }

    private func findNearestObjective(scene: Scene, botTeam: TeamColor) -> Entity? {
        var nearest: Entity?
        var nearestDistance: Float = Float.infinity

        for entity in scene.entities {
            searchForObjective(in: entity, nearest: &nearest, nearestDistance: &nearestDistance)
        }

        return nearest
    }

    private func searchForObjective(in entity: Entity, nearest: inout Entity?, nearestDistance: inout Float) {
        if let territory = entity.components[TerritoryComponent.self],
           territory.controllingTeam == nil || territory.isContested {
            let dist = distance(botEntity.position, entity.position)
            if dist < nearestDistance {
                nearestDistance = dist
                nearest = entity
            }
        }

        for child in entity.children {
            searchForObjective(in: child, nearest: &nearest, nearestDistance: &nearestDistance)
        }
    }

    private func findNearestPowerUp(scene: Scene) -> Entity? {
        var nearest: Entity?
        var nearestDistance: Float = Float.infinity

        for entity in scene.entities {
            if entity.name.hasPrefix("PowerUp_") {
                let dist = distance(botEntity.position, entity.position)
                if dist < nearestDistance {
                    nearestDistance = dist
                    nearest = entity
                }
            }

            for child in entity.children {
                if child.name.hasPrefix("PowerUp_") {
                    let dist = distance(botEntity.position, child.position)
                    if dist < nearestDistance {
                        nearestDistance = dist
                        nearest = child
                    }
                }
            }
        }

        return nearest
    }

    // MARK: - Utilities

    private func distance(_ a: SIMD3<Float>, _ b: SIMD3<Float>) -> Float {
        return simd_distance(a, b)
    }
}

// MARK: - Bot State

enum BotState {
    case idle
    case seekingEnemy
    case combat
    case seekingObjective
    case retreating
    case collectingPowerUp
}

// MARK: - Difficulty

enum Difficulty: String, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    case pro = "Pro"

    var description: String {
        switch self {
        case .easy: return "Learning the basics"
        case .medium: return "Competent opponent"
        case .hard: return "Challenging combat"
        case .pro: return "Pro-level difficulty"
        }
    }
}

// MARK: - Bot Manager

@MainActor
class BotManager {
    private var bots: [UUID: BotAI] = [:]

    func createBot(in scene: Scene, team: TeamColor, difficulty: Difficulty, spawnPosition: SIMD3<Float>) -> Entity {
        let botPlayer = Player(
            username: "Bot_\(Int.random(in: 1000...9999))",
            skillRating: difficultyToSR(difficulty),
            team: team
        )

        let botEntity = EntityFactory.createPlayer(
            id: botPlayer.id,
            username: botPlayer.username,
            position: spawnPosition,
            team: team,
            isLocalPlayer: false
        )

        let botAI = BotAI(botEntity: botEntity, difficulty: difficulty)
        bots[botPlayer.id] = botAI

        return botEntity
    }

    func update(deltaTime: TimeInterval, scene: Scene) {
        for (_, bot) in bots {
            bot.update(deltaTime: deltaTime, scene: scene)
        }
    }

    func removeBot(_ botID: UUID) {
        bots.removeValue(forKey: botID)
    }

    private func difficultyToSR(_ difficulty: Difficulty) -> Int {
        switch difficulty {
        case .easy: return 500
        case .medium: return 1500
        case .hard: return 2500
        case .pro: return 3500
        }
    }
}
