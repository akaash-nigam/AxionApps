import XCTest
@testable import EscapeRoomNetwork

/// Unit tests for multiplayer manager
final class MultiplayerManagerTests: XCTestCase {

    var sut: MultiplayerManager!

    override func setUp() {
        super.setUp()
        sut = MultiplayerManager()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitialization() {
        XCTAssertNotNil(sut)
        XCTAssertNil(sut.currentSession)
        XCTAssertTrue(sut.connectedPlayers.isEmpty)
        XCTAssertFalse(sut.isSessionActive)
    }

    // MARK: - Session Management Tests

    func testStartMultiplayerSession() async throws {
        // Given
        let puzzleId = UUID()

        // When
        try await sut.startMultiplayerSession(puzzleId: puzzleId)

        // Then
        XCTAssertNotNil(sut.currentSession)
        XCTAssertEqual(sut.currentSession?.puzzleId, puzzleId)
        XCTAssertTrue(sut.isSessionActive)
        XCTAssertFalse(sut.connectedPlayers.isEmpty)
    }

    func testJoinSession() async throws {
        // Given
        let sessionId = UUID()

        // When
        try await sut.joinSession(sessionId: sessionId)

        // Then
        XCTAssertTrue(sut.isSessionActive)
        XCTAssertFalse(sut.connectedPlayers.isEmpty)
    }

    func testLeaveSession() async throws {
        // Given
        try await sut.startMultiplayerSession(puzzleId: UUID())
        XCTAssertTrue(sut.isSessionActive)

        // When
        sut.leaveSession()

        // Then
        XCTAssertNil(sut.currentSession)
        XCTAssertTrue(sut.connectedPlayers.isEmpty)
        XCTAssertFalse(sut.isSessionActive)
    }

    // MARK: - Player Management Tests

    func testAddPlayer() {
        // Given
        let newPlayer = Player(username: "TestPlayer")

        // When
        sut.addPlayer(newPlayer)

        // Then
        XCTAssertEqual(sut.connectedPlayers.count, 1)
        XCTAssertTrue(sut.connectedPlayers.contains(where: { $0.id == newPlayer.id }))
    }

    func testAddDuplicatePlayer() {
        // Given
        let player = Player(username: "TestPlayer")
        sut.addPlayer(player)

        // When - Try to add same player again
        sut.addPlayer(player)

        // Then - Should only have one instance
        XCTAssertEqual(sut.connectedPlayers.count, 1)
    }

    func testRemovePlayer() {
        // Given
        let player = Player(username: "TestPlayer")
        sut.addPlayer(player)
        XCTAssertEqual(sut.connectedPlayers.count, 1)

        // When
        sut.removePlayer(player.id)

        // Then
        XCTAssertTrue(sut.connectedPlayers.isEmpty)
    }

    func testRemoveNonexistentPlayer() {
        // Given
        let player = Player(username: "TestPlayer")
        sut.addPlayer(player)

        // When
        sut.removePlayer(UUID()) // Random UUID

        // Then - Original player should still be there
        XCTAssertEqual(sut.connectedPlayers.count, 1)
    }

    // MARK: - State Synchronization Tests

    func testSyncGameState() async throws {
        // Given
        try await sut.startMultiplayerSession(puzzleId: UUID())
        let state = SharedGameState(
            completedObjectives: [UUID()],
            discoveredClues: [UUID()],
            currentPhase: 2
        )

        // When
        sut.syncGameState(state)

        // Then - Should not crash
    }

    func testReceiveGameState() async throws {
        // Given
        try await sut.startMultiplayerSession(puzzleId: UUID())
        let newState = SharedGameState(
            completedObjectives: [UUID()],
            discoveredClues: [UUID()],
            currentPhase: 3
        )

        // When
        sut.receiveGameState(newState)

        // Then
        XCTAssertEqual(sut.currentSession?.sharedState.currentPhase, 3)
        XCTAssertEqual(sut.currentSession?.sharedState.completedObjectives.count, 1)
    }

    // MARK: - Message Handling Tests

    func testSendMessageWithoutSession() {
        // Given - No active session
        let message = NetworkMessage.chatMessage("Hello")

        // When/Then - Should handle gracefully
        sut.sendMessage(message)
    }

    func testSendMessageWithSession() async throws {
        // Given
        try await sut.startMultiplayerSession(puzzleId: UUID())
        let message = NetworkMessage.chatMessage("Hello")

        // When/Then - Should not crash
        sut.sendMessage(message)
    }

    func testHandlePlayerJoinedMessage() {
        // Given
        let newPlayer = Player(username: "NewPlayer")
        let message = NetworkMessage.playerJoined(newPlayer)

        // When
        sut.handleReceivedMessage(message)

        // Then
        XCTAssertTrue(sut.connectedPlayers.contains(where: { $0.id == newPlayer.id }))
    }

    func testHandlePlayerLeftMessage() {
        // Given
        let player = Player(username: "TestPlayer")
        sut.addPlayer(player)
        let message = NetworkMessage.playerLeft(player.id)

        // When
        sut.handleReceivedMessage(message)

        // Then
        XCTAssertFalse(sut.connectedPlayers.contains(where: { $0.id == player.id }))
    }

    func testHandlePuzzleProgressMessage() async throws {
        // Given
        try await sut.startMultiplayerSession(puzzleId: UUID())
        let progress = PuzzleProgress(puzzleId: UUID())
        let message = NetworkMessage.puzzleProgress(progress)

        // When/Then - Should not crash
        sut.handleReceivedMessage(message)
    }

    // MARK: - Edge Case Tests

    func testMultipleSessionsSequential() async throws {
        // When - Create multiple sessions sequentially
        try await sut.startMultiplayerSession(puzzleId: UUID())
        let firstSessionId = sut.currentSession?.id

        sut.leaveSession()

        try await sut.startMultiplayerSession(puzzleId: UUID())
        let secondSessionId = sut.currentSession?.id

        // Then
        XCTAssertNotEqual(firstSessionId, secondSessionId)
    }

    func testMaxPlayers() async throws {
        // Given
        try await sut.startMultiplayerSession(puzzleId: UUID())

        // When - Add 6 players (typical max for collaborative games)
        for i in 1...6 {
            sut.addPlayer(Player(username: "Player\(i)"))
        }

        // Then
        XCTAssertEqual(sut.connectedPlayers.count, 7) // 6 + local player
    }

    // MARK: - Performance Tests

    func testSessionCreationPerformance() {
        measure {
            Task {
                try? await sut.startMultiplayerSession(puzzleId: UUID())
                sut.leaveSession()
            }
        }
    }

    func testMessageHandlingPerformance() {
        measure {
            for _ in 0..<100 {
                let message = NetworkMessage.chatMessage("Test")
                sut.handleReceivedMessage(message)
            }
        }
    }
}
