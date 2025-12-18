import XCTest
@testable import ArenaEsports

final class EntityManagerTests: XCTestCase {
    var entityManager: EntityManager!

    override func setUp() async throws {
        try await super.setUp()
        entityManager = EntityManager.shared
        await entityManager.clear()
    }

    override func tearDown() async throws {
        await entityManager.clear()
        try await super.tearDown()
    }

    // MARK: - Entity Creation Tests

    func testCreateEntity() async {
        let entity = await entityManager.createEntity()

        XCTAssertNotNil(entity)
        XCTAssertNotNil(entity.id)
        XCTAssertTrue(entity.isActive)
    }

    func testCreateInactiveEntity() async {
        let entity = await entityManager.createEntity(isActive: false)

        XCTAssertFalse(entity.isActive)
    }

    func testEntityCount() async {
        _ = await entityManager.createEntity()
        _ = await entityManager.createEntity()

        let count = await entityManager.entityCount
        XCTAssertEqual(count, 2)
    }

    // MARK: - Entity Retrieval Tests

    func testGetEntity() async {
        let entity = await entityManager.createEntity()

        let retrieved = await entityManager.getEntity(entity.id)

        XCTAssertNotNil(retrieved)
        XCTAssertEqual(retrieved?.id, entity.id)
    }

    func testGetNonExistentEntity() async {
        let nonExistentID = UUID()

        let retrieved = await entityManager.getEntity(nonExistentID)

        XCTAssertNil(retrieved)
    }

    func testGetAllEntities() async {
        _ = await entityManager.createEntity()
        _ = await entityManager.createEntity()
        _ = await entityManager.createEntity()

        let allEntities = await entityManager.allEntities

        XCTAssertEqual(allEntities.count, 3)
    }

    func testGetActiveEntities() async {
        _ = await entityManager.createEntity(isActive: true)
        _ = await entityManager.createEntity(isActive: false)
        _ = await entityManager.createEntity(isActive: true)

        let activeEntities = await entityManager.activeEntities

        XCTAssertEqual(activeEntities.count, 2)
    }

    // MARK: - Entity Removal Tests

    func testRemoveEntity() async {
        let entity = await entityManager.createEntity()
        let entityID = entity.id

        await entityManager.removeEntity(entityID)

        let retrieved = await entityManager.getEntity(entityID)
        XCTAssertNil(retrieved)

        let count = await entityManager.entityCount
        XCTAssertEqual(count, 0)
    }

    func testRemoveNonExistentEntity() async {
        let nonExistentID = UUID()

        // Should not crash
        await entityManager.removeEntity(nonExistentID)

        let count = await entityManager.entityCount
        XCTAssertEqual(count, 0)
    }

    func testClearAllEntities() async {
        _ = await entityManager.createEntity()
        _ = await entityManager.createEntity()
        _ = await entityManager.createEntity()

        await entityManager.clear()

        let count = await entityManager.entityCount
        XCTAssertEqual(count, 0)
    }

    // MARK: - Component Query Tests

    func testEntitiesWithComponent() async {
        let entity1 = await entityManager.createEntity()
        entity1.addComponent(TransformComponent(entityID: entity1.id))

        let entity2 = await entityManager.createEntity()
        entity2.addComponent(TransformComponent(entityID: entity2.id))
        entity2.addComponent(HealthComponent(entityID: entity2.id, current: 100, maximum: 100))

        let entity3 = await entityManager.createEntity()
        entity3.addComponent(HealthComponent(entityID: entity3.id, current: 100, maximum: 100))

        // Query entities with Transform component
        let withTransform = await entityManager.entitiesWithComponent(TransformComponent.self)
        XCTAssertEqual(withTransform.count, 2)

        // Query entities with Health component
        let withHealth = await entityManager.entitiesWithComponent(HealthComponent.self)
        XCTAssertEqual(withHealth.count, 2)
    }

    func testEntitiesWithMultipleComponents() async {
        let entity1 = await entityManager.createEntity()
        entity1.addComponent(TransformComponent(entityID: entity1.id))
        entity1.addComponent(HealthComponent(entityID: entity1.id, current: 100, maximum: 100))

        let entity2 = await entityManager.createEntity()
        entity2.addComponent(TransformComponent(entityID: entity2.id))

        // Query entities with both Transform and Health
        let withBoth = await entityManager.entitiesWithComponents([
            TransformComponent.self,
            HealthComponent.self
        ])

        XCTAssertEqual(withBoth.count, 1)
        XCTAssertEqual(withBoth.first?.id, entity1.id)
    }

    func testQueryInactiveEntities() async {
        let entity = await entityManager.createEntity(isActive: false)
        entity.addComponent(TransformComponent(entityID: entity.id))

        // Query should only return active entities
        let results = await entityManager.entitiesWithComponent(TransformComponent.self)

        XCTAssertEqual(results.count, 0)
    }

    // MARK: - Statistics Tests

    func testActiveEntityCount() async {
        _ = await entityManager.createEntity(isActive: true)
        _ = await entityManager.createEntity(isActive: false)
        _ = await entityManager.createEntity(isActive: true)

        let activeCount = await entityManager.activeEntityCount
        XCTAssertEqual(activeCount, 2)

        let totalCount = await entityManager.entityCount
        XCTAssertEqual(totalCount, 3)
    }
}
