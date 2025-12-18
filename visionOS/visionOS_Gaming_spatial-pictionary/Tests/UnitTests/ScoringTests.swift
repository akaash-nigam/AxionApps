import XCTest
@testable import SpatialPictionary

/// Unit tests for Scoring System
/// ✅ Can run with: XCTest framework
/// ❌ Cannot run: Without Xcode environment
final class ScoringTests: XCTestCase {
    var scoringSystem: ScoringSystem!

    override func setUp() {
        super.setUp()
        scoringSystem = ScoringSystem()
    }

    override func tearDown() {
        scoringSystem = nil
        super.tearDown()
    }

    // MARK: - Base Points Tests

    func testCorrectGuessBasePoints() {
        let points = scoringSystem.calculatePoints(
            difficulty: .easy,
            timeRemaining: 45.0,
            totalTime: 90.0,
            hintsUsed: 0
        )

        // Base 100 + time bonus (45s * 2 = 90)
        XCTAssertEqual(points, 190,
                      "Easy word with 45s remaining should give 190 points")
    }

    func testDifficultyMultiplierEasy() {
        let points = scoringSystem.calculatePoints(
            difficulty: .easy,
            timeRemaining: 0,
            totalTime: 90,
            hintsUsed: 0
        )

        XCTAssertEqual(points, 100,
                      "Easy difficulty should have 1.0x multiplier")
    }

    func testDifficultyMultiplierMedium() {
        let points = scoringSystem.calculatePoints(
            difficulty: .medium,
            timeRemaining: 0,
            totalTime: 90,
            hintsUsed: 0
        )

        XCTAssertEqual(points, 150,
                      "Medium difficulty should have 1.5x multiplier")
    }

    func testDifficultyMultiplierHard() {
        let points = scoringSystem.calculatePoints(
            difficulty: .hard,
            timeRemaining: 0,
            totalTime: 90,
            hintsUsed: 0
        )

        XCTAssertEqual(points, 200,
                      "Hard difficulty should have 2.0x multiplier")
    }

    // MARK: - Time Bonus Tests

    func testTimeBonusCalculation() {
        // 60 seconds remaining = 120 bonus points (2 points per second)
        let points = scoringSystem.calculateTimeBonus(timeRemaining: 60.0)

        XCTAssertEqual(points, 120,
                      "60 seconds should give 120 bonus points")
    }

    func testNoTimeBonusWhenTimeExpired() {
        let points = scoringSystem.calculateTimeBonus(timeRemaining: 0.0)

        XCTAssertEqual(points, 0,
                      "No time remaining should give no bonus")
    }

    func testPartialTimeBonus() {
        let points = scoringSystem.calculateTimeBonus(timeRemaining: 30.0)

        XCTAssertEqual(points, 60,
                      "30 seconds should give 60 bonus points")
    }

    // MARK: - Hint Penalty Tests

    func testNoHintsPenalty() {
        let points = scoringSystem.calculatePoints(
            difficulty: .medium,
            timeRemaining: 0,
            totalTime: 90,
            hintsUsed: 0
        )

        XCTAssertEqual(points, 150,
                      "No hints should give full points")
    }

    func testOneHintPenalty() {
        let points = scoringSystem.calculatePoints(
            difficulty: .medium,
            timeRemaining: 0,
            totalTime: 90,
            hintsUsed: 1
        )

        // 75% of 150 = 112.5 rounded to 112
        XCTAssertEqual(points, 112,
                      "One hint should reduce points to 75%")
    }

    func testTwoHintsPenalty() {
        let points = scoringSystem.calculatePoints(
            difficulty: .medium,
            timeRemaining: 0,
            totalTime: 90,
            hintsUsed: 2
        )

        // 50% of 150 = 75
        XCTAssertEqual(points, 75,
                      "Two hints should reduce points to 50%")
    }

    func testThreeHintsPenalty() {
        let points = scoringSystem.calculatePoints(
            difficulty: .medium,
            timeRemaining: 0,
            totalTime: 90,
            hintsUsed: 3
        )

        // 25% of 150 = 37.5 rounded to 37
        XCTAssertEqual(points, 37,
                      "Three hints should reduce points to 25%")
    }

    // MARK: - Artist Bonus Tests

    func testArtistBonusEasy() {
        let bonus = scoringSystem.calculateArtistBonus(
            difficulty: .easy,
            guesserCount: 1
        )

        // Artist gets 50 points base * 1.0 difficulty = 50
        XCTAssertEqual(bonus, 50,
                      "Artist bonus for easy should be 50")
    }

    func testArtistBonusMedium() {
        let bonus = scoringSystem.calculateArtistBonus(
            difficulty: .medium,
            guesserCount: 1
        )

        // Artist gets 50 points base * 1.5 difficulty = 75
        XCTAssertEqual(bonus, 75,
                      "Artist bonus for medium should be 75")
    }

    func testArtistBonusHard() {
        let bonus = scoringSystem.calculateArtistBonus(
            difficulty: .hard,
            guesserCount: 1
        )

        // Artist gets 50 points base * 2.0 difficulty = 100
        XCTAssertEqual(bonus, 100,
                      "Artist bonus for hard should be 100")
    }

    func testArtistBonusIncreasesWithGuessers() {
        let bonus1 = scoringSystem.calculateArtistBonus(
            difficulty: .easy,
            guesserCount: 1
        )
        let bonus3 = scoringSystem.calculateArtistBonus(
            difficulty: .easy,
            guesserCount: 3
        )

        // More guessers = engagement bonus
        XCTAssertGreaterThan(bonus3, bonus1,
                           "More guessers should increase artist bonus")
    }

    // MARK: - Leaderboard Tests

    func testLeaderboardSorting() {
        let id1 = UUID()
        let id2 = UUID()
        let id3 = UUID()

        scoringSystem.updateScore(playerID: id1, points: 100)
        scoringSystem.updateScore(playerID: id2, points: 300)
        scoringSystem.updateScore(playerID: id3, points: 200)

        let leaderboard = scoringSystem.getLeaderboard()

        XCTAssertEqual(leaderboard[0].score, 300,
                      "First place should have 300 points")
        XCTAssertEqual(leaderboard[1].score, 200,
                      "Second place should have 200 points")
        XCTAssertEqual(leaderboard[2].score, 100,
                      "Third place should have 100 points")
    }

    func testLeaderboardWithTies() {
        let id1 = UUID()
        let id2 = UUID()
        let id3 = UUID()

        scoringSystem.updateScore(playerID: id1, points: 100)
        scoringSystem.updateScore(playerID: id2, points: 100)
        scoringSystem.updateScore(playerID: id3, points: 200)

        let leaderboard = scoringSystem.getLeaderboard()

        XCTAssertEqual(leaderboard[0].score, 200,
                      "First place should be 200")
        XCTAssertEqual(leaderboard[1].score, 100,
                      "Second place should be 100 (tie)")
        XCTAssertEqual(leaderboard[2].score, 100,
                      "Third place should be 100 (tie)")
    }

    // MARK: - Score Update Tests

    func testUpdateScore() {
        let playerID = UUID()

        scoringSystem.updateScore(playerID: playerID, points: 100)
        XCTAssertEqual(scoringSystem.getScore(for: playerID), 100)

        scoringSystem.updateScore(playerID: playerID, points: 50)
        XCTAssertEqual(scoringSystem.getScore(for: playerID), 150)
    }

    func testResetScores() {
        let id1 = UUID()
        let id2 = UUID()

        scoringSystem.updateScore(playerID: id1, points: 100)
        scoringSystem.updateScore(playerID: id2, points: 200)

        scoringSystem.resetAllScores()

        XCTAssertEqual(scoringSystem.getScore(for: id1), 0)
        XCTAssertEqual(scoringSystem.getScore(for: id2), 0)
    }
}
