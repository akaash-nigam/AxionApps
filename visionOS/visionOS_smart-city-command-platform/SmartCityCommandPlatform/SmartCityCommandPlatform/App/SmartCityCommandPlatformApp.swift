//
//  SmartCityCommandPlatformApp.swift
//  SmartCityCommandPlatform
//
//  visionOS Smart City Command Platform
//  Created by Claude Code
//

import SwiftUI
import SwiftData

@main
struct SmartCityCommandPlatformApp: App {
    // MARK: - State

    @State private var appState = AppState()
    @State private var immersionLevel: ImmersionStyle = .progressive

    // MARK: - SwiftData Container

    let modelContainer: ModelContainer

    // MARK: - Initialization

    init() {
        // Configure SwiftData schema
        let schema = Schema([
            City.self,
            District.self,
            Building.self,
            Infrastructure.self,
            InfrastructureComponent.self,
            IoTSensor.self,
            SensorReading.self,
            EmergencyIncident.self,
            EmergencyResponse.self,
            IncidentUpdate.self,
            TransportationAsset.self,
            CitizenRequest.self,
            RequestUpdate.self,
            AnalyticsSnapshot.self,
            UtilityConnection.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )

        do {
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
        } catch {
            fatalError("Failed to create model container: \(error)")
        }
    }

    // MARK: - Scene Configuration

    var body: some Scene {
        // MARK: Primary Operations Center Window

        WindowGroup("City Operations Center", id: "operations-center") {
            OperationsCenterView()
                .environment(appState)
        }
        .windowStyle(.plain)
        .windowResizability(.contentSize)
        .defaultSize(width: 1400, height: 900)
        .modelContainer(modelContainer)

        // MARK: Analytics Dashboard Window

        WindowGroup("Analytics Dashboard", id: "analytics") {
            AnalyticsDashboardView()
                .environment(appState)
        }
        .defaultSize(width: 1000, height: 700)
        .windowStyle(.automatic)
        .modelContainer(modelContainer)

        // MARK: Emergency Command Window

        WindowGroup("Emergency Command", id: "emergency-command") {
            EmergencyCommandView()
                .environment(appState)
        }
        .defaultSize(width: 1200, height: 800)
        .windowStyle(.plain)
        .modelContainer(modelContainer)

        // MARK: 3D City Model Volume

        WindowGroup("3D City Model", id: "city-3d") {
            City3DModelView()
                .environment(appState)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1000, height: 800, depth: 600)
        .modelContainer(modelContainer)

        // MARK: Infrastructure Volume

        WindowGroup("Infrastructure Systems", id: "infrastructure-3d") {
            InfrastructureVolumeView()
                .environment(appState)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 800, height: 600, depth: 400)
        .modelContainer(modelContainer)

        // MARK: Immersive City Exploration

        ImmersiveSpace(id: "city-immersive") {
            CityImmersiveView()
                .environment(appState)
        }
        .immersionStyle(selection: $immersionLevel, in: .progressive)
        .upperLimbVisibility(.visible)

        // MARK: Crisis Management Immersive

        ImmersiveSpace(id: "crisis-management") {
            CrisisManagementView()
                .environment(appState)
        }
        .immersionStyle(selection: .constant(.full), in: .full)
    }
}

// MARK: - App State

import Observation

@Observable
final class AppState {
    // MARK: User Session

    var currentUser: User?
    var userRole: UserRole = .operator

    // MARK: City Selection

    var selectedCity: City?
    var cities: [City] = []

    // MARK: View State

    var activeWorkspace: Workspace = .operations
    var immersiveMode: ImmersionMode = .none

    // MARK: Real-time Data

    var liveIncidents: [EmergencyIncident] = []
    var criticalAlerts: [Alert] = []

    // MARK: Connectivity

    var isConnected = true
    var lastSyncTime: Date?

    // MARK: Methods

    func switchCity(_ city: City) {
        selectedCity = city
        // Trigger data reload
        Task {
            await loadCityData(city)
        }
    }

    private func loadCityData(_ city: City) async {
        // Load city-specific data
        // This will be implemented with real data services
    }
}

// MARK: - Supporting Types

enum Workspace {
    case operations
    case emergency
    case planning
    case analytics
}

enum ImmersionMode {
    case none
    case partial
    case full
}

enum UserRole: String {
    case operator
    case supervisor
    case director
    case planner
    case emergency
}

struct User: Identifiable {
    let id: UUID
    var name: String
    var email: String
    var role: UserRole
    var department: String

    init(id: UUID = UUID(), name: String, email: String, role: UserRole, department: String) {
        self.id = id
        self.name = name
        self.email = email
        self.role = role
        self.department = department
    }
}

struct Alert: Identifiable {
    let id: UUID
    var severity: AlertSeverity
    var title: String
    var message: String
    var timestamp: Date
    var acknowledged: Bool

    init(id: UUID = UUID(), severity: AlertSeverity, title: String, message: String, timestamp: Date = Date(), acknowledged: Bool = false) {
        self.id = id
        self.severity = severity
        self.title = title
        self.message = message
        self.timestamp = timestamp
        self.acknowledged = acknowledged
    }
}

enum AlertSeverity: String {
    case info
    case warning
    case critical
    case emergency
}
