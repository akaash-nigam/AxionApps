//
//  SceneManager.swift
//  Language Immersion Rooms
//
//  Manages RealityKit scene state and interactions
//

import Foundation
import RealityKit
import Observation

@Observable
class SceneManager {
    // MARK: - Scene State
    var isSceneLoaded: Bool = false
    var isScanning: Bool = false

    // MARK: - Object Labeling
    var detectedObjects: [DetectedObject] = []
    var activeLabels: [UUID: Entity] = []
    var showLabels: Bool = true

    // MARK: - Conversation
    var isInConversation: Bool = false
    var isListening: Bool = false
    var conversationHistory: [ConversationMessage] = []
    var lastMessage: String = ""
    var currentCharacter: AICharacter?

    // MARK: - Grammar
    var currentGrammarCard: GrammarError?
    var showGrammar: Bool = true

    // MARK: - Services
    private let objectDetector: ObjectDetectionService
    private let vocabularyService: VocabularyService
    private let conversationService: ConversationService
    private let speechService: SpeechService

    // MARK: - Scene Coordinator
    private var sceneCoordinator: SceneCoordinator?

    init() {
        // Initialize services
        self.objectDetector = ObjectDetectionService()
        self.vocabularyService = VocabularyService()
        self.conversationService = ConversationService()
        self.speechService = SpeechService()

        print("🎬 SceneManager initialized")
    }

    // MARK: - Scene Setup

    @MainActor
    func setupScene(content: RealityViewContent) async {
        print("🔧 Setting up scene...")

        // Initialize scene coordinator
        sceneCoordinator = SceneCoordinator(vocabularyService: vocabularyService)
        await sceneCoordinator?.setupScene(content: content)

        // Load Maria character (MVP: single character)
        currentCharacter = AICharacter.maria

        // Add character to scene
        if let character = currentCharacter {
            sceneCoordinator?.addCharacter(character)
        }

        isSceneLoaded = true
        print("✅ Scene ready")
    }

    func cleanup() {
        sceneCoordinator?.cleanup()
        sceneCoordinator = nil
        detectedObjects.removeAll()
        conversationHistory.removeAll()
        isSceneLoaded = false
        print("🧹 Scene cleaned up")
    }

    // MARK: - Object Detection & Labeling

    func startObjectDetection() async {
        print("🔍 Starting object detection...")
        isScanning = true

        do {
            // Detect objects in scene
            let objects = try await objectDetector.detectObjects()
            await MainActor.run {
                self.detectedObjects = objects
                print("✅ Detected \(objects.count) objects")
            }

            // Create labels for detected objects using scene coordinator
            await createLabelsForObjects(objects)

        } catch {
            print("❌ Object detection error: \(error)")
        }

        isScanning = false
    }

    @MainActor
    private func createLabelsForObjects(_ objects: [DetectedObject]) async {
        guard let coordinator = sceneCoordinator else {
            print("❌ No scene coordinator")
            return
        }

        // Create labels in the scene
        await coordinator.createLabels(for: objects)
        print("✅ Labels created in scene")
    }

    func toggleLabels() {
        showLabels.toggle()
        sceneCoordinator?.toggleLabelsVisibility(visible: showLabels)
        print("🏷️ Labels: \(showLabels ? "visible" : "hidden")")
    }

    @MainActor
    func handleLabelTap(on entity: Entity) {
        guard let coordinator = sceneCoordinator else { return }

        // Get tapped word
        if let word = coordinator.handleTap(on: entity) {
            // Play pronunciation
            playPronunciation(for: word.word)
        }
    }

    func playPronunciation(for word: String) {
        Task {
            await speechService.playPronunciation(word: word, language: .spanish)
        }
    }

    // MARK: - Conversation

    func startConversation() async {
        guard let character = currentCharacter else { return }

        print("💬 Starting conversation with \(character.name)...")
        isInConversation = true

        // Get greeting from AI
        do {
            let greeting = try await conversationService.generateGreeting(character: character)
            await addMessage(greeting, from: .aiCharacter)

            // Speak greeting
            await speechService.speak(greeting, voice: character.voiceID)

        } catch {
            print("❌ Conversation start error: \(error)")
        }
    }

    func endConversation() {
        isInConversation = false
        isListening = false
        print("👋 Conversation ended. Messages: \(conversationHistory.count)")
    }

    func startListening() {
        guard isInConversation else { return }

        isListening = true
        print("🎤 Listening...")

        Task {
            do {
                let transcription = try await speechService.startRecognition(language: .spanish)
                await processUserSpeech(transcription)
            } catch {
                print("❌ Speech recognition error: \(error)")
                await MainActor.run {
                    self.isListening = false
                }
            }
        }
    }

    func stopListening() {
        isListening = false
        speechService.stopRecognition()
        print("🎤 Stopped listening")
    }

    private func processUserSpeech(_ text: String) async {
        guard !text.isEmpty else { return }

        print("💭 User said: \(text)")

        // Add user message
        await addMessage(text, from: .user)

        // Check for grammar errors (basic)
        let errors = await conversationService.checkGrammar(text, language: .spanish)
        if let firstError = errors.first {
            await MainActor.run {
                self.currentGrammarCard = firstError
            }
        }

        // Get AI response
        do {
            let response = try await conversationService.generateResponse(
                to: text,
                history: conversationHistory,
                character: currentCharacter!
            )

            await addMessage(response, from: .aiCharacter)

            // Speak response
            await speechService.speak(response, voice: currentCharacter!.voiceID)

        } catch {
            print("❌ AI response error: \(error)")
        }

        await MainActor.run {
            self.isListening = false
        }
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

    func dismissGrammarCard() {
        currentGrammarCard = nil
    }
}

// MARK: - Supporting Types

enum MessageSender {
    case user
    case aiCharacter
    case system
}
