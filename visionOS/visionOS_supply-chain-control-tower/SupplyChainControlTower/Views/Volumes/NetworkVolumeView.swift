//
//  NetworkVolumeView.swift
//  SupplyChainControlTower
//
//  3D network visualization in a volume
//

import SwiftUI
import RealityKit

struct NetworkVolumeView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        RealityView { content in
            // Create the network visualization
            await setupNetworkScene(content: content)
        } update: { content in
            // Update scene when network changes
            if let network = appState.network {
                await updateNetworkScene(content: content, network: network)
            }
        }
    }

    @MainActor
    private func setupNetworkScene(content: RealityViewContent) async {
        // Create a root entity for the network
        let rootEntity = Entity()
        rootEntity.name = "NetworkRoot"

        // Add ambient lighting
        var lightComponent = DirectionalLightComponent()
        lightComponent.intensity = 5000
        let lightEntity = Entity()
        lightEntity.components.set(lightComponent)
        rootEntity.addChild(lightEntity)

        content.add(rootEntity)

        // Initial network setup
        if let network = appState.network {
            await updateNetworkScene(content: content, network: network)
        }
    }

    @MainActor
    private func updateNetworkScene(content: RealityViewContent, network: SupplyChainNetwork) async {
        guard let rootEntity = content.entities.first(where: { $0.name == "NetworkRoot" }) else {
            return
        }

        // Remove existing node entities
        rootEntity.children.removeAll(where: { $0.name.hasPrefix("Node-") })

        // Create node entities
        for node in network.nodes {
            let nodeEntity = createNodeEntity(node: node)
            rootEntity.addChild(nodeEntity)
        }

        // Create edge entities
        for edge in network.edges {
            let edgeEntity = createEdgeEntity(edge: edge, network: network)
            rootEntity.addChild(edgeEntity)
        }
    }

    @MainActor
    private func createNodeEntity(node: Node) -> Entity {
        let entity = Entity()
        entity.name = "Node-\(node.id)"

        // Create sphere mesh for the node
        let size: Float = Float(0.02 + (node.capacity.utilization * 0.05)) // 2-7cm based on utilization
        let mesh = MeshResource.generateSphere(radius: size)

        // Create material based on status
        var material = PhysicallyBasedMaterial()
        material.baseColor = PhysicallyBasedMaterial.BaseColor(tint: nodeColor(status: node.status))
        material.emissiveColor = PhysicallyBasedMaterial.EmissiveColor(color: nodeColor(status: node.status))
        material.emissiveIntensity = 0.5

        let modelComponent = ModelComponent(mesh: mesh, materials: [material])
        entity.components.set(modelComponent)

        // Position based on normalized coordinates (simplified)
        let x = Float((node.location.longitude + 180) / 360) * 2 - 1 // -1 to 1
        let y = Float(node.location.latitude / 90) * 0.5 // -0.5 to 0.5
        let z = Float(-1.0) // Fixed depth

        entity.position = SIMD3(x: x, y: y, z: z)

        // Add input target for interactions
        entity.components.set(InputTargetComponent())

        // Add hover effect
        entity.components.set(HoverEffectComponent())

        return entity
    }

    @MainActor
    private func createEdgeEntity(edge: Edge, network: SupplyChainNetwork) -> Entity {
        let entity = Entity()
        entity.name = "Edge-\(edge.id)"

        // Find source and destination nodes
        guard let sourceNode = network.nodes.first(where: { $0.id == edge.source }),
              let destNode = network.nodes.first(where: { $0.id == edge.destination }) else {
            return entity
        }

        // Create a simple line/tube between nodes
        let sourceX = Float((sourceNode.location.longitude + 180) / 360) * 2 - 1
        let sourceY = Float(sourceNode.location.latitude / 90) * 0.5
        let destX = Float((destNode.location.longitude + 180) / 360) * 2 - 1
        let destY = Float(destNode.location.latitude / 90) * 0.5

        // Create cylinder as connection
        let distance = sqrt(pow(destX - sourceX, 2) + pow(destY - sourceY, 2))
        let mesh = MeshResource.generateCylinder(height: distance, radius: 0.002)

        var material = PhysicallyBasedMaterial()
        material.baseColor = PhysicallyBasedMaterial.BaseColor(tint: .gray)
        material.metallic = 0.3
        material.roughness = 0.6

        let modelComponent = ModelComponent(mesh: mesh, materials: [material])
        entity.components.set(modelComponent)

        // Position and rotate to connect nodes
        let midX = (sourceX + destX) / 2
        let midY = (sourceY + destY) / 2
        entity.position = SIMD3(x: midX, y: midY, z: -1.0)

        return entity
    }

    private func nodeColor(status: NodeStatus) -> UIColor {
        switch status {
        case .healthy: return .systemGreen
        case .warning: return .systemYellow
        case .critical: return .systemRed
        case .offline: return .systemGray
        }
    }
}

#Preview {
    NetworkVolumeView()
        .environment(AppState())
}
