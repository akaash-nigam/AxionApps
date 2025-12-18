//
//  VirtualGymView.swift
//  SpatialWellness
//
//  Created by Claude on 2025-11-17.
//  Copyright © 2025 Spatial Wellness Platform. All rights reserved.
//

import SwiftUI
import RealityKit

/// Virtual Gym - immersive workout space
struct VirtualGymView: View {
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    var body: some View {
        RealityView { content in
            // Create gym environment
            // For now, placeholder
        }
        .overlay(alignment: .topTrailing) {
            Button {
                Task {
                    await dismissImmersiveSpace()
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .padding()
                    .background(.ultraThinMaterial, in: Circle())
            }
            .padding()
        }
        .overlay(alignment: .bottom) {
            VStack {
                Text("Virtual Gym")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Let's workout!")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(.ultraThinMaterial, in: Capsule())
            .padding()
        }
    }
}

#Preview {
    VirtualGymView()
}
