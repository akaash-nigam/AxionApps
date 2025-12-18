import XCTest
@testable import HideAndSeekEvolved

final class PlayerTests: XCTestCase {

    // MARK: - Initialization Tests

    func testPlayerInitialization_withDefaults() {
        // Given & When
        let player = Player(name: "Test Player")

        // Then
        XCTAssertEqual(player.name, "Test Player")
        XCTAssertEqual(player.role, .hider)
        XCTAssertEqual(player.position, .zero)
        XCTAssertTrue(player.activeAbilities.isEmpty)
        XCTAssertEqual(player.stats.totalGamesPlayed, 0)
    }

    func testPlayerInitialization_withCustomValues() {
        // Given
        let customPosition = SIMD3<Float>(1.0, 2.0, 3.0)
        let customRole = PlayerRole.seeker
        let customAbilities: [Ability] = [.camouflage(opacity: 0.1)]

        // When
        let player = Player(
            name: "Custom Player",
            role: customRole,
            position: customPosition,
            activeAbilities: customAbilities
        )

        // Then
        XCTAssertEqual(player.name, "Custom Player")
        XCTAssertEqual(player.role, customRole)
        XCTAssertEqual(player.position, customPosition)
        XCTAssertEqual(player.activeAbilities.count, 1)
    }

    // MARK: - Player Stats Tests

    func testPlayerStats_winRate_withZeroGames() {
        // Given
        let stats = PlayerStats()

        // When
        let winRate = stats.winRate

        // Then
        XCTAssertEqual(winRate, 0.0, accuracy: 0.001)
    }

    func testPlayerStats_winRate_withGames() {
        // Given
        var stats = PlayerStats()
        stats.totalGamesPlayed = 10
        stats.gamesWon = 6

        // When
        let winRate = stats.winRate

        // Then
        XCTAssertEqual(winRate, 0.6, accuracy: 0.001)
    }

    func testPlayerStats_winRate_perfectWins() {
        // Given
        var stats = PlayerStats()
        stats.totalGamesPlayed = 5
        stats.gamesWon = 5

        // When
        let winRate = stats.winRate

        // Then
        XCTAssertEqual(winRate, 1.0, accuracy: 0.001)
    }

    // MARK: - Codable Tests

    func testPlayer_encodingAndDecoding() throws {
        // Given
        let originalPlayer = Player(
            name: "Codable Test",
            role: .seeker,
            position: SIMD3<Float>(5.0, 1.5, 3.0),
            activeAbilities: [.thermalVision(range: 5.0)]
        )

        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalPlayer)

        let decoder = JSONDecoder()
        let decodedPlayer = try decoder.decode(Player.self, from: data)

        // Then
        XCTAssertEqual(originalPlayer.id, decodedPlayer.id)
        XCTAssertEqual(originalPlayer.name, decodedPlayer.name)
        XCTAssertEqual(originalPlayer.role, decodedPlayer.role)
        XCTAssertEqual(originalPlayer.position, decodedPlayer.position)
        XCTAssertEqual(originalPlayer.activeAbilities.count, decodedPlayer.activeAbilities.count)
    }

    // MARK: - Avatar Configuration Tests

    func testAvatarConfig_defaultValues() {
        // Given & When
        let avatar = AvatarConfig()

        // Then
        XCTAssertEqual(avatar.bodyType, .average)
        XCTAssertEqual(avatar.height, .medium)
        XCTAssertEqual(avatar.pattern, .solid)
        XCTAssertEqual(avatar.accessory, .none)
    }

    func testAvatarConfig_customization() {
        // Given & When
        var avatar = AvatarConfig()
        avatar.bodyType = .athletic
        avatar.height = .tall
        avatar.pattern = .stripes
        avatar.accessory = .hat

        // Then
        XCTAssertEqual(avatar.bodyType, .athletic)
        XCTAssertEqual(avatar.height, .tall)
        XCTAssertEqual(avatar.pattern, .stripes)
        XCTAssertEqual(avatar.accessory, .hat)
    }

    // MARK: - Player Role Tests

    func testPlayerRole_equality() {
        // Given
        let role1 = PlayerRole.hider
        let role2 = PlayerRole.hider
        let role3 = PlayerRole.seeker

        // Then
        XCTAssertEqual(role1, role2)
        XCTAssertNotEqual(role1, role3)
    }

    // MARK: - SIMD3 Codable Tests

    func testSIMD3Float_encodingAndDecoding() throws {
        // Given
        let originalVector = SIMD3<Float>(10.5, 20.3, 30.7)

        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalVector)

        let decoder = JSONDecoder()
        let decodedVector = try decoder.decode(SIMD3<Float>.self, from: data)

        // Then
        XCTAssertEqual(originalVector.x, decodedVector.x, accuracy: 0.001)
        XCTAssertEqual(originalVector.y, decodedVector.y, accuracy: 0.001)
        XCTAssertEqual(originalVector.z, decodedVector.z, accuracy: 0.001)
    }

    // MARK: - simd_quatf Codable Tests

    func testQuaternion_encodingAndDecoding() throws {
        // Given
        let angle: Float = .pi / 4
        let axis = SIMD3<Float>(0, 1, 0)
        let originalQuat = simd_quatf(angle: angle, axis: axis)

        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalQuat)

        let decoder = JSONDecoder()
        let decodedQuat = try decoder.decode(simd_quatf.self, from: data)

        // Then
        XCTAssertEqual(originalQuat.real, decodedQuat.real, accuracy: 0.001)
        XCTAssertEqual(originalQuat.imag.x, decodedQuat.imag.x, accuracy: 0.001)
        XCTAssertEqual(originalQuat.imag.y, decodedQuat.imag.y, accuracy: 0.001)
        XCTAssertEqual(originalQuat.imag.z, decodedQuat.imag.z, accuracy: 0.001)
    }
}
