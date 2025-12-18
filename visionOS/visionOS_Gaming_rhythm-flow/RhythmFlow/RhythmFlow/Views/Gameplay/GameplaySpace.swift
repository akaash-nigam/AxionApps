//
//  GameplaySpace.swift
//  RhythmFlow
//
//  Immersive gameplay space
//

import SwiftUI
import RealityKit

struct GameplaySpace: View {
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        RealityView { content in
            // Setup 3D scene
            await setupGameplayScene(content)
        } update: { content in
            // Update scene based on state changes
        }
        .overlay(alignment: .top) {
            // HUD overlay
            GameplayHUD()
        }
        .persistentSystemOverlays(.hidden)
    }

    // MARK: - Scene Setup
    private func setupGameplayScene(_ content: RealityViewContent) async {
        print("🎮 Setting up gameplay scene")

        // Create root entity
        let rootEntity = Entity()
        rootEntity.name = "GameRoot"

        // Add environment
        let environment = await createEnvironment()
        rootEntity.addChild(environment)

        // Add gameplay area
        let gameplayArea = createGameplayArea()
        rootEntity.addChild(gameplayArea)

        // Add to content
        content.add(rootEntity)

        print("✅ Gameplay scene setup complete")
    }

    // MARK: - Environment
    private func createEnvironment() async -> Entity {
        let environment = Entity()
        environment.name = "Environment"

        // Create skybox
        let skybox = Entity()
        skybox.name = "Skybox"

        // Add gradient background
        // TODO: Add actual skybox material

        environment.addChild(skybox)

        return environment
    }

    // MARK: - Gameplay Area
    private func createGameplayArea() -> Entity {
        let gameplayArea = Entity()
        gameplayArea.name = "GameplayArea"

        // Create note spawn zones
        let centerZone = createNoteZone(at: SIMD3<Float>(0, 1.5, 0.8))
        gameplayArea.addChild(centerZone)

        // Add visual guides (for debugging)
        let targetLine = createTargetLine()
        gameplayArea.addChild(targetLine)

        return gameplayArea
    }

    private func createNoteZone(at position: SIMD3<Float>) -> Entity {
        let zone = Entity()
        zone.name = "NoteZone"
        zone.position = position

        return zone
    }

    private func createTargetLine() -> Entity {
        let line = Entity()
        line.name = "TargetLine"

        // Create a visual line where notes should be hit
        let mesh = MeshResource.generateBox(
            width: 2.0,
            height: 0.01,
            depth: 0.01
        )

        var material = SimpleMaterial()
        material.color = .init(tint: .cyan.withAlphaComponent(0.3))

        line.components.set(ModelComponent(
            mesh: mesh,
            materials: [material]
        ))

        line.position = SIMD3<Float>(0, 1.5, 0.8)

        return line
    }
}

// MARK: - Gameplay HUD

struct GameplayHUD: View {
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        VStack {
            HStack {
                // Score display
                scoreDisplay

                Spacer()

                // Combo display
                comboDisplay
            }
            .padding()

            Spacer()
        }
    }

    private var scoreDisplay: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("SCORE")
                .font(.caption)
                .foregroundColor(.secondary)

            Text("0")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.cyan, .blue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }

    private var comboDisplay: some View {
        VStack(spacing: 5) {
            Text("COMBO")
                .font(.caption)
                .foregroundColor(.secondary)

            Text("0x")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.orange)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

// MARK: - Song Preview Volume

struct SongPreviewVolume: View {
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        RealityView { content in
            // Create 3D preview
            let preview = createSongPreview()
            content.add(preview)
        }
    }

    private func createSongPreview() -> Entity {
        let preview = Entity()

        // TODO: Add 3D visualization of song
        // For now, just a placeholder sphere

        let mesh = MeshResource.generateSphere(radius: 0.2)
        var material = SimpleMaterial()
        material.color = .init(tint: .cyan)

        preview.components.set(ModelComponent(
            mesh: mesh,
            materials: [material]
        ))

        return preview
    }
}

// MARK: - Preview

#Preview {
    GameplaySpace()
        .environment(AppCoordinator())
}
