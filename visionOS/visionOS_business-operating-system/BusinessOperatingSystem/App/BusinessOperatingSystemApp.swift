//
//  BusinessOperatingSystemApp.swift
//  BusinessOperatingSystem
//
//  Created by BOS Team on 2025-01-20.
//

import SwiftUI
import SwiftData

@main
struct BusinessOperatingSystemApp: App {
    // MARK: - State

    @State private var appState = AppState()
    @State private var services = ServiceContainer()
    @State private var immersionLevel: ImmersionStyle = .full
    @State private var initializationError: Error?

    // MARK: - Model Container

    let modelContainer: ModelContainer

    init() {
        // Configure SwiftData model container with graceful fallback
        let schema = Schema([
            CachedOrganization.self,
            CachedDepartment.self,
            CachedKPI.self,
            CachedEmployee.self
        ])

        do {
            let configuration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                allowsSave: true,
                cloudKitDatabase: .none  // Can be .private for iCloud sync
            )

            self.modelContainer = try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
        } catch {
            // Fallback to in-memory storage if persistent storage fails
            // This allows the app to launch and function, albeit without persistence
            print("⚠️ Failed to initialize persistent ModelContainer: \(error.localizedDescription)")
            print("⚠️ Falling back to in-memory storage. Data will not persist between sessions.")

            do {
                let fallbackConfiguration = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: true,
                    allowsSave: true
                )
                self.modelContainer = try ModelContainer(
                    for: schema,
                    configurations: [fallbackConfiguration]
                )
                // Store error for later display to user
                _initializationError = State(initialValue: error)
            } catch {
                // Last resort: create minimal container
                // This should rarely fail, but we handle it gracefully
                print("❌ Critical: Failed to initialize even in-memory storage: \(error)")
                self.modelContainer = try! ModelContainer(for: schema)
                _initializationError = State(initialValue: error)
            }
        }
    }

    // MARK: - Body

    var body: some Scene {
        // MARK: Main Dashboard Window

        WindowGroup(id: "dashboard") {
            DashboardView(initializationError: initializationError)
                .environment(\.appState, appState)
                .environment(\.services, services)
                .task {
                    // Initialize services on launch
                    do {
                        try await services.initializeAll()

                        // Authenticate user
                        try await authenticateUser()

                        // Load initial data
                        await loadInitialData()
                    } catch {
                        appState.lastError = ErrorAlertConfig.from(error: error)
                        await services.analytics.trackEvent(.errorOccurred(error))
                    }
                }
        }
        .windowStyle(.plain)
        .defaultSize(width: 1200, height: 800)
        .modelContainer(modelContainer)

        // MARK: Department Detail Window

        WindowGroup(id: "department", for: Department.ID.self) { $departmentID in
            if let departmentID {
                DepartmentDetailView(departmentID: departmentID)
                    .environment(\.appState, appState)
                    .environment(\.services, services)
            }
        }
        .windowStyle(.plain)
        .defaultSize(width: 900, height: 1100)
        .modelContainer(modelContainer)

        // MARK: Report Window

        WindowGroup(id: "report", for: Report.ID.self) { $reportID in
            if let reportID {
                ReportDetailView(reportID: reportID)
                    .environment(\.appState, appState)
                    .environment(\.services, services)
            }
        }
        .windowStyle(.plain)
        .defaultSize(width: 800, height: 1000)
        .modelContainer(modelContainer)

        // MARK: Department Volume

        WindowGroup(id: "department-volume", for: Department.ID.self) { $departmentID in
            if let departmentID {
                DepartmentVolumeView(departmentID: departmentID)
                    .environment(\.appState, appState)
                    .environment(\.services, services)
            }
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1.0, height: 1.0, depth: 1.0, in: .meters)
        .modelContainer(modelContainer)

        // MARK: Data Visualization Volume

        WindowGroup(id: "visualization-volume", for: Visualization.ID.self) { $vizID in
            if let vizID {
                DataVisualizationVolume(visualizationID: vizID)
                    .environment(\.appState, appState)
                    .environment(\.services, services)
            }
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 0.8, height: 1.2, depth: 0.8, in: .meters)
        .modelContainer(modelContainer)

        // MARK: Business Universe Immersive Space

        ImmersiveSpace(id: "business-universe") {
            BusinessUniverseView()
                .environment(\.appState, appState)
                .environment(\.services, services)
        }
        .immersionStyle(selection: $immersionLevel, in: .full)
    }

    // MARK: - Helper Methods

    @MainActor
    private func authenticateUser() async throws {
        // Biometric authentication
        do {
            let user = try await services.auth.authenticateUser()
            appState.user = user
        } catch {
            print("Authentication failed: \(error)")
            throw error
        }
    }

    @MainActor
    private func loadInitialData() async {
        do {
            // Load organization data
            let organization = try await services.repository.fetchOrganization()
            appState.organization = organization

            // Start real-time sync
            await services.sync.startSync()
        } catch {
            print("Failed to load initial data: \(error)")
        }
    }
}

// MARK: - Environment Keys

private struct AppStateKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue = AppState()
}

private struct ServiceContainerKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue = ServiceContainer()
}

extension EnvironmentValues {
    var appState: AppState {
        get { self[AppStateKey.self] }
        set { self[AppStateKey.self] = newValue }
    }

    var services: ServiceContainer {
        get { self[ServiceContainerKey.self] }
        set { self[ServiceContainerKey.self] = newValue }
    }
}
