//
//  TimelineViewModel.swift
//  SpatialScreenplayWorkshop
//
//  Created on 2025-11-24
//

import Foundation
import SwiftUI

/// View model for spatial timeline
@Observable
@MainActor
final class TimelineViewModel {
    // MARK: - Properties

    var appState: AppState?
    var timelineContainer: TimelineContainerEntity?

    var selectedScene: Scene?
    var viewMode: TimelineViewMode = .byAct
    var filterStatus: SceneStatus?

    // MARK: - Setup

    func setup(appState: AppState) {
        self.appState = appState
    }

    // MARK: - Scene Selection

    func selectScene(_ scene: Scene) {
        selectedScene = scene

        // Update selection in RealityKit
        timelineContainer?.selectCard(for: scene.id)

        // Notify app state
        appState?.selectScene(scene)
    }

    func deselectScene() {
        selectedScene = nil
        timelineContainer?.deselectAll()
    }

    // MARK: - Navigation

    func openEditor(for scene: Scene) {
        appState?.selectScene(scene)
        appState?.navigateTo(.scriptEditor)
    }

    // MARK: - Scene Management

    func addNewScene() {
        guard let appState = appState else { return }

        Task {
            do {
                try await appState.addScene()

                // Reload timeline
                if let project = appState.currentProject,
                   let container = timelineContainer {
                    container.loadScenes(from: project)
                }
            } catch {
                print("Failed to add scene: \(error)")
            }
        }
    }

    func deleteScene(_ scene: Scene) {
        guard let appState = appState else { return }

        Task {
            do {
                try await appState.deleteScene(scene)

                // Update timeline
                timelineContainer?.removeScene(scene.id)

                // Clear selection if deleted scene was selected
                if selectedScene?.id == scene.id {
                    deselectScene()
                }
            } catch {
                print("Failed to delete scene: \(error)")
            }
        }
    }

    func duplicateScene(_ scene: Scene) {
        guard let appState = appState,
              let project = appState.currentProject else { return }

        Task {
            do {
                // Create duplicate
                let duplicate = Scene(
                    sceneNumber: (project.scenes?.count ?? 0) + 1,
                    slugLine: scene.slugLine,
                    content: scene.content,
                    position: ScenePosition(
                        act: scene.position.act,
                        sequence: scene.position.sequence
                    ),
                    metadata: scene.metadata
                )

                try await appState.addScene(duplicate)

                // Reload timeline
                if let container = timelineContainer {
                    container.loadScenes(from: project)
                }
            } catch {
                print("Failed to duplicate scene: \(error)")
            }
        }
    }

    // MARK: - Reordering

    func moveScene(_ scene: Scene, to targetIndex: Int) {
        guard let appState = appState,
              var scenes = appState.currentProject?.scenes else { return }

        // Reorder scenes
        timelineContainer?.moveCard(from: scene.id, to: targetIndex, in: &scenes)

        // Save changes
        Task {
            try? await appState.saveCurrentProject()
        }
    }

    // MARK: - Filtering

    var filteredScenes: [Scene] {
        guard let project = appState?.currentProject,
              let scenes = project.scenes else {
            return []
        }

        if let status = filterStatus {
            return scenes.filter { $0.status == status }
        }

        return scenes
    }

    // MARK: - View Mode Changes

    func changeViewMode(_ mode: TimelineViewMode) {
        viewMode = mode

        // Trigger re-layout in RealityKit
        if let project = appState?.currentProject,
           let container = timelineContainer {
            container.loadScenes(from: project)
        }
    }

    // MARK: - Statistics

    var totalScenes: Int {
        appState?.currentProject?.scenes?.count ?? 0
    }

    var scenesByAct: [Int: Int] {
        guard let scenes = appState?.currentProject?.scenes else {
            return [:]
        }

        return Dictionary(grouping: scenes) { $0.position.act }
            .mapValues { $0.count }
    }

    var totalPages: Double {
        guard let scenes = appState?.currentProject?.scenes else {
            return 0
        }

        return scenes.reduce(0) { $0 + $1.pageLength }
    }
}
