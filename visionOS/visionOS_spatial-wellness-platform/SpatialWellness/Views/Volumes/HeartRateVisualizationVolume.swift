//
//  HeartRateVisualizationVolume.swift
//  SpatialWellness
//
//  Created by Claude on 2025-11-17.
//  Copyright © 2025 Spatial Wellness Platform. All rights reserved.
//

import SwiftUI
import RealityKit

/// Heart Rate Visualization Volume - flowing river representation
struct HeartRateVisualizationVolume: View {
    var body: some View {
        RealityView { content in
            // Create placeholder 3D content
            let mesh = MeshResource.generateSphere(radius: 0.15)
            let material = SimpleMaterial(color: .red, isMetallic: false)
            let entity = ModelEntity(mesh: mesh, materials: [material])

            entity.position = [0, 0, 0]

            content.add(entity)
        }
        .overlay(alignment: .top) {
            VStack {
                Text("Heart Rate River")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                    .background(.ultraThinMaterial, in: Capsule())
            }
            .padding()
        }
    }
}

#Preview {
    HeartRateVisualizationVolume()
}
