//
//  ParkourPathwaysApp.swift
//  Parkour Pathways
//
//  Main app entry point for visionOS
//

import SwiftUI
import SwiftData

@main
struct ParkourPathwaysApp: App {
    // App state
    @StateObject private var appCoordinator = AppCoordinator()
    @StateObject private var gameStateManager = GameStateManager()

    // SwiftData model container
    let modelContainer: ModelContainer

    init() {
        // Initialize SwiftData container
        do {
            let schema = Schema([
                PlayerData.self,
                CourseData.self,
                SessionMetrics.self
            ])
            let configuration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        // Window mode for menus and setup
        WindowGroup(id: "main-window") {
            MainMenuView()
                .environmentObject(appCoordinator)
                .environmentObject(gameStateManager)
                .modelContainer(modelContainer)
        }
        .windowStyle(.plain)
        .defaultSize(width: 800, height: 600)

        // Immersive space for gameplay
        ImmersiveSpace(id: "game-space") {
            ImmersiveGameView()
                .environmentObject(appCoordinator)
                .environmentObject(gameStateManager)
        }
        .immersionStyle(selection: .constant(.full), in: .full)
    }
}
