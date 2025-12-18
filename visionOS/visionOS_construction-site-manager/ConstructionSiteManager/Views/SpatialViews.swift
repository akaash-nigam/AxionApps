//
//  SpatialViews.swift
//  Construction Site Manager
//
//  Spatial (3D/AR) views
//

import SwiftUI
import RealityKit

// MARK: - Site Overview Volume

struct SiteOverviewVolumeView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        RealityView { content in
            // Create root entity
            let rootEntity = Entity()

            // Add placeholder 3D content
            let box = ModelEntity(
                mesh: .generateBox(size: 0.5),
                materials: [SimpleMaterial(color: .blue, isMetallic: false)]
            )
            box.position = [0, 0, 0]

            rootEntity.addChild(box)
            content.add(rootEntity)
        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomOrnament) {
                HStack(spacing: 16) {
                    Button("Layers") {
                        // Show layer controls
                    }

                    Button("Timeline") {
                        // Show timeline scrubber
                    }

                    Button("Filter") {
                        // Show filters
                    }
                }
            }
        }
    }
}

// MARK: - AR Site Overlay

struct ARSiteOverlayView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        RealityView { content in
            // AR content will be added here
            // This would include:
            // - BIM model overlay
            // - Progress visualization
            // - Safety zones
            // - Annotations

            let placeholder = ModelEntity(
                mesh: .generateSphere(radius: 0.1),
                materials: [SimpleMaterial(color: .green, isMetallic: false)]
            )
            placeholder.position = [0, 1.5, -2]

            content.add(placeholder)
        }
        .upperLimbVisibility(.visible)
        .toolbar {
            ToolbarItemGroup(placement: .bottomOrnament) {
                HStack(spacing: 12) {
                    Toggle(isOn: .constant(true)) {
                        Label("BIM", systemImage: "cube")
                    }
                    .toggleStyle(.button)

                    Toggle(isOn: .constant(true)) {
                        Label("Safety", systemImage: "shield")
                    }
                    .toggleStyle(.button)

                    Toggle(isOn: .constant(true)) {
                        Label("Progress", systemImage: "chart.bar")
                    }
                    .toggleStyle(.button)

                    Divider()

                    Button {
                        // Measure tool
                    } label: {
                        Label("Measure", systemImage: "ruler")
                    }

                    Button {
                        // Annotate
                    } label: {
                        Label("Note", systemImage: "note.text")
                    }

                    Button {
                        // Create issue
                    } label: {
                        Label("Issue", systemImage: "exclamationmark.triangle")
                    }
                }
            }
        }
    }
}

// MARK: - Full Immersive Experience

struct ImmersiveExperienceView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        RealityView { content in
            // Full immersive environment
            // Training scenarios, client presentations, etc.

            let environment = Entity()

            // Add environment content
            let ground = ModelEntity(
                mesh: .generatePlane(width: 10, depth: 10),
                materials: [SimpleMaterial(color: .gray, isMetallic: false)]
            )
            ground.position = [0, 0, 0]

            environment.addChild(ground)
            content.add(environment)
        }
    }
}

#Preview("Volume") {
    SiteOverviewVolumeView()
        .environment(AppState())
}

#Preview("AR Overlay") {
    ARSiteOverlayView()
        .environment(AppState())
}
