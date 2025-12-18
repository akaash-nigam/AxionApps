//
//  OrganizationChartVolumeView.swift
//  Institutional Memory Vault
//
//  3D visualization of organizational structure
//

import SwiftUI
import RealityKit
import SwiftData

struct OrganizationChartVolumeView: View {
    @Query private var departments: [Department]

    var body: some View {
        RealityView { content in
            // Create hierarchical structure
            // Root node
            let rootMesh = MeshResource.generateBox(width: 0.2, height: 0.1, depth: 0.05)
            let rootMaterial = SimpleMaterial(color: .blue, isMetallic: true)
            let rootEntity = ModelEntity(mesh: rootMesh, materials: [rootMaterial])
            rootEntity.position = [0, 0.3, 0]
            content.add(rootEntity)

            // Department nodes
            for (index, _) in departments.enumerated() {
                let angle = Float(index) * (2 * .pi / Float(max(departments.count, 1)))
                let x = cos(angle) * 0.3
                let z = sin(angle) * 0.3

                let deptMesh = MeshResource.generateBox(width: 0.15, height: 0.08, depth: 0.04)
                let deptMaterial = SimpleMaterial(color: .orange, isMetallic: false)
                let deptEntity = ModelEntity(mesh: deptMesh, materials: [deptMaterial])
                deptEntity.position = [x, 0, z]
                content.add(deptEntity)
            }
        }
        .overlay(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Organization Structure")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("\(departments.count) departments")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .glassBackgroundEffect()
        }
    }
}

#Preview {
    OrganizationChartVolumeView()
}
