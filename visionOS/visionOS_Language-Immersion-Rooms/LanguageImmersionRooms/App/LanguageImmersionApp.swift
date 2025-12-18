//
//  LanguageImmersionApp.swift
//  Language Immersion Rooms
//
//  Created by Claude Code
//  Copyright © 2025 Language Immersion Rooms. All rights reserved.
//

import SwiftUI

@main
struct LanguageImmersionApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var sceneManager = SceneManager()

    // Initialize persistence controller
    let persistenceController = PersistenceController.shared

    init() {
        print("🚀 Language Immersion Rooms - MVP v1.0")
        print("📱 Platform: visionOS")
        print("🌍 Language: Spanish (MVP)")
    }

    var body: some Scene {
        // Main window for menu and settings
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .windowStyle(.plain)

        // Immersive space for learning experience
        ImmersiveSpace(id: "LearningSpace") {
            ImmersiveLearningView()
                .environmentObject(appState)
                .environmentObject(sceneManager)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
