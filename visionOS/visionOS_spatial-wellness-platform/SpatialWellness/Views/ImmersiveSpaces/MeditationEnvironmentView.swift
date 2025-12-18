//
//  MeditationEnvironmentView.swift
//  SpatialWellness
//
//  Created by Claude on 2025-11-17.
//  Copyright © 2025 Spatial Wellness Platform. All rights reserved.
//

import SwiftUI
import RealityKit

/// Meditation Environment - immersive meditation space
struct MeditationEnvironmentView: View {
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    var body: some View {
        RealityView { content in
            // Create peaceful environment
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
                Text("Meditation Temple")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Find your calm")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(.ultraThinMaterial, in: Capsule())
            .padding()
        }
    }
}

#Preview {
    MeditationEnvironmentView()
}
