//
//  CultureArchitectureSystemApp.swift
//  CultureArchitectureSystem
//
//  Created on 2025-01-20
//  Copyright © 2025 CultureSpace Technologies. All rights reserved.
//

import SwiftUI
import SwiftData

@main
struct CultureArchitectureSystemApp: App {
    @State private var appModel = AppModel()

    let modelContainer: ModelContainer

    init() {
        // Configure SwiftData schema
        let schema = Schema([
            Organization.self,
            CulturalValue.self,
            Employee.self,
            Recognition.self,
            BehaviorEvent.self,
            CulturalLandscape.self,
            CulturalRegion.self,
            Department.self
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )

        do {
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        // Primary Dashboard Window
        WindowGroup(id: "dashboard") {
            ContentView()
                .environment(appModel)
                .modelContainer(modelContainer)
        }
        .windowStyle(.plain)
        .defaultSize(width: 1200, height: 800)

        // Analytics Window
        WindowGroup(id: "analytics") {
            AnalyticsView()
                .environment(appModel)
                .modelContainer(modelContainer)
        }
        .windowStyle(.plain)
        .defaultSize(width: 1000, height: 700)

        // Recognition Window
        WindowGroup(id: "recognition") {
            RecognitionView()
                .environment(appModel)
                .modelContainer(modelContainer)
        }
        .windowStyle(.plain)
        .defaultSize(width: 600, height: 500)

        // Team Culture Volume (3D bounded space)
        WindowGroup(id: "team-culture", for: UUID.self) { $teamId in
            TeamCultureVolume(teamId: teamId)
                .environment(appModel)
                .modelContainer(modelContainer)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 2.0, height: 1.5, depth: 2.0, in: .meters)

        // Value Explorer Volume
        WindowGroup(id: "value-explorer", for: UUID.self) { $valueId in
            ValueExplorerVolume(valueId: valueId)
                .environment(appModel)
                .modelContainer(modelContainer)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1.5, height: 1.5, depth: 1.5, in: .meters)

        // Full Culture Campus Immersive Experience
        ImmersiveSpace(id: "culture-campus") {
            CultureCampusView()
                .environment(appModel)
                .modelContainer(modelContainer)
        }
        .immersionStyle(selection: .constant(.progressive), in: .progressive)

        // Onboarding Immersive Journey
        ImmersiveSpace(id: "onboarding") {
            OnboardingImmersiveView()
                .environment(appModel)
                .modelContainer(modelContainer)
        }
        .immersionStyle(selection: .constant(.full), in: .full)
    }
}
