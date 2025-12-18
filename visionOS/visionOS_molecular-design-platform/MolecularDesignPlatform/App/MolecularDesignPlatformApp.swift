//
//  MolecularDesignPlatformApp.swift
//  Molecular Design Platform
//
//  Main application entry point for visionOS
//

import SwiftUI
import SwiftData

@main
struct MolecularDesignPlatformApp: App {
    // MARK: - State

    @State private var appState = AppState()
    @State private var immersionStyle: ImmersionStyle = .mixed

    // MARK: - Scene Configuration

    var body: some Scene {
        // Main control panel window
        WindowGroup(id: "control-panel") {
            MainControlView()
                .environment(appState)
        }
        .windowStyle(.plain)
        .defaultSize(width: 800, height: 600)
        .modelContainer(appState.modelContainer)

        // Molecule viewer volume
        WindowGroup(id: "molecule-viewer") {
            MoleculeVolumeView()
                .environment(appState)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 0.6, height: 0.6, depth: 0.6, in: .meters)
        .modelContainer(appState.modelContainer)

        // Analytics dashboard window
        WindowGroup(id: "analytics") {
            AnalyticsDashboardView()
                .environment(appState)
        }
        .defaultSize(width: 1000, height: 700)
        .modelContainer(appState.modelContainer)

        // Immersive molecular laboratory
        ImmersiveSpace(id: "molecular-lab") {
            MolecularLabEnvironment()
                .environment(appState)
        }
        .immersionStyle(selection: $immersionStyle, in: .mixed, .progressive, .full)
        .upperLimbVisibility(.automatic)
    }
}

// MARK: - App State

@Observable
class AppState {
    // MARK: - Properties

    var currentUser: Researcher?
    var activeProject: Project?
    var sceneCoordinator: SceneCoordinator
    var services: ServiceContainer

    // UI state
    var selectedMolecules: Set<UUID> = []
    var visualizationStyle: VisualizationStyle = .ballAndStick
    var isSimulationRunning: Bool = false

    // Collaboration state
    var collaborationSession: CollaborationSession?
    var activeParticipants: [Researcher] = []

    // SwiftData model container
    let modelContainer: ModelContainer

    // MARK: - Initialization

    init() {
        // Set up SwiftData schema
        let schema = Schema([
            Molecule.self,
            Project.self,
            Simulation.self,
            Experiment.self
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )

        do {
            self.modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )

            let modelContext = ModelContext(modelContainer)

            // Initialize coordinators and services
            self.sceneCoordinator = SceneCoordinator()
            self.services = ServiceContainer(modelContext: modelContext)

        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
}

// MARK: - Scene Coordinator

@Observable
class SceneCoordinator {
    var openWindows: Set<String> = ["control-panel"]
    var activeVolumes: Set<String> = []
    var immersiveSpaceActive: Bool = false

    func openMoleculeViewer(molecule: Molecule) {
        activeVolumes.insert("molecule-viewer")
    }

    func enterImmersiveLab(project: Project) {
        immersiveSpaceActive = true
    }

    func exitImmersiveLab() {
        immersiveSpaceActive = false
    }
}

// MARK: - Environment Keys

private struct AppStateKey: EnvironmentKey {
    static let defaultValue: AppState? = nil
}

extension EnvironmentValues {
    var appState: AppState? {
        get { self[AppStateKey.self] }
        set { self[AppStateKey.self] = newValue }
    }
}
