import XCTest
@testable import InteractiveTheater

/// Unit tests for CharacterModel and related types
final class CharacterModelTests: XCTestCase {

    // MARK: - Test PersonalityTraits

    func testPersonalityTraitsDefault() {
        let traits = PersonalityTraits()

        // All traits should default to 0.5
        XCTAssertEqual(traits.openness, 0.5)
        XCTAssertEqual(traits.conscientiousness, 0.5)
        XCTAssertEqual(traits.extraversion, 0.5)
        XCTAssertEqual(traits.agreeableness, 0.5)
        XCTAssertEqual(traits.neuroticism, 0.5)
        XCTAssertEqual(traits.honor, 0.5)
        XCTAssertEqual(traits.ambition, 0.5)
        XCTAssertEqual(traits.loyalty, 0.5)
        XCTAssertEqual(traits.compassion, 0.5)
    }

    func testPersonalityTraitsCustom() {
        let traits = PersonalityTraits(
            openness: 0.8,
            conscientiousness: 0.7,
            extraversion: 0.6,
            agreeableness: 0.9,
            neuroticism: 0.3,
            honor: 0.95,
            ambition: 0.2,
            loyalty: 0.85,
            compassion: 0.9
        )

        XCTAssertEqual(traits.openness, 0.8)
        XCTAssertEqual(traits.honor, 0.95)
        XCTAssertEqual(traits.compassion, 0.9)
    }

    // MARK: - Test EmotionalState

    func testEmotionalStateCreation() {
        let emotion = EmotionalState(
            primaryEmotion: .joy,
            emotionIntensity: 0.8,
            emotionTrigger: "Player choice",
            emotionDuration: 120.0
        )

        XCTAssertEqual(emotion.primaryEmotion, .joy)
        XCTAssertEqual(emotion.emotionIntensity, 0.8)
        XCTAssertEqual(emotion.emotionTrigger, "Player choice")
        XCTAssertEqual(emotion.emotionDuration, 120.0)
    }

    func testEmotionalStateDefaultDuration() {
        let emotion = EmotionalState(
            primaryEmotion: .sadness,
            emotionIntensity: 0.6
        )

        XCTAssertEqual(emotion.emotionDuration, 60.0) // Default
    }

    // MARK: - Test Relationship

    func testRelationshipDefaults() {
        let characterID = UUID()
        let relationship = Relationship(targetCharacterID: characterID)

        XCTAssertEqual(relationship.trust, 0.5)
        XCTAssertEqual(relationship.affection, 0.0)
        XCTAssertEqual(relationship.respect, 0.5)
        XCTAssertTrue(relationship.history.isEmpty)
    }

    func testRelationshipCustomValues() {
        let characterID = UUID()
        let event = RelationshipEvent(
            timestamp: Date(),
            eventDescription: "Helped in battle",
            impactOnTrust: 0.2,
            impactOnAffection: 0.1,
            impactOnRespect: 0.3
        )

        let relationship = Relationship(
            targetCharacterID: characterID,
            trust: 0.7,
            affection: 0.5,
            respect: 0.8,
            history: [event]
        )

        XCTAssertEqual(relationship.trust, 0.7)
        XCTAssertEqual(relationship.affection, 0.5)
        XCTAssertEqual(relationship.respect, 0.8)
        XCTAssertEqual(relationship.history.count, 1)
    }

    // MARK: - Test CharacterModel

    func testCharacterModelCreation() {
        let characterID = UUID()
        let personality = PersonalityTraits(honor: 0.9, ambition: 0.7)
        let emotion = EmotionalState(primaryEmotion: .pride, emotionIntensity: 0.8)

        let character = CharacterModel(
            id: characterID,
            name: "Hamlet",
            role: .protagonist,
            personality: personality,
            emotionalState: emotion,
            backstory: "Prince of Denmark",
            motivations: ["Avenge father", "Seek truth"],
            currentObjectives: [],
            visualAssetID: "hamlet_model",
            costumes: [],
            animations: [],
            dialogueTree: DialogueTree(rootNodeID: UUID(), nodes: []),
            voiceProfile: VoiceProfile(pitch: 1.0, speed: 1.0, accent: "Danish", timbre: "deep"),
            behaviorPatterns: []
        )

        XCTAssertEqual(character.name, "Hamlet")
        XCTAssertEqual(character.role, .protagonist)
        XCTAssertEqual(character.personality.honor, 0.9)
        XCTAssertEqual(character.emotionalState.primaryEmotion, .pride)
        XCTAssertEqual(character.backstory, "Prince of Denmark")
        XCTAssertEqual(character.motivations.count, 2)
    }

    // MARK: - Test Codable Conformance

    func testCharacterModelCodable() throws {
        let character = createTestCharacter()

        // Encode
        let encoder = JSONEncoder()
        let data = try encoder.encode(character)

        // Decode
        let decoder = JSONDecoder()
        let decodedCharacter = try decoder.decode(CharacterModel.self, from: data)

        XCTAssertEqual(character.id, decodedCharacter.id)
        XCTAssertEqual(character.name, decodedCharacter.name)
        XCTAssertEqual(character.role, decodedCharacter.role)
        XCTAssertEqual(character.personality.honor, decodedCharacter.personality.honor)
    }

    func testEmotionCodable() throws {
        let emotion = EmotionalState(
            primaryEmotion: .grief,
            emotionIntensity: 0.9,
            emotionTrigger: "Father's death"
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(emotion)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(EmotionalState.self, from: data)

        XCTAssertEqual(emotion.primaryEmotion, decoded.primaryEmotion)
        XCTAssertEqual(emotion.emotionIntensity, decoded.emotionIntensity)
        XCTAssertEqual(emotion.emotionTrigger, decoded.emotionTrigger)
    }

    // MARK: - Helper Methods

    private func createTestCharacter() -> CharacterModel {
        CharacterModel(
            name: "Test Character",
            role: .supporting,
            personality: PersonalityTraits(),
            emotionalState: EmotionalState(primaryEmotion: .joy, emotionIntensity: 0.5),
            backstory: "Test backstory",
            motivations: ["Test motivation"],
            currentObjectives: [],
            visualAssetID: "test_asset",
            costumes: [],
            animations: [],
            dialogueTree: DialogueTree(rootNodeID: UUID(), nodes: []),
            voiceProfile: VoiceProfile(pitch: 1.0, speed: 1.0, accent: "neutral", timbre: "medium"),
            behaviorPatterns: []
        )
    }
}
