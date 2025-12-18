//
//  TacticalPlanningVolume.swift
//  MilitaryDefenseTraining
//
//  Created by Claude Code
//

import SwiftUI
import RealityKit

struct TacticalPlanningVolume: View {
    let scenarioID: UUID

    @State private var rotationAngle: Double = 0
    @State private var selectedLayer: TacticalLayer = .terrain

    var body: some View {
        ZStack {
            // 3D Terrain View
            RealityView { content in
                setup3DTerrain(content: content)
            } update: { content in
                // Update terrain based on rotation, layers, etc.
            }
            .gesture(
                RotateGesture3D()
                    .onChanged { value in
                        rotationAngle = value.rotation.angle.degrees
                    }
            )

            // Layer Controls (Overlay)
            VStack {
                Spacer()

                HStack(spacing: 12) {
                    ForEach(TacticalLayer.allCases, id: \.self) { layer in
                        Button {
                            selectedLayer = layer
                        } label: {
                            VStack {
                                Image(systemName: layer.icon)
                                    .font(.title3)

                                Text(layer.rawValue)
                                    .font(.caption2)
                            }
                            .padding(8)
                            .background(selectedLayer == layer ? .blue : .clear)
                            .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                .padding()
            }
        }
    }

    private func setup3DTerrain(content: RealityViewContent) {
        // Create 3D terrain model
        // For now, placeholder cube
        let terrain = ModelEntity(
            mesh: .generateBox(size: 1.0),
            materials: [SimpleMaterial(color: .brown, isMetallic: false)]
        )
        terrain.position = [0, 0, 0]
        content.add(terrain)
    }
}

enum TacticalLayer: String, CaseIterable {
    case terrain = "Terrain"
    case intel = "Intel"
    case friendly = "Friendly"
    case objectives = "Objectives"
    case routes = "Routes"

    var icon: String {
        switch self {
        case .terrain: return "mountain.2"
        case .intel: return "eye"
        case .friendly: return "person.3"
        case .objectives: return "target"
        case .routes: return "arrow.triangle.turn.up.right.diamond"
        }
    }
}

#Preview {
    TacticalPlanningVolume(scenarioID: UUID())
}
