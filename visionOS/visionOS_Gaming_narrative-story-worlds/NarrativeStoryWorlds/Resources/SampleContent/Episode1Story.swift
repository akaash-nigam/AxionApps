import Foundation

/// Sample story content for Episode 1: "The Visitor"
struct Episode1Story {

    static func createEpisode() -> Story {
        let mainCharacter = createSarahCharacter()

        let chapter1 = createChapter1(characterID: mainCharacter.id)
        let chapter2 = createChapter2(characterID: mainCharacter.id)

        return Story(
            id: UUID(),
            title: "Episode 1: The Visitor",
            genre: .mystery,
            estimatedDuration: 3600, // 60 minutes
            chapters: [chapter1, chapter2],
            characters: [mainCharacter],
            branches: [],
            achievements: createAchievements()
        )
    }

    // MARK: - Characters

    static func createSarahCharacter() -> Character {
        return Character(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            name: "Sarah",
            bio: "A mysterious woman who appears in your living room one evening, claiming to have an urgent message from your past.",
            appearance: CharacterAppearance(
                modelName: "sarah_model",
                texturePaths: [
                    "base": "sarah_base",
                    "normal": "sarah_normal"
                ],
                clothingLayers: ["casual_outfit"]
            ),
            personality: Personality(
                openness: 0.8,
                conscientiousness: 0.7,
                extraversion: 0.5,
                agreeableness: 0.9,
                neuroticism: 0.6,
                loyalty: 0.9,
                deception: 0.1,
                vulnerability: 0.7
            ),
            emotionalState: EmotionalState(
                currentEmotion: .mysterious,
                intensity: 0.6,
                trust: 0.5,
                stress: 0.4,
                attraction: 0.0,
                fear: 0.3,
                history: []
            ),
            narrativeRole: .mysterious,
            relationshipWithPlayer: Relationship(
                characterID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                trustLevel: 0.5,
                bondLevel: .stranger
            ),
            storyFlags: []
        )
    }

    // MARK: - Chapter 1: First Contact

    static func createChapter1(characterID: UUID) -> Chapter {
        let introScene = createIntroScene(characterID: characterID)
        let conversationScene = createConversationScene(characterID: characterID)

        return Chapter(
            id: UUID(),
            title: "Chapter 1: First Contact",
            scenes: [introScene, conversationScene],
            completionState: .notStarted
        )
    }

    static func createIntroScene(characterID: UUID) -> Scene {
        let dialogueNode1 = DialogueNode(
            id: UUID(uuidString: "10000000-0000-0000-0000-000000000001")!,
            speakerID: characterID,
            text: "Please, don't be alarmed. I know this is... unexpected.",
            audioClip: "sarah_intro_01",
            responses: [],
            conditions: [],
            displayDuration: 4.0,
            autoAdvance: true,
            emotionalTone: .neutral,
            facialAnimation: "calm_concern"
        )

        let dialogueNode2 = DialogueNode(
            id: UUID(uuidString: "10000000-0000-0000-0000-000000000002")!,
            speakerID: characterID,
            text: "My name is Sarah. We haven't met before, but... I need your help.",
            audioClip: "sarah_intro_02",
            responses: [],
            conditions: [],
            displayDuration: 4.0,
            autoAdvance: true,
            emotionalTone: .mysterious,
            facialAnimation: "slight_worry"
        )

        let beat1 = StoryBeat(
            id: UUID(),
            type: .dialogue,
            content: AnyBeatContent(dialogueNode1),
            emotionalWeight: 0.3,
            pacing: .slow
        )

        let beat2 = StoryBeat(
            id: UUID(),
            type: .dialogue,
            content: AnyBeatContent(dialogueNode2),
            emotionalWeight: 0.4,
            pacing: .normal
        )

        return Scene(
            id: UUID(),
            location: .playerHome,
            characterIDs: [characterID],
            storyBeats: [beat1, beat2],
            requiredFlags: [],
            spatialConfiguration: SpatialConfiguration(
                characterPositions: [
                    characterID: SpatialConfiguration.Position(x: 0, y: 0, z: -2)
                ]
            )
        )
    }

    static func createConversationScene(characterID: UUID) -> Scene {
        let choice1 = Choice(
            id: UUID(uuidString: "20000000-0000-0000-0000-000000000001")!,
            prompt: "How do you respond to Sarah's sudden appearance?",
            options: [
                ChoiceOption(
                    id: UUID(),
                    text: "I'm listening. What do you need?",
                    icon: "ear",
                    storyBranchID: nil,
                    relationshipImpacts: [characterID: 0.1],
                    flagsSet: ["sarah_trusting"],
                    emotionalTone: .neutral,
                    spatialPosition: .left,
                    visualStyle: .positive
                ),
                ChoiceOption(
                    id: UUID(),
                    text: "Who are you really? How did you get in here?",
                    icon: "questionmark.circle",
                    storyBranchID: nil,
                    relationshipImpacts: [characterID: -0.05],
                    flagsSet: ["sarah_suspicious"],
                    emotionalTone: .neutral,
                    spatialPosition: .center,
                    visualStyle: .neutral
                ),
                ChoiceOption(
                    id: UUID(),
                    text: "You need to leave. Now.",
                    icon: "xmark.circle",
                    storyBranchID: nil,
                    relationshipImpacts: [characterID: -0.2],
                    flagsSet: ["sarah_hostile"],
                    emotionalTone: .angry,
                    spatialPosition: .right,
                    visualStyle: .negative
                )
            ],
            timeLimit: nil,
            emotionalContext: .tense
        )

        let beat = StoryBeat(
            id: UUID(),
            type: .choice,
            content: AnyBeatContent(choice1),
            emotionalWeight: 0.6,
            pacing: .normal
        )

        return Scene(
            id: UUID(),
            location: .playerHome,
            characterIDs: [characterID],
            storyBeats: [beat],
            requiredFlags: [],
            spatialConfiguration: SpatialConfiguration(
                characterPositions: [
                    characterID: SpatialConfiguration.Position(x: 0, y: 0, z: -1.5)
                ]
            )
        )
    }

    // MARK: - Chapter 2: The Revelation

    static func createChapter2(characterID: UUID) -> Chapter {
        // Placeholder for Chapter 2
        return Chapter(
            id: UUID(),
            title: "Chapter 2: The Revelation",
            scenes: [],
            completionState: .notStarted
        )
    }

    // MARK: - Achievements

    static func createAchievements() -> [Achievement] {
        return [
            Achievement(
                id: UUID(),
                title: "First Contact",
                description: "Met Sarah for the first time",
                icon: "person.circle",
                condition: .completeChapter(1)
            ),
            Achievement(
                id: UUID(),
                title: "Building Trust",
                description: "Gained Sarah's trust",
                icon: "heart.fill",
                condition: .reachBondLevel(.friend)
            ),
            Achievement(
                id: UUID(),
                title: "The Truth Seeker",
                description: "Asked all the right questions",
                icon: "magnifyingglass",
                condition: .discoverSecret("sarahs_past")
            )
        ]
    }
}
