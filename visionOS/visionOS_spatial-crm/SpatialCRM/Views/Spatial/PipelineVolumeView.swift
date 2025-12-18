//
//  PipelineVolumeView.swift
//  SpatialCRM
//
//  3D Pipeline River volume view
//

import SwiftUI
import RealityKit

struct PipelineVolumeView: View {
    @State private var opportunities: [Opportunity] = []

    var body: some View {
        RealityView { content in
            await setupPipelineRiver(in: content)
        }
        .toolbar {
            ToolbarItem(placement: .bottomOrnament) {
                VStack {
                    Text("Pipeline River")
                        .font(.headline)
                    Text("Drag deals between stages")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .glassBackgroundEffect()
            }
        }
    }

    private func setupPipelineRiver(in content: RealityViewContent) async {
        // Create stage lanes
        for stage in DealStage.allCases.prefix(6) {  // Exclude closed
            let y = Float(stage.rawValue) * 0.5
            let plane = MeshResource.generatePlane(width: 2.0, depth: 0.3)
            let material = SimpleMaterial(color: .blue.withAlphaComponent(0.2), isMetallic: false)
            let stageEntity = ModelEntity(mesh: plane, materials: [material])
            stageEntity.position = SIMD3(0, y, 0)
            content.add(stageEntity)
        }

        // Add sample deal "boats"
        for i in 0..<5 {
            let box = MeshResource.generateBox(size: 0.2)
            let material = SimpleMaterial(color: .orange, isMetallic: true)
            let dealEntity = ModelEntity(mesh: box, materials: [material])
            dealEntity.position = SIMD3(Float.random(in: -0.5...0.5), Float(i) * 0.5, 0)
            content.add(dealEntity)
        }
    }
}

#Preview {
    PipelineVolumeView()
}
