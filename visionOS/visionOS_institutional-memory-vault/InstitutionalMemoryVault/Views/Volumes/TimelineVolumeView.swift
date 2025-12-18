//
//  TimelineVolumeView.swift
//  Institutional Memory Vault
//
//  3D temporal visualization of knowledge over time
//

import SwiftUI
import RealityKit

struct TimelineVolumeView: View {
    var body: some View {
        RealityView { content in
            // Create timeline spine
            let spineMesh = MeshResource.generateBox(width: 1.0, height: 0.02, depth: 0.02)
            let spineMaterial = SimpleMaterial(color: .gray, isMetallic: true)
            let spineEntity = ModelEntity(mesh: spineMesh, materials: [spineMaterial])
            content.add(spineEntity)

            // Add time markers
            for i in 0..<10 {
                let x = Float(i - 5) * 0.1
                let markerMesh = MeshResource.generateSphere(radius: 0.03)
                let markerMaterial = SimpleMaterial(color: .purple, isMetallic: false)
                let markerEntity = ModelEntity(mesh: markerMesh, materials: [markerMaterial])
                markerEntity.position = [x, 0, 0]
                content.add(markerEntity)
            }
        }
        .overlay(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Knowledge Timeline")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Journey through organizational history")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .glassBackgroundEffect()
        }
    }
}

#Preview {
    TimelineVolumeView()
}
