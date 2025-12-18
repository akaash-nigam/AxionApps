import XCTest
@testable import TacticalTeamShooters

final class NetworkIntegrationTests: XCTestCase {

    var networkManager: NetworkManager!

    override func setUp() {
        super.setUp()
        networkManager = NetworkManager()
    }

    override func tearDown() {
        networkManager.disconnect()
        networkManager = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testNetworkManagerInitialization() {
        XCTAssertNotNil(networkManager)
        XCTAssertFalse(networkManager.isConnected)
        XCTAssertTrue(networkManager.connectedPlayers.isEmpty)
        XCTAssertEqual(networkManager.latency, 0.0)
    }

    // MARK: - Serialization Tests

    func testPlayerInputSerialization() throws {
        let input = PlayerInput(
            timestamp: CACurrentMediaTime(),
            sequence: 1,
            position: CodableSimd3(SIMD3<Float>(1, 2, 3)),
            rotation: CodableQuaternion(simd_quatf(angle: 0, axis: SIMD3(0, 1, 0))),
            movement: CodableSimd2(SIMD2<Float>(0.5, 0.5)),
            actions: PlayerActions(isFiring: true)
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(input)

        XCTAssertGreaterThan(data.count, 0)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(PlayerInput.self, from: data)

        XCTAssertEqual(decoded.sequence, input.sequence)
        XCTAssertEqual(decoded.position.x, input.position.x, accuracy: 0.01)
        XCTAssertEqual(decoded.position.y, input.position.y, accuracy: 0.01)
        XCTAssertEqual(decoded.position.z, input.position.z, accuracy: 0.01)
        XCTAssertTrue(decoded.actions.isFiring)
    }

    func testPlayerActionsSerialization() throws {
        let actions = PlayerActions(
            isFiring: true,
            isReloading: false,
            isJumping: true,
            isCrouching: false
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(actions)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(PlayerActions.self, from: data)

        XCTAssertEqual(decoded.isFiring, actions.isFiring)
        XCTAssertEqual(decoded.isReloading, actions.isReloading)
        XCTAssertEqual(decoded.isJumping, actions.isJumping)
        XCTAssertEqual(decoded.isCrouching, actions.isCrouching)
    }

    func testGameStateSnapshotSerialization() throws {
        let snapshot = GameStateSnapshot(
            timestamp: CACurrentMediaTime(),
            sequence: 100,
            players: [
                PlayerState(
                    id: UUID(),
                    position: CodableSimd3(SIMD3<Float>(0, 0, 0)),
                    rotation: CodableQuaternion(simd_quatf(angle: 0, axis: SIMD3(0, 1, 0))),
                    health: 100.0,
                    isAlive: true
                ),
                PlayerState(
                    id: UUID(),
                    position: CodableSimd3(SIMD3<Float>(10, 0, 10)),
                    rotation: CodableQuaternion(simd_quatf(angle: Float.pi / 2, axis: SIMD3(0, 1, 0))),
                    health: 75.0,
                    isAlive: true
                )
            ]
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(snapshot)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(GameStateSnapshot.self, from: data)

        XCTAssertEqual(decoded.sequence, snapshot.sequence)
        XCTAssertEqual(decoded.players.count, 2)
        XCTAssertEqual(decoded.players[0].health, 100.0, accuracy: 0.1)
        XCTAssertEqual(decoded.players[1].health, 75.0, accuracy: 0.1)
        XCTAssertTrue(decoded.players[0].isAlive)
        XCTAssertTrue(decoded.players[1].isAlive)
    }

    // MARK: - Codable SIMD Tests

    func testCodableSimd3() throws {
        let original = SIMD3<Float>(1.5, 2.5, 3.5)
        let codable = CodableSimd3(original)

        let encoder = JSONEncoder()
        let data = try encoder.encode(codable)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(CodableSimd3.self, from: data)

        XCTAssertEqual(decoded.x, original.x, accuracy: 0.01)
        XCTAssertEqual(decoded.y, original.y, accuracy: 0.01)
        XCTAssertEqual(decoded.z, original.z, accuracy: 0.01)

        let reconstructed = decoded.simd3
        XCTAssertEqual(reconstructed.x, original.x, accuracy: 0.01)
        XCTAssertEqual(reconstructed.y, original.y, accuracy: 0.01)
        XCTAssertEqual(reconstructed.z, original.z, accuracy: 0.01)
    }

    func testCodableSimd2() throws {
        let original = SIMD2<Float>(0.75, -0.5)
        let codable = CodableSimd2(original)

        let encoder = JSONEncoder()
        let data = try encoder.encode(codable)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(CodableSimd2.self, from: data)

        XCTAssertEqual(decoded.x, original.x, accuracy: 0.01)
        XCTAssertEqual(decoded.y, original.y, accuracy: 0.01)

        let reconstructed = decoded.simd2
        XCTAssertEqual(reconstructed.x, original.x, accuracy: 0.01)
        XCTAssertEqual(reconstructed.y, original.y, accuracy: 0.01)
    }

    func testCodableQuaternion() throws {
        let original = simd_quatf(angle: Float.pi / 4, axis: SIMD3(0, 1, 0))
        let codable = CodableQuaternion(original)

        let encoder = JSONEncoder()
        let data = try encoder.encode(codable)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(CodableQuaternion.self, from: data)

        let reconstructed = decoded.quaternion

        XCTAssertEqual(reconstructed.vector.x, original.vector.x, accuracy: 0.01)
        XCTAssertEqual(reconstructed.vector.y, original.vector.y, accuracy: 0.01)
        XCTAssertEqual(reconstructed.vector.z, original.vector.z, accuracy: 0.01)
        XCTAssertEqual(reconstructed.vector.w, original.vector.w, accuracy: 0.01)
    }

    // MARK: - Data Size Tests

    func testPlayerInputDataSize() throws {
        let input = PlayerInput(
            timestamp: CACurrentMediaTime(),
            sequence: 1,
            position: CodableSimd3(SIMD3<Float>(1, 2, 3)),
            rotation: CodableQuaternion(simd_quatf(angle: 0, axis: SIMD3(0, 1, 0))),
            movement: CodableSimd2(SIMD2<Float>(0.5, 0.5)),
            actions: PlayerActions()
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(input)

        // Data should be reasonably small (< 500 bytes)
        XCTAssertLessThan(data.count, 500)

        print("Player input data size: \(data.count) bytes")
    }

    func testGameStateSnapshotDataSize() throws {
        // Create snapshot with 10 players
        var players: [PlayerState] = []
        for _ in 0..<10 {
            players.append(PlayerState(
                id: UUID(),
                position: CodableSimd3(SIMD3<Float>(0, 0, 0)),
                rotation: CodableQuaternion(simd_quatf(angle: 0, axis: SIMD3(0, 1, 0))),
                health: 100.0,
                isAlive: true
            ))
        }

        let snapshot = GameStateSnapshot(
            timestamp: CACurrentMediaTime(),
            sequence: 1,
            players: players
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(snapshot)

        // Data should be reasonable (< 5KB for 10 players)
        XCTAssertLessThan(data.count, 5000)

        print("Game state snapshot data size (10 players): \(data.count) bytes")
    }
}
