# Arena Esports - Implementation Plan
*Detailed Development Roadmap with Test-Driven Development*

---

## Document Overview

**Version:** 1.0
**Last Updated:** 2025-11-19
**Status:** Design Phase
**Development Approach:** Test-Driven Development (TDD)
**Related Documents:** ARCHITECTURE.md, TECHNICAL_SPEC.md, DESIGN.md

---

## Table of Contents

1. [Development Approach](#development-approach)
2. [Phase 1: Foundation (Weeks 1-4)](#phase-1-foundation-weeks-1-4)
3. [Phase 2: Core Gameplay (Weeks 5-10)](#phase-2-core-gameplay-weeks-5-10)
4. [Phase 3: Spatial Features (Weeks 11-16)](#phase-3-spatial-features-weeks-11-16)
5. [Phase 4: Multiplayer (Weeks 17-22)](#phase-4-multiplayer-weeks-17-22)
6. [Phase 5: UI/UX Polish (Weeks 23-26)](#phase-5-uiux-polish-weeks-23-26)
7. [Phase 6: Performance & Optimization (Weeks 27-30)](#phase-6-performance--optimization-weeks-27-30)
8. [Phase 7: Beta & Launch (Weeks 31-36)](#phase-7-beta--launch-weeks-31-36)
9. [Success Metrics](#success-metrics)
10. [Risk Mitigation](#risk-mitigation)

---

## 1. Development Approach

### Test-Driven Development (TDD) Strategy

We will follow strict TDD principles throughout development:

```
Red → Green → Refactor Cycle:
1. Write failing test
2. Write minimum code to pass
3. Refactor for quality
4. Repeat
```

### Testing Pyramid

```
               ┌─────────────┐
              /               \
             /   E2E Tests     \    10% - Full workflows
            /      (Slow)       \
           /───────────────────────\
          /                         \
         /   Integration Tests       \  30% - System interactions
        /        (Medium)             \
       /─────────────────────────────────\
      /                                   \
     /        Unit Tests                   \ 60% - Individual components
    /          (Fast)                       \
   /───────────────────────────────────────────\
```

### Test Coverage Goals

```yaml
Overall Coverage: 80%

By Component:
  Core Game Logic: 90%
  Physics Systems: 85%
  Network Layer: 80%
  UI Components: 70%
  Rendering: 60%

Critical Paths: 100%
  - Combat system
  - Player movement
  - Network synchronization
  - Match flow
```

### Development Principles

1. **Test First:** Write tests before implementation
2. **Small Iterations:** Small, testable increments
3. **Continuous Integration:** Automated testing on every commit
4. **Performance Testing:** Regular performance benchmarks
5. **Code Review:** All code reviewed before merge
6. **Documentation:** Update docs with code changes

---

## 2. Phase 1: Foundation (Weeks 1-4)

### Objective
Establish project structure, core architecture, and development infrastructure.

---

### Week 1: Project Setup

#### Day 1-2: Xcode Project Creation

**Tasks:**
- [ ] Create new visionOS app project in Xcode 16+
- [ ] Configure project settings (deployment target, capabilities)
- [ ] Set up folder structure per ARCHITECTURE.md
- [ ] Configure Swift Package Manager dependencies
- [ ] Set up Git repository and branching strategy

**Tests to Write:**
```swift
// Basic project structure tests
func testProjectStructureExists() {
    XCTAssertTrue(FileManager.default.fileExists(atPath: "ArenaEsports/App"))
    XCTAssertTrue(FileManager.default.fileExists(atPath: "ArenaEsports/Game"))
    // ... test all directories exist
}
```

**Deliverables:**
- Working Xcode project
- Project structure document
- Initial Git commit

---

#### Day 3-4: Core Architecture Setup

**Tasks:**
- [ ] Implement Entity-Component-System base protocols
- [ ] Create EntityManager singleton
- [ ] Set up Game Loop infrastructure
- [ ] Implement basic State Machine

**Tests to Write:**
```swift
// EntityManagerTests.swift
class EntityManagerTests: XCTestCase {
    func testEntityCreation() {
        let entity = EntityManager.shared.createEntity()
        XCTAssertNotNil(entity)
        XCTAssertNotNil(entity.id)
    }

    func testComponentAddition() {
        let entity = EntityManager.shared.createEntity()
        let transform = TransformComponent(entityID: entity.id, position: .zero)
        entity.components.append(transform)

        XCTAssertEqual(entity.components.count, 1)
    }

    func testEntityQuery() {
        // Create entities with different components
        let entity1 = EntityManager.shared.createEntity()
        entity1.components.append(TransformComponent(entityID: entity1.id))

        let entity2 = EntityManager.shared.createEntity()
        entity2.components.append(TransformComponent(entityID: entity2.id))
        entity2.components.append(PhysicsComponent(entityID: entity2.id))

        // Query entities with TransformComponent
        let results = EntityManager.shared.query(with: TransformComponent.self)
        XCTAssertEqual(results.count, 2)

        // Query entities with both Transform and Physics
        let resultsWithPhysics = EntityManager.shared.query(
            with: [TransformComponent.self, PhysicsComponent.self]
        )
        XCTAssertEqual(resultsWithPhysics.count, 1)
    }
}

// GameLoopTests.swift
class GameLoopTests: XCTestCase {
    func testGameLoopInitialization() {
        let gameLoop = GameLoop()
        XCTAssertNotNil(gameLoop)
        XCTAssertFalse(gameLoop.isRunning)
    }

    func testGameLoopStartStop() async {
        let gameLoop = GameLoop()
        await gameLoop.start()
        XCTAssertTrue(gameLoop.isRunning)

        await gameLoop.stop()
        XCTAssertFalse(gameLoop.isRunning)
    }

    func testSystemUpdateOrder() async {
        let gameLoop = GameLoop()
        var updateOrder: [String] = []

        let mockSystem1 = MockSystem(priority: 100, onUpdate: {
            updateOrder.append("system1")
        })
        let mockSystem2 = MockSystem(priority: 200, onUpdate: {
            updateOrder.append("system2")
        })

        gameLoop.addSystem(mockSystem1)
        gameLoop.addSystem(mockSystem2)

        await gameLoop.updateOnce()

        XCTAssertEqual(updateOrder, ["system2", "system1"]) // Higher priority first
    }
}

// GameStateMachineTests.swift
class GameStateMachineTests: XCTestCase {
    func testInitialState() {
        let stateMachine = GameStateMachine()
        XCTAssertEqual(stateMachine.currentState, .mainMenu)
    }

    func testValidTransition() async throws {
        let stateMachine = GameStateMachine()
        try await stateMachine.transition(to: .training)
        XCTAssertEqual(stateMachine.currentState, .training)
    }

    func testInvalidTransition() async {
        let stateMachine = GameStateMachine()
        await XCTAssertThrowsError(
            try await stateMachine.transition(to: .inMatch(matchID: UUID()))
        )
    }
}
```

**Deliverables:**
- Functional ECS system
- Working game loop
- State machine implementation
- 20+ passing unit tests

---

#### Day 5: CI/CD Setup

**Tasks:**
- [ ] Configure GitHub Actions for CI
- [ ] Set up automated testing pipeline
- [ ] Configure code coverage reporting
- [ ] Set up build automation

**GitHub Actions Workflow:**
```yaml
name: CI

on: [push, pull_request]

jobs:
  test:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v3

      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode_16.0.app

      - name: Build
        run: |
          xcodebuild build \
            -scheme ArenaEsports \
            -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
            -configuration Debug

      - name: Run Tests
        run: |
          xcodebuild test \
            -scheme ArenaEsports \
            -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
            -configuration Debug \
            -enableCodeCoverage YES

      - name: Code Coverage
        run: |
          xcrun xccov view \
            --report \
            --json \
            DerivedData/Logs/Test/*.xcresult \
            > coverage.json

      - name: Upload Coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage.json
          fail_ci_if_error: true

      - name: Check Coverage Threshold
        run: |
          COVERAGE=$(jq '.lineCoverage' coverage.json)
          if (( $(echo "$COVERAGE < 0.8" | bc -l) )); then
            echo "Coverage $COVERAGE is below 80% threshold"
            exit 1
          fi
```

**Deliverables:**
- Working CI/CD pipeline
- Automated test execution
- Code coverage tracking

---

### Week 2: Data Models & Persistence

#### Day 1-3: Core Data Models

**Tasks:**
- [ ] Implement Player model
- [ ] Implement Team model
- [ ] Implement Match model
- [ ] Implement Arena model
- [ ] Implement Component models (Transform, Health, etc.)

**Tests to Write:**
```swift
// PlayerModelTests.swift
class PlayerModelTests: XCTestCase {
    func testPlayerInitialization() {
        let player = Player(id: UUID(), username: "TestPlayer")
        XCTAssertNotNil(player.id)
        XCTAssertEqual(player.username, "TestPlayer")
        XCTAssertEqual(player.skillRating, 0)
    }

    func testPlayerStatistics() {
        var player = Player(id: UUID(), username: "TestPlayer")
        player.statistics.matchesPlayed = 10
        player.statistics.wins = 6
        player.statistics.losses = 4

        let winRate = player.statistics.winRate
        XCTAssertEqual(winRate, 0.6, accuracy: 0.01)
    }

    func testPlayerCodable() throws {
        let player = Player(id: UUID(), username: "TestPlayer")

        let encoded = try JSONEncoder().encode(player)
        let decoded = try JSONDecoder().decode(Player.self, from: encoded)

        XCTAssertEqual(player.id, decoded.id)
        XCTAssertEqual(player.username, decoded.username)
    }
}

// MatchModelTests.swift
class MatchModelTests: XCTestCase {
    func testMatchCreation() {
        let match = Match(
            id: UUID(),
            teams: [UUID(), UUID()],
            arena: Arena(id: UUID(), name: "Test Arena"),
            mode: .elimination
        )

        XCTAssertEqual(match.teams.count, 2)
        XCTAssertEqual(match.status, .waiting)
    }

    func testMatchStateTransitions() async {
        var match = Match(/* ... */)

        match.status = .inProgress
        XCTAssertEqual(match.status, .inProgress)

        match.status = .completed
        XCTAssertEqual(match.status, .completed)
    }
}

// ComponentTests.swift
class ComponentTests: XCTestCase {
    func testTransformComponent() {
        let entityID = UUID()
        let transform = TransformComponent(
            entityID: entityID,
            position: SIMD3(1, 2, 3),
            rotation: simd_quatf(angle: 0, axis: SIMD3(0, 1, 0))
        )

        XCTAssertEqual(transform.entityID, entityID)
        XCTAssertEqual(transform.position, SIMD3(1, 2, 3))
    }

    func testHealthComponent() {
        let entityID = UUID()
        var health = HealthComponent(
            entityID: entityID,
            current: 100,
            maximum: 100
        )

        XCTAssertTrue(health.isAlive)
        XCTAssertEqual(health.healthPercentage, 1.0)

        health.current = 50
        XCTAssertEqual(health.healthPercentage, 0.5)

        health.current = 0
        XCTAssertFalse(health.isAlive)
    }
}
```

**Deliverables:**
- All core data models implemented
- 30+ passing model tests
- Serialization/deserialization working

---

#### Day 4-5: SwiftData Integration

**Tasks:**
- [ ] Set up SwiftData model context
- [ ] Implement PlayerProgress persistence
- [ ] Create SaveSystem actor
- [ ] Implement load/save functionality

**Tests to Write:**
```swift
// SaveSystemTests.swift
class SaveSystemTests: XCTestCase {
    var saveSystem: SaveSystem!
    var modelContext: ModelContext!

    override func setUp() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: PlayerProgress.self,
            configurations: config
        )
        modelContext = ModelContext(container)
        saveSystem = SaveSystem(modelContext: modelContext)
    }

    func testSavePlayerProgress() async throws {
        let player = Player(id: UUID(), username: "TestPlayer")
        player.statistics.matchesPlayed = 10

        try await saveSystem.saveProgress(player)

        let loaded = try await saveSystem.loadProgress(playerID: player.id)
        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.id, player.id)
        XCTAssertEqual(loaded?.statistics.matchesPlayed, 10)
    }

    func testUpdateProgress() async throws {
        let player = Player(id: UUID(), username: "TestPlayer")
        try await saveSystem.saveProgress(player)

        var updated = try await saveSystem.loadProgress(playerID: player.id)!
        updated.statistics.matchesPlayed = 20
        try await saveSystem.saveProgress(updated)

        let reloaded = try await saveSystem.loadProgress(playerID: player.id)
        XCTAssertEqual(reloaded?.statistics.matchesPlayed, 20)
    }
}
```

**Deliverables:**
- Working save/load system
- Data persistence tests passing
- iCloud sync configured

---

### Week 3-4: Physics & Collision System

#### Tasks:
- [ ] Implement PhysicsSystem
- [ ] Create SpatialGrid for spatial partitioning
- [ ] Implement collision detection
- [ ] Set up collision resolution
- [ ] Add physics materials

**Tests to Write:**
```swift
// PhysicsSystemTests.swift
class PhysicsSystemTests: XCTestCase {
    var physicsSystem: PhysicsSystem!
    var entities: [any Entity] = []

    override func setUp() {
        physicsSystem = PhysicsSystem()
        entities = []
    }

    func testGravityApplication() async {
        let entity = TestEntity()
        entity.components.append(PhysicsComponent(
            entityID: entity.id,
            velocity: .zero,
            acceleration: .zero,
            mass: 1.0,
            friction: 0.0,
            hasGravity: true
        ))
        entity.components.append(TransformComponent(
            entityID: entity.id,
            position: SIMD3(0, 10, 0)
        ))

        let deltaTime: TimeInterval = 1.0
        await physicsSystem.update(deltaTime: deltaTime, entities: [entity])

        let physics = entity.components.first(where: { $0 is PhysicsComponent }) as! PhysicsComponent
        XCTAssertLessThan(physics.velocity.y, 0) // Falling
    }

    func testVelocityIntegration() async {
        let entity = TestEntity()
        entity.components.append(PhysicsComponent(
            entityID: entity.id,
            velocity: SIMD3(5, 0, 0),
            acceleration: .zero,
            mass: 1.0,
            friction: 0.0,
            hasGravity: false
        ))
        entity.components.append(TransformComponent(
            entityID: entity.id,
            position: .zero
        ))

        let deltaTime: TimeInterval = 1.0
        await physicsSystem.update(deltaTime: deltaTime, entities: [entity])

        let transform = entity.components.first(where: { $0 is TransformComponent }) as! TransformComponent
        XCTAssertEqual(transform.position.x, 5.0, accuracy: 0.01)
    }

    func testFriction() async {
        let entity = TestEntity()
        entity.components.append(PhysicsComponent(
            entityID: entity.id,
            velocity: SIMD3(10, 0, 0),
            acceleration: .zero,
            mass: 1.0,
            friction: 0.5, // 50% friction
            hasGravity: false
        ))

        await physicsSystem.update(deltaTime: 1.0, entities: [entity])

        let physics = entity.components.first(where: { $0 is PhysicsComponent }) as! PhysicsComponent
        XCTAssertLessThan(physics.velocity.x, 10.0) // Slowed by friction
    }
}

// CollisionSystemTests.swift
class CollisionSystemTests: XCTestCase {
    func testSpatialGridInsertion() {
        let grid = SpatialGrid(cellSize: 2.0)
        let entityID = UUID()

        grid.insert(entity: entityID, at: SIMD3(1, 1, 1))

        let nearby = grid.query(near: SIMD3(1, 1, 1), radius: 1.0)
        XCTAssertTrue(nearby.contains(entityID))
    }

    func testCollisionDetection() async {
        let collisionSystem = CollisionSystem()

        // Create two overlapping entities
        let entity1 = TestEntity()
        entity1.components.append(TransformComponent(
            entityID: entity1.id,
            position: SIMD3(0, 0, 0)
        ))
        entity1.components.append(CollisionComponent(
            entityID: entity1.id,
            radius: 1.0
        ))

        let entity2 = TestEntity()
        entity2.components.append(TransformComponent(
            entityID: entity2.id,
            position: SIMD3(0.5, 0, 0) // Overlapping
        ))
        entity2.components.append(CollisionComponent(
            entityID: entity2.id,
            radius: 1.0
        ))

        await collisionSystem.update(deltaTime: 0.016, entities: [entity1, entity2])

        // Verify collision was detected
        XCTAssertTrue(collisionSystem.collisionsDetected.count > 0)
    }

    func testCollisionResolution() async {
        // Test that colliding objects separate
        let collisionSystem = CollisionSystem()

        let entity1 = createTestEntity(at: SIMD3(0, 0, 0))
        let entity2 = createTestEntity(at: SIMD3(0.1, 0, 0))

        await collisionSystem.update(deltaTime: 0.016, entities: [entity1, entity2])

        let transform1 = entity1.components.first(where: { $0 is TransformComponent }) as! TransformComponent
        let transform2 = entity2.components.first(where: { $0 is TransformComponent }) as! TransformComponent

        let distance = simd_distance(transform1.position, transform2.position)
        XCTAssertGreaterThan(distance, 0.1) // Should have separated
    }
}
```

**Performance Tests:**
```swift
class PhysicsPerformanceTests: XCTestCase {
    func testPhysicsSystemPerformance() {
        let physicsSystem = PhysicsSystem()
        let entities = (0..<1000).map { _ in createTestEntity() }

        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
            Task {
                await physicsSystem.update(deltaTime: 0.016, entities: entities)
            }
        }
    }

    func testSpatialGridPerformance() {
        let grid = SpatialGrid(cellSize: 5.0)

        measure {
            for i in 0..<10000 {
                let position = SIMD3<Float>(
                    Float.random(in: -100...100),
                    Float.random(in: -100...100),
                    Float.random(in: -100...100)
                )
                grid.insert(entity: UUID(), at: position)
            }
        }
    }
}
```

**Deliverables:**
- Functional physics system
- Spatial partitioning working
- Collision detection accurate
- 40+ physics tests passing
- Performance benchmarks met

---

## 3. Phase 2: Core Gameplay (Weeks 5-10)

### Week 5-6: Combat System

#### Tasks:
- [ ] Implement weapon system (rifles, blasters, etc.)
- [ ] Create hit detection (hitscan and projectiles)
- [ ] Implement damage calculation
- [ ] Add weapon recoil and spread
- [ ] Create weapon feedback (VFX, SFX)

**Tests to Write:**
```swift
// WeaponSystemTests.swift
class WeaponSystemTests: XCTestCase {
    func testWeaponFiring() async {
        let weapon = SpatialRifle()
        let lastFireTime: TimeInterval = 0

        let canFire = (CACurrentMediaTime() - lastFireTime) >= weapon.fireRate
        XCTAssertTrue(canFire)
    }

    func testWeaponAmmo() {
        var weapon = SpatialRifle()
        let initialAmmo = weapon.ammo.magazineSize

        // Fire weapon
        weapon.ammo.magazineSize -= 1

        XCTAssertEqual(weapon.ammo.magazineSize, initialAmmo - 1)
    }

    func testWeaponReload() async {
        var weapon = SpatialRifle()
        weapon.ammo.magazineSize = 0
        weapon.ammo.reserveAmmo = 30

        // Reload
        let reloadAmount = min(30, weapon.ammo.reserveAmmo)
        weapon.ammo.magazineSize = reloadAmount
        weapon.ammo.reserveAmmo -= reloadAmount

        XCTAssertEqual(weapon.ammo.magazineSize, 30)
        XCTAssertEqual(weapon.ammo.reserveAmmo, 0)
    }
}

// HitDetectionTests.swift
class HitDetectionTests: XCTestCase {
    var hitDetection: HitDetectionSystem!

    override func setUp() async throws {
        hitDetection = HitDetectionSystem()
    }

    func testBasicHitscan() async {
        let origin = SIMD3<Float>(0, 0, 0)
        let direction = SIMD3<Float>(0, 0, 1)
        let weapon = SpatialRifle()

        // Place target at distance
        let target = createTarget(at: SIMD3(0, 0, 10))
        physicsWorld.addEntity(target)

        let hit = await hitDetection.performHitscan(
            from: origin,
            direction: direction,
            maxDistance: 50,
            weapon: weapon
        )

        XCTAssertNotNil(hit)
        XCTAssertEqual(hit?.distance, 10, accuracy: 0.1)
    }

    func testHeadshotDetection() async {
        let origin = SIMD3<Float>(0, 1.6, 0) // Eye level
        let direction = SIMD3<Float>(0, 0, 1)

        let target = createTarget(at: SIMD3(0, 0, 10))
        target.headPosition = SIMD3(0, 1.8, 10)

        let hit = await hitDetection.performHitscan(
            from: origin,
            direction: direction,
            maxDistance: 50,
            weapon: SpatialRifle()
        )

        XCTAssertTrue(hit?.isHeadshot ?? false)
    }

    func testDamageCalculation() async {
        let weapon = SpatialRifle()

        // Test damage at various distances
        let testCases: [(distance: Float, expectedMultiplier: Float)] = [
            (5, 1.0),    // Close range - full damage
            (20, 1.0),   // Medium range - full damage
            (35, 0.8),   // Far range - reduced damage
            (55, 0.5)    // Very far - minimum damage
        ]

        for testCase in testCases {
            let damage = calculateDamage(weapon: weapon, distance: testCase.distance)
            let expectedDamage = weapon.damage.baseDamage * testCase.expectedMultiplier

            XCTAssertEqual(damage, expectedDamage, accuracy: 1.0)
        }
    }

    func testWeaponSpread() {
        let weapon = SpatialRifle()
        let baseDirection = SIMD3<Float>(0, 0, 1)

        // Fire multiple shots and check spread
        var directions: [SIMD3<Float>] = []
        for _ in 0..<100 {
            let direction = applySpread(baseDirection, weapon: weapon)
            directions.append(direction)
        }

        // Calculate average deviation
        let avgDeviation = directions.reduce(0.0) { sum, dir in
            sum + acos(simd_dot(normalize(dir), normalize(baseDirection)))
        } / Float(directions.count)

        // Should be within weapon spread
        XCTAssertLessThanOrEqual(avgDeviation, weapon.accuracy.baseSpread * .pi / 180.0)
    }
}

// DamageSystemTests.swift
class DamageSystemTests: XCTestCase {
    func testApplyDamage() async {
        let entity = createTestEntity()
        var health = HealthComponent(
            entityID: entity.id,
            current: 100,
            maximum: 100
        )
        entity.components.append(health)

        // Apply damage
        await applyDamage(25, to: entity.id)

        health = entity.components.first(where: { $0 is HealthComponent }) as! HealthComponent
        XCTAssertEqual(health.current, 75)
    }

    func testEntityDeath() async {
        let entity = createTestEntity()
        var health = HealthComponent(
            entityID: entity.id,
            current: 25,
            maximum: 100
        )
        entity.components.append(health)

        // Apply lethal damage
        await applyDamage(30, to: entity.id)

        health = entity.components.first(where: { $0 is HealthComponent }) as! HealthComponent
        XCTAssertFalse(health.isAlive)
        XCTAssertEqual(health.current, 0) // Shouldn't go negative
    }
}
```

**Integration Tests:**
```swift
class CombatIntegrationTests: XCTestCase {
    func testFullCombatSequence() async throws {
        // Setup: Two players facing each other
        let player1 = createPlayer(at: SIMD3(0, 0, 0))
        let player2 = createPlayer(at: SIMD3(0, 0, 10))

        // Player 1 fires at Player 2
        let weapon = SpatialRifle()
        let direction = normalize(player2.position - player1.position)

        let hit = await hitDetection.performHitscan(
            from: player1.position,
            direction: direction,
            maxDistance: 50,
            weapon: weapon
        )

        // Verify hit registered
        XCTAssertNotNil(hit)
        XCTAssertEqual(hit?.entity, player2.id)

        // Verify damage applied
        let health = player2.components.first(where: { $0 is HealthComponent }) as? HealthComponent
        XCTAssertLessThan(health?.current ?? 100, 100)

        // Verify visual effects spawned
        XCTAssertTrue(particleSystemActive(type: .muzzleFlash))
        XCTAssertTrue(particleSystemActive(type: .bulletImpact))

        // Verify audio played
        XCTAssertTrue(audioPlayed(sound: .weaponFire))
        XCTAssertTrue(audioPlayed(sound: .weaponHit))
    }

    func testMultiKillScenario() async throws {
        let attacker = createPlayer()
        let targets = (0..<3).map { i in
            createPlayer(at: SIMD3(Float(i) * 2, 0, 10))
        }

        // Eliminate all targets
        for target in targets {
            await eliminateTarget(attacker: attacker, target: target)
        }

        // Verify multi-kill tracked
        let stats = attacker.components.first(where: { $0 is StatisticsComponent }) as? StatisticsComponent
        XCTAssertEqual(stats?.kills, 3)
        XCTAssertTrue(stats?.achievements.contains(.tripleKill) ?? false)
    }
}
```

**Deliverables:**
- Complete weapon system
- Accurate hit detection
- Damage calculation working
- 50+ combat tests passing
- VFX/SFX integrated

---

### Week 7-8: Movement System

#### Tasks:
- [ ] Implement player movement (walk, sprint, crouch)
- [ ] Add jump mechanics
- [ ] Create spherical movement for 360° arenas
- [ ] Implement momentum and physics
- [ ] Add movement feedback

**Tests to Write:**
```swift
// MovementSystemTests.swift
class MovementSystemTests: XCTestCase {
    var movementSystem: MovementSystem!

    override func setUp() {
        movementSystem = MovementSystem()
    }

    func testBasicMovement() async {
        let entity = createPlayer()
        let input = InputComponent(
            entityID: entity.id,
            movementDirection: SIMD2(1, 0), // Move right
            aimDirection: .zero
        )
        entity.components.append(input)

        await movementSystem.update(deltaTime: 1.0, entities: [entity])

        let transform = entity.components.first(where: { $0 is TransformComponent }) as! TransformComponent
        XCTAssertGreaterThan(transform.position.x, 0) // Moved right
    }

    func testSprintSpeed() async {
        let entity = createPlayer()
        var input = InputComponent(entityID: entity.id)
        input.movementDirection = SIMD2(1, 0)
        input.isSprinting = true
        entity.components.append(input)

        let initialPosition = getPosition(entity)
        await movementSystem.update(deltaTime: 1.0, entities: [entity])
        let newPosition = getPosition(entity)

        let distanceMoved = simd_distance(initialPosition, newPosition)
        let config = MovementConfig()

        XCTAssertEqual(distanceMoved, config.sprintSpeed, accuracy: 0.1)
    }

    func testJumpMechanics() async {
        let entity = createPlayer()
        var input = InputComponent(entityID: entity.id)
        input.jumpPressed = true
        entity.components.append(input)

        await movementSystem.update(deltaTime: 0.016, entities: [entity])

        let physics = entity.components.first(where: { $0 is PhysicsComponent }) as! PhysicsComponent
        XCTAssertGreaterThan(physics.velocity.y, 0) // Moving upward
    }

    func testSphericalMovement() async {
        let entity = createPlayer()
        entity.components.append(TransformComponent(
            entityID: entity.id,
            position: SIMD3(15, 0, 0) // On sphere surface (radius 15)
        ))

        var input = InputComponent(entityID: entity.id)
        input.movementDirection = SIMD2(0, 1) // Move "forward"
        entity.components.append(input)

        await movementSystem.update(deltaTime: 1.0, entities: [entity])

        let transform = entity.components.first(where: { $0 is TransformComponent }) as! TransformComponent
        let distance = simd_length(transform.position)

        // Should stay on sphere surface
        XCTAssertEqual(distance, 15.0, accuracy: 0.1)
    }

    func testMovementAcceleration() async {
        let entity = createPlayer()
        var input = InputComponent(entityID: entity.id)
        input.movementDirection = SIMD2(1, 0)
        entity.components.append(input)

        // First frame
        await movementSystem.update(deltaTime: 0.016, entities: [entity])
        let velocity1 = getVelocity(entity).x

        // Second frame
        await movementSystem.update(deltaTime: 0.016, entities: [entity])
        let velocity2 = getVelocity(entity).x

        // Should accelerate
        XCTAssertGreaterThan(velocity2, velocity1)
    }
}
```

**Performance Tests:**
```swift
class MovementPerformanceTests: XCTestCase {
    func testMovementSystemPerformance() {
        let movementSystem = MovementSystem()
        let entities = (0..<100).map { _ in createPlayer() }

        measure(metrics: [XCTClockMetric()]) {
            Task {
                await movementSystem.update(deltaTime: 0.016, entities: entities)
            }
        }

        // Should process 100 entities in < 1ms
    }
}
```

**Deliverables:**
- Complete movement system
- Spherical movement working
- Movement tests passing (30+)
- Smooth, responsive controls

---

### Week 9-10: Ability System

#### Tasks:
- [ ] Implement ability framework
- [ ] Create Dash ability
- [ ] Create Shield ability
- [ ] Add cooldown management
- [ ] Implement visual effects

**Tests to Write:**
```swift
// AbilitySystemTests.swift
class AbilitySystemTests: XCTestCase {
    func testAbilityActivation() async throws {
        let entity = createPlayer()
        let dashAbility = DashAbility()

        try await dashAbility.activate(on: entity.id)

        // Verify dash velocity applied
        let physics = entity.components.first(where: { $0 is PhysicsComponent }) as! PhysicsComponent
        XCTAssertGreaterThan(simd_length(physics.velocity), 0)
    }

    func testAbilityCooldown() async throws {
        let entity = createPlayer()
        let dashAbility = DashAbility()

        // Use ability
        try await dashAbility.activate(on: entity.id)

        // Try to use again immediately - should fail
        await XCTAssertThrowsError(
            try await dashAbility.activate(on: entity.id)
        )

        // Wait for cooldown
        try await Task.sleep(nanoseconds: UInt64(dashAbility.cooldown * 1_000_000_000))

        // Should work now
        try await dashAbility.activate(on: entity.id)
    }

    func testShieldAbility() async throws {
        let entity = createPlayer()
        let shieldAbility = ShieldAbility()

        try await shieldAbility.activate(on: entity.id)

        // Verify shield component added
        XCTAssertNotNil(entity.components.first(where: { $0 is ShieldComponent }))

        // Take damage while shielded
        await applyDamage(50, to: entity.id)

        let shield = entity.components.first(where: { $0 is ShieldComponent }) as! ShieldComponent
        XCTAssertLessThan(shield.health, shieldAbility.shieldHealth)

        // Health should be reduced less due to shield
        let health = entity.components.first(where: { $0 is HealthComponent }) as! HealthComponent
        XCTAssertGreaterThan(health.current, 50) // Shield absorbed some damage
    }

    func testAbilityEnergyCost() async throws {
        let entity = createPlayer()
        var energy = EnergyComponent(entityID: entity.id, current: 100, maximum: 100)
        entity.components.append(energy)

        let dashAbility = DashAbility()
        try await dashAbility.activate(on: entity.id)

        energy = entity.components.first(where: { $0 is EnergyComponent }) as! EnergyComponent
        XCTAssertEqual(energy.current, 100 - dashAbility.energyCost)
    }
}

// AbilityIntegrationTests.swift
class AbilityIntegrationTests: XCTestCase {
    func testDashEscape() async throws {
        // Scenario: Player uses dash to escape combat
        let player = createPlayer(at: SIMD3(0, 0, 0))
        let enemy = createPlayer(at: SIMD3(2, 0, 0))

        let initialDistance = simd_distance(
            getPosition(player),
            getPosition(enemy)
        )

        // Use dash
        let dashAbility = DashAbility()
        try await dashAbility.activate(on: player.id)

        // Wait for dash duration
        try await Task.sleep(nanoseconds: UInt64(dashAbility.duration * 1_000_000_000))

        let finalDistance = simd_distance(
            getPosition(player),
            getPosition(enemy)
        )

        XCTAssertGreaterThan(finalDistance, initialDistance + dashAbility.dashDistance * 0.8)
    }
}
```

**Deliverables:**
- Ability system framework
- 2+ abilities implemented
- 20+ ability tests passing
- Visual effects integrated

---

## 4. Phase 3: Spatial Features (Weeks 11-16)

### Week 11-12: RealityKit Integration

#### Tasks:
- [ ] Set up RealityKit scene
- [ ] Create arena entities
- [ ] Implement player entity rendering
- [ ] Add lighting and materials
- [ ] Optimize rendering pipeline

**Tests to Write:**
```swift
// RealityKitTests.swift
class RealityKitTests: XCTestCase {
    func testArenaCreation() async {
        let arena = ArenaEntity()
        arena.generateSphericalArena(radius: 15.0)

        XCTAssertNotNil(arena.components[ModelComponent.self])
        XCTAssertNotNil(arena.components[CollisionComponent.self])
    }

    func testPlayerEntityRendering() {
        let player = PlayerEntity()

        XCTAssertNotNil(player.components[ModelComponent.self])
        XCTAssertNotNil(player.components[PhysicsBodyComponent.self])
    }

    func testLODSystem() async {
        let renderSystem = RenderSystem()
        let entity = PlayerEntity()
        entity.position = SIMD3(50, 0, 0) // Far away

        let context = MockSceneUpdateContext()
        renderSystem.update(context: context)

        // Verify LOD adjusted for distance
        XCTAssertTrue(entity.isSimplified)
    }
}

// RenderPerformanceTests.swift
class RenderPerformanceTests: XCTestCase {
    func testRenderingFrameRate() {
        let scene = createTestScene(entities: 100)

        measure(metrics: [XCTClockMetric()]) {
            scene.render()
        }

        // Should maintain 120 FPS (8.33ms per frame)
        // Each render should take < 5ms
    }

    func testMemoryUsage() {
        measure(metrics: [XCTMemoryMetric()]) {
            let scene = createTestScene(entities: 500)
            scene.render()
        }

        // Should stay under 500 MB for 500 entities
    }
}
```

**Deliverables:**
- RealityKit scene rendering
- Arena visualization
- Performance targets met (90+ FPS)
- 15+ rendering tests passing

---

### Week 13-14: Hand & Eye Tracking

#### Tasks:
- [ ] Integrate ARKit hand tracking
- [ ] Implement gesture recognition
- [ ] Add eye tracking for aiming
- [ ] Create calibration system
- [ ] Test tracking accuracy

**Tests to Write:**
```swift
// HandTrackingTests.swift
class HandTrackingTests: XCTestCase {
    var gestureRecognizer: HandGestureRecognizer!

    override func setUp() async throws {
        gestureRecognizer = HandGestureRecognizer()
    }

    func testPointGestureRecognition() async {
        let mockHandAnchor = createMockHandAnchor(gesture: .point)

        let gesture = await gestureRecognizer.recognizeGesture(from: mockHandAnchor)

        XCTAssertEqual(gesture, .point)
    }

    func testPinchGestureRecognition() async {
        let mockHandAnchor = createMockHandAnchor(gesture: .pinch)

        let gesture = await gestureRecognizer.recognizeGesture(from: mockHandAnchor)

        XCTAssertEqual(gesture, .pinch)
    }

    func testGestureConfidence() async {
        let mockHandAnchor = createMockHandAnchor(
            gesture: .point,
            confidence: 0.7
        )

        let gesture = await gestureRecognizer.recognizeGesture(from: mockHandAnchor)

        // Should not recognize with low confidence
        XCTAssertNil(gesture)
    }
}

// EyeTrackingTests.swift
class EyeTrackingTests: XCTestCase {
    func testGazeDirection() async {
        let eyeTracking = EyeTrackingSystem()

        let gazeDirection = await eyeTracking.getGazeDirection()

        XCTAssertNotNil(gazeDirection)
        XCTAssertEqual(simd_length(gazeDirection!), 1.0, accuracy: 0.01) // Normalized
    }

    func testTargetLocking() async {
        let eyeTracking = EyeTrackingSystem()
        let target = createTarget(at: SIMD3(0, 0, 10))

        // Look at target for dwell time
        for _ in 0..<Int(eyeTracking.targetLockTime * 60) { // 60 FPS
            await eyeTracking.update()
        }

        XCTAssertEqual(eyeTracking.currentTarget, target.id)
    }
}
```

**Integration Tests:**
```swift
class TrackingIntegrationTests: XCTestCase {
    func testHandTrackingToAiming() async throws {
        let handTracking = HandTrackingSystem()
        let combatSystem = CombatSystem()

        // Point hand at target
        let mockHandAnchor = createMockHandAnchor(
            gesture: .point,
            direction: SIMD3(0, 0, 1)
        )

        await handTracking.update(anchors: [mockHandAnchor])

        // Pinch to shoot
        let pinchAnchor = createMockHandAnchor(gesture: .pinch)
        await handTracking.update(anchors: [pinchAnchor])

        // Verify weapon fired
        XCTAssertTrue(combatSystem.weaponFired)
    }
}
```

**Deliverables:**
- Hand tracking working
- Gesture recognition accurate (>90%)
- Eye tracking integrated
- 25+ tracking tests passing

---

### Week 15-16: Spatial Audio

#### Tasks:
- [ ] Set up AVFoundation spatial audio
- [ ] Implement positional audio for weapons
- [ ] Add footstep audio system
- [ ] Create voice chat with spatial positioning
- [ ] Optimize audio performance

**Tests to Write:**
```swift
// AudioSystemTests.swift
class AudioSystemTests: XCTestCase {
    var audioSystem: AudioSystem!

    override func setUp() {
        audioSystem = AudioSystem()
    }

    func testSpatialAudioPositioning() {
        let source = SIMD3<Float>(10, 0, 0) // 10 meters to the right

        audioSystem.playSound(.weaponFire, at: source)

        // Verify audio positioned correctly
        let audioNode = audioSystem.sources.first?.value
        XCTAssertNotNil(audioNode)
        XCTAssertEqual(audioNode?.position.x, 10, accuracy: 0.1)
    }

    func testAudioAttenuation() {
        let nearSource = SIMD3<Float>(5, 0, 0)
        let farSource = SIMD3<Float>(50, 0, 0)

        audioSystem.playSound(.weaponFire, at: nearSource, volume: 1.0)
        let nearVolume = getCurrentVolume()

        audioSystem.playSound(.weaponFire, at: farSource, volume: 1.0)
        let farVolume = getCurrentVolume()

        // Far sound should be quieter
        XCTAssertLessThan(farVolume, nearVolume)
    }

    func testFootstepSystem() async {
        let player = createPlayer()
        var physics = PhysicsComponent(entityID: player.id)
        physics.velocity = SIMD3(5, 0, 0) // Moving
        player.components.append(physics)

        await audioSystem.update(deltaTime: 0.3, entities: [player])

        // Should have played footstep
        XCTAssertTrue(audioSystem.soundPlayed(type: .footstep))
    }
}

// AudioPerformanceTests.swift
class AudioPerformanceTests: XCTestCase {
    func testAudioSystemPerformance() {
        let audioSystem = AudioSystem()

        measure {
            // Play 100 simultaneous sounds
            for i in 0..<100 {
                let position = SIMD3<Float>(
                    Float(i % 10),
                    0,
                    Float(i / 10)
                )
                audioSystem.playSound(.weaponFire, at: position)
            }
        }

        // Should handle 100 sounds without performance degradation
    }
}
```

**Deliverables:**
- Spatial audio working
- Positional accuracy verified
- Voice chat integrated
- 15+ audio tests passing

---

## 5. Phase 4: Multiplayer (Weeks 17-22)

### Week 17-18: Network Infrastructure

#### Tasks:
- [ ] Set up WebRTC connection
- [ ] Implement network message protocol
- [ ] Create client-side prediction
- [ ] Add server reconciliation
- [ ] Set up matchmaking service

**Tests to Write:**
```swift
// NetworkTests.swift
class NetworkTests: XCTestCase {
    var networkManager: NetworkManager!

    override func setUp() async throws {
        networkManager = NetworkManager()
    }

    func testConnection() async throws {
        try await networkManager.connect(to: testServerURL)

        XCTAssertTrue(networkManager.isConnected)
    }

    func testMessageSerialization() throws {
        let message = NetworkMessage.playerAction(
            action: PlayerAction(
                timestamp: 0,
                movementDirection: SIMD2(1, 0),
                aimDirection: SIMD3(0, 0, 1),
                actions: [.shoot]
            ),
            sequenceNumber: 1
        )

        let encoded = try JSONEncoder().encode(message)
        let decoded = try JSONDecoder().decode(NetworkMessage.self, from: encoded)

        // Verify round-trip
        if case .playerAction(let action, let seq) = decoded {
            XCTAssertEqual(seq, 1)
            XCTAssertEqual(action.movementDirection.x, 1)
        } else {
            XCTFail("Failed to decode message")
        }
    }

    func testLatencyMeasurement() async throws {
        try await networkManager.connect(to: testServerURL)

        let latency = await networkManager.measureLatency()

        XCTAssertLessThan(latency, 0.050) // < 50ms
    }
}

// ClientPredictionTests.swift
class ClientPredictionTests: XCTestCase {
    func testPrediction() async {
        let predictionSystem = PredictionSystem()

        let input = PlayerInput(
            timestamp: 0,
            movementDirection: SIMD2(1, 0),
            aimDirection: .zero,
            actions: []
        )

        await predictionSystem.predictLocalAction(input)

        // Verify action applied locally
        let player = getLocalPlayer()
        XCTAssertGreaterThan(getPosition(player).x, 0)
    }

    func testReconciliation() async {
        let predictionSystem = PredictionSystem()

        // Apply local prediction
        let input = PlayerInput(/* ... */)
        await predictionSystem.predictLocalAction(input)

        // Receive server state (slightly different)
        let serverState = GameStateSnapshot(
            timestamp: 1.0,
            serverTick: 60,
            players: [PlayerSnapshot(/* ... */)]
        )

        await predictionSystem.reconcileWithServer(state: serverState)

        // Verify reconciled to server state
        let player = getLocalPlayer()
        XCTAssertEqual(getPosition(player), serverState.players[0].position, accuracy: 0.1)
    }
}
```

**Integration Tests:**
```swift
class MultiplayerIntegrationTests: XCTestCase {
    func testTwoPlayerConnection() async throws {
        let client1 = GameClient()
        let client2 = GameClient()

        try await client1.connect(to: testServerURL)
        try await client2.connect(to: testServerURL)

        // Verify both connected
        XCTAssertEqual(await server.playerCount, 2)

        // Verify players can see each other
        let client1Players = await client1.getVisiblePlayers()
        XCTAssertEqual(client1Players.count, 2) // Self + other player
    }

    func testNetworkSync() async throws {
        let client1 = GameClient()
        let client2 = GameClient()

        try await client1.connect(to: testServerURL)
        try await client2.connect(to: testServerURL)

        // Client 1 moves
        await client1.move(direction: SIMD2(1, 0))

        // Wait for sync
        try await Task.sleep(nanoseconds: 100_000_000) // 100ms

        // Client 2 should see movement
        let client2View = await client2.getPlayerPosition(client1.playerID)
        XCTAssertGreaterThan(client2View.x, 0)
    }
}
```

**Performance Tests:**
```swift
class NetworkPerformanceTests: XCTestCase {
    func testMessageThroughput() async throws {
        let networkManager = NetworkManager()
        try await networkManager.connect(to: testServerURL)

        measure {
            Task {
                for _ in 0..<60 { // 1 second at 60 Hz
                    try? await networkManager.sendAction(PlayerAction(/* ... */))
                }
            }
        }
    }

    func testBandwidthUsage() async throws {
        let networkManager = NetworkManager()
        try await networkManager.connect(to: testServerURL)

        let initialBytes = networkManager.bytesSent

        // Send data for 1 second
        for _ in 0..<60 {
            try? await networkManager.sendAction(PlayerAction(/* ... */))
            try await Task.sleep(nanoseconds: 16_666_666) // 60 Hz
        }

        let bytesPerSecond = networkManager.bytesSent - initialBytes

        // Should be under 15 KB/s per player
        XCTAssertLessThan(bytesPerSecond, 15_000)
    }
}
```

**Deliverables:**
- Network layer functional
- Client prediction working
- Latency < 50ms
- 40+ network tests passing

---

### Week 19-20: Matchmaking & Lobbies

#### Tasks:
- [ ] Implement matchmaking service
- [ ] Create lobby system
- [ ] Add party support
- [ ] Implement skill-based matching
- [ ] Test with multiple clients

**Tests to Write:**
```swift
// MatchmakingTests.swift
class MatchmakingTests: XCTestCase {
    var matchmaking: MatchmakingService!

    override func setUp() async throws {
        matchmaking = MatchmakingService()
    }

    func testBasicMatchmaking() async {
        // Add 10 players to queue
        let players = (0..<10).map { i in
            MatchmakingRequest(
                playerID: UUID(),
                skillRating: 1500 + i * 10,
                region: .northAmerica,
                partyMembers: [],
                requestTime: Date()
            )
        }

        for player in players {
            await matchmaking.joinQueue(player)
        }

        // Should create a match
        try await Task.sleep(nanoseconds: 1_000_000_000)

        XCTAssertEqual(await matchmaking.queue.count, 0) // All matched
    }

    func testSkillBasedMatching() async {
        let lowSkillPlayer = MatchmakingRequest(
            playerID: UUID(),
            skillRating: 1000,
            region: .northAmerica,
            partyMembers: [],
            requestTime: Date()
        )

        let highSkillPlayer = MatchmakingRequest(
            playerID: UUID(),
            skillRating: 2500,
            region: .northAmerica,
            partyMembers: [],
            requestTime: Date()
        )

        await matchmaking.joinQueue(lowSkillPlayer)
        await matchmaking.joinQueue(highSkillPlayer)

        try await Task.sleep(nanoseconds: 1_000_000_000)

        // Should NOT match due to skill gap
        XCTAssertEqual(await matchmaking.queue.count, 2)
    }

    func testPartyMatchmaking() async {
        let party = (0..<3).map { _ in UUID() }

        let partyLeader = MatchmakingRequest(
            playerID: party[0],
            skillRating: 1500,
            region: .northAmerica,
            partyMembers: Array(party.dropFirst()),
            requestTime: Date()
        )

        await matchmaking.joinQueue(partyLeader)

        // Add 7 more solo players
        for _ in 0..<7 {
            await matchmaking.joinQueue(MatchmakingRequest(
                playerID: UUID(),
                skillRating: 1500,
                region: .northAmerica,
                partyMembers: [],
                requestTime: Date()
            ))
        }

        try await Task.sleep(nanoseconds: 1_000_000_000)

        // Should create match with party on same team
        let match = await matchmaking.activeMatches.first
        XCTAssertNotNil(match)
    }
}
```

**Deliverables:**
- Matchmaking functional
- Parties working
- Queue times acceptable (<60s)
- 20+ matchmaking tests passing

---

### Week 21-22: Match Flow & Synchronization

#### Tasks:
- [ ] Implement match initialization
- [ ] Create round system
- [ ] Add score tracking
- [ ] Implement match end conditions
- [ ] Test full match flow

**Tests to Write:**
```swift
// MatchFlowTests.swift
class MatchFlowTests: XCTestCase {
    func testMatchInitialization() async {
        let match = Match(/* ... */)

        await match.initialize()

        XCTAssertEqual(match.status, .waiting)
        XCTAssertEqual(match.currentRound, 0)
        XCTAssertEqual(match.score.teamA, 0)
        XCTAssertEqual(match.score.teamB, 0)
    }

    func testMatchStart() async {
        let match = Match(/* ... */)

        await match.start()

        XCTAssertEqual(match.status, .inProgress)
        XCTAssertEqual(match.currentRound, 1)
    }

    func testRoundCompletion() async {
        let match = Match(/* ... */)
        await match.start()

        // Eliminate all players on Team B
        for player in match.teamB {
            await eliminatePlayer(player)
        }

        await match.checkRoundEnd()

        XCTAssertEqual(match.score.teamA, 1)
        XCTAssertEqual(match.currentRound, 2)
    }

    func testMatchEnd() async {
        let match = Match(/* ... */)
        await match.start()

        // Team A wins 4 rounds
        match.score.teamA = 4
        await match.checkMatchEnd()

        XCTAssertEqual(match.status, .completed)
        XCTAssertEqual(match.winner, .teamA)
    }
}

// SynchronizationTests.swift
class SynchronizationTests: XCTestCase {
    func testStateSynchronization() async throws {
        let server = MockGameServer()
        let client = GameClient()

        try await client.connect(to: server.url)

        // Server updates state
        await server.updateGameState()

        // Wait for sync
        try await Task.sleep(nanoseconds: 100_000_000)

        // Client should have latest state
        let clientState = await client.gameState
        let serverState = await server.gameState

        XCTAssertEqual(clientState.serverTick, serverState.serverTick)
    }

    func testLagCompensation() async {
        let server = MockGameServer()
        let shooter = createPlayer()
        let target = createTarget(at: SIMD3(0, 0, 10))

        // Shooter fires with 100ms latency
        let shootTime = CACurrentMediaTime()
        let shooterLatency: TimeInterval = 0.1

        let hit = await server.validateHit(
            shooterID: shooter.id,
            targetID: target.id,
            timestamp: shootTime,
            shooterLatency: shooterLatency
        )

        // Should rewind state and validate hit
        XCTAssertTrue(hit)
    }
}
```

**Integration Tests:**
```swift
class FullMatchIntegrationTests: XCTestCase {
    func testCompleteMatch() async throws {
        // Create 10 players
        let players = (0..<10).map { _ in GameClient() }

        // Connect all players
        for player in players {
            try await player.connect(to: testServerURL)
        }

        // Start match
        let match = await server.createMatch(players: players)
        await match.start()

        // Play match
        while match.status == .inProgress {
            // Simulate gameplay
            for player in players {
                await player.update()
            }

            await match.update(deltaTime: 0.016)
            try await Task.sleep(nanoseconds: 16_000_000) // 60 FPS
        }

        // Verify match completed
        XCTAssertEqual(match.status, .completed)
        XCTAssertNotNil(match.winner)

        // Verify all players received results
        for player in players {
            XCTAssertNotNil(await player.matchResults)
        }
    }
}
```

**Deliverables:**
- Match flow working end-to-end
- Round system functional
- Synchronization accurate
- 30+ match flow tests passing

---

## 6. Phase 5: UI/UX Polish (Weeks 23-26)

### Week 23-24: Main Menus & HUD

#### Tasks:
- [ ] Implement main menu system
- [ ] Create in-game HUD
- [ ] Add pause menu
- [ ] Implement settings menu
- [ ] Polish transitions and animations

**Tests to Write:**
```swift
// UITests.swift
class UITests: XCTestCase {
    func testMainMenuNavigation() {
        let mainMenu = MainMenuView()

        mainMenu.selectOption(.playCompetitive)

        XCTAssertEqual(mainMenu.currentView, .matchmaking)
    }

    func testHUDDisplay() {
        let player = createPlayer()
        let hud = HUDView(player: player)

        // Verify HUD shows correct info
        XCTAssertEqual(hud.health, player.health)
        XCTAssertEqual(hud.ammo, player.weapon.ammo)
    }

    func testSettingsMenu() {
        let settings = SettingsView()

        settings.setSensitivity(0.8)

        XCTAssertEqual(UserDefaults.standard.float(forKey: "aimSensitivity"), 0.8)
    }
}

// UIAccessibilityTests.swift
class UIAccessibilityTests: XCTestCase {
    func testColorBlindMode() {
        let settings = AccessibilitySettings()
        settings.colorBlindMode = .deuteranopia

        let teamColor = settings.getTeamColor(.blue)

        // Should return adjusted color
        XCTAssertNotEqual(teamColor, .blue)
    }

    func testTextScaling() {
        let settings = AccessibilitySettings()
        settings.textScaleFactor = 1.5

        let fontSize = settings.getScaledFontSize(base: 18)

        XCTAssertEqual(fontSize, 27, accuracy: 0.1)
    }

    func testHighContrastMode() {
        let settings = AccessibilitySettings()
        settings.highContrastMode = true

        let backgroundColor = settings.getBackgroundColor()

        // Should have high contrast
        XCTAssertGreaterThan(backgroundColor.contrastRatio(with: .white), 7.0)
    }
}
```

**UI Tests (XCUITest):**
```swift
// UIIntegrationTests.swift
class UIIntegrationTests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        app = XCUIApplication()
        app.launch()
    }

    func testMainMenuFlow() {
        // Verify main menu appears
        XCTAssertTrue(app.buttons["Play Competitive"].exists)

        // Tap play button
        app.buttons["Play Competitive"].tap()

        // Verify matchmaking screen appears
        XCTAssertTrue(app.staticTexts["Searching for match..."].exists)
    }

    func testSettingsNavigation() {
        app.buttons["Settings"].tap()

        XCTAssertTrue(app.navigationBars["Settings"].exists)

        // Test sensitivity slider
        let slider = app.sliders["Aim Sensitivity"]
        slider.adjust(toNormalizedSliderPosition: 0.8)

        // Verify setting saved
        app.buttons["Back"].tap()
        app.buttons["Settings"].tap()

        XCTAssertEqual(slider.normalizedSliderPosition, 0.8, accuracy: 0.1)
    }
}
```

**Deliverables:**
- Complete menu system
- Functional HUD
- Settings working
- 25+ UI tests passing

---

### Week 25-26: Post-Match & Social Features

#### Tasks:
- [ ] Implement post-match screen
- [ ] Add statistics display
- [ ] Create replay system
- [ ] Implement friends list
- [ ] Add team management

**Tests to Write:**
```swift
// PostMatchTests.swift
class PostMatchTests: XCTestCase {
    func testStatisticsCalculation() {
        let matchResults = MatchResults(/* ... */)
        matchResults.kills = 12
        matchResults.deaths = 5
        matchResults.assists = 8

        let kda = matchResults.calculateKDA()

        XCTAssertEqual(kda, (12 + 8) / 5, accuracy: 0.1)
    }

    func testMVPSelection() {
        let players = (0..<10).map { i in
            createPlayer(kills: i * 2, deaths: 5)
        }

        let mvp = selectMVP(from: players)

        XCTAssertEqual(mvp.kills, 18) // Player with most kills
    }

    func testRankUpdate() async {
        var player = createPlayer(skillRating: 2100)

        await updateRankAfterMatch(player: &player, result: .victory)

        XCTAssertGreaterThan(player.skillRating, 2100)
    }
}

// SocialTests.swift
class SocialTests: XCTestCase {
    func testFriendRequest() async {
        let player1 = createPlayer()
        let player2 = createPlayer()

        await player1.sendFriendRequest(to: player2.id)

        XCTAssertTrue(player2.friendRequests.contains(player1.id))
    }

    func testTeamCreation() async {
        let captain = createPlayer()
        let members = (0..<4).map { _ in createPlayer() }

        let team = await createTeam(
            name: "Test Team",
            captain: captain,
            members: members
        )

        XCTAssertEqual(team.members.count, 5)
        XCTAssertEqual(team.captain, captain.id)
    }
}
```

**Deliverables:**
- Post-match screen complete
- Statistics accurate
- Social features working
- 20+ post-match tests passing

---

## 7. Phase 6: Performance & Optimization (Weeks 27-30)

### Week 27-28: Performance Profiling

#### Tasks:
- [ ] Profile with Instruments
- [ ] Identify bottlenecks
- [ ] Optimize rendering pipeline
- [ ] Reduce memory usage
- [ ] Improve network efficiency

**Performance Tests:**
```swift
// PerformanceTests.swift
class PerformanceTests: XCTestCase {
    func testFrameRateUnderLoad() {
        let scene = createComplexScene(entities: 500)
        let performanceMonitor = PerformanceMonitor()

        measure(metrics: [XCTClockMetric()]) {
            for _ in 0..<120 { // 2 seconds at 60 FPS
                scene.update(deltaTime: 0.016)
                performanceMonitor.recordFrame(deltaTime: 0.016)
            }
        }

        XCTAssertGreaterThanOrEqual(performanceMonitor.currentFPS, 90)
    }

    func testMemoryUnderLoad() {
        measure(metrics: [XCTMemoryMetric()]) {
            let scene = createComplexScene(entities: 1000)

            for _ in 0..<60 {
                scene.update(deltaTime: 0.016)
            }
        }

        // Should stay under 3.5 GB
        XCTAssertLessThan(getCurrentMemoryUsage(), 3.5 * 1024 * 1024 * 1024)
    }

    func testCPUUsage() {
        let scene = createComplexScene(entities: 200)

        measure(metrics: [XCTCPUMetric()]) {
            for _ in 0..<60 {
                scene.update(deltaTime: 0.016)
            }
        }

        // Should use < 50% CPU on average
    }

    func testNetworkLatency() async {
        let networkManager = NetworkManager()
        try? await networkManager.connect(to: testServerURL)

        var latencies: [TimeInterval] = []

        for _ in 0..<100 {
            let latency = await networkManager.measureLatency()
            latencies.append(latency)
        }

        let avgLatency = latencies.reduce(0, +) / Double(latencies.count)

        XCTAssertLessThan(avgLatency, 0.050) // < 50ms average
    }
}
```

**Optimization Checklist:**
- [ ] Reduce draw calls to < 1000
- [ ] Implement object pooling
- [ ] Optimize texture sizes
- [ ] Reduce physics calculations
- [ ] Minimize network messages
- [ ] Cache frequently accessed data

**Deliverables:**
- Performance profiling complete
- Bottlenecks identified and fixed
- Frame rate consistently 90+ FPS
- Memory usage under budget

---

### Week 29-30: Final Optimization

#### Tasks:
- [ ] Implement dynamic quality scaling
- [ ] Add LOD systems
- [ ] Optimize asset loading
- [ ] Reduce battery usage
- [ ] Final performance testing

**Tests to Write:**
```swift
// OptimizationTests.swift
class OptimizationTests: XCTestCase {
    func testDynamicQualityScaling() {
        let optimizer = PerformanceOptimizer.shared

        // Simulate low FPS
        for _ in 0..<10 {
            optimizer.recordFPS(55)
        }

        // Should reduce quality
        XCTAssertEqual(optimizer.currentQualityLevel, .competitive)

        // Simulate FPS recovery
        for _ in 0..<10 {
            optimizer.recordFPS(110)
        }

        // Should increase quality
        XCTAssertEqual(optimizer.currentQualityLevel, .professional)
    }

    func testLODSystem() {
        let entity = PlayerEntity()
        entity.position = SIMD3(50, 0, 0) // Far away

        let lod = calculateLOD(for: entity)

        XCTAssertEqual(lod, .veryLow)
    }

    func testAssetCaching() {
        let cache = AssetCache.shared

        measure {
            for _ in 0..<1000 {
                let asset = cache.load(key: "test_asset") {
                    loadExpensiveAsset()
                }
            }
        }

        // Should be fast due to caching
    }
}

// BatteryUsageTests.swift
class BatteryUsageTests: XCTestCase {
    func testPowerConsumption() {
        // Measure power usage over 5 minutes
        let startLevel = getBatteryLevel()
        let startTime = Date()

        // Run game
        runGameLoop(duration: 300) // 5 minutes

        let endLevel = getBatteryLevel()
        let endTime = Date()

        let percentPerHour = (startLevel - endLevel) / (endTime.timeIntervalSince(startTime) / 3600)

        // Should drain < 60% per hour
        XCTAssertLessThan(percentPerHour, 60)
    }
}
```

**Deliverables:**
- All optimization techniques implemented
- Performance targets consistently met
- Battery usage acceptable
- Final performance report

---

## 8. Phase 7: Beta & Launch (Weeks 31-36)

### Week 31-32: Beta Testing

#### Tasks:
- [ ] Recruit beta testers
- [ ] Deploy TestFlight build
- [ ] Collect feedback
- [ ] Fix critical bugs
- [ ] Iterate on balance

**Testing Checklist:**
- [ ] 100+ beta testers recruited
- [ ] Feedback collected via surveys
- [ ] Critical bugs (P0) fixed
- [ ] Performance validated on real devices
- [ ] Balance adjustments made

**Metrics to Track:**
```yaml
Technical Metrics:
  - Crash rate: < 1%
  - Average FPS: > 90
  - Network latency: < 50ms
  - Load times: < 5s

Gameplay Metrics:
  - Match completion rate: > 90%
  - Average match duration: 15-20 minutes
  - Player retention (7-day): > 40%
  - Matchmaking time: < 60s

Balance Metrics:
  - Weapon usage distribution
  - Map win rates (should be 48-52%)
  - Ability pick rates
  - Rank distribution
```

---

### Week 33-34: Polish & Bug Fixing

#### Tasks:
- [ ] Fix all P0 and P1 bugs
- [ ] Polish animations
- [ ] Improve feedback
- [ ] Optimize loading times
- [ ] Final QA pass

**Bug Fixing Priority:**
```
P0 (Critical - Must Fix):
  - Crashes
  - Game-breaking bugs
  - Network disconnections
  - Performance issues

P1 (High - Should Fix):
  - Gameplay bugs
  - UI/UX issues
  - Balance problems
  - Minor crashes

P2 (Medium - Nice to Fix):
  - Visual glitches
  - Audio issues
  - Minor UI problems

P3 (Low - Can Defer):
  - Cosmetic issues
  - Enhancement requests
```

**Final Test Suite:**
```swift
// FinalQATests.swift
class FinalQATests: XCTestCase {
    func testCompleteUserJourney() async throws {
        // Test complete flow from launch to match completion
        let app = XCUIApplication()
        app.launch()

        // Onboarding
        XCTAssertTrue(app.buttons["Start Tutorial"].exists)
        app.buttons["Start Tutorial"].tap()

        // Complete tutorial
        completeTutorial(app: app)

        // Start competitive match
        app.buttons["Play Competitive"].tap()

        // Wait for matchmaking
        waitForMatchmaking(app: app)

        // Play match
        playMatch(app: app)

        // Verify results screen
        XCTAssertTrue(app.staticTexts["Match Results"].exists)
    }

    func testAccessibilityCompliance() {
        // Verify all accessibility features work
        let settings = AccessibilitySettings()

        // Test each mode
        for mode in ColorBlindMode.allCases {
            settings.colorBlindMode = mode
            XCTAssertTrue(isUIReadable())
        }

        // Test text scaling
        for scale in [0.8, 1.0, 1.5, 2.0] {
            settings.textScaleFactor = scale
            XCTAssertTrue(isUIReadable())
        }
    }
}
```

---

### Week 35-36: Launch Preparation

#### Tasks:
- [ ] Create App Store assets
- [ ] Write App Store description
- [ ] Prepare marketing materials
- [ ] Set up analytics
- [ ] Submit for review

**App Store Checklist:**
- [ ] App Store screenshots (all required sizes)
- [ ] App preview video
- [ ] App description optimized
- [ ] Keywords researched
- [ ] Privacy policy published
- [ ] Support URL active
- [ ] Pricing configured
- [ ] Release notes written

**Launch Day Checklist:**
- [ ] Server capacity verified
- [ ] Monitoring systems active
- [ ] Support team ready
- [ ] Social media scheduled
- [ ] Press kit distributed

---

## 9. Success Metrics

### Technical KPIs

```yaml
Performance:
  - Frame Rate: 90+ FPS (95th percentile)
  - Load Time: < 5 seconds
  - Crash Rate: < 1%
  - Network Latency: < 50ms (average)

Quality:
  - Test Coverage: > 80%
  - Code Review: 100% of PRs
  - Bug Resolution Time: < 48 hours (P0)

Development:
  - Velocity: 40-50 story points/sprint
  - CI/CD: < 10 minutes build time
  - Deployment: Daily to TestFlight
```

### Gameplay KPIs

```yaml
Engagement:
  - Day 1 Retention: > 60%
  - Day 7 Retention: > 40%
  - Day 30 Retention: > 20%
  - Average Session: 30-45 minutes
  - Sessions per Day: 2-3

Competitive:
  - Matchmaking Time: < 60 seconds
  - Match Completion: > 90%
  - Rank Distribution: Bell curve
  - Fair Matches: 48-52% win rate

Monetization:
  - Conversion: > 5% to paid
  - ARPU: $15-20
  - Retention (paid): > 60% (30-day)
```

---

## 10. Risk Mitigation

### Technical Risks

**Risk:** Performance doesn't meet 90 FPS target
- **Mitigation:** Weekly performance testing, dynamic quality scaling
- **Contingency:** Reduce visual fidelity, optimize aggressively

**Risk:** Network latency too high
- **Mitigation:** Regional servers, client prediction
- **Contingency:** Increase buffer, optimize netcode

**Risk:** Hand tracking accuracy insufficient
- **Mitigation:** Early testing, controller fallback
- **Contingency:** Emphasize controller support

### Schedule Risks

**Risk:** Features take longer than estimated
- **Mitigation:** Agile sprints, regular retrospectives
- **Contingency:** Cut P2/P3 features, extend timeline

**Risk:** Critical bugs found late
- **Mitigation:** Continuous testing, early beta
- **Contingency:** Delay launch if necessary

### Market Risks

**Risk:** Limited Vision Pro adoption
- **Mitigation:** Cross-promotion, demo events
- **Contingency:** Focus on quality over quantity

**Risk:** Competition launches first
- **Mitigation:** Unique features, better quality
- **Contingency:** Differentiate positioning

---

## Conclusion

This implementation plan provides a comprehensive roadmap for building Arena Esports with:

- **36-week development timeline**
- **Test-Driven Development** throughout
- **80% test coverage** target
- **Continuous integration** and deployment
- **Performance optimization** focus
- **Risk mitigation** strategies

Key success factors:
1. Strict adherence to TDD
2. Weekly performance testing
3. Early and continuous beta testing
4. Aggressive optimization
5. Strong focus on competitive integrity

**Next Steps:**
1. Review and approve implementation plan
2. Set up development environment
3. Begin Phase 1: Foundation
4. Start writing tests and building!

---

**Document Status:** Complete - Ready for Implementation
**Start Date:** TBD
**Target Launch:** Week 36
