//
//  FieldServiceARApp.swift
//  FieldServiceAR
//
//  Created by Claude Code
//  Copyright © 2025 Enterprise. All rights reserved.
//

import SwiftUI
import SwiftData

@main
struct FieldServiceARApp: App {
    // Dependency container
    @State private var container = DependencyContainer()

    var body: some Scene {
        // Dashboard Window (Primary Entry Point)
        WindowGroup(id: "dashboard") {
            DashboardView()
                .environment(\.appState, container.appState)
                .modelContainer(container.modelContainer)
        }
        .windowStyle(.plain)
        .defaultSize(width: 800, height: 600)

        // Job Details Window
        WindowGroup(id: "job-details", for: UUID.self) { $jobId in
            if let jobId = jobId {
                JobDetailsView(jobId: jobId)
                    .environment(\.appState, container.appState)
                    .modelContainer(container.modelContainer)
            }
        }
        .defaultSize(width: 1000, height: 700)

        // Equipment Library Window
        WindowGroup(id: "equipment-library") {
            EquipmentLibraryView()
                .environment(\.appState, container.appState)
                .modelContainer(container.modelContainer)
        }
        .defaultSize(width: 900, height: 650)

        // 3D Equipment Preview Volume
        WindowGroup(id: "equipment-3d", for: UUID.self) { $equipmentId in
            if let equipmentId = equipmentId {
                Equipment3DView(equipmentId: equipmentId)
                    .environment(\.appState, container.appState)
                    .modelContainer(container.modelContainer)
            }
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 0.6, height: 0.6, depth: 0.6, in: .meters)

        // AR Repair Guidance (Immersive Space)
        ImmersiveSpace(id: "ar-repair") {
            ARRepairView()
                .environment(\.appState, container.appState)
                .modelContainer(container.modelContainer)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}

// App State Environment Key
extension EnvironmentValues {
    @Entry var appState: AppState = AppState()
}
