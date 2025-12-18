//
//  TerritoryExplorerView.swift
//  SpatialCRM
//
//  Immersive Territory Explorer view
//

import SwiftUI
import RealityKit

struct TerritoryExplorerView: View {
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    var body: some View {
        RealityView { content in
            await setupTerritoryTerrain(in: content)
        }
        .toolbar {
            ToolbarItem(placement: .bottomOrnament) {
                Button("Exit Territory") {
                    Task {
                        await dismissImmersiveSpace()
                    }
                }
                .buttonStyle(.bordered)
                .glassBackgroundEffect()
            }
        }
    }

    private func setupTerritoryTerrain(in content: RealityViewContent) async {
        // Create terrain grid
        let gridSize = 10
        for x in 0..<gridSize {
            for z in 0..<gridSize {
                let height = Float.random(in: 0...0.5)
                let box = MeshResource.generateBox(size: [0.3, height, 0.3])
                let material = SimpleMaterial(color: .green.withAlphaComponent(0.7), isMetallic: false)
                let entity = ModelEntity(mesh: box, materials: [material])
                entity.position = SIMD3(
                    Float(x - gridSize/2) * 0.35,
                    height / 2,
                    Float(z - gridSize/2) * 0.35
                )
                content.add(entity)
            }
        }
    }
}

#Preview {
    TerritoryExplorerView()
}
