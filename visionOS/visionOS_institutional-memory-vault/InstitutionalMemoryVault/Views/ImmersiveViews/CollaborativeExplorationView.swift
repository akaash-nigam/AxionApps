//
//  CollaborativeExplorationView.swift
//  Institutional Memory Vault
//
//  Shared exploration environment for teams
//

import SwiftUI
import RealityKit

struct CollaborativeExplorationView: View {
    var body: some View {
        RealityView { content in
            // Shared space visualization
            let centerMesh = MeshResource.generateSphere(radius: 0.2)
            let centerMaterial = SimpleMaterial(color: .green, isMetallic: true)
            let center = ModelEntity(mesh: centerMesh, materials: [centerMaterial])
            content.add(center)

            // Placeholder for multiple user avatars
            let positions: [SIMD3<Float>] = [
                [0.5, 0, 0.5],
                [-0.5, 0, 0.5],
                [0.5, 0, -0.5],
                [-0.5, 0, -0.5]
            ]

            for position in positions {
                let avatarMesh = MeshResource.generateBox(width: 0.1, height: 0.2, depth: 0.1)
                let avatarMaterial = SimpleMaterial(color: .cyan, isMetallic: false)
                let avatar = ModelEntity(mesh: avatarMesh, materials: [avatarMaterial])
                avatar.position = position
                content.add(avatar)
            }
        }
        .overlay(alignment: .top) {
            Text("Collaborative Exploration")
                .font(.title)
                .fontWeight(.bold)
                .padding()
                .glassBackgroundEffect()
                .padding(.top, 50)
        }
    }
}

#Preview {
    CollaborativeExplorationView()
}
