import XCTest
@testable import HideAndSeekEvolved

final class HidingMechanicsSystemTests: XCTestCase {
    var sut: HidingMechanicsSystem!
    var mockEntity: Entity!

    override func setUp() async throws {
        sut = HidingMechanicsSystem()
        mockEntity = Entity()
    }

    override func tearDown() async throws {
        sut = nil
        mockEntity = nil
    }

    // MARK: - Camouflage Tests

    func testActivateCamouflage_success() async throws {
        // Given
        let playerId = UUID()

        // When
        try await sut.activateCamouflage(for: playerId, entity: mockEntity, targetOpacity: 0.1)

        // Then
        let activeAbility = await sut.getActiveAbility(for: playerId)
        XCTAssertNotNil(activeAbility)
        if case .camouflage(let opacity) = activeAbility {
            XCTAssertEqual(opacity, 0.1, accuracy: 0.001)
        } else {
            XCTFail("Expected camouflage ability")
        }
    }

    func testActivateCamouflage_whileOnCooldown_throwsError() async {
        // Given
        let playerId = UUID()
        try? await sut.activateCamouflage(for: playerId, entity: mockEntity)

        // When/Then
        do {
            try await sut.activateCamouflage(for: playerId, entity: mockEntity)
            XCTFail("Expected error to be thrown")
        } catch HidingError.abilityOnCooldown {
            // Success
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testDeactivateCamouflage_removesAbility() async throws {
        // Given
        let playerId = UUID()
        try await sut.activateCamouflage(for: playerId, entity: mockEntity)

        // When
        await sut.deactivateCamouflage(for: playerId, entity: mockEntity)

        // Then
        let activeAbility = await sut.getActiveAbility(for: playerId)
        XCTAssertNil(activeAbility)
    }

    // MARK: - Size Manipulation Tests

    func testManipulateSize_validScale_success() async throws {
        // Given
        let playerId = UUID()
        let targetScale: Float = 0.5

        // When
        try await sut.manipulateSize(for: playerId, entity: mockEntity, targetScale: targetScale)

        // Then
        let activeAbility = await sut.getActiveAbility(for: playerId)
        XCTAssertNotNil(activeAbility)
        if case .sizeManipulation(let scale) = activeAbility {
            XCTAssertEqual(scale, targetScale, accuracy: 0.001)
        } else {
            XCTFail("Expected size manipulation ability")
        }
    }

    func testManipulateSize_scaleTooSmall_throwsError() async {
        // Given
        let playerId = UUID()
        let targetScale: Float = 0.2  // Too small (minimum is 0.3)

        // When/Then
        do {
            try await sut.manipulateSize(for: playerId, entity: mockEntity, targetScale: targetScale)
            XCTFail("Expected error to be thrown")
        } catch HidingError.invalidScale {
            // Success
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testManipulateSize_scaleTooLarge_throwsError() async {
        // Given
        let playerId = UUID()
        let targetScale: Float = 2.5  // Too large (maximum is 2.0)

        // When/Then
        do {
            try await sut.manipulateSize(for: playerId, entity: mockEntity, targetScale: targetScale)
            XCTFail("Expected error to be thrown")
        } catch HidingError.invalidScale {
            // Success
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testManipulateSize_minimumScale_success() async throws {
        // Given
        let playerId = UUID()
        let targetScale: Float = 0.3  // Minimum allowed

        // When
        try await sut.manipulateSize(for: playerId, entity: mockEntity, targetScale: targetScale)

        // Then
        let activeAbility = await sut.getActiveAbility(for: playerId)
        XCTAssertNotNil(activeAbility)
    }

    func testManipulateSize_maximumScale_success() async throws {
        // Given
        let playerId = UUID()
        let targetScale: Float = 2.0  // Maximum allowed

        // When
        try await sut.manipulateSize(for: playerId, entity: mockEntity, targetScale: targetScale)

        // Then
        let activeAbility = await sut.getActiveAbility(for: playerId)
        XCTAssertNotNil(activeAbility)
    }

    // MARK: - Sound Masking Tests

    func testActivateSoundMasking_success() async throws {
        // Given
        let playerId = UUID()
        let effectiveness: Float = 0.8

        // When
        try await sut.activateSoundMasking(for: playerId, effectiveness: effectiveness)

        // Then
        let activeAbility = await sut.getActiveAbility(for: playerId)
        XCTAssertNotNil(activeAbility)
        if case .soundMasking(let eff) = activeAbility {
            XCTAssertEqual(eff, effectiveness, accuracy: 0.001)
        } else {
            XCTFail("Expected sound masking ability")
        }
    }

    func testDeactivateSoundMasking_removesAbility() async throws {
        // Given
        let playerId = UUID()
        try await sut.activateSoundMasking(for: playerId)

        // When
        await sut.deactivateSoundMasking(for: playerId)

        // Then
        let activeAbility = await sut.getActiveAbility(for: playerId)
        XCTAssertNil(activeAbility)
    }

    // MARK: - Ability Status Tests

    func testIsAbilityActive_whenActive_returnsTrue() async throws {
        // Given
        let playerId = UUID()
        try await sut.activateCamouflage(for: playerId, entity: mockEntity)

        // When
        let isActive = await sut.isAbilityActive(for: playerId)

        // Then
        XCTAssertTrue(isActive)
    }

    func testIsAbilityActive_whenInactive_returnsFalse() async {
        // Given
        let playerId = UUID()

        // When
        let isActive = await sut.isAbilityActive(for: playerId)

        // Then
        XCTAssertFalse(isActive)
    }

    func testGetCooldownRemaining_whenActive_returnsPositiveValue() async throws {
        // Given
        let playerId = UUID()
        try await sut.activateCamouflage(for: playerId, entity: mockEntity)

        // When
        let cooldown = await sut.getCooldownRemaining(for: playerId)

        // Then
        XCTAssertGreaterThan(cooldown, 0)
    }

    func testGetCooldownRemaining_whenInactive_returnsZero() async {
        // Given
        let playerId = UUID()

        // When
        let cooldown = await sut.getCooldownRemaining(for: playerId)

        // Then
        XCTAssertEqual(cooldown, 0, accuracy: 0.001)
    }
}
