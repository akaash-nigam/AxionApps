//
//  TimelineRealityView.swift
//  SpatialScreenplayWorkshop
//
//  Created on 2025-11-24
//

import SwiftUI
import RealityKit

/// RealityView wrapper for spatial timeline
struct TimelineRealityView: View {
    @Environment(AppState.self) private var appState
    @Bindable var viewModel: TimelineViewModel

    var body: some View {
        RealityView { content in
            // Setup RealityKit scene
            await setupScene(content: content)
        } update: { content in
            // Update scene when project changes
            await updateScene(content: content)
        }
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    handleTap(on: value.entity)
                }
        )
        .gesture(
            LongPressGesture(minimumDuration: 0.5)
                .targetedToAnyEntity()
                .onEnded { value in
                    handleLongPress(on: value.entity)
                }
        )
    }

    // MARK: - Scene Setup

    @MainActor
    private func setupScene(content: RealityViewContent) async {
        guard let project = appState.currentProject else { return }

        // Create timeline container
        let container = TimelineContainerEntity(project: project)
        content.add(container)

        // Store reference in view model
        viewModel.timelineContainer = container

        // Position container in front of user
        var transform = Transform.identity
        transform.translation = SIMD3<Float>(0, 1.5, -3.0)  // 3m in front, 1.5m up
        container.transform = transform

        // Add ambient lighting
        await addLighting(to: content)
    }

    @MainActor
    private func updateScene(content: RealityViewContent) async {
        guard let project = appState.currentProject else { return }

        // Update timeline with new scenes
        if let container = viewModel.timelineContainer {
            container.loadScenes(from: project)
        }
    }

    @MainActor
    private func addLighting(to content: RealityViewContent) async {
        // Add directional light for card visibility
        let light = DirectionalLight()
        light.light.intensity = 1000
        light.light.color = .white
        light.shadow = DirectionalLightComponent.Shadow()

        var lightTransform = Transform.identity
        lightTransform.rotation = simd_quatf(angle: -.pi / 4, axis: [1, -1, 0])
        light.transform = lightTransform

        content.add(light)
    }

    // MARK: - Gesture Handling

    private func handleTap(on entity: Entity) {
        // Find scene card
        guard let card = findSceneCard(from: entity) else { return }

        // Select scene
        viewModel.selectScene(card.scene)

        // Highlight card
        viewModel.timelineContainer?.selectCard(for: card.scene.id)
    }

    private func handleLongPress(on entity: Entity) {
        // Find scene card
        guard let card = findSceneCard(from: entity) else { return }

        // Open editor for scene
        viewModel.openEditor(for: card.scene)
    }

    private func findSceneCard(from entity: Entity) -> SceneCardEntity? {
        var current: Entity? = entity

        while let entity = current {
            if let card = entity as? SceneCardEntity {
                return card
            }
            current = entity.parent
        }

        return nil
    }
}
