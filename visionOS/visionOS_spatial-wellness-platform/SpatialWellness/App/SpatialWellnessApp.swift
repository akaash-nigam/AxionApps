//
//  SpatialWellnessApp.swift
//  SpatialWellness
//
//  Created by Claude on 2025-11-17.
//  Copyright © 2025 Spatial Wellness Platform. All rights reserved.
//

import SwiftUI
import SwiftData

/// Main application entry point for the Spatial Wellness Platform
/// Configures windows, volumes, and immersive spaces for visionOS
@main
struct SpatialWellnessApp: App {

    // MARK: - State

    /// Shared application state
    @State private var appState = AppState()

    /// Immersion style for progressive immersion
    @State private var immersionStyle: ImmersionStyle = .progressive

    // MARK: - SwiftData Configuration

    /// SwiftData model container for persistent storage
    let modelContainer: ModelContainer

    // MARK: - Initialization

    init() {
        // Configure SwiftData schema
        let schema = Schema([
            UserProfile.self,
            BiometricReading.self,
            Activity.self,
            HealthGoal.self,
            Challenge.self,
            Achievement.self,
            WellnessEnvironment.self
        ])

        // Create model configuration (privacy: no iCloud sync by default)
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true,
            cloudKitDatabase: .none
        )

        do {
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
        } catch {
            fatalError("Failed to initialize SwiftData ModelContainer: \(error)")
        }
    }

    // MARK: - Scene Configuration

    var body: some Scene {

        // MARK: Main Dashboard Window

        WindowGroup(id: "dashboard") {
            DashboardView()
                .environment(appState)
                .modelContainer(modelContainer)
        }
        .windowStyle(.automatic)
        .defaultSize(width: 800, height: 600)

        // MARK: Biometric Detail Window

        WindowGroup(id: "biometrics") {
            BiometricDetailView()
                .environment(appState)
                .modelContainer(modelContainer)
        }
        .windowStyle(.automatic)
        .defaultSize(width: 600, height: 800)

        // MARK: Community Window

        WindowGroup(id: "community") {
            CommunityView()
                .environment(appState)
                .modelContainer(modelContainer)
        }
        .windowStyle(.automatic)
        .defaultSize(width: 900, height: 700)

        // MARK: Settings Window

        WindowGroup(id: "settings") {
            SettingsView()
                .environment(appState)
                .modelContainer(modelContainer)
        }
        .windowStyle(.automatic)
        .defaultSize(width: 700, height: 500)

        // MARK: Health Landscape Volume (3D Visualization)

        WindowGroup(id: "healthLandscape") {
            HealthLandscapeVolume()
                .environment(appState)
                .modelContainer(modelContainer)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1.0, height: 1.0, depth: 1.0, in: .meters)

        // MARK: Heart Rate Visualization Volume

        WindowGroup(id: "heartRateViz") {
            HeartRateVisualizationVolume()
                .environment(appState)
                .modelContainer(modelContainer)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 0.8, height: 0.8, depth: 0.8, in: .meters)

        // MARK: Meditation Immersive Space

        ImmersiveSpace(id: "meditation") {
            MeditationEnvironmentView()
                .environment(appState)
                .modelContainer(modelContainer)
        }
        .immersionStyle(selection: $immersionStyle, in: .progressive)
        .upperLimbVisibility(.visible)

        // MARK: Virtual Gym Immersive Space

        ImmersiveSpace(id: "virtualGym") {
            VirtualGymView()
                .environment(appState)
                .modelContainer(modelContainer)
        }
        .immersionStyle(selection: $immersionStyle, in: .full)
        .upperLimbVisibility(.visible)

        // MARK: Relaxation Beach Immersive Space

        ImmersiveSpace(id: "relaxationBeach") {
            RelaxationBeachView()
                .environment(appState)
                .modelContainer(modelContainer)
        }
        .immersionStyle(selection: $immersionStyle, in: .progressive)
        .upperLimbVisibility(.hidden)
    }
}
