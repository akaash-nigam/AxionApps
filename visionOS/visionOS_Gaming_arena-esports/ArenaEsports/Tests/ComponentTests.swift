import XCTest
import simd
@testable import ArenaEsports

final class ComponentTests: XCTestCase {
    var entityID: UUID!

    override func setUp() {
        super.setUp()
        entityID = UUID()
    }

    // MARK: - TransformComponent Tests

    func testTransformComponentInitialization() {
        let transform = TransformComponent(entityID: entityID)

        XCTAssertEqual(transform.entityID, entityID)
        XCTAssertEqual(transform.position, .zero)
        XCTAssertEqual(transform.scale, SIMD3(repeating: 1))
    }

    func testTransformComponentWithValues() {
        let position = SIMD3<Float>(1, 2, 3)
        let rotation = simd_quatf(angle: .pi / 2, axis: SIMD3(0, 1, 0))
        let scale = SIMD3<Float>(2, 2, 2)

        let transform = TransformComponent(
            entityID: entityID,
            position: position,
            rotation: rotation,
            scale: scale
        )

        XCTAssertEqual(transform.position, position)
        XCTAssertEqual(transform.scale, scale)
    }

    func testTransformDirectionVectors() {
        let transform = TransformComponent(
            entityID: entityID,
            rotation: simd_quatf(angle: 0, axis: SIMD3(0, 1, 0))
        )

        // Default forward should be negative Z
        let forward = transform.forward
        XCTAssertEqual(forward.x, 0, accuracy: 0.001)
        XCTAssertEqual(forward.y, 0, accuracy: 0.001)
        XCTAssertEqual(forward.z, -1, accuracy: 0.001)

        // Default right should be positive X
        let right = transform.right
        XCTAssertEqual(right.x, 1, accuracy: 0.001)
        XCTAssertEqual(right.y, 0, accuracy: 0.001)
        XCTAssertEqual(right.z, 0, accuracy: 0.001)

        // Default up should be positive Y
        let up = transform.up
        XCTAssertEqual(up.x, 0, accuracy: 0.001)
        XCTAssertEqual(up.y, 1, accuracy: 0.001)
        XCTAssertEqual(up.z, 0, accuracy: 0.001)
    }

    func testTransformRotation() {
        // Rotate 90 degrees around Y axis
        let rotation = simd_quatf(angle: .pi / 2, axis: SIMD3(0, 1, 0))
        let transform = TransformComponent(
            entityID: entityID,
            rotation: rotation
        )

        let forward = transform.forward

        // After 90° rotation around Y, forward should point in +X direction
        XCTAssertEqual(forward.x, 1, accuracy: 0.001)
        XCTAssertEqual(forward.y, 0, accuracy: 0.001)
        XCTAssertEqual(forward.z, 0, accuracy: 0.001)
    }

    // MARK: - HealthComponent Tests

    func testHealthComponentInitialization() {
        let health = HealthComponent(
            entityID: entityID,
            current: 100,
            maximum: 100
        )

        XCTAssertEqual(health.entityID, entityID)
        XCTAssertEqual(health.current, 100)
        XCTAssertEqual(health.maximum, 100)
        XCTAssertTrue(health.isAlive)
        XCTAssertEqual(health.healthPercentage, 1.0)
    }

    func testHealthComponentTakeDamage() {
        var health = HealthComponent(
            entityID: entityID,
            current: 100,
            maximum: 100
        )

        health.takeDamage(25, at: 1.0)

        XCTAssertEqual(health.current, 75)
        XCTAssertTrue(health.isAlive)
        XCTAssertEqual(health.healthPercentage, 0.75, accuracy: 0.01)
        XCTAssertEqual(health.lastDamageTime, 1.0)
    }

    func testHealthComponentLethalDamage() {
        var health = HealthComponent(
            entityID: entityID,
            current: 50,
            maximum: 100
        )

        health.takeDamage(60, at: 2.0)

        XCTAssertEqual(health.current, 0)
        XCTAssertFalse(health.isAlive)
        XCTAssertEqual(health.healthPercentage, 0)
    }

    func testHealthComponentOverkillDamage() {
        var health = HealthComponent(
            entityID: entityID,
            current: 10,
            maximum: 100
        )

        health.takeDamage(100, at: 2.0)

        // Health should not go negative
        XCTAssertEqual(health.current, 0)
        XCTAssertFalse(health.isAlive)
    }

    func testHealthComponentHealing() {
        var health = HealthComponent(
            entityID: entityID,
            current: 50,
            maximum: 100
        )

        health.heal(30)

        XCTAssertEqual(health.current, 80)
        XCTAssertTrue(health.isAlive)
        XCTAssertEqual(health.healthPercentage, 0.8, accuracy: 0.01)
    }

    func testHealthComponentOverhealing() {
        var health = HealthComponent(
            entityID: entityID,
            current: 90,
            maximum: 100
        )

        health.heal(50)

        // Health should not exceed maximum
        XCTAssertEqual(health.current, 100)
        XCTAssertEqual(health.healthPercentage, 1.0)
    }

    func testHealthComponentRegeneration() {
        var health = HealthComponent(
            entityID: entityID,
            current: 50,
            maximum: 100,
            regenerationRate: 5.0 // 5 HP per second
        )

        // Simulate 2 seconds of regeneration
        health.heal(health.regenerationRate * 2)

        XCTAssertEqual(health.current, 60)
    }

    func testHealthComponentPercentageCalculation() {
        let health = HealthComponent(
            entityID: entityID,
            current: 33,
            maximum: 100
        )

        XCTAssertEqual(health.healthPercentage, 0.33, accuracy: 0.01)
    }
}
