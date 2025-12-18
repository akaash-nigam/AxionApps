import XCTest
import simd
@testable import ArenaEsports

final class PhysicsSystemTests: XCTestCase {
    var physicsSystem: PhysicsSystem!
    var entityManager: EntityManager!

    override func setUp() async throws {
        try await super.setUp()
        physicsSystem = PhysicsSystem()
        entityManager = EntityManager.shared
        await entityManager.clear()
    }

    override func tearDown() async throws {
        await entityManager.clear()
        try await super.tearDown()
    }

    // MARK: - Gravity Tests

    func testGravityApplication() async {
        let entity = await entityManager.createEntity()
        entity.addComponent(TransformComponent(entityID: entity.id, position: SIMD3(0, 10, 0)))
        entity.addComponent(PhysicsComponent(
            entityID: entity.id,
            velocity: .zero,
            acceleration: .zero,
            hasGravity: true
        ))

        await physicsSystem.update(deltaTime: 1.0, entities: [entity])

        let physics = entity.getComponent(PhysicsComponent.self)!
        XCTAssertLessThan(physics.velocity.y, 0, "Entity should fall due to gravity")
    }

    func testNoGravity() async {
        let entity = await entityManager.createEntity()
        entity.addComponent(TransformComponent(entityID: entity.id))
        entity.addComponent(PhysicsComponent(
            entityID: entity.id,
            velocity: .zero,
            hasGravity: false
        ))

        await physicsSystem.update(deltaTime: 1.0, entities: [entity])

        let physics = entity.getComponent(PhysicsComponent.self)!
        XCTAssertEqual(physics.velocity.y, 0, accuracy: 0.001)
    }

    // MARK: - Velocity Tests

    func testVelocityIntegration() async {
        let entity = await entityManager.createEntity()
        entity.addComponent(TransformComponent(entityID: entity.id, position: .zero))
        entity.addComponent(PhysicsComponent(
            entityID: entity.id,
            velocity: SIMD3(5, 0, 0),
            hasGravity: false
        ))

        await physicsSystem.update(deltaTime: 1.0, entities: [entity])

        let transform = entity.getComponent(TransformComponent.self)!
        XCTAssertEqual(transform.position.x, 5.0, accuracy: 0.1)
    }

    func testFriction() async {
        let entity = await entityManager.createEntity()
        entity.addComponent(TransformComponent(entityID: entity.id))
        entity.addComponent(PhysicsComponent(
            entityID: entity.id,
            velocity: SIMD3(10, 0, 0),
            friction: 0.5,
            hasGravity: false
        ))

        await physicsSystem.update(deltaTime: 1.0, entities: [entity])

        let physics = entity.getComponent(PhysicsComponent.self)!
        XCTAssertLessThan(physics.velocity.x, 10.0, "Velocity should decrease due to friction")
    }

    // MARK: - Collision Tests

    func testCollisionDetection() async {
        // Create two overlapping entities
        let entity1 = await entityManager.createEntity()
        entity1.addComponent(TransformComponent(entityID: entity1.id, position: SIMD3(0, 0, 0)))
        entity1.addComponent(CollisionComponent(entityID: entity1.id, radius: 1.0))

        let entity2 = await entityManager.createEntity()
        entity2.addComponent(TransformComponent(entityID: entity2.id, position: SIMD3(0.5, 0, 0)))
        entity2.addComponent(CollisionComponent(entityID: entity2.id, radius: 1.0))

        await physicsSystem.update(deltaTime: 0.016, entities: [entity1, entity2])

        let transform1 = entity1.getComponent(TransformComponent.self)!
        let transform2 = entity2.getComponent(TransformComponent.self)!
        let distance = simd_distance(transform1.position, transform2.position)

        XCTAssertGreaterThan(distance, 0.5, "Entities should separate after collision")
    }

    func testNoCollisionWhenFarApart() async {
        let entity1 = await entityManager.createEntity()
        entity1.addComponent(TransformComponent(entityID: entity1.id, position: SIMD3(0, 0, 0)))
        entity1.addComponent(CollisionComponent(entityID: entity1.id, radius: 1.0))

        let entity2 = await entityManager.createEntity()
        entity2.addComponent(TransformComponent(entityID: entity2.id, position: SIMD3(10, 0, 0)))
        entity2.addComponent(CollisionComponent(entityID: entity2.id, radius: 1.0))

        let initialDistance = 10.0

        await physicsSystem.update(deltaTime: 0.016, entities: [entity1, entity2])

        let transform1 = entity1.getComponent(TransformComponent.self)!
        let transform2 = entity2.getComponent(TransformComponent.self)!
        let distance = simd_distance(transform1.position, transform2.position)

        XCTAssertEqual(distance, Float(initialDistance), accuracy: 0.1)
    }

    // MARK: - Integration Tests

    func testPhysicsWithMultipleEntities() async {
        let entities = await createMultiplePhysicsEntities(count: 10)

        await physicsSystem.update(deltaTime: 0.016, entities: entities)

        // Verify all entities updated
        for entity in entities {
            XCTAssertNotNil(entity.getComponent(PhysicsComponent.self))
            XCTAssertNotNil(entity.getComponent(TransformComponent.self))
        }
    }

    // MARK: - Helper Methods

    private func createMultiplePhysicsEntities(count: Int) async -> [GameEntity] {
        var entities: [GameEntity] = []

        for i in 0..<count {
            let entity = await entityManager.createEntity()
            entity.addComponent(TransformComponent(
                entityID: entity.id,
                position: SIMD3(Float(i) * 2, 0, 0)
            ))
            entity.addComponent(PhysicsComponent(
                entityID: entity.id,
                velocity: SIMD3(Float.random(in: -1...1), 0, 0),
                hasGravity: false
            ))
            entities.append(entity)
        }

        return entities
    }
}
