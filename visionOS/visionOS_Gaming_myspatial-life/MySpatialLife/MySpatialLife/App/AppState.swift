import SwiftUI
import Observation

@Observable
class AppState {
    // App-level state
    var isFirstLaunch: Bool = true
    var hasCompletedTutorial: Bool = false
    var currentScene: AppScene = .mainMenu

    // Settings
    var settings: GameSettings = GameSettings()

    // Window management
    var activeWindows: Set<String> = []

    enum AppScene {
        case mainMenu
        case familyCreation
        case gameplay
        case settings
    }

    func launchGame() {
        currentScene = .gameplay
    }

    func returnToMenu() {
        currentScene = .mainMenu
    }
}

struct GameSettings: Codable {
    var soundVolume: Float = 0.8
    var musicVolume: Float = 0.6
    var voiceVolume: Float = 0.9

    var enableSubtitles: Bool = false
    var enableColorBlindMode: Bool = false
    var enableReducedMotion: Bool = false

    var difficultyMode: DifficultyMode = .story
    var timeSpeedPreference: TimeSpeed = .normal

    enum DifficultyMode: String, Codable {
        case creative
        case story
        case balanced
        case challenging
    }

    enum CodingKeys: String, CodingKey {
        case soundVolume, musicVolume, voiceVolume
        case enableSubtitles, enableColorBlindMode, enableReducedMotion
        case difficultyMode, timeSpeedPreference
    }
}

// Time speed enum (also used in game state)
enum TimeSpeed: String, Codable {
    case paused
    case normal
    case fast
    case veryFast
}
