import XCTest
@testable import MySpatialLife

final class RelationshipTests: XCTestCase {

    func testRelationshipCreation() {
        let id1 = UUID()
        let id2 = UUID()

        let relationship = CharacterRelationship(
            characterA: id1,
            characterB: id2,
            relationshipType: .stranger,
            relationshipScore: 0.0
        )

        XCTAssertEqual(relationship.characterA, id1)
        XCTAssertEqual(relationship.characterB, id2)
        XCTAssertEqual(relationship.relationshipType, .stranger)
        XCTAssertEqual(relationship.relationshipScore, 0.0)
    }

    func testRelationshipScoreUpdate() {
        var relationship = CharacterRelationship(
            characterA: UUID(),
            characterB: UUID()
        )

        // Update score positively
        relationship.updateScore(by: 30.0)
        XCTAssertEqual(relationship.relationshipScore, 30.0, accuracy: 0.01)

        // Update score negatively
        relationship.updateScore(by: -10.0)
        XCTAssertEqual(relationship.relationshipScore, 20.0, accuracy: 0.01)
    }

    func testRelationshipScoreClamping() {
        var relationship = CharacterRelationship(
            characterA: UUID(),
            characterB: UUID()
        )

        // Try to exceed max
        relationship.updateScore(by: 150.0)
        XCTAssertEqual(relationship.relationshipScore, 100.0)

        // Try to go below min
        relationship.updateScore(by: -250.0)
        XCTAssertEqual(relationship.relationshipScore, -100.0)
    }

    func testRelationshipTypeProgression() {
        var relationship = CharacterRelationship(
            characterA: UUID(),
            characterB: UUID()
        )

        // Start as stranger
        XCTAssertEqual(relationship.relationshipType, .stranger)

        // Progress to acquaintance
        relationship.updateScore(by: 15.0)
        XCTAssertEqual(relationship.relationshipType, .acquaintance)

        // Progress to friend
        relationship.updateScore(by: 40.0)
        XCTAssertEqual(relationship.relationshipType, .friend)

        // Progress to best friend
        relationship.updateScore(by: 30.0)
        XCTAssertEqual(relationship.relationshipType, .bestFriend)
    }

    func testRomanceProgression() {
        var relationship = CharacterRelationship(
            characterA: UUID(),
            characterB: UUID()
        )

        // Build up romance
        relationship.updateRomance(by: 0.75)
        XCTAssertEqual(relationship.romanceLevel, 0.75, accuracy: 0.01)
        XCTAssertEqual(relationship.relationshipType, .romantic)

        // Reach soulmate level
        relationship.updateRomance(by: 0.15)
        XCTAssertEqual(relationship.romanceLevel, 0.9, accuracy: 0.01)
        XCTAssertEqual(relationship.relationshipType, .soulmate)
    }

    func testDatingProgression() {
        var relationship = CharacterRelationship(
            characterA: UUID(),
            characterB: UUID()
        )

        // Start dating
        XCTAssertFalse(relationship.isDating)
        relationship.startDating()
        XCTAssertTrue(relationship.isDating)
        XCTAssertNotNil(relationship.datingStartDate)
    }

    func testMarriage() {
        var relationship = CharacterRelationship(
            characterA: UUID(),
            characterB: UUID()
        )

        // Get married
        XCTAssertFalse(relationship.isMarried)
        relationship.marry()
        XCTAssertTrue(relationship.isMarried)
        XCTAssertNotNil(relationship.marriageDate)
        XCTAssertEqual(relationship.relationshipType, .spouse)

        // Dating should end
        XCTAssertFalse(relationship.isDating)
    }

    func testDivorce() {
        var relationship = CharacterRelationship(
            characterA: UUID(),
            characterB: UUID()
        )

        // Get married first
        relationship.updateScore(by: 80.0)
        relationship.updateRomance(by: 0.9)
        relationship.marry()
        let scoreBeforeDivorce = relationship.relationshipScore

        // Divorce
        relationship.divorce()

        XCTAssertFalse(relationship.isMarried)
        XCTAssertNil(relationship.marriageDate)
        XCTAssertLessThan(relationship.relationshipScore, scoreBeforeDivorce)
        XCTAssertLessThan(relationship.romanceLevel, 0.9)
    }

    func testInteractionRecording() {
        var relationship = CharacterRelationship(
            characterA: UUID(),
            characterB: UUID()
        )

        let initialCount = relationship.interactionCount

        relationship.recordInteraction()

        XCTAssertEqual(relationship.interactionCount, initialCount + 1)
    }

    func testRelationshipDecay() {
        var relationship = CharacterRelationship(
            characterA: UUID(),
            characterB: UUID(),
            relationshipScore: 50.0
        )

        let initialScore = relationship.relationshipScore

        // Apply 10 days of decay
        relationship.applyDecay(daysSinceLastInteraction: 10)

        // Score should decrease
        XCTAssertLessThan(relationship.relationshipScore, initialScore)

        // Should not decay below friendship threshold
        XCTAssertGreaterThanOrEqual(relationship.relationshipScore, 20.0)
    }

    func testRelationshipDecayDoesntGoBelowThreshold() {
        var relationship = CharacterRelationship(
            characterA: UUID(),
            characterB: UUID(),
            relationshipScore: 25.0
        )

        // Apply lots of decay
        relationship.applyDecay(daysSinceLastInteraction: 100)

        // Should stop at threshold
        XCTAssertGreaterThanOrEqual(relationship.relationshipScore, 20.0)
    }

    func testFriendshipLevelUpdate() {
        var relationship = CharacterRelationship(
            characterA: UUID(),
            characterB: UUID()
        )

        relationship.updateFriendship(by: 0.6)

        XCTAssertEqual(relationship.friendshipLevel, 0.6, accuracy: 0.01)
        XCTAssertEqual(relationship.relationshipType, .friend)
    }

    func testNegativeRelationship() {
        var relationship = CharacterRelationship(
            characterA: UUID(),
            characterB: UUID()
        )

        // Make them enemies
        relationship.updateScore(by: -60.0)

        XCTAssertEqual(relationship.relationshipType, .enemy)
    }

    func testRelationshipCodable() throws {
        let original = CharacterRelationship(
            characterA: UUID(),
            characterB: UUID(),
            relationshipType: .friend,
            relationshipScore: 50.0
        )

        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let data = try encoder.encode(original)
        let decoded = try decoder.decode(CharacterRelationship.self, from: data)

        XCTAssertEqual(original.id, decoded.id)
        XCTAssertEqual(original.relationshipType, decoded.relationshipType)
        XCTAssertEqual(original.relationshipScore, decoded.relationshipScore, accuracy: 0.01)
    }
}
