//
//  AppState.swift
//  SpatialScreenplayWorkshop
//
//  Created on 2025-11-24
//

import Foundation
import SwiftData
import Observation

/// Global application state
@Observable
@MainActor
final class AppState {
    // MARK: - Properties

    /// Current project being edited
    var currentProject: Project?

    /// Current scene being edited
    var currentScene: Scene?

    /// Current view in the app
    var currentView: AppView = .projectList

    /// Whether immersive space is active
    var isImmersive: Bool = false

    /// Auto-save manager
    let autoSaveManager = AutoSaveManager()

    /// Model container
    let modelContainer: ModelContainer

    /// Project store for data operations
    private var projectStore: ProjectStore?

    // MARK: - Initialization

    init(modelContainer: ModelContainer = .shared) {
        self.modelContainer = modelContainer
        self.projectStore = ProjectStore(modelContainer: modelContainer)
    }

    // MARK: - Project Management

    /// Load a project
    func loadProject(_ project: Project) async {
        currentProject = project
        autoSaveManager.stop()

        if let store = projectStore {
            autoSaveManager.start(projectId: project.id, store: store)
        }

        // Load first scene if available
        if let firstScene = project.scenes?.first {
            currentScene = firstScene
        }
    }

    /// Create a new project
    func createProject(title: String, type: ProjectType, author: String) async throws {
        guard let store = projectStore else { return }

        let project = Project.blank(title: title, type: type, author: author)

        // Add initial blank scene
        let scene = Scene.blank(number: 1, act: 1)
        scene.project = project
        project.scenes = [scene]

        try await store.save(project)

        await loadProject(project)
        navigateTo(.timeline)
    }

    /// Delete a project
    func deleteProject(_ project: Project) async throws {
        guard let store = projectStore else { return }

        try await store.delete(id: project.id)

        if currentProject?.id == project.id {
            currentProject = nil
            currentScene = nil
            autoSaveManager.stop()
            navigateTo(.projectList)
        }
    }

    /// Save current project
    func saveCurrentProject() async throws {
        guard let project = currentProject,
              let store = projectStore else { return }

        try await store.update(project)
        autoSaveManager.markSaved()
    }

    // MARK: - Scene Management

    /// Select a scene
    func selectScene(_ scene: Scene) {
        currentScene = scene
        autoSaveManager.markChanged()
    }

    /// Add a new scene to current project
    func addScene() async throws {
        guard let project = currentProject,
              let store = projectStore else { return }

        let sceneNumber = (project.scenes?.count ?? 0) + 1
        let scene = Scene.blank(number: sceneNumber, act: 1)

        try await store.addScene(scene, to: project)

        currentScene = scene
        autoSaveManager.markChanged()
    }

    /// Delete a scene
    func deleteScene(_ scene: Scene) async throws {
        guard let project = currentProject,
              let store = projectStore else { return }

        try await store.deleteScene(scene, from: project)

        if currentScene?.id == scene.id {
            currentScene = project.scenes?.first
        }

        autoSaveManager.markChanged()
    }

    // MARK: - Navigation

    /// Navigate to a different view
    func navigateTo(_ view: AppView) {
        currentView = view

        // Update immersive state based on view
        switch view {
        case .scriptEditor:
            isImmersive = true
        case .timeline:
            isImmersive = false
        default:
            isImmersive = false
        }
    }

    /// Go back to previous view
    func goBack() {
        switch currentView {
        case .scriptEditor:
            navigateTo(.timeline)
        case .timeline:
            navigateTo(.projectList)
        case .projectList:
            break  // Already at root
        }
    }

    // MARK: - Change Tracking

    /// Mark that content has changed
    func markChanged() {
        autoSaveManager.markChanged()
    }

    // MARK: - Cleanup

    /// Clean up resources
    func cleanup() {
        autoSaveManager.stop()
        currentProject = nil
        currentScene = nil
    }
}

// MARK: - App View

/// Available views in the application
enum AppView {
    case projectList
    case timeline
    case scriptEditor
}

// MARK: - Preview Support

extension AppState {
    static var preview: AppState {
        let state = AppState(modelContainer: .preview)
        Task { @MainActor in
            // Set up preview state
            if let store = state.projectStore {
                let projects = try? await store.fetchAll()
                state.currentProject = projects?.first
                state.currentScene = state.currentProject?.scenes?.first
            }
        }
        return state
    }
}
