//
//  RealityRealmsApp.swift
//  Reality Realms RPG
//
//  Main application entry point for visionOS
//

import SwiftUI

@main
struct RealityRealmsApp: App {
    @State private var immersionStyle: ImmersionStyle = .full
    @StateObject private var gameStateManager = GameStateManager.shared
    @StateObject private var appModel = AppModel()

    init() {
        // Configure app on launch
        configureApp()
    }

    var body: some Scene {
        // Main menu window
        WindowGroup {
            MainMenuView()
                .environmentObject(gameStateManager)
                .environmentObject(appModel)
        }
        .windowStyle(.plain)

        // Immersive game space
        ImmersiveSpace(id: "GameSpace") {
            GameView()
                .environmentObject(gameStateManager)
                .environmentObject(appModel)
        }
        .immersionStyle(selection: $immersionStyle, in: .full)
    }

    private func configureApp() {
        // Configure logging
        print("🎮 Reality Realms RPG - Initializing...")

        // Initialize game systems
        _ = EventBus.shared
        _ = GameStateManager.shared
        _ = PerformanceMonitor.shared

        print("✅ Game systems initialized")
    }
}

/// App-level state and configuration
@MainActor
class AppModel: ObservableObject {
    @Published var isImmersiveSpaceOpen = false
    @Published var needsRoomScan = true
    @Published var hasCompletedTutorial = false

    init() {
        loadSettings()
    }

    func loadSettings() {
        // Load user settings from UserDefaults
        hasCompletedTutorial = UserDefaults.standard.bool(forKey: "hasCompletedTutorial")
    }

    func saveSettings() {
        UserDefaults.standard.set(hasCompletedTutorial, forKey: "hasCompletedTutorial")
    }
}
