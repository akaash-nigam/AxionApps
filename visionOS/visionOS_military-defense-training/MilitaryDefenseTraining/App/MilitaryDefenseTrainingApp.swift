//
//  MilitaryDefenseTrainingApp.swift
//  MilitaryDefenseTraining
//
//  Created by Claude Code
//  Copyright © 2024 Military Defense Training. All rights reserved.
//

import SwiftUI
import SwiftData
import RealityKit

@main
struct MilitaryDefenseTrainingApp: App {
    @State private var appState = AppState()
    @State private var spaceManager = SpaceManager()

    // SwiftData model container
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            TrainingSession.self,
            Warrior.self,
            Scenario.self,
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )

        do {
            return try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        // MARK: - Main Window (Mission Control)
        WindowGroup(id: "mission-control") {
            MissionControlView()
                .environment(appState)
                .environment(spaceManager)
        }
        .windowStyle(.plain)
        .defaultSize(width: 1000, height: 700)
        .modelContainer(sharedModelContainer)

        // MARK: - Briefing Window
        WindowGroup(id: "briefing", for: Scenario.ID.self) { $scenarioID in
            if let scenarioID = scenarioID {
                MissionBriefingView(scenarioID: scenarioID)
                    .environment(appState)
                    .environment(spaceManager)
            }
        }
        .windowStyle(.plain)
        .defaultSize(width: 900, height: 650)
        .modelContainer(sharedModelContainer)

        // MARK: - After Action Review Window
        WindowGroup(id: "after-action", for: TrainingSession.ID.self) { $sessionID in
            if let sessionID = sessionID {
                AfterActionReviewView(sessionID: sessionID)
                    .environment(appState)
                    .environment(spaceManager)
            }
        }
        .windowStyle(.plain)
        .defaultSize(width: 1200, height: 800)
        .modelContainer(sharedModelContainer)

        // MARK: - Volume (Tactical Planning)
        WindowGroup(id: "tactical-planning", for: Scenario.ID.self) { $scenarioID in
            if let scenarioID = scenarioID {
                TacticalPlanningVolume(scenarioID: scenarioID)
                    .environment(appState)
                    .environment(spaceManager)
            }
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1.5, height: 1.0, depth: 1.5, in: .meters)
        .modelContainer(sharedModelContainer)

        // MARK: - Immersive Space (Combat Training)
        ImmersiveSpace(id: "combat-zone") {
            CombatEnvironmentView()
                .environment(appState)
                .environment(spaceManager)
        }
        .immersionStyle(selection: .constant(.progressive), in: .progressive)

        // MARK: - Settings Window
        WindowGroup(id: "settings") {
            SettingsView()
                .environment(appState)
                .environment(spaceManager)
        }
        .windowStyle(.plain)
        .defaultSize(width: 700, height: 500)
        .modelContainer(sharedModelContainer)
    }
}
