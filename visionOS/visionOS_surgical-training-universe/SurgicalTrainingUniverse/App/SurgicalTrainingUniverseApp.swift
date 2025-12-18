//
//  SurgicalTrainingUniverseApp.swift
//  Surgical Training Universe
//
//  Created by Claude Code
//  Copyright © 2025 Surgical Training Universe. All rights reserved.
//

import SwiftUI
import SwiftData

/// Main application entry point for Surgical Training Universe
/// A visionOS application for immersive surgical training and education
@main
struct SurgicalTrainingUniverseApp: App {

    // MARK: - Properties

    /// SwiftData model container for persistence
    let modelContainer: ModelContainer

    /// Application state management
    @State private var appState = AppState()

    // MARK: - Initialization

    init() {
        // Configure SwiftData schema
        do {
            let schema = Schema([
                SurgeonProfile.self,
                ProcedureSession.self,
                SurgicalMovement.self,
                AIInsight.self,
                AnatomicalModel.self,
                Certification.self,
                CollaborationSession.self
            ])

            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                allowsSave: true
            )

            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )

            print("✅ SwiftData container initialized successfully")
        } catch {
            fatalError("❌ Could not initialize ModelContainer: \(error)")
        }
    }

    // MARK: - App Scenes

    var body: some Scene {

        // MARK: Main Dashboard Window
        WindowGroup(id: "dashboard") {
            DashboardView()
                .environment(appState)
                .modelContainer(modelContainer)
        }
        .windowStyle(.plain)
        .defaultSize(width: 1000, height: 700)

        // MARK: Analytics Window
        WindowGroup(id: "analytics") {
            AnalyticsView()
                .environment(appState)
                .modelContainer(modelContainer)
        }
        .windowStyle(.plain)
        .defaultSize(width: 1200, height: 800)

        // MARK: Settings Window
        WindowGroup(id: "settings") {
            SettingsView()
                .environment(appState)
                .modelContainer(modelContainer)
        }
        .windowStyle(.plain)
        .defaultSize(width: 600, height: 500)

        // MARK: Anatomy Explorer Volume
        WindowGroup(id: "anatomy-volume") {
            AnatomyVolumeView()
                .environment(appState)
                .modelContainer(modelContainer)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1.0, height: 1.0, depth: 1.0, in: .meters)

        // MARK: Instrument Preview Volume
        WindowGroup(id: "instrument-preview") {
            InstrumentPreviewVolume()
                .environment(appState)
                .modelContainer(modelContainer)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 0.5, height: 0.5, depth: 0.5, in: .meters)

        // MARK: Surgical Theater (Immersive)
        ImmersiveSpace(id: "surgical-theater") {
            SurgicalTheaterView()
                .environment(appState)
                .modelContainer(modelContainer)
        }
        .immersionStyle(selection: .constant(.full), in: .full)
        .upperLimbVisibility(.visible)

        // MARK: Collaborative Theater (Immersive)
        ImmersiveSpace(id: "collaborative-theater") {
            CollaborativeTheaterView()
                .environment(appState)
                .modelContainer(modelContainer)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed, .full)
        .upperLimbVisibility(.visible)
    }
}
