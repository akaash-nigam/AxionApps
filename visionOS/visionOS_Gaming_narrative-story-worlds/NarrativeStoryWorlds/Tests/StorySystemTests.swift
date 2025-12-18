import XCTest
@testable import NarrativeStoryWorlds

/// Test suite for story systems
final class StorySystemTests: XCTestCase {

    // MARK: - Dialogue System Tests

    func testDialogueNodeCreation() {
        let dialogueNode = DialogueNode(
            id: UUID(),
            speakerID: UUID(),
            text: "Test dialogue",
            audioClip: nil,
            responses: [],
            conditions: [],
            displayDuration: 5.0,
            autoAdvance: false,
            emotionalTone: .neutral,
            facialAnimation: nil
        )

        XCTAssertEqual(dialogueNode.text, "Test dialogue")
        XCTAssertEqual(dialogueNode.emotionalTone, .neutral)
        XCTAssertFalse(dialogueNode.autoAdvance)
    }

    // MARK: - Choice System Tests

    func testChoiceCreation() {
        let characterID = UUID()
        let option1 = ChoiceOption(
            id: UUID(),
            text: "Option 1",
            icon: nil,
            storyBranchID: nil,
            relationshipImpacts: [characterID: 0.1],
            flagsSet: [],
            emotionalTone: .happy,
            spatialPosition: .left,
            visualStyle: .positive
        )

        XCTAssertEqual(option1.text, "Option 1")
        XCTAssertEqual(option1.relationshipImpacts[characterID], 0.1)
        XCTAssertEqual(option1.emotionalTone, .happy)
    }

    func testRelationshipImpact() {
        let characterID = UUID()
        let option = ChoiceOption(
            id: UUID(),
            text: "Be kind",
            icon: nil,
            storyBranchID: nil,
            relationshipImpacts: [characterID: 0.2],
            flagsSet: [],
            emotionalTone: .happy,
            spatialPosition: .center,
            visualStyle: .positive
        )

        XCTAssertEqual(option.relationshipImpacts[characterID], 0.2)
    }

    // MARK: - Character AI Tests

    func testPersonalityTraits() {
        let personality = Personality(
            openness: 0.8,
            conscientiousness: 0.7,
            extraversion: 0.6,
            agreeableness: 0.9,
            neuroticism: 0.4,
            loyalty: 0.8,
            deception: 0.2,
            vulnerability: 0.6
        )

        XCTAssertEqual(personality.openness, 0.8)
        XCTAssertEqual(personality.conscientiousness, 0.7)
        XCTAssertEqual(personality.agreeableness, 0.9)
    }

    func testEmotionalStateTracking() {
        var emotionalState = EmotionalState(
            currentEmotion: .neutral,
            intensity: 0.5,
            trust: 0.5,
            stress: 0.3,
            attraction: 0.0,
            fear: 0.2,
            history: []
        )

        // Simulate trust increase
        emotionalState.trust = min(1.0, emotionalState.trust + 0.2)
        XCTAssertEqual(emotionalState.trust, 0.7)

        // Simulate stress increase
        emotionalState.stress = min(1.0, emotionalState.stress + 0.3)
        XCTAssertEqual(emotionalState.stress, 0.6)
    }

    // MARK: - Story State Tests

    func testStoryStateInitialization() {
        let storyState = StoryState()

        XCTAssertNil(storyState.currentStoryID)
        XCTAssertEqual(storyState.playTime, 0)
        XCTAssertTrue(storyState.completedScenes.isEmpty)
        XCTAssertTrue(storyState.activeFlags.isEmpty)
    }

    func testFlagManagement() {
        var storyState = StoryState()

        // Add flags
        storyState.activeFlags.insert("met_sarah")
        storyState.activeFlags.insert("discovered_secret")

        XCTAssertTrue(storyState.activeFlags.contains("met_sarah"))
        XCTAssertTrue(storyState.activeFlags.contains("discovered_secret"))
        XCTAssertEqual(storyState.activeFlags.count, 2)
    }

    // MARK: - Relationship Tests

    func testRelationshipProgression() {
        var relationship = Relationship(
            characterID: UUID(),
            trustLevel: 0.5,
            bondLevel: .stranger
        )

        // Increase trust
        relationship.trustLevel = 0.7

        // Update bond level based on trust
        if relationship.trustLevel >= 0.6 {
            relationship.bondLevel = .friend
        }

        XCTAssertEqual(relationship.bondLevel, .friend)
    }

    // MARK: - Performance Tests

    func testPerformanceMetrics() {
        let metrics = PerformanceMetrics(
            fps: 90.0,
            averageFrameTime: 1.0 / 90.0,
            qualityLevel: .high,
            thermalState: .nominal
        )

        XCTAssertTrue(metrics.isPerformingWell)
        XCTAssertEqual(metrics.fps, 90.0)
        XCTAssertEqual(metrics.qualityLevel, .high)
    }
}
