# Data Models & Schema Design

## Overview

This document defines all data models, database schemas, and persistence structures for Language Immersion Rooms.

## Core Data Models

### User Profile

```swift
struct UserProfile: Codable, Identifiable {
    let id: UUID
    var username: String
    var email: String

    // Learning preferences
    var nativeLanguage: Language
    var targetLanguages: [LanguageProgress]
    var proficiencyLevel: ProficiencyLevel

    // Settings
    var preferences: UserPreferences
    var subscriptionTier: SubscriptionTier
    var subscriptionExpiry: Date?

    // Progress tracking
    var totalStudyTime: TimeInterval
    var currentStreak: Int
    var longestStreak: Int
    var lastActiveDate: Date

    // Metadata
    var createdAt: Date
    var updatedAt: Date
}

enum ProficiencyLevel: String, Codable {
    case beginner = "A1"
    case elementaryIntermediate = "A2"
    case intermediate = "B1"
    case upperIntermediate = "B2"
    case advanced = "C1"
    case proficient = "C2"
}

enum SubscriptionTier: String, Codable {
    case free
    case premium
    case family
}
```

### Language Progress

```swift
struct LanguageProgress: Codable, Identifiable {
    let id: UUID
    let language: Language
    var proficiencyLevel: ProficiencyLevel

    // Vocabulary
    var vocabularyKnown: Int
    var vocabularyReviewing: Int
    var vocabularyMastered: Int

    // Grammar
    var grammarTopicsMastered: [String]
    var grammarTopicsInProgress: [String]

    // Skills
    var listeningScore: Double // 0-100
    var speakingScore: Double
    var readingScore: Double
    var writingScore: Double

    // Time tracking
    var totalStudyTime: TimeInterval
    var conversationTime: TimeInterval
    var pronunciationPracticeTime: TimeInterval

    // Achievements
    var completedLessons: [UUID]
    var earnedBadges: [Badge]

    // SRS (Spaced Repetition)
    var nextReviewDate: Date
    var dueCards: Int

    var updatedAt: Date
}
```

### Language

```swift
struct Language: Codable, Hashable, Identifiable {
    let id: String // ISO 639-1 code (e.g., "es", "fr", "ja")
    let name: String // "Spanish"
    let nativeName: String // "Español"
    let flag: String // Flag emoji

    // Variants
    var hasRegionalVariants: Bool
    var variants: [LanguageVariant]? // e.g., Spain Spanish, Mexican Spanish

    // Support level
    var supportsConversations: Bool
    var supportsObjectLabeling: Bool
    var supportsPronunciation: Bool
    var supportsGrammarAnalysis: Bool

    // Content availability
    var availableEnvironments: [String]
    var availableCharacters: [String]
    var availableScenarios: [String]
}

struct LanguageVariant: Codable, Hashable {
    let id: String // "es-ES", "es-MX"
    let name: String // "Castilian Spanish", "Mexican Spanish"
    let region: String // "Spain", "Mexico"
}
```

### User Preferences

```swift
struct UserPreferences: Codable {
    // Display
    var labelStyle: LabelStyle
    var labelSize: LabelSize
    var showPronunciationGuides: Bool
    var showGrammarCards: Bool

    // Audio
    var speechSpeed: Double // 0.5 - 2.0
    var volume: Double // 0.0 - 1.0
    var voiceGender: VoiceGender?

    // Learning
    var difficultyMode: DifficultyMode
    var correctionTiming: CorrectionTiming
    var dailyGoalMinutes: Int
    var reminderTime: Date?

    // Accessibility
    var highContrastMode: Bool
    var largeFonts: Bool
    var reducedMotion: Bool

    // Privacy
    var allowAnalytics: Bool
    var shareProgressWithFriends: Bool
}

enum LabelStyle: String, Codable {
    case minimal // Word only
    case standard // Word + pronunciation
    case detailed // Word + pronunciation + example
}

enum LabelSize: String, Codable {
    case small, medium, large
}

enum VoiceGender: String, Codable {
    case male, female, neutral
}

enum DifficultyMode: String, Codable {
    case easy // Slow speech, simple grammar
    case normal
    case challenging // Native speed, complex structures
}

enum CorrectionTiming: String, Codable {
    case immediate // Correct as user speaks
    case afterSentence // Wait until sentence complete
    case endOfSession // Review all at end
    case silent // Track but don't show
}
```

### Vocabulary Word

```swift
struct VocabularyWord: Codable, Identifiable {
    let id: UUID
    let word: String
    let language: Language

    // Translation and definition
    var translation: String // In user's native language
    var definition: String?
    var partOfSpeech: PartOfSpeech

    // Context
    var exampleSentences: [String]
    var idiomaticUsages: [String]?
    var synonyms: [String]
    var antonyms: [String]

    // Pronunciation
    var ipa: String // International Phonetic Alphabet
    var audioURL: URL?
    var syllables: [String]

    // Metadata
    var frequency: WordFrequency // How common this word is
    var difficulty: DifficultyLevel
    var category: [VocabularyCategory]

    // Learning data
    var learningState: LearningState
    var addedDate: Date
    var lastReviewedDate: Date?
    var nextReviewDate: Date?
    var reviewCount: Int
    var correctCount: Int
    var incorrectCount: Int
    var easinessFactor: Double // For SRS algorithm (SM-2)
    var interval: Int // Days until next review
}

enum PartOfSpeech: String, Codable {
    case noun, verb, adjective, adverb, pronoun
    case preposition, conjunction, interjection
    case article, determiner
}

enum WordFrequency: String, Codable {
    case veryCommon // Top 1000 words
    case common // Top 5000
    case uncommon // Top 20000
    case rare // Beyond 20000
}

enum VocabularyCategory: String, Codable {
    case home, kitchen, bedroom, bathroom, office
    case food, drinks, restaurant, cooking
    case travel, transportation, hotel
    case business, work, meeting
    case health, medical, body
    case shopping, clothes, colors
    case emotions, personality, relationships
    case nature, weather, animals
    case technology, media
    case education, school
}

enum LearningState: String, Codable {
    case new // Never seen
    case learning // Currently studying
    case reviewing // In SRS queue
    case mastered // Consistently correct
    case difficult // Needs extra practice
}
```

### Grammar Rule

```swift
struct GrammarRule: Codable, Identifiable {
    let id: UUID
    let ruleID: String // Unique identifier (e.g., "es-verb-present-ir")
    let language: Language

    // Rule information
    var title: String // "Present Tense: Ir (to go)"
    var category: GrammarCategory
    var explanation: String
    var difficulty: DifficultyLevel

    // Examples
    var correctExamples: [GrammarExample]
    var incorrectExamples: [GrammarExample]

    // Related rules
    var prerequisiteRules: [String] // Rule IDs
    var relatedRules: [String]

    // Practice
    var exercises: [GrammarExercise]

    // Usage
    var commonMistakes: [String]
    var tips: [String]
}

enum GrammarCategory: String, Codable {
    case verbConjugation
    case nounGender
    case articles
    case pronouns
    case adjectiveAgreement
    case sentenceStructure
    case prepositions
    case negation
    case questions
    case tenses
    case moods
}

struct GrammarExample: Codable {
    let sentence: String
    let translation: String
    let explanation: String?
}

struct GrammarExercise: Codable, Identifiable {
    let id: UUID
    let question: String
    let options: [String]?
    let correctAnswer: String
    let explanation: String
}
```

### Conversation

```swift
struct Conversation: Codable, Identifiable {
    let id: UUID
    let scenarioID: String
    let characterID: String
    let language: Language

    // Metadata
    var startTime: Date
    var endTime: Date?
    var duration: TimeInterval

    // Messages
    var messages: [ConversationMessage]

    // Analysis
    var grammarErrors: [GrammarError]
    var pronunciationFeedback: [PronunciationFeedback]
    var vocabularyUsed: [String]
    var overallScore: Double? // 0-100

    // Learning outcomes
    var newWordsLearned: [String]
    var grammarTopicsPracticed: [String]
}

struct ConversationMessage: Codable, Identifiable {
    let id: UUID
    let sender: MessageSender
    let content: String
    let timestamp: Date
    var audioURL: URL?

    // For user messages
    var transcriptionConfidence: Double?
    var detectedErrors: [GrammarError]?
}

enum MessageSender: String, Codable {
    case user
    case aiCharacter
    case system
}

struct GrammarError: Codable, Identifiable {
    let id: UUID
    let errorType: String
    let incorrectPhrase: String
    let correctPhrase: String
    let ruleID: String
    let explanation: String
    let position: Range<Int>? // Position in text
}

struct PronunciationFeedback: Codable, Identifiable {
    let id: UUID
    let word: String
    let attemptedPronunciation: String // IPA
    let correctPronunciation: String // IPA
    let accuracyScore: Double // 0-100
    let problematicPhonemes: [Phoneme]
    let audioURL: URL?
}

struct Phoneme: Codable {
    let symbol: String // IPA symbol
    let accuracyScore: Double
    let feedback: String
}
```

### Scenario

```swift
struct Scenario: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let language: Language

    // Classification
    var category: ScenarioCategory
    var difficulty: DifficultyLevel
    var duration: TimeInterval // Expected duration

    // Content
    var environmentID: String
    var characterID: String
    var objectives: [LearningObjective]
    var vocabularyFocus: [String]
    var grammarFocus: [String]

    // Script (optional structured conversation)
    var conversationFlow: [ConversationNode]?

    // Cultural elements
    var culturalNotes: [String]
    var etiquetteTips: [String]
}

enum ScenarioCategory: String, Codable {
    case dailyLife, dining, shopping, travel
    case business, professional, interview
    case social, dating, friends
    case medical, emergency
    case education, academic
    case cultural, customs
}

struct LearningObjective: Codable {
    let description: String
    let type: ObjectiveType
}

enum ObjectiveType: String, Codable {
    case vocabulary
    case grammar
    case pronunciation
    case cultural
}

struct ConversationNode: Codable {
    let id: String
    let characterPrompt: String
    let expectedUserResponses: [String]? // Optional guidance
    let nextNodeID: String?
}
```

### AI Character

```swift
struct AICharacter: Codable, Identifiable {
    let id: String
    let name: String
    let language: Language

    // Appearance
    var modelAssetName: String // 3D model reference
    var thumbnailURL: URL

    // Voice
    var voiceID: String // TTS voice identifier
    var accent: String // "Madrid", "Tokyo", "Paris"
    var gender: VoiceGender

    // Personality
    var personalityTraits: [String] // "friendly", "formal", "patient"
    var backstory: String
    var age: String
    var occupation: String

    // Behavior
    var speakingSpeed: Double // Default speed
    var conversationStyle: ConversationStyle
    var difficultyAdjustment: Bool // Adapts to user level

    // Usage
    var availableScenarios: [String]
    var specializations: [String] // "Business", "Casual", "Teaching"
}

enum ConversationStyle: String, Codable {
    case formal
    case casual
    case teacher // More patient, explanatory
    case native // Natural, colloquial
}
```

### Environment

```swift
struct Environment: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let language: Language

    // Assets
    var assetBundleName: String
    var previewImageURL: URL
    var assetSize: Int64 // Bytes

    // Atmosphere
    var ambientSoundURL: URL?
    var backgroundMusicURL: URL?
    var lightingProfile: LightingProfile

    // Interactive elements
    var interactiveObjects: [InteractiveObject]
    var labeledObjects: [String] // Object categories present

    // Cultural context
    var culturalDescription: String
    var regionalInfo: String
    var appropriateScenarios: [String]

    // Technical
    var requiredCapabilities: [String]
    var downloadable: Bool
    var installed: Bool
}

struct InteractiveObject: Codable, Identifiable {
    let id: String
    let name: String
    let position: SIMD3<Float>
    let action: InteractionType
}

enum InteractionType: String, Codable {
    case tap // Show info
    case speak // Voice trigger
    case grab // Hand interaction
}

enum LightingProfile: String, Codable {
    case bright // Daytime, well-lit
    case ambient // Evening, soft light
    case dramatic // Focused lighting
    case natural // Outdoor
}
```

### Spatial Anchor Data

```swift
struct SpatialAnchorData: Codable, Identifiable {
    let id: UUID

    // Anchor information
    var anchorIdentifier: UUID // ARKit anchor ID
    var transform: simd_float4x4

    // Associated content
    var contentType: AnchorContentType
    var contentID: String // Reference to vocabulary, object, etc.

    // Language data
    var language: Language
    var displayText: String
    var audioURL: URL?

    // Persistence
    var worldMapData: Data? // Serialized ARWorldMap
    var roomIdentifier: String // To handle multiple rooms
    var lastSeenDate: Date

    // State
    var isActive: Bool
    var expiresAt: Date?
}

enum AnchorContentType: String, Codable {
    case objectLabel
    case grammarCard
    case culturalNote
    case interactiveProp
}
```

### Achievement & Badge

```swift
struct Badge: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let iconName: String

    var category: BadgeCategory
    var rarity: BadgeRarity

    // Requirements
    var requirement: BadgeRequirement

    // Rewards
    var xpReward: Int
    var unlocksFeature: String?
}

enum BadgeCategory: String, Codable {
    case conversation
    case vocabulary
    case grammar
    case pronunciation
    case streak
    case cultural
    case milestone
}

enum BadgeRarity: String, Codable {
    case common, rare, epic, legendary
}

struct BadgeRequirement: Codable {
    let type: RequirementType
    let target: Int
}

enum RequirementType: String, Codable {
    case conversationCount
    case wordsLearned
    case streakDays
    case studyHours
    case scenariosCompleted
    case perfectPronunciation
}
```

## CoreData Schema

```swift
// Core Data Entities

@objc(UserProfileEntity)
class UserProfileEntity: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var username: String
    @NSManaged var email: String
    @NSManaged var nativeLanguageCode: String
    @NSManaged var currentStreakDays: Int32
    @NSManaged var totalStudyMinutes: Int64
    @NSManaged var subscriptionTier: String
    @NSManaged var createdAt: Date
    @NSManaged var updatedAt: Date

    @NSManaged var languageProgress: Set<LanguageProgressEntity>
    @NSManaged var conversations: Set<ConversationEntity>
    @NSManaged var vocabularyWords: Set<VocabularyWordEntity>
}

@objc(LanguageProgressEntity)
class LanguageProgressEntity: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var languageCode: String
    @NSManaged var proficiencyLevel: String
    @NSManaged var vocabularyKnown: Int32
    @NSManaged var listeningScore: Double
    @NSManaged var speakingScore: Double
    @NSManaged var totalStudyMinutes: Int64
    @NSManaged var nextReviewDate: Date

    @NSManaged var userProfile: UserProfileEntity
}

@objc(VocabularyWordEntity)
class VocabularyWordEntity: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var word: String
    @NSManaged var translation: String
    @NSManaged var languageCode: String
    @NSManaged var partOfSpeech: String
    @NSManaged var ipa: String
    @NSManaged var learningState: String
    @NSManaged var easinessFactor: Double
    @NSManaged var interval: Int32
    @NSManaged var nextReviewDate: Date?
    @NSManaged var correctCount: Int32
    @NSManaged var incorrectCount: Int32

    @NSManaged var userProfile: UserProfileEntity
}

@objc(ConversationEntity)
class ConversationEntity: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var scenarioID: String
    @NSManaged var characterID: String
    @NSManaged var languageCode: String
    @NSManaged var startTime: Date
    @NSManaged var endTime: Date?
    @NSManaged var durationSeconds: Double
    @NSManaged var messagesData: Data // JSON serialized
    @NSManaged var overallScore: Double

    @NSManaged var userProfile: UserProfileEntity
}

@objc(SpatialAnchorEntity)
class SpatialAnchorEntity: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var anchorIdentifier: UUID
    @NSManaged var transformData: Data
    @NSManaged var contentType: String
    @NSManaged var contentID: String
    @NSManaged var languageCode: String
    @NSManaged var displayText: String
    @NSManaged var roomIdentifier: String
    @NSManaged var lastSeenDate: Date
    @NSManaged var isActive: Bool
}
```

## CloudKit Schema

```swift
// CloudKit Record Types

// CKRecord: UserProfile
// - recordName: user_<UUID>
// - fields: username, email, nativeLanguage, subscriptionTier, totalStudyTime

// CKRecord: LanguageProgress
// - recordName: progress_<UUID>
// - reference: userProfile
// - fields: languageCode, vocabularyCount, scores, studyTime

// CKRecord: ConversationHistory
// - recordName: conversation_<UUID>
// - reference: userProfile
// - fields: scenarioID, characterID, duration, score, messagesJSON

// Sync Strategy:
// - UserDefaults for app preferences (not synced)
// - CoreData for local learning data
// - CloudKit for cross-device sync
// - Conflict resolution: last-write-wins for most fields
// - Additive merge for vocabulary lists and achievements
```

## JSON Examples

### API Response: Translation

```json
{
  "word": "table",
  "language": "es",
  "translation": "mesa",
  "ipa": "/ˈme.sa/",
  "gender": "feminine",
  "article": "la",
  "examples": [
    {
      "spanish": "La mesa es roja.",
      "english": "The table is red."
    }
  ],
  "frequency": "veryCommon",
  "synonyms": [],
  "category": ["home", "furniture"]
}
```

### API Response: Grammar Check

```json
{
  "inputText": "Yo va al parque",
  "errors": [
    {
      "errorType": "verbConjugation",
      "position": { "start": 3, "end": 5 },
      "incorrect": "va",
      "correct": "voy",
      "ruleID": "es-verb-present-ir",
      "explanation": "First person singular of 'ir' is 'voy', not 'va'.",
      "severity": "high"
    }
  ],
  "correctedText": "Yo voy al parque"
}
```

## Data Validation Rules

- Email: Valid RFC 5322 format
- Username: 3-20 characters, alphanumeric + underscore
- Language codes: ISO 639-1 (2-letter) or ISO 639-3 (3-letter)
- Dates: ISO 8601 format
- Audio URLs: HTTPS only, supported formats: .mp3, .m4a, .wav
- Scores: 0.0 - 100.0
- SRS intervals: 1 - 365 days
- Study time: non-negative integers (seconds)

## Migrations

- Version 1.0: Initial schema
- Version 1.1: Add pronunciation feedback fields
- Version 1.2: Add regional language variants
- Version 2.0: CloudKit sync support

All migrations handled via CoreData lightweight migration where possible, custom migration for complex changes.
