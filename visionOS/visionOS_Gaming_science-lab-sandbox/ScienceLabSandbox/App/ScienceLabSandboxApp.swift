//
//  ScienceLabSandboxApp.swift
//  Science Lab Sandbox
//
//  Main app entry point for Science Lab Sandbox visionOS application
//

import SwiftUI
import RealityKit

@main
@MainActor
struct ScienceLabSandboxApp: App {

    // MARK: - Properties

    @StateObject private var gameCoordinator = GameCoordinator()
    @StateObject private var appState = AppState()

    // MARK: - Scene Definitions

    var body: some SwiftUI.Scene {
        // Main Window Group for 2D UI
        WindowGroup {
            MainMenuView()
                .environmentObject(gameCoordinator)
                .environmentObject(appState)
        }
        .windowStyle(.plain)
        .defaultSize(width: 800, height: 600)

        // Volumetric Window for Contained Experiments
        WindowGroup(id: "experiment-volume") {
            ExperimentVolumeView()
                .environmentObject(gameCoordinator)
                .environmentObject(appState)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1.0, height: 0.8, depth: 1.0, in: .meters)

        // Immersive Space for Full Laboratory Experience
        ImmersiveSpace(id: "laboratory") {
            LaboratoryImmersiveView()
                .environmentObject(gameCoordinator)
                .environmentObject(appState)
        }
        .immersionStyle(selection: $appState.immersionStyle, in: .mixed, .progressive, .full)
    }
}

// MARK: - App State

/// Global application state
@MainActor
class AppState: ObservableObject {
    @Published var immersionStyle: ImmersionStyle = .mixed
    @Published var isImmersiveSpaceOpened: Bool = false
    @Published var selectedDiscipline: ScientificDiscipline?
    @Published var selectedExperiment: Experiment?

    // User preferences
    @Published var enableSpatialAudio: Bool = true
    @Published var enableHaptics: Bool = true
    @Published var enableVoiceCommands: Bool = false
    @Published var difficultyMode: DifficultyMode = .adaptive
    @Published var accessibilityMode: AccessibilityMode = .standard

    // Session tracking
    @Published var sessionStartTime: Date?
    @Published var totalLabTime: TimeInterval = 0
}

// MARK: - Enumerations

enum DifficultyMode: String, CaseIterable, Identifiable {
    case beginner
    case intermediate
    case advanced
    case expert
    case adaptive

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .beginner: return "Beginner"
        case .intermediate: return "Intermediate"
        case .advanced: return "Advanced"
        case .expert: return "Expert"
        case .adaptive: return "Adaptive (AI-Adjusted)"
        }
    }
}

enum AccessibilityMode: String, CaseIterable, Identifiable {
    case standard
    case highContrast
    case voiceOnly
    case simplified
    case largeText

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .standard: return "Standard"
        case .highContrast: return "High Contrast"
        case .voiceOnly: return "Voice Only"
        case .simplified: return "Simplified Controls"
        case .largeText: return "Large Text"
        }
    }
}
