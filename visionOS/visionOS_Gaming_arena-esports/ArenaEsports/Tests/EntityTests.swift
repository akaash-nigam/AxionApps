import XCTest
@testable import ArenaEsports

final class EntityTests: XCTestCase {
    var entity: GameEntity!

    override func setUp() {
        super.setUp()
        entity = GameEntity()
    }

    override func tearDown() {
        entity = nil
        super.tearDown()
    }

    // MARK: - Entity Creation Tests

    func testEntityInitialization() {
        XCTAssertNotNil(entity)
        XCTAssertNotNil(entity.id)
        XCTAssertTrue(entity.isActive)
        XCTAssertEqual(entity.components.count, 0)
    }

    func testEntityWithCustomID() {
        let customID = UUID()
        let customEntity = GameEntity(id: customID)

        XCTAssertEqual(customEntity.id, customID)
    }

    func testEntityInactive() {
        let inactiveEntity = GameEntity(isActive: false)

        XCTAssertFalse(inactiveEntity.isActive)
    }

    // MARK: - Component Management Tests

    func testAddComponent() {
        let transform = TransformComponent(entityID: entity.id, position: SIMD3(1, 2, 3))
        entity.addComponent(transform)

        XCTAssertEqual(entity.components.count, 1)
    }

    func testGetComponent() {
        let transform = TransformComponent(entityID: entity.id, position: SIMD3(1, 2, 3))
        entity.addComponent(transform)

        let retrieved = entity.getComponent(TransformComponent.self)

        XCTAssertNotNil(retrieved)
        XCTAssertEqual(retrieved?.position, SIMD3(1, 2, 3))
    }

    func testGetNonExistentComponent() {
        let retrieved = entity.getComponent(TransformComponent.self)

        XCTAssertNil(retrieved)
    }

    func testHasComponent() {
        let transform = TransformComponent(entityID: entity.id)
        entity.addComponent(transform)

        XCTAssertTrue(entity.hasComponent(TransformComponent.self))
        XCTAssertFalse(entity.hasComponent(HealthComponent.self))
    }

    func testRemoveComponent() {
        let transform = TransformComponent(entityID: entity.id)
        entity.addComponent(transform)

        XCTAssertEqual(entity.components.count, 1)

        entity.removeComponent(TransformComponent.self)

        XCTAssertEqual(entity.components.count, 0)
        XCTAssertNil(entity.getComponent(TransformComponent.self))
    }

    func testMultipleComponents() {
        let transform = TransformComponent(entityID: entity.id)
        let health = HealthComponent(entityID: entity.id, current: 100, maximum: 100)

        entity.addComponent(transform)
        entity.addComponent(health)

        XCTAssertEqual(entity.components.count, 2)
        XCTAssertNotNil(entity.getComponent(TransformComponent.self))
        XCTAssertNotNil(entity.getComponent(HealthComponent.self))
    }

    // MARK: - Entity State Tests

    func testEntityActivation() {
        entity.isActive = false
        XCTAssertFalse(entity.isActive)

        entity.isActive = true
        XCTAssertTrue(entity.isActive)
    }
}
