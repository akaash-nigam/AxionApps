import Foundation

/// Represents a historical figure that players can interact with
struct HistoricalCharacter: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let era: HistoricalEra
    let role: String  // e.g., "Pharaoh", "Philosopher", "Scientist"
    let lifespan: String  // e.g., "100 BCE - 44 BCE"

    // Biography
    let shortBiography: String  // 2-3 sentences
    let fullBiography: String   // Detailed life story
    let accomplishments: [String]
    let historicalSignificance: String

    // Personality & Teaching Style
    let personality: CharacterPersonality
    let teachingStyle: TeachingStyle
    let knowledgeDomains: [KnowledgeDomain]
    let specialAbilities: [String]  // What makes them unique

    // Dialogue & Interaction
    let greeting: String
    let farewell: String
    let catchphrases: [String]
    let topicExpertise: [String: ExpertiseLevel]

    // 3D Model & Audio
    let modelResourceName: String
    let portraitImageName: String
    let voiceProfile: VoiceProfile
    let animationSet: [String: String]  // Animation name -> Resource

    // Gameplay
    let initialRelationshipLevel: RelationshipLevel
    let questsOffered: [String]  // Quest IDs
    let artifactsOwned: [String]  // Artifact IDs they can gift
    let mysteryInvolvement: [String: MysteryRole]  // Mystery ID -> Role

    init(id: String,
         name: String,
         era: HistoricalEra,
         role: String,
         lifespan: String,
         shortBiography: String,
         fullBiography: String,
         accomplishments: [String],
         historicalSignificance: String,
         personality: CharacterPersonality,
         teachingStyle: TeachingStyle,
         knowledgeDomains: [KnowledgeDomain],
         specialAbilities: [String] = [],
         greeting: String,
         farewell: String,
         catchphrases: [String] = [],
         topicExpertise: [String: ExpertiseLevel] = [:],
         modelResourceName: String,
         portraitImageName: String,
         voiceProfile: VoiceProfile,
         animationSet: [String: String] = [:],
         initialRelationshipLevel: RelationshipLevel = .stranger,
         questsOffered: [String] = [],
         artifactsOwned: [String] = [],
         mysteryInvolvement: [String: MysteryRole] = [:]) {
        self.id = id
        self.name = name
        self.era = era
        self.role = role
        self.lifespan = lifespan
        self.shortBiography = shortBiography
        self.fullBiography = fullBiography
        self.accomplishments = accomplishments
        self.historicalSignificance = historicalSignificance
        self.personality = personality
        self.teachingStyle = teachingStyle
        self.knowledgeDomains = knowledgeDomains
        self.specialAbilities = specialAbilities
        self.greeting = greeting
        self.farewell = farewell
        self.catchphrases = catchphrases
        self.topicExpertise = topicExpertise
        self.modelResourceName = modelResourceName
        self.portraitImageName = portraitImageName
        self.voiceProfile = voiceProfile
        self.animationSet = animationSet
        self.initialRelationshipLevel = initialRelationshipLevel
        self.questsOffered = questsOffered
        self.artifactsOwned = artifactsOwned
        self.mysteryInvolvement = mysteryInvolvement
    }
}

// MARK: - Supporting Types

/// Personality traits of a character
struct CharacterPersonality: Codable, Hashable {
    let traits: [PersonalityTrait]
    let temperament: Temperament
    let communication: CommunicationStyle

    enum PersonalityTrait: String, Codable {
        case wise, brave, curious, patient, ambitious
        case diplomatic, strategic, creative, analytical
        case compassionate, determined, innovative
    }

    enum Temperament: String, Codable {
        case calm, energetic, serious, playful, contemplative
    }

    enum CommunicationStyle: String, Codable {
        case direct, socratic, storytelling, demonstrative
    }
}

/// How the character teaches
struct TeachingStyle: Codable, Hashable {
    let primary: TeachingMethod
    let ageAdaptation: Bool  // Adapts to student age
    let usesAnalogies: Bool
    let questionFrequency: QuestionFrequency
    let feedbackStyle: FeedbackStyle

    enum TeachingMethod: String, Codable {
        case lecture              // Tells information
        case socraticQuestioning  // Asks questions
        case demonstration        // Shows by doing
        case storytelling         // Uses narratives
        case handson              // Encourages doing
    }

    enum QuestionFrequency: String, Codable {
        case frequent, moderate, rare, never
    }

    enum FeedbackStyle: String, Codable {
        case encouraging, constructive, direct, gentle
    }
}

/// Knowledge domain
struct KnowledgeDomain: Codable, Hashable {
    let name: String
    let description: String
    let topics: [String]

    static let philosophy = KnowledgeDomain(
        name: "Philosophy",
        description: "Questions about existence, knowledge, values, reason, mind, and language",
        topics: ["Ethics", "Logic", "Metaphysics", "Epistemology"]
    )

    static let mathematics = KnowledgeDomain(
        name: "Mathematics",
        description: "Study of numbers, quantity, structure, and patterns",
        topics: ["Geometry", "Arithmetic", "Algebra", "Astronomy"]
    )

    static let governance = KnowledgeDomain(
        name: "Governance",
        description: "Systems of government and leadership",
        topics: ["Democracy", "Republic", "Law", "Diplomacy"]
    )
}

/// Expertise level in a topic
enum ExpertiseLevel: String, Codable {
    case novice
    case intermediate
    case expert
    case master

    var responseDepth: Int {
        switch self {
        case .novice: return 1
        case .intermediate: return 2
        case .expert: return 3
        case .master: return 4
        }
    }
}

/// Voice characteristics
struct VoiceProfile: Codable, Hashable {
    let gender: Gender
    let ageGroup: AgeGroup
    let accent: String  // e.g., "British", "Latin", "Greek"
    let pitch: Pitch
    let pace: Pace
    let emotionalRange: EmotionalRange

    enum Gender: String, Codable {
        case male, female, neutral
    }

    enum AgeGroup: String, Codable {
        case young, adult, elderly
    }

    enum Pitch: String, Codable {
        case low, medium, high
    }

    enum Pace: String, Codable {
        case slow, moderate, fast
    }

    enum EmotionalRange: String, Codable {
        case reserved, moderate, expressive
    }
}

/// Role in a mystery
enum MysteryRole: String, Codable {
    case questGiver       // Gives the mystery
    case witness          // Has information
    case expert           // Provides expertise
    case keeper           // Guards key artifact
    case mentor           // Provides guidance
}

// MARK: - Character Progress

/// Tracks player relationship with a character
struct CharacterProgress: Codable {
    let characterID: String
    var relationshipLevel: RelationshipLevel = .stranger
    var conversationCount: Int = 0
    var topicsDiscussed: Set<String> = []
    var questsCompleted: Set<String> = []
    var giftsReceived: Set<String> = []  // Artifact IDs
    var lastInteractionDate: Date?
    var totalInteractionTime: TimeInterval = 0
    var favoriteTopics: [String: Int] = [:]  // Topic -> times discussed

    var canLevelUp: Bool {
        conversationCount >= relationshipLevel.conversationsRequired
    }

    mutating func recordConversation(topics: [String], duration: TimeInterval) {
        conversationCount += 1
        topicsDiscussed.formUnion(topics)
        totalInteractionTime += duration
        lastInteractionDate = Date()

        for topic in topics {
            favoriteTopics[topic, default: 0] += 1
        }

        // Auto level up if requirements met
        if canLevelUp {
            levelUp()
        }
    }

    mutating func levelUp() {
        switch relationshipLevel {
        case .stranger: relationshipLevel = .acquaintance
        case .acquaintance: relationshipLevel = .friend
        case .friend: relationshipLevel = .confidant
        case .confidant: relationshipLevel = .mentor
        case .mentor: break  // Max level
        }
    }

    mutating func receiveGift(_ artifactID: String) {
        giftsReceived.insert(artifactID)
    }

    mutating func completeQuest(_ questID: String) {
        questsCompleted.insert(questID)
        // Quests significantly boost relationship
        conversationCount += 5
        if canLevelUp {
            levelUp()
        }
    }
}

// MARK: - Sample Characters

extension HistoricalCharacter {
    /// Julius Caesar
    static var juliusCaesar: HistoricalCharacter {
        HistoricalCharacter(
            id: "julius_caesar",
            name: "Julius Caesar",
            era: .ancientRome,
            role: "Roman General and Statesman",
            lifespan: "100 BCE - 44 BCE",
            shortBiography: "Military general who played a critical role in the rise of the Roman Empire. Famous for conquering Gaul and crossing the Rubicon River.",
            fullBiography: "Gaius Julius Caesar was a Roman general, statesman, and notable author who played a critical role in the events that led to the demise of the Roman Republic and the rise of the Roman Empire...",
            accomplishments: [
                "Conquered Gaul (modern France)",
                "Crossed the Rubicon River to march on Rome",
                "Reformed the Roman calendar",
                "Wrote detailed military commentaries"
            ],
            historicalSignificance: "Changed the course of Western civilization by transforming Rome from republic to empire",
            personality: CharacterPersonality(
                traits: [.ambitious, .strategic, .brave, .determined],
                temperament: .serious,
                communication: .direct
            ),
            teachingStyle: TeachingStyle(
                primary: .lecture,
                ageAdaptation: true,
                usesAnalogies: true,
                questionFrequency: .moderate,
                feedbackStyle: .direct
            ),
            knowledgeDomains: [
                .governance,
                KnowledgeDomain(name: "Military Strategy", description: "Tactics and leadership in warfare", topics: ["Tactics", "Logistics", "Leadership"])
            ],
            greeting: "Ave! I am Julius Caesar, general of Rome. What would you like to know about my campaigns?",
            farewell: "Vale! May victory be yours.",
            catchphrases: [
                "Veni, vidi, vici",
                "The die is cast",
                "Et tu, Brute?"
            ],
            topicExpertise: [
                "Military Strategy": .master,
                "Roman Politics": .expert,
                "Governance": .expert
            ],
            modelResourceName: "character_julius_caesar",
            portraitImageName: "portrait_caesar",
            voiceProfile: VoiceProfile(
                gender: .male,
                ageGroup: .adult,
                accent: "Latin",
                pitch: .medium,
                pace: .moderate,
                emotionalRange: .moderate
            ),
            questsOffered: ["conquest_of_gaul", "crossing_rubicon"],
            artifactsOwned: ["caesars_laurel", "roman_sword", "military_maps"]
        )
    }

    /// Cleopatra VII
    static var cleopatra: HistoricalCharacter {
        HistoricalCharacter(
            id: "cleopatra",
            name: "Cleopatra VII",
            era: .ancientEgypt,
            role: "Last Pharaoh of Egypt",
            lifespan: "69 BCE - 30 BCE",
            shortBiography: "Last active pharaoh of Ptolemaic Egypt. Known for her intelligence, political acumen, and relationships with Julius Caesar and Mark Antony.",
            fullBiography: "Cleopatra VII Philopator was the last active ruler of the Ptolemaic Kingdom of Egypt. A member of the Ptolemaic dynasty, she was a descendant of its founder Ptolemy I Soter, a Macedonian Greek general and companion of Alexander the Great...",
            accomplishments: [
                "Spoke multiple languages including Egyptian, Greek, and Latin",
                "Maintained Egypt's independence during Roman expansion",
                "Advanced Egyptian culture and learning",
                "Skilled diplomat and negotiator"
            ],
            historicalSignificance: "Last pharaoh of Egypt who tried to save her kingdom from Roman conquest",
            personality: CharacterPersonality(
                traits: [.intelligent, .diplomatic, .ambitious, .innovative],
                temperament: .contemplative,
                communication: .diplomatic
            ),
            teachingStyle: TeachingStyle(
                primary: .socraticQuestioning,
                ageAdaptation: true,
                usesAnalogies: true,
                questionFrequency: .frequent,
                feedbackStyle: .encouraging
            ),
            knowledgeDomains: [
                .governance,
                KnowledgeDomain(name: "Languages", description: "Study of multiple languages and translation", topics: ["Greek", "Latin", "Egyptian", "Aramaic"]),
                KnowledgeDomain(name: "Diplomacy", description: "Art of international relations", topics: ["Negotiation", "Alliance Building", "Trade"])
            ],
            greeting: "Welcome, traveler. I am Cleopatra, Queen of Egypt. How may I enlighten you about my kingdom?",
            farewell: "May the gods guide your path.",
            catchphrases: [
                "Knowledge is the true crown",
                "Egypt will endure"
            ],
            topicExpertise: [
                "Egyptian History": .master,
                "Diplomacy": .master,
                "Languages": .expert,
                "Trade Routes": .expert
            ],
            modelResourceName: "character_cleopatra",
            portraitImageName: "portrait_cleopatra",
            voiceProfile: VoiceProfile(
                gender: .female,
                ageGroup: .adult,
                accent: "Ptolemaic Egyptian",
                pitch: .medium,
                pace: .moderate,
                emotionalRange: .moderate
            ),
            questsOffered: ["nile_trade", "library_alexandria"],
            artifactsOwned: ["royal_seal", "papyrus_scroll", "golden_necklace"]
        )
    }

    /// Sample character for testing
    static func sample(id: String = "sample_character",
                      era: HistoricalEra = .ancientEgypt,
                      name: String = "Sample Historian") -> HistoricalCharacter {
        HistoricalCharacter(
            id: id,
            name: name,
            era: era,
            role: "Historical Figure",
            lifespan: "Unknown",
            shortBiography: "A sample character for testing.",
            fullBiography: "This is a test character used in development.",
            accomplishments: ["Testing", "Development"],
            historicalSignificance: "Helps verify the game systems work correctly",
            personality: CharacterPersonality(
                traits: [.wise, .patient],
                temperament: .calm,
                communication: .direct
            ),
            teachingStyle: TeachingStyle(
                primary: .lecture,
                ageAdaptation: true,
                usesAnalogies: false,
                questionFrequency: .moderate,
                feedbackStyle: .encouraging
            ),
            knowledgeDomains: [.philosophy],
            greeting: "Greetings!",
            farewell: "Goodbye!",
            modelResourceName: "character_sample",
            portraitImageName: "portrait_sample",
            voiceProfile: VoiceProfile(
                gender: .neutral,
                ageGroup: .adult,
                accent: "Generic",
                pitch: .medium,
                pace: .moderate,
                emotionalRange: .moderate
            )
        )
    }
}
