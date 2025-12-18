//
//  AppCoordinator.swift
//  RhythmFlow
//
//  Central coordinator for app-wide state and navigation
//

import SwiftUI
import Observation

@Observable
@MainActor
class AppCoordinator {
    // MARK: - State
    var gameState: GameState = .mainMenu
    var selectedSong: Song?
    var currentDifficulty: Difficulty = .normal
    var playerProfile: PlayerProfile

    // MARK: - Managers
    private(set) var gameEngine: GameEngine?
    private(set) var audioEngine: AudioEngine?
    private(set) var inputManager: InputManager?
    private(set) var scoreManager: ScoreManager?

    // MARK: - Initialization
    init() {
        // Load or create player profile
        self.playerProfile = Self.loadPlayerProfile() ?? PlayerProfile.default
    }

    // MARK: - Gameplay Setup
    func setupGameplay() {
        print("🎮 Setting up gameplay environment")

        // Initialize core systems
        self.audioEngine = AudioEngine()
        self.inputManager = InputManager()
        self.scoreManager = ScoreManager()
        self.gameEngine = GameEngine(
            audioEngine: audioEngine!,
            inputManager: inputManager!,
            scoreManager: scoreManager!
        )

        // Request necessary permissions
        Task {
            await requestPermissions()
        }
    }

    func cleanupGameplay() {
        print("🧹 Cleaning up gameplay environment")

        // Save player progress
        savePlayerProfile()

        // Cleanup systems
        gameEngine?.cleanup()
        audioEngine?.cleanup()
        inputManager?.cleanup()

        // Release resources
        gameEngine = nil
        audioEngine = nil
        inputManager = nil
        scoreManager = nil
    }

    // MARK: - Game Flow
    func startSong(_ song: Song, difficulty: Difficulty) {
        guard let gameEngine = gameEngine else {
            print("❌ Game engine not initialized")
            return
        }

        selectedSong = song
        currentDifficulty = difficulty
        gameState = .playing

        Task {
            await gameEngine.startSong(song, difficulty: difficulty)
        }
    }

    func pauseGame() {
        gameState = .paused
        gameEngine?.pause()
    }

    func resumeGame() {
        gameState = .playing
        gameEngine?.resume()
    }

    func endSong(session: GameSession) {
        gameState = .results

        // Update player statistics
        playerProfile.updateStatistics(from: session)

        // Save progress
        savePlayerProfile()
    }

    func returnToMenu() {
        gameState = .mainMenu
        selectedSong = nil
    }

    // MARK: - Permissions
    private func requestPermissions() async {
        // Hand tracking permission
        let handTrackingAuth = await inputManager?.requestHandTrackingAuthorization()
        print("✋ Hand tracking authorized: \(handTrackingAuth ?? false)")

        // World sensing permission
        let worldSensingAuth = await inputManager?.requestWorldSensingAuthorization()
        print("🌍 World sensing authorized: \(worldSensingAuth ?? false)")
    }

    // MARK: - Persistence
    private static func loadPlayerProfile() -> PlayerProfile? {
        guard let data = UserDefaults.standard.data(forKey: "playerProfile"),
              let profile = try? JSONDecoder().decode(PlayerProfile.self, from: data) else {
            return nil
        }
        return profile
    }

    private func savePlayerProfile() {
        guard let data = try? JSONEncoder().encode(playerProfile) else {
            print("❌ Failed to encode player profile")
            return
        }
        UserDefaults.standard.set(data, forKey: "playerProfile")
        print("💾 Player profile saved")
    }
}

// MARK: - Game State
enum GameState {
    case mainMenu
    case songSelection
    case calibration
    case countdown
    case playing
    case paused
    case results
    case multiplayer(MultiplayerState)

    enum MultiplayerState {
        case lobby
        case syncing
        case competing
        case finished
    }
}
