import SwiftUI
import RealityKit

struct ImmersiveStoreView: View {
    let storeId: UUID

    @State private var storeEntity: Entity?
    @State private var showAnalytics = false
    @State private var showCustomerFlow = false

    var body: some View {
        RealityView { content in
            // Create full-scale store
            if let entity = await createFullScaleStore(storeId: storeId) {
                content.add(entity)
                storeEntity = entity
            }

            // Add ambient lighting
            let ambientLight = AmbientLightComponent(color: .white, intensity: 1000)
            let lightEntity = Entity()
            lightEntity.components.set(ambientLight)
            content.add(lightEntity)
        } update: { content in
            // Real-time updates
        }
        .overlay(alignment: .topLeading) {
            ImmersiveControls(
                showAnalytics: $showAnalytics,
                showCustomerFlow: $showCustomerFlow
            )
            .padding(32)
        }
    }

    private func createFullScaleStore(storeId: UUID) async -> Entity? {
        // Create full-scale (1:1) store environment
        let containerEntity = Entity()

        // Create floor at actual size (20m x 30m)
        let floorMesh = MeshResource.generatePlane(width: 20, depth: 30)
        var floorMaterial = SimpleMaterial()
        floorMaterial.color = .init(tint: .gray)

        let floorEntity = ModelEntity(mesh: floorMesh, materials: [floorMaterial])
        floorEntity.position = [0, 0, 0]
        containerEntity.addChild(floorEntity)

        // Add walls
        // ... (would add actual walls here)

        // Add fixtures at real scale
        // ... (would add actual fixtures here)

        return containerEntity
    }
}

// MARK: - Immersive Controls

struct ImmersiveControls: View {
    @Binding var showAnalytics: Bool
    @Binding var showCustomerFlow: Bool

    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Immersive Walkthrough")
                .font(.headline)

            Toggle("Show Analytics", isOn: $showAnalytics)
            Toggle("Show Customer Flow", isOn: $showCustomerFlow)

            Divider()

            Button(action: { Task { await dismissImmersiveSpace() } }) {
                Label("Exit Immersive Mode", systemImage: "xmark.circle.fill")
            }
        }
        .padding()
        .glassBackgroundEffect()
    }
}
