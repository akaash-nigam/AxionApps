//
//  MysteryInvestigationApp.swift
//  Mystery Investigation
//
//  A spatial detective experience for Apple Vision Pro
//  Created: January 2025
//

import SwiftUI
import RealityKit

@main
struct MysteryInvestigationApp: App {
    @State private var gameCoordinator = GameCoordinator()
    @State private var appState: AppState = .mainMenu

    var body: some Scene {
        // Primary Window - Main Menu and UI
        WindowGroup {
            ContentView()
                .environment(gameCoordinator)
        }
        .windowStyle(.plain)

        // Immersive Space - Crime Scene Investigation
        ImmersiveSpace(id: "CrimeScene") {
            CrimeSceneView()
                .environment(gameCoordinator)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed, .progressive, .full)

        // Volume - Evidence Examination Viewer (Optional)
        WindowGroup(id: "EvidenceViewer") {
            EvidenceExaminationView()
                .environment(gameCoordinator)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 0.5, height: 0.5, depth: 0.5, in: .meters)
    }
}

/// App state management
enum AppState {
    case mainMenu
    case caseSelection
    case investigating
    case paused
    case caseComplete
}

/// Main content view that routes to appropriate screens
struct ContentView: View {
    @Environment(GameCoordinator.self) private var coordinator

    var body: some View {
        Group {
            switch coordinator.currentState {
            case .mainMenu:
                MainMenuView()
            case .caseSelection:
                CaseSelectionView()
            case .investigating:
                InvestigationHUDView()
            case .paused:
                PauseMenuView()
            case .caseComplete:
                CaseSummaryView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(GameCoordinator())
}
