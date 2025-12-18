import Foundation

/// Represents a complete theatrical performance
struct PerformanceData: Codable, Identifiable, Sendable {
    let id: UUID
    let title: String
    let author: String
    let genre: TheaterGenre
    let duration: TimeInterval

    // Content
    let acts: [Act]
    let characters: [CharacterModel]
    let settings: [SettingData]

    // Metadata
    let ageRating: AgeRating
    let culturalContext: CulturalContext
    let educationalObjectives: [LearningObjective]
    let historicalPeriod: HistoricalPeriod?

    // Narrative structure
    let narrativeGraph: NarrativeGraph
    let endings: [EndingData]

    init(
        id: UUID = UUID(),
        title: String,
        author: String,
        genre: TheaterGenre,
        duration: TimeInterval,
        acts: [Act],
        characters: [CharacterModel],
        settings: [SettingData],
        ageRating: AgeRating,
        culturalContext: CulturalContext,
        educationalObjectives: [LearningObjective],
        historicalPeriod: HistoricalPeriod?,
        narrativeGraph: NarrativeGraph,
        endings: [EndingData]
    ) {
        self.id = id
        self.title = title
        self.author = author
        self.genre = genre
        self.duration = duration
        self.acts = acts
        self.characters = characters
        self.settings = settings
        self.ageRating = ageRating
        self.culturalContext = culturalContext
        self.educationalObjectives = educationalObjectives
        self.historicalPeriod = historicalPeriod
        self.narrativeGraph = narrativeGraph
        self.endings = endings
    }
}

// MARK: - Supporting Types

enum TheaterGenre: String, Codable, Sendable {
    case tragedy
    case comedy
    case history
    case romance
    case mystery
    case philosophical
}

struct Act: Codable, Identifiable, Sendable {
    let id: UUID
    let number: Int
    let title: String
    let scenes: [TheaterScene]
}

struct TheaterScene: Codable, Identifiable, Sendable {
    let id: UUID
    let number: Int
    let title: String
    let setting: UUID // Reference to SettingData
    let duration: TimeInterval
}

enum AgeRating: String, Codable, Sendable {
    case everyone = "E"
    case everyone10Plus = "E10+"
    case teen = "T"
    case mature = "M"
}

struct CulturalContext: Codable, Sendable {
    let culture: String
    let timePerio: String
    let geographicLocation: String
    let culturalNotes: String
}

struct LearningObjective: Codable, Identifiable, Sendable {
    let id: UUID
    let category: String
    let description: String
    let assessmentCriteria: [String]
}

enum HistoricalPeriod: String, Codable, Sendable {
    case ancient = "Ancient"
    case medieval = "Medieval"
    case renaissance = "Renaissance"
    case enlightenment = "Enlightenment"
    case victorian = "Victorian"
    case modern = "Modern"
    case contemporary = "Contemporary"
}

struct EndingData: Codable, Identifiable, Sendable {
    let id: UUID
    let title: String
    let description: String
    let requiredChoices: [UUID]
    let narrativeNodeID: UUID
}
