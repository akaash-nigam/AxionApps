//
//  SpatialCRMApp.swift
//  SpatialCRM
//
//  visionOS Spatial CRM Application
//  Created: 2025-11-17
//

import SwiftUI
import SwiftData

@main
struct SpatialCRMApp: App {
    // MARK: - Properties

    let modelContainer: ModelContainer
    @State private var appState = AppState()

    // MARK: - Initialization

    init() {
        // Configure SwiftData schema
        let schema = Schema([
            Account.self,
            Contact.self,
            Opportunity.self,
            Activity.self,
            Territory.self,
            SalesRep.self,
            CollaborationSession.self
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true,
            cloudKitDatabase: .private("iCloud.com.company.spatialcrm")
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

    // MARK: - Body

    var body: some Scene {
        // Main Dashboard Window
        WindowGroup(id: "dashboard") {
            ContentView()
                .environment(appState)
        }
        .modelContainer(modelContainer)
        .windowStyle(.plain)
        .defaultSize(width: 1400, height: 900)
        .windowResizability(.contentSize)

        // Customer Detail Window
        WindowGroup(id: "customer-detail", for: UUID.self) { $customerId in
            if let customerId = customerId {
                CustomerDetailView(customerId: customerId)
                    .environment(appState)
            }
        }
        .modelContainer(modelContainer)
        .defaultSize(width: 1000, height: 700)

        // Quick Actions Panel
        WindowGroup(id: "quick-actions") {
            QuickActionsView()
                .environment(appState)
        }
        .modelContainer(modelContainer)
        .windowStyle(.plain)
        .defaultSize(width: 400, height: 600)

        // MARK: - Volumetric Windows

        // Pipeline River Volume
        WindowGroup(id: "pipeline-volume") {
            PipelineVolumeView()
                .environment(appState)
        }
        .modelContainer(modelContainer)
        .windowStyle(.volumetric)
        .defaultSize(width: 2.0, height: 1.5, depth: 1.0, in: .meters)

        // Relationship Network Volume
        WindowGroup(id: "network-volume") {
            NetworkGraphView()
                .environment(appState)
        }
        .modelContainer(modelContainer)
        .windowStyle(.volumetric)
        .defaultSize(width: 1.5, height: 1.5, depth: 1.5, in: .meters)

        // MARK: - Immersive Spaces

        // Customer Galaxy
        ImmersiveSpace(id: "customer-galaxy") {
            CustomerGalaxyView()
                .environment(appState)
        }
        .modelContainer(modelContainer)
        .immersionStyle(selection: .constant(.mixed), in: .mixed, .progressive, .full)

        // Territory Explorer
        ImmersiveSpace(id: "territory-explorer") {
            TerritoryExplorerView()
                .environment(appState)
        }
        .modelContainer(modelContainer)
        .immersionStyle(selection: .constant(.full), in: .full)
    }
}

// MARK: - App State

@Observable
class AppState {
    var currentUser: SalesRep?
    var selectedAccount: Account?
    var selectedOpportunity: Opportunity?
    var activeView: AppView = .dashboard
    var spatialMode: SpatialMode = .window
    var collaborationSession: CollaborationSession?
    var isAuthenticated: Bool = false

    init() {
        // Initialize with default values
        // In production, would load from persistent storage
    }
}

// MARK: - Supporting Types

enum AppView: String, Codable {
    case dashboard
    case pipeline
    case accounts
    case analytics
    case settings
}

enum SpatialMode: String, Codable {
    case window
    case volume
    case immersive
}

// MARK: - Navigation State

@Observable
class NavigationState {
    var path: [Route] = []

    func navigate(to route: Route) {
        path.append(route)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path.removeAll()
    }
}

enum Route: Hashable {
    case dashboard
    case pipeline
    case accounts
    case accountDetail(UUID)
    case opportunityDetail(UUID)
    case galaxy
    case territory
}
