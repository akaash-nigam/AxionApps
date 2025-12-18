//
//  ExperimentVolumeView.swift
//  Science Lab Sandbox
//
//  Volumetric view for contained experiments
//

import SwiftUI
import RealityKit

struct ExperimentVolumeView: View {

    @EnvironmentObject var gameCoordinator: GameCoordinator
    @EnvironmentObject var appState: AppState

    var body: some View {
        RealityView { content in
            // Create experiment scene
            await setupExperimentScene(content)
        } update: { content in
            // Update scene based on experiment state
        }
        .onAppear {
            print("📦 Experiment volume view appeared")
        }
        .onDisappear {
            print("📦 Experiment volume view disappeared")
        }
    }

    private func setupExperimentScene(_ content: RealityViewContent) async {
        // Create a simple lab bench
        let bench = await createLabBench()
        content.add(bench)

        // Add some basic equipment
        if let beaker = await createBeaker() {
            beaker.position = [0, 0.1, 0]
            content.add(beaker)
        }

        print("📦 Experiment scene setup complete")
    }

    private func createLabBench() async -> Entity {
        let bench = ModelEntity(
            mesh: .generateBox(width: 0.8, height: 0.05, depth: 0.6),
            materials: [SimpleMaterial(color: .brown, isMetallic: false)]
        )

        bench.position = [0, 0, 0]

        return bench
    }

    private func createBeaker() async -> Entity? {
        // Create a simple beaker model
        let beaker = ModelEntity(
            mesh: .generateCylinder(height: 0.15, radius: 0.05),
            materials: [SimpleMaterial(color: .white.withAlphaComponent(0.3), isMetallic: false)]
        )

        // Add physics
        beaker.components[PhysicsBodyComponent.self] = PhysicsBodyComponent(
            massProperties: .default,
            mode: .dynamic
        )

        // Add collision
        beaker.components[CollisionComponent.self] = CollisionComponent(
            shapes: [.generateCapsule(height: 0.15, radius: 0.05)]
        )

        // Add input target for interaction
        beaker.components[InputTargetComponent.self] = InputTargetComponent()

        return beaker
    }
}

#Preview {
    ExperimentVolumeView()
        .environmentObject(GameCoordinator())
        .environmentObject(AppState())
}
