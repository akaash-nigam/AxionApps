//
//  ImmersivePrototypeView.swift
//  IndustrialCADCAM
//
//  Full-scale prototype immersive experience
//

import SwiftUI
import RealityKit

struct ImmersivePrototypeView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    @State private var rootEntity = Entity()
    @State private var prototypeScale: Float = 1.0

    var body: some View {
        RealityView { content in
            setupImmersiveScene(content: content)
        } update: { content in
            updateImmersiveScene(content: content)
        }
        .upperLimbVisibility(.visible)
        .persistentSystemOverlays(.hidden)
        .ornament(attachmentAnchor: .scene(.bottom)) {
            immersiveControlsOrnament
        }
    }

    // MARK: - Scene Setup

    private func setupImmersiveScene(content: RealityViewContent) {
        content.add(rootEntity)

        // Add full-scale prototype
        addFullScalePrototype()

        // Add measurement annotations
        addMeasurementAnnotations()

        // Add environmental context
        addEnvironment()
    }

    private func addFullScalePrototype() {
        // Create a sample full-scale product (e.g., 1 meter tall assembly)
        let mesh = MeshResource.generateBox(size: [0.5, 1.0, 0.3])

        var material = PhysicallyBasedMaterial()
        material.baseColor = .init(tint: .init(red: 0.8, green: 0.8, blue: 0.85, alpha: 1.0))
        material.metallic = 0.7
        material.roughness = 0.4

        let prototypeEntity = ModelEntity(mesh: mesh, materials: [material])
        prototypeEntity.position = SIMD3<Float>(0, 0.5, -1.5) // 1.5m in front of user

        // Enable physics for collision
        prototypeEntity.generateCollisionShapes(recursive: false)

        rootEntity.addChild(prototypeEntity)
    }

    private func addMeasurementAnnotations() {
        // Add 3D measurement annotations
        let annotation = createAnnotation(
            text: "1000 mm",
            position: SIMD3<Float>(0, 1.0, -1.5)
        )
        rootEntity.addChild(annotation)
    }

    private func createAnnotation(text: String, position: SIMD3<Float>) -> Entity {
        let entity = Entity()
        entity.position = position

        // TODO: Add 3D text or billboard for annotation
        // For now, just a placeholder sphere
        let mesh = MeshResource.generateSphere(radius: 0.02)
        var material = UnlitMaterial()
        material.color = .init(tint: .yellow)

        let marker = ModelEntity(mesh: mesh, materials: [material])
        entity.addChild(marker)

        return entity
    }

    private func addEnvironment() {
        // Add ground plane for context
        let groundMesh = MeshResource.generatePlane(width: 10, depth: 10)

        var groundMaterial = SimpleMaterial()
        groundMaterial.color = .init(tint: .white.withAlphaComponent(0.05))

        let ground = ModelEntity(mesh: groundMesh, materials: [groundMaterial])
        ground.position = SIMD3<Float>(0, 0, 0)

        rootEntity.addChild(ground)
    }

    private func updateImmersiveScene(content: RealityViewContent) {
        // Update scene based on state changes
    }

    // MARK: - Ornaments

    private var immersiveControlsOrnament: some View {
        HStack(spacing: 20) {
            // Scale controls
            VStack {
                Text("Scale: \(String(format: "%.1f", prototypeScale))x")
                    .font(.caption)

                HStack {
                    Button(action: { prototypeScale = max(0.1, prototypeScale - 0.1) }) {
                        Image(systemName: "minus.circle")
                    }

                    Slider(value: $prototypeScale, in: 0.1...5.0, step: 0.1)
                        .frame(width: 150)

                    Button(action: { prototypeScale = min(5.0, prototypeScale + 0.1) }) {
                        Image(systemName: "plus.circle")
                    }
                }
            }

            Divider()

            // View options
            Button(action: {}) {
                Label("Explode View", systemImage: "arrow.up.left.and.arrow.down.right")
            }
            .buttonStyle(.bordered)

            Button(action: {}) {
                Label("Annotations", systemImage: "text.bubble")
            }
            .buttonStyle(.bordered)

            Divider()

            // Exit immersive mode
            Button(action: { exitImmersiveMode() }) {
                Label("Exit", systemImage: "xmark.circle.fill")
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
        }
        .padding()
        .glassBackgroundEffect()
    }

    // MARK: - Actions

    private func exitImmersiveMode() {
        Task {
            await dismissImmersiveSpace()
        }
    }
}

#Preview {
    ImmersivePrototypeView()
}
