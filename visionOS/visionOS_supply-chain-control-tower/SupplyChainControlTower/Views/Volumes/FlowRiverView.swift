//
//  FlowRiverView.swift
//  SupplyChainControlTower
//
//  3D flow visualization as a river system
//

import SwiftUI
import RealityKit

struct FlowRiverView: View {
    @Environment(AppState.self) private var appState
    @State private var animationTime: TimeInterval = 0

    var body: some View {
        RealityView { content in
            await setupFlowRiver(content: content)
        } update: { content in
            if let network = appState.network {
                await updateFlowRiver(content: content, network: network)
            }
        }
        .task {
            // Animation loop for flowing particles
            while true {
                try? await Task.sleep(for: .milliseconds(16)) // ~60 FPS
                animationTime += 0.016
            }
        }
    }

    @MainActor
    private func setupFlowRiver(content: RealityViewContent) async {
        let rootEntity = Entity()
        rootEntity.name = "FlowRoot"

        // Add lighting
        var lightComponent = DirectionalLightComponent()
        lightComponent.intensity = 5000
        let lightEntity = Entity()
        lightEntity.components.set(lightComponent)
        rootEntity.addChild(lightEntity)

        content.add(rootEntity)
    }

    @MainActor
    private func updateFlowRiver(content: RealityViewContent, network: SupplyChainNetwork) async {
        guard let rootEntity = content.entities.first(where: { $0.name == "FlowRoot" }) else {
            return
        }

        // Remove existing flow entities
        rootEntity.children.removeAll(where: { $0.name.hasPrefix("Flow-") })

        // Create flow visualization for each active shipment
        for flow in network.flows where flow.status == .inTransit {
            let flowEntity = createFlowEntity(flow: flow, network: network)
            rootEntity.addChild(flowEntity)
        }
    }

    @MainActor
    private func createFlowEntity(flow: Flow, network: SupplyChainNetwork) -> Entity {
        let entity = Entity()
        entity.name = "Flow-\(flow.id)"

        // Create particle-like representation
        let particleSize: Float = 0.015
        let mesh = MeshResource.generateSphere(radius: particleSize)

        // Color based on status
        let flowColor: UIColor = {
            switch flow.status {
            case .pending: return .systemBlue
            case .inTransit: return .systemGreen
            case .delayed: return .systemOrange
            case .delivered: return .systemGreen
            case .cancelled: return .systemRed
            }
        }()

        var material = PhysicallyBasedMaterial()
        material.baseColor = PhysicallyBasedMaterial.BaseColor(tint: flowColor)
        material.emissiveColor = PhysicallyBasedMaterial.EmissiveColor(color: flowColor)
        material.emissiveIntensity = 0.8

        let modelComponent = ModelComponent(mesh: mesh, materials: [material])
        entity.components.set(modelComponent)

        // Position along route based on progress
        let progress = Float(flow.actualProgress)
        let x = (progress - 0.5) * 2.5 // Move from left to right
        let y = 0.1 + sin(progress * .pi) * 0.15 // Arc trajectory
        let z: Float = 0

        entity.position = SIMD3(x: x, y: y, z: z)

        // Create trail effect with smaller particles
        for i in 1...5 {
            let trailEntity = Entity()
            let trailSize = particleSize * (1.0 - Float(i) * 0.15)
            let trailMesh = MeshResource.generateSphere(radius: trailSize)

            var trailMaterial = PhysicallyBasedMaterial()
            trailMaterial.baseColor = PhysicallyBasedMaterial.BaseColor(tint: flowColor.withAlphaComponent(1.0 - Double(i) * 0.15))
            trailMaterial.emissiveColor = PhysicallyBasedMaterial.EmissiveColor(color: flowColor)
            trailMaterial.emissiveIntensity = 0.8 * (1.0 - Float(i) * 0.15)

            trailEntity.components.set(ModelComponent(mesh: trailMesh, materials: [trailMaterial]))

            let trailProgress = progress - Float(i) * 0.05
            let trailX = (trailProgress - 0.5) * 2.5
            let trailY = 0.1 + sin(trailProgress * .pi) * 0.15

            trailEntity.position = SIMD3(x: trailX, y: trailY, z: 0)
            entity.addChild(trailEntity)
        }

        return entity
    }
}

#Preview {
    FlowRiverView()
        .environment(AppState())
}
