import XCTest
@testable import MySpatialLife

final class CharacterTests: XCTestCase {

    func testCharacterCreation() {
        let personality = Personality.balanced
        let character = Character(
            firstName: "Sarah",
            lastName: "Smith",
            age: 25,
            gender: .female,
            personality: personality
        )

        XCTAssertEqual(character.firstName, "Sarah")
        XCTAssertEqual(character.lastName, "Smith")
        XCTAssertEqual(character.fullName, "Sarah Smith")
        XCTAssertEqual(character.age, 25)
        XCTAssertEqual(character.gender, .female)
        XCTAssertEqual(character.lifeStage, .youngAdult)
    }

    func testLifeStageForAge() {
        XCTAssertEqual(Character.lifeStageForAge(1), .baby)
        XCTAssertEqual(Character.lifeStageForAge(4), .toddler)
        XCTAssertEqual(Character.lifeStageForAge(10), .child)
        XCTAssertEqual(Character.lifeStageForAge(15), .teen)
        XCTAssertEqual(Character.lifeStageForAge(25), .youngAdult)
        XCTAssertEqual(Character.lifeStageForAge(40), .adult)
        XCTAssertEqual(Character.lifeStageForAge(60), .elder)
    }

    func testNeedAccess() {
        let character = Character(
            firstName: "Test",
            lastName: "User",
            age: 25,
            gender: .male,
            personality: .balanced
        )

        // Test getting need values
        XCTAssertEqual(character.needValue(for: .hunger), 1.0)
        XCTAssertEqual(character.needValue(for: .energy), 1.0)

        // Test setting need values
        character.setNeed(.hunger, to: 0.5)
        XCTAssertEqual(character.needValue(for: .hunger), 0.5)
    }

    func testNeedValuesClamped() {
        let character = Character(
            firstName: "Test",
            lastName: "User",
            age: 25,
            gender: .male,
            personality: .balanced
        )

        // Try to set values outside range
        character.setNeed(.hunger, to: 1.5)
        XCTAssertEqual(character.hunger, 1.0)

        character.setNeed(.energy, to: -0.5)
        XCTAssertEqual(character.energy, 0.0)
    }

    func testMostCriticalNeed() {
        let character = Character(
            firstName: "Test",
            lastName: "User",
            age: 25,
            gender: .male,
            personality: .balanced
        )

        // Set hunger to lowest
        character.hunger = 0.1
        character.energy = 0.5
        character.social = 0.8

        let critical = character.mostCriticalNeed()
        XCTAssertEqual(critical, .hunger)
    }

    func testHasCriticalNeed() {
        let character = Character(
            firstName: "Test",
            lastName: "User",
            age: 25,
            gender: .male,
            personality: .balanced
        )

        // Initially no critical needs
        XCTAssertFalse(character.hasCriticalNeed)

        // Make hunger critical
        character.hunger = 0.1
        XCTAssertTrue(character.hasCriticalNeed)
    }

    func testAgeUp() {
        let character = Character(
            firstName: "Test",
            lastName: "User",
            age: 19,  // Teen
            gender: .male,
            personality: .balanced
        )

        XCTAssertEqual(character.lifeStage, .teen)

        // Age up to young adult
        character.ageUp()

        XCTAssertEqual(character.age, 20)
        XCTAssertEqual(character.lifeStage, .youngAdult)
    }

    func testSkillsInitialized() {
        let character = Character(
            firstName: "Test",
            lastName: "User",
            age: 25,
            gender: .male,
            personality: .balanced
        )

        // All skills should start at 1
        for skill in Skill.allCases {
            XCTAssertEqual(character.skills[skill], 1)
        }
    }

    func testRelationshipManagement() {
        let character = Character(
            firstName: "Test",
            lastName: "User",
            age: 25,
            gender: .male,
            personality: .balanced
        )

        let otherID = UUID()
        let relationship = CharacterRelationship(
            characterA: character.id,
            characterB: otherID,
            relationshipType: .friend,
            relationshipScore: 50.0
        )

        // Add relationship
        character.setRelationship(relationship, with: otherID)

        // Retrieve relationship
        let retrieved = character.relationship(with: otherID)
        XCTAssertNotNil(retrieved)
        XCTAssertEqual(retrieved?.relationshipType, .friend)
    }

    func testGeneticsCreation() {
        let personality = Personality(
            openness: 0.8,
            conscientiousness: 0.6,
            extraversion: 0.7,
            agreeableness: 0.9,
            neuroticism: 0.3
        )

        let character = Character(
            firstName: "Test",
            lastName: "User",
            age: 25,
            gender: .male,
            personality: personality
        )

        // Genetics should be created from personality
        XCTAssertEqual(character.genetics.opennessGene, 0.8, accuracy: 0.01)
        XCTAssertEqual(character.genetics.extraversionGene, 0.7, accuracy: 0.01)
    }

    func testCharacterCodable() throws {
        let original = Character(
            firstName: "Sarah",
            lastName: "Smith",
            age: 25,
            gender: .female,
            personality: .balanced
        )

        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let data = try encoder.encode(original)
        let decoded = try decoder.decode(Character.self, from: data)

        XCTAssertEqual(original.id, decoded.id)
        XCTAssertEqual(original.firstName, decoded.firstName)
        XCTAssertEqual(original.lastName, decoded.lastName)
        XCTAssertEqual(original.age, decoded.age)
    }
}
