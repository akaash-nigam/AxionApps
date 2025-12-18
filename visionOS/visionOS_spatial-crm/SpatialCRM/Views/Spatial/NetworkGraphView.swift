//
//  NetworkGraphView.swift
//  SpatialCRM
//
//  3D Relationship Network volume view
//

import SwiftUI
import RealityKit

struct NetworkGraphView: View {
    var body: some View {
        RealityView { content in
            await setupNetworkGraph(in: content)
        }
        .toolbar {
            ToolbarItem(placement: .bottomOrnament) {
                Text("Relationship Network")
                    .padding()
                    .glassBackgroundEffect()
            }
        }
    }

    private func setupNetworkGraph(in content: RealityViewContent) async {
        // Create sample contact nodes
        for i in 0..<8 {
            let angle = Float(i) * (2 * .pi / 8)
            let radius: Float = 0.5

            let x = radius * cos(angle)
            let z = radius * sin(angle)

            let sphere = MeshResource.generateSphere(radius: 0.08)
            let color: UIColor = i == 0 ? .systemGreen : .systemBlue
            let material = SimpleMaterial(color: color, isMetallic: true)
            let entity = ModelEntity(mesh: sphere, materials: [material])
            entity.position = SIMD3(x, 0, z)

            content.add(entity)
        }
    }
}

#Preview {
    NetworkGraphView()
}
