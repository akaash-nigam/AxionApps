//
//  SupplyChainControlTowerApp.swift
//  SupplyChainControlTower
//
//  Created by Claude Code
//

import SwiftUI
import SwiftData

@main
struct SupplyChainControlTowerApp: App {

    // MARK: - State

    @State private var appState = AppState()
    @State private var immersionLevel: ImmersionStyle = .progressive

    // MARK: - SwiftData Model Container

    var modelContainer: ModelContainer = {
        let schema = Schema([
            CachedNetworkState.self,
            OfflineOperation.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    // MARK: - Body

    var body: some Scene {
        // MARK: Dashboard Window
        WindowGroup("Dashboard", id: "dashboard") {
            DashboardView()
                .environment(appState)
        }
        .defaultSize(width: 1200, height: 800)
        .modelContainer(modelContainer)

        // MARK: Alert Panel Window
        WindowGroup("Alerts", id: "alerts") {
            AlertsView()
                .environment(appState)
        }
        .defaultSize(width: 400, height: 600)
        .modelContainer(modelContainer)

        // MARK: Control Panel Window
        WindowGroup("Controls", id: "controls") {
            ControlPanelView()
                .environment(appState)
        }
        .defaultSize(width: 600, height: 400)
        .modelContainer(modelContainer)

        // MARK: Network Volume
        WindowGroup(id: "network-volume") {
            NetworkVolumeView()
                .environment(appState)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 2.0, height: 1.5, depth: 2.0, in: .meters)
        .modelContainer(modelContainer)

        // MARK: Inventory Landscape Volume
        WindowGroup(id: "inventory-volume") {
            InventoryLandscapeView()
                .environment(appState)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1.5, height: 1.0, depth: 1.5, in: .meters)
        .modelContainer(modelContainer)

        // MARK: Flow River Volume
        WindowGroup(id: "flow-volume") {
            FlowRiverView()
                .environment(appState)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 3.0, height: 1.0, depth: 1.0, in: .meters)
        .modelContainer(modelContainer)

        // MARK: Global Command Center (Immersive Space)
        ImmersiveSpace(id: "command-center") {
            GlobalCommandCenterView()
                .environment(appState)
        }
        .immersionStyle(selection: $immersionLevel, in: .progressive)
        .modelContainer(modelContainer)
    }
}
