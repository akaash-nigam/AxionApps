//
//  FinancialOpsApp.swift
//  Financial Operations Platform
//
//  Main application entry point for visionOS
//

import SwiftUI
import SwiftData

@main
struct FinancialOpsApp: App {
    // MARK: - Properties

    let modelContainer: ModelContainer

    @State private var appState = AppState()

    // MARK: - Initialization

    init() {
        do {
            // Configure SwiftData schema
            let schema = Schema([
                FinancialTransaction.self,
                Account.self,
                CashPosition.self,
                KPI.self,
                RiskAssessment.self,
                CloseTask.self
            ])

            let configuration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                allowsSave: true
            )

            modelContainer = try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
        } catch {
            fatalError("Failed to initialize model container: \(error)")
        }
    }

    // MARK: - Scene Configuration

    var body: some Scene {
        // Main Dashboard Window
        WindowGroup(id: "dashboard") {
            DashboardView()
                .environment(appState)
        }
        .windowStyle(.automatic)
        .defaultSize(width: 1400, height: 900)
        .modelContainer(modelContainer)

        // Transaction Detail Window
        WindowGroup(id: "transactions", for: String.self) { $accountId in
            if let accountId = accountId {
                TransactionListView(accountId: accountId)
                    .environment(appState)
            }
        }
        .defaultSize(width: 1000, height: 700)
        .modelContainer(modelContainer)

        // Treasury Command Center
        WindowGroup(id: "treasury") {
            TreasuryView()
                .environment(appState)
        }
        .defaultSize(width: 1200, height: 800)
        .modelContainer(modelContainer)

        // KPI Volume (3D Bounded Space)
        WindowGroup(id: "kpi-volume") {
            KPIVolumeView()
                .environment(appState)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 0.6, height: 0.6, depth: 0.6, in: .meters)
        .modelContainer(modelContainer)

        // Cash Flow Universe (Mixed Immersive)
        ImmersiveSpace(id: "cash-flow-universe") {
            CashFlowUniverseView()
                .environment(appState)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)

        // Risk Topography (Mixed Immersive)
        ImmersiveSpace(id: "risk-topography") {
            RiskTopographyView()
                .environment(appState)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)

        // Financial Close Environment (Mixed Immersive)
        ImmersiveSpace(id: "close-environment") {
            FinancialCloseEnvironmentView()
                .environment(appState)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}

// MARK: - App State

@Observable
final class AppState {
    // User Session
    var currentUser: User?
    var isAuthenticated: Bool = false

    // Global Settings
    var preferredCurrency: Currency = Currency(code: "USD", symbol: "$", name: "US Dollar")
    var selectedRegion: String?
    var theme: AppTheme = .automatic

    // Navigation State
    var selectedModule: AppModule = .dashboard
    var activeImmersiveSpace: String?

    // Real-time Updates
    var liveDataEnabled: Bool = true
    var lastSyncTime: Date?

    // Notifications
    var unreadAlerts: Int = 0
}

// MARK: - Supporting Types

enum AppModule: String, CaseIterable {
    case dashboard
    case transactions
    case treasury
    case analytics
    case closeManagement
    case settings
}

enum AppTheme: String {
    case automatic
    case light
    case dark
}

struct User: Codable, Identifiable {
    let id: String
    let name: String
    let email: String
    let role: UserRole
}

enum UserRole: String, Codable {
    case cfo
    case controller
    case treasuryManager
    case analyst
    case auditor
    case viewer
}
