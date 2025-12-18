//
//  AppState.swift
//  Spatial Arena Championship
//
//  App-level state management
//

import Foundation
import Observation

@Observable
class AppState {
    // MARK: - App State
    var currentScreen: Screen = .mainMenu
    var isImmersiveSpaceOpen: Bool = false

    // MARK: - Player Data
    var localPlayer: PlayerProfile
    var isAuthenticated: Bool = false

    // MARK: - Match State
    var currentMatch: Match?
    var isInMatch: Bool = false
    var matchState: MatchState = .pending

    // MARK: - Settings
    var settings: GameSettings = GameSettings()

    // MARK: - Network
    var isOnline: Bool = false
    var latency: TimeInterval = 0

    init() {
        // Load or create player profile
        self.localPlayer = Self.loadPlayerProfile() ?? PlayerProfile(username: "Player")
        self.isAuthenticated = false
    }

    // MARK: - Methods

    func startMatch(_ match: Match) {
        currentMatch = match
        isInMatch = true
        matchState = .loading
        currentScreen = .game
    }

    func endMatch() {
        // Save match results
        if let match = currentMatch {
            saveMatchResult(match)
        }

        currentMatch = nil
        isInMatch = false
        matchState = .completed
        currentScreen = .postMatch
    }

    func returnToMainMenu() {
        currentMatch = nil
        isInMatch = false
        currentScreen = .mainMenu
    }

    // MARK: - Persistence

    private static func loadPlayerProfile() -> PlayerProfile? {
        guard let data = UserDefaults.standard.data(forKey: "playerProfile"),
              let profile = try? JSONDecoder().decode(PlayerProfile.self, from: data) else {
            return nil
        }
        return profile
    }

    func savePlayerProfile() {
        guard let data = try? JSONEncoder().encode(localPlayer) else { return }
        UserDefaults.standard.set(data, forKey: "playerProfile")
    }

    private func saveMatchResult(_ match: Match) {
        // TODO: Implement match result persistence
        guard let winner = match.winner else { return }

        let didWin = localPlayer.playerID == winner.players.first?.id
        let stats = match.team1.players.first { $0.id == localPlayer.playerID }?.stats ??
                    match.team2.players.first { $0.id == localPlayer.playerID }?.stats ??
                    PlayerStats()

        let srChange = calculateSRChange(won: didWin, match: match)

        localPlayer.addMatchResult(won: didWin, stats: stats, srChange: srChange)
        localPlayer.addExperience(didWin ? 1000 : 500)

        savePlayerProfile()
    }

    private func calculateSRChange(won: Bool, match: Match) -> Int {
        // Basic SR calculation (simplified)
        let baseSR = won ? GameConstants.Progression.baseWinSR : -GameConstants.Progression.baseLossSR
        // TODO: Add performance bonus, opponent strength, etc.
        return baseSR
    }
}

// MARK: - Screen enum

enum Screen {
    case mainMenu
    case matchmaking
    case game
    case postMatch
    case settings
    case training
}

// MARK: - Game Settings

struct GameSettings: Codable {
    var audioSettings: AudioSettings = AudioSettings()
    var graphicsSettings: GraphicsSettings = GraphicsSettings()
    var controlSettings: ControlSettings = ControlSettings()
    var accessibilitySettings: AccessibilitySettings = AccessibilitySettings()
}

struct AudioSettings: Codable {
    var masterVolume: Float = 1.0
    var musicVolume: Float = 0.7
    var sfxVolume: Float = 1.0
    var voiceVolume: Float = 1.0
    var spatialAudioEnabled: Bool = true
}

struct GraphicsSettings: Codable {
    var quality: GraphicsQuality = .high
    var particleEffects: Bool = true
    var bloomEnabled: Bool = true
    var dynamicResolution: Bool = true

    enum GraphicsQuality: String, Codable, CaseIterable {
        case low
        case medium
        case high
        case ultra

        var displayName: String {
            rawValue.capitalized
        }
    }
}

struct ControlSettings: Codable {
    var sensitivity: Float = 1.0
    var aimAssist: Bool = false
    var gestureThreshold: Float = 0.5
    var handedness: Handedness = .right

    enum Handedness: String, Codable {
        case left
        case right
        case ambidextrous
    }
}

struct AccessibilitySettings: Codable {
    var colorBlindMode: ColorBlindMode = .none
    var textSize: TextSize = .medium
    var motionSicknessMode: Bool = false
    var visualEffectsIntensity: Float = 1.0

    enum ColorBlindMode: String, Codable, CaseIterable {
        case none
        case deuteranopia
        case protanopia
        case tritanopia

        var displayName: String {
            switch self {
            case .none: return "None"
            case .deuteranopia: return "Deuteranopia (Red-Green)"
            case .protanopia: return "Protanopia (Red-Green Severe)"
            case .tritanopia: return "Tritanopia (Blue-Yellow)"
            }
        }
    }

    enum TextSize: String, Codable {
        case small
        case medium
        case large
        case extraLarge
    }
}
