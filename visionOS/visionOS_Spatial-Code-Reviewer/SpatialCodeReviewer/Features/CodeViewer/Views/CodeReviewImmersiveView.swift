//
//  CodeReviewImmersiveView.swift
//  SpatialCodeReviewer
//
//  Created by Claude on 2025-11-24.
//  Story 0.5: Basic 3D Code Window
//  Story 0.7: Basic Gestures
//

import SwiftUI
import RealityKit

struct CodeReviewImmersiveView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var spatialManager = SpatialManager()
    @StateObject private var gestureManager = GestureManager()

    @State private var showError = false
    @State private var errorMessage: String = ""
    @State private var showSettings = false

    var body: some View {
        ZStack {
            // 3D Reality View
            RealityView { content in
                setupScene(content: content)
            } update: { content in
                updateScene(content: content)
            }
            .task {
                await loadRepository()
            }
            .gesture(
                SpatialTapGesture()
                    .targetedToAnyEntity()
                    .onEnded { value in
                        handleTap(on: value.entity)
                    }
            )

            // Loading overlay
            if spatialManager.isLoading {
                VStack {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(1.5)

                    Text("Loading repository...")
                        .font(.headline)
                        .padding(.top)

                    Text("\(Int(spatialManager.loadingProgress * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(30)
                .background(.regularMaterial)
                .cornerRadius(20)
            }

            // Settings button overlay
            if !spatialManager.isLoading {
                SettingsButtonOverlay(showSettings: $showSettings)
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsPanelView()
        }
        .alert("Error Loading Repository", isPresented: $showError) {
            Button("OK", role: .cancel) {
                // Dismiss immersive space on error
                appState.isImmersiveSpaceActive = false
            }
        } message: {
            Text(errorMessage)
        }
    }

    // MARK: - Scene Setup

    private func setupScene(content: RealityViewContent) {
        // Add ambient light
        var ambientEntity = Entity()
        ambientEntity.name = "AmbientLight"
        let ambientLight = AmbientLightComponent(color: .white, intensity: 500)
        ambientEntity.components[AmbientLightComponent.self] = ambientLight
        content.add(ambientEntity)

        // Add directional light
        var directionalEntity = Entity()
        directionalEntity.name = "DirectionalLight"
        let directionalLight = DirectionalLightComponent(
            color: .white,
            intensity: 1000,
            isRealWorldProxy: false
        )
        directionalEntity.components[DirectionalLightComponent.self] = directionalLight
        directionalEntity.look(at: [0, 0, -1], from: [0, 2, 0], relativeTo: nil)
        content.add(directionalEntity)

        // Add point light for rim lighting
        var pointEntity = Entity()
        pointEntity.name = "PointLight"
        let pointLight = PointLightComponent(
            color: .white,
            intensity: 200,
            attenuationRadius: 5.0
        )
        pointEntity.components[PointLightComponent.self] = pointLight
        pointEntity.position = [0, 2, 1]
        content.add(pointEntity)

        print("✅ Scene lighting setup complete")
    }

    private func updateScene(content: RealityViewContent) {
        // Remove all existing code windows from content
        for entity in content.entities {
            if entity.name.hasPrefix("CodeWindow_") {
                content.remove(entity)
            }
        }

        // Add all code window entities from spatial manager
        for entity in spatialManager.getEntities() {
            content.add(entity)
        }
    }

    // MARK: - Repository Loading

    private func loadRepository() async {
        guard let repository = appState.selectedRepository else {
            errorMessage = "No repository selected"
            showError = true
            return
        }

        print("🚀 Loading repository: \(repository.fullName)")

        do {
            // Parse owner/name from fullName
            let components = repository.fullName.split(separator: "/")
            guard components.count == 2 else {
                throw SpatialManager.SpatialError.repositoryNotDownloaded
            }

            let owner = String(components[0])
            let name = String(components[1])

            // Load repository through spatial manager
            try await spatialManager.loadRepository(owner: owner, name: name)

            print("✅ Successfully loaded \(repository.name) in 3D space")

        } catch let error as SpatialManager.SpatialError {
            errorMessage = error.localizedDescription
            showError = true
        } catch {
            errorMessage = "Failed to load repository: \(error.localizedDescription)"
            showError = true
        }
    }

    // MARK: - Interaction Handling

    private func handleTap(on entity: Entity) {
        // Handle with gesture manager
        gestureManager.handleTap(on: entity)

        // Also update spatial manager
        spatialManager.focusOnEntity(entity)

        // Add haptic feedback (pulse animation)
        entity.pulse()

        // Get code window component if available
        if let codeWindow = entity.components[CodeWindowComponent.self] {
            print("📂 Tapped: \(codeWindow.fileName)")
            print("   Path: \(codeWindow.filePath)")
            print("   Type: \(codeWindow.isDirectory ? "Directory" : "File")")
            print("   Lines: \(codeWindow.lineCount)")
        }
    }
}

// MARK: - Gesture Extensions

extension CodeReviewImmersiveView {
    /// Creates drag gesture for repositioning entities
    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                // Simplified drag for MVP - full 3D drag in production
                print("🖐️ Dragging...")
            }
            .onEnded { _ in
                gestureManager.handleDragEnded()
                print("✋ Drag ended")
            }
    }

    /// Creates magnify gesture for scaling entities
    var magnifyGesture: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                let scale = Float(value.magnification)
                gestureManager.handlePinchChanged(scale: scale)
            }
            .onEnded { _ in
                gestureManager.handlePinchEnded()
            }
    }
}

// MARK: - Preview

#Preview(immersionStyle: .mixed) {
    CodeReviewImmersiveView()
        .environmentObject(AppState())
}
