//
//  InventoryLandscapeView.swift
//  SupplyChainControlTower
//
//  3D terrain visualization of inventory levels
//

import SwiftUI
import RealityKit

struct InventoryLandscapeView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        RealityView { content in
            await setupInventoryLandscape(content: content)
        } update: { content in
            if let network = appState.network {
                await updateInventoryLandscape(content: content, network: network)
            }
        }
    }

    @MainActor
    private func setupInventoryLandscape(content: RealityViewContent) async {
        let rootEntity = Entity()
        rootEntity.name = "InventoryRoot"

        // Add lighting
        var lightComponent = DirectionalLightComponent()
        lightComponent.intensity = 5000
        let lightEntity = Entity()
        lightEntity.components.set(lightComponent)
        rootEntity.addChild(lightEntity)

        content.add(rootEntity)
    }

    @MainActor
    private func updateInventoryLandscape(content: RealityViewContent, network: SupplyChainNetwork) async {
        guard let rootEntity = content.entities.first(where: { $0.name == "InventoryRoot" }) else {
            return
        }

        // Remove existing terrain
        rootEntity.children.removeAll(where: { $0.name.hasPrefix("Terrain-") })

        // Create terrain visualization for each node with inventory
        for (index, node) in network.nodes.enumerated() where !node.inventory.isEmpty {
            let terrainEntity = createTerrainEntity(node: node, index: index)
            rootEntity.addChild(terrainEntity)
        }
    }

    @MainActor
    private func createTerrainEntity(node: Node, index: Int) -> Entity {
        let entity = Entity()
        entity.name = "Terrain-\(node.id)"

        // Calculate total inventory value
        let totalValue = node.inventory.reduce(0.0) { $0 + $1.value }
        let totalQuantity = node.inventory.reduce(0.0) { $0 + $1.quantity }

        // Height represents stock level (normalized)
        let height = Float(min(totalQuantity / 1000.0, 1.0)) * 0.3 // Max 30cm

        // Create box as simplified terrain
        let mesh = MeshResource.generateBox(width: 0.15, height: height, depth: 0.15)

        // Color based on inventory turnover
        let avgTurnover = node.inventory.reduce(0.0) { $0 + $1.turnoverRate } / Double(max(node.inventory.count, 1))
        let terrainColor = turnoverColor(rate: avgTurnover)

        var material = PhysicallyBasedMaterial()
        material.baseColor = PhysicallyBasedMaterial.BaseColor(tint: terrainColor)
        material.roughness = 0.8

        let modelComponent = ModelComponent(mesh: mesh, materials: [material])
        entity.components.set(modelComponent)

        // Position in grid
        let gridSize = 4
        let row = index / gridSize
        let col = index % gridSize
        let spacing: Float = 0.35

        let x = Float(col) * spacing - (Float(gridSize) * spacing / 2)
        let y = height / 2 // Align bottom to y=0
        let z = Float(row) * spacing - 0.5

        entity.position = SIMD3(x: x, y: y, z: z)

        return entity
    }

    private func turnoverColor(rate: Double) -> UIColor {
        // Green for high turnover, yellow for medium, red for low
        if rate > 0.7 {
            return .systemGreen
        } else if rate > 0.4 {
            return .systemYellow
        } else {
            return .systemRed
        }
    }
}

#Preview {
    InventoryLandscapeView()
        .environment(AppState())
}
