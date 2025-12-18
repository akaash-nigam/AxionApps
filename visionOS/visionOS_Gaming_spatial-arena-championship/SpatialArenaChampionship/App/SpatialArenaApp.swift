//
//  SpatialArenaApp.swift
//  Spatial Arena Championship
//
//  Main app entry point
//

import SwiftUI

@main
struct SpatialArenaApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        // Main Menu Window
        WindowGroup(id: "MainMenu") {
            MainMenuView()
                .environment(appState)
        }
        .windowStyle(.plain)
        .defaultSize(width: 800, height: 600)

        // Immersive Arena Space
        ImmersiveSpace(id: "ArenaSpace") {
            ArenaView()
                .environment(appState)
        }
        .immersionStyle(selection: .constant(.full), in: .full)
        .upperLimbVisibility(.visible)
    }
}
