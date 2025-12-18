//
//  HealthLandscapeVolume.swift
//  SpatialWellness
//
//  Created by Claude on 2025-11-17.
//  Copyright © 2025 Spatial Wellness Platform. All rights reserved.
//

import SwiftUI
import RealityKit

/// Health Landscape Volume - 3D visualization of overall health
struct HealthLandscapeVolume: View {
    var body: some View {
        RealityView { content in
            // Create placeholder 3D content
            let mesh = MeshResource.generateBox(size: 0.3)
            let material = SimpleMaterial(color: .green, isMetallic: false)
            let entity = ModelEntity(mesh: mesh, materials: [material])

            entity.position = [0, 0, 0]

            content.add(entity)
        }
        .overlay(alignment: .top) {
            VStack {
                Text("Health Landscape")
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
    HealthLandscapeVolume()
}
