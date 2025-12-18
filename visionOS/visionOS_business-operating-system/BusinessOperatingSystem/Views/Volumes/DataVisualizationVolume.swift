//
//  DataVisualizationVolume.swift
//  BusinessOperatingSystem
//
//  Created by BOS Team on 2025-01-20.
//

import SwiftUI
import RealityKit

struct DataVisualizationVolume: View {
    let visualizationID: Visualization.ID

    var body: some View {
        RealityView { content in
            // Create 3D data visualization
            await createVisualization(content: content)
        }
    }

    private func createVisualization(content: RealityViewContent) async {
        // Placeholder visualization
        let mesh = MeshResource.generateSphere(radius: 0.3)
        var material = SimpleMaterial(color: .green, isMetallic: false)

        let entity = ModelEntity(mesh: mesh, materials: [material])
        entity.position = [0, 0, -1]

        content.add(entity)
    }
}
