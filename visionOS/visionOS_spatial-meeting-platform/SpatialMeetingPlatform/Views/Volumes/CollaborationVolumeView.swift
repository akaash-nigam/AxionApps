//
//  CollaborationVolumeView.swift
//  SpatialMeetingPlatform
//
//  3D whiteboard and collaboration volume
//

import SwiftUI
import RealityKit

struct CollaborationVolumeView: View {

    @Environment(AppModel.self) private var appModel
    @State private var drawingStrokes: [DrawingStroke] = []

    var body: some View {
        RealityView { content in
            await setupWhiteboard(content: content)
        } update: { content in
            updateDrawing(content: content)
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .targetedToAnyEntity()
                .onChanged { value in
                    handleDrawGesture(value)
                }
        )
    }

    // MARK: - Setup

    private func setupWhiteboard(content: RealityViewContent) async {
        // Create whiteboard surface
        let whiteboardEntity = createWhiteboardSurface()
        content.add(whiteboardEntity)

        // Add drawing tools
        let toolbar = createToolbar()
        content.add(toolbar)
    }

    private func updateDrawing(content: RealityViewContent) {
        // Update drawing strokes
        // In real implementation: Render new strokes in 3D space
    }

    // MARK: - Entity Creation

    private func createWhiteboardSurface() -> Entity {
        let whiteboardEntity = Entity()

        // Create board surface
        let boardMesh = MeshResource.generatePlane(width: 1.5, height: 1.0)
        let boardMaterial = SimpleMaterial(
            color: .white,
            isMetallic: false
        )
        let board = ModelEntity(mesh: boardMesh, materials: [boardMaterial])

        whiteboardEntity.addChild(board)
        whiteboardEntity.position = SIMD3(0, 1.5, -1.5)

        return whiteboardEntity
    }

    private func createToolbar() -> Entity {
        let toolbarEntity = Entity()

        // Create toolbar background
        let toolbarMesh = MeshResource.generatePlane(width: 0.6, height: 0.1)
        let toolbarMaterial = SimpleMaterial(
            color: .gray.withAlphaComponent(0.8),
            isMetallic: false
        )
        let toolbar = ModelEntity(mesh: toolbarMesh, materials: [toolbarMaterial])

        toolbarEntity.addChild(toolbar)
        toolbarEntity.position = SIMD3(0, 0.8, -1.5)

        return toolbarEntity
    }

    // MARK: - Gesture Handling

    private func handleDrawGesture(_ value: EntityTargetValue<DragGesture.Value>) {
        // Extract 3D position from gesture
        let location = value.location3D

        // Add to drawing strokes
        // In real implementation: Create stroke entity and sync with other participants

        print("Drawing at: \(location)")
    }
}

struct DrawingStroke {
    var points: [SIMD3<Float>]
    var color: Color
    var thickness: Float
    var authorID: UUID
    var timestamp: Date
}

#Preview {
    CollaborationVolumeView()
        .environment(AppModel())
}
