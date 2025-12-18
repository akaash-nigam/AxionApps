//
//  NetworkIntegrationTests.swift
//  Spatial Arena Championship Tests
//
//  Integration tests for networking
//

import XCTest
@testable import SpatialArenaChampionship

@MainActor
final class NetworkIntegrationTests: XCTestCase {

    var networkManager: NetworkManager!

    override func setUp() async throws {
        try await super.setUp()
        networkManager = NetworkManager()
    }

    override func tearDown() {
        networkManager?.disconnect()
        networkManager = nil
        super.tearDown()
    }

    // MARK: - Connection Tests

    func testHostMatchInitialization() throws {
        try networkManager.hostMatch(maxPlayers: 10)

        XCTAssertTrue(networkManager.isHost)
        XCTAssertEqual(networkManager.connectionState, .hosting)
    }

    func testJoinMatchInitialization() throws {
        try networkManager.joinMatch()

        XCTAssertFalse(networkManager.isHost)
        XCTAssertEqual(networkManager.connectionState, .browsing)
    }

    func testMultipleHostAttemptsFail() throws {
        try networkManager.hostMatch(maxPlayers: 10)

        XCTAssertThrowsError(try networkManager.hostMatch(maxPlayers: 10)) { error in
            // Should throw error when already hosting
        }
    }

    // MARK: - Message Encoding Tests

    func testNetworkMessageEncoding() throws {
        let message = NetworkMessage(
            type: .playerPosition,
            payload: ["x": 1.0, "y": 2.0, "z": 3.0],
            senderID: UUID()
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(message)

        XCTAssertGreaterThan(data.count, 0)
    }

    func testNetworkMessageDecoding() throws {
        let originalMessage = NetworkMessage(
            type: .playerPosition,
            payload: ["x": 1.0, "y": 2.0, "z": 3.0],
            senderID: UUID()
        )

        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let data = try encoder.encode(originalMessage)
        let decodedMessage = try decoder.decode(NetworkMessage.self, from: data)

        XCTAssertEqual(originalMessage.type, decodedMessage.type)
        XCTAssertEqual(originalMessage.senderID, decodedMessage.senderID)
    }

    // MARK: - Message Handler Tests

    func testMessageHandlerRegistration() {
        var receivedMessage: NetworkMessage?

        networkManager.registerHandler(for: .playerPosition) { message in
            receivedMessage = message
        }

        // Simulate receiving a message
        let testMessage = NetworkMessage(
            type: .playerPosition,
            payload: [:],
            senderID: UUID()
        )

        // Manually trigger handler (in real scenario, this happens via network)
        if let handler = networkManager.messageHandlers[.playerPosition] {
            handler(testMessage)
        }

        XCTAssertNotNil(receivedMessage)
    }

    // MARK: - Statistics Tests

    func testNetworkStatsInitialization() {
        XCTAssertEqual(networkManager.networkStats.bytesSent, 0)
        XCTAssertEqual(networkManager.networkStats.bytesReceived, 0)
        XCTAssertEqual(networkManager.networkStats.messagesSent, 0)
        XCTAssertEqual(networkManager.networkStats.messagesReceived, 0)
    }

    // MARK: - Disconnect Tests

    func testDisconnectCleansUp() throws {
        try networkManager.hostMatch(maxPlayers: 10)

        networkManager.disconnect()

        XCTAssertEqual(networkManager.connectionState, .disconnected)
        XCTAssertEqual(networkManager.connectedPeers.count, 0)
        XCTAssertFalse(networkManager.isHost)
    }

    // MARK: - Performance Tests

    func testMessageEncodingPerformance() {
        let message = NetworkMessage(
            type: .playerPosition,
            payload: ["x": 1.0, "y": 2.0, "z": 3.0],
            senderID: UUID()
        )

        let encoder = JSONEncoder()

        measure {
            for _ in 0..<1000 {
                _ = try? encoder.encode(message)
            }
        }
    }
}
