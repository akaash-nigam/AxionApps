//
//  MemoryPalaceImmersiveView.swift
//  Institutional Memory Vault
//
//  Immersive memory palace environment
//

import SwiftUI
import RealityKit

struct MemoryPalaceImmersiveView: View {
    var body: some View {
        RealityView { content in
            // Create floor
            let floorMesh = MeshResource.generatePlane(width: 10, depth: 10)
            let floorMaterial = SimpleMaterial(color: .gray.withAlphaComponent(0.3), isMetallic: true)
            let floor = ModelEntity(mesh: floorMesh, materials: [floorMaterial])
            floor.position.y = -0.5
            content.add(floor)

            // Central atrium marker
            let atriumMesh = MeshResource.generateCylinder(height: 2, radius: 0.5)
            let atriumMaterial = SimpleMaterial(color: .blue.withAlphaComponent(0.5), isMetallic: false)
            let atrium = ModelEntity(mesh: atriumMesh, materials: [atriumMaterial])
            atrium.position = [0, 0, 0]
            content.add(atrium)

            // Temporal hall indicators (4 directions)
            let directions: [(Float, Float)] = [(3, 0), (-3, 0), (0, 3), (0, -3)]
            for (x, z) in directions {
                let pillarMesh = MeshResource.generateBox(width: 0.2, height: 1.5, depth: 0.2)
                let pillarMaterial = SimpleMaterial(color: .purple, isMetallic: true)
                let pillar = ModelEntity(mesh: pillarMesh, materials: [pillarMaterial])
                pillar.position = [x, 0, z]
                content.add(pillar)
            }
        }
        .overlay(alignment: .bottom) {
            VStack(spacing: 10) {
                Text("Welcome to the Memory Palace")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Explore organizational wisdom through time and space")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 20) {
                    Button("Temporal Halls") {
                        // Navigate to temporal halls
                    }

                    Button("Department Wings") {
                        // Navigate to department wings
                    }

                    Button("Decision Chambers") {
                        // Navigate to decision chambers
                    }
                }
                .buttonStyle(.bordered)
            }
            .padding(30)
            .glassBackgroundEffect()
            .padding(.bottom, 50)
        }
    }
}

#Preview {
    MemoryPalaceImmersiveView()
}
