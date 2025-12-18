//
//  RhythmFlowApp.swift
//  RhythmFlow
//
//  Created by Claude AI
//  Copyright © 2025 BeatSpace Studios. All rights reserved.
//

import SwiftUI

@main
struct RhythmFlowApp: App {
    @State private var appCoordinator = AppCoordinator()
    @State private var immersionStyle: ImmersionStyle = .progressive

    var body: some Scene {
        // Main Menu Window - 2D Interface
        WindowGroup(id: "main-menu") {
            MainMenuView()
                .environment(appCoordinator)
        }
        .windowStyle(.plain)
        .defaultSize(width: 800, height: 600)

        // Song Preview Volume - 3D Preview
        WindowGroup(id: "song-preview") {
            SongPreviewVolume()
                .environment(appCoordinator)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 600, height: 400, depth: 300, in: .points)

        // Gameplay Immersive Space - Full Experience
        ImmersiveSpace(id: "gameplay") {
            GameplaySpace()
                .environment(appCoordinator)
                .onAppear {
                    appCoordinator.setupGameplay()
                }
                .onDisappear {
                    appCoordinator.cleanupGameplay()
                }
        }
        .immersionStyle(selection: $immersionStyle, in: .progressive, .full)
    }
}
