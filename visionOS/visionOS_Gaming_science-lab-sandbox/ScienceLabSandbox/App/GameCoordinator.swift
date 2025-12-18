//
//  GameCoordinator.swift
//  Science Lab Sandbox
//
//  Central coordinator managing all game systems and state
//

import Foundation
import Combine
import RealityKit
import QuartzCore

@MainActor
class GameCoordinator: ObservableObject {

    // MARK: - Published Properties

    @Published var gameState: GameState = .initializing
    @Published var currentExperiment: ExperimentSession?
    @Published var playerProgress: PlayerProgress

    // MARK: - System Managers

    let gameStateManager: GameStateManager
    let experimentManager: ExperimentManager
    let physicsManager: PhysicsManager
    let audioManager: SpatialAudioManager
    let inputManager: InputManager
    let aiTutorSystem: AITutorSystem
    let saveManager: SaveManager

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()
    private var lastUpdateTime: TimeInterval = 0
    private let targetFrameTime: TimeInterval = 1.0 / 90.0  // 90 FPS

    // MARK: - Initialization

    init() {
        // Initialize player progress
        self.playerProgress = PlayerProgress()

        // Initialize system managers
        self.gameStateManager = GameStateManager()
        self.experimentManager = ExperimentManager()
        self.physicsManager = PhysicsManager()
        self.audioManager = SpatialAudioManager()
        self.inputManager = InputManager()
        self.aiTutorSystem = AITutorSystem()
        self.saveManager = SaveManager()

        // Load saved progress
        Task {
            await loadProgress()
        }

        setupObservers()
    }

    // MARK: - Game Loop

    func update(deltaTime: TimeInterval) {
        // Ensure we don't update too fast
        let currentTime = CACurrentMediaTime()
        guard currentTime - lastUpdateTime >= targetFrameTime else { return }

        lastUpdateTime = currentTime

        // Update all systems in order
        inputManager.processInput()
        experimentManager.update(deltaTime: deltaTime)
        physicsManager.update(deltaTime: deltaTime)
        aiTutorSystem.update(deltaTime: deltaTime)
        audioManager.update(deltaTime: deltaTime)

        // Update game state
        gameStateManager.update(deltaTime: deltaTime)
    }

    // MARK: - Experiment Management

    func startExperiment(_ experiment: Experiment) async throws {
        guard gameState == .laboratorySelection || gameState == .mainMenu else {
            throw GameError.invalidState
        }

        // Create new experiment session
        let session = ExperimentSession(
            id: UUID(),
            experimentID: experiment.id,
            startTime: Date()
        )

        currentExperiment = session

        // Transition to active experiment state
        gameStateManager.transition(to: .experimentSetup)

        // Initialize experiment
        try await experimentManager.setupExperiment(experiment)

        // Transition to active
        gameStateManager.transition(to: .activeExperiment)

        // Notify AI tutor
        aiTutorSystem.startExperimentGuidance(experiment, session: session)

        // Play experiment start audio
        audioManager.playSound(.experimentStart)
    }

    func completeExperiment(conclusion: String?) async {
        guard let session = currentExperiment else { return }

        // Finalize session
        var finalSession = session
        finalSession.endTime = Date()
        finalSession.conclusion = conclusion

        // Save session
        try? await saveManager.saveExperiment(finalSession)

        // Update progress
        playerProgress.completedExperiments.insert(session.experimentID)

        // Calculate and award XP
        let xp = calculateExperimentXP(session: finalSession)
        playerProgress.addExperience(xp)

        // Check for achievements
        checkAndAwardAchievements()

        // Save progress
        try? await saveManager.saveProgress(playerProgress)

        // Transition to analysis state
        gameStateManager.transition(to: .experimentAnalysis)

        // Get AI feedback
        let analysis = aiTutorSystem.analyzeExperiment(finalSession)
        print("Experiment Analysis: \(analysis)")

        // Play completion audio
        audioManager.playSound(.experimentComplete)

        currentExperiment = nil
    }

    // MARK: - State Management

    func transitionToMainMenu() {
        gameStateManager.transition(to: .mainMenu)
    }

    func transitionToLaboratorySelection() {
        gameStateManager.transition(to: .laboratorySelection)
    }

    func pauseExperiment() {
        gameStateManager.transition(to: .paused)
        audioManager.playSound(.menuOpen)
    }

    func resumeExperiment() {
        if let previousState = gameStateManager.previousState {
            gameStateManager.transition(to: previousState)
        }
        audioManager.playSound(.menuClose)
    }

    // MARK: - Progress Management

    private func loadProgress() async {
        do {
            let progress = try await saveManager.loadProgress()
            self.playerProgress = progress
        } catch {
            print("No existing progress found or error loading: \(error)")
            // Use default initialized progress
        }
    }

    func saveProgress() async {
        do {
            try await saveManager.saveProgress(playerProgress)
        } catch {
            print("Error saving progress: \(error)")
        }
    }

    // MARK: - XP and Achievements

    private func calculateExperimentXP(session: ExperimentSession) -> Int {
        var xp = 50  // Base XP

        // Bonus for completion
        if session.conclusion != nil {
            xp += 25
        }

        // Bonus for measurements
        xp += min(session.measurements.count * 5, 50)

        // Bonus for observations
        xp += min(session.observations.count * 10, 50)

        // Bonus for hypothesis
        if session.hypothesis != nil {
            xp += 25
        }

        return xp
    }

    private func checkAndAwardAchievements() {
        // Check for various achievements

        // Chemistry Novice: Complete 10 chemistry experiments
        if playerProgress.completedExperiments.count >= 10 {
            awardAchievement(.chemistryNovice)
        }

        // Perfect Safety Record: 100 experiments with zero violations
        if playerProgress.completedExperiments.count >= 100 && playerProgress.safetyViolations == 0 {
            awardAchievement(.perfectSafetyRecord)
        }
    }

    private func awardAchievement(_ achievement: Achievement) {
        guard !playerProgress.achievements.contains(where: { $0.id == achievement.id }) else {
            return  // Already awarded
        }

        playerProgress.achievements.append(achievement)

        // Play achievement sound
        audioManager.playSound(.achievementUnlocked)

        // Show notification (would trigger UI update)
        print("🏆 Achievement Unlocked: \(achievement.name)")
    }

    // MARK: - Setup

    private func setupObservers() {
        // Observe game state changes
        gameStateManager.$currentState
            .sink { [weak self] newState in
                self?.gameState = newState
                self?.handleStateChange(newState)
            }
            .store(in: &cancellables)
    }

    private func handleStateChange(_ newState: GameState) {
        switch newState {
        case .initializing:
            break
        case .mainMenu:
            audioManager.playMusic(.menu)
        case .laboratorySelection:
            audioManager.playMusic(.menu)
        case .experimentSetup:
            audioManager.stopMusic()
        case .activeExperiment:
            audioManager.playAmbience(.laboratory)
        case .experimentAnalysis:
            audioManager.stopAmbience()
        case .paused:
            audioManager.pauseAll()
        case .settings:
            break
        }
    }
}

// MARK: - Game Error

enum GameError: Error {
    case invalidState
    case experimentNotFound
    case saveFailed
    case loadFailed

    var localizedDescription: String {
        switch self {
        case .invalidState:
            return "Invalid game state for this operation"
        case .experimentNotFound:
            return "Experiment not found"
        case .saveFailed:
            return "Failed to save progress"
        case .loadFailed:
            return "Failed to load progress"
        }
    }
}
