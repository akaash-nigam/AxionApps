//
//  CombatEnvironmentView.swift
//  MilitaryDefenseTraining
//
//  Created by Claude Code
//

import SwiftUI
import RealityKit

struct CombatEnvironmentView: View {
    @Environment(AppState.self) private var appState
    @Environment(SpaceManager.self) private var spaceManager
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.openWindow) private var openWindow

    @State private var combatViewModel = CombatViewModel()

    var body: some View {
        ZStack {
            // RealityView for 3D combat environment
            RealityView { content in
                // This is where the 3D combat scene would be created
                // For now, placeholder
                setupCombatScene(content: content)
            } update: { content in
                // Update scene each frame
            }

            // HUD Overlay
            HUDOverlay(viewModel: combatViewModel)

            // Pause Menu (if paused)
            if combatViewModel.isPaused {
                PauseMenu(
                    onResume: {
                        combatViewModel.isPaused = false
                    },
                    onExit: {
                        exitCombat()
                    }
                )
            }
        }
        .onAppear {
            combatViewModel.startMission()
        }
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    // Handle tap gestures
                }
        )
    }

    private func setupCombatScene(content: RealityViewContent) {
        // Create basic environment
        // In full implementation, this would load the scenario terrain,
        // spawn enemies, set up lighting, etc.

        // Placeholder: Add a simple ground plane
        let ground = ModelEntity(
            mesh: .generatePlane(width: 100, depth: 100),
            materials: [SimpleMaterial(color: .gray, isMetallic: false)]
        )
        ground.position = [0, 0, 0]
        content.add(ground)
    }

    private func exitCombat() {
        guard let session = appState.activeSession else { return }
        appState.endSession()

        Task {
            await spaceManager.exitCombat(
                sessionID: session.id,
                dismissImmersiveSpace,
                openWindow
            )
        }
    }
}

// MARK: - Combat ViewModel
@Observable
class CombatViewModel {
    var isPaused: Bool = false
    var health: Float = 100
    var currentAmmo: Int = 30
    var totalAmmo: Int = 210
    var objectivesCompleted: Int = 0
    var totalObjectives: Int = 3
    var missionTime: TimeInterval = 0

    func startMission() {
        // Initialize mission
        isPaused = false
        health = 100
        currentAmmo = 30
        totalAmmo = 210
        missionTime = 0
    }

    func fire() {
        guard currentAmmo > 0 else { return }
        currentAmmo -= 1
    }

    func reload() {
        let roundsNeeded = 30 - currentAmmo
        let roundsToLoad = min(roundsNeeded, totalAmmo)
        currentAmmo += roundsToLoad
        totalAmmo -= roundsToLoad
    }

    func takeDamage(_ amount: Float) {
        health = max(0, health - amount)
    }
}

// MARK: - HUD Overlay
struct HUDOverlay: View {
    let viewModel: CombatViewModel

    var body: some View {
        VStack {
            // Top HUD
            HStack {
                // Compass
                Text("N 045°")
                    .font(.caption)
                    .padding(8)
                    .background(.ultraThinMaterial)
                    .cornerRadius(8)

                Spacer()

                // Ammo
                VStack(alignment: .trailing) {
                    Text("\(viewModel.currentAmmo)")
                        .font(.title)
                        .bold()
                        .monospacedDigit()

                    Text("\(viewModel.totalAmmo)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
                .padding(8)
                .background(.ultraThinMaterial)
                .cornerRadius(8)
            }
            .padding()

            Spacer()

            // Crosshair (center)
            Image(systemName: "scope")
                .font(.title)
                .foregroundStyle(.white.opacity(0.7))

            Spacer()

            // Bottom HUD
            HStack {
                // Health
                VStack(alignment: .leading) {
                    Text("Health")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 2) {
                        ForEach(0..<10) { i in
                            Rectangle()
                                .fill(i < Int(viewModel.health / 10) ? .green : .gray.opacity(0.3))
                                .frame(width: 20, height: 8)
                        }
                    }

                    Text("\(Int(viewModel.health))%")
                        .font(.caption)
                        .monospacedDigit()
                }
                .padding(8)
                .background(.ultraThinMaterial)
                .cornerRadius(8)

                Spacer()

                // Objectives
                VStack(alignment: .trailing) {
                    Text("Objectives")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("\(viewModel.objectivesCompleted)/\(viewModel.totalObjectives)")
                        .font(.subheadline)
                        .bold()
                        .monospacedDigit()
                }
                .padding(8)
                .background(.ultraThinMaterial)
                .cornerRadius(8)
            }
            .padding()
        }
    }
}

// MARK: - Pause Menu
struct PauseMenu: View {
    let onResume: () -> Void
    let onExit: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Text("Mission Paused")
                    .font(.largeTitle)
                    .bold()

                VStack(spacing: 12) {
                    Button("Resume") {
                        onResume()
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(width: 200)

                    Button("Restart Mission") {
                        // Restart logic
                    }
                    .buttonStyle(.bordered)
                    .frame(width: 200)

                    Button("Abort Mission") {
                        onExit()
                    }
                    .buttonStyle(.bordered)
                    .frame(width: 200)
                }
            }
            .padding(40)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
        }
    }
}

#Preview {
    CombatEnvironmentView()
        .environment(AppState())
        .environment(SpaceManager())
}
