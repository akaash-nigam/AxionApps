import SwiftUI
import RealityKit

struct StorePreviewVolume: View {
    let storeId: UUID

    @State private var storeEntity: Entity?
    @State private var showWalls = true
    @State private var showGrid = true

    var body: some View {
        RealityView { content in
            // Create 3D store model
            if let entity = await loadStoreModel(storeId: storeId) {
                content.add(entity)
                storeEntity = entity
            }

            // Add lighting
            let ambientLight = AmbientLightComponent(color: .white, intensity: 500)
            let lightEntity = Entity()
            lightEntity.components.set(ambientLight)
            content.add(lightEntity)
        } update: { content in
            // Update content as needed
        }
        .ornament(attachmentAnchor: .scene(.bottom)) {
            VolumeControls(showWalls: $showWalls, showGrid: $showGrid)
        }
    }

    private func loadStoreModel(storeId: UUID) async -> Entity? {
        // In production, load actual 3D model
        // For now, create a simple placeholder

        let containerEntity = Entity()

        // Create floor
        let floorMesh = MeshResource.generatePlane(width: 1.5, depth: 1.0)
        var floorMaterial = SimpleMaterial()
        floorMaterial.color = .init(tint: .gray.withAlphaComponent(0.3))

        let floorEntity = ModelEntity(mesh: floorMesh, materials: [floorMaterial])
        floorEntity.position = [0, 0, 0]
        containerEntity.addChild(floorEntity)

        // Create sample fixtures
        for i in 0..<5 {
            let fixtureMesh = MeshResource.generateBox(width: 0.15, height: 0.12, depth: 0.05)
            var fixtureMaterial = SimpleMaterial()
            fixtureMaterial.color = .init(tint: .blue.withAlphaComponent(0.5))

            let fixtureEntity = ModelEntity(mesh: fixtureMesh, materials: [fixtureMaterial])
            fixtureEntity.position = [Float(i) * 0.25 - 0.5, 0.06, 0]

            containerEntity.addChild(fixtureEntity)
        }

        return containerEntity
    }
}

// MARK: - Volume Controls

struct VolumeControls: View {
    @Binding var showWalls: Bool
    @Binding var showGrid: Bool

    var body: some View {
        HStack(spacing: 16) {
            Toggle("Walls", isOn: $showWalls)
            Toggle("Grid", isOn: $showGrid)

            Divider()
                .frame(height: 24)

            Button(action: {}) {
                Label("Rotate", systemImage: "arrow.triangle.2.circlepath")
            }

            Button(action: {}) {
                Label("Reset View", systemImage: "arrow.counterclockwise")
            }
        }
        .padding()
        .glassBackgroundEffect()
    }
}
