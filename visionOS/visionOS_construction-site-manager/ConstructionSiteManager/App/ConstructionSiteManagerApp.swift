//
//  ConstructionSiteManagerApp.swift
//  Construction Site Manager
//
//  Main app entry point
//

import SwiftUI
import SwiftData

@main
struct ConstructionSiteManagerApp: App {
    @State private var appState = AppState()
    @State private var immersionStyle: ImmersionStyle = .mixed

    var body: some Scene {
        // MARK: - Main Control Window
        WindowGroup("Site Control", id: "main-control") {
            ContentView()
                .environment(appState)
        }
        .windowStyle(.plain)
        .defaultSize(width: 800, height: 600)
        .modelContainer(for: [
            Site.self,
            Project.self,
            BIMModel.self,
            BIMElement.self,
            Issue.self,
            TeamMember.self,
            DangerZone.self,
            SafetyAlert.self,
            SafetyIncident.self
        ])

        // MARK: - Site Overview Volume
        WindowGroup("Site Overview", id: "site-overview") {
            SiteOverviewVolumeView()
                .environment(appState)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 2, height: 1.5, depth: 2, in: .meters)

        // MARK: - AR Overlay (Mixed Reality)
        ImmersiveSpace(id: "ar-overlay") {
            ARSiteOverlayView()
                .environment(appState)
        }
        .immersionStyle(selection: $immersionStyle, in: .mixed)
        .upperLimbVisibility(.visible)

        // MARK: - Full Immersive (Training/Presentation)
        ImmersiveSpace(id: "full-immersive") {
            ImmersiveExperienceView()
                .environment(appState)
        }
        .immersionStyle(selection: $immersionStyle, in: .full)
    }
}

// MARK: - App State

/// Global application state
@Observable
final class AppState {
    // Current context
    var currentSite: Site?
    var currentProject: Project?
    var selectedElements: Set<String> = []

    // User state
    var currentUser: User
    var userRole: TeamRole = .projectManager
    var permissions: Set<Permission> = []

    // View state
    var presentationMode: PresentationMode = .window
    var activeFilters: [FilterType] = []
    var viewSettings: ViewSettings

    // Spatial state
    var devicePose: Transform3D?
    var siteAnchorEstablished: Bool = false
    var visibleArea: BoundingBox?

    // Sync state
    var isSyncing: Bool = false
    var lastSyncDate: Date?
    var pendingUploads: Int = 0
    var isOffline: Bool = false

    // AR state
    var showBIMOverlay: Bool = true
    var showProgressLayer: Bool = true
    var showSafetyZones: Bool = true
    var showAnnotations: Bool = true
    var showWorkerTracking: Bool = false

    init() {
        // Initialize with default user
        self.currentUser = User(
            id: UUID(),
            name: "Demo User",
            email: "demo@example.com",
            role: .projectManager
        )
        self.viewSettings = ViewSettings()
    }

    func selectSite(_ site: Site) {
        currentSite = site
        currentProject = site.projects.first
    }

    func selectProject(_ project: Project) {
        currentProject = project
    }

    func toggleElementSelection(_ elementId: String) {
        if selectedElements.contains(elementId) {
            selectedElements.remove(elementId)
        } else {
            selectedElements.insert(elementId)
        }
    }

    func clearSelection() {
        selectedElements.removeAll()
    }
}

// MARK: - Supporting Types

struct User: Codable, Identifiable, Equatable {
    var id: UUID
    var name: String
    var email: String
    var role: TeamRole
    var photoURL: String?
}

enum Permission: String, Codable {
    case viewSite
    case editProgress
    case createIssue
    case manageSafety
    case editTeam
    case viewReports
    case exportData
    case manageSettings
}

enum PresentationMode: String, Codable {
    case window
    case volume
    case mixedReality
    case fullImmersive
}

enum FilterType: String, Codable {
    case discipline
    case status
    case floor
    case assignee
}

struct ViewSettings: Codable {
    var showCompleted: Bool = true
    var showNotStarted: Bool = true
    var ghostCompletedWork: Bool = false
    var highlightIssues: Bool = true
    var autoHideLayers: Bool = false
    var measurementUnit: MeasurementUnit = .metric

    enum MeasurementUnit: String, Codable {
        case metric
        case imperial
    }
}

struct BoundingBox: Codable, Equatable {
    var min: SIMD3<Float>
    var max: SIMD3<Float>

    var center: SIMD3<Float> {
        (min + max) / 2
    }

    var size: SIMD3<Float> {
        max - min
    }

    func contains(_ point: SIMD3<Float>) -> Bool {
        return point.x >= min.x && point.x <= max.x &&
               point.y >= min.y && point.y <= max.y &&
               point.z >= min.z && point.z <= max.z
    }
}
