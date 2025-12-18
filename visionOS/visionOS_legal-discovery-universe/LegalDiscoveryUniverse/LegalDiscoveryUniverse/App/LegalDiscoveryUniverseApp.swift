//
//  LegalDiscoveryUniverseApp.swift
//  Legal Discovery Universe
//
//  Created on 2025-11-17.
//

import SwiftUI
import SwiftData

@main
struct LegalDiscoveryUniverseApp: App {
    // MARK: - Properties

    var modelContainer: ModelContainer

    @State private var appState = AppState()
    @State private var immersionLevel: ImmersionStyle = .mixed

    // MARK: - Initialization

    init() {
        // Configure SwiftData schema
        let schema = Schema([
            LegalCase.self,
            LegalDocument.self,
            LegalEntity.self,
            Timeline.self,
            TimelineEvent.self,
            Annotation.self,
            EntityRelationship.self
        ])

        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )

        do {
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [config]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    // MARK: - Scene Configuration

    var body: some Scene {
        // Main Dashboard Window
        WindowGroup("Legal Discovery Universe", id: WindowIdentifier.mainDashboard.rawValue) {
            CaseDashboardView()
                .environment(appState)
        }
        .windowStyle(.plain)
        .defaultSize(width: 1400, height: 900)
        .modelContainer(modelContainer)
        .commands {
            CaseManagementCommands()
            DocumentCommands()
        }

        // Document Viewer Window
        WindowGroup("Document Viewer", id: WindowIdentifier.documentViewer.rawValue, for: UUID.self) { $documentID in
            if let documentID {
                DocumentViewerView(documentID: documentID)
                    .environment(appState)
            }
        }
        .windowStyle(.plain)
        .defaultSize(width: 1000, height: 1200)
        .modelContainer(modelContainer)

        // Search Results Window
        WindowGroup("Search Results", id: WindowIdentifier.searchResults.rawValue) {
            SearchResultsView()
                .environment(appState)
        }
        .windowStyle(.plain)
        .defaultSize(width: 1200, height: 800)
        .modelContainer(modelContainer)

        // Evidence Cluster Volume
        WindowGroup("Evidence Cluster", id: WindowIdentifier.evidenceCluster.rawValue) {
            EvidenceClusterView()
                .environment(appState)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1.0, height: 1.0, depth: 1.0, in: .meters)
        .modelContainer(modelContainer)

        // Evidence Universe Immersive Space
        ImmersiveSpace(id: ImmersiveSpaceIdentifier.evidenceUniverse.rawValue) {
            EvidenceUniverseView()
                .environment(appState)
        }
        .immersionStyle(selection: $immersionLevel, in: .mixed, .progressive, .full)
        .upperLimbVisibility(.visible)

        // Timeline Immersive Space
        ImmersiveSpace(id: ImmersiveSpaceIdentifier.timeline.rawValue) {
            TimelineImmersiveView()
                .environment(appState)
        }
        .immersionStyle(selection: .constant(.progressive), in: .progressive)
        .upperLimbVisibility(.visible)
    }
}

// MARK: - Window Identifiers

enum WindowIdentifier: String {
    case mainDashboard = "main-dashboard"
    case documentViewer = "document-viewer"
    case searchResults = "search-results"
    case evidenceCluster = "evidence-cluster"
}

enum ImmersiveSpaceIdentifier: String {
    case evidenceUniverse = "evidence-universe"
    case timeline = "timeline-space"
}

// MARK: - Application State

@Observable
final class AppState {
    // Current case
    var currentCase: LegalCase?

    // UI State
    var activeWindow: WindowIdentifier?
    var immersiveSpaceActive: Bool = false
    var selectedDocuments: Set<UUID> = []

    // User preferences
    var preferences: UserPreferences = UserPreferences()

    // Spatial state
    var spatialMode: SpatialMode = .windowed
    var viewportTransform: simd_float4x4?

    init() {
        // Load user preferences
        loadPreferences()
    }

    func loadPreferences() {
        // Load from UserDefaults or file
        preferences = UserPreferences.load()
    }

    func savePreferences() {
        preferences.save()
    }
}

// MARK: - User Preferences

struct UserPreferences: Codable {
    var enableAIAnalysis: Bool = true
    var auto3DVisualization: Bool = false
    var showTutorial: Bool = true
    var theme: Theme = .auto
    var defaultSearchFilters: [String] = []

    static func load() -> UserPreferences {
        guard let data = UserDefaults.standard.data(forKey: "userPreferences"),
              let preferences = try? JSONDecoder().decode(UserPreferences.self, from: data) else {
            return UserPreferences()
        }
        return preferences
    }

    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: "userPreferences")
        }
    }
}

enum Theme: String, Codable {
    case light
    case dark
    case auto
}

enum SpatialMode {
    case windowed
    case volumetric
    case immersive
}

// MARK: - Commands

struct CaseManagementCommands: Commands {
    var body: some Commands {
        CommandMenu("Case") {
            Button("New Case...") {
                // Action
            }
            .keyboardShortcut("n", modifiers: .command)

            Button("Open Case...") {
                // Action
            }
            .keyboardShortcut("o", modifiers: .command)

            Divider()

            Button("Close Case") {
                // Action
            }
            .keyboardShortcut("w", modifiers: .command)
        }
    }
}

struct DocumentCommands: Commands {
    var body: some Commands {
        CommandMenu("Document") {
            Button("Upload Documents...") {
                // Action
            }
            .keyboardShortcut("u", modifiers: .command)

            Button("Mark Relevant") {
                // Action
            }
            .keyboardShortcut("r", modifiers: .command)

            Button("Flag Privileged") {
                // Action
            }
            .keyboardShortcut("p", modifiers: .command)

            Divider()

            Button("Export Selection...") {
                // Action
            }
            .keyboardShortcut("e", modifiers: .command)
        }
    }
}
