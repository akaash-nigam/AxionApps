# State Management Design

## Architecture

Language Immersion Rooms uses Swift's `Observation` framework (iOS 17+) for reactive state management, combined with Combine for async streams.

## App-Level State

### AppState

```swift
import Observation
import SwiftUI

@Observable
class AppState {
    // User session
    var currentUser: UserProfile?
    var isAuthenticated: Bool = false

    // Learning state
    var currentLanguage: Language
    var targetLanguages: [Language]
    var activeSession: LearningSession?

    // UI state
    var selectedTab: Tab = .home
    var showingSettings: Bool = false
    var showingProgress: Bool = false

    // Session metrics
    var todayProgress: Double = 0.0
    var currentStreak: Int = 0

    // Preferences
    var preferences: UserPreferences = .default

    init() {
        self.currentLanguage = .spanish
        self.targetLanguages = []
        loadUser()
    }

    func loadUser() {
        // Load from persistence
        if let savedUser = UserDefaults.standard.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(UserProfile.self, from: savedUser) {
            self.currentUser = user
            self.isAuthenticated = true
        }
    }

    func startLearningSession() {
        activeSession = LearningSession(language: currentLanguage)
    }

    func endLearningSession() {
        guard let session = activeSession else { return }
        // Save session data
        saveSession(session)
        activeSession = nil
    }
}

enum Tab {
    case home, learn, progress, settings
}
```

## Scene-Level State

### SceneManager

```swift
@Observable
class SceneManager {
    // Scene state
    var isSceneLoaded: Bool = false
    var currentEnvironment: Environment?
    var currentCharacter: AICharacter?

    // Object labeling
    var detectedObjects: [DetectedObject] = []
    var activeLabels: [ObjectLabelEntity] = []
    var showLabels: Bool = true
    var labelMode: LabelMode = .standard

    // Conversation
    var conversationHistory: [ConversationMessage] = []
    var isInConversation: Bool = false
    var isListening: Bool = false
    var lastMessage: String = ""

    // Grammar
    var currentGrammarCard: GrammarCard?
    var showGrammar: Bool = true
    var grammarErrors: [GrammarError] = []

    // Services
    private let aiService: AIServiceProtocol
    private let languageService: LanguageServiceProtocol
    private let speechService: SpeechServiceProtocol

    init(
        aiService: AIServiceProtocol,
        languageService: LanguageServiceProtocol,
        speechService: SpeechServiceProtocol
    ) {
        self.aiService = aiService
        self.languageService = languageService
        self.speechService = speechService
    }

    // MARK: - Scene Setup

    func setupScene(content: RealityViewContent) async {
        // Initialize RealityKit scene
        await loadEnvironment()
        await spawnCharacter()
        isSceneLoaded = true
    }

    func updateScene(content: RealityViewContent) {
        // Update based on state changes
        if showLabels {
            displayLabels(in: content)
        } else {
            hideLabels(in: content)
        }
    }

    // MARK: - Object Labeling

    func startObjectDetection() async {
        // Detect objects and create labels
        let objects = await detectObjectsInScene()
        await MainActor.run {
            self.detectedObjects = objects
        }
    }

    private func detectObjectsInScene() async -> [DetectedObject] {
        // ARKit + Core ML object detection
        return []
    }

    // MARK: - Conversation

    func startConversation(with character: AICharacter) async {
        currentCharacter = character
        isInConversation = true

        // Character greeting
        let greeting = await aiService.generateGreeting(character: character)
        await addMessage(greeting, from: .aiCharacter)
    }

    func startListening() {
        isListening = true
        speechService.startRecording { [weak self] transcription in
            Task {
                await self?.processUserSpeech(transcription)
            }
        }
    }

    func stopListening() {
        isListening = false
        speechService.stopRecording()
    }

    private func processUserSpeech(_ text: String) async {
        // Add user message
        await addMessage(text, from: .user)

        // Check grammar
        let errors = await checkGrammar(text)
        if !errors.isEmpty {
            await MainActor.run {
                self.grammarErrors = errors
                self.currentGrammarCard = GrammarCard(error: errors.first!)
            }
        }

        // Get AI response
        let response = await aiService.generateResponse(
            to: text,
            context: conversationHistory
        )
        await addMessage(response, from: .aiCharacter)
    }

    private func addMessage(_ text: String, from sender: MessageSender) async {
        let message = ConversationMessage(
            id: UUID(),
            sender: sender,
            content: text,
            timestamp: Date()
        )

        await MainActor.run {
            self.conversationHistory.append(message)
            self.lastMessage = text
        }
    }

    private func checkGrammar(_ text: String) async -> [GrammarError] {
        // Grammar analysis
        return []
    }
}
```

## Feature-Specific State

### ConversationState

```swift
@Observable
class ConversationState {
    var scenario: Scenario?
    var character: AICharacter?
    var messages: [ConversationMessage] = []
    var isActive: Bool = false
    var userIsTyping: Bool = false

    // Real-time transcription
    var partialTranscription: String = ""
    var finalTranscription: String = ""

    // Feedback
    var pronunciationScore: Double?
    var grammarScore: Double?
}
```

### PronunciationState

```swift
@Observable
class PronunciationState {
    var targetWord: String = ""
    var userAttempts: [PronunciationAttempt] = []
    var currentFeedback: PronunciationFeedback?

    var isRecording: Bool = false
    var showWaveform: Bool = true
    var showMouthGuide: Bool = true

    struct PronunciationAttempt {
        let timestamp: Date
        let audioURL: URL
        let score: Double
        let feedback: String
    }
}
```

### ProgressState

```swift
@Observable
class ProgressState {
    var languageProgress: [LanguageProgress] = []
    var recentSessions: [LearningSession] = []
    var statistics: LearningStatistics

    var selectedTimeRange: TimeRange = .week
    var selectedLanguage: Language?

    enum TimeRange {
        case week, month, year, allTime
    }
}
```

## Persistence

### State Persistence

```swift
class StatePersistence {
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    // Save state to UserDefaults
    func saveState<T: Codable>(_ state: T, key: String) {
        if let data = try? encoder.encode(state) {
            UserDefaults.standard.set(data, key: key)
        }
    }

    // Load state from UserDefaults
    func loadState<T: Codable>(key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return nil
        }
        return try? decoder.decode(T.self, from: data)
    }

    // Save to CoreData
    func saveToDatabase(_ session: LearningSession) {
        let context = PersistenceController.shared.container.viewContext

        let entity = LearningSessionEntity(context: context)
        entity.id = session.id
        entity.startTime = session.startTime
        entity.endTime = session.endTime
        entity.language = session.language.id

        try? context.save()
    }
}
```

## State Synchronization

### CloudKit Sync

```swift
import CloudKit

class CloudSyncManager {
    private let container = CKContainer.default()
    private let database: CKDatabase

    init() {
        self.database = container.privateCloudDatabase
    }

    func syncProgress(_ progress: LanguageProgress) async throws {
        let record = CKRecord(recordType: "LanguageProgress")
        record["languageCode"] = progress.language.id
        record["vocabularyKnown"] = progress.vocabularyKnown
        record["totalStudyTime"] = progress.totalStudyTime
        record["updatedAt"] = progress.updatedAt

        try await database.save(record)
    }

    func fetchProgress() async throws -> [LanguageProgress] {
        let query = CKQuery(recordType: "LanguageProgress", predicate: NSPredicate(value: true))
        let results = try await database.records(matching: query)

        return results.matchResults.compactMap { try? $0.1.get() }
            .compactMap { record in
                // Convert CKRecord to LanguageProgress
                return nil // Implement conversion
            }
    }
}
```

## State Restoration

### Scene State Restoration

```swift
class SceneStateRestoration {
    func saveSceneState(_ manager: SceneManager) {
        let state = SceneState(
            environmentID: manager.currentEnvironment?.id,
            characterID: manager.currentCharacter?.id,
            labelMode: manager.labelMode,
            showLabels: manager.showLabels
        )

        StatePersistence().saveState(state, key: "lastSceneState")
    }

    func restoreSceneState() -> SceneState? {
        return StatePersistence().loadState(key: "lastSceneState")
    }
}

struct SceneState: Codable {
    let environmentID: String?
    let characterID: String?
    let labelMode: LabelMode
    let showLabels: Bool
}
```

## Memory Management

### State Cleanup

```swift
extension SceneManager {
    func cleanup() {
        // Clear large objects
        activeLabels.removeAll()
        detectedObjects.removeAll()
        conversationHistory.removeAll(keepingCapacity: false)

        // Cancel ongoing tasks
        // Release resources
    }
}
```

## Testing State

### State Mocking

```swift
extension AppState {
    static var preview: AppState {
        let state = AppState()
        state.currentUser = UserProfile.mock
        state.isAuthenticated = true
        state.currentStreak = 7
        state.todayProgress = 0.65
        return state
    }
}

extension SceneManager {
    static var preview: SceneManager {
        let manager = SceneManager(
            aiService: MockAIService(),
            languageService: MockLanguageService(),
            speechService: MockSpeechService()
        )
        manager.isSceneLoaded = true
        manager.showLabels = true
        return manager
    }
}
```
