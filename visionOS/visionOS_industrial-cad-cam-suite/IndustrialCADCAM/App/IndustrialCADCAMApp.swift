//
//  IndustrialCADCAMApp.swift
//  IndustrialCADCAM
//
//  Industrial CAD/CAM Suite for visionOS
//  Next-Generation 3D Design and Manufacturing
//

import SwiftUI
import SwiftData
import RealityKit

@main
struct IndustrialCADCAMApp: App {

    // MARK: - State

    @State private var appState = AppState()
    @State private var immersionStyle: ImmersionStyle = .mixed

    // MARK: - Model Container

    let modelContainer: ModelContainer

    init() {
        // Initialize SwiftData model container
        let schema = Schema([
            Project.self,
            Part.self,
            Assembly.self,
            Feature.self,
            ManufacturingProcess.self,
            SimulationResult.self
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .private("iCloud.com.industrial.cadcam")
        )

        do {
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    // MARK: - Scene Configuration

    var body: some Scene {

        // MARK: Project Browser Window
        WindowGroup(id: "project-browser") {
            ProjectBrowserView()
                .environment(appState)
                .frame(minWidth: 600, minHeight: 400)
        }
        .windowStyle(.plain)
        .defaultSize(width: 800, height: 600)
        .modelContainer(modelContainer)

        // MARK: Properties Inspector Window
        WindowGroup(id: "properties-inspector") {
            PropertiesInspectorView()
                .environment(appState)
        }
        .windowStyle(.plain)
        .defaultSize(width: 400, height: 800)
        .modelContainer(modelContainer)

        // MARK: Tools Palette Window
        WindowGroup(id: "tools-palette") {
            ToolsPaletteView()
                .environment(appState)
        }
        .windowStyle(.plain)
        .defaultSize(width: 300, height: 600)
        .modelContainer(modelContainer)

        // MARK: Design Volume (Primary Workspace)
        WindowGroup(id: "design-volume") {
            DesignVolumeView()
                .environment(appState)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 2.0, height: 1.5, depth: 1.5, in: .meters)
        .modelContainer(modelContainer)

        // MARK: Simulation Theater Volume
        WindowGroup(id: "simulation-theater") {
            SimulationTheaterView()
                .environment(appState)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 3.0, height: 2.0, depth: 2.0, in: .meters)
        .modelContainer(modelContainer)

        // MARK: Full-Scale Prototype Immersive Space
        ImmersiveSpace(id: "immersive-prototype") {
            ImmersivePrototypeView()
                .environment(appState)
        }
        .immersionStyle(selection: $immersionStyle, in: .mixed, .progressive, .full)
        .upperLimbVisibility(.visible)

        // MARK: Manufacturing Floor Immersive Space
        ImmersiveSpace(id: "manufacturing-floor") {
            ManufacturingFloorView()
                .environment(appState)
        }
        .immersionStyle(selection: .constant(.full), in: .full)
        .modelContainer(modelContainer)
    }
}

// MARK: - App State

@Observable
class AppState {
    var currentProject: Project?
    var openAssemblies: [Assembly] = []
    var activeSession: DesignSession?
    var selectedParts: Set<UUID> = []

    // UI State
    var showingPropertiesPanel: Bool = true
    var showingToolsPalette: Bool = true
    var immersionLevel: ImmersionStyle = .mixed
    var viewMode: ViewMode = .shaded

    // Collaboration state
    var collaborators: [Participant] = []
    var spatialAnnotations: [SpatialAnnotation] = []

    init() {
        // Initialize with default state
    }
}

// MARK: - View Mode

enum ViewMode: String, CaseIterable {
    case shaded = "Shaded"
    case wireframe = "Wireframe"
    case hiddenLineRemoved = "Hidden Line"
    case transparent = "Transparent"
    case xray = "X-Ray"
}

// MARK: - Temporary Placeholder Types
// These will be properly defined in the Models folder

struct DesignSession: Identifiable {
    let id = UUID()
    var projectId: UUID
    var participants: [Participant]
}

struct Participant: Identifiable {
    let id = UUID()
    var name: String
    var avatarColor: String
}

struct SpatialAnnotation: Identifiable {
    let id = UUID()
    var authorId: UUID
    var position: SIMD3<Float>
    var content: String
}
