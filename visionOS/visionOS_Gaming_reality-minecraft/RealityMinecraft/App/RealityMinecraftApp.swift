//
//  RealityMinecraftApp.swift
//  Reality Minecraft
//
//  Main application entry point for visionOS
//

import SwiftUI

@main
struct RealityMinecraftApp: App {
    @StateObject private var appModel = AppModel()
    @StateObject private var gameStateManager = GameStateManager()

    var body: some Scene {
        // Main Menu Window
        WindowGroup(id: "MainMenu") {
            MainMenuView()
                .environmentObject(appModel)
                .environmentObject(gameStateManager)
        }
        .windowStyle(.plain)
        .defaultSize(width: 800, height: 600)

        // Game World Immersive Space
        ImmersiveSpace(id: "GameWorld") {
            GameWorldView()
                .environmentObject(appModel)
                .environmentObject(gameStateManager)
        }
        .immersionStyle(selection: .constant(.full), in: .full)

        // Settings Window
        WindowGroup(id: "Settings") {
            SettingsView()
                .environmentObject(appModel)
        }
        .windowStyle(.plain)
        .defaultSize(width: 600, height: 800)
    }
}

/// Main application model managing global state
@MainActor
class AppModel: ObservableObject {
    @Published var isImmersiveSpaceOpen: Bool = false
    @Published var currentWorld: WorldData?
    @Published var settings: GameSettings = GameSettings()

    // Managers
    let worldPersistenceManager = WorldPersistenceManager()
    let performanceMonitor = PerformanceMonitor()

    init() {
        setupObservers()
    }

    private func setupObservers() {
        // Monitor memory warnings
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleMemoryWarning()
        }
    }

    func openImmersiveSpace() async {
        isImmersiveSpaceOpen = true
    }

    func closeImmersiveSpace() async {
        isImmersiveSpaceOpen = false
    }

    func loadWorld(id: UUID) async throws {
        currentWorld = try await worldPersistenceManager.loadWorld(id: id)
    }

    func saveCurrentWorld() async throws {
        guard let world = currentWorld else { return }
        try await worldPersistenceManager.saveWorld(world)
    }

    private func handleMemoryWarning() {
        print("⚠️ Memory warning received - clearing caches")
        // Clear non-essential caches
    }
}

/// Global game settings
struct GameSettings: Codable {
    // Graphics
    var renderDistance: Int = 8 // chunks
    var detailLevel: DetailLevel = .high
    var enableShadows: Bool = true
    var enableParticles: Bool = true
    var targetFPS: Int = 90

    // Audio
    var masterVolume: Float = 1.0
    var musicVolume: Float = 0.7
    var sfxVolume: Float = 1.0
    var enableSpatialAudio: Bool = true

    // Controls
    var handTrackingSensitivity: Float = 1.0
    var enableVoiceCommands: Bool = true
    var enableController: Bool = false

    // Gameplay
    var difficulty: Difficulty = .normal
    var gameMode: GameMode = .creative
    var autoSaveInterval: TimeInterval = 300 // 5 minutes
    var showTutorialHints: Bool = true

    // Comfort
    var enableBreakReminders: Bool = true
    var breakReminderInterval: TimeInterval = 1800 // 30 minutes
    var enableSafetyBoundaries: Bool = true
    var uiDistance: Float = 0.5 // meters

    enum DetailLevel: String, Codable {
        case low, medium, high
    }
}
