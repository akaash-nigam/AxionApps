//
//  LaboratoryImmersiveView.swift
//  Science Lab Sandbox
//
//  Full immersive laboratory experience
//

import SwiftUI
import RealityKit

struct LaboratoryImmersiveView: View {

    @EnvironmentObject var gameCoordinator: GameCoordinator
    @EnvironmentObject var appState: AppState

    @State private var laboratoryEntity: Entity?

    var body: some View {
        RealityView { content in
            await setupLaboratory(content)
        } update: { content in
            updateLaboratory(content)
        }
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    handleTap(on: value.entity)
                }
        )
        .onAppear {
            print("🔬 Laboratory immersive view appeared")
            gameCoordinator.audioManager.playAmbience(.laboratory)
        }
        .onDisappear {
            print("🔬 Laboratory immersive view disappeared")
            gameCoordinator.audioManager.stopAmbience()
        }
    }

    // MARK: - Setup

    private func setupLaboratory(_ content: RealityViewContent) async {
        // Create main laboratory container
        let lab = Entity()
        lab.name = "Laboratory"

        // Add laboratory stations
        await createChemistryStation(parent: lab)
        await createPhysicsStation(parent: lab)
        await createBiologyStation(parent: lab)

        // Add environment
        addLighting(to: lab)

        content.add(lab)
        laboratoryEntity = lab

        print("🔬 Laboratory setup complete")
    }

    private func createChemistryStation(parent: Entity) async {
        let station = Entity()
        station.name = "Chemistry Station"
        station.position = [-1.5, 0, -2]  // Left side

        // Create lab bench
        let bench = ModelEntity(
            mesh: .generateBox(width: 1.2, height: 0.05, depth: 0.8),
            materials: [SimpleMaterial(color: .gray, isMetallic: false)]
        )
        bench.position = [0, 0.8, 0]
        station.addChild(bench)

        // Add basic equipment
        let beaker = await createEquipment(type: .beaker, position: [-0.3, 0.85, 0])
        let burner = await createEquipment(type: .burner, position: [0.3, 0.85, 0])

        if let beaker = beaker { station.addChild(beaker) }
        if let burner = burner { station.addChild(burner) }

        parent.addChild(station)
    }

    private func createPhysicsStation(parent: Entity) async {
        let station = Entity()
        station.name = "Physics Station"
        station.position = [0, 0, -2]  // Center

        // Create physics apparatus placeholder
        let apparatus = ModelEntity(
            mesh: .generateBox(width: 1.0, height: 1.0, depth: 0.5),
            materials: [SimpleMaterial(color: .blue.withAlphaComponent(0.3), isMetallic: false)]
        )
        apparatus.position = [0, 0.5, 0]
        station.addChild(apparatus)

        parent.addChild(station)
    }

    private func createBiologyStation(parent: Entity) async {
        let station = Entity()
        station.name = "Biology Station"
        station.position = [1.5, 0, -2]  // Right side

        // Create microscope placeholder
        let microscope = ModelEntity(
            mesh: .generateCylinder(height: 0.3, radius: 0.08),
            materials: [SimpleMaterial(color: .white, isMetallic: true)]
        )
        microscope.position = [0, 0.9, 0]
        station.addChild(microscope)

        parent.addChild(station)
    }

    private func createEquipment(type: EquipmentType, position: SIMD3<Float>) async -> Entity? {
        switch type {
        case .beaker:
            let beaker = ModelEntity(
                mesh: .generateCylinder(height: 0.12, radius: 0.04),
                materials: [SimpleMaterial(color: .white.withAlphaComponent(0.4), isMetallic: false)]
            )
            beaker.position = position
            beaker.name = "Beaker"

            // Add physics
            beaker.components[PhysicsBodyComponent.self] = PhysicsBodyComponent(
                massProperties: .default,
                mode: .dynamic
            )

            // Add collision
            beaker.components[CollisionComponent.self] = CollisionComponent(
                shapes: [.generateCapsule(height: 0.12, radius: 0.04)]
            )

            // Add input target
            beaker.components[InputTargetComponent.self] = InputTargetComponent()

            return beaker

        case .burner:
            let burner = ModelEntity(
                mesh: .generateBox(width: 0.08, height: 0.10, depth: 0.08),
                materials: [SimpleMaterial(color: .gray, isMetallic: true)]
            )
            burner.position = position
            burner.name = "Burner"

            // Add input target
            burner.components[InputTargetComponent.self] = InputTargetComponent()

            return burner

        default:
            return nil
        }
    }

    private func addLighting(to entity: Entity) {
        // Add directional light
        let lightEntity = Entity()

        var directionalLight = DirectionalLightComponent()
        directionalLight.intensity = 1000

        lightEntity.components[DirectionalLightComponent.self] = directionalLight
        lightEntity.look(at: [0, 0, 0], from: [1, 2, 1], relativeTo: nil)

        entity.addChild(lightEntity)
    }

    // MARK: - Update

    private func updateLaboratory(_ content: RealityViewContent) {
        // Update laboratory based on experiment state
        guard let experiment = gameCoordinator.currentExperiment else { return }

        // Update based on current discipline
        // Add/remove equipment as needed
    }

    // MARK: - Interaction

    private func handleTap(on entity: Entity) {
        print("👆 Tapped on: \(entity.name)")

        // Play interaction sound
        gameCoordinator.audioManager.playSound(.buttonClick)

        // Handle equipment interaction
        if entity.name == "Beaker" {
            handleBeakerInteraction(entity)
        } else if entity.name == "Burner" {
            handleBurnerInteraction(entity)
        }
    }

    private func handleBeakerInteraction(_ entity: Entity) {
        print("🧪 Interacted with beaker")
        // Implement beaker-specific interactions
    }

    private func handleBurnerInteraction(_ entity: Entity) {
        print("🔥 Interacted with burner")
        // Implement burner-specific interactions
    }
}

#Preview {
    LaboratoryImmersiveView()
        .environmentObject(GameCoordinator())
        .environmentObject(AppState())
}
