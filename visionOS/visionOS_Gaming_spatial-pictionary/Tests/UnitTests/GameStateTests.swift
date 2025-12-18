import XCTest
@testable import SpatialPictionary

/// Unit tests for GameState management
/// ✅ Can run with: XCTest framework
/// ❌ Cannot run: Without Xcode environment
final class GameStateTests: XCTestCase {
    var gameState: GameState!

    override func setUp() {
        super.setUp()
        gameState = GameState()
    }

    override func tearDown() {
        gameState = nil
        super.tearDown()
    }

    // MARK: - Phase Transition Tests

    func testInitialPhaseIsLobby() {
        XCTAssertEqual(gameState.currentPhase, .lobby,
                      "Initial game phase should be lobby")
    }

    func testTransitionFromLobbyToWordSelection() {
        let artist = Player(
            id: UUID(),
            name: "Artist",
            avatar: AvatarConfiguration.default,
            score: 0,
            isLocal: true,
            deviceID: "device1",
            spatialExperience: 0
        )
        gameState.players.append(artist)

        gameState.transitionTo(.wordSelection)

        switch gameState.currentPhase {
        case .wordSelection:
            XCTAssertTrue(true, "Successfully transitioned to word selection")
        default:
            XCTFail("Expected word selection phase, got \(gameState.currentPhase)")
        }
    }

    func testTransitionToDrawingRequiresWord() {
        let artist = Player(
            id: UUID(),
            name: "Artist",
            avatar: AvatarConfiguration.default,
            score: 0,
            isLocal: true,
            deviceID: "device1",
            spatialExperience: 0
        )
        let word = Word(
            id: UUID(),
            text: "cat",
            category: .animals,
            difficulty: .easy,
            language: "en",
            metadata: [:]
        )

        gameState.selectWord(word, artist: artist)

        switch gameState.currentPhase {
        case .drawing(let selectedArtist, let selectedWord, _):
            XCTAssertEqual(selectedArtist.id, artist.id,
                          "Artist should match")
            XCTAssertEqual(selectedWord.id, word.id,
                          "Word should match")
        default:
            XCTFail("Expected drawing phase")
        }
    }

    // MARK: - Player Management Tests

    func testAddPlayer() {
        let player = Player(
            id: UUID(),
            name: "Player1",
            avatar: AvatarConfiguration.default,
            score: 0,
            isLocal: true,
            deviceID: "device1",
            spatialExperience: 0
        )

        gameState.addPlayer(player)

        XCTAssertEqual(gameState.players.count, 1,
                      "Should have one player")
        XCTAssertEqual(gameState.players.first?.name, "Player1",
                      "Player name should match")
    }

    func testRemovePlayer() {
        let player = Player(
            id: UUID(),
            name: "Player1",
            avatar: AvatarConfiguration.default,
            score: 0,
            isLocal: true,
            deviceID: "device1",
            spatialExperience: 0
        )
        gameState.addPlayer(player)

        XCTAssertEqual(gameState.players.count, 1,
                      "Should have one player before removal")

        gameState.removePlayer(player.id)

        XCTAssertEqual(gameState.players.count, 0,
                      "Should have no players after removal")
    }

    func testMaxPlayersLimit() {
        // Add maximum players (12)
        for i in 1...12 {
            let player = Player(
                id: UUID(),
                name: "Player\(i)",
                avatar: AvatarConfiguration.default,
                score: 0,
                isLocal: true,
                deviceID: "device\(i)",
                spatialExperience: 0
            )
            gameState.addPlayer(player)
        }

        XCTAssertEqual(gameState.players.count, 12,
                      "Should have 12 players")

        // Try to add 13th player
        let extraPlayer = Player(
            id: UUID(),
            name: "Extra",
            avatar: AvatarConfiguration.default,
            score: 0,
            isLocal: true,
            deviceID: "device13",
            spatialExperience: 0
        )
        gameState.addPlayer(extraPlayer)

        // Should still be 12
        XCTAssertEqual(gameState.players.count, 12,
                      "Should not exceed maximum of 12 players")
    }

    // MARK: - Round Management Tests

    func testRoundNumberIncrementsAfterRound() {
        gameState.roundNumber = 0

        gameState.completeRound()

        XCTAssertEqual(gameState.roundNumber, 1,
                      "Round number should increment")
    }

    func testArtistRotation() {
        let player1 = Player(
            id: UUID(),
            name: "Player1",
            avatar: AvatarConfiguration.default,
            score: 0,
            isLocal: true,
            deviceID: "device1",
            spatialExperience: 0
        )
        let player2 = Player(
            id: UUID(),
            name: "Player2",
            avatar: AvatarConfiguration.default,
            score: 0,
            isLocal: true,
            deviceID: "device2",
            spatialExperience: 0
        )
        let player3 = Player(
            id: UUID(),
            name: "Player3",
            avatar: AvatarConfiguration.default,
            score: 0,
            isLocal: true,
            deviceID: "device3",
            spatialExperience: 0
        )

        gameState.players = [player1, player2, player3]

        XCTAssertEqual(gameState.selectNextArtist()?.id, player1.id,
                      "First artist should be player1")
        XCTAssertEqual(gameState.selectNextArtist()?.id, player2.id,
                      "Second artist should be player2")
        XCTAssertEqual(gameState.selectNextArtist()?.id, player3.id,
                      "Third artist should be player3")
        XCTAssertEqual(gameState.selectNextArtist()?.id, player1.id,
                      "Should wrap around to player1")
    }

    // MARK: - Score Management Tests

    func testAddScore() {
        let playerID = UUID()
        gameState.scores[playerID] = 100

        gameState.addScore(50, to: playerID)

        XCTAssertEqual(gameState.scores[playerID], 150,
                      "Score should be updated")
    }

    func testGetLeaderboard() {
        let p1 = UUID()
        let p2 = UUID()
        let p3 = UUID()

        gameState.scores[p1] = 100
        gameState.scores[p2] = 300
        gameState.scores[p3] = 200

        let leaderboard = gameState.getLeaderboard()

        XCTAssertEqual(leaderboard[0].playerID, p2,
                      "Highest scorer should be first")
        XCTAssertEqual(leaderboard[1].playerID, p3,
                      "Second highest should be second")
        XCTAssertEqual(leaderboard[2].playerID, p1,
                      "Lowest scorer should be last")
    }
}
