//
//  SmartAgricultureApp.swift
//  SmartAgriculture
//
//  Created by Claude Code
//  Copyright © 2025 Smart Agriculture. All rights reserved.
//

import SwiftUI
import SwiftData

@main
struct SmartAgricultureApp: App {
    // MARK: - State

    @State private var appModel = AppModel()
    @State private var farmManager = FarmManager()
    @State private var serviceContainer = ServiceContainer()

    // MARK: - Scene Configuration

    var body: some Scene {
        // MARK: Dashboard Window (Primary)
        WindowGroup(id: "dashboard") {
            DashboardView()
                .environment(appModel)
                .environment(farmManager)
                .environment(serviceContainer)
        }
        .windowStyle(.automatic)
        .defaultSize(width: 1200, height: 800)

        // MARK: Analytics Window
        WindowGroup(id: "analytics") {
            AnalyticsView()
                .environment(farmManager)
                .environment(serviceContainer)
        }
        .defaultSize(width: 1000, height: 700)

        // MARK: Control Panel Window
        WindowGroup(id: "controls") {
            ControlPanelView()
                .environment(appModel)
                .environment(farmManager)
        }
        .defaultSize(width: 400, height: 600)

        // MARK: Field 3D Volume
        WindowGroup(id: "fieldVolume") {
            FieldVolumeView()
                .environment(farmManager)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 2.0, height: 1.5, depth: 2.0, in: .meters)

        // MARK: Crop Model Volume
        WindowGroup(id: "cropModel") {
            CropModelView()
                .environment(farmManager)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 0.8, height: 1.2, depth: 0.8, in: .meters)

        // MARK: Farm Walkthrough (Immersive)
        ImmersiveSpace(id: "farmWalkthrough") {
            FarmImmersiveView()
                .environment(farmManager)
        }
        .immersionStyle(selection: $appModel.immersionLevel, in: .mixed, .progressive, .full)

        // MARK: Planning Mode (Mixed Reality)
        ImmersiveSpace(id: "planningMode") {
            PlanningImmersiveView()
                .environment(farmManager)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }

    // MARK: - Initialization

    init() {
        // Configure app appearance
        configureAppearance()
    }

    private func configureAppearance() {
        // Any global appearance configuration
    }
}
