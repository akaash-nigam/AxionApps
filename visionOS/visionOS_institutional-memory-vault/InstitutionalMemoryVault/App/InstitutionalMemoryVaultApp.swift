//
//  InstitutionalMemoryVaultApp.swift
//  Institutional Memory Vault
//
//  Created on 2025-11-17
//  Copyright © 2025 Institutional Memory Vault. All rights reserved.
//

import SwiftUI
import SwiftData

@main
struct InstitutionalMemoryVaultApp: App {

    // MARK: - State

    @State private var appState = AppState()
    @State private var immersionLevel: ImmersionStyle = .mixed

    // MARK: - SwiftData Model Container

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            KnowledgeEntity.self,
            Employee.self,
            Department.self,
            Organization.self,
            KnowledgeConnection.self,
            MemoryPalaceRoom.self
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true,
            groupContainer: .identifier("group.com.company.memory-vault"),
            cloudKitDatabase: .none // Configure for CloudKit later
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    // MARK: - Scene Configuration

    var body: some Scene {
        // MARK: Main Dashboard Window
        WindowGroup(id: "main-dashboard") {
            MainDashboardView()
                .environment(appState)
        }
        .windowStyle(.plain)
        .defaultSize(width: 1400, height: 900)
        .modelContainer(sharedModelContainer)

        // MARK: Knowledge Search Window
        WindowGroup(id: "search") {
            KnowledgeSearchView()
                .environment(appState)
        }
        .windowStyle(.plain)
        .defaultSize(width: 900, height: 700)
        .modelContainer(sharedModelContainer)

        // MARK: Knowledge Detail Window
        WindowGroup(id: "detail", for: UUID.self) { $knowledgeId in
            if let id = knowledgeId {
                KnowledgeDetailView(knowledgeId: id)
                    .environment(appState)
            }
        }
        .windowStyle(.plain)
        .defaultSize(width: 800, height: 1000)
        .modelContainer(sharedModelContainer)

        // MARK: Analytics Dashboard Window
        WindowGroup(id: "analytics") {
            AnalyticsDashboardView()
                .environment(appState)
        }
        .windowStyle(.plain)
        .defaultSize(width: 1200, height: 800)
        .modelContainer(sharedModelContainer)

        // MARK: Settings Window
        WindowGroup(id: "settings") {
            SettingsView()
                .environment(appState)
        }
        .windowStyle(.plain)
        .defaultSize(width: 600, height: 800)
        .modelContainer(sharedModelContainer)

        // MARK: Knowledge Network Volume (3D)
        WindowGroup(id: "knowledge-network-3d") {
            KnowledgeNetworkVolumeView()
                .environment(appState)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1000, height: 1000, depth: 1000, in: .points)
        .modelContainer(sharedModelContainer)

        // MARK: Timeline Volume (3D)
        WindowGroup(id: "timeline-3d") {
            TimelineVolumeView()
                .environment(appState)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1200, height: 800, depth: 400, in: .points)
        .modelContainer(sharedModelContainer)

        // MARK: Department Structure Volume (3D)
        WindowGroup(id: "org-chart-3d") {
            OrganizationChartVolumeView()
                .environment(appState)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1000, height: 1000, depth: 800, in: .points)
        .modelContainer(sharedModelContainer)

        // MARK: Memory Palace Immersive Space
        ImmersiveSpace(id: "memory-palace") {
            MemoryPalaceImmersiveView()
                .environment(appState)
        }
        .immersionStyle(selection: $immersionLevel, in: .mixed, .progressive, .full)
        .modelContainer(sharedModelContainer)

        // MARK: Knowledge Capture Studio
        ImmersiveSpace(id: "capture-studio") {
            KnowledgeCaptureStudioView()
                .environment(appState)
        }
        .immersionStyle(selection: $immersionLevel, in: .mixed, .progressive, .full)
        .modelContainer(sharedModelContainer)

        // MARK: Collaborative Exploration Space
        ImmersiveSpace(id: "collaboration-space") {
            CollaborativeExplorationView()
                .environment(appState)
        }
        .immersionStyle(selection: .constant(.progressive), in: .progressive)
        .modelContainer(sharedModelContainer)
    }
}

// MARK: - App State

@Observable
final class AppState {
    var currentUser: Employee?
    var activeWorkspace: Workspace = .dashboard
    var navigationStack: [NavigationDestination] = []
    var selectedKnowledge: Set<UUID> = []

    enum Workspace {
        case dashboard
        case search
        case analytics
        case memoryPalace
        case captureStudio
    }

    enum NavigationDestination: Hashable {
        case knowledgeDetail(UUID)
        case departmentView(UUID)
        case employeeProfile(UUID)
        case settings
    }
}
