//
//  LegalDiscoveryUniverseApp.swift
//  Legal Discovery Universe
//
//  Created by Claude Code
//  Copyright © 2024 Legal Discovery Universe. All rights reserved.
//

import SwiftUI
import SwiftData

@main
struct LegalDiscoveryUniverseApp: App {
    @State private var appState = AppState()
    @State private var immersionLevel: ImmersionStyle = .progressive

    var body: some Scene {
        // MARK: - Main Discovery Workspace
        WindowGroup("Discovery Workspace", id: "main-workspace") {
            ContentView()
                .environment(appState)
        }
        .defaultSize(width: 1200, height: 900)
        .windowResizability(.contentSize)
        .modelContainer(DataManager.shared.modelContainer)
        .windowStyle(.plain)

        // MARK: - Document Detail Window
        WindowGroup("Document Detail", id: "document-detail", for: UUID.self) { $documentId in
            if let documentId {
                DocumentDetailView(documentId: documentId)
                    .environment(appState)
            } else {
                Text("Select a document")
                    .font(.title)
                    .foregroundStyle(.secondary)
            }
        }
        .defaultSize(width: 900, height: 1200)
        .windowResizability(.contentMinSize)
        .modelContainer(DataManager.shared.modelContainer)

        // MARK: - Settings Window
        WindowGroup("Settings", id: "settings") {
            SettingsView()
                .environment(appState)
        }
        .defaultSize(width: 800, height: 600)
        .modelContainer(DataManager.shared.modelContainer)

        // MARK: - Evidence Universe Volume
        WindowGroup("Evidence Universe", id: "evidence-universe") {
            EvidenceUniverseView()
                .environment(appState)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1.5, height: 1.5, depth: 1.5, in: .meters)
        .modelContainer(DataManager.shared.modelContainer)

        // MARK: - Timeline Volume
        WindowGroup("Timeline", id: "timeline-volume") {
            TimelineVolumeView()
                .environment(appState)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 2.0, height: 0.8, depth: 0.5, in: .meters)
        .modelContainer(DataManager.shared.modelContainer)

        // MARK: - Network Analysis Volume
        WindowGroup("Network Analysis", id: "network-volume") {
            NetworkAnalysisView()
                .environment(appState)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1.2, height: 1.2, depth: 1.2, in: .meters)
        .modelContainer(DataManager.shared.modelContainer)

        // MARK: - Case Investigation Immersive Space
        ImmersiveSpace(id: "case-investigation") {
            CaseInvestigationSpace()
                .environment(appState)
        }
        .immersionStyle(selection: $immersionLevel, in: .progressive)
        .upperLimbVisibility(.visible)

        // MARK: - Presentation Mode Immersive Space
        ImmersiveSpace(id: "presentation-mode") {
            PresentationModeSpace()
                .environment(appState)
        }
        .immersionStyle(selection: .constant(.full), in: .full)
        .upperLimbVisibility(.hidden)
    }
}

// MARK: - Main Content View
struct ContentView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    var body: some View {
        DiscoveryWorkspaceView()
            .toolbar {
                ToolbarItemGroup(placement: .bottomOrnament) {
                    BottomToolbar()
                }
            }
    }
}

// MARK: - Bottom Toolbar
struct BottomToolbar: View {
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace

    var body: some View {
        HStack(spacing: 24) {
            Button {
                // Home action
            } label: {
                Label("Home", systemImage: "house.fill")
            }

            Button {
                openWindow(id: "evidence-universe")
            } label: {
                Label("Universe", systemImage: "globe")
            }

            Button {
                openWindow(id: "timeline-volume")
            } label: {
                Label("Timeline", systemImage: "clock.fill")
            }

            Button {
                openWindow(id: "network-volume")
            } label: {
                Label("Network", systemImage: "point.3.connected.trianglepath.dotted")
            }

            Button {
                openWindow(id: "settings")
            } label: {
                Label("Settings", systemImage: "gear")
            }
        }
        .padding()
        .glassBackgroundEffect()
    }
}
