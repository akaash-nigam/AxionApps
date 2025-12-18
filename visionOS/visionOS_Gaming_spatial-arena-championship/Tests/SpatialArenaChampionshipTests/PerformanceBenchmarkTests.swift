//
//  PerformanceBenchmarkTests.swift
//  Spatial Arena Championship Tests
//
//  Performance benchmarking tests
//

import XCTest
import RealityKit
@testable import SpatialArenaChampionship

@MainActor
final class PerformanceBenchmarkTests: XCTestCase {

    // MARK: - Entity Creation Performance

    func testEntityFactoryPerformance() {
        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
            for _ in 0..<100 {
                let _ = EntityFactory.createPlayer(
                    id: UUID(),
                    position: SIMD3<Float>(
                        Float.random(in: -10...10),
                        0,
                        Float.random(in: -10...10)
                    ),
                    team: Bool.random() ? .blue : .red
                )
            }
        }
    }

    func testProjectileCreationPerformance() {
        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
            for _ in 0..<500 {
                let _ = EntityFactory.createProjectile(
                    position: .zero,
                    direction: SIMD3<Float>(0, 0, 1),
                    speed: 15.0,
                    damage: 25.0,
                    ownerID: UUID(),
                    team: .blue
                )
            }
        }
    }

    // MARK: - System Update Performance

    func testMovementSystemPerformance() {
        let scene = Scene()
        let arena = Arena.cyberArena()
        let movementSystem = MovementSystem(scene: scene, arenaBounds: arena.dimensions)

        // Create multiple entities
        let anchor = AnchorEntity()
        scene.addAnchor(anchor)

        for i in 0..<50 {
            let player = EntityFactory.createPlayer(
                id: UUID(),
                position: SIMD3<Float>(Float(i), 0, 0),
                team: i % 2 == 0 ? .blue : .red
            )
            anchor.addChild(player)
        }

        measure(metrics: [XCTClockMetric(), XCTCPUMetric()]) {
            for _ in 0..<100 {
                movementSystem.update(deltaTime: 0.016) // 60 FPS
            }
        }
    }

    func testCombatSystemPerformance() {
        let scene = Scene()
        let combatSystem = CombatSystem(scene: scene)

        // Create players
        let anchor = AnchorEntity()
        scene.addAnchor(anchor)

        for i in 0..<20 {
            let player = EntityFactory.createPlayer(
                id: UUID(),
                position: SIMD3<Float>(Float(i), 0, 0),
                team: i % 2 == 0 ? .blue : .red
            )
            anchor.addChild(player)
        }

        // Create projectiles
        for i in 0..<100 {
            let projectile = EntityFactory.createProjectile(
                position: SIMD3<Float>(Float(i % 10), 0, Float(i / 10)),
                direction: SIMD3<Float>(0, 0, 1),
                speed: 15.0,
                damage: 25.0,
                ownerID: UUID(),
                team: .blue
            )
            anchor.addChild(projectile)
        }

        measure(metrics: [XCTClockMetric(), XCTCPUMetric()]) {
            for _ in 0..<100 {
                combatSystem.update(deltaTime: 0.016)
            }
        }
    }

    // MARK: - AI Performance

    func testBotAIDecisionMakingPerformance() {
        let scene = Scene()
        let anchor = AnchorEntity()
        scene.addAnchor(anchor)

        // Create bot
        let bot = EntityFactory.createPlayer(
            id: UUID(),
            position: .zero,
            team: .blue
        )
        anchor.addChild(bot)

        // Create enemies
        for i in 0..<10 {
            let enemy = EntityFactory.createPlayer(
                id: UUID(),
                position: SIMD3<Float>(Float(i * 5), 0, Float(i * 5)),
                team: .red
            )
            anchor.addChild(enemy)
        }

        let botAI = BotAI(entity: bot, difficulty: .hard)

        measure(metrics: [XCTClockMetric(), XCTCPUMetric()]) {
            for _ in 0..<1000 {
                botAI.update(deltaTime: 0.016, scene: scene)
            }
        }
    }

    func testMultipleBotPerformance() {
        let scene = Scene()
        let anchor = AnchorEntity()
        scene.addAnchor(anchor)

        var bots: [(Entity, BotAI)] = []

        // Create 8 bots
        for i in 0..<8 {
            let bot = EntityFactory.createPlayer(
                id: UUID(),
                position: SIMD3<Float>(Float(i * 2), 0, 0),
                team: i % 2 == 0 ? .blue : .red
            )
            anchor.addChild(bot)

            let ai = BotAI(entity: bot, difficulty: .medium)
            bots.append((bot, ai))
        }

        measure(metrics: [XCTClockMetric(), XCTCPUMetric()]) {
            for _ in 0..<100 {
                for (_, ai) in bots {
                    ai.update(deltaTime: 0.016, scene: scene)
                }
            }
        }
    }

    // MARK: - Network Message Performance

    func testNetworkMessageSerializationPerformance() {
        let messages = (0..<1000).map { _ in
            NetworkMessage(
                type: .playerPosition,
                payload: [
                    "x": Double.random(in: -50...50),
                    "y": Double.random(in: 0...10),
                    "z": Double.random(in: -50...50)
                ],
                senderID: UUID()
            )
        }

        let encoder = JSONEncoder()

        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
            for message in messages {
                _ = try? encoder.encode(message)
            }
        }
    }

    func testNetworkMessageDeserializationPerformance() {
        let message = NetworkMessage(
            type: .playerPosition,
            payload: ["x": 1.0, "y": 2.0, "z": 3.0],
            senderID: UUID()
        )

        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let data = try! encoder.encode(message)

        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
            for _ in 0..<1000 {
                _ = try? decoder.decode(NetworkMessage.self, from: data)
            }
        }
    }

    // MARK: - Collision Detection Performance

    func testCollisionDetectionPerformance() {
        let scene = Scene()
        let combatSystem = CombatSystem(scene: scene)

        let anchor = AnchorEntity()
        scene.addAnchor(anchor)

        // Create grid of players
        for x in 0..<10 {
            for z in 0..<10 {
                let player = EntityFactory.createPlayer(
                    id: UUID(),
                    position: SIMD3<Float>(Float(x * 2), 0, Float(z * 2)),
                    team: (x + z) % 2 == 0 ? .blue : .red
                )
                anchor.addChild(player)
            }
        }

        // Create many projectiles
        for i in 0..<200 {
            let projectile = EntityFactory.createProjectile(
                position: SIMD3<Float>(
                    Float.random(in: -10...10),
                    1.5,
                    Float.random(in: -10...10)
                ),
                direction: SIMD3<Float>(
                    Float.random(in: -1...1),
                    0,
                    Float.random(in: -1...1)
                ).normalized,
                speed: 15.0,
                damage: 25.0,
                ownerID: UUID(),
                team: i % 2 == 0 ? .blue : .red
            )
            anchor.addChild(projectile)
        }

        measure(metrics: [XCTClockMetric(), XCTCPUMetric()]) {
            for _ in 0..<50 {
                combatSystem.update(deltaTime: 0.016)
            }
        }
    }

    // MARK: - Memory Tests

    func testPlayerMemoryFootprint() {
        measure(metrics: [XCTMemoryMetric()]) {
            var players: [Player] = []
            for i in 0..<1000 {
                players.append(Player(
                    username: "Player\(i)",
                    skillRating: 1500,
                    team: i % 2 == 0 ? .blue : .red
                ))
            }
            // Keep players in scope
            _ = players.count
        }
    }

    func testEntityMemoryFootprint() {
        measure(metrics: [XCTMemoryMetric()]) {
            var entities: [Entity] = []
            for i in 0..<500 {
                entities.append(EntityFactory.createPlayer(
                    id: UUID(),
                    position: SIMD3<Float>(Float(i), 0, 0),
                    team: i % 2 == 0 ? .blue : .red
                ))
            }
            _ = entities.count
        }
    }

    // MARK: - Match Simulation Performance

    func testFullMatchSimulationPerformance() {
        let match = Match(
            matchType: .competitive,
            gameMode: .teamDeathmatch,
            arena: .cyberArena(),
            team1: Team(color: .blue, players: [
                Player(username: "Blue1", skillRating: 1500, team: .blue),
                Player(username: "Blue2", skillRating: 1500, team: .blue)
            ]),
            team2: Team(color: .red, players: [
                Player(username: "Red1", skillRating: 1500, team: .red),
                Player(username: "Red2", skillRating: 1500, team: .red)
            ])
        )

        let controller = TeamDeathmatchModeController(match: match, killLimit: 50)

        measure(metrics: [XCTClockMetric(), XCTCPUMetric()]) {
            // Simulate 60 seconds of gameplay at 60 FPS
            for _ in 0..<3600 {
                controller.update(deltaTime: 0.016)

                // Randomly generate eliminations
                if Int.random(in: 0..<100) < 2 {
                    controller.handlePlayerElimination(
                        victim: match.team2.players[0].id,
                        killer: match.team1.players[0].id
                    )
                }
            }
        }
    }

    // MARK: - JSON Encoding Performance

    func testMatchCodingPerformance() {
        let match = Match(
            matchType: .competitive,
            gameMode: .teamDeathmatch,
            arena: .cyberArena(),
            team1: Team(color: .blue, players: [
                Player(username: "Blue1", skillRating: 1500, team: .blue)
            ]),
            team2: Team(color: .red, players: [
                Player(username: "Red1", skillRating: 1500, team: .red)
            ])
        )

        let encoder = JSONEncoder()

        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
            for _ in 0..<100 {
                _ = try? encoder.encode(match)
            }
        }
    }

    // MARK: - Frame Budget Tests

    func testFrameBudgetCompliance() {
        let scene = Scene()
        let arena = Arena.cyberArena()

        let movementSystem = MovementSystem(scene: scene, arenaBounds: arena.dimensions)
        let combatSystem = CombatSystem(scene: scene)

        let anchor = AnchorEntity()
        scene.addAnchor(anchor)

        // Create realistic game scenario
        for i in 0..<10 {
            let player = EntityFactory.createPlayer(
                id: UUID(),
                position: SIMD3<Float>(Float(i * 2), 0, 0),
                team: i % 2 == 0 ? .blue : .red
            )
            anchor.addChild(player)
        }

        for i in 0..<50 {
            let projectile = EntityFactory.createProjectile(
                position: SIMD3<Float>(Float(i % 10), 1.5, Float(i / 10)),
                direction: SIMD3<Float>(0, 0, 1),
                speed: 15.0,
                damage: 25.0,
                ownerID: UUID(),
                team: .blue
            )
            anchor.addChild(projectile)
        }

        // Measure single frame update
        // Target: < 11ms for 90 FPS
        measure(metrics: [XCTClockMetric()]) {
            movementSystem.update(deltaTime: 0.011)
            combatSystem.update(deltaTime: 0.011)
        }
    }
}

// MARK: - Utilities

extension SIMD3 where Scalar == Float {
    var normalized: SIMD3<Float> {
        let length = simd_length(self)
        return length > 0 ? self / length : self
    }
}
